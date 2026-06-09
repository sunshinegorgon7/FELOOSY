import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../../core/utils/backup_encryption.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/database/database_helper.dart';
import '../../providers/google_auth_provider.dart' show kDriveAppDataScope;

class BackupEntry {
  final String id;
  final DateTime modifiedTime;
  const BackupEntry({required this.id, required this.modifiedTime});
}

sealed class BackupResult {
  const BackupResult();
}

class BackupCreated extends BackupResult {
  final DateTime createdAt;
  const BackupCreated(this.createdAt);
}

class BackupSkipped extends BackupResult {
  const BackupSkipped();
}

class GoogleDriveBackupService {
  final DatabaseHelper _db;
  const GoogleDriveBackupService(this._db);

  static const _maxBackups = 5;
  static const _backupPrefix = 'feloosy_backup';
  static const _manifestName = 'feloosy_manifest.json';

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

  Future<List<BackupEntry>> _listAllBackups(drive.DriveApi api) async {
    final list = await api.files.list(
      spaces: 'appDataFolder',
      q: "name contains '$_backupPrefix' and trashed = false",
      $fields: 'files(id,name,modifiedTime)',
      orderBy: 'modifiedTime desc',
    );
    return (list.files ?? [])
        .where((f) => f.id != null && f.modifiedTime != null)
        .map((f) => BackupEntry(id: f.id!, modifiedTime: f.modifiedTime!))
        .toList();
  }

  Future<List<BackupEntry>> listBackups() async {
    final api = await _api();
    return _listAllBackups(api);
  }

  Future<DateTime?> lastBackupTime() async {
    try {
      final api = await _api();
      final all = await _listAllBackups(api);
      return all.firstOrNull?.modifiedTime;
    } catch (_) {
      return null;
    }
  }

  // SHA-256 of all user data. app_settings.last_backup_at is stripped out
  // so that a freshly-written timestamp doesn't count as a content change.
  Future<String> _computeContentHash(Database db) async {
    final rawSettings = await db.query('app_settings', orderBy: 'id');
    final settings = rawSettings.map((row) {
      final copy = Map<String, Object?>.from(row);
      copy.remove('last_backup_at');
      return copy;
    }).toList();

    final tables = <String, List<Map<String, Object?>>>{
      'accounts': await db.query('accounts', orderBy: 'id'),
      'transactions': await db.query('transactions', orderBy: 'uuid'),
      'budgets': await db.query('budgets', orderBy: 'id'),
      'categories': await db.query('categories', orderBy: 'uuid'),
      'app_settings': settings,
    };

    // Sort keys within each row so column ordering from SQLite is irrelevant.
    final canonical = tables.map(
      (table, rows) => MapEntry(
        table,
        rows
            .map((row) => Map.fromEntries(
                  row.entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key)),
                ))
            .toList(),
      ),
    );

    return sha256.convert(utf8.encode(jsonEncode(canonical))).toString();
  }

  // Reads the manifest HEAD from Drive. Returns null when no backup exists yet.
  Future<({String fileId, String contentHash})?> _fetchManifest(
      drive.DriveApi api) async {
    final list = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_manifestName' and trashed = false",
      $fields: 'files(id)',
    );
    final file = list.files?.firstOrNull;
    if (file?.id == null) return null;

    final media = await api.files.get(
      file!.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final bytes = await media.stream.expand((x) => x).toList();
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return (fileId: file.id!, contentHash: json['content_hash'] as String);
  }

  Future<void> _saveManifest(
    drive.DriveApi api, {
    String? existingManifestId,
    required String contentHash,
    required String backupId,
    required int backedUpAt,
  }) async {
    final bytes = utf8.encode(jsonEncode({
      'content_hash': contentHash,
      'backup_id': backupId,
      'backed_up_at': backedUpAt,
    }));
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: 'application/json',
    );

    if (existingManifestId != null) {
      await api.files.update(drive.File(), existingManifestId,
          uploadMedia: media);
    } else {
      await api.files.create(
        drive.File()
          ..name = _manifestName
          ..parents = ['appDataFolder'],
        uploadMedia: media,
      );
    }
  }

  Future<BackupResult> backup({bool silent = false}) async {
    if (silent) {
      // Non-interactive path: only proceed if Drive is already authorized.
      // authorizeScopes() would show a consent UI; authorizationForScopes()
      // returns null instead, which we treat as nothing to do.
      final auth = await GoogleSignIn.instance.authorizationClient
          .authorizationForScopes([kDriveAppDataScope]);
      if (auth == null) return const BackupSkipped();
    }
    final api = await _api();
    final db = await _db.database;

    final contentHash = await _computeContentHash(db);
    final manifest = await _fetchManifest(api);

    if (manifest != null && manifest.contentHash == contentHash) {
      return const BackupSkipped();
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = jsonEncode({
      'version': 1,
      'created_at': timestamp,
      'content_hash': contentHash,
      'data': {
        'accounts': await db.query('accounts'),
        'transactions': await db.query('transactions'),
        'budgets': await db.query('budgets'),
        'categories': await db.query('categories'),
        'app_settings': await db.query('app_settings'),
      },
    });

    final encrypted = await BackupEncryption.encrypt(utf8.encode(payload));
    final newFile = await api.files.create(
      drive.File()
        ..name = '${_backupPrefix}_$timestamp.feloosybkp'
        ..parents = ['appDataFolder'],
      uploadMedia: drive.Media(
        Stream.value(encrypted),
        encrypted.length,
        contentType: 'application/octet-stream',
      ),
    );

    await _saveManifest(
      api,
      existingManifestId: manifest?.fileId,
      contentHash: contentHash,
      backupId: newFile.id!,
      backedUpAt: timestamp,
    );

    // Prune: keep only the _maxBackups most recent backup files.
    final all = await _listAllBackups(api);
    if (all.length > _maxBackups) {
      for (final entry in all.skip(_maxBackups)) {
        await api.files.delete(entry.id);
      }
    }

    await db.update(
      'app_settings',
      {'last_backup_at': timestamp},
      where: 'id = 1',
    );

    return BackupCreated(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  Future<void> restore(String fileId) async {
    final api = await _api();

    final response = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final rawBytes = Uint8List.fromList(
        await response.stream.expand((x) => x).toList());

    List<int> jsonBytes;
    if (BackupEncryption.isEncrypted(rawBytes)) {
      final decrypted = await BackupEncryption.decrypt(rawBytes);
      if (decrypted == null) {
        throw const FormatException('Backup file could not be decrypted.');
      }
      jsonBytes = decrypted;
    } else {
      // Backwards compatibility: plain-JSON backups created before encryption.
      jsonBytes = rawBytes;
    }

    final json = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;
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
