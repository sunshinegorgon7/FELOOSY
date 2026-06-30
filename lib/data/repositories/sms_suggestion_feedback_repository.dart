import '../database/database_helper.dart';

class SmsRejectedEntry {
  final String keyword;
  final DateTime dismissedAt;
  const SmsRejectedEntry({required this.keyword, required this.dismissedAt});
}

class SmsSuggestionFeedbackRepository {
  final DatabaseHelper _db;
  SmsSuggestionFeedbackRepository(this._db);

  Future<void> insertFeedback(String keyword, String action) async {
    final db = await _db.database;
    await db.insert('sms_suggestion_feedback', {
      'keyword': keyword.toLowerCase(),
      'action': action,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Set<String>> getRejectedKeywords() async {
    final db = await _db.database;
    final rows = await db.query(
      'sms_suggestion_feedback',
      columns: ['keyword'],
      where: "action = 'rejected'",
    );
    return rows.map((r) => r['keyword'] as String).toSet();
  }

  Future<List<SmsRejectedEntry>> getAllRejected() async {
    final db = await _db.database;
    final rows = await db.query(
      'sms_suggestion_feedback',
      where: "action = 'rejected'",
      orderBy: 'created_at DESC',
    );
    return rows
        .map((r) => SmsRejectedEntry(
              keyword: r['keyword'] as String,
              dismissedAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
            ))
        .toList();
  }

  Future<void> removeRejected(String keyword) async {
    final db = await _db.database;
    await db.delete(
      'sms_suggestion_feedback',
      where: "keyword = ? AND action = 'rejected'",
      whereArgs: [keyword.toLowerCase()],
    );
  }

  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('sms_suggestion_feedback');
  }
}
