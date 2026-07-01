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
        WHERE LOWER(description) LIKE LOWER(?) AND source != 'carryover'
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

  /// Atomically ensures the carry-over transaction for [accountId] within
  /// [[periodStart], [periodEnd]] matches [tx]: inserts if absent, updates
  /// the existing row in place if its amount/type has drifted from a
  /// fresher calculation (e.g. after a formula fix or an edit to a past
  /// period's transactions), and deletes it if [tx].amount is now zero.
  /// Using a DB transaction prevents the race condition where two concurrent
  /// provider builds both pass an in-memory check before either write commits.
  /// Returns true when the DB was actually changed.
  Future<bool> syncCarryOver({
    required model.Transaction tx,
    required int accountId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final db = await _db.database;
    bool changed = false;
    await db.transaction((txn) async {
      final existingRows = await txn.query(
        'transactions',
        where:
            "account_id = ? AND source = 'carryover' "
            'AND transaction_date >= ? AND transaction_date <= ?',
        whereArgs: [
          accountId,
          periodStart.millisecondsSinceEpoch,
          periodEnd.millisecondsSinceEpoch,
        ],
        limit: 1,
      );

      if (tx.amount == 0) {
        if (existingRows.isNotEmpty) {
          await txn.delete('transactions',
              where: 'id = ?', whereArgs: [existingRows.first['id']]);
          changed = true;
        }
        return;
      }

      if (existingRows.isEmpty) {
        await txn.insert('transactions', tx.toMap());
        changed = true;
        return;
      }

      final existing = model.Transaction.fromMap(existingRows.first);
      final upToDate =
          existing.amount == tx.amount && existing.type == tx.type;
      if (!upToDate) {
        await txn.update(
          'transactions',
          {
            'amount': tx.amount,
            'type': tx.type.name,
            'updated_at': tx.updatedAt.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [existing.id],
        );
        changed = true;
      }
    });
    return changed;
  }

  Future<int> deleteCarryOversForAccount(int accountId) async {
    final db = await _db.database;
    return db.delete(
      'transactions',
      where: "account_id = ? AND source = 'carryover'",
      whereArgs: [accountId],
    );
  }

  Future<List<model.Transaction>> getByRecurringRule(String ruleUuid) async {
    final db = await _db.database;
    final rows = await db.query(
      'transactions',
      where: "source = ?",
      whereArgs: ['recurring:$ruleUuid'],
    );
    return rows.map(model.Transaction.fromMap).toList();
  }

  Future<int> count() async {
    final db = await _db.database;
    final rows = await db.rawQuery('SELECT COUNT(*) as c FROM transactions');
    return rows.first['c'] as int? ?? 0;
  }

  Future<int> countForMonth(int year, int month, int accountId) async {
    final db = await _db.database;
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as c FROM transactions '
      'WHERE account_id = ? AND transaction_date >= ? AND transaction_date < ?',
      [accountId, start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return rows.first['c'] as int? ?? 0;
  }

  /// Returns category UUIDs ordered by transaction frequency (most used first).
  Future<List<String>> getMostUsedCategoryUuids({int limit = 4, int? accountId}) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT category_uuid, COUNT(*) as cnt
      FROM transactions
      WHERE source != 'carryover'${accountId == null ? '' : ' AND account_id = ?'}
      GROUP BY category_uuid
      ORDER BY cnt DESC
      LIMIT ?
      ''',
      accountId == null ? [limit] : [accountId, limit],
    );
    return rows.map((r) => r['category_uuid'] as String).toList();
  }
}
