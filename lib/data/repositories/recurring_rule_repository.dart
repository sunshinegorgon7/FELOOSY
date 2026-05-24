import '../database/database_helper.dart';
import '../models/recurring_rule.dart';

class RecurringRuleRepository {
  final DatabaseHelper _db;
  RecurringRuleRepository(this._db);

  Future<List<RecurringRule>> getAll() async {
    final db = await _db.database;
    final rows =
        await db.query('recurring_rules', orderBy: 'created_at ASC');
    return rows.map(RecurringRule.fromMap).toList();
  }

  Future<List<RecurringRule>> getActive() async {
    final db = await _db.database;
    final rows = await db.query('recurring_rules',
        where: 'is_active = 1', orderBy: 'created_at ASC');
    return rows.map(RecurringRule.fromMap).toList();
  }

  Future<RecurringRule?> getByUuid(String uuid) async {
    final db = await _db.database;
    final rows = await db
        .query('recurring_rules', where: 'uuid = ?', whereArgs: [uuid]);
    return rows.isEmpty ? null : RecurringRule.fromMap(rows.first);
  }

  Future<RecurringRule> insert(RecurringRule rule) async {
    final db = await _db.database;
    await db.insert('recurring_rules', rule.toMap());
    return rule;
  }

  Future<void> update(RecurringRule rule) async {
    final db = await _db.database;
    await db.update('recurring_rules', rule.toMap(),
        where: 'uuid = ?', whereArgs: [rule.uuid]);
  }

  Future<void> delete(String uuid) async {
    final db = await _db.database;
    await db.delete('recurring_rules', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<void> updateLastGeneratedDate(String uuid, DateTime date) async {
    final db = await _db.database;
    await db.update(
      'recurring_rules',
      {
        'last_generated_date': date.millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  /// Deletes all transactions whose source is 'recurring:{uuid}' AND whose
  /// transaction_date is strictly after [afterDate].
  Future<void> deleteFutureOccurrences(
      String ruleUuid, DateTime afterDate) async {
    final db = await _db.database;
    await db.delete(
      'transactions',
      where: "source = ? AND transaction_date > ?",
      whereArgs: [
        'recurring:$ruleUuid',
        afterDate.millisecondsSinceEpoch,
      ],
    );
  }

  /// Deletes all transactions whose source is 'recurring:{uuid}' AND whose
  /// transaction_date is >= [fromDate].
  Future<void> deleteFromOccurrences(
      String ruleUuid, DateTime fromDate) async {
    final db = await _db.database;
    await db.delete(
      'transactions',
      where: "source = ? AND transaction_date >= ?",
      whereArgs: [
        'recurring:$ruleUuid',
        fromDate.millisecondsSinceEpoch,
      ],
    );
  }
}
