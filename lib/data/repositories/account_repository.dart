import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/account.dart';

class AccountRepository {
  final DatabaseHelper _db;
  AccountRepository(this._db);

  Future<List<Account>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('accounts', orderBy: 'created_at ASC');
    return rows.map(Account.fromMap).toList();
  }

  Future<Account> create(Account account) async {
    final db = await _db.database;
    final id = await db.insert('accounts', account.toMap());
    return Account(
      id: id,
      name: account.name,
      currencyCode: account.currencyCode,
      currencySymbol: account.currencySymbol,
      currencySymbolLeading: account.currencySymbolLeading,
      defaultMonthlyBudget: account.defaultMonthlyBudget,
      isFavorite: account.isFavorite,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  Future<void> save(Account account) async {
    final db = await _db.database;
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int accountId) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('transactions',
          where: 'account_id = ?', whereArgs: [accountId]);
      await txn.delete('budgets', where: 'account_id = ?', whereArgs: [accountId]);
      await txn.delete('accounts', where: 'id = ?', whereArgs: [accountId]);
    });
  }

  Future<void> setFavorite(int accountId) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update('accounts', {'is_favorite': 0});
      await txn.update(
        'accounts',
        {'is_favorite': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [accountId],
      );
    });
  }
}
