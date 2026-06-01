import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import 'ai_analysis_result.dart';

class LocalAnalysisService {
  static AiAnalysisSuccess analyze({
    required List<Transaction> transactions,
    required List<Category> categories,
    required String groupLabel,
    required String currencySymbol,
    required bool symbolLeading,
    required double budgetAmount,
  }) {
    final catMap = {for (final c in categories) c.uuid: c};

    // Exclude carry-over system transactions — they are budget adjustments,
    // not real spending, and would skew category breakdowns and advice.
    final analysisTransactions = transactions.where((t) => !t.isCarryOver).toList();

    final catTotals = <String, double>{};
    double totalExpenses = 0;
    double totalIncome = 0;

    for (final tx in analysisTransactions) {
      if (tx.type == TransactionType.expense) {
        totalExpenses += tx.amount;
        final name = catMap[tx.categoryUuid]?.name ?? 'Other';
        catTotals[name] = (catTotals[name] ?? 0) + tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }

    final sorted = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCat = sorted.isNotEmpty ? sorted.first : null;
    final net = budgetAmount > 0 ? budgetAmount - totalExpenses + totalIncome : null;
    final isOver = net != null && net < 0;

    String fmt(double v) => symbolLeading
        ? '$currencySymbol${v.toStringAsFixed(2)}'
        : '${v.toStringAsFixed(2)} $currencySymbol';

    // Summary
    final overUnder = isOver
        ? 'exceeded the budget by ${fmt(net.abs())}'
        : net != null
            ? 'stayed ${fmt(net)} under budget'
            : 'had no budget set';
    final summary = 'In $groupLabel, you brought in ${fmt(totalIncome)} '
        'and spent ${fmt(totalExpenses)} across ${analysisTransactions.length} transactions. '
        'You $overUnder.';

    // Insights
    final insights = <String>[];
    if (topCat != null) {
      final pct = totalExpenses > 0
          ? ((topCat.value / totalExpenses) * 100).round()
          : 0;
      insights.add(
        '${topCat.key} was your largest expense at ${fmt(topCat.value)} ($pct% of spending).',
      );
    }
    if (sorted.length >= 2) {
      insights.add(
        '${sorted[1].key} came in second at ${fmt(sorted[1].value)}.',
      );
    }
    if (totalIncome > 0 && totalExpenses > 0) {
      final savingsRate =
          ((totalIncome - totalExpenses) / totalIncome * 100).round();
      insights.add(
        savingsRate > 0
            ? 'You saved approximately $savingsRate% of your income this period.'
            : 'Expenses exceeded income by ${fmt(totalExpenses - totalIncome)} this period.',
      );
    }

    // Advice
    String advice;
    if (topCat != null && totalExpenses > 0) {
      final pct = ((topCat.value / totalExpenses) * 100).round();
      if (pct > 40) {
        advice =
            'Consider reviewing your ${topCat.key} spending — it accounts for $pct% of your total expenses.';
      } else if (isOver) {
        advice =
            'You went over budget this period. Reviewing your top spending categories could help you identify where to trim.';
      } else {
        advice =
            "You're on track. Keeping ${topCat.key} spending steady will help maintain this balance.";
      }
    } else {
      advice = 'Add more transactions to get detailed spending insights.';
    }

    return AiAnalysisSuccess(
      summary: summary,
      insights: insights,
      advice: advice,
    );
  }
}
