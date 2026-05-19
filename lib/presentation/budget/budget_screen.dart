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
import '../../providers/ai_analysis_provider.dart';
import 'widgets/ai_insights_card.dart';

enum _LedgerGrouping { day, week, month, year }

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  _LedgerGrouping _grouping = _LedgerGrouping.month;

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(currentBudgetPeriodProvider);
    final budgetAsync = ref.watch(currentBudgetProvider);
    final summaryAsync = ref.watch(budgetSummaryProvider);
    final allTxAsync = ref.watch(allTransactionsForAccountProvider);
    final cats =
        ref.watch(categoriesProvider).asData?.value ?? const <Category>[];
    final account = ref.watch(activeAccountProvider);

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _GroupingPicker(
            value: _grouping,
            onChanged: (g) => setState(() => _grouping = g),
          ),
        ),
      ),
      body: allTxAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allTxs) {
          final groups = _group(allTxs, _grouping);

          // Trigger background AI scan for all complete groups
          if (account != null && cats.isNotEmpty) {
            final jobs = groups
                .where((g) => g.isPeriodComplete)
                .map((g) => AiScanJob(
                      hash: computeGroupHash(g.txs, 0),
                      groupLabel: g.label,
                      transactions: g.txs,
                      budgetAmount: 0,
                      currencySymbol: account.currencySymbol,
                      symbolLeading: account.currencySymbolLeading,
                    ))
                .toList();
            if (jobs.isNotEmpty) {
              Future.microtask(() {
                ref.read(aiBackgroundScannerProvider.notifier).enqueue(jobs);
              });
            }
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 80),
            children: [
              // ── Current period budget card ───────────────────────────
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.calendar_month,
                                color: cs.primary, size: 13),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'CURRENT PERIOD',
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.10 * 11,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${DateFormat('MMM d').format(period.start)} – '
                            '${DateFormat('MMM d').format(period.end)}',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        period.label,
                        style: tt.titleLarge?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      budgetAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('$e'),
                        data: (budget) => budget == null
                            ? _NoBudget(onSet: () => _showSetBudget(context))
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

              // ── Period cards ─────────────────────────────────────────
              if (allTxs.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      'No transactions yet.',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                )
              else
                for (final group in groups)
                  _MonthCard(
                    monthLabel: group.label,
                    transactions: group.txs,
                    cats: cats,
                    isPeriodComplete: group.isPeriodComplete,
                    currencySymbol: account?.currencySymbol ?? '',
                    symbolLeading: account?.currencySymbolLeading ?? false,
                  ),
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
// Grouping
// ---------------------------------------------------------------------------

class _MonthGroup {
  final String label;
  final List<Transaction> txs;
  final bool isPeriodComplete;
  const _MonthGroup(this.label, this.txs, this.isPeriodComplete);
}

List<_MonthGroup> _group(List<Transaction> txs, _LedgerGrouping g) =>
    switch (g) {
      _LedgerGrouping.day   => _groupByDay(txs),
      _LedgerGrouping.week  => _groupByWeek(txs),
      _LedgerGrouping.month => _groupByMonth(txs),
      _LedgerGrouping.year  => _groupByYear(txs),
    };

List<_MonthGroup> _groupByDay(List<Transaction> txs) {
  final keys = <String>[];
  final map = <String, List<Transaction>>{};
  final now = DateTime.now();
  for (final tx in txs) {
    final key = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
    if (!map.containsKey(key)) keys.add(key);
    map.putIfAbsent(key, () => []).add(tx);
  }
  return [
    for (final k in keys)
      _MonthGroup(
        DateFormat('EEE, d MMM yyyy').format(DateFormat('yyyy-MM-dd').parse(k)),
        map[k]!,
        DateFormat('yyyy-MM-dd')
            .parse(k)
            .isBefore(DateTime(now.year, now.month, now.day)),
      ),
  ];
}

List<_MonthGroup> _groupByWeek(List<Transaction> txs) {
  final keys = <String>[];
  final map = <String, List<Transaction>>{};
  final now = DateTime.now();
  for (final tx in txs) {
    final dt = tx.transactionDate;
    final monday = dt.subtract(Duration(days: dt.weekday - 1));
    final key = DateFormat('yyyy-MM-dd').format(monday);
    if (!map.containsKey(key)) keys.add(key);
    map.putIfAbsent(key, () => []).add(tx);
  }
  return [
    for (final k in keys)
      _MonthGroup(
        _weekLabel(DateFormat('yyyy-MM-dd').parse(k)),
        map[k]!,
        DateFormat('yyyy-MM-dd')
            .parse(k)
            .add(const Duration(days: 6))
            .isBefore(now),
      ),
  ];
}

String _weekLabel(DateTime monday) {
  final sunday = monday.add(const Duration(days: 6));
  if (monday.month == sunday.month) {
    return '${DateFormat('d').format(monday)}–${DateFormat('d MMM yyyy').format(sunday)}';
  } else if (monday.year == sunday.year) {
    return '${DateFormat('d MMM').format(monday)}–${DateFormat('d MMM yyyy').format(sunday)}';
  } else {
    return '${DateFormat('d MMM yy').format(monday)}–${DateFormat('d MMM yy').format(sunday)}';
  }
}

List<_MonthGroup> _groupByMonth(List<Transaction> txs) {
  final keys = <String>[];
  final map = <String, List<Transaction>>{};
  final now = DateTime.now();
  for (final tx in txs) {
    final key = DateFormat('MMMM yyyy').format(tx.transactionDate);
    if (!map.containsKey(key)) keys.add(key);
    map.putIfAbsent(key, () => []).add(tx);
  }
  return [
    for (final k in keys)
      _MonthGroup(k, map[k]!, _isMonthComplete(k, now)),
  ];
}

bool _isMonthComplete(String monthLabel, DateTime now) {
  try {
    final dt = DateFormat('MMMM yyyy').parse(monthLabel);
    final lastDay = DateTime(dt.year, dt.month + 1, 0);
    return lastDay.isBefore(DateTime(now.year, now.month, now.day));
  } catch (_) {
    return false;
  }
}

List<_MonthGroup> _groupByYear(List<Transaction> txs) {
  final keys = <String>[];
  final map = <String, List<Transaction>>{};
  final now = DateTime.now();
  for (final tx in txs) {
    final key = '${tx.transactionDate.year}';
    if (!map.containsKey(key)) keys.add(key);
    map.putIfAbsent(key, () => []).add(tx);
  }
  return [
    for (final k in keys)
      _MonthGroup(
        k,
        map[k]!,
        int.tryParse(k) != null && int.parse(k) < now.year,
      ),
  ];
}

// ---------------------------------------------------------------------------
// Grouping filter — shown in the AppBar bottom
// ---------------------------------------------------------------------------

class _GroupingPicker extends StatelessWidget {
  final _LedgerGrouping value;
  final ValueChanged<_LedgerGrouping> onChanged;

  const _GroupingPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: _LedgerGrouping.values.map((g) {
          final selected = g == value;
          final label = switch (g) {
            _LedgerGrouping.day   => 'Day',
            _LedgerGrouping.week  => 'Week',
            _LedgerGrouping.month => 'Month',
            _LedgerGrouping.year  => 'Year',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? cs.primary.withValues(alpha: 0.55)
                        : cs.outlineVariant,
                    width: selected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Month card — expandable
// ---------------------------------------------------------------------------

class _CatStat {
  final Category category;
  final double amount;
  const _CatStat(this.category, this.amount);
}

class _MonthCard extends ConsumerStatefulWidget {
  final String monthLabel;
  final List<Transaction> transactions;
  final List<Category> cats;
  final bool isPeriodComplete;
  final String currencySymbol;
  final bool symbolLeading;

  const _MonthCard({
    required this.monthLabel,
    required this.transactions,
    required this.cats,
    required this.isPeriodComplete,
    required this.currencySymbol,
    required this.symbolLeading,
  });

  @override
  ConsumerState<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends ConsumerState<_MonthCard> {
  bool _expanded = false;
  String? _selectedCategoryUuid;

  String get _hash => computeGroupHash(widget.transactions, 0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final expenseTotal = widget.transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (a, t) => a + t.amount);
    final incomeTotal = widget.transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (a, t) => a + t.amount);

    // Top 5 expense categories for this month
    final totals = <String, double>{};
    for (final tx in widget.transactions
        .where((t) => t.type == TransactionType.expense)) {
      totals[tx.categoryUuid] = (totals[tx.categoryUuid] ?? 0) + tx.amount;
    }
    final topStats = (totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .map((e) {
          final cat =
              widget.cats.where((c) => c.uuid == e.key).firstOrNull;
          return cat != null ? _CatStat(cat, e.value) : null;
        })
        .whereType<_CatStat>()
        .toList();

    final displayedTxs = _selectedCategoryUuid == null
        ? widget.transactions
        : widget.transactions
            .where((t) => t.categoryUuid == _selectedCategoryUuid)
            .toList();

    final hash = _hash;
    final scanningHashes = ref.watch(aiBackgroundScannerProvider);
    final isScanning = scanningHashes.contains(hash);
    final cacheAsync = ref.watch(aiCacheForHashProvider(hash));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Collapsed header ──────────────────────────────────────
          InkWell(
            onTap: () => setState(() {
              _expanded = !_expanded;
              if (!_expanded) _selectedCategoryUuid = null;
            }),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  Text(
                    widget.monthLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: cs.onSurface,
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
                    const SizedBox(width: 8),
                  if (expenseTotal > 0)
                    Text(
                      '−${_fmt(expenseTotal)}',
                      style: GoogleFonts.dmMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.primary,
                      ),
                    ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more,
                        color: cs.onSurfaceVariant, size: 18),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable content ────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bar chart
                if (topStats.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                    child: _MonthBarChart(
                      stats: topStats,
                      selectedCategoryUuid: _selectedCategoryUuid,
                      onTap: (uuid) => setState(() {
                        _selectedCategoryUuid =
                            _selectedCategoryUuid == uuid ? null : uuid;
                      }),
                    ),
                  ),
                  // Active filter chip
                  if (_selectedCategoryUuid != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Builder(builder: (ctx) {
                          final selStat = topStats
                              .where((s) =>
                                  s.category.uuid == _selectedCategoryUuid)
                              .firstOrNull;
                          final catColor = selStat != null
                              ? Color(selStat.category.colorValue)
                              : cs.primary;
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedCategoryUuid = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
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
                                  Icon(Icons.close,
                                      size: 12, color: catColor),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],

                // ── AI Insights ─────────────────────────────────────
                const Divider(height: 1),
                const SizedBox(height: 12),
                if (!widget.isPeriodComplete)
                  AiInsightsPendingCard(groupLabel: widget.monthLabel)
                else if (isScanning && cacheAsync.value == null)
                  const AiInsightsPreparingCard()
                else
                  cacheAsync.when(
                    loading: () => const AiInsightsPreparingCard(),
                    error: (e, st) => const SizedBox.shrink(),
                    data: (entry) => entry != null
                        ? AiInsightsCard(entry: entry)
                        : isScanning
                            ? const AiInsightsPreparingCard()
                            : const SizedBox.shrink(),
                  ),

                // Transaction list
                const Divider(height: 1),
                if (displayedTxs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'No transactions in this category.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  )
                else
                  for (final tx in displayedTxs)
                    TransactionTile(
                      transaction: tx,
                      category: widget.cats
                          .where((c) => c.uuid == tx.categoryUuid)
                          .firstOrNull,
                      onTap: () =>
                          context.push('/transactions/edit', extra: tx),
                    ),
                const SizedBox(height: 4),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive bar chart — mirrors home screen _TopCategoriesChart
// ---------------------------------------------------------------------------

class _MonthBarChart extends StatefulWidget {
  final List<_CatStat> stats;
  final String? selectedCategoryUuid;
  final void Function(String) onTap;

  const _MonthBarChart({
    required this.stats,
    required this.selectedCategoryUuid,
    required this.onTap,
  });

  @override
  State<_MonthBarChart> createState() => _MonthBarChartState();
}

class _MonthBarChartState extends State<_MonthBarChart> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    const barAreaH = 72.0;
    final cs = Theme.of(context).colorScheme;
    final maxAmount = widget.stats.first.amount;
    final hasSelection = widget.selectedCategoryUuid != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: widget.stats.map((stat) {
        final color = Color(stat.category.colorValue);
        final targetH =
            (barAreaH * (stat.amount / maxAmount)).clamp(4.0, barAreaH);
        final barH = _entered ? targetH : 0.0;
        final isSelected = stat.category.uuid == widget.selectedCategoryUuid;
        final isDeselected = hasSelection && !isSelected;

        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTap(stat.category.uuid),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isDeselected ? 0.3 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: barAreaH + 20,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          bottom: barH + 4,
                          left: 0,
                          right: 0,
                          child: Text(
                            _fmt(stat.amount),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'DM Mono',
                              color: AppTheme.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          bottom: 0,
                          left: 8,
                          right: 8,
                          height: barH,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5)),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.55),
                                        blurRadius: 8,
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
                  const SizedBox(height: 5),
                  Text(
                    stat.category.name,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
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

// ---------------------------------------------------------------------------
// Budget card sub-widgets (current period)
// ---------------------------------------------------------------------------

class _NoBudget extends StatelessWidget {
  final VoidCallback onSet;
  const _NoBudget({required this.onSet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'No budget set',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onSet,
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Set Budget'),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
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
    final cs = Theme.of(context).colorScheme;
    final account = ref.watch(activeAccountProvider);

    final formattedBudget = account == null
        ? budget.amount.toStringAsFixed(2)
        : CurrencyFormatter.formatWith(
            amount: budget.amount,
            symbol: account.currencySymbol,
            symbolLeading: account.currencySymbolLeading,
          );

    return summaryAsync.whenOrNull(data: (s) {
          final summary = s as BudgetSummary;
          final progress = summary.spentPercentage.clamp(0.0, 1.0);
          final isOver = summary.isOverBudget;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedBudget,
                          style: GoogleFonts.dmMono(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOver
                              ? '${summary.formatAmount(summary.totalExpenses)} spent · over budget'
                              : '${summary.formatAmount(summary.remaining)} remaining · ${(progress * 100).round()}% spent',
                          style: TextStyle(
                            fontSize: 11,
                            color: isOver
                                ? cs.error
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: cs.primary.withValues(alpha: 0.4),
                          width: 1.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      shape: const StadiumBorder(),
                    ),
                    child: Text('Change',
                        style:
                            TextStyle(color: cs.primary, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: cs.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOver ? cs.error : cs.primary,
                  ),
                ),
              ),
            ],
          );
        }) ??
        Row(
          children: [
            Expanded(
              child: Text(
                formattedBudget,
                style: GoogleFonts.dmMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: cs.primary.withValues(alpha: 0.4), width: 1.5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
                shape: const StadiumBorder(),
              ),
              child: Text('Change',
                  style: TextStyle(color: cs.primary, fontSize: 12)),
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
