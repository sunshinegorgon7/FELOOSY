import 'package:flutter_test/flutter_test.dart';
import 'package:feloosy/core/utils/month_calculator.dart';

void main() {
  group('MonthCalculator.periodContaining', () {
    group('default start day = 1', () {
      test('mid-month falls in same month', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 3, 15), 1);
        expect(period.budgetYear, 2026);
        expect(period.budgetMonth, 3);
        expect(period.start, DateTime(2026, 3, 1));
      });

      test('first day is inclusive', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 4, 1), 1);
        expect(period.budgetMonth, 4);
      });

      test('last day of month is still in same period', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 3, 31), 1);
        expect(period.budgetMonth, 3);
      });

      test('February — non-leap year ends Mar 31 period next', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2025, 2, 28), 1);
        expect(period.budgetYear, 2025);
        expect(period.budgetMonth, 2);
      });

      test('February — leap year', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2024, 2, 29), 1);
        expect(period.budgetYear, 2024);
        expect(period.budgetMonth, 2);
      });
    });

    group('custom start day = 25', () {
      test('day before start day belongs to previous period', () {
        // Mar 10 → period started Feb 25
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 3, 10), 25);
        expect(period.budgetYear, 2026);
        expect(period.budgetMonth, 2);
        expect(period.start, DateTime(2026, 2, 25));
      });

      test('start day itself starts new period', () {
        // Mar 25 → period started Mar 25
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 3, 25), 25);
        expect(period.budgetYear, 2026);
        expect(period.budgetMonth, 3);
        expect(period.start, DateTime(2026, 3, 25));
      });

      test('end is day before next period start', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 3, 25), 25);
        // end should be Apr 24 23:59:59...
        expect(period.end.year, 2026);
        expect(period.end.month, 4);
        expect(period.end.day, 24);
      });

      test('January period spans Dec 25 – Jan 24', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 1, 10), 25);
        expect(period.budgetYear, 2025);
        expect(period.budgetMonth, 12);
        expect(period.start, DateTime(2025, 12, 25));
      });
    });

    group('start day = 28 (max, February edge cases)', () {
      test('Feb 1 is in January period (day < 28)', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 2, 1), 28);
        expect(period.budgetYear, 2026);
        expect(period.budgetMonth, 1);
      });

      test('Feb 28 starts February period', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 2, 28), 28);
        expect(period.budgetYear, 2026);
        expect(period.budgetMonth, 2);
        expect(period.start, DateTime(2026, 2, 28));
      });

      test('March 1 still in February period (day < 28)', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 3, 1), 28);
        expect(period.budgetYear, 2026);
        expect(period.budgetMonth, 2);
      });

      test('March 28 starts March period', () {
        final period = MonthCalculator.periodContaining(
            DateTime(2026, 3, 28), 28);
        expect(period.budgetYear, 2026);
        expect(period.budgetMonth, 3);
      });
    });

    group('recentPeriods', () {
      test('returns correct count', () {
        final periods = MonthCalculator.recentPeriods(
            DateTime(2026, 4, 15), 1, 6);
        expect(periods.length, 6);
      });

      test('first period is current, rest are past', () {
        final periods = MonthCalculator.recentPeriods(
            DateTime(2026, 4, 15), 1, 3);
        expect(periods[0].budgetMonth, 4);
        expect(periods[1].budgetMonth, 3);
        expect(periods[2].budgetMonth, 2);
      });
    });
  });
}
