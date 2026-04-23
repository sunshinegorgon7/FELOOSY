import 'budget_period.dart';

class BudgetSummary {
  final double budgetAmount;
  final double totalExpenses;
  final double totalIncome;
  final String currencyCode;
  final String currencySymbol;
  final bool currencySymbolLeading;
  final BudgetPeriod period;
  final int transactionCount;

  const BudgetSummary({
    required this.budgetAmount,
    required this.totalExpenses,
    required this.totalIncome,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencySymbolLeading,
    required this.period,
    required this.transactionCount,
  });

  double get remaining => budgetAmount - totalExpenses + totalIncome;

  double get spentPercentage =>
      budgetAmount == 0 ? 0 : (totalExpenses - totalIncome) / budgetAmount;

  bool get isOverBudget => remaining < 0;

  String formatAmount(double amount) {
    final formatted = amount.toStringAsFixed(2);
    return currencySymbolLeading
        ? '$currencySymbol $formatted'
        : '$formatted $currencySymbol';
  }
}
