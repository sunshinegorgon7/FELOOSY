import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_theme.dart';
import '../../data/models/category.dart';
import '../../providers/categories_provider.dart';
import '../../providers/purchase_provider.dart';

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

  String get _activeType =>
      _tabController.index == 0 ? 'expense' : 'income';

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '−',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, height: 1),
                  ),
                  SizedBox(width: 6),
                  Text('Expense'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, height: 1),
                  ),
                  SizedBox(width: 6),
                  Text('Income'),
                ],
              ),
            ),
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
              _CategorySectionList(
                allCats: cats,
                sectionType: 'expense',
                bottomPad: bottomPad,
              ),
              _CategorySectionList(
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
          final isPurchased =
              ref.read(purchaseProvider).valueOrNull ?? false;
          if (!isPurchased) {
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

// ---------------------------------------------------------------------------

class _CategorySectionList extends ConsumerWidget {
  final List<Category> allCats;
  final String sectionType; // 'expense' or 'income'
  final double bottomPad;

  const _CategorySectionList({
    required this.allCats,
    required this.sectionType,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typed = allCats
        .where((c) => c.transactionType == sectionType)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final both = allCats
        .where((c) => c.transactionType == null)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (typed.isEmpty && both.isEmpty) {
      return Center(
        child: Text(
          'No ${sectionType == 'expense' ? 'expense' : 'income'} categories yet.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 80),
      children: [
        if (typed.isNotEmpty) ...[
          for (final cat in typed)
            _CategoryTile(key: ValueKey(cat.uuid), category: cat),
        ],
        if (both.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SectionHeader(label: 'Shown in both tabs'),
          const SizedBox(height: 8),
          for (final cat in both)
            _CategoryTile(key: ValueKey(cat.uuid), category: cat),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.10 * 11,
        color: AppTheme.muted,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CategoryTile extends ConsumerWidget {
  final Category category;
  const _CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = category;
    final color = Color(cat.colorValue);
    final iconData =
        IconData(cat.iconCodePoint, fontFamily: cat.iconFontFamily);
    final cs = Theme.of(context).colorScheme;
    final isActive = cat.isActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isActive ? 1.0 : 0.45,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: isActive ? 0.18 : 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              // Icon badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isActive ? 0.14 : 0.06),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(iconData,
                    color: color.withValues(alpha: isActive ? 1.0 : 0.5),
                    size: 20),
              ),
              const SizedBox(width: 12),
              // Name + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppTheme.cream
                                : cs.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _TypeBadge(type: cat.transactionType),
                        if (!cat.isActive) ...[
                          const SizedBox(width: 6),
                          Text(
                            'Hidden',
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit',
                onPressed: () =>
                    context.push('/categories/edit', extra: cat),
              ),
              if (cat.isCustom)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: 'Delete',
                  color: cs.error,
                  onPressed: () => _confirmDelete(context, ref, cat),
                )
              else
                IconButton(
                  icon: Icon(
                    isActive
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  tooltip: isActive ? 'Hide' : 'Show',
                  onPressed: () => ref
                      .read(categoriesProvider.notifier)
                      .setActive(cat.uuid, active: !isActive),
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Category cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Delete "${cat.name}"? Transactions using it will keep the category label.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(categoriesProvider.notifier).delete(cat.uuid);
    }
  }
}

// ---------------------------------------------------------------------------

class _TypeBadge extends StatelessWidget {
  final String? type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      'expense' => ('Expense', AppTheme.expenseColor),
      'income'  => ('Income',  AppTheme.incomeColor),
      _         => ('Both',    AppTheme.muted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
