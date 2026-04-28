import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import 'budget_period_provider.dart';
import 'database_provider.dart';
import 'firebase_sync_provider.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final period = ref.watch(currentBudgetPeriodProvider);
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getForPeriod(period.start, period.end);
  }

  Future<void> add(Transaction tx) async {
    await ref.read(transactionRepositoryProvider).insert(tx);
    try {
      await ref.read(firebaseSyncProvider)?.syncTransaction(tx);
    } catch (e) {
      // Sync failure is non-fatal; sign-out will push all local data as safety net
      debugPrint('Firestore sync (add) error: $e');
    }
    ref.invalidateSelf();
  }

  Future<void> remove(String uuid) async {
    await ref.read(transactionRepositoryProvider).delete(uuid);
    try {
      await ref.read(firebaseSyncProvider)?.deleteTransaction(uuid);
    } catch (e) {
      debugPrint('Firestore sync (delete) error: $e');
    }
    ref.invalidateSelf();
  }

  Future<void> edit(Transaction tx) async {
    await ref.read(transactionRepositoryProvider).save(tx);
    try {
      await ref.read(firebaseSyncProvider)?.syncTransaction(tx);
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
  return ref.read(transactionRepositoryProvider).getMostUsedCategoryUuids();
});
