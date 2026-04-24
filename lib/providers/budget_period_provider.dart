import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/month_calculator.dart';
import '../domain/entities/budget_period.dart';
import 'settings_provider.dart';

final currentBudgetPeriodProvider = Provider<BudgetPeriod>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  final day =
      settingsAsync.whenOrNull(data: (s) => s.monthStartDay) ?? 1;
  return MonthCalculator.periodContaining(DateTime.now(), day);
});
