import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/category.dart';
import '../../../data/models/transaction.dart';
import '../../transactions/widgets/transaction_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final recent = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Text('Recent Transactions', style: tt.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No transactions yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
          ...recent.map((tx) {
            final cat = categories
                .where((c) => c.uuid == tx.categoryUuid)
                .firstOrNull;
            return TransactionTile(transaction: tx, category: cat);
          }),
      ],
    );
  }
}
