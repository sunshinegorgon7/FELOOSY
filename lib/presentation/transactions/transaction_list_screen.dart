import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import 'widgets/transaction_tile.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);
    final catAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: txAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (txs) {
          if (txs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('No transactions yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Tap + to add one.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                ],
              ),
            );
          }

          final cats = catAsync.valueOrNull ?? [];
          final grouped = _groupByDate(txs);

          return ListView.builder(
            itemCount: grouped.length,
            itemBuilder: (ctx, i) {
              final entry = grouped[i];
              if (entry is _DateHeader) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    entry.label,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                  ),
                );
              }

              final tx = (entry as _TxEntry).tx;
              final cat =
                  cats.where((c) => c.uuid == tx.categoryUuid).firstOrNull;

              return Slidable(
                key: ValueKey(tx.uuid),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _confirmDelete(context, ref, tx),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(12)),
                    ),
                  ],
                ),
                child: TransactionTile(transaction: tx, category: cat),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add?type=expense'),
        child: const Icon(Icons.add),
      ),
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

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Transaction tx) async {
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
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
