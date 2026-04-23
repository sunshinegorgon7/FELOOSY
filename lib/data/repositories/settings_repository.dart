import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  final DatabaseHelper _db;
  SettingsRepository(this._db);

  Future<AppSettings> get() async {
    final db = await _db.database;
    final rows = await db.query('app_settings', where: 'id = 1');
    if (rows.isEmpty) {
      final defaults = AppSettings.defaults;
      await db.insert('app_settings', defaults.toMap());
      return defaults;
    }
    return AppSettings.fromMap(rows.first);
  }

  Future<void> save(AppSettings settings) async {
    final db = await _db.database;
    await db.insert(
      'app_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
