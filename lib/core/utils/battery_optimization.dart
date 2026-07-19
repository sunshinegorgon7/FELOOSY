import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/app_localizations.dart';

abstract final class BatteryOptimization {
  static bool _promptedThisSession = false;
  static const _storage = FlutterSecureStorage();
  static const _lastDismissedKey = 'feloosy_battery_opt_last_dismissed_ms';
  static const _reprompt = Duration(days: 3);

  static Future<void> promptIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;
    if (_promptedThisSession) return;

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return;

    final raw = await _storage.read(key: _lastDismissedKey);
    final lastMs = raw != null ? int.tryParse(raw) : null;
    if (lastMs != null &&
        DateTime.now().difference(
              DateTime.fromMillisecondsSinceEpoch(lastMs),
            ) <
            _reprompt) {
      return;
    }

    _promptedThisSession = true;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
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
    } else {
      await _storage.write(
        key: _lastDismissedKey,
        value: '${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }
}
