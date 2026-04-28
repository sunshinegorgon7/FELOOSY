import '../database/database_helper.dart';
import '../models/transaction.dart' as model;

class DescriptionSuggestion {
  final String description;
  final String categoryUuid;
  const DescriptionSuggestion(
      {required this.description, required this.categoryUuid});
}

class TransactionRepository {
  final DatabaseHelper _db;
  TransactionRepository(this._db);

  Future<List<model.Transaction>> getForPeriod(
      DateTime start, DateTime end, {int? accountId}) async {
    final db = await _db.database;
    final rows = await db.query(
      'transactions',
      where: accountId == null
          ? 'transaction_date >= ? AND transaction_date <= ?'
          : 'transaction_date >= ? AND transaction_date <= ? AND account_id = ?',
      whereArgs: accountId == null
          ? [
              start.millisecondsSinceEpoch,
              end.millisecondsSinceEpoch,
            ]
          : [
              start.millisecondsSinceEpoch,
              end.millisecondsSinceEpoch,
              accountId,
            ],
      orderBy: 'transaction_date DESC',
    );
    return rows.map(model.Transaction.fromMap).toList();
  }

  Future<model.Transaction?> getByUuid(String uuid) async {
    final db = await _db.database;
    final rows =
        await db.query('transactions', where: 'uuid = ?', whereArgs: [uuid]);
    return rows.isEmpty ? null : model.Transaction.fromMap(rows.first);
  }

  Future<model.Transaction> insert(model.Transaction tx) async {
    final db = await _db.database;
    final id = await db.insert('transactions', tx.toMap());
    return model.Transaction(
      id: id,
      uuid: tx.uuid,
      accountId: tx.accountId,
      amount: tx.amount,
      type: tx.type,
      description: tx.description,
      categoryUuid: tx.categoryUuid,
      transactionDate: tx.transactionDate,
      createdAt: tx.createdAt,
      updatedAt: tx.updatedAt,
    );
  }

  Future<void> save(model.Transaction tx) async {
    final db = await _db.database;
    await db.update(
      'transactions',
      tx.toMap(),
      where: 'uuid = ?',
      whereArgs: [tx.uuid],
    );
  }

  Future<void> delete(String uuid) async {
    final db = await _db.database;
    await db.delete('transactions', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<List<model.Transaction>> getAll({int? accountId}) async {
    final db = await _db.database;
    final rows = await db.query(
      'transactions',
      where: accountId == null ? null : 'account_id = ?',
      whereArgs: accountId == null ? null : [accountId],
      orderBy: 'transaction_date DESC',
    );
    return rows.map(model.Transaction.fromMap).toList();
  }

  /// Returns up to 8 distinct descriptions containing [query] (case-insensitive).
  ///
  /// Each suggestion is paired with the category from the latest transaction
  /// for that normalized description (ordered by `created_at DESC, id DESC`).
  Future<List<DescriptionSuggestion>> getDescriptionSuggestions(
      String query) async {
    if (query.trim().isEmpty) return [];
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      WITH ranked AS (
        SELECT
          id,
          description,
          category_uuid,
          created_at,
          LOWER(description) AS normalized_description,
          ROW_NUMBER() OVER (
            PARTITION BY LOWER(description)
            ORDER BY created_at DESC, id DESC
          ) AS row_num
        FROM transactions
        WHERE LOWER(description) LIKE LOWER(?)
      )
      SELECT description, category_uuid
      FROM ranked
      WHERE row_num = 1
      ORDER BY created_at DESC, id DESC
      LIMIT 8
      ''',
      ['%${query.trim()}%'],
    );
    return rows
        .map((r) => DescriptionSuggestion(
              description: r['description'] as String,
              categoryUuid: r['category_uuid'] as String,
            ))
        .toList();
  }

  /// Returns category UUIDs ordered by transaction frequency (most used first).
  Future<List<String>> getMostUsedCategoryUuids({int limit = 4, int? accountId}) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT category_uuid, COUNT(*) as cnt
      FROM transactions
      ${accountId == null ? '' : 'WHERE account_id = ?'}
      GROUP BY category_uuid
      ORDER BY cnt DESC
      LIMIT ?
      ''',
      accountId == null ? [limit] : [accountId, limit],
    );
    return rows.map((r) => r['category_uuid'] as String).toList();
  }
}
