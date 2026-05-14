import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../data/database/database_helper.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_period_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transactions_provider.dart';

// Watched in app.dart and settings_screen.dart to reflect snapshot state.
final snapshotModeProvider = FutureProvider<bool>((ref) async {
  return SeedSnapshotService.isSnapshotActive();
});

class SeedSnapshotService {
  static const _backupFile = 'feloosy_dev_snapshot_backup.json';
  static const _markerFile = 'feloosy_dev_snapshot_active';

  static Future<String> _supportDir() async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  static Future<bool> isSnapshotActive() async {
    final dir = await _supportDir();
    return File('$dir/$_markerFile').exists();
  }

  // Backs up current accounts/transactions/budgets, then seeds 3 wallets with
  // 90 days of transactions. All edits made while in snapshot mode are real but
  // discarded when exitSnapshot() is called.
  static Future<void> enterSnapshot(WidgetRef ref) async {
    final db = await DatabaseHelper.instance.database;

    // 1. Serialise current data tables to a local JSON file.
    final accounts = await db.query('accounts');
    final transactions = await db.query('transactions');
    final budgets = await db.query('budgets');

    final dir = await _supportDir();
    await File('$dir/$_backupFile').writeAsString(jsonEncode({
      'accounts': accounts,
      'transactions': transactions,
      'budgets': budgets,
    }));

    // 2. Clear data tables (categories and app_settings are left untouched).
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
      await txn.delete('accounts');
    });

    // 3. Seed fresh sample data.
    await _seedData(db);

    // 4. Write marker so the banner survives app restarts.
    await File('$dir/$_markerFile').writeAsString('1');

    // 5. Reset navigation state and rebuild all data providers.
    ref.read(selectedHomeAccountIdProvider.notifier).select(null);
    ref.read(selectedPeriodOffsetProvider.notifier).reset();
    _invalidateAll(ref);
  }

  // Restores the pre-snapshot data and removes all snapshot artefacts.
  static Future<void> exitSnapshot(WidgetRef ref) async {
    final dir = await _supportDir();
    final backup = File('$dir/$_backupFile');
    if (!await backup.exists()) return;

    final db = await DatabaseHelper.instance.database;
    final data = jsonDecode(await backup.readAsString()) as Map<String, dynamic>;

    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
      await txn.delete('accounts');

      for (final row in (data['accounts'] as List)) {
        await txn.insert('accounts', Map<String, Object?>.from(row as Map));
      }
      for (final row in (data['budgets'] as List)) {
        await txn.insert('budgets', Map<String, Object?>.from(row as Map));
      }
      for (final row in (data['transactions'] as List)) {
        await txn.insert('transactions', Map<String, Object?>.from(row as Map));
      }
    });

    await File('$dir/$_markerFile').delete();
    await backup.delete();

    ref.read(selectedHomeAccountIdProvider.notifier).select(null);
    ref.read(selectedPeriodOffsetProvider.notifier).reset();
    _invalidateAll(ref);
  }

  static void _invalidateAll(WidgetRef ref) {
    ref.invalidate(accountsProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(transactionPeriodOffsetsProvider);
    ref.invalidate(currentBudgetProvider);
    ref.invalidate(snapshotModeProvider);
  }

  // ---------------------------------------------------------------------------
  // Seeding
  // ---------------------------------------------------------------------------

  static Future<void> _seedData(Database db) async {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;

    // 3 wallets with different currencies and monthly budgets.
    final aedId = await db.insert('accounts', {
      'name': 'Personal',
      'currency_code': 'AED',
      'currency_symbol': 'AED',
      'currency_symbol_leading': 0,
      'default_monthly_budget': 15000.0,
      'is_favorite': 1,
      'month_start_day': null,
      'created_at': nowMs,
      'updated_at': nowMs,
    });
    final usdId = await db.insert('accounts', {
      'name': 'Work',
      'currency_code': 'USD',
      'currency_symbol': '\$',
      'currency_symbol_leading': 1,
      'default_monthly_budget': 5000.0,
      'is_favorite': 0,
      'month_start_day': null,
      'created_at': nowMs,
      'updated_at': nowMs,
    });
    final gbpId = await db.insert('accounts', {
      'name': 'Travel',
      'currency_code': 'GBP',
      'currency_symbol': '£',
      'currency_symbol_leading': 1,
      'default_monthly_budget': 2000.0,
      'is_favorite': 0,
      'month_start_day': null,
      'created_at': nowMs,
      'updated_at': nowMs,
    });

    // (accountId, currencyScale relative to AED, monthly salary)
    final wallets = [
      (aedId, 1.00, 15000.0),
      (usdId, 0.27, 5000.0),
      (gbpId, 0.21, 2000.0),
    ];

    const uuid = Uuid();
    final batch = db.batch();

    for (final (accountId, scale, salaryAmount) in wallets) {
      for (var d = 89; d >= 0; d--) {
        final day = now.subtract(Duration(days: d));
        final isFirstOfMonth = day.day == 1;
        // Fixed seed per (day, account) gives consistent data across runs.
        final rng = Random(42 + d * 3 + accountId * 97);

        // 4 expense transactions spread through the day.
        for (var t = 0; t < 4; t++) {
          final catUuid = _pickExpenseCat(rng);
          final amount = _expenseAmount(catUuid, scale, rng);
          final txTime = DateTime(day.year, day.month, day.day, 8 + t * 2 + rng.nextInt(2));
          batch.insert('transactions', {
            'uuid': uuid.v4(),
            'account_id': accountId,
            'amount': amount,
            'type': 'expense',
            'description': _expenseDesc(catUuid, rng),
            'category_uuid': catUuid,
            'transaction_date': txTime.millisecondsSinceEpoch,
            'created_at': nowMs,
            'updated_at': nowMs,
          });
        }

        // 1 income transaction: salary on the 1st, small income otherwise.
        if (isFirstOfMonth) {
          batch.insert('transactions', {
            'uuid': uuid.v4(),
            'account_id': accountId,
            'amount': salaryAmount,
            'type': 'income',
            'description': 'Monthly salary',
            'category_uuid': '00000000-0000-0000-0000-000000000014',
            'transaction_date': DateTime(day.year, day.month, day.day, 9).millisecondsSinceEpoch,
            'created_at': nowMs,
            'updated_at': nowMs,
          });
        } else {
          final (incUuid, incMin, incMax, incDesc) = _smallIncomeCats[rng.nextInt(_smallIncomeCats.length)];
          final incAmount = _scaled(incMin, incMax, scale, rng);
          batch.insert('transactions', {
            'uuid': uuid.v4(),
            'account_id': accountId,
            'amount': incAmount,
            'type': 'income',
            'description': incDesc,
            'category_uuid': incUuid,
            'transaction_date': DateTime(day.year, day.month, day.day, 18).millisecondsSinceEpoch,
            'created_at': nowMs,
            'updated_at': nowMs,
          });
        }
      }
    }

    await batch.commit(noResult: true);
  }

  // Expense categories: (uuid, minAED, maxAED) with integer weights (sum = 100).
  static const _expenseCats = [
    ('00000000-0000-0000-0000-000000000003', 8.0, 25.0),    // Coffee      — 25
    ('00000000-0000-0000-0000-000000000001', 30.0, 180.0),  // Groceries   — 20
    ('00000000-0000-0000-0000-000000000002', 25.0, 120.0),  // Dining Out  — 18
    ('00000000-0000-0000-0000-000000000004', 10.0, 50.0),   // Transport   — 12
    ('00000000-0000-0000-0000-000000000010', 80.0, 500.0),  // Shopping    — 8
    ('00000000-0000-0000-0000-000000000011', 30.0, 200.0),  // Entertainment— 6
    ('00000000-0000-0000-0000-000000000005', 80.0, 200.0),  // Fuel        — 4
    ('00000000-0000-0000-0000-000000000012', 50.0, 200.0),  // Sports/Gym  — 3
    ('00000000-0000-0000-0000-000000000008', 50.0, 300.0),  // Healthcare  — 2
    ('00000000-0000-0000-0000-000000000009', 20.0, 80.0),   // Pharmacy    — 2
  ];
  static const _catWeights = [25, 20, 18, 12, 8, 6, 4, 3, 2, 2]; // sum = 100

  static const _smallIncomeCats = [
    ('00000000-0000-0000-0000-000000000015', 5.0, 50.0, 'Cashback'),
    ('00000000-0000-0000-0000-000000000016', 20.0, 200.0, 'Refund'),
    ('00000000-0000-0000-0000-000000000017', 50.0, 300.0, 'Reimbursement'),
  ];

  static const _descriptions = {
    '00000000-0000-0000-0000-000000000001': ['Supermarket', 'Weekly groceries', 'Fresh produce', 'Household supplies', 'Carrefour run'],
    '00000000-0000-0000-0000-000000000002': ['Lunch out', 'Dinner with friends', 'Restaurant', 'Takeaway', 'Brunch'],
    '00000000-0000-0000-0000-000000000003': ['Morning coffee', 'Flat white', 'Iced latte', 'Cappuccino', 'Café stop'],
    '00000000-0000-0000-0000-000000000004': ['Metro card top-up', 'Taxi', 'Uber', 'Bus fare', 'Parking'],
    '00000000-0000-0000-0000-000000000005': ['Fuel', 'Gas station', 'Petrol top-up'],
    '00000000-0000-0000-0000-000000000008': ['Doctor visit', 'Medical checkup', 'Clinic'],
    '00000000-0000-0000-0000-000000000009': ['Pharmacy', 'Medicine', 'Vitamins'],
    '00000000-0000-0000-0000-000000000010': ['Online shopping', 'Clothing', 'Electronics', 'Mall'],
    '00000000-0000-0000-0000-000000000011': ['Cinema', 'Netflix', 'Concert ticket', 'Gaming', 'Streaming'],
    '00000000-0000-0000-0000-000000000012': ['Gym membership', 'Yoga class', 'Sports gear'],
  };

  static String _pickExpenseCat(Random rng) {
    var roll = rng.nextInt(100);
    for (var i = 0; i < _catWeights.length; i++) {
      roll -= _catWeights[i];
      if (roll < 0) return _expenseCats[i].$1;
    }
    return _expenseCats[0].$1;
  }

  static double _expenseAmount(String catUuid, double scale, Random rng) {
    for (final (u, mn, mx) in _expenseCats) {
      if (u == catUuid) return _scaled(mn, mx, scale, rng);
    }
    return _scaled(10.0, 30.0, scale, rng);
  }

  static double _scaled(double min, double max, double scale, Random rng) {
    final raw = (min + rng.nextDouble() * (max - min)) * scale;
    return (raw * 100).roundToDouble() / 100;
  }

  static String _expenseDesc(String catUuid, Random rng) {
    final list = _descriptions[catUuid] ?? ['Purchase'];
    return list[rng.nextInt(list.length)];
  }
}
