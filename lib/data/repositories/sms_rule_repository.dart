import '../database/database_helper.dart';
import '../models/sms_rule.dart';

class SmsRuleRepository {
  final DatabaseHelper _db;
  SmsRuleRepository(this._db);

  Future<List<SmsRule>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('sms_rules', orderBy: 'created_at ASC');
    return rows.map(SmsRule.fromMap).toList();
  }

  Future<SmsRule?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query('sms_rules', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return SmsRule.fromMap(rows.first);
  }

  Future<SmsRule> insert(SmsRule rule) async {
    final db = await _db.database;
    final id = await db.insert('sms_rules', rule.toMap());
    return SmsRule.fromMap({...rule.toMap(), 'id': id});
  }

  Future<void> update(SmsRule rule) async {
    final db = await _db.database;
    await db.update(
      'sms_rules',
      rule.toMap(),
      where: 'id = ?',
      whereArgs: [rule.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('sms_rules', where: 'id = ?', whereArgs: [id]);
  }
}
