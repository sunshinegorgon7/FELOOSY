import '../../data/models/app_settings.dart';
import '../../data/models/transaction.dart';
import '../entities/budget_period.dart';
import '../entities/budget_summary.dart';

class BudgetService {
  static BudgetSummary computeSummary({
    required double budgetAmount,
    required List<Transaction> transactions,
    required AppSettings settings,
    required BudgetPeriod period,
  }) {
    double totalExpenses = 0;
    double totalIncome = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        totalExpenses += tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }

    return BudgetSummary(
      budgetAmount: budgetAmount,
      totalExpenses: totalExpenses,
      totalIncome: totalIncome,
      currencyCode: settings.currencyCode,
      currencySymbol: settings.currencySymbol,
      currencySymbolLeading: settings.currencySymbolLeading,
      period: period,
      transactionCount: transactions.length,
    );
  }
}
