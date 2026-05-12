import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../domain/entities/budget_summary.dart';
import '../../providers/budget_period_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/budget_summary_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import '../transactions/widgets/transaction_tile.dart';
import 'set_budget_sheet.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  bool _cardExpanded = false;

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(currentBudgetPeriodProvider);
    final budgetAsync = ref.watch(currentBudgetProvider);
    final summaryAsync = ref.watch(budgetSummaryProvider);
    final txAsync = ref.watch(transactionsProvider);
    final catAsync = ref.watch(categoriesProvider);

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Budget')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom + 80),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Period info + budget ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.calendar_month,
                                color: cs.primary, size: 16),
                          ),
                          const Gap(8),
                          Text(
                            'CURRENT PERIOD',
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.10 * 11,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        period.label,
                        style: tt.titleLarge?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          letterSpacing: 28 * -0.01,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMM d').format(period.start)} – '
                        '${DateFormat('MMM d, y').format(period.end)}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const Gap(16),
                      budgetAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('$e'),
                        data: (budget) => budget == null
                            ? _NoBudget(
                                onSet: () => _showSetBudget(context))
                            : _BudgetInfo(
                                budget: budget,
                                summaryAsync: summaryAsync,
                                onEdit: () => _showSetBudget(context),
                              ),
                      ),
                    ],
                  ),
                ),

                // ── Collapsible transactions + chart ────────────────────
                txAsync.maybeWhen(
                  data: (txs) {
                    if (txs.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(height: 1),
                        InkWell(
                          onTap: () => setState(
                              () => _cardExpanded = !_cardExpanded),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  '${txs.length} transaction'
                                  '${txs.length == 1 ? '' : 's'}'
                                  ' this period',
                                  style: tt.labelMedium?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: _cardExpanded ? 0.5 : 0,
                                  duration:
                                      const Duration(milliseconds: 200),
                                  child: Icon(Icons.expand_more,
                                      color: cs.primary, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: catAsync.maybeWhen(
                            data: (cats) => summaryAsync.maybeWhen(
                              data: (summary) => _ExpandedContent(
                                txs: txs,
                                cats: cats,
                                summary: summary,
                              ),
                              orElse: () => const SizedBox.shrink(),
                            ),
                            orElse: () => const SizedBox.shrink(),
                          ),
                          crossFadeState: _cardExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 220),
                        ),
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSetBudget(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SetBudgetSheet(),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _NoBudget extends StatelessWidget {
  final VoidCallback onSet;
  const _NoBudget({required this.onSet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No budget set',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const Gap(12),
        FilledButton.icon(
          onPressed: onSet,
          icon: const Icon(Icons.add),
          label: const Text('Set Budget'),
        ),
      ],
    );
  }
}

class _BudgetInfo extends ConsumerWidget {
  final Budget budget;
  final AsyncValue summaryAsync;
  final VoidCallback onEdit;

  const _BudgetInfo({
    required this.budget,
    required this.summaryAsync,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final account = ref.watch(activeAccountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUDGET',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.10 * 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account == null
                        ? budget.amount.toStringAsFixed(2)
                        : CurrencyFormatter.formatWith(
                            amount: budget.amount,
                            symbol: account.currencySymbol,
                            symbolLeading: account.currencySymbolLeading,
                          ),
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 14, color: cs.primary),
              label: Text('Change',
                  style: TextStyle(color: cs.primary, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.primary.withValues(alpha: 0.4), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
        const Gap(12),
        summaryAsync.whenOrNull(data: (s) {
              final budget = s as BudgetSummary;
              final progress = budget.spentPercentage.clamp(0.0, 1.0);
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: cs.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budget.isOverBudget ? cs.error : cs.primary,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SPENT',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.10 * 11,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            budget.formatAmount(budget.totalExpenses),
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 14,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'REMAINING',
                            style: tt.labelSmall?.copyWith(
                              color: budget.isOverBudget ? cs.error : cs.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.10 * 11,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            budget.formatAmount(budget.remaining),
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 14,
                              color: budget.isOverBudget ? cs.error : cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }) ??
            const SizedBox.shrink(),
      ],
    );
  }
}

// ── Expanded card content ─────────────────────────────────────────────────

class _ExpandedContent extends StatefulWidget {
  final List<Transaction> txs;
  final List<Category> cats;
  final BudgetSummary summary;

  const _ExpandedContent({
    required this.txs,
    required this.cats,
    required this.summary,
  });

  @override
  State<_ExpandedContent> createState() => _ExpandedContentState();
}

class _ExpandedContentState extends State<_ExpandedContent> {
  String? _selectedCategoryFilter;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Compute top 5 expense categories
    final totals = <String, double>{};
    for (final tx
        in widget.txs.where((t) => t.type == TransactionType.expense)) {
      totals[tx.categoryUuid] =
          (totals[tx.categoryUuid] ?? 0) + tx.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted
        .take(5)
        .map((e) {
          final cat =
              widget.cats.where((c) => c.uuid == e.key).firstOrNull;
          return cat != null ? _CatStat(cat, e.value) : null;
        })
        .whereType<_CatStat>()
        .toList();

    final displayedTxs = _selectedCategoryFilter == null
        ? widget.txs
        : widget.txs
            .where((tx) => tx.categoryUuid == _selectedCategoryFilter)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Top 5 bar chart ─────────────────────────────────────────
        if (top5.isNotEmpty) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Text(
              'TOP SPENDING',
              style: tt.labelSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.10 * 11,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: _TopCategoriesChart(
              stats: top5,
              summary: widget.summary,
              selectedCategoryUuid: _selectedCategoryFilter,
              onTap: (uuid) => setState(() {
                _selectedCategoryFilter =
                    _selectedCategoryFilter == uuid ? null : uuid;
              }),
            ),
          ),
          if (_selectedCategoryFilter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Builder(builder: (ctx) {
                    final selStat = top5
                        .where(
                          (s) => s.category.uuid == _selectedCategoryFilter,
                        )
                        .firstOrNull;
                    final catColor = selStat != null
                        ? Color(selStat.category.colorValue)
                        : cs.primary;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryFilter = null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: catColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selStat?.category.name ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: catColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(Icons.close, size: 13, color: catColor),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],

        // ── Transaction list ─────────────────────────────────────────
        const Divider(height: 1),
        for (final tx in displayedTxs)
          TransactionTile(
            transaction: tx,
            category: widget.cats
                .where((c) => c.uuid == tx.categoryUuid)
                .firstOrNull,
            onTap: () => context.push('/transactions/edit', extra: tx),
          ),
        if (displayedTxs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No transactions in this category.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Top categories bar chart ─────────────────────────────────────────────

class _CatStat {
  final Category category;
  final double amount;
  const _CatStat(this.category, this.amount);
}

class _TopCategoriesChart extends StatelessWidget {
  final List<_CatStat> stats;
  final BudgetSummary summary;
  final String? selectedCategoryUuid;
  final void Function(String categoryUuid)? onTap;

  const _TopCategoriesChart({
    required this.stats,
    required this.summary,
    this.selectedCategoryUuid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const barAreaHeight = 100.0;
    final maxAmount = stats.first.amount;
    final cs = Theme.of(context).colorScheme;
    final hasSelection = selectedCategoryUuid != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: stats.map((stat) {
        final color = Color(stat.category.colorValue);
        final barH =
            (barAreaHeight * (stat.amount / maxAmount)).clamp(4.0, barAreaHeight);
        final isSelected = stat.category.uuid == selectedCategoryUuid;
        final isDeselected = hasSelection && !isSelected;

        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap?.call(stat.category.uuid),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isDeselected ? 0.3 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: barAreaHeight + 26,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          bottom: barH + 4,
                          left: 0,
                          right: 0,
                          child: Text(
                            summary.formatAmount(stat.amount),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'DM Mono',
                              color: cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 10,
                          right: 10,
                          height: barH,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.55),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stat.category.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
