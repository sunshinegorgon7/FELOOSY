import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Today';
  if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('EEEE, MMMM d').format(date);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryUuid;
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(budgetSummaryProvider);
    final txAsync = ref.watch(transactionsProvider);
    final catAsync = ref.watch(categoriesProvider);
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final showAddTransactionBar = !_isSearching && !isKeyboardOpen;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 16,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
                  hintStyle: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Text(
                'FELOOSY',
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  letterSpacing: 3,
                ),
              ),
        actions: _isSearching
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _stopSearch,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search_outlined),
                  tooltip: 'Search',
                  onPressed: _startSearch,
                ),
                IconButton(
                  tooltip: 'Budget',
                  icon: const Icon(Icons.analytics_outlined),
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
          if (showAddTransactionBar)
            Positioned(
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              left: 16,
              child: FloatingActionButton(
                heroTag: 'income_fab',
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                onPressed: () => context.push('/transactions/add?type=income'),
                child: const Icon(Icons.add),
              ),
            ),
          if (showAddTransactionBar)
            Positioned(
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'expense_fab',
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                onPressed: () => context.push('/transactions/add?type=expense'),
                child: const Icon(Icons.remove),
              ),
            ),
          // Available balance centered between the two FABs
          if (showAddTransactionBar &&
              summaryAsync case AsyncData(:final value))
            if (value.budgetAmount > 0)
              Positioned(
                bottom: 16 + MediaQuery.paddingOf(context).bottom,
                left: 72,
                right: 72,
                height: 56,
                child: _BalancePill(summary: value),
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

    // Category filter then description search
    final categoryFiltered = _selectedCategoryUuid == null
        ? txs
        : txs
            .where((tx) => tx.categoryUuid == _selectedCategoryUuid)
            .toList();

    final filteredTxs = _searchQuery.isEmpty
        ? categoryFiltered
        : categoryFiltered
            .where((tx) => tx.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    final selectedCat = _selectedCategoryUuid != null
        ? cats.where((c) => c.uuid == _selectedCategoryUuid).firstOrNull
        : null;

    final groups = _groupByDate(filteredTxs);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Period header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
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
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
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
                // ── Search mode: flat list of matching transactions ──
                if (_searchQuery.isNotEmpty) {
                  final tx = filteredTxs[index];
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
                          onPressed: (_) async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete transaction?'),
                                content: Text(
                                    '"${tx.description}" will be permanently removed.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && mounted) {
                              await ref
                                  .read(transactionsProvider.notifier)
                                  .remove(tx.uuid);
                            }
                          },
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
                      onTap: () =>
                          context.push('/transactions/edit', extra: tx),
                    ),
                  );
                }

                // ── Normal mode: day-group headers ──
                final group = groups[index];
                return InkWell(
                  onTap: () =>
                      _showDayOverlay(context, group, cats, summary),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Row(
                      children: [
                        Icon(Icons.chevron_right,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          group.label,
                          style: tt.labelMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _searchQuery.isNotEmpty
                  ? filteredTxs.length
                  : groups.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  void _showDayOverlay(
    BuildContext context,
    _DayGroup group,
    List<Category> cats,
    BudgetSummary summary,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DayOverlay(
        dayLabel: group.label,
        cats: cats,
        summary: summary,
      ),
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
      final label = _dayLabel(tx.transactionDate);
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

}

class _DayGroup {
  final String label;
  final double dayNet;
  final List<Transaction> txs;
  _DayGroup(this.label, this.dayNet, this.txs);
}

// ---------------------------------------------------------------------------
// Full-page overlay shown when tapping a day group
// ---------------------------------------------------------------------------

class _DayOverlay extends ConsumerStatefulWidget {
  final String dayLabel;
  final List<Category> cats;
  final BudgetSummary summary;

  const _DayOverlay({
    required this.dayLabel,
    required this.cats,
    required this.summary,
  });

  @override
  ConsumerState<_DayOverlay> createState() => _DayOverlayState();
}

class _DayOverlayState extends ConsumerState<_DayOverlay> {
  Future<void> _delete(Transaction tx) async {
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

  @override
  Widget build(BuildContext context) {
    final allTxs = ref.watch(transactionsProvider).asData?.value ?? const <Transaction>[];
    final dayTxs = allTxs
        .where((tx) => _dayLabel(tx.transactionDate) == widget.dayLabel)
        .toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    // Auto-close when all transactions in this day are deleted
    if (dayTxs.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      expand: false,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(
                children: [
                  Text(
                    widget.dayLabel,
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant),
            // Transaction list (reactive)
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: dayTxs.length,
                itemBuilder: (ctx, index) {
                  final tx = dayTxs[index];
                  final cat = widget.cats
                      .where((c) => c.uuid == tx.categoryUuid)
                      .firstOrNull;
                  return Slidable(
                    key: ValueKey(tx.uuid),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (_) => _delete(tx),
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
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Balance pill shown between the two FABs
// ---------------------------------------------------------------------------

class _BalancePill extends StatelessWidget {
  final BudgetSummary summary;
  const _BalancePill({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isOver = summary.isOverBudget;
    final color = isOver ? Colors.red.shade600 : Colors.green.shade600;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            summary.formatAmount(summary.remaining.abs()),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
          Text(
            isOver ? 'over budget' : 'available',
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
