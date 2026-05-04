import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/database/database_helper.dart';
import '../../providers/google_auth_provider.dart' show kDriveAppDataScope;

class GoogleDriveBackupService {
  final DatabaseHelper _db;
  const GoogleDriveBackupService(this._db);

  static const _backupFileName = 'feloosy_backup.json';

  Future<drive.DriveApi> _api() async {
    final auth = await GoogleSignIn.instance.authorizationClient
        .authorizeScopes([kDriveAppDataScope]);
    final client = auth.authClient(scopes: [kDriveAppDataScope]);
    return drive.DriveApi(client);
  }

  Future<bool> hasLocalData() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM transactions');
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<String?> _findBackupFileId(drive.DriveApi api) async {
    final list = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName' and trashed = false",
      $fields: 'files(id)',
    );
    return list.files?.firstOrNull?.id;
  }

  Future<DateTime?> lastBackupTime() async {
    try {
      final api = await _api();
      final list = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName' and trashed = false",
        $fields: 'files(id,modifiedTime)',
      );
      return list.files?.firstOrNull?.modifiedTime;
    } catch (_) {
      return null;
    }
  }

  Future<void> backup() async {
    final api = await _api();
    final db = await _db.database;

    final payload = jsonEncode({
      'version': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'data': {
        'accounts': await db.query('accounts'),
        'transactions': await db.query('transactions'),
        'budgets': await db.query('budgets'),
        'categories': await db.query('categories'),
        'app_settings': await db.query('app_settings'),
      },
    });

    final bytes = utf8.encode(payload);
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: 'application/json',
    );

    final existingId = await _findBackupFileId(api);
    if (existingId != null) {
      await api.files.update(drive.File(), existingId, uploadMedia: media);
    } else {
      await api.files.create(
        drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'],
        uploadMedia: media,
      );
    }

    await db.update(
      'app_settings',
      {'last_backup_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = 1',
    );
  }

  Future<void> restore() async {
    final api = await _api();

    final list = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName' and trashed = false",
      $fields: 'files(id)',
    );
    final fileId = list.files?.firstOrNull?.id;
    if (fileId == null) throw Exception('No backup found in Google Drive.');

    final response = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = await response.stream.expand((x) => x).toList();
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final tables = json['data'] as Map<String, dynamic>;

    final db = await _db.database;
    await db.transaction((txn) async {
      for (final table in [
        'transactions',
        'budgets',
        'categories',
        'accounts',
        'app_settings',
      ]) {
        await txn.delete(table);
      }
      for (final table in [
        'app_settings',
        'accounts',
        'categories',
        'budgets',
        'transactions',
      ]) {
        final rows = (tables[table] as List<dynamic>?) ?? [];
        for (final row in rows) {
          await txn.insert(
            table,
            Map<String, dynamic>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }
}
