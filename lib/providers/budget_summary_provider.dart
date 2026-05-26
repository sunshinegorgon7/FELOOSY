import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../domain/entities/budget_summary.dart';
import '../domain/services/budget_service.dart';
import '../core/utils/month_calculator.dart';
import 'budget_period_provider.dart';
import 'budget_provider.dart';
import 'accounts_provider.dart';
import 'settings_provider.dart';
import 'transactions_provider.dart';
import 'database_provider.dart';

final budgetSummaryProvider = FutureProvider<BudgetSummary>((ref) async {
  final period = ref.watch(selectedBudgetPeriodProvider);
  final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
  final transactions = await ref.watch(transactionsProvider.future);
  final settings = await ref.watch(settingsProvider.future);

  if (selectedAccountId == null) {
    return BudgetService.computeSummary(
      budgetAmount: 0,
      transactions: transactions,
      settings: settings,
      period: period,
    );
  }

  final budget = await ref.watch(currentBudgetProvider.future);
  final account = ref.watch(activeAccountProvider);
  final budgetAmount =
      budget?.amount ?? account?.defaultMonthlyBudget ?? settings.defaultMonthlyBudget;

  double carryOverAmount = 0.0;
  if ((account?.carryOverEnabled ?? false) && budgetAmount > 0) {
    final effectiveDay = ref.read(effectiveMonthStartDayProvider);
    final prevPeriod = MonthCalculator.previousPeriod(period, effectiveDay);
    final txRepo = ref.read(transactionRepositoryProvider);
    final budgetRepo = ref.read(budgetRepositoryProvider);

    final prevTxs = await txRepo.getForPeriod(
      prevPeriod.start,
      prevPeriod.end,
      accountId: selectedAccountId,
    );
    final prevBudget = await budgetRepo.getForPeriod(
      prevPeriod.budgetYear,
      prevPeriod.budgetMonth,
      accountId: selectedAccountId,
    );
    final prevBudgetAmount =
        prevBudget?.amount ?? account?.defaultMonthlyBudget ?? settings.defaultMonthlyBudget;

    if (prevTxs.isNotEmpty) {
      final prevExpenses = prevTxs
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);
      final prevIncome = prevTxs
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (s, t) => s + t.amount);
      final prevRemaining = prevBudgetAmount - prevExpenses + prevIncome;
      carryOverAmount = prevRemaining > 0 ? prevRemaining : 0.0;
    }
  }

  return BudgetService.computeSummary(
    budgetAmount: budgetAmount,
    transactions: transactions,
    settings: settings,
    period: period,
    carryOverAmount: carryOverAmount,
  );
});
