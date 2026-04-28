import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseHelper _db;
  CategoryRepository(this._db);

  Future<List<Category>> getAll({bool activeOnly = true}) async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'sort_order ASC',
    );
    return rows.map(Category.fromMap).toList();
  }

  Future<Category?> getByUuid(String uuid) async {
    final db = await _db.database;
    final rows =
        await db.query('categories', where: 'uuid = ?', whereArgs: [uuid]);
    return rows.isEmpty ? null : Category.fromMap(rows.first);
  }

  Future<void> insert(Category category) async {
    final db = await _db.database;
    await db.insert('categories', category.toMap());
  }

  Future<void> update(Category category) async {
    final db = await _db.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'uuid = ?',
      whereArgs: [category.uuid],
    );
  }

  Future<void> delete(String uuid) async {
    final db = await _db.database;
    await db.delete('categories', where: 'uuid = ?', whereArgs: [uuid]);
  }
}
