import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget.dart';
import 'accounts_provider.dart';
import 'budget_period_provider.dart';
import 'database_provider.dart';
import 'firebase_sync_provider.dart';

class CurrentBudgetNotifier extends AsyncNotifier<Budget?> {
  @override
  Future<Budget?> build() async {
    final period = ref.watch(currentBudgetPeriodProvider);
    final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
    if (selectedAccountId == null) return null;
    final repo = ref.watch(budgetRepositoryProvider);
    return repo.getForPeriod(
      period.budgetYear,
      period.budgetMonth,
      accountId: selectedAccountId,
    );
  }

  Future<void> setAmount(double amount) async {
    final period = ref.read(currentBudgetPeriodProvider);
    final repo = ref.read(budgetRepositoryProvider);
    final account = ref.read(activeAccountProvider);
    if (account?.id == null) return;
    final now = DateTime.now();
    final budget = Budget(
      accountId: account!.id!,
      year: period.budgetYear,
      month: period.budgetMonth,
      amount: amount,
      currencyCode: account.currencyCode,
      createdAt: now,
      updatedAt: now,
    );
    await repo.upsert(budget);
    ref.read(firebaseSyncProvider)?.syncBudget(budget);
    ref.invalidateSelf();
  }
}

final currentBudgetProvider =
    AsyncNotifierProvider<CurrentBudgetNotifier, Budget?>(
        CurrentBudgetNotifier.new);
