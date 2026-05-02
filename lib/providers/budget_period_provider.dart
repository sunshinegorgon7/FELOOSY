import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/month_calculator.dart';
import '../domain/entities/budget_period.dart';
import 'accounts_provider.dart';
import 'settings_provider.dart';

/// Resolves the month-start day to use for the currently selected wallet.
/// Falls back to the global setting when the wallet has no override or when
/// "all wallets" is selected.
final effectiveMonthStartDayProvider = Provider<int>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  final globalDay = settingsAsync.whenOrNull(data: (s) => s.monthStartDay) ?? 1;
  final account = ref.watch(activeAccountProvider);
  return account?.monthStartDay ?? globalDay;
});

/// The period that contains today, computed with the effective start day.
final currentBudgetPeriodProvider = Provider<BudgetPeriod>((ref) {
  final day = ref.watch(effectiveMonthStartDayProvider);
  return MonthCalculator.periodContaining(DateTime.now(), day);
});

/// How many months to offset from the current period.
/// 0 = current period, -1 = previous month, -2 = two months ago, etc.
/// Reset to 0 whenever the selected wallet changes.
final selectedPeriodOffsetProvider =
    NotifierProvider<_SelectedPeriodOffsetNotifier, int>(
        _SelectedPeriodOffsetNotifier.new);

class _SelectedPeriodOffsetNotifier extends Notifier<int> {
  @override
  int build() {
    // Reset to 0 when the selected wallet changes.
    ref.watch(selectedHomeAccountIdProvider);
    return 0;
  }

  void goBack() => state--;
  void goForward() {
    if (state < 0) state++;
  }

  void reset() => state = 0;
}

/// The budget period currently being viewed on the home screen.
final selectedBudgetPeriodProvider = Provider<BudgetPeriod>((ref) {
  final current = ref.watch(currentBudgetPeriodProvider);
  final offset = ref.watch(selectedPeriodOffsetProvider);
  final day = ref.watch(effectiveMonthStartDayProvider);
  if (offset == 0) return current;
  var period = current;
  // offset is always <= 0 (we don't allow navigating to the future)
  for (var i = 0; i > offset; i--) {
    period = MonthCalculator.previousPeriod(period, day);
  }
  return period;
});
