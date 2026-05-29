import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_theme.dart';
import '../../data/models/category.dart';
import '../../providers/access_tier_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _activeType => _tabController.index == 0 ? 'expense' : 'income';

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(child: _TabLabel(symbol: '−', label: 'Expense')),
            Tab(child: _TabLabel(symbol: '+', label: 'Income')),
          ],
        ),
      ),
      body: catsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cats) {
          final bottomPad = MediaQuery.paddingOf(context).bottom;
          return TabBarView(
            controller: _tabController,
            children: [
              _CategoryIndex(
                allCats: cats,
                sectionType: 'expense',
                bottomPad: bottomPad,
              ),
              _CategoryIndex(
                allCats: cats,
                sectionType: 'income',
                bottomPad: bottomPad,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!ref.read(accessTierProvider).canCustomCategories) {
            context.push('/paywall');
            return;
          }
          context.push('/categories/edit', extra: {'defaultType': _activeType});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String symbol;
  final String label;
  const _TabLabel({required this.symbol, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(symbol,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, height: 1)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _CategoryIndex extends ConsumerWidget {
  final List<Category> allCats;
  final String sectionType; // 'expense' or 'income'
  final double bottomPad;

  const _CategoryIndex({
    required this.allCats,
    required this.sectionType,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoped = allCats
        .where((c) =>
            c.transactionType == sectionType || c.transactionType == null)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (scoped.isEmpty) {
      return Center(
        child: Text(
          'No ${sectionType == 'expense' ? 'expense' : 'income'} categories yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    final spendAsync = ref.watch(sectionType == 'expense'
        ? categorySpendThisPeriodProvider
        : categoryIncomeThisPeriodProvider);

    final spend = spendAsync.asData?.value ?? const <String, double>{};
    final total = spend.values.fold<double>(0, (a, b) => a + b);

    final active = scoped.where((c) => (spend[c.uuid] ?? 0) > 0).toList()
      ..sort((a, b) =>
          (spend[b.uuid] ?? 0).compareTo(spend[a.uuid] ?? 0));
    final unused = scoped.where((c) => (spend[c.uuid] ?? 0) == 0).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 80),
      children: [
        _SummaryStrip(
          total: total,
          activeCount: active.length,
        ),
        const SizedBox(height: 4),
        for (final cat in active)
          _IndexRow(
            category: cat,
            amount: spend[cat.uuid] ?? 0,
            total: total,
          ),
        if (unused.isNotEmpty) ...[
          const SizedBox(height: 18),
          _UnusedHeader(count: unused.length),
          const SizedBox(height: 4),
          for (final cat in unused)
            _IndexRow(
              category: cat,
              amount: 0,
              total: total,
              dim: true,
            ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryStrip extends StatelessWidget {
  final double total;
  final int activeCount;
  const _SummaryStrip({required this.total, required this.activeCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAY · SPEND',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fmt(total),
                  style: GoogleFonts.dmMono(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$activeCount active',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _UnusedHeader extends StatelessWidget {
  final int count;
  const _UnusedHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'UNUSED THIS MONTH · $count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _IndexRow extends StatelessWidget {
  final Category category;
  final double amount;
  final double total;
  final bool dim;

  const _IndexRow({
    required this.category,
    required this.amount,
    required this.total,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = AppTheme.categoryBarColor(
      uuid: category.uuid,
      colorValue: category.colorValue,
      colorScheme: cs,
    );
    final iconData =
        IconData(category.iconCodePoint, fontFamily: category.iconFontFamily);
    final pct = (total > 0 && amount > 0) ? amount / total : 0.0;
    final opacity = dim ? 0.55 : 1.0;

    return InkWell(
      onTap: () => GoRouter.of(context)
          .push('/categories/edit', extra: category),
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 3px color sliver
              Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              // Icon
              Icon(iconData, color: color, size: 20),
              const SizedBox(width: 14),
              // Name + share bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface,
                            letterSpacing: -0.1,
                          ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 2,
                        backgroundColor:
                            cs.onSurface.withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount + %
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amount > 0 ? _fmt(amount) : '—',
                    style: GoogleFonts.dmMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: amount > 0
                          ? cs.onSurface
                          : cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    amount > 0
                        ? '${(pct * 100).toStringAsFixed(0)}% of spend'
                        : 'unused',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.2,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _fmt(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '$whole.${parts[1]}';
}
