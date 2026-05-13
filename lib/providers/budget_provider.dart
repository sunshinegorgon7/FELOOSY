import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget.dart';
import 'accounts_provider.dart';
import 'budget_period_provider.dart';
import 'database_provider.dart';

class CurrentBudgetNotifier extends AsyncNotifier<Budget?> {
  @override
  Future<Budget?> build() async {
    final period = ref.watch(selectedBudgetPeriodProvider);
    final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
    if (selectedAccountId == null) return null;
    final repo = ref.watch(budgetRepositoryProvider);
    final stored = await repo.getForPeriod(
      period.budgetYear,
      period.budgetMonth,
      accountId: selectedAccountId,
    );
    if (stored != null) return stored;

    // No explicit budget row yet — synthesize one from the wallet's default
    // so the Budget screen can display it. Nothing is written to the DB here;
    // setAmount() persists a real row the first time the user edits it.
    final account = ref.watch(activeAccountProvider);
    final defaultAmount = account?.defaultMonthlyBudget ?? 0;
    if (defaultAmount <= 0) return null;
    final now = DateTime.now();
    return Budget(
      accountId: selectedAccountId,
      year: period.budgetYear,
      month: period.budgetMonth,
      amount: defaultAmount,
      currencyCode: account!.currencyCode,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> setAmount(double amount) async {
    final period = ref.read(selectedBudgetPeriodProvider);
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
    ref.invalidateSelf();
  }
}

final currentBudgetProvider =
    AsyncNotifierProvider<CurrentBudgetNotifier, Budget?>(
        CurrentBudgetNotifier.new);
