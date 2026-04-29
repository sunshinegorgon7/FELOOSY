import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/utils/currency_formatter.dart';
import '../data/models/transaction.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_period_provider.dart';
import '../providers/database_provider.dart';

Future<void> syncBalanceHomeWidget(WidgetRef ref) async {
  final accounts = ref.read(accountsProvider).value ?? const [];
  final favorite = accounts.where((a) => a.isFavorite).firstOrNull ?? accounts.firstOrNull;

  if (favorite?.id == null) {
    await HomeWidget.saveWidgetData<String>('widget_account_name', 'Favorite account');
    await HomeWidget.saveWidgetData<String>('widget_available_amount', '\$0.00');
    await HomeWidget.updateWidget(androidName: 'FeloosyBalanceWidgetProvider');
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
  await HomeWidget.saveWidgetData<String>(
    'widget_available_amount',
    CurrencyFormatter.formatWith(
      amount: remaining,
      symbol: favorite.currencySymbol,
      symbolLeading: favorite.currencySymbolLeading,
    ),
  );
  await HomeWidget.updateWidget(androidName: 'FeloosyBalanceWidgetProvider');
}
