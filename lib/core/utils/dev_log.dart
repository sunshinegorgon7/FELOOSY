import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/app_flavor.dart';

/// Lightweight, dev-flavor-only file logger for diagnosing the SMS pipeline on
/// real devices. Writes to a daily-rotating file under the app support dir and
/// prunes files older than [_retentionDays]. No-op in prod so it never touches
/// disk for real users.
///
/// Both the app isolate and the headless SMS background isolate call into this;
/// they append to the same daily file. Interleaved lines are fine for a log.
class DevLog {
  static const _dirName = 'logs';
  static const _filePrefix = 'sms-';
  static const _retentionDays = 7;

  static bool _prunedThisRun = false;

  /// Directory holding the log files. Created on demand.
  ///
  /// Uses the application support directory, which on Android is the app's
  /// `filesDir` (`/data/data/<pkg>/files`). The native [SmsReceiver] writes to
  /// `context.filesDir/logs` with the same filename convention, so native and
  /// Dart lifecycle events land in the same daily file.
  static Future<Directory> logDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, _dirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Appends a timestamped line. Never throws.
  static Future<void> log(String tag, String message) async {
    if (!AppFlavor.isDev) return;
    try {
      final dir = await logDir();
      final now = DateTime.now();
      final file = File(p.join(dir.path, '$_filePrefix${_dateStamp(now)}.log'));
      final line = '${now.toIso8601String()} | $tag | $message\n';
      await file.writeAsString(line, mode: FileMode.append, flush: true);
      await _pruneOnce(dir);
    } catch (_) {
      // Diagnostics must never affect app behaviour.
    }
  }

  /// All current log files, newest first. Empty in prod.
  static Future<List<File>> files() async {
    if (!AppFlavor.isDev) return const [];
    try {
      final dir = await logDir();
      final logs = (await dir.list().toList())
          .whereType<File>()
          .where((f) => p.basename(f.path).startsWith(_filePrefix))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));
      return logs;
    } catch (_) {
      return const [];
    }
  }

  /// All log files concatenated oldest-first, for export/sharing. Empty string
  /// when there is nothing to export.
  static Future<String> combined() async {
    final logs = await files();
    if (logs.isEmpty) return '';
    final buf = StringBuffer();
    for (final f in logs.reversed) {
      buf.writeln('===== ${p.basename(f.path)} =====');
      try {
        buf.writeln(await f.readAsString());
      } catch (_) {}
    }
    return buf.toString();
  }

  static Future<void> _pruneOnce(Directory dir) async {
    if (_prunedThisRun) return;
    _prunedThisRun = true;
    final cutoff = DateTime.now().subtract(const Duration(days: _retentionDays));
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!name.startsWith(_filePrefix)) continue;
      final stamp = name
          .replaceFirst(_filePrefix, '')
          .replaceFirst('.log', '');
      final date = DateTime.tryParse(stamp);
      if (date != null && date.isBefore(cutoff)) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }

  static String _dateStamp(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
