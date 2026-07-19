import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/home/data_sheet.dart';

abstract final class BackupReminder {
  static bool _promptedThisSession = false;
  static const _staleAfter = Duration(days: 7);

  static Future<void> promptIfNeeded(
    BuildContext context,
    AppSettings settings,
  ) async {
    if (!settings.googleBackupEnabled) return;
    if (_promptedThisSession) return;

    final last = settings.lastBackupAt;
    final overdue =
        last == null || DateTime.now().difference(last) > _staleAfter;
    if (!overdue) return;

    _promptedThisSession = true;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final wantsBackup = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.cloud_off_outlined, color: cs.primary),
          title: Text(l10n.backupReminderTitle),
          content: Text(l10n.backupReminderBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.backupReminderLater),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.backupReminderNow),
            ),
          ],
        );
      },
    );

    if (wantsBackup == true && context.mounted) {
      showDataSheet(context);
    }
  }
}
