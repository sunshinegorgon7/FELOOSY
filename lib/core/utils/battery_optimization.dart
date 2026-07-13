import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/app_localizations.dart';

abstract final class BatteryOptimization {
  static bool _promptedThisSession = false;

  static Future<void> promptIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;
    if (_promptedThisSession) return;

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return;

    _promptedThisSession = true;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.battery_alert_outlined, color: cs.primary),
          title: Text(l10n.batteryOptTitle),
          content: Text(l10n.batteryOptBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.batteryOptNotNow),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.batteryOptAllow),
            ),
          ],
        );
      },
    );

    if (accepted == true) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }
}
