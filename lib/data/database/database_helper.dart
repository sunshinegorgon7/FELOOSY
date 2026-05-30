import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../app/app_flavor.dart';
import '../../core/constants/brand_categories.dart';
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
      version: 21,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        currency_code TEXT NOT NULL,
        currency_symbol TEXT NOT NULL,
        currency_symbol_leading INTEGER NOT NULL DEFAULT 0,
        default_monthly_budget REAL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        month_start_day INTEGER,
        carry_over_enabled INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        amount REAL NOT NULL,
        currency_code TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(account_id, year, month)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        account_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        category_uuid TEXT NOT NULL,
        transaction_date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        source TEXT NOT NULL DEFAULT 'manual'
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
        created_at INTEGER NOT NULL,
        transaction_type TEXT,
        logo_url TEXT,
        currency_hint TEXT
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
        favorite_account_id INTEGER,
        google_backup_enabled INTEGER NOT NULL DEFAULT 0,
        default_monthly_budget REAL NOT NULL DEFAULT 0,
        last_backup_at INTEGER,
        updated_at INTEGER NOT NULL,
        tutorial_completed INTEGER NOT NULL DEFAULT 0,
        privacy_accepted_at INTEGER
      )
    ''');

    await db.execute(
      '''
      CREATE TABLE ai_analysis_cache (
        hash TEXT PRIMARY KEY,
        group_label TEXT NOT NULL,
        summary TEXT NOT NULL,
        insights TEXT NOT NULL,
        advice TEXT NOT NULL,
        source TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_after INTEGER
      )
      ''',
    );

    await db.execute('''
      CREATE TABLE sms_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        keyword TEXT NOT NULL,
        description TEXT,
        category_uuid TEXT NOT NULL,
        transaction_type TEXT NOT NULL,
        account_id INTEGER NOT NULL DEFAULT 1,
        amount_regex TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_rules (
        uuid TEXT PRIMARY KEY,
        account_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        category_uuid TEXT NOT NULL,
        frequency TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        last_generated_date INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await _seed(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('[DB] onUpgrade: $oldVersion → $newVersion');
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
    if (oldVersion < 5) {
      for (final (index, (name, _, _, _)) in kDefaultCategoryData.indexed) {
        final stableUuid = kDefaultCategoryUuids[index];
        final rows = await db.query(
          'categories',
          columns: ['uuid'],
          where: 'name = ? AND is_custom = 0',
          whereArgs: [name],
        );
        if (rows.isNotEmpty) {
          final oldUuid = rows.first['uuid'] as String;
          if (oldUuid != stableUuid) {
            await db.rawUpdate(
              'UPDATE categories SET uuid = ? WHERE uuid = ?',
              [stableUuid, oldUuid],
            );
            await db.rawUpdate(
              'UPDATE transactions SET category_uuid = ? WHERE category_uuid = ?',
              [stableUuid, oldUuid],
            );
          }
        }
      }
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE accounts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          currency_code TEXT NOT NULL,
          currency_symbol TEXT NOT NULL,
          currency_symbol_leading INTEGER NOT NULL DEFAULT 0,
          default_monthly_budget REAL,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      final settingsRows = await db.query('app_settings', where: 'id = 1');
      final settings = settingsRows.first;
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('accounts', {
        'name': 'Main Account',
        'currency_code': settings['currency_code'] as String,
        'currency_symbol': settings['currency_symbol'] as String,
        'currency_symbol_leading': settings['currency_symbol_leading'] as int,
        'default_monthly_budget': settings['default_monthly_budget'] as num?,
        'is_favorite': 1,
        'created_at': now,
        'updated_at': now,
      });
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN account_id INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN account_id INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE app_settings ADD COLUMN favorite_account_id INTEGER',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_budgets_account_period ON budgets(account_id, year, month)',
      );
    }
    if (oldVersion < 8) {
      await db.execute(
        'ALTER TABLE accounts ADD COLUMN month_start_day INTEGER',
      );
    }
    if (oldVersion < 9) {
      await db.execute('DROP TABLE IF EXISTS pending_sync_ops');
    }
    if (oldVersion < 10) {
      await db.execute(
        'ALTER TABLE app_settings ADD COLUMN tutorial_completed INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 11) {
      // Migrate default category colors to the quieter Grove/Nimbus palette.
      // Values are Color(0xFFRRGGBB).toARGB32() integer equivalents.
      const colorUpdates = <(String, int)>[
        ('00000000-0000-0000-0000-000000000001', 0xFF6E8F68), // Groceries
        ('00000000-0000-0000-0000-000000000002', 0xFF8F7A4F), // Dining Out
        ('00000000-0000-0000-0000-000000000003', 0xFF8A6F5C), // Coffee
        ('00000000-0000-0000-0000-000000000004', 0xFF5F7F8A), // Transport
        ('00000000-0000-0000-0000-000000000005', 0xFF7B7462), // Fuel
        ('00000000-0000-0000-0000-000000000006', 0xFF9A8652), // Utilities
        ('00000000-0000-0000-0000-000000000007', 0xFF7C7796), // Rent / Housing
        ('00000000-0000-0000-0000-000000000008', 0xFF8A7078), // Healthcare
        ('00000000-0000-0000-0000-000000000009', 0xFF8B7589), // Pharmacy
        ('00000000-0000-0000-0000-000000000010', 0xFF8A765F), // Shopping
        ('00000000-0000-0000-0000-000000000011', 0xFF7F7299), // Entertainment
        ('00000000-0000-0000-0000-000000000012', 0xFF5F8A84), // Sports / Gym
        ('00000000-0000-0000-0000-000000000013', 0xFF67849A), // Travel
        ('00000000-0000-0000-0000-000000000014', 0xFF6B7E9A), // Salary
        ('00000000-0000-0000-0000-000000000015', 0xFF7A8064), // Cashback
        ('00000000-0000-0000-0000-000000000016', 0xFF6E8790), // Refund
      ];
      for (final (uuid, colorValue) in colorUpdates) {
        await db.rawUpdate(
          'UPDATE categories SET color_value = ? WHERE uuid = ? AND is_custom = 0',
          [colorValue, uuid],
        );
      }
    }
    if (oldVersion < 12) {
      await db.execute(
        'ALTER TABLE categories ADD COLUMN transaction_type TEXT',
      );
      // Tag all default expense categories
      const expenseUuids = [
        '00000000-0000-0000-0000-000000000001',
        '00000000-0000-0000-0000-000000000002',
        '00000000-0000-0000-0000-000000000003',
        '00000000-0000-0000-0000-000000000004',
        '00000000-0000-0000-0000-000000000005',
        '00000000-0000-0000-0000-000000000006',
        '00000000-0000-0000-0000-000000000007',
        '00000000-0000-0000-0000-000000000008',
        '00000000-0000-0000-0000-000000000009',
        '00000000-0000-0000-0000-000000000010',
        '00000000-0000-0000-0000-000000000011',
        '00000000-0000-0000-0000-000000000012',
        '00000000-0000-0000-0000-000000000013',
      ];
      const incomeUuids = [
        '00000000-0000-0000-0000-000000000014',
        '00000000-0000-0000-0000-000000000015',
        '00000000-0000-0000-0000-000000000016',
      ];
      for (final uuid in expenseUuids) {
        await db.rawUpdate(
          "UPDATE categories SET transaction_type = 'expense' WHERE uuid = ? AND is_custom = 0",
          [uuid],
        );
      }
      for (final uuid in incomeUuids) {
        await db.rawUpdate(
          "UPDATE categories SET transaction_type = 'income' WHERE uuid = ? AND is_custom = 0",
          [uuid],
        );
      }
      // Update Healthcare icon to thermostat
      final (_, healthcareIcon, _, _) = kDefaultCategoryData[7];
      await db.rawUpdate(
        'UPDATE categories SET icon_code_point = ? WHERE uuid = ? AND is_custom = 0',
        [healthcareIcon.codePoint, '00000000-0000-0000-0000-000000000008'],
      );
      // Insert new income categories if not already present
      final now = DateTime.now().millisecondsSinceEpoch;
      final existingCount = (await db.rawQuery(
        'SELECT COUNT(*) as c FROM categories',
      )).first['c'] as int;
      final newCats = [
        kDefaultCategoryData[16], // Reimbursement
        kDefaultCategoryData[17], // Insurance
      ];
      for (final (i, (name, icon, color, type)) in newCats.indexed) {
        final uuid = kDefaultCategoryUuids[16 + i];
        final exists = (await db.query(
          'categories',
          where: 'uuid = ?',
          whereArgs: [uuid],
        )).isNotEmpty;
        if (!exists) {
          await db.insert('categories', {
            'uuid': uuid,
            'name': name,
            'color_value': color.toARGB32(),
            'icon_code_point': icon.codePoint,
            'icon_font_family': icon.fontFamily ?? 'MaterialIcons',
            'is_custom': 0,
            'is_active': 1,
            'sort_order': existingCount + i,
            'transaction_type': type,
            'created_at': now,
          });
        }
      }
    }
    if (oldVersion < 13) {
      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS ai_analysis_cache (
          hash TEXT PRIMARY KEY,
          group_label TEXT NOT NULL,
          summary TEXT NOT NULL,
          insights TEXT NOT NULL,
          advice TEXT NOT NULL,
          source TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          retry_after INTEGER
        )
        ''',
      );
    }
    if (oldVersion < 14) {
      // Migrate default category colors to the quieter Grove/Nimbus palette.
      // Values are Color(0xFFRRGGBB).toARGB32() integer equivalents.
      const colorUpdates = <(String, int)>[
        ('00000000-0000-0000-0000-000000000001', 0xFF6E8F68),
        ('00000000-0000-0000-0000-000000000002', 0xFF8F7A4F),
        ('00000000-0000-0000-0000-000000000003', 0xFF8A6F5C),
        ('00000000-0000-0000-0000-000000000004', 0xFF5F7F8A),
        ('00000000-0000-0000-0000-000000000005', 0xFF7B7462),
        ('00000000-0000-0000-0000-000000000006', 0xFF9A8652),
        ('00000000-0000-0000-0000-000000000007', 0xFF7C7796),
        ('00000000-0000-0000-0000-000000000008', 0xFF8A7078),
        ('00000000-0000-0000-0000-000000000009', 0xFF8B7589),
        ('00000000-0000-0000-0000-000000000010', 0xFF8A765F),
        ('00000000-0000-0000-0000-000000000011', 0xFF7F7299),
        ('00000000-0000-0000-0000-000000000012', 0xFF5F8A84),
        ('00000000-0000-0000-0000-000000000013', 0xFF67849A),
        ('00000000-0000-0000-0000-000000000014', 0xFF6B7E9A),
        ('00000000-0000-0000-0000-000000000015', 0xFF7A8064),
        ('00000000-0000-0000-0000-000000000016', 0xFF6E8790),
        ('00000000-0000-0000-0000-000000000017', 0xFF776D8F),
        ('00000000-0000-0000-0000-000000000018', 0xFF5F7C76),
      ];
      for (final (uuid, colorValue) in colorUpdates) {
        await db.rawUpdate(
          'UPDATE categories SET color_value = ? WHERE uuid = ? AND is_custom = 0',
          [colorValue, uuid],
        );
      }
    }
    if (oldVersion < 15) {
      await db.execute(
        "ALTER TABLE transactions ADD COLUMN source TEXT NOT NULL DEFAULT 'manual'",
      );
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sms_rules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          keyword TEXT NOT NULL,
          category_uuid TEXT NOT NULL,
          transaction_type TEXT NOT NULL,
          account_id INTEGER NOT NULL DEFAULT 1,
          amount_regex TEXT,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 16) {
      await db.execute(
        'ALTER TABLE sms_rules ADD COLUMN description TEXT',
      );
    }
    if (oldVersion < 17) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recurring_rules (
          uuid TEXT PRIMARY KEY,
          account_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          description TEXT NOT NULL,
          category_uuid TEXT NOT NULL,
          frequency TEXT NOT NULL,
          start_date INTEGER NOT NULL,
          last_generated_date INTEGER,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 18) {
      await db.execute(
        'ALTER TABLE accounts ADD COLUMN carry_over_enabled INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 19) {
      await db.execute(
        'ALTER TABLE app_settings ADD COLUMN privacy_accepted_at INTEGER',
      );
    }
    if (oldVersion < 20) {
      debugPrint('[DB] Running migration v20: adding brand categories');
      await db.execute('ALTER TABLE categories ADD COLUMN logo_url TEXT');
      await db.execute('ALTER TABLE categories ADD COLUMN currency_hint TEXT');
      final now = DateTime.now().millisecondsSinceEpoch;
      int inserted = 0;
      for (final cat in buildBrandCategories()) {
        final exists = (await db.query(
          'categories',
          columns: ['id'],
          where: 'uuid = ?',
          whereArgs: [cat.uuid],
        )).isNotEmpty;
        if (!exists) {
          await db.insert('categories', {...cat.toMap(), 'created_at': now});
          inserted++;
        }
      }
      debugPrint('[DB] v20 done: inserted $inserted brand categories');
    }
    if (oldVersion < 21) {
      // Clearbit Logo API shut down — migrate stored URLs to Google S2 favicons.
      // Old: https://logo.clearbit.com/{domain}
      // New: https://www.google.com/s2/favicons?sz=128&domain={domain}
      debugPrint('[DB] Running migration v21: rewriting logo URLs');
      await db.rawUpdate(
        "UPDATE categories "
        "SET logo_url = 'https://www.google.com/s2/favicons?sz=128&domain=' "
        "    || SUBSTR(logo_url, LENGTH('https://logo.clearbit.com/') + 1) "
        "WHERE logo_url LIKE 'https://logo.clearbit.com/%'",
      );
      final updated = await db.rawQuery(
        "SELECT COUNT(*) as c FROM categories WHERE logo_url LIKE '%google.com%'",
      );
      debugPrint('[DB] v21 done: ${updated.first['c']} logo URLs updated');
    }
  }

  Future<void> _seed(Database db) async {
    final defaults = AppSettings.defaults;
    await db.insert('app_settings', defaults.toMap());
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('accounts', {
      'name': 'Main Account',
      'currency_code': defaults.currencyCode,
      'currency_symbol': defaults.currencySymbol,
      'currency_symbol_leading': defaults.currencySymbolLeading ? 1 : 0,
      'default_monthly_budget':
          defaults.defaultMonthlyBudget > 0 ? defaults.defaultMonthlyBudget : null,
      'is_favorite': 1,
      'created_at': now,
      'updated_at': now,
    });

    final batch = db.batch();
    for (final cat in buildDefaultCategories()) {
      batch.insert('categories', cat.toMap());
    }
    for (final cat in buildBrandCategories()) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> resetAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('recurring_rules');
      await txn.delete('budgets');
      await txn.delete('categories');
      await txn.delete('app_settings');
      await txn.delete('accounts');
      final defaults = AppSettings.defaults;
      await txn.insert('app_settings', defaults.toMap());
      final now = DateTime.now().millisecondsSinceEpoch;
      await txn.insert('accounts', {
        'name': 'Main Account',
        'currency_code': defaults.currencyCode,
        'currency_symbol': defaults.currencySymbol,
        'currency_symbol_leading': defaults.currencySymbolLeading ? 1 : 0,
        'default_monthly_budget': defaults.defaultMonthlyBudget > 0
            ? defaults.defaultMonthlyBudget
            : null,
        'is_favorite': 1,
        'created_at': now,
        'updated_at': now,
      });
      for (final cat in buildDefaultCategories()) {
        await txn.insert('categories', cat.toMap());
      }
      for (final cat in buildBrandCategories()) {
        await txn.insert('categories', cat.toMap());
      }
    });
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}


