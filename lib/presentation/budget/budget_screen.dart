import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(currentBudgetPeriodProvider);
    final budgetAsync = ref.watch(currentBudgetProvider);
    final summaryAsync = ref.watch(budgetSummaryProvider);
    final allTxAsync = ref.watch(allTransactionsForAccountProvider);
    final cats = ref.watch(categoriesProvider).asData?.value ?? const <Category>[];

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('History Ledger')),
      body: allTxAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allTxs) {
          final groups = _groupByMonth(allTxs);

          return ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 80),
            children: [
              // ── Current period budget card ───────────────────────────
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
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
                          const SizedBox(width: 8),
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
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 16),
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
              ),

              // ── Full transaction history ─────────────────────────────
              if (allTxs.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No transactions yet.',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 24),
                for (final group in groups)
                  _MonthSection(
                    monthLabel: group.label,
                    transactions: group.txs,
                    cats: cats,
                  ),
              ],
            ],
          );
        },
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

// ---------------------------------------------------------------------------
// Month grouping helpers
// ---------------------------------------------------------------------------

class _MonthGroup {
  final String label;
  final List<Transaction> txs;
  const _MonthGroup(this.label, this.txs);
}

List<_MonthGroup> _groupByMonth(List<Transaction> txs) {
  final keys = <String>[];
  final map = <String, List<Transaction>>{};
  for (final tx in txs) {
    final key = DateFormat('MMMM yyyy').format(tx.transactionDate);
    if (!map.containsKey(key)) keys.add(key);
    map.putIfAbsent(key, () => []).add(tx);
  }
  return [for (final k in keys) _MonthGroup(k, map[k]!)];
}

// ---------------------------------------------------------------------------
// Month section widget
// ---------------------------------------------------------------------------

class _MonthSection extends StatelessWidget {
  final String monthLabel;
  final List<Transaction> transactions;
  final List<Category> cats;

  const _MonthSection({
    required this.monthLabel,
    required this.transactions,
    required this.cats,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final expenseTotal = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (a, t) => a + t.amount);
    final incomeTotal = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (a, t) => a + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                monthLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (incomeTotal > 0)
                Text(
                  '+${_fmt(incomeTotal)}',
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.incomeColor,
                  ),
                ),
              if (expenseTotal > 0 && incomeTotal > 0)
                const SizedBox(width: 10),
              if (expenseTotal > 0)
                Text(
                  '−${_fmt(expenseTotal)}',
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.expenseColor,
                  ),
                ),
            ],
          ),
        ),
        for (final tx in transactions)
          TransactionTile(
            transaction: tx,
            category:
                cats.where((c) => c.uuid == tx.categoryUuid).firstOrNull,
            onTap: () => context.push('/transactions/edit', extra: tx),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Budget card sub-widgets (period-scoped)
// ---------------------------------------------------------------------------

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
        const SizedBox(height: 12),
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
                    style: const TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
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
                side: BorderSide(
                    color: cs.primary.withValues(alpha: 0.4), width: 1.5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        summaryAsync.whenOrNull(data: (s) {
              final summary = s as BudgetSummary;
              final progress = summary.spentPercentage.clamp(0.0, 1.0);
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: cs.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        summary.isOverBudget ? cs.error : cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Stat(
                        label: 'SPENT',
                        value: summary.formatAmount(summary.totalExpenses),
                        color: cs.onSurface,
                      ),
                      _Stat(
                        label: 'REMAINING',
                        value: summary.formatAmount(summary.remaining),
                        color: summary.isOverBudget ? cs.error : cs.primary,
                        alignEnd: true,
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

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.10 * 11,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 14,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

String _fmt(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '$whole.${parts[1]}';
}
