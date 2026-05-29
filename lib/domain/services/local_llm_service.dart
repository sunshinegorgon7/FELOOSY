import 'dart:convert';
import 'package:fllama/fllama.dart';
import 'package:fllama/fllama_type.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import 'ai_analysis_result.dart';

class LocalLlmService {
  static Future<AiAnalysisResult> analyze({
    required String modelPath,
    required List<Transaction> transactions,
    required List<Category> categories,
    required String groupLabel,
    required String currencySymbol,
    required bool symbolLeading,
    required double budgetAmount,
  }) async {
    final fllama = Fllama.instance();
    if (fllama == null) return const AiAnalysisFailure('fllama unavailable');

    double? contextId;
    try {
      final ctx = await fllama.initContext(modelPath, nCtx: 2048, nBatch: 512);
      if (ctx == null) return const AiAnalysisFailure('Failed to load model');
      contextId = double.parse(ctx['contextId'].toString());

      final rawPrompt = _buildPrompt(
        transactions: transactions,
        categories: categories,
        groupLabel: groupLabel,
        currencySymbol: currencySymbol,
        symbolLeading: symbolLeading,
        budgetAmount: budgetAmount,
      );

      // Use the model's chat template so instruction-tuned models respond correctly
      final formatted = await fllama.getFormattedChat(
        contextId,
        messages: [RoleContent(role: 'user', content: rawPrompt)],
      );

      final result = await fllama.completion(
        contextId,
        prompt: formatted ?? rawPrompt,
        nPredict: 512,
        temperature: 0.35,
        stop: ['<end_of_turn>', '<eos>', 'Human:', 'User:'],
        emitRealtimeCompletion: false,
      );

      final text = result?['text'] as String?
          ?? result?['content'] as String?
          ?? '';

      if (text.isEmpty) return const AiAnalysisFailure('Empty model response');

      final jsonStr = _extractJson(text);
      if (jsonStr == null) return const AiAnalysisFailure('No JSON found in response');

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final rawInsights = json['insights'];
      final insights = rawInsights is List
          ? rawInsights.map((e) => e.toString()).toList()
          : <String>[];

      return AiAnalysisSuccess(
        summary: json['summary']?.toString() ?? '',
        insights: insights,
        advice: json['advice']?.toString() ?? '',
      );
    } catch (e) {
      return AiAnalysisFailure(e.toString());
    } finally {
      if (contextId != null) {
        await fllama.releaseContext(contextId);
      }
    }
  }

  static String? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    try {
      final candidate = text.substring(start, end + 1);
      jsonDecode(candidate); // validate it parses
      return candidate;
    } catch (_) {
      return null;
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
    if (budgetAmount > 0) sb.writeln('Budget: ${fmt(budgetAmount)}');
    sb.writeln('Total Income: ${fmt(totalIncome)}');
    sb.writeln('Total Expenses: ${fmt(totalExpenses)}');
    if (net != null) {
      sb.writeln(isOver
          ? 'Net: ${fmt(net.abs())} over budget'
          : 'Net: ${fmt(net)} under budget');
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
      sb.writeln(
          'Income,income,${fmt(totalIncome)},${transactions.where((t) => t.type == TransactionType.income).length}');
    }
    sb.writeln();
    sb.writeln(
      'Analyze this budget summary. Respond with ONLY a JSON object — no explanation, '
      'no preamble, no markdown. The JSON must have exactly three keys: '
      '"summary" (string: 2–3 sentences covering income, total spending, and '
      'whether over or under budget, use exact figures), '
      '"insights" (array of exactly 2–3 short strings identifying spending drivers '
      'with exact figures), '
      '"advice" (string: one concise actionable suggestion). '
      'Start your response with {',
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
