import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../data/database/database_helper.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';

class FirebaseSyncService {
  final String uid;
  final FirebaseFirestore _fs;
  final DatabaseHelper _local;

  FirebaseSyncService({required this.uid, required DatabaseHelper localDb})
      : _fs = FirebaseFirestore.instance,
        _local = localDb;

  // ── Collection / document references ─────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _txCol =>
      _fs.collection('users').doc(uid).collection('transactions');

  CollectionReference<Map<String, dynamic>> get _budgetCol =>
      _fs.collection('users').doc(uid).collection('budgets');

  CollectionReference<Map<String, dynamic>> get _catCol =>
      _fs.collection('users').doc(uid).collection('categories');

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _fs.collection('users').doc(uid).collection('settings').doc('main');

  // ── Individual sync (called on every local write) ─────────────────────────

  Future<void> syncTransaction(Transaction tx) =>
      _txCol.doc(tx.uuid).set(tx.toMap());

  Future<void> deleteTransaction(String uuid) => _txCol.doc(uuid).delete();

  Future<void> syncBudget(Budget budget) {
    final id = '${budget.year}-${budget.month}';
    return _budgetCol.doc(id).set(budget.toMap());
  }

  Future<void> syncCategory(Category cat) =>
      _catCol.doc(cat.uuid).set(cat.toMap());

  Future<void> deleteCategory(String uuid) => _catCol.doc(uuid).delete();

  Future<void> syncSettings(AppSettings settings) =>
      _settingsDoc.set(settings.toMap());

  // ── Check whether this user already has cloud data ────────────────────────

  Future<bool> hasRemoteData() async {
    final snap = await _txCol.limit(1).get();
    return snap.docs.isNotEmpty;
  }

  // ── Full push: local SQLite → Firestore ───────────────────────────────────

  Future<void> pushAll() async {
    final db = await _local.database;
    final batch = _fs.batch();

    final txRows = await db.query('transactions');
    for (final row in txRows) {
      batch.set(_txCol.doc(row['uuid'] as String), _stripId(row));
    }

    final budgetRows = await db.query('budgets');
    for (final row in budgetRows) {
      final id = '${row['year']}-${row['month']}';
      batch.set(_budgetCol.doc(id), _stripId(row));
    }

    final catRows = await db.query('categories');
    for (final row in catRows) {
      batch.set(_catCol.doc(row['uuid'] as String), _stripId(row));
    }

    final settingsRows = await db.query('app_settings');
    if (settingsRows.isNotEmpty) {
      batch.set(_settingsDoc, settingsRows.first);
    }

    await batch.commit();
  }

  // ── Full pull: Firestore → local SQLite ───────────────────────────────────

  Future<void> pullAll() async {
    final db = await _local.database;

    final txSnap = await _txCol.get();
    if (txSnap.docs.isNotEmpty) {
      await db.delete('transactions');
      final batch = db.batch();
      for (final doc in txSnap.docs) {
        batch.insert('transactions', doc.data(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    }

    final budgetSnap = await _budgetCol.get();
    if (budgetSnap.docs.isNotEmpty) {
      await db.delete('budgets');
      final batch = db.batch();
      for (final doc in budgetSnap.docs) {
        batch.insert('budgets', doc.data(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    }

    // Restore categories from cloud so transaction category_uuid references
    // always match local categories after reinstall.
    final catSnap = await _catCol.get();
    if (catSnap.docs.isNotEmpty) {
      await db.delete('categories');
      final batch = db.batch();
      for (final doc in catSnap.docs) {
        batch.insert('categories', doc.data(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    }

    final settingsDoc = await _settingsDoc.get();
    if (settingsDoc.exists && settingsDoc.data() != null) {
      await db.update('app_settings', settingsDoc.data()!,
          where: 'id = ?', whereArgs: [1]);
    }
  }

  Map<String, dynamic> _stripId(Map<String, dynamic> row) =>
      Map.of(row)..remove('id');
}
