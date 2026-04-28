import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';

class BudgetRepository {
  final DatabaseHelper _db;
  BudgetRepository(this._db);

  Future<Budget?> getForPeriod(int year, int month, {required int accountId}) async {
    final db = await _db.database;
    final rows = await db.query(
      'budgets',
      where: 'year = ? AND month = ? AND account_id = ?',
      whereArgs: [year, month, accountId],
    );
    return rows.isEmpty ? null : Budget.fromMap(rows.first);
  }

  Future<List<Budget>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('budgets', orderBy: 'year DESC, month DESC');
    return rows.map(Budget.fromMap).toList();
  }

  Future<Budget> upsert(Budget budget) async {
    final db = await _db.database;
    final id = await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return Budget(
      id: id,
      accountId: budget.accountId,
      year: budget.year,
      month: budget.month,
      amount: budget.amount,
      currencyCode: budget.currencyCode,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  Future<void> delete(int year, int month) async {
    final db = await _db.database;
    await db.delete(
      'budgets',
      where: 'year = ? AND month = ? AND account_id = ?',
      whereArgs: [year, month, budget.accountId],
    );
  }
}
