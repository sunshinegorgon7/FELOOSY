import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/app_theme.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Budget')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                              color: const Color(0x1FF5A623),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.calendar_month,
                                color: AppTheme.amber, size: 16),
                          ),
                          const Gap(8),
                          Text(
                            'CURRENT PERIOD',
                            style: tt.labelSmall?.copyWith(
                              color: AppTheme.amber,
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
                          color: AppTheme.cream,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          letterSpacing: 28 * -0.01,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMM d').format(period.start)} – '
                        '${DateFormat('MMM d, y').format(period.end)}',
                        style: tt.bodySmall?.copyWith(
                          color: AppTheme.muted,
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
                        const Divider(height: 1, color: AppTheme.border),
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
                                    color: AppTheme.amber,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: _cardExpanded ? 0.5 : 0,
                                  duration:
                                      const Duration(milliseconds: 200),
                                  child: const Icon(Icons.expand_more,
                                      color: AppTheme.amber, size: 20),
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
              ?.copyWith(color: AppTheme.muted),
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
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.10 * 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cream,
                      ),
                      children: [
                        TextSpan(
                          text: account == null
                              ? budget.amount.toStringAsFixed(2)
                              : CurrencyFormatter.formatWith(
                                  amount: budget.amount,
                                  symbol: account.currencySymbol,
                                  symbolLeading: account.currencySymbolLeading,
                                ),
                        ),
                        const TextSpan(
                          text: ' AED',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined,
                  size: 14, color: AppTheme.amber),
              label: const Text('Change',
                  style: TextStyle(color: AppTheme.amber, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Color(0x66F5A623), width: 1.5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
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
                      backgroundColor: const Color(0x14F6F1E3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budget.isOverBudget
                            ? AppTheme.destructiveColor
                            : AppTheme.amber,
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
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.10 * 11,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            budget.formatAmount(budget.totalExpenses),
                            style: const TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 14,
                              color: AppTheme.cream,
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
                              color: budget.isOverBudget
                                  ? AppTheme.destructiveColor
                                  : AppTheme.amber,
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
                              color: budget.isOverBudget
                                  ? AppTheme.destructiveColor
                                  : AppTheme.amber,
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

class _ExpandedContent extends StatelessWidget {
  final List<Transaction> txs;
  final List<Category> cats;
  final BudgetSummary summary;

  const _ExpandedContent({
    required this.txs,
    required this.cats,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Compute top 5 expense categories
    final totals = <String, double>{};
    for (final tx
        in txs.where((t) => t.type == TransactionType.expense)) {
      totals[tx.categoryUuid] =
          (totals[tx.categoryUuid] ?? 0) + tx.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted
        .take(5)
        .map((e) {
          final cat =
              cats.where((c) => c.uuid == e.key).firstOrNull;
          return cat != null ? _CatStat(cat, e.value) : null;
        })
        .whereType<_CatStat>()
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
                color: AppTheme.amber,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.10 * 11,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _TopCategoriesChart(stats: top5, summary: summary),
          ),
        ],

        // ── Transaction list ─────────────────────────────────────────
        const Divider(height: 1),
        for (final tx in txs) ...[
          TransactionTile(
            transaction: tx,
            category:
                cats.where((c) => c.uuid == tx.categoryUuid).firstOrNull,
            onTap: () => context.push('/transactions/edit', extra: tx),
          ),
        ],
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

  const _TopCategoriesChart(
      {required this.stats, required this.summary});

  @override
  Widget build(BuildContext context) {
    const barAreaHeight = 100.0;
    final maxAmount = stats.first.amount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: stats.map((stat) {
        final color = Color(stat.category.colorValue);
        final barH =
            (barAreaHeight * (stat.amount / maxAmount)).clamp(4.0, barAreaHeight);
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.formatAmount(stat.amount),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'DM Mono',
                  color: AppTheme.muted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: barAreaHeight,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: barH,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                stat.category.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.muted,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
