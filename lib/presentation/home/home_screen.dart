import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/category.dart';
import '../../data/models/account.dart';
import '../../data/models/transaction.dart';
import '../../domain/entities/budget_summary.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/budget_period_provider.dart';
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
  bool _accountInitialized = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  List<_DayGroup> _visibleGroups = const [];

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
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final shouldHideBottomActions = _isSearching || isKeyboardOpen;
    if (!_accountInitialized && accounts.isNotEmpty && selectedAccountId == null) {
      final initial = accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.first;
      if (initial.id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(selectedHomeAccountIdProvider.notifier).select(initial.id);
          }
        });
      }
      _accountInitialized = true;
    }
    final hasSelectedAccount = selectedAccountId != null &&
        accounts.any((a) => a.id == selectedAccountId);
    if (selectedAccountId != null && !hasSelectedAccount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(selectedHomeAccountIdProvider.notifier).select(null);
        }
      });
    }
    // When only one wallet remains and the view is "all wallets", auto-select it.
    if (accounts.length == 1 && selectedAccountId == null) {
      final single = accounts.first;
      if (single.id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(selectedHomeAccountIdProvider.notifier).select(single.id);
          }
        });
      }
    }
    final isAllAccounts = selectedAccountId == null || !hasSelectedAccount;
    final selectedAccountName = !isAllAccounts
        ? accounts.where((a) => a.id == selectedAccountId).firstOrNull?.name
        : null;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        titleSpacing: 16,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: cs.onSurface, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search transactions…',
                  hintStyle: TextStyle(color: cs.onSurfaceVariant),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            : Row(
                children: [
                  Text(
                    'FELOOSY',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      letterSpacing: 3,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wallet_outlined, size: 13, color: cs.onSurfaceVariant),
                            const SizedBox(width: 5),
                            Text(
                              isAllAccounts ? 'All wallets' : selectedAccountName ?? 'Unknown wallet',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
                if (accounts.length > 1)
                  PopupMenuButton<int>(
                    tooltip: 'Select wallet',
                    icon: const Icon(Icons.wallet_outlined, size: 20),
                    initialValue: hasSelectedAccount ? selectedAccountId : -1,
                    onSelected: (value) {
                      ref
                          .read(selectedHomeAccountIdProvider.notifier)
                          .select(value == -1 ? null : value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                        value: -1,
                        child: Text('All wallets'),
                      ),
                      ...accounts.map(
                        (account) => PopupMenuItem<int>(
                          value: account.id ?? -1,
                          child: Text(account.name),
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  tooltip: 'Budget',
                  icon: const Icon(Icons.menu_book_outlined),
                  onPressed: isAllAccounts ? null : () => context.push('/budget'),
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
                    data: (cats) => _buildBody(
                      context,
                      summary,
                      txs,
                      cats,
                      accounts,
                      selectedAccountId,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!shouldHideBottomActions)
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
          if (!shouldHideBottomActions)
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
          if (!shouldHideBottomActions)
            if (summaryAsync case AsyncData(:final value))
            if (value.budgetAmount > 0 && !isAllAccounts)
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
    List<Account> accounts,
    int? selectedAccountId,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isAllAccounts = selectedAccountId == null;
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
    _visibleGroups = groups;

    final period = ref.watch(selectedBudgetPeriodProvider);
    final periodOffset = ref.watch(selectedPeriodOffsetProvider);
    final periodLabel = DateFormat('MMMM yyyy')
        .format(DateTime(period.budgetYear, period.budgetMonth));
    final isCurrentPeriod = periodOffset == 0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 300) {
          // swipe right → go back in time
          ref.read(selectedPeriodOffsetProvider.notifier).goBack();
        } else if (velocity < -300 && !isCurrentPeriod) {
          // swipe left → go forward (only if we're in a past month)
          ref.read(selectedPeriodOffsetProvider.notifier).goForward();
        }
      },
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Period navigation header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous month',
                      onPressed: () =>
                          ref.read(selectedPeriodOffsetProvider.notifier).goBack(),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: isCurrentPeriod
                            ? null
                            : () => ref
                                .read(selectedPeriodOffsetProvider.notifier)
                                .reset(),
                        child: Column(
                          children: [
                            Text(
                              periodLabel,
                              textAlign: TextAlign.center,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!isCurrentPeriod)
                              Text(
                                'Tap to return to current month',
                                textAlign: TextAlign.center,
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next month',
                      onPressed: isCurrentPeriod
                          ? null
                          : () => ref
                              .read(selectedPeriodOffsetProvider.notifier)
                              .goForward(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Spacer(),
                    if (summary.budgetAmount == 0 && !isAllAccounts)
                      TextButton.icon(
                        onPressed: () => context.push('/budget/set'),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Set Budget'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Pie chart
        if (!isAllAccounts)
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
                final group = groups[index];
                return InkWell(
                  onTap: () =>
                      _showDayOverlay(
                        context,
                        group,
                        cats,
                        summary,
                        scopedTxs: _searchQuery.isNotEmpty ? filteredTxs : null,
                      ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Row(
                      children: [
                        Icon(Icons.chevron_right,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          _searchQuery.isNotEmpty
                              ? '${group.label} (${group.txs.length})'
                              : group.label,
                          style: tt.labelMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: groups.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    ),
    );
  }

  void _showDayOverlay(
    BuildContext context,
    _DayGroup group,
    List<Category> cats,
    BudgetSummary summary, {
    List<Transaction>? scopedTxs,
  }) {
    final overlayGroups =
        scopedTxs == null ? _visibleGroups : _groupByDate(scopedTxs);
    final initialIndex =
        overlayGroups.indexWhere((visible) => visible.day == group.day);
    if (initialIndex < 0) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DayOverlay(
        dayKeys: overlayGroups.map((g) => g.day).toList(),
        initialIndex: initialIndex,
        cats: cats,
        selectedCategoryUuid: _selectedCategoryUuid,
        summary: summary,
        scopedTxs: scopedTxs,
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

    final groupTxs = <DateTime, List<Transaction>>{};
    final groupOrder = <DateTime>[];

    for (final tx in txs) {
      final day = DateUtils.dateOnly(tx.transactionDate);
      if (!groupTxs.containsKey(day)) {
        groupTxs[day] = [];
        groupOrder.add(day);
      }
      groupTxs[day]!.add(tx);
    }

    return groupOrder.map((day) {
      final dayTxs = groupTxs[day]!;
      final dayNet = dayTxs.fold(
          0.0,
          (sum, tx) => tx.type == TransactionType.income
              ? sum + tx.amount
              : sum - tx.amount);
      return _DayGroup(day, _dayLabel(day), dayNet, dayTxs);
    }).toList();
  }

}

class _DayGroup {
  final DateTime day;
  final String label;
  final double dayNet;
  final List<Transaction> txs;
  _DayGroup(this.day, this.label, this.dayNet, this.txs);
}

// ---------------------------------------------------------------------------
// Full-page overlay shown when tapping a day group
// ---------------------------------------------------------------------------

class _DayOverlay extends ConsumerStatefulWidget {
  final List<DateTime> dayKeys;
  final int initialIndex;
  final List<Category> cats;
  final String? selectedCategoryUuid;
  final BudgetSummary summary;
  final List<Transaction>? scopedTxs;

  const _DayOverlay({
    required this.dayKeys,
    required this.initialIndex,
    required this.cats,
    required this.selectedCategoryUuid,
    required this.summary,
    this.scopedTxs,
  });

  @override
  ConsumerState<_DayOverlay> createState() => _DayOverlayState();
}

class _DayOverlayState extends ConsumerState<_DayOverlay> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

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
    final allTxs = widget.scopedTxs ??
        ref.watch(transactionsProvider).asData?.value ??
        const <Transaction>[];
    final visibleDays = widget.dayKeys.where((day) {
      return allTxs.any((tx) {
        final txDay = DateUtils.dateOnly(tx.transactionDate);
        final sameDay = txDay == day;
        final matchesCategory = widget.selectedCategoryUuid == null ||
            tx.categoryUuid == widget.selectedCategoryUuid;
        return sameDay && matchesCategory;
      });
    }).toList();

    if (visibleDays.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    if (_currentIndex >= visibleDays.length && visibleDays.isNotEmpty) {
      _currentIndex = visibleDays.length - 1;
    }

    final currentDay = visibleDays.isEmpty ? null : visibleDays[_currentIndex];
    final dayTxs = currentDay == null
        ? <Transaction>[]
        : (allTxs
            .where((tx) {
              final txDay = DateUtils.dateOnly(tx.transactionDate);
              final sameDay = txDay == currentDay;
              final matchesCategory = widget.selectedCategoryUuid == null ||
                  tx.categoryUuid == widget.selectedCategoryUuid;
              return sameDay && matchesCategory;
            })
            .toList()
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate)));

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
                    currentDay == null ? '' : _dayLabel(currentDay),
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (visibleDays.length > 1) ...[
                    IconButton(
                      onPressed: _currentIndex > 0
                          ? () => setState(() => _currentIndex--)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous day',
                    ),
                    IconButton(
                      onPressed: _currentIndex < visibleDays.length - 1
                          ? () => setState(() => _currentIndex++)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next day',
                    ),
                  ],
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
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity > 300 && _currentIndex > 0) {
                    setState(() => _currentIndex--);
                  } else if (velocity < -300 &&
                      _currentIndex < visibleDays.length - 1) {
                    setState(() => _currentIndex++);
                  }
                },
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
