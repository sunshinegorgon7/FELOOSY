import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/utils/currency_formatter.dart';
import '../data/models/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_period_provider.dart';
import '../providers/database_provider.dart';

const _balanceWidgetProvider =
    'com.feloosy.app.widget.FeloosyBalanceWidgetProvider';

Future<void> syncBalanceHomeWidget(WidgetRef ref) async {
  final accounts = ref.read(accountsProvider).value ?? const [];
  final favorite = accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.firstOrNull;

  if (favorite?.id == null) {
    await HomeWidget.saveWidgetData<String>('widget_account_name', 'Favorite wallet');
    await HomeWidget.saveWidgetData<String>('widget_available_amount', '\$0.00');
    await HomeWidget.saveWidgetData<bool>('widget_has_available_money', true);
    await HomeWidget.updateWidget(qualifiedAndroidName: _balanceWidgetProvider);
    return;
  }

  final period = ref.read(currentBudgetPeriodProvider);
  final txRepo = ref.read(transactionRepositoryProvider);
  final budgetRepo = ref.read(budgetRepositoryProvider);
  final txs = await txRepo.getForPeriod(period.start, period.end, accountId: favorite!.id);
  final budget = await budgetRepo.getForPeriod(
    period.budgetYear,
    period.budgetMonth,
    accountId: favorite.id!,
  );

  double expenses = 0;
  double income = 0;
  for (final tx in txs) {
    if (tx.type == TransactionType.expense) {
      expenses += tx.amount;
    } else {
      income += tx.amount;
    }
  }

  final budgetAmount = budget?.amount ?? favorite.defaultMonthlyBudget ?? 0;
  final remaining = budgetAmount - expenses + income;

  await HomeWidget.saveWidgetData<String>('widget_account_name', favorite.name);
  await HomeWidget.saveWidgetData<bool>('widget_has_available_money', remaining >= 0);
  await HomeWidget.saveWidgetData<String>(
    'widget_available_amount',
    CurrencyFormatter.formatWith(
      amount: remaining,
      symbol: favorite.currencySymbol,
      symbolLeading: favorite.currencySymbolLeading,
    ),
  );
  await HomeWidget.updateWidget(qualifiedAndroidName: _balanceWidgetProvider);
}

const _todayWidgetProvider =
    'com.feloosy.app.widget.FeloosyTodayWidgetProvider';

Future<void> syncTodayHomeWidget(WidgetRef ref) async {
  final accounts = ref.read(accountsProvider).value ?? const [];
  final favorite =
      accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.firstOrNull;

  if (favorite?.id == null) {
    await HomeWidget.saveWidgetData<String>('widget_today_account_name', 'Wallet');
    await HomeWidget.saveWidgetData<String>('widget_today_total', '0');
    await HomeWidget.saveWidgetData<String>('widget_today_currency_code', 'AED');
    await HomeWidget.saveWidgetData<String>('widget_today_categories_json', '[]');
    await HomeWidget.saveWidgetData<bool>('widget_today_is_empty', true);
    await HomeWidget.updateWidget(qualifiedAndroidName: _todayWidgetProvider);
    return;
  }

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

  final txRepo = ref.read(transactionRepositoryProvider);
  final categoryRepo = ref.read(categoryRepositoryProvider);

  final txs = await txRepo.getForPeriod(
    todayStart,
    todayEnd,
    accountId: favorite!.id,
  );
  final expenses =
      txs.where((t) => t.type == TransactionType.expense).toList();

  // Group by category UUID, sum amounts.
  final Map<String, double> byCategory = {};
  for (final tx in expenses) {
    byCategory[tx.categoryUuid] =
        (byCategory[tx.categoryUuid] ?? 0) + tx.amount;
  }

  if (byCategory.isEmpty) {
    await HomeWidget.saveWidgetData<String>(
        'widget_today_account_name', favorite.name);
    await HomeWidget.saveWidgetData<String>('widget_today_total', '0');
    await HomeWidget.saveWidgetData<String>(
        'widget_today_currency_code', favorite.currencyCode);
    await HomeWidget.saveWidgetData<String>('widget_today_categories_json', '[]');
    await HomeWidget.saveWidgetData<bool>('widget_today_is_empty', true);
    await HomeWidget.updateWidget(qualifiedAndroidName: _todayWidgetProvider);
    return;
  }

  // Sort descending by amount; top 3 named, rest collapsed into Other.
  final sorted = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final List<Map<String, dynamic>> categories = [];
  double otherAmount = 0;

  for (int i = 0; i < sorted.length; i++) {
    if (i < 3) {
      final category = await categoryRepo.getByUuid(sorted[i].key);
      // colorValue is ARGB int; encode as #AARRGGBB for Android Color.parseColor.
      final colorHex =
          '#${(category?.colorValue ?? 0xFFFFFFFF).toRadixString(16).padLeft(8, '0').toUpperCase()}';
      categories.add({
        'name': category?.name ?? 'Other',
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

  final total = byCategory.values.fold(0.0, (a, b) => a + b);

  await HomeWidget.saveWidgetData<String>(
      'widget_today_account_name', favorite.name);
  await HomeWidget.saveWidgetData<String>('widget_today_total', total.toString());
  await HomeWidget.saveWidgetData<String>(
      'widget_today_currency_code', favorite.currencyCode);
  await HomeWidget.saveWidgetData<String>(
      'widget_today_categories_json', jsonEncode(categories));
  await HomeWidget.saveWidgetData<bool>('widget_today_is_empty', false);
  await HomeWidget.updateWidget(qualifiedAndroidName: _todayWidgetProvider);
}
