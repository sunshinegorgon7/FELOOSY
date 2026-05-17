import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_keys.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';

sealed class AiAnalysisResult {
  const AiAnalysisResult();
}

class AiAnalysisSuccess extends AiAnalysisResult {
  final String summary;
  final List<String> insights;
  final String advice;
  const AiAnalysisSuccess({
    required this.summary,
    required this.insights,
    required this.advice,
  });
}

class AiAnalysisQuotaExceeded extends AiAnalysisResult {
  const AiAnalysisQuotaExceeded();
}

class AiAnalysisFailure extends AiAnalysisResult {
  final String message;
  const AiAnalysisFailure(this.message);
}

class AiAnalysisService {
  static final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: kGeminiApiKey,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      temperature: 0.4,
    ),
  );

  static Future<AiAnalysisResult> analyze({
    required List<Transaction> transactions,
    required List<Category> categories,
    required String groupLabel,
    required String currencySymbol,
    required bool symbolLeading,
    required double budgetAmount,
  }) async {
    try {
      final prompt = _buildPrompt(
        transactions: transactions,
        categories: categories,
        groupLabel: groupLabel,
        currencySymbol: currencySymbol,
        symbolLeading: symbolLeading,
        budgetAmount: budgetAmount,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null || text.isEmpty) {
        return const AiAnalysisFailure('Empty response from AI');
      }

      final json = jsonDecode(text) as Map<String, dynamic>;
      final rawInsights = json['insights'];
      final insights = rawInsights is List
          ? rawInsights.map((e) => e.toString()).toList()
          : <String>[];

      return AiAnalysisSuccess(
        summary: json['summary']?.toString() ?? '',
        insights: insights,
        advice: json['advice']?.toString() ?? '',
      );
    } on GenerativeAIException catch (e) {
      if (e.message.contains('429') ||
          e.message.toLowerCase().contains('quota') ||
          e.message.toLowerCase().contains('rate')) {
        return const AiAnalysisQuotaExceeded();
      }
      return AiAnalysisFailure(e.message);
    } catch (e) {
      return AiAnalysisFailure(e.toString());
    }
  }

  static String _buildPrompt({
    required List<Transaction> transactions,
    required List<Category> categories,
    required String groupLabel,
    required String currencySymbol,
    required bool symbolLeading,
    required double budgetAmount,
  }) {
    final catMap = {for (final c in categories) c.uuid: c};

    final totals = <String, _CatTotal>{};
    double totalExpenses = 0;
    double totalIncome = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        totalExpenses += tx.amount;
        final name = catMap[tx.categoryUuid]?.name ?? 'Other';
        totals[name] = (totals[name] ?? const _CatTotal()) + tx;
      } else {
        totalIncome += tx.amount;
      }
    }

    final net = budgetAmount > 0 ? budgetAmount - totalExpenses + totalIncome : null;
    final isOver = net != null && net < 0;

    String fmt(double v) => symbolLeading
        ? '$currencySymbol${v.toStringAsFixed(2)}'
        : '${v.toStringAsFixed(2)} $currencySymbol';

    final sb = StringBuffer();
    sb.writeln('Period: $groupLabel');
    if (budgetAmount > 0) {
      sb.writeln('Budget: ${fmt(budgetAmount)}');
    }
    sb.writeln('Total Income: ${fmt(totalIncome)}');
    sb.writeln('Total Expenses: ${fmt(totalExpenses)}');
    if (net != null) {
      sb.writeln(
        isOver
            ? 'Net: ${fmt(net.abs())} over budget'
            : 'Net: ${fmt(net)} under budget',
      );
    }
    sb.writeln('Transactions: ${transactions.length}');
    sb.writeln();
    sb.writeln('category,type,total,transactions');
    for (final entry in (totals.entries.toList()
          ..sort((a, b) => b.value.total.compareTo(a.value.total)))
        .take(15)) {
      sb.writeln(
          '${entry.key},expense,${fmt(entry.value.total)},${entry.value.count}');
    }
    if (totalIncome > 0) {
      sb.writeln('Income,income,${fmt(totalIncome)},${transactions.where((t) => t.type == TransactionType.income).length}');
    }

    sb.writeln();
    sb.writeln(
      'Analyze this budget summary and respond in JSON with exactly three keys: '
      '"summary" (2-3 sentences covering income, total spending, and whether over or under budget — use exact figures), '
      '"insights" (array of exactly 2-3 short bullets identifying the main spending drivers using exact figures from the data), '
      'and "advice" (one concise, actionable improvement suggestion). '
      'Keep the tone clear and supportive. Use the exact figures from the data provided.',
    );

    return sb.toString();
  }
}

class _CatTotal {
  final double total;
  final int count;
  const _CatTotal({this.total = 0, this.count = 0});

  _CatTotal operator +(Transaction tx) =>
      _CatTotal(total: total + tx.amount, count: count + 1);
}
