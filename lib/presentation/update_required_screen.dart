import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_info.dart';
import '../services/remote_config_service.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final RemoteConfig config;

  const UpdateRequiredScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.system_update_outlined, size: 72, color: cs.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Update Required',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    config.message,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Build $kAppBuildNumber',
                    style: TextStyle(color: cs.outline, fontSize: 12),
                  ),
                  if (config.storeUrl != null) ...[
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(config.storeUrl!),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Update Now'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
