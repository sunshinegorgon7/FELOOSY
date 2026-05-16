import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../data/models/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_period_provider.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';

const _androidProvider = 'com.feloosy.app.widget.FeloosyWidgetProvider';
const _iOSKind = 'FeloosyWidget';
const _appGroup = 'group.com.feloosy.feloosy';

/// Syncs widget data for the favourite account.
/// Header: available = monthlyBudget − totalSpentThisMonth.
/// Bar/legend: top-3 expense categories for the current budget month + Other.
Future<void> syncWidget(WidgetRef ref) async {
  try {
    await HomeWidget.setAppGroupId(_appGroup);
    await _sync(ref);
  } catch (_) {}
}

Future<void> _sync(WidgetRef ref) async {
  // Sync the app's theme preference so the widget can match it exactly,
  // even when the user has overridden the system default.
  final themeMode = ref.read(settingsProvider)
      .whenOrNull(data: (s) => s.themeMode) ?? 'system';
  await HomeWidget.saveWidgetData<String>('fw_theme_mode', themeMode);

  final accounts = ref.read(accountsProvider).value ?? const [];
  final account =
      accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.firstOrNull;

  if (account?.id == null) {
    await _writeEmpty('Wallet', 'AED');
    return;
  }

  final period = ref.read(currentBudgetPeriodProvider);
  final txRepo = ref.read(transactionRepositoryProvider);
  final budgetRepo = ref.read(budgetRepositoryProvider);
  final categoryRepo = ref.read(categoryRepositoryProvider);

  // --- Header: month-to-date available balance ---
  final monthTxs = await txRepo.getForPeriod(
    period.start,
    period.end,
    accountId: account!.id,
  );
  double spentThisMonth = 0;
  for (final tx in monthTxs) {
    if (tx.type == TransactionType.expense) spentThisMonth += tx.amount;
  }
  final budget = await budgetRepo.getForPeriod(
    period.budgetYear,
    period.budgetMonth,
    accountId: account.id!,
  );
  final monthlyBudget = budget?.amount ?? account.defaultMonthlyBudget ?? 0;
  final available = monthlyBudget - spentThisMonth;

  // --- Bar/legend: this month's expenses by category ---
  final Map<String, double> byCategory = {};
  for (final tx in monthTxs) {
    if (tx.type == TransactionType.expense) {
      byCategory[tx.categoryUuid] =
          (byCategory[tx.categoryUuid] ?? 0) + tx.amount;
    }
  }

  final todayEmpty = byCategory.isEmpty;
  final todayTotal =
      byCategory.values.fold(0.0, (sum, v) => sum + v);

  final sorted = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final List<Map<String, dynamic>> catList = [];
  double otherAmount = 0;

  for (int i = 0; i < sorted.length; i++) {
    if (i < 3) {
      final cat = await categoryRepo.getByUuid(sorted[i].key);
      // Flutter ARGB int → #AARRGGBB for Android Color.parseColor
      final colorHex =
          '#${(cat?.colorValue ?? 0xFFFFFFFF).toRadixString(16).padLeft(8, '0').toUpperCase()}';
      catList.add({
        'name': cat?.name ?? 'Other',
        'amount': sorted[i].value,
        'color': colorHex,
      });
    } else {
      otherAmount += sorted[i].value;
    }
  }
  if (otherAmount > 0) {
    catList.add({'name': 'Other', 'amount': otherAmount, 'color': '#FF5B8DB8'});
  }

  await HomeWidget.saveWidgetData<String>('fw_account_name', account.name);
  await HomeWidget.saveWidgetData<String>(
      'fw_currency_code', account.currencyCode);
  await HomeWidget.saveWidgetData<String>('fw_available', available.toString());
  await HomeWidget.saveWidgetData<bool>('fw_is_over_budget', available < 0);
  await HomeWidget.saveWidgetData<bool>('fw_today_empty', todayEmpty);
  await HomeWidget.saveWidgetData<String>(
      'fw_today_total', todayTotal.toString());
  await HomeWidget.saveWidgetData<String>(
      'fw_categories_json', jsonEncode(catList));

  await HomeWidget.updateWidget(
    qualifiedAndroidName: _androidProvider,
    iOSName: _iOSKind,
  );
}

Future<void> _writeEmpty(String accountName, String currencyCode) async {
  await HomeWidget.saveWidgetData<String>('fw_account_name', accountName);
  await HomeWidget.saveWidgetData<String>('fw_currency_code', currencyCode);
  await HomeWidget.saveWidgetData<String>('fw_available', '0');
  await HomeWidget.saveWidgetData<bool>('fw_is_over_budget', false);
  await HomeWidget.saveWidgetData<bool>('fw_today_empty', true);
  await HomeWidget.saveWidgetData<String>('fw_today_total', '0');
  await HomeWidget.saveWidgetData<String>('fw_categories_json', '[]');
  await HomeWidget.updateWidget(
    qualifiedAndroidName: _androidProvider,
    iOSName: _iOSKind,
  );
}
