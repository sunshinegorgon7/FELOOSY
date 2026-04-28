import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;
import 'package:sqflite/sqflite.dart' hide Transaction;

import '../../data/database/database_helper.dart';

class ImportSummary {
  final int transactions;
  final int budgets;
  final int categories;
  const ImportSummary({
    required this.transactions,
    required this.budgets,
    required this.categories,
  });
}

class LocalExportService {
  final DatabaseHelper _db;
  const LocalExportService(this._db);

  // ── Export ───────────────────────────────────────────────────────────────

  Future<void> export() async {
    final db = await _db.database;
    final payload = <String, dynamic>{
      'feloosy_backup': true,
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'transactions': await db.query('transactions'),
      'budgets': await db.query('budgets'),
      'categories': await db.query('categories'),
      'settings': (await db.query('app_settings')).firstOrNull,
    };

    final json = const JsonEncoder.withIndent('  ').convert(payload);
    final dir = await getTemporaryDirectory();
    final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File(p.join(dir.path, 'feloosy_$ts.json'));
    await file.writeAsString(json, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'FELOOSY backup',
      ),
    );
  }

  // ── Import ───────────────────────────────────────────────────────────────

  /// Parses a backup file and returns counts without writing to the DB.
  Future<ImportSummary> preview(String filePath) async {
    final data = await _parse(filePath);
    return ImportSummary(
      transactions: (data['transactions'] as List).length,
      budgets: (data['budgets'] as List).length,
      categories: (data['categories'] as List? ?? []).length,
    );
  }

  /// Commits the import, replacing all local transactions, budgets,
  /// categories, and settings with the data from the backup file.
  Future<ImportSummary> commit(String filePath) async {
    final data = await _parse(filePath);
    final db = await _db.database;

    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
      if (data['categories'] != null) await txn.delete('categories');

      for (final row in data['transactions'] as List) {
        await txn.insert(
          'transactions',
          Map<String, dynamic>.from(row as Map),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final row in data['budgets'] as List) {
        await txn.insert(
          'budgets',
          Map<String, dynamic>.from(row as Map),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      if (data['categories'] != null) {
        for (final row in data['categories'] as List) {
          await txn.insert(
            'categories',
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      if (data['settings'] != null) {
        await txn.update(
          'app_settings',
          Map<String, dynamic>.from(data['settings'] as Map),
          where: 'id = ?',
          whereArgs: [1],
        );
      }
    });

    return ImportSummary(
      transactions: (data['transactions'] as List).length,
      budgets: (data['budgets'] as List).length,
      categories: (data['categories'] as List? ?? []).length,
    );
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _parse(String filePath) async {
    final raw = await File(filePath).readAsString();
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('File is not valid JSON.');
    }
    if (data['feloosy_backup'] != true) {
      throw const FormatException('Not a FELOOSY backup file.');
    }
    final version = data['version'] as int? ?? 0;
    if (version > 1) {
      throw FormatException('Backup version $version is not supported by this app version.');
    }
    return data;
  }
}
