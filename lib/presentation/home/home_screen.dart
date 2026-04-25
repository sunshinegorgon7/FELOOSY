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
import '../transactions/widgets/transaction_tile.dart';
import 'widgets/spending_pie_chart.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryUuid;

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

    // Only active categories for display purposes
    final activeCats = cats.where((c) => c.isActive).toList();

    final filteredTxs = _selectedCategoryUuid == null
        ? txs
        : txs
            .where((tx) => tx.categoryUuid == _selectedCategoryUuid)
            .toList();

    final selectedCat = _selectedCategoryUuid != null
        ? cats.where((c) => c.uuid == _selectedCategoryUuid).firstOrNull
        : null;

    final grouped = _groupByDate(filteredTxs);

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

        // Transactions section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              children: [
                Text(
                  selectedCat != null ? selectedCat.name : 'Transactions',
                  style: tt.titleSmall,
                ),
                if (selectedCat != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategoryUuid = null),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),

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
                final item = grouped[index];
                if (item is _DateHeader) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      item.label,
                      style: tt.labelMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                final tx = (item as _TxEntry).tx;
                final cat =
                    cats.where((c) => c.uuid == tx.categoryUuid).firstOrNull;
                return Slidable(
                  key: ValueKey(tx.uuid),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) => _confirmDelete(context, tx),
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
              },
              childCount: grouped.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  List<Object> _groupByDate(List<Transaction> txs) {
    final result = <Object>[];
    String? lastLabel;
    for (final tx in txs) {
      final label = _dateLabel(tx.transactionDate);
      if (label != lastLabel) {
        result.add(_DateHeader(label));
        lastLabel = label;
      }
      result.add(_TxEntry(tx));
    }
    return result;
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

class _DateHeader {
  final String label;
  _DateHeader(this.label);
}

class _TxEntry {
  final Transaction tx;
  _TxEntry(this.tx);
}
