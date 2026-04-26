import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../app/app_flavor.dart';
import '../../core/constants/default_categories.dart';
import '../models/app_settings.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  Database? _db;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docDir.path, AppFlavor.databaseName);
    return openDatabase(
      dbPath,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        amount REAL NOT NULL,
        currency_code TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(year, month)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        category_uuid TEXT NOT NULL,
        transaction_date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_date ON transactions(transaction_date)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_category ON transactions(category_uuid)
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        icon_code_point INTEGER NOT NULL,
        icon_font_family TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        sort_order INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY,
        currency_code TEXT NOT NULL DEFAULT 'AED',
        currency_symbol TEXT NOT NULL DEFAULT 'AED',
        currency_symbol_leading INTEGER NOT NULL DEFAULT 0,
        month_start_day INTEGER NOT NULL DEFAULT 1,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        color_theme TEXT NOT NULL DEFAULT 'green2',
        google_backup_enabled INTEGER NOT NULL DEFAULT 0,
        last_backup_at INTEGER,
        updated_at INTEGER NOT NULL
      )
    ''');

    await _seed(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE app_settings ADD COLUMN default_monthly_budget REAL NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "UPDATE categories SET is_active = 0 WHERE name = 'Other' AND is_custom = 0",
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE app_settings ADD COLUMN color_theme TEXT NOT NULL DEFAULT 'green2'",
      );
    }
  }

  Future<void> _seed(Database db) async {
    // Default settings
    await db.insert('app_settings', AppSettings.defaults.toMap());

    // Default categories
    final batch = db.batch();
    for (final cat in buildDefaultCategories()) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> resetAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
      await txn.delete('categories');
      await txn.delete('app_settings');
      await txn.insert('app_settings', AppSettings.defaults.toMap());
      for (final cat in buildDefaultCategories()) {
        await txn.insert('categories', cat.toMap());
      }
    });
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
