import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import 'budget_period_provider.dart';
import 'database_provider.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final period = ref.watch(currentBudgetPeriodProvider);
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getForPeriod(period.start, period.end);
  }

  Future<void> add(Transaction tx) async {
    await ref.read(transactionRepositoryProvider).insert(tx);
    ref.invalidateSelf();
  }

  Future<void> remove(String uuid) async {
    await ref.read(transactionRepositoryProvider).delete(uuid);
    ref.invalidateSelf();
  }

  Future<void> edit(Transaction tx) async {
    await ref.read(transactionRepositoryProvider).save(tx);
    ref.invalidateSelf();
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
        TransactionsNotifier.new);

final mostUsedCategoryUuidsProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(transactionRepositoryProvider).getMostUsedCategoryUuids();
});
