import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

/// Records which SMS messages have already produced an auto-transaction, so the
/// two independent consumers — the foreground queue-replay and the headless
/// background engine — can never both create a transaction for the same message.
class SmsLedgerRepository {
  final DatabaseHelper _db;
  SmsLedgerRepository(this._db);

  /// Stable key for an SMS. Both processing paths only carry body + sender, so
  /// that is all we can hash.
  static String hashFor({required String sender, required String body}) {
    return sha256.convert(utf8.encode('$sender\n$body')).toString();
  }

  /// Atomically claims [hash] for processing. Returns true for the first caller
  /// and false for every subsequent one.
  ///
  /// `INSERT OR IGNORE` on the primary key is atomic across the separate SQLite
  /// connections used by the app isolate and the background-engine isolate
  /// (SQLite serialises writers with a file lock), so exactly one caller wins
  /// the race even when both check at the same instant.
  Future<bool> claim(String hash) async {
    final db = await _db.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.rawInsert(
      'INSERT OR IGNORE INTO processed_sms(hash, created_at) VALUES(?, ?)',
      [hash, now],
    );
    final changed =
        Sqflite.firstIntValue(await db.rawQuery('SELECT changes()')) ?? 0;

    // Keep the ledger bounded — 30 days is far longer than any redelivery window.
    await db.delete(
      'processed_sms',
      where: 'created_at < ?',
      whereArgs: [
        DateTime.now()
            .subtract(const Duration(days: 30))
            .millisecondsSinceEpoch,
      ],
    );

    return changed == 1;
  }
}
