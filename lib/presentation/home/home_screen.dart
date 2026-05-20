import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/app_theme.dart';
import '../../data/models/category.dart';
import '../../data/models/account.dart';
import '../../data/models/transaction.dart';
import '../../domain/entities/budget_summary.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/budget_period_provider.dart';
import '../../providers/budget_summary_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';
import '../settings/settings_screen.dart';
import '../transactions/widgets/transaction_tile.dart';
import '../tutorial/tutorial_overlay.dart';

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Today';
  if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('EEEE, MMMM d').format(date);
}

enum _HomeListView { byDay, byCategory }

class _CatGroup {
  final Category category;
  final double net;
  final int count;
  final List<Transaction> txs;
  _CatGroup(this.category, this.net, this.count, this.txs);
}

List<_CatGroup> _groupByCategory(
    List<Transaction> txs, List<Category> cats) {
  final map = <String, List<Transaction>>{};
  for (final tx in txs) {
    map.putIfAbsent(tx.categoryUuid, () => []).add(tx);
  }
  final groups = <_CatGroup>[];
  for (final entry in map.entries) {
    final cat = cats.where((c) => c.uuid == entry.key).firstOrNull;
    if (cat == null) continue;
    final net = entry.value.fold(
      0.0,
      (sum, tx) => tx.type == TransactionType.income
          ? sum + tx.amount
          : sum - tx.amount,
    );
    groups.add(_CatGroup(cat, net, entry.value.length, entry.value));
  }
  groups.sort((a, b) => b.net.abs().compareTo(a.net.abs()));
  return groups;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearching = false;
  bool _accountInitialized = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  List<_DayGroup> _visibleGroups = const [];
  Set<int> _cachedPeriodOffsets = const {};

  String? _selectedCategoryFilter;
  _HomeListView _listView = _HomeListView.byDay;
  bool _tutorialDismissed = false;
  final _addFabKey = GlobalKey();
  final _settingsIconKey = GlobalKey();
  final _budgetHeroKey = GlobalKey();
  final _periodNavKey = GlobalKey();

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

  int? _olderTransactionPeriodOffset(
    int currentOffset,
    Set<int> availableOffsets,
  ) {
    int? olderOffset;
    for (final offset in availableOffsets) {
      if (offset < currentOffset &&
          (olderOffset == null || offset > olderOffset)) {
        olderOffset = offset;
      }
    }
    return olderOffset;
  }

  int? _newerTransactionPeriodOffset(
    int currentOffset,
    Set<int> availableOffsets,
  ) {
    int? newerOffset;
    for (final offset in availableOffsets) {
      if (offset > currentOffset &&
          (newerOffset == null || offset < newerOffset)) {
        newerOffset = offset;
      }
    }
    return newerOffset;
  }

  void _goToPeriodOffset(int offset) {
    ref.read(selectedPeriodOffsetProvider.notifier).goTo(offset);
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(budgetSummaryProvider);
    final txAsync = ref.watch(transactionsProvider);
    final catAsync = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final shouldHideBottomActions = _isSearching || isKeyboardOpen;
    if (!_accountInitialized &&
        accounts.isNotEmpty &&
        selectedAccountId == null) {
      final initial =
          accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.first;
      if (initial.id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(selectedHomeAccountIdProvider.notifier).select(initial.id);
          }
        });
      }
      _accountInitialized = true;
    }
    final hasSelectedAccount =
        selectedAccountId != null &&
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
    final accentColor = AppTheme.primaryText(cs);

    final showTutorial =
        !_tutorialDismissed &&
        settingsAsync.value?.tutorialCompleted == false;

    final scaffold = Scaffold(
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
            : Stack(
                alignment: Alignment.center,
                children: [
                  // Bubbles — truly centered in the title area
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Wallet switcher bubble ────────────────────────
                      PopupMenuButton<int>(
                        tooltip: accounts.length > 1 ? 'Switch wallet' : '',
                        enabled: accounts.length > 1,
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
                            (a) => PopupMenuItem<int>(
                              value: a.id ?? -1,
                              child: Text(a.name),
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.wallet,
                                size: 13,
                                color: accentColor,
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  isAllAccounts
                                      ? 'All wallets'
                                      : selectedAccountName ?? 'Wallet',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (accounts.length > 1) ...[
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: cs.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ── History ledger bubble ─────────────────────────
                      Opacity(
                        opacity: isAllAccounts ? 0.35 : 1.0,
                        child: GestureDetector(
                          onTap: isAllAccounts
                              ? null
                              : () => context.push('/budget'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: cs.primary.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.scrollText,
                                  size: 13,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'History',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  icon: const Icon(LucideIcons.search, size: 22),
                  tooltip: 'Search',
                  onPressed: _startSearch,
                ),
                IconButton(
                  key: _settingsIconKey,
                  icon: const Icon(LucideIcons.slidersHorizontal, size: 22),
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
                ref.invalidate(transactionPeriodOffsetsProvider);
              },
              child: summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
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
              bottom: 20 + MediaQuery.paddingOf(context).bottom,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: FloatingActionButton(
                      key: _addFabKey,
                      heroTag: 'add_fab',
                      elevation: 0,
                      highlightElevation: 0,
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      onPressed: () =>
                          context.push('/transactions/add?type=expense'),
                      child: const Icon(Icons.add, size: 28),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    if (!showTutorial) return scaffold;
    return Stack(
      children: [
        scaffold,
        TutorialOverlay(
          steps: _buildTutorialSteps(),
          onComplete: _completeTutorial,
        ),
      ],
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
    final accentColor = AppTheme.primaryText(cs);

    final isAllAccounts = selectedAccountId == null;

    final filteredTxs = _searchQuery.isEmpty
        ? txs
        : txs
              .where(
                (tx) => tx.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    final categoryFilteredTxs = _selectedCategoryFilter == null
        ? filteredTxs
        : filteredTxs
              .where((tx) => tx.categoryUuid == _selectedCategoryFilter)
              .toList();

    final groups = _groupByDate(categoryFilteredTxs);
    _visibleGroups = groups;
    final catGroups = _listView == _HomeListView.byCategory
        ? _groupByCategory(filteredTxs, cats)
        : const <_CatGroup>[];

    // Compute all expense categories for the current period, sorted by amount.
    final expenseTotals = <String, double>{};
    for (final tx in txs.where((t) => t.type == TransactionType.expense)) {
      expenseTotals[tx.categoryUuid] =
          (expenseTotals[tx.categoryUuid] ?? 0) + tx.amount;
    }
    final sortedExpenses = expenseTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final allCatStats = sortedExpenses
        .map((e) {
          final cat = cats.where((c) => c.uuid == e.key).firstOrNull;
          return cat != null ? _CatStat(cat, e.value) : null;
        })
        .whereType<_CatStat>()
        .toList();

    final period = ref.watch(selectedBudgetPeriodProvider);
    final periodOffset = ref.watch(selectedPeriodOffsetProvider);
    // Keep the last known offsets across provider reloads so swipe is never
    // briefly disabled during account switches or transaction mutations.
    final freshOffsets =
        ref.watch(transactionPeriodOffsetsProvider).asData?.value;
    if (freshOffsets != null) _cachedPeriodOffsets = freshOffsets;
    final transactionPeriodOffsets = _cachedPeriodOffsets;
    final olderPeriodOffset = _olderTransactionPeriodOffset(
      periodOffset,
      transactionPeriodOffsets,
    );
    // Always allow navigating toward the current period even if it has no
    // transactions — fall back to offset 0 so the right chevron is never
    // disabled while the user is stuck in a past period.
    final newerPeriodOffset = periodOffset == 0
        ? null
        : (_newerTransactionPeriodOffset(periodOffset, transactionPeriodOffsets) ?? 0);
    final periodLabel = DateFormat(
      'MMMM yyyy',
    ).format(DateTime(period.budgetYear, period.budgetMonth));
    final isCurrentPeriod = periodOffset == 0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 300 && olderPeriodOffset != null) {
          // Swipe right to the nearest older period with transactions.
          _goToPeriodOffset(olderPeriodOffset);
        } else if (velocity < -300 && newerPeriodOffset != null) {
          // Swipe left to the nearest newer period with transactions.
          _goToPeriodOffset(newerPeriodOffset);
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Period navigation header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                key: _periodNavKey,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous month',
                    onPressed: olderPeriodOffset == null
                        ? null
                        : () => _goToPeriodOffset(olderPeriodOffset),
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
                                color: accentColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next month',
                    onPressed: newerPeriodOffset == null
                        ? null
                        : () => _goToPeriodOffset(newerPeriodOffset),
                  ),
                ],
              ),
            ),
          ),

          if (!isAllAccounts)
            SliverToBoxAdapter(
              child: KeyedSubtree(
                key: _budgetHeroKey,
                child: _BudgetHero(summary: summary),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          if (allCatStats.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'TOP SPENDING',
                      style: tt.labelSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.10 * 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _TopCategoriesChart(
                      stats: allCatStats,
                      summary: summary,
                      selectedCategoryUuid: _selectedCategoryFilter,
                      onTap: (uuid) => setState(() {
                        _selectedCategoryFilter =
                            _selectedCategoryFilter == uuid ? null : uuid;
                      }),
                    ),
                    if (_selectedCategoryFilter != null &&
                        _listView == _HomeListView.byDay) ...[
                      const SizedBox(height: 10),
                      Builder(builder: (ctx) {
                        final selStat = allCatStats
                            .where(
                              (s) => s.category.uuid == _selectedCategoryFilter,
                            )
                            .firstOrNull;
                        final catColor = selStat != null
                            ? Color(selStat.category.colorValue)
                            : accentColor;
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                  () => _selectedCategoryFilter = null),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: catColor.withValues(alpha: 0.4),
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
                                    Icon(Icons.close,
                                        size: 13, color: catColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: _HomeListView.values.map((v) {
                  final selected = v == _listView;
                  final label = switch (v) {
                    _HomeListView.byDay      => 'By Day',
                    _HomeListView.byCategory => 'By Category',
                  };
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _listView = v),
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
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? accentColor
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          if (_listView == _HomeListView.byCategory) ...[
            if (catGroups.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No transactions yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final catGroup = catGroups[index];
                    final catColor =
                        Color(catGroup.category.colorValue);
                    return InkWell(
                      onTap: () => _showCategoryTimeline(
                          context, catGroup, cats, summary),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 13),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                IconData(
                                  catGroup.category.iconCodePoint,
                                  fontFamily:
                                      catGroup.category.iconFontFamily,
                                ),
                                size: 15,
                                color: catColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                catGroup.category.name,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${catGroup.count}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 88,
                              child: Text(
                                summary.formatAmount(catGroup.net.abs()),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'DM Mono',
                                  color: accentColor,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: catGroups.length,
                ),
              ),
          ] else ...[
            if (categoryFilteredTxs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      _selectedCategoryFilter != null
                          ? 'No transactions in this\ncategory for this period.'
                          : 'No transactions yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final group = groups[index];
                  if (_selectedCategoryFilter != null || _isSearching) {
                    return _ExpandableDayGroup(
                      key: ValueKey(group.day),
                      group: group,
                      cats: cats,
                      summary: summary,
                      initiallyExpanded: true,
                    );
                  }
                  return InkWell(
                    onTap: () => _showDayOverlay(
                      context,
                      group,
                      cats,
                      summary,
                      scopedTxs:
                          _searchQuery.isNotEmpty ? filteredTxs : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.label,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${group.txs.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 88,
                            child: Text(
                              summary.formatAmount(group.dayNet.abs()),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'DM Mono',
                                color: accentColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: groups.length),
              ),
          ],

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
    final overlayGroups = scopedTxs == null
        ? _visibleGroups
        : _groupByDate(scopedTxs);
    final initialIndex = overlayGroups.indexWhere(
      (visible) => visible.day == group.day,
    );
    if (initialIndex < 0) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DayOverlay(
        dayKeys: overlayGroups.map((g) => g.day).toList(),
        initialIndex: initialIndex,
        cats: cats,
        summary: summary,
        scopedTxs: scopedTxs,
      ),
    );
  }

  void _openSettings(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: AppTheme.deepNimbus.withValues(alpha: 0.54),
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
                color: Theme.of(ctx).colorScheme.outlineVariant,
              ),
              const Expanded(child: SettingsScreen(isModal: true)),
            ],
          ),
        );
      },
    );
  }

  void _completeTutorial() {
    setState(() => _tutorialDismissed = true);
    ref.read(settingsProvider.notifier).markTutorialComplete();
  }

  List<TutorialStep> _buildTutorialSteps() => [
        const TutorialStep(
          title: 'Welcome to FELOOSY',
          body:
              'Your personal budget, beautifully simple.\nLet\'s take a quick tour of the key features.',
        ),
        TutorialStep(
          title: 'Monthly Budget',
          body:
              'This card shows your budget vs. spending for the month. Tap "Set Budget" to define your monthly limit.',
          spotlightKey: _budgetHeroKey,
          padding: 16,
        ),
        TutorialStep(
          title: 'Add a Transaction',
          body:
              'Tap the + button to record a purchase, bill, or income. Pick a category to see where your money goes.',
          spotlightKey: _addFabKey,
        ),
        TutorialStep(
          title: 'Browse Past Months',
          body:
              'Tap the arrows or swipe left/right on the home screen to review any previous month.',
          spotlightKey: _periodNavKey,
        ),
        TutorialStep(
          title: 'Settings & More',
          body:
              'Change currency, manage accounts, customise categories, and back up your data from here.',
          spotlightKey: _settingsIconKey,
          padding: 18,
        ),
        const TutorialStep(
          title: 'You\'re all set!',
          body:
              'Start by adding your first transaction. FELOOSY will track the rest.',
        ),
      ];

  void _showCategoryTimeline(
    BuildContext context,
    _CatGroup catGroup,
    List<Category> cats,
    BudgetSummary summary,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryTimeline(
        category: catGroup.category,
        cats: cats,
        summary: summary,
      ),
    );
  }
}

class _DayGroup {
  final DateTime day;
  final String label;
  final double dayNet;
  final List<Transaction> txs;
  _DayGroup(this.day, this.label, this.dayNet, this.txs);
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
          : sum - tx.amount,
    );
    return _DayGroup(day, _dayLabel(day), dayNet, dayTxs);
  }).toList();
}

// ---------------------------------------------------------------------------
// Category timeline — bottom sheet showing one category's transactions by day
// ---------------------------------------------------------------------------

class _CategoryTimeline extends ConsumerStatefulWidget {
  final Category category;
  final List<Category> cats;
  final BudgetSummary summary;

  const _CategoryTimeline({
    required this.category,
    required this.cats,
    required this.summary,
  });

  @override
  ConsumerState<_CategoryTimeline> createState() =>
      _CategoryTimelineState();
}

class _CategoryTimelineState extends ConsumerState<_CategoryTimeline> {
  Future<void> _delete(Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('"${tx.description}" will be permanently removed.'),
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
    if (confirmed == true && mounted) {
      await ref.read(transactionsProvider.notifier).remove(tx.uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cat = widget.category;
    final catColor = Color(cat.colorValue);

    final allTxs =
        ref.watch(transactionsProvider).asData?.value ?? const <Transaction>[];
    final catTxs = allTxs
        .where((tx) => tx.categoryUuid == cat.uuid)
        .toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    if (catTxs.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    final dayGroups = _groupByDate(catTxs);

    // Flatten into a mixed list of headers + transactions for the ListView.
    final items = <Object>[];
    for (final g in dayGroups) {
      items.add(g.label);
      items.addAll(g.txs);
    }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      IconData(cat.iconCodePoint,
                          fontFamily: cat.iconFontFamily),
                      size: 15,
                      color: catColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    cat.name,
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
            Expanded(
              child: catTxs.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions.',
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final item = items[i];
                        if (item is String) {
                          return Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 14, 20, 4),
                            child: Text(
                              item,
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        }
                        final tx = item as Transaction;
                        final txCat = widget.cats
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
                                backgroundColor:
                                    Theme.of(ctx).colorScheme.error,
                                foregroundColor:
                                    Theme.of(ctx).colorScheme.onError,
                                icon: Icons.delete_outline,
                                label: 'Delete',
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(12),
                                ),
                              ),
                            ],
                          ),
                          child: TransactionTile(
                            transaction: tx,
                            category: txCat,
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
// Full-page overlay shown when tapping a day group
// ---------------------------------------------------------------------------

class _DayOverlay extends ConsumerStatefulWidget {
  final List<DateTime> dayKeys;
  final int initialIndex;
  final List<Category> cats;
  final BudgetSummary summary;
  final List<Transaction>? scopedTxs;

  const _DayOverlay({
    required this.dayKeys,
    required this.initialIndex,
    required this.cats,
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
        content: Text('"${tx.description}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
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
    final allTxs =
        widget.scopedTxs ??
        ref.watch(transactionsProvider).asData?.value ??
        const <Transaction>[];
    final visibleDays = widget.dayKeys
        .where((day) => allTxs.any(
              (tx) => DateUtils.dateOnly(tx.transactionDate) == day,
            ))
        .toList();

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
                .where((tx) =>
                    DateUtils.dateOnly(tx.transactionDate) == currentDay)
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
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
// Budget hero — remaining amount + thin progress line, no card surround
// ---------------------------------------------------------------------------

class _BudgetHero extends StatelessWidget {
  final BudgetSummary summary;
  const _BudgetHero({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = AppTheme.primaryText(cs);

    if (summary.budgetAmount == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            Text(
              'No budget set.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 6),
            TextButton(
              onPressed: () => context.push('/budget/set'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Set Budget'),
            ),
          ],
        ),
      );
    }

    final isOver = summary.isOverBudget;
    final heroColor = isOver ? cs.error : accentColor;
    final pct = summary.spentPercentage.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.formatAmount(summary.remaining.abs()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Mono',
              color: heroColor,
              height: 1.0,
              letterSpacing: 44 * -0.02,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isOver
                ? 'over budget · ${(pct * 100).round()}% spent'
                : 'remaining this month · ${(pct * 100).round()}% spent',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: cs.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(heroColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top spending categories bar chart (shared with budget screen)
// ---------------------------------------------------------------------------

class _CatStat {
  final Category category;
  final double amount;
  const _CatStat(this.category, this.amount);
}

class _TopCategoriesChart extends StatefulWidget {
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
  State<_TopCategoriesChart> createState() => _TopCategoriesChartState();
}

class _TopCategoriesChartState extends State<_TopCategoriesChart> {
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
    final cs = Theme.of(context).colorScheme;
    final accentColor = AppTheme.primaryText(cs);
    const barAreaHeight = 100.0;
    final maxAmount = widget.stats.first.amount;
    final hasSelection = widget.selectedCategoryUuid != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widget.stats.map((stat) {
          const barWidth = 64.0;
          final color = Color(stat.category.colorValue);
          final targetH =
              (barAreaHeight * (stat.amount / maxAmount)).clamp(4.0, barAreaHeight);
          final barH = _entered ? targetH : 0.0;
          final isSelected = stat.category.uuid == widget.selectedCategoryUuid;
          final isDeselected = hasSelection && !isSelected;

          return SizedBox(
            width: barWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onTap?.call(stat.category.uuid),
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
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            bottom: barH + 4,
                            left: 0,
                            right: 0,
                            child: Text(
                              widget.summary.formatAmount(stat.amount),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'DM Mono',
                                color: accentColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            bottom: 0,
                            left: 10,
                            right: 10,
                            height: barH,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
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
                    const SizedBox(height: 6),
                    Text(
                      stat.category.name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: accentColor,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expandable day group — shown when a category filter is active
// ---------------------------------------------------------------------------

class _ExpandableDayGroup extends StatefulWidget {
  final _DayGroup group;
  final List<Category> cats;
  final BudgetSummary summary;
  final bool initiallyExpanded;

  const _ExpandableDayGroup({
    super.key,
    required this.group,
    required this.cats,
    required this.summary,
    this.initiallyExpanded = false,
  });

  @override
  State<_ExpandableDayGroup> createState() => _ExpandableDayGroupState();
}

class _ExpandableDayGroupState extends State<_ExpandableDayGroup> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = AppTheme.primaryText(cs);
    final group = widget.group;
    final firstCat = group.txs.isNotEmpty
        ? widget.cats
            .where((c) => c.uuid == group.txs.first.categoryUuid)
            .firstOrNull
        : null;
    final lineColor = firstCat != null
        ? Color(firstCat.colorValue).withValues(alpha: 0.45)
        : cs.primary.withValues(alpha: 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    group.label,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${group.txs.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.summary.formatAmount(group.dayNet.abs()),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'DM Mono',
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 32, right: 16, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: lineColor, width: 2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: group.txs
                          .map(
                            (tx) => _InlineTransactionRow(
                              tx: tx,
                              cat: widget.cats
                                  .where((c) => c.uuid == tx.categoryUuid)
                                  .firstOrNull,
                              summary: widget.summary,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Single inline transaction row (YAML-indented, shown inside expanded day)
// ---------------------------------------------------------------------------

class _InlineTransactionRow extends StatelessWidget {
  final Transaction tx;
  final Category? cat;
  final BudgetSummary summary;

  const _InlineTransactionRow({
    required this.tx,
    required this.cat,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isExpense = tx.type == TransactionType.expense;
    final catColor = cat != null ? Color(cat!.colorValue) : cs.onSurfaceVariant;
    final amountPrefix = isExpense ? '-' : '+';
    final amountColor = isExpense
        ? AppTheme.expenseText(cs)
        : AppTheme.incomeText(cs);

    final label =
        tx.description.isEmpty ? (cat?.name ?? 'Transaction') : tx.description;
    final sublabel = tx.description.isNotEmpty ? cat?.name : null;

    return InkWell(
      onTap: () => context.push('/transactions/edit', extra: tx),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                IconData(
                  cat?.iconCodePoint ?? 0xe25a,
                  fontFamily: cat?.iconFontFamily ?? 'MaterialIcons',
                ),
                size: 15,
                color: catColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sublabel != null)
                    Text(
                      sublabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$amountPrefix${summary.formatAmount(tx.amount)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Mono',
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
