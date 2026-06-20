import '../database/database_helper.dart';
import '../models/sms_rule.dart';

class SmsRuleRepository {
  final DatabaseHelper _db;
  SmsRuleRepository(this._db);

  Future<List<SmsRule>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('sms_rules', orderBy: 'created_at ASC');
    final rules = <SmsRule>[];
    for (final row in rows) {
      final ruleId = row['id'] as int;
      final accountRows = await db.query(
        'sms_rule_accounts',
        columns: ['account_id'],
        where: 'sms_rule_id = ?',
        whereArgs: [ruleId],
      );
      final accountIds = accountRows.map((r) => r['account_id'] as int).toList();
      rules.add(SmsRule.fromMap(row, accountIds: accountIds));
    }
    return rules;
  }

  Future<SmsRule?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query('sms_rules', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final accountRows = await db.query(
      'sms_rule_accounts',
      columns: ['account_id'],
      where: 'sms_rule_id = ?',
      whereArgs: [id],
    );
    final accountIds = accountRows.map((r) => r['account_id'] as int).toList();
    return SmsRule.fromMap(rows.first, accountIds: accountIds);
  }

  Future<SmsRule> insert(SmsRule rule) async {
    final db = await _db.database;
    return db.transaction((txn) async {
      final id = await txn.insert('sms_rules', rule.toMap());
      for (final accountId in rule.accountIds) {
        await txn.insert('sms_rule_accounts', {
          'sms_rule_id': id,
          'account_id': accountId,
        });
      }
      return SmsRule.fromMap(
        {...rule.toMap(), 'id': id},
        accountIds: rule.accountIds,
      );
    });
  }

  Future<void> update(SmsRule rule) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'sms_rules',
        rule.toMap(),
        where: 'id = ?',
        whereArgs: [rule.id],
      );
      await txn.delete(
        'sms_rule_accounts',
        where: 'sms_rule_id = ?',
        whereArgs: [rule.id],
      );
      for (final accountId in rule.accountIds) {
        await txn.insert('sms_rule_accounts', {
          'sms_rule_id': rule.id,
          'account_id': accountId,
        });
      }
    });
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('sms_rule_accounts', where: 'sms_rule_id = ?', whereArgs: [id]);
      await txn.delete('sms_rules', where: 'id = ?', whereArgs: [id]);
    });
  }
}
