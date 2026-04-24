import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/budget_summary_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/recent_transactions_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(budgetSummaryProvider);
          ref.invalidate(transactionsProvider);
        },
        child: ListView(
          children: [
            // Budget summary card
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading budget: $e'),
              ),
              data: (summary) => BudgetSummaryCard(
                summary: summary,
                onSetBudget: () => context.push('/budget/set'),
              ),
            ),

            // Recent transactions
            txAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (txs) => catAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
                data: (cats) => RecentTransactionsList(
                  transactions: txs,
                  categories: cats,
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Icon(Icons.remove, color: Colors.red.shade600),
              ),
              title: const Text('Add Expense',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Record money spent'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/transactions/add?type=expense');
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: Icon(Icons.add, color: Colors.green.shade600),
              ),
              title: const Text('Add Income / Cashback',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Record money received'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/transactions/add?type=income');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
