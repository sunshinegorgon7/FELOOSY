import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';
import '../domain/services/google_drive_backup_service.dart';

final googleDriveBackupProvider = Provider<GoogleDriveBackupService>((_) {
  return GoogleDriveBackupService(DatabaseHelper.instance);
});
