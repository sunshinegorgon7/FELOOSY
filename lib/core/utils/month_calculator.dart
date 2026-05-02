import '../../domain/entities/budget_period.dart';

class MonthCalculator {
  /// Returns the budget period that contains [referenceDate].
  ///
  /// [monthStartDay] must be 1–28 (enforced by Settings UI).
  ///
  /// Examples with monthStartDay = 25:
  ///   referenceDate = Mar 10 → period Feb 25 – Mar 24 (labeled "February")
  ///   referenceDate = Mar 28 → period Mar 25 – Apr 24 (labeled "March")
  ///
  /// Examples with monthStartDay = 1 (default):
  ///   referenceDate = Mar 15 → period Mar 1 – Mar 31 (labeled "March")
  static BudgetPeriod periodContaining(
      DateTime referenceDate, int monthStartDay) {
    assert(monthStartDay >= 1 && monthStartDay <= 28);

    late DateTime periodStart;

    if (referenceDate.day >= monthStartDay) {
      periodStart = DateTime(
          referenceDate.year, referenceDate.month, monthStartDay);
    } else {
      final prevMonth = referenceDate.month - 1;
      final prevYear =
          prevMonth == 0 ? referenceDate.year - 1 : referenceDate.year;
      final normalizedPrevMonth = prevMonth == 0 ? 12 : prevMonth;
      periodStart = DateTime(prevYear, normalizedPrevMonth, monthStartDay);
    }

    final nextPeriodStart = _addOneMonth(periodStart);
    // End is the last microsecond before the next period starts
    final periodEnd =
        nextPeriodStart.subtract(const Duration(microseconds: 1));

    return BudgetPeriod(
      start: periodStart,
      end: periodEnd,
      budgetYear: periodStart.year,
      budgetMonth: periodStart.month,
    );
  }

  /// Returns the [count] most recent periods ending at [referenceDate].
  static List<BudgetPeriod> recentPeriods(
      DateTime referenceDate, int monthStartDay, int count) {
    final periods = <BudgetPeriod>[];
    var current = periodContaining(referenceDate, monthStartDay);
    for (var i = 0; i < count; i++) {
      periods.add(current);
      final prevStart = _subtractOneMonth(current.start);
      current = periodContaining(prevStart, monthStartDay);
    }
    return periods;
  }

  /// Returns the period immediately before [period].
  static BudgetPeriod previousPeriod(BudgetPeriod period, int monthStartDay) {
    final prevStart = _subtractOneMonth(period.start);
    return periodContaining(prevStart, monthStartDay);
  }

  /// Returns the period immediately after [period].
  static BudgetPeriod nextPeriod(BudgetPeriod period, int monthStartDay) {
    final nextStart = _addOneMonth(period.start);
    return periodContaining(nextStart, monthStartDay);
  }

  static DateTime _addOneMonth(DateTime date) {
    final nextMonth = date.month + 1;
    return nextMonth > 12
        ? DateTime(date.year + 1, 1, date.day)
        : DateTime(date.year, nextMonth, date.day);
  }

  static DateTime _subtractOneMonth(DateTime date) {
    final prevMonth = date.month - 1;
    return prevMonth == 0
        ? DateTime(date.year - 1, 12, date.day)
        : DateTime(date.year, prevMonth, date.day);
  }
}
