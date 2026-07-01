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
  /// Carry-over tracks a running balance, not a period-to-period delta: it is
  /// the previous period's own carry-over (if any) plus that period's own
  /// budget-vs-actual. A deficit therefore persists across periods until
  /// spending actually catches up, instead of resetting every period.
  ///   running balance > 0 → income transaction (surplus rolled forward)
  ///   running balance < 0 → expense transaction (deficit rolled forward)
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
    final allPrevTxs = await txRepo.getForPeriod(
      prevPeriod.start,
      prevPeriod.end,
      accountId: account.id!,
    );

    // The running balance the previous period itself carried in. Excluded
    // from prevExpenses/prevIncome below (so it isn't double-counted as a
    // regular transaction) but re-added as a level so a deficit/surplus
    // persists across periods instead of resetting to that period's own
    // delta alone.
    final prevCarryOverIncome = allPrevTxs
        .where((t) => t.isCarryOver && t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final prevCarryOverExpense = allPrevTxs
        .where((t) => t.isCarryOver && t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final prevCarryOverNet = prevCarryOverIncome - prevCarryOverExpense;

    final prevTxs = allPrevTxs.where((t) => !t.isCarryOver).toList();

    // Nothing to carry: no new activity in the previous period AND no
    // inherited balance from before that. A nonzero inherited balance must
    // still roll forward even through a period with zero new transactions.
    if (prevTxs.isEmpty && prevCarryOverNet == 0) return false;

    final prevBudget = await budgetRepo.getForPeriod(
      prevPeriod.budgetYear,
      prevPeriod.budgetMonth,
      accountId: account.id!,
    );
    final prevBudgetAmount =
        prevBudget?.amount ??
        account.defaultMonthlyBudget ??
        0;

    if (prevBudgetAmount <= 0 && prevCarryOverNet == 0) return false;

    final prevExpenses = prevTxs
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final prevIncome = prevTxs
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final net = prevCarryOverNet + prevBudgetAmount - prevExpenses + prevIncome;

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
