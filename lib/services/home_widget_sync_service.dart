import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../data/models/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_period_provider.dart';
import '../providers/database_provider.dart';

const _spendWidgetProvider =
    'com.feloosy.app.widget.FeloosyTodayWidgetProvider';

/// Syncs the spending widget with current-period data for the favourite account.
///
/// Shows: available budget (budget − expenses + income) as the headline number,
/// top-3 expense categories for the period + "Other" collapsed remainder,
/// all as a stacked progress bar and colour-coded legend.
Future<void> syncSpendingWidget(WidgetRef ref) async {
  final accounts = ref.read(accountsProvider).value ?? const [];
  final favorite =
      accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.firstOrNull;

  if (favorite?.id == null) {
    await _writeEmpty('Wallet', 'AED');
    return;
  }

  final period = ref.read(currentBudgetPeriodProvider);
  final txRepo = ref.read(transactionRepositoryProvider);
  final budgetRepo = ref.read(budgetRepositoryProvider);
  final categoryRepo = ref.read(categoryRepositoryProvider);

  final txs = await txRepo.getForPeriod(
    period.start,
    period.end,
    accountId: favorite!.id,
  );

  double expenses = 0;
  double income = 0;
  final Map<String, double> byExpenseCategory = {};

  for (final tx in txs) {
    if (tx.type == TransactionType.expense) {
      expenses += tx.amount;
      byExpenseCategory[tx.categoryUuid] =
          (byExpenseCategory[tx.categoryUuid] ?? 0) + tx.amount;
    } else {
      income += tx.amount;
    }
  }

  final budget = await budgetRepo.getForPeriod(
    period.budgetYear,
    period.budgetMonth,
    accountId: favorite.id!,
  );
  final budgetAmount = budget?.amount ?? favorite.defaultMonthlyBudget ?? 0;
  final available = budgetAmount - expenses + income;

  if (byExpenseCategory.isEmpty) {
    await _writeEmpty(favorite.name, favorite.currencyCode,
        available: available);
    return;
  }

  // Sort expense categories descending; top 3 named, rest collapsed.
  final sorted = byExpenseCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final List<Map<String, dynamic>> categories = [];
  double otherAmount = 0;

  for (int i = 0; i < sorted.length; i++) {
    if (i < 3) {
      final cat = await categoryRepo.getByUuid(sorted[i].key);
      // colorValue is Flutter ARGB int; encode as #AARRGGBB for Android.
      final colorHex =
          '#${(cat?.colorValue ?? 0xFFFFFFFF).toRadixString(16).padLeft(8, '0').toUpperCase()}';
      categories.add({
        'name': cat?.name ?? 'Other',
        'amount': sorted[i].value,
        'color': colorHex,
      });
    } else {
      otherAmount += sorted[i].value;
    }
  }

  if (otherAmount > 0) {
    // rgba(246,241,227,0.4) → ARGB #66F6F1E3
    categories.add({
      'name': 'Other',
      'amount': otherAmount,
      'color': '#66F6F1E3',
    });
  }

  await HomeWidget.saveWidgetData<String>(
      'widget_spend_account_name', favorite.name);
  await HomeWidget.saveWidgetData<String>(
      'widget_spend_available', available.toString());
  await HomeWidget.saveWidgetData<String>(
      'widget_spend_currency_code', favorite.currencyCode);
  await HomeWidget.saveWidgetData<String>(
      'widget_spend_categories_json', jsonEncode(categories));
  await HomeWidget.saveWidgetData<bool>('widget_spend_is_empty', false);
  await HomeWidget.updateWidget(qualifiedAndroidName: _spendWidgetProvider);
}

Future<void> _writeEmpty(
  String accountName,
  String currencyCode, {
  double available = 0,
}) async {
  await HomeWidget.saveWidgetData<String>(
      'widget_spend_account_name', accountName);
  await HomeWidget.saveWidgetData<String>(
      'widget_spend_available', available.toString());
  await HomeWidget.saveWidgetData<String>(
      'widget_spend_currency_code', currencyCode);
  await HomeWidget.saveWidgetData<String>('widget_spend_categories_json', '[]');
  await HomeWidget.saveWidgetData<bool>('widget_spend_is_empty', true);
  await HomeWidget.updateWidget(qualifiedAndroidName: _spendWidgetProvider);
}
