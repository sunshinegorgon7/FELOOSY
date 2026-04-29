import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import 'accounts_provider.dart';
import 'budget_period_provider.dart';
import 'database_provider.dart';
import 'firebase_sync_provider.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final period = ref.watch(currentBudgetPeriodProvider);
    final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
    final repo = ref.watch(transactionRepositoryProvider);
    if (selectedAccountId == null) {
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));
      return repo.getForPeriod(start, end);
    }
    return repo.getForPeriod(period.start, period.end, accountId: selectedAccountId);
  }

  Future<void> add(Transaction tx) async {
    await ref.read(transactionRepositoryProvider).insert(tx);
    try {
      final sync = ref.read(firebaseSyncProvider);
      await sync?.syncTransaction(tx);
      await sync?.flushPendingTransactionOps();
    } catch (e) {
      // Sync failure is non-fatal; operation is queued locally for retry.
      debugPrint('Firestore sync (add) error: $e');
    }
    ref.invalidateSelf();
  }

  Future<void> remove(String uuid) async {
    await ref.read(transactionRepositoryProvider).delete(uuid);
    try {
      final sync = ref.read(firebaseSyncProvider);
      await sync?.deleteTransaction(uuid);
      await sync?.flushPendingTransactionOps();
    } catch (e) {
      debugPrint('Firestore sync (delete) error: $e');
    }
    ref.invalidateSelf();
  }

  Future<void> edit(Transaction tx) async {
    await ref.read(transactionRepositoryProvider).save(tx);
    try {
      final sync = ref.read(firebaseSyncProvider);
      await sync?.syncTransaction(tx);
      await sync?.flushPendingTransactionOps();
    } catch (e) {
      debugPrint('Firestore sync (edit) error: $e');
    }
    ref.invalidateSelf();
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
        TransactionsNotifier.new);

final mostUsedCategoryUuidsProvider = FutureProvider<List<String>>((ref) async {
  ref.watch(transactionsProvider); // re-run when transactions change
  final activeAccount = ref.watch(activeAccountProvider);
  return ref.read(transactionRepositoryProvider).getMostUsedCategoryUuids(
        accountId: activeAccount?.id,
      );
});
