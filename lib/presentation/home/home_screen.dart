import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../domain/entities/budget_summary.dart';
import '../../providers/budget_summary_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import '../settings/settings_screen.dart';
import '../transactions/widgets/transaction_tile.dart';
import 'widgets/spending_pie_chart.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryUuid;
  final Set<String> _expandedDates = {};

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(budgetSummaryProvider);
    final txAsync = ref.watch(transactionsProvider);
    final catAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FELOOSY',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            tooltip: 'Budget',
            icon: const _BudgetBarIcon(),
            onPressed: () => context.push('/budget'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(budgetSummaryProvider);
                ref.invalidate(transactionsProvider);
              },
              child: summaryAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (summary) => txAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      const Center(child: Text('Error loading transactions')),
                  data: (txs) => catAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        const Center(child: Text('Error loading categories')),
                    data: (cats) =>
                        _buildBody(context, summary, txs, cats),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'income_fab',
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/transactions/add?type=income'),
              child: const Icon(Icons.add),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'expense_fab',
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/transactions/add?type=expense'),
              child: const Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BudgetSummary summary,
    List<Transaction> txs,
    List<Category> cats,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final activeCats = cats.where((c) => c.isActive).toList();

    final filteredTxs = _selectedCategoryUuid == null
        ? txs
        : txs
            .where((tx) => tx.categoryUuid == _selectedCategoryUuid)
            .toList();

    final selectedCat = _selectedCategoryUuid != null
        ? cats.where((c) => c.uuid == _selectedCategoryUuid).firstOrNull
        : null;

    final groups = _groupByDate(filteredTxs);

    // Flatten groups based on expanded state (collapsed by default)
    final flatItems = <Object>[];
    for (final g in groups) {
      flatItems.add(g);
      if (_expandedDates.contains(g.label)) {
        flatItems.addAll(g.txs);
      }
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Period header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  summary.period.label,
                  style: tt.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (summary.budgetAmount == 0)
                  TextButton.icon(
                    onPressed: () => context.push('/budget/set'),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Set Budget'),
                  ),
              ],
            ),
          ),
        ),

        // Pie chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SpendingPieChart(
              transactions: txs,
              categories: activeCats,
              summary: summary,
              selectedCategoryUuid: _selectedCategoryUuid,
              onCategoryToggle: (uuid) =>
                  setState(() => _selectedCategoryUuid = uuid),
            ),
          ),
        ),

        // Category filter label (only when a category is selected)
        if (selectedCat != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Row(
                children: [
                  Text(selectedCat.name, style: tt.titleSmall),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategoryUuid = null),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

        if (filteredTxs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  selectedCat != null
                      ? 'No ${selectedCat.name} transactions this period.'
                      : 'No transactions yet.\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = flatItems[index];

                if (item is _DayGroup) {
                  final isExpanded =
                      _expandedDates.contains(item.label);
                  final sign = item.dayNet >= 0 ? '+' : '−';
                  return InkWell(
                    onTap: () => setState(() {
                      if (isExpanded) {
                        _expandedDates.remove(item.label);
                      } else {
                        _expandedDates.add(item.label);
                      }
                    }),
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.label,
                            style: tt.labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const Spacer(),
                          Text(
                            '$sign${summary.formatAmount(item.dayNet.abs())}',
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final tx = item as Transaction;
                final cat = cats
                    .where((c) => c.uuid == tx.categoryUuid)
                    .firstOrNull;
                return Slidable(
                  key: ValueKey(tx.uuid),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) =>
                            _confirmDelete(context, tx),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12)),
                      ),
                    ],
                  ),
                  child: TransactionTile(
                    transaction: tx,
                    category: cat,
                    compact: true,
                    onTap: () =>
                        context.push('/transactions/edit', extra: tx),
                  ),
                );
              },
              childCount: flatItems.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  void _openSettings(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final topPad = MediaQuery.paddingOf(context).top;
        final botPad = MediaQuery.paddingOf(context).bottom;
        return Dialog(
          insetPadding: EdgeInsets.fromLTRB(20, topPad + 16, 20, botPad + 16),
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                child: Row(
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Divider(
                  height: 1,
                  color: Theme.of(ctx).colorScheme.outlineVariant),
              const Expanded(child: SettingsScreen(isModal: true)),
            ],
          ),
        );
      },
    );
  }

  List<_DayGroup> _groupByDate(List<Transaction> txs) {
    if (txs.isEmpty) return [];

    final groupTxs = <String, List<Transaction>>{};
    final groupOrder = <String>[];

    for (final tx in txs) {
      final label = _dateLabel(tx.transactionDate);
      if (!groupTxs.containsKey(label)) {
        groupTxs[label] = [];
        groupOrder.add(label);
      }
      groupTxs[label]!.add(tx);
    }

    return groupOrder.map((label) {
      final dayTxs = groupTxs[label]!;
      final dayNet = dayTxs.fold(
          0.0,
          (sum, tx) => tx.type == TransactionType.income
              ? sum + tx.amount
              : sum - tx.amount);
      return _DayGroup(label, dayNet, dayTxs);
    }).toList();
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEEE, MMMM d').format(date);
  }

  Future<void> _confirmDelete(BuildContext context, Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content:
            Text('"${tx.description}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(transactionsProvider.notifier).remove(tx.uuid);
    }
  }
}

class _DayGroup {
  final String label;
  final double dayNet;
  final List<Transaction> txs;
  _DayGroup(this.label, this.dayNet, this.txs);
}

// ── Budget bar icon (ascending bars + trend arrow) ────────────────────────────

class _BudgetBarIcon extends StatelessWidget {
  const _BudgetBarIcon();

  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    return CustomPaint(
      size: const Size(22, 22),
      painter: _BudgetBarPainter(color: color),
    );
  }
}

class _BudgetBarPainter extends CustomPainter {
  final Color color;
  const _BudgetBarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final barW = w * 0.22;
    final gap = w * 0.10;
    final baseline = h * 0.92;
    final rr = Radius.circular(barW * 0.45);

    // Three ascending bars
    final bars = [
      (x: w * 0.04, bh: h * 0.38),
      (x: w * 0.04 + barW + gap, bh: h * 0.62),
      (x: w * 0.04 + (barW + gap) * 2, bh: h * 0.86),
    ];
    final alphas = [0.50, 0.72, 1.0];

    final barPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < bars.length; i++) {
      barPaint.color = color.withValues(alpha: alphas[i]);
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          bars[i].x, baseline - bars[i].bh,
          bars[i].x + barW, baseline,
          topLeft: rr, topRight: rr,
        ),
        barPaint,
      );
    }

    // Trend arrow from bar-1 top → bar-3 top + small extension
    final p0x = bars[0].x + barW * 0.5;
    final p0y = baseline - bars[0].bh;
    final p1x = bars[1].x + barW * 0.5;
    final p1y = baseline - bars[1].bh;
    final p2x = bars[2].x + barW * 0.5;
    final p2y = baseline - bars[2].bh;

    final dx = p2x - p0x;
    final dy = p2y - p0y;
    final len = math.sqrt(dx * dx + dy * dy);
    final ext = w * 0.14;
    final endX = p2x + dx / len * ext;
    final endY = p2y + dy / len * ext;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()
      ..moveTo(p0x, p0y)
      ..lineTo(p1x, p1y)
      ..lineTo(endX, endY);
    canvas.drawPath(linePath, linePaint);

    // Arrowhead
    final angle = math.atan2(endY - p1y, endX - p1x);
    final headLen = w * 0.18;
    const spread = 0.42;
    canvas.drawLine(
      Offset(endX, endY),
      Offset(endX - headLen * math.cos(angle - spread),
          endY - headLen * math.sin(angle - spread)),
      linePaint,
    );
    canvas.drawLine(
      Offset(endX, endY),
      Offset(endX - headLen * math.cos(angle + spread),
          endY - headLen * math.sin(angle + spread)),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_BudgetBarPainter old) => old.color != color;
}
