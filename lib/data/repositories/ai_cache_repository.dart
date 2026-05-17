import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../domain/services/ai_analysis_service.dart';

class AiCacheEntry {
  final String hash;
  final String groupLabel;
  final AiAnalysisSuccess result;
  final String source; // 'ai' or 'local'
  final DateTime createdAt;
  final DateTime? retryAfter;

  const AiCacheEntry({
    required this.hash,
    required this.groupLabel,
    required this.result,
    required this.source,
    required this.createdAt,
    this.retryAfter,
  });
}

class AiCacheRepository {
  final DatabaseHelper _db;
  const AiCacheRepository(this._db);

  Future<AiCacheEntry?> get(String hash) async {
    final db = await _db.database;
    final rows = await db.query(
      'ai_analysis_cache',
      where: 'hash = ?',
      whereArgs: [hash],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final insights = (jsonDecode(row['insights'] as String) as List)
        .map((e) => e.toString())
        .toList();
    return AiCacheEntry(
      hash: row['hash'] as String,
      groupLabel: row['group_label'] as String,
      result: AiAnalysisSuccess(
        summary: row['summary'] as String,
        insights: insights,
        advice: row['advice'] as String,
      ),
      source: row['source'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      retryAfter: row['retry_after'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['retry_after'] as int)
          : null,
    );
  }

  Future<void> put({
    required String hash,
    required String groupLabel,
    required AiAnalysisSuccess result,
    required String source,
    DateTime? retryAfter,
  }) async {
    final db = await _db.database;
    await db.insert(
      'ai_analysis_cache',
      {
        'hash': hash,
        'group_label': groupLabel,
        'summary': result.summary,
        'insights': jsonEncode(result.insights),
        'advice': result.advice,
        'source': source,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'retry_after': retryAfter?.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> needsRetry(String hash) async {
    final db = await _db.database;
    final rows = await db.query(
      'ai_analysis_cache',
      columns: ['source', 'retry_after'],
      where: 'hash = ?',
      whereArgs: [hash],
    );
    if (rows.isEmpty) return false;
    final row = rows.first;
    final isLocal = row['source'] == 'local';
    final retryAfter = row['retry_after'] as int?;
    if (!isLocal) return false;
    if (retryAfter == null) return false;
    return DateTime.now().millisecondsSinceEpoch >= retryAfter;
  }

  Future<void> delete(String hash) async {
    final db = await _db.database;
    await db.delete('ai_analysis_cache', where: 'hash = ?', whereArgs: [hash]);
  }
}
