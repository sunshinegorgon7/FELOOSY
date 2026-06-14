import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app/app_theme.dart';
import '../../core/widgets/discreet_amount.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import '../transactions/widgets/transaction_tile.dart';

enum _LedgerGrouping { month, year }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _LedgerGrouping _grouping = _LedgerGrouping.month;

  @override
  Widget build(BuildContext context) {
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
        title: Text(context.l10n.history),
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

          return ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 80),
            children: [
              if (allTxs.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      'No transactions yet.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
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
      _LedgerGrouping.month => _groupByMonth(txs),
      _LedgerGrouping.year => _groupByYear(txs),
    };

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
    for (final k in keys) _MonthGroup(k, map[k]!, _isMonthComplete(k, now)),
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
// Grouping picker
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
            _LedgerGrouping.month => context.l10n.historyMonth,
            _LedgerGrouping.year => context.l10n.historyYear,
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected
                        ? AppTheme.primaryText(cs)
                        : cs.onSurfaceVariant,
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
// Month card
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = AppTheme.primaryText(cs);

    final expenseTotal = widget.transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (a, t) => a + t.amount);
    final incomeTotal = widget.transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (a, t) => a + t.amount);

    final totals = <String, double>{};
    for (final tx in widget.transactions.where(
      (t) => t.type == TransactionType.expense,
    )) {
      totals[tx.categoryUuid] = (totals[tx.categoryUuid] ?? 0) + tx.amount;
    }
    final topStats =
        (totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) {
              final cat = widget.cats.where((c) => c.uuid == e.key).firstOrNull;
              return cat != null ? _CatStat(cat, e.value) : null;
            })
            .whereType<_CatStat>()
            .toList();

    final displayedTxs = _selectedCategoryUuid == null
        ? widget.transactions
        : widget.transactions
              .where((t) => t.categoryUuid == _selectedCategoryUuid)
              .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() {
              _expanded = !_expanded;
              if (!_expanded) _selectedCategoryUuid = null;
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Text(
                    widget.monthLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (incomeTotal > 0)
                    DiscreetAmount(
                      child: Text(
                        '+${_fmt(incomeTotal)}',
                        style: GoogleFonts.dmMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.incomeText(cs),
                        ),
                      ),
                    ),
                  if (expenseTotal > 0 && incomeTotal > 0)
                    const SizedBox(width: 8),
                  if (expenseTotal > 0)
                    DiscreetAmount(
                      child: Text(
                        '−${_fmt(expenseTotal)}',
                        style: GoogleFonts.dmMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: accentColor,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: cs.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox.shrink()
                : Column(
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
                        if (_selectedCategoryUuid != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Builder(
                                builder: (ctx) {
                                  final selStat = topStats
                                      .where(
                                        (s) =>
                                            s.category.uuid ==
                                            _selectedCategoryUuid,
                                      )
                                      .firstOrNull;
                                  final catColor = selStat != null
                                      ? AppTheme.categoryBarColor(
                                          uuid: selStat.category.uuid,
                                          colorValue:
                                              selStat.category.colorValue,
                                          colorScheme: cs,
                                        )
                                      : accentColor;
                                  return GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedCategoryUuid = null,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: catColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: catColor.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
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
                                          Icon(
                                            Icons.close,
                                            size: 12,
                                            color: catColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],

                      // Transaction list
                      const Divider(height: 1),
                      if (displayedTxs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'No transactions in this category.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
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
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bar chart
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
    const barAreaH = 90.0;
    final cs = Theme.of(context).colorScheme;
    final maxAmount = widget.stats.first.amount;
    final hasSelection = widget.selectedCategoryUuid != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: widget.stats.map((stat) {
        final color = AppTheme.categoryBarColor(
          uuid: stat.category.uuid,
          colorValue: stat.category.colorValue,
          colorScheme: cs,
        );
        final targetH = (barAreaH * (stat.amount / maxAmount)).clamp(
          4.0,
          barAreaH,
        );
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
                          child: DiscreetAmount(
                            child: Text(
                              _fmt(stat.amount),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'DM Mono',
                                color: cs.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
                                top: Radius.circular(5),
                              ),
                              border: isSelected
                                  ? Border.all(
                                      color: color.withValues(alpha: 0.55),
                                    )
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
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? color : cs.onSurfaceVariant,
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

String _fmt(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '$whole.${parts[1]}';
}
