import '../database/database_helper.dart';
import '../models/transaction.dart' as model;

class TransactionRepository {
  final DatabaseHelper _db;
  TransactionRepository(this._db);

  Future<List<model.Transaction>> getForPeriod(
      DateTime start, DateTime end) async {
    final db = await _db.database;
    final rows = await db.query(
      'transactions',
      where: 'transaction_date >= ? AND transaction_date <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
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

  Future<List<model.Transaction>> getAll() async {
    final db = await _db.database;
    final rows =
        await db.query('transactions', orderBy: 'transaction_date DESC');
    return rows.map(model.Transaction.fromMap).toList();
  }
}
