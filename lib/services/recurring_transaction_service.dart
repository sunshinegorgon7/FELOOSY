import 'package:flutter/material.dart' show DateUtils;
import 'package:uuid/uuid.dart';
import '../data/models/recurring_rule.dart';
import '../data/models/transaction.dart';
import '../data/repositories/recurring_rule_repository.dart';
import '../data/repositories/transaction_repository.dart';

class RecurringTransactionService {
  static const _uuid = Uuid();

  static Future<void> generatePending({
    required TransactionRepository txRepo,
    required RecurringRuleRepository ruleRepo,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final rules = await ruleRepo.getActive();
    for (final rule in rules) {
      await _generateForRule(rule, today, txRepo, ruleRepo);
    }
  }

  static Future<void> _generateForRule(
    RecurringRule rule,
    DateTime today,
    TransactionRepository txRepo,
    RecurringRuleRepository ruleRepo,
  ) async {
    // Seed cursor just before startDate when no occurrences have been generated,
    // so the first call to _nextOccurrenceAfter produces startDate itself.
    DateTime cursor = rule.lastGeneratedDate != null
        ? DateUtils.dateOnly(rule.lastGeneratedDate!)
        : DateUtils.dateOnly(rule.startDate)
            .subtract(const Duration(days: 1));

    DateTime? lastGenerated;

    while (true) {
      final next =
          _nextOccurrenceAfter(cursor, rule.frequency, rule.startDate);
      if (next.isAfter(today)) break;

      final now = DateTime.now();
      await txRepo.insert(
        Transaction(
          uuid: _uuid.v4(),
          accountId: rule.accountId,
          amount: rule.amount,
          type: rule.type == 'income'
              ? TransactionType.income
              : TransactionType.expense,
          description: rule.description,
          categoryUuid: rule.categoryUuid,
          transactionDate: next,
          createdAt: now,
          updatedAt: now,
          source: 'recurring:${rule.uuid}',
        ),
      );
      cursor = next;
      lastGenerated = next;
    }

    if (lastGenerated != null) {
      await ruleRepo.updateLastGeneratedDate(rule.uuid, lastGenerated);
    }
  }

  /// Returns the next occurrence date strictly after [cursor], anchored to
  /// [startDate]'s day-of-month for monthly/annual frequencies.
  static DateTime _nextOccurrenceAfter(
    DateTime cursor,
    RecurringFrequency frequency,
    DateTime startDate,
  ) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return DateUtils.dateOnly(
            cursor.add(const Duration(days: 1)));

      case RecurringFrequency.weekly:
        return DateUtils.dateOnly(
            cursor.add(const Duration(days: 7)));

      case RecurringFrequency.monthly:
        // Advance month by month from startDate until we pass cursor.
        DateTime candidate = DateUtils.dateOnly(startDate);
        while (!candidate.isAfter(cursor)) {
          candidate = _clampToMonth(
              candidate.year, candidate.month + 1, startDate.day);
        }
        return candidate;

      case RecurringFrequency.annually:
        DateTime candidate = DateUtils.dateOnly(startDate);
        while (!candidate.isAfter(cursor)) {
          candidate = _clampToMonth(
              candidate.year + 1, startDate.month, startDate.day);
        }
        return candidate;
    }
  }

  /// Returns a date clamped to the last day of the given month, so that
  /// day=31 in a 28-day month becomes day=28 rather than overflowing.
  static DateTime _clampToMonth(int year, int month, int day) {
    // Normalise month overflow (e.g. month=13 → year+1, month=1).
    final normalised = DateTime(year, month, 1);
    final lastDay = DateTime(normalised.year, normalised.month + 1, 0).day;
    return DateTime(
        normalised.year, normalised.month, day.clamp(1, lastDay));
  }
}
