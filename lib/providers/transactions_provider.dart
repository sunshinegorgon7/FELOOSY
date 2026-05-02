import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/month_calculator.dart';
import '../data/models/budget.dart';
import '../data/models/transaction.dart';
import 'accounts_provider.dart';
import 'budget_period_provider.dart';
import 'budget_provider.dart';
import 'database_provider.dart';
import 'firebase_sync_provider.dart';
import 'settings_provider.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final period = ref.watch(selectedBudgetPeriodProvider);
    final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
    final repo = ref.watch(transactionRepositoryProvider);
    if (selectedAccountId == null) {
      return repo.getForPeriod(period.start, period.end);
    }
    return repo.getForPeriod(period.start, period.end, accountId: selectedAccountId);
  }

  Future<void> add(Transaction tx) async {
    await ref.read(transactionRepositoryProvider).insert(tx);
    await _ensureBudgetExists(tx);
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
    await _ensureBudgetExists(tx);
    try {
      final sync = ref.read(firebaseSyncProvider);
      await sync?.syncTransaction(tx);
      await sync?.flushPendingTransactionOps();
    } catch (e) {
      debugPrint('Firestore sync (edit) error: $e');
    }
    ref.invalidateSelf();
  }

  /// Creates a budget row for the month the transaction falls in, if one does
  /// not already exist. Uses the account's month-start-day override when set,
  /// otherwise falls back to the global setting.
  Future<void> _ensureBudgetExists(Transaction tx) async {
    final accounts = ref.read(accountsProvider).value ?? [];
    final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;
    if (account?.id == null) return;

    final globalDay = ref
            .read(settingsProvider)
            .whenOrNull(data: (s) => s.monthStartDay) ??
        1;
    final monthStartDay = account!.monthStartDay ?? globalDay;

    final period =
        MonthCalculator.periodContaining(tx.transactionDate, monthStartDay);

    final budgetRepo = ref.read(budgetRepositoryProvider);
    final existing = await budgetRepo.getForPeriod(
      period.budgetYear,
      period.budgetMonth,
      accountId: account.id!,
    );
    if (existing != null) return;

    final now = DateTime.now();
    await budgetRepo.upsert(Budget(
      accountId: account.id!,
      year: period.budgetYear,
      month: period.budgetMonth,
      amount: account.defaultMonthlyBudget ?? 0,
      currencyCode: account.currencyCode,
      createdAt: now,
      updatedAt: now,
    ));
    ref.invalidate(currentBudgetProvider);
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
