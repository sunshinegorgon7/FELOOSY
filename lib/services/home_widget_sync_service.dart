import 'dart:convert';

import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../app/app_theme.dart';
import '../core/constants/default_categories.dart';
import '../core/utils/month_calculator.dart';
import '../data/models/account.dart';
import '../data/models/transaction.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/entities/budget_period.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_period_provider.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';

const _androidProvider = 'com.feloosy.app.widget.FeloosyWidgetProvider';
const _iOSKind = 'FeloosyWidget';
const _appGroup = 'group.com.feloosy.feloosy';

/// Syncs widget data for the favourite account (called from the running app).
/// Header: available = monthlyBudget − totalSpentThisMonth.
/// Bar/legend: top-3 expense categories for the current budget month + Other.
Future<void> syncWidget(WidgetRef ref) async {
  try {
    await HomeWidget.setAppGroupId(_appGroup);

    final themeMode = ref.read(settingsProvider)
        .whenOrNull(data: (s) => s.themeMode) ?? 'system';
    final accounts = ref.read(accountsProvider).value ?? const [];
    final account =
        accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.firstOrNull;

    await _writeWidget(
      account: account,
      period: ref.read(currentBudgetPeriodProvider),
      themeMode: themeMode,
      txRepo: ref.read(transactionRepositoryProvider),
      budgetRepo: ref.read(budgetRepositoryProvider),
      categoryRepo: ref.read(categoryRepositoryProvider),
    );
  } catch (_) {}
}

/// Provider-free variant for the SMS background isolate, where there is no
/// `WidgetRef`. Resolves the favourite account and its budget period directly
/// from repositories so the launcher widget updates even while the app process
/// is dead.
Future<void> syncWidgetFromRepos({
  required List<Account> accounts,
  required SettingsRepository settingsRepo,
  required TransactionRepository txRepo,
  required BudgetRepository budgetRepo,
  required CategoryRepository categoryRepo,
}) async {
  try {
    await HomeWidget.setAppGroupId(_appGroup);

    final settings = await settingsRepo.get();
    final account =
        accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.firstOrNull;
    final day = account?.monthStartDay ?? settings.monthStartDay;
    final period = MonthCalculator.periodContaining(
      DateUtils.dateOnly(DateTime.now()),
      day,
    );

    await _writeWidget(
      account: account,
      period: period,
      themeMode: settings.themeMode,
      txRepo: txRepo,
      budgetRepo: budgetRepo,
      categoryRepo: categoryRepo,
    );
  } catch (_) {}
}

Future<void> _writeWidget({
  required Account? account,
  required BudgetPeriod period,
  required String themeMode,
  required TransactionRepository txRepo,
  required BudgetRepository budgetRepo,
  required CategoryRepository categoryRepo,
}) async {
  // Sync the app's theme preference so the widget can match it exactly,
  // even when the user has overridden the system default.
  await HomeWidget.saveWidgetData<String>('fw_theme_mode', themeMode);

  if (account?.id == null) {
    await _writeEmpty('Wallet', 'AED');
    return;
  }

  // --- Header: month-to-date available balance ---
  final monthTxs = await txRepo.getForPeriod(
    period.start,
    period.end,
    accountId: account!.id,
  );
  double spentThisMonth = 0;
  double incomeThisMonth = 0;
  for (final tx in monthTxs) {
    if (tx.type == TransactionType.expense) spentThisMonth += tx.amount;
    if (tx.type == TransactionType.income) incomeThisMonth += tx.amount;
  }
  final budget = await budgetRepo.getForPeriod(
    period.budgetYear,
    period.budgetMonth,
    accountId: account.id!,
  );
  final monthlyBudget = budget?.amount ?? account.defaultMonthlyBudget ?? 0;
  final available = monthlyBudget + incomeThisMonth - spentThisMonth;

  // --- Bar/legend: this month's expenses by category ---
  // Exclude carry-over from the visual breakdown — its effect is already
  // baked into the available-to-spend number above.
  final Map<String, double> byCategory = {};
  for (final tx in monthTxs) {
    if (tx.type == TransactionType.expense &&
        tx.categoryUuid != kCarryOverCategoryUuid) {
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
    if (i < 5) {
      final cat = await categoryRepo.getByUuid(sorted[i].key);
      final uuid = cat?.uuid ?? '';
      final colorValue = cat?.colorValue ?? 0xFF6E8790;
      // Pre-compute the chart bar colour for each theme so the widget
      // doesn't need to replicate AppTheme.categoryBarColor logic
      final lightColor = AppTheme.categoryBarColor(
        uuid: uuid, colorValue: colorValue,
        colorScheme: AppTheme.light.colorScheme,
      );
      final darkColor = AppTheme.categoryBarColor(
        uuid: uuid, colorValue: colorValue,
        colorScheme: AppTheme.dark.colorScheme,
      );
      catList.add({
        'name': cat?.name ?? 'Other',
        'amount': sorted[i].value,
        'colorLight': '#${lightColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
        'colorDark':  '#${darkColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
      });
    } else {
      otherAmount += sorted[i].value;
    }
  }
  if (otherAmount > 0) {
    catList.add({
      'name': 'Other',
      'amount': otherAmount,
      'colorLight': '#ff2a6090',
      'colorDark':  '#ff80c0e0',
    });
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
