import 'package:uuid/uuid.dart';
import '../core/constants/default_categories.dart';
import '../core/utils/month_calculator.dart';
import '../data/models/account.dart';
import '../data/models/app_settings.dart';
import '../data/models/transaction.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../domain/entities/budget_period.dart';

class CarryOverService {
  static const _uuid = Uuid();

  /// Inserts a carry-over transaction for [account] in [period] if one does not
  /// already exist. Returns true when a transaction was inserted.
  ///
  /// Carry-over is a signed adjustment:
  ///   surplus (prev budget > prev spend) → income transaction
  ///   deficit (prev spend > prev budget) → expense transaction
  ///
  /// Previous-period carry-overs are excluded from the net calculation to
  /// prevent compounding (cascade) across multiple months.
  static Future<bool> generateIfNeeded({
    required Account account,
    required BudgetPeriod period,
    required int monthStartDay,
    required TransactionRepository txRepo,
    required BudgetRepository budgetRepo,
    required AppSettings settings,
  }) async {
    if (!account.carryOverEnabled || account.id == null) return false;

    // Quick non-atomic pre-check (avoids the prev-period DB query on most calls).
    final currentTxs = await txRepo.getForPeriod(
      period.start,
      period.end,
      accountId: account.id!,
    );
    if (currentTxs.any((t) => t.isCarryOver)) return false;

    final prevPeriod = MonthCalculator.previousPeriod(period, monthStartDay);
    final prevTxs = (await txRepo.getForPeriod(
      prevPeriod.start,
      prevPeriod.end,
      accountId: account.id!,
    )).where((t) => !t.isCarryOver).toList();

    // No recorded activity in the previous period — nothing to carry over.
    // This prevents a phantom carry-over when the user just started the app
    // and the prior period has a default budget but zero transactions.
    if (prevTxs.isEmpty) return false;

    final prevBudget = await budgetRepo.getForPeriod(
      prevPeriod.budgetYear,
      prevPeriod.budgetMonth,
      accountId: account.id!,
    );
    final prevBudgetAmount =
        prevBudget?.amount ??
        account.defaultMonthlyBudget ??
        0;

    if (prevBudgetAmount <= 0) return false;

    final prevExpenses = prevTxs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final prevIncome = prevTxs
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final net = prevBudgetAmount - prevExpenses + prevIncome;

    if (net == 0) return false;

    final now = DateTime.now();
    // Atomic check-and-insert: prevents a second concurrent build from
    // inserting a duplicate before the first write is visible.
    return txRepo.insertCarryOverIfAbsent(
      tx: Transaction(
        uuid: _uuid.v4(),
        accountId: account.id!,
        amount: net.abs(),
        type: net > 0 ? TransactionType.income : TransactionType.expense,
        description: 'Budget carry-over',
        categoryUuid: kCarryOverCategoryUuid,
        transactionDate: period.start,
        createdAt: now,
        updatedAt: now,
        source: 'carryover',
      ),
      accountId: account.id!,
      periodStart: period.start,
      periodEnd: period.end,
    );
  }
}
