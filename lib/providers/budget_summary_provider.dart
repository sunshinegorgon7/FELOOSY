import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/budget_summary.dart';
import '../domain/services/budget_service.dart';
import 'budget_period_provider.dart';
import 'budget_provider.dart';
import 'accounts_provider.dart';
import 'settings_provider.dart';
import 'transactions_provider.dart';

final budgetSummaryProvider = FutureProvider<BudgetSummary>((ref) async {
  final period = ref.watch(currentBudgetPeriodProvider);
  final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
  final transactions = await ref.watch(transactionsProvider.future);
  if (selectedAccountId == null) {
    return BudgetService.computeSummary(
      budgetAmount: 0,
      transactions: transactions,
      settings: await ref.watch(settingsProvider.future),
      period: period,
    );
  }
  final budget = await ref.watch(currentBudgetProvider.future);
  final account = ref.watch(activeAccountProvider);
  final settings = await ref.watch(settingsProvider.future);

  return BudgetService.computeSummary(
    budgetAmount: budget?.amount ?? account?.defaultMonthlyBudget ?? 0,
    transactions: transactions,
    settings: settings,
    period: period,
  );
});
