import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../domain/entities/budget_summary.dart';
import '../domain/services/budget_service.dart';
import '../services/carry_over_service.dart';
import 'budget_period_provider.dart';
import 'budget_provider.dart';
import 'accounts_provider.dart';
import 'settings_provider.dart';
import 'transactions_provider.dart';
import 'database_provider.dart';

final budgetSummaryProvider = FutureProvider<BudgetSummary>((ref) async {
  final period = ref.watch(selectedBudgetPeriodProvider);
  final selectedAccountId = ref.watch(selectedHomeAccountIdProvider);
  // Watch for reactivity — rebuilds this provider when transactions mutate.
  ref.watch(transactionsProvider);

  final settings = await ref.watch(settingsProvider.future);

  if (selectedAccountId == null) {
    return BudgetService.computeSummary(
      budgetAmount: 0,
      transactions: const [],
      settings: settings,
      period: period,
    );
  }

  final budget = await ref.watch(currentBudgetProvider.future);
  final account = ref.watch(activeAccountProvider);
  final budgetAmount =
      budget?.amount ?? account?.defaultMonthlyBudget ?? 0;

  final txRepo = ref.read(transactionRepositoryProvider);
  final budgetRepo = ref.read(budgetRepositoryProvider);

  if (account != null && account.carryOverEnabled) {
    final monthStartDay = ref.read(effectiveMonthStartDayProvider);
    final changed = await CarryOverService.generateIfNeeded(
      account: account,
      period: period,
      monthStartDay: monthStartDay,
      txRepo: txRepo,
      budgetRepo: budgetRepo,
      settings: settings,
    );
    if (changed) {
      // Refresh the transaction list so the synced carry-over appears there too.
      ref.invalidate(transactionsProvider);
    }
  }

  // Fetch fresh from the repo (includes any just-synced carry-over).
  final transactions = await txRepo.getForPeriod(
    period.start,
    period.end,
    accountId: selectedAccountId,
  );

  // Separate carry-over from regular transactions.
  // Regular transactions go into computeSummary; carry-over adjusts the budget
  // via the carryOverAmount field so it is not double-counted.
  final regularTxs = transactions.where((t) => !t.isCarryOver).toList();
  final coIncome = transactions
      .where((t) => t.isCarryOver && t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);
  final coExpense = transactions
      .where((t) => t.isCarryOver && t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);
  // Signed: positive = surplus carried in, negative = deficit carried in.
  final carryOverNet = coIncome - coExpense;

  return BudgetService.computeSummary(
    budgetAmount: budgetAmount,
    transactions: regularTxs,
    settings: settings,
    period: period,
    carryOverAmount: carryOverNet,
  );
});
