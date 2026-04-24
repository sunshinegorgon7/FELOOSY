import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget.dart';
import 'budget_period_provider.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

class CurrentBudgetNotifier extends AsyncNotifier<Budget?> {
  @override
  Future<Budget?> build() async {
    final period = ref.watch(currentBudgetPeriodProvider);
    final repo = ref.watch(budgetRepositoryProvider);
    return repo.getForPeriod(period.budgetYear, period.budgetMonth);
  }

  Future<void> setAmount(double amount) async {
    final period = ref.read(currentBudgetPeriodProvider);
    final repo = ref.read(budgetRepositoryProvider);
    final settings = await ref.read(settingsProvider.future);
    final now = DateTime.now();
    await repo.upsert(Budget(
      year: period.budgetYear,
      month: period.budgetMonth,
      amount: amount,
      currencyCode: settings.currencyCode,
      createdAt: now,
      updatedAt: now,
    ));
    ref.invalidateSelf();
  }
}

final currentBudgetProvider =
    AsyncNotifierProvider<CurrentBudgetNotifier, Budget?>(
        CurrentBudgetNotifier.new);
