import '../../data/models/category.dart';
import '../../data/models/transaction.dart';

enum InsightType { pace, trend, anomaly, pattern }

enum InsightSeverity { info, positive, warning }

class Insight {
  final InsightType type;
  final InsightSeverity severity;
  final String text;

  const Insight({
    required this.type,
    required this.severity,
    required this.text,
  });
}

class InsightsService {
  InsightsService._();

  static List<Insight> compute({
    required List<Transaction> currentTxns,
    required List<Transaction> previousTxns,
    required List<Category> categories,
    double? budget,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime today,
  }) {
    final results = <Insight>[];

    final pace = _paceInsight(currentTxns, budget, periodStart, periodEnd, today);
    if (pace != null) results.add(pace);

    results.addAll(_trendInsights(currentTxns, previousTxns, categories));

    final anomaly = _anomalyInsight(currentTxns, today);
    if (anomaly != null) results.add(anomaly);

    final pattern = _patternInsight(currentTxns, previousTxns);
    if (pattern != null) results.add(pattern);

    // Warning first, then positive, then info
    results.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return results.take(3).toList();
  }

  // ── Pace ─────────────────────────────────────────────────────────────────

  static Insight? _paceInsight(
    List<Transaction> txns,
    double? budget,
    DateTime periodStart,
    DateTime periodEnd,
    DateTime today,
  ) {
    if (budget == null || budget <= 0) return null;

    final expenses = txns
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, t) => s + t.amount);

    if (expenses == 0) return null;

    final spentFraction = expenses / budget;

    if (spentFraction > 1.0) {
      return const Insight(
        type: InsightType.pace,
        severity: InsightSeverity.warning,
        text: 'Budget exceeded',
      );
    }

    final totalDays = periodEnd.difference(periodStart).inDays + 1;
    final elapsed =
        today.difference(periodStart).inDays.clamp(1, totalDays);
    final timeFraction = elapsed / totalDays;

    if (spentFraction > timeFraction + 0.20) {
      return const Insight(
        type: InsightType.pace,
        severity: InsightSeverity.warning,
        text: 'Budget at risk',
      );
    }

    // Only show "on track" after 30% of the period has passed
    if (timeFraction >= 0.30 && spentFraction < timeFraction - 0.20) {
      return const Insight(
        type: InsightType.pace,
        severity: InsightSeverity.positive,
        text: 'Spending on track',
      );
    }

    return null;
  }

  // ── Trends ───────────────────────────────────────────────────────────────

  static List<Insight> _trendInsights(
    List<Transaction> current,
    List<Transaction> previous,
    List<Category> categories,
  ) {
    if (previous.isEmpty) return [];

    Map<String, double> expensesByCategory(List<Transaction> txns) {
      final map = <String, double>{};
      for (final t in txns) {
        if (t.type != TransactionType.expense) continue;
        map[t.categoryUuid] = (map[t.categoryUuid] ?? 0) + t.amount;
      }
      return map;
    }

    final currMap = expensesByCategory(current);
    final prevMap = expensesByCategory(previous);

    final deltas = <MapEntry<String, double>>[];
    for (final e in currMap.entries) {
      final prev = prevMap[e.key];
      if (prev != null && prev > 0) {
        final delta = (e.value - prev) / prev;
        if (delta.abs() > 0.30) deltas.add(MapEntry(e.key, delta));
      }
    }

    deltas.sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return deltas.take(2).map((e) {
      final pct = (e.value.abs() * 100).round();
      final catName =
          categories.where((c) => c.uuid == e.key).firstOrNull?.name ??
          'Spending';
      final isUp = e.value > 0;
      return Insight(
        type: InsightType.trend,
        severity: isUp ? InsightSeverity.warning : InsightSeverity.positive,
        text: isUp ? '$catName up $pct%' : '$catName down $pct%',
      );
    }).toList();
  }

  // ── Anomaly ──────────────────────────────────────────────────────────────

  static Insight? _anomalyInsight(List<Transaction> txns, DateTime today) {
    final byDate = <DateTime, double>{};
    for (final t in txns) {
      if (t.type != TransactionType.expense) continue;
      final day = DateTime(
        t.transactionDate.year,
        t.transactionDate.month,
        t.transactionDate.day,
      );
      byDate[day] = (byDate[day] ?? 0) + t.amount;
    }

    if (byDate.length < 3) return null;

    final mean =
        byDate.values.fold<double>(0, (s, v) => s + v) / byDate.length;
    if (mean <= 0) return null;

    final todayOnly = DateTime(today.year, today.month, today.day);
    final sevenDaysAgo = todayOnly.subtract(const Duration(days: 7));

    DateTime? anomalyDay;
    double anomalyRatio = 0;

    for (final entry in byDate.entries) {
      if (!entry.key.isBefore(sevenDaysAgo)) {
        final ratio = entry.value / mean;
        if (ratio > 2.5 && ratio > anomalyRatio) {
          anomalyDay = entry.key;
          anomalyRatio = ratio;
        }
      }
    }

    if (anomalyDay == null) return null;

    return Insight(
      type: InsightType.anomaly,
      severity: InsightSeverity.warning,
      text: 'High spend: ${_shortDayName(anomalyDay, todayOnly)}',
    );
  }

  static String _shortDayName(DateTime date, DateTime todayOnly) {
    if (date == todayOnly) return 'today';
    if (date == todayOnly.subtract(const Duration(days: 1))) return 'yesterday';
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday];
  }

  // ── Pattern ──────────────────────────────────────────────────────────────

  static Insight? _patternInsight(
    List<Transaction> current,
    List<Transaction> previous,
  ) {
    final expenses = [...current, ...previous]
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenses.length < 14) return null;

    final sumByDow = List<double>.filled(8, 0);
    final countByDow = List<int>.filled(8, 0);

    for (final t in expenses) {
      final dow = t.transactionDate.weekday; // 1=Mon, 7=Sun
      sumByDow[dow] += t.amount;
      countByDow[dow]++;
    }

    int bestDow = -1;
    double bestAvg = 0;

    for (int d = 1; d <= 7; d++) {
      if (countByDow[d] == 0) continue;
      final avg = sumByDow[d] / countByDow[d];
      if (avg > bestAvg) {
        bestAvg = avg;
        bestDow = d;
      }
    }

    if (bestDow == -1) return null;

    final total = expenses.fold<double>(0, (s, t) => s + t.amount);
    final uniqueDays = expenses
        .map((t) => DateTime(
              t.transactionDate.year,
              t.transactionDate.month,
              t.transactionDate.day,
            ))
        .toSet()
        .length;
    if (uniqueDays == 0) return null;

    final overallDailyAvg = total / uniqueDays;
    if (bestAvg < overallDailyAvg * 1.5) return null;

    const dayNames = [
      '',
      'Mondays',
      'Tuesdays',
      'Wednesdays',
      'Thursdays',
      'Fridays',
      'Saturdays',
      'Sundays',
    ];
    return Insight(
      type: InsightType.pattern,
      severity: InsightSeverity.info,
      text: 'Peaks on ${dayNames[bestDow]}',
    );
  }
}
