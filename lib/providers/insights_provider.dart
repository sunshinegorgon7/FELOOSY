import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/month_calculator.dart';
import '../domain/services/insights_service.dart';
import 'accounts_provider.dart';
import 'budget_period_provider.dart';
import 'budget_summary_provider.dart';
import 'categories_provider.dart';
import 'database_provider.dart';
import 'transactions_provider.dart';

final insightsProvider = FutureProvider<List<Insight>>((ref) async {
  // React to any transaction change in the current period
  final currentTxns = await ref.watch(transactionsProvider.future);

  final period = ref.watch(selectedBudgetPeriodProvider);
  final monthStartDay = ref.watch(effectiveMonthStartDayProvider);
  final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
  final categories = ref.watch(categoriesProvider).asData?.value ?? const [];

  // Fetch previous period transactions (one DB read)
  final prevPeriod = MonthCalculator.previousPeriod(period, monthStartDay);
  final txRepo = ref.read(transactionRepositoryProvider);
  final prevTxns = await txRepo.getForPeriod(
    prevPeriod.start,
    prevPeriod.end,
    accountId: selectedAccountId,
  );

  final summary = await ref.watch(budgetSummaryProvider.future);
  final budget = summary.budgetAmount > 0 ? summary.budgetAmount : null;

  return InsightsService.compute(
    currentTxns: currentTxns,
    previousTxns: prevTxns,
    categories: categories,
    budget: budget,
    periodStart: period.start,
    periodEnd: period.end,
    today: DateTime.now(),
  );
});
