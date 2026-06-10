import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: const [
          _PolicyHeader(),
          SizedBox(height: 24),
          _Section(
            title: 'Summary',
            body:
                'Feloosy is a local-first budgeting app. Your financial data '
                'stays on your device. We have no user accounts and no servers '
                'that store your personal information. The only optional '
                'external data flow is Google Drive backup (your own Drive '
                'folder). SMS auto-import is an opt-in feature; messages are '
                'processed entirely in memory and never stored or transmitted.',
          ),
          _Section(
            title: '1. Data We Store Locally',
            body:
                'The following data is stored only on your device in a private '
                'SQLite database:\n\n'
                '• Transactions (amounts, dates, descriptions, categories)\n'
                '• Budget amounts per month\n'
                '• Wallet names and currency settings\n'
                '• Category names, icons, and colours\n'
                '• App preferences (theme, month start day)\n'
                '• SMS parsing rules (keywords and patterns)\n'
                '• Recurring transaction rules\n\n'
                'Uninstalling the app permanently deletes all of this data.',
          ),
          _Section(
            title: '2. SMS Auto-Import (Opt-In, Android Only)',
            body:
                'SMS auto-import is entirely opt-in. If you enable it, '
                'Feloosy requests READ_SMS and RECEIVE_SMS permissions '
                'to detect bank transaction notifications.\n\n'
                'How SMS data is used:\n'
                '• Each incoming or scanned SMS is matched in memory against '
                'your rules to identify the sender and extract a transaction '
                'amount.\n'
                '• If a match is found, only the extracted amount and matched '
                'rule metadata are saved as a transaction.\n'
                '• The raw SMS text is never written to our database, never '
                'sent to any server, and never shared with any third party.\n\n'
                'You can disable SMS auto-import at any time in '
                'Settings → Automations. Disabling does not affect any '
                'existing transactions.',
          ),
          _Section(
            title: '3. Financial Data & Local Storage',
            body:
                'All budget and transaction data is stored locally on your '
                'device using SQLite. We operate no servers and have no '
                'ability to access your financial data remotely.\n\n'
                'Your data never leaves your device unless you explicitly '
                'enable Google Drive backup (described below).',
          ),
          _Section(
            title: '4. Google Drive Backup (Optional)',
            body:
                'If you sign in with Google and enable Drive backup, Feloosy '
                'uploads a JSON snapshot of your data to the private '
                'appDataFolder of your own Google Drive account. This folder '
                'is accessible only to you and to Feloosy.\n\n'
                '• Data in transit is encrypted via HTTPS.\n'
                '• Backups are stored under your Google account and governed '
                'by Google\'s Privacy Policy (policies.google.com/privacy).\n'
                '• You can delete all backups at any time via '
                'drive.google.com → Storage → Hidden app data.\n'
                '• Signing out of Google in Feloosy disconnects the app; '
                'existing Drive backups remain under your Google account '
                'until you delete them.\n\n'
                'We never access your Google Drive beyond the appDataFolder '
                'created for Feloosy.',
          ),
          _Section(
            title: '5. In-App Purchases',
            body:
                'Feloosy offers an optional Pro lifetime purchase processed '
                'through Google Play Billing. We receive only a purchase '
                'confirmation token; payment details and card information are '
                'handled entirely by Google. Purchase status is stored locally '
                'on your device in encrypted secure storage.',
          ),
          _Section(
            title: '6. Third-Party Data Sharing',
            body:
                'We do not sell, rent, or share your personal data with '
                'third parties for advertising or any commercial purpose.\n\n'
                'The only third-party services that may receive any data are:\n\n'
                '• Google Drive — your own backup files (optional, Drive '
                'backup feature only)\n'
                '• Google Play Billing — purchase confirmation (when buying '
                'Pro)\n\n'
                'No analytics SDKs, advertising networks, AI APIs, or '
                'crash-reporting services are integrated in this app.',
          ),
          _Section(
            title: '7. Data Retention & Deletion',
            body:
                'Local data: retained until you uninstall the app or use the '
                '"Reset app" option in Settings → Danger Zone.\n\n'
                'Drive backups: retained in your Google Drive until you delete '
                'them manually. Feloosy automatically keeps at most 5 backups '
                'and deletes the oldest when a new one is created.',
          ),
          _Section(
            title: '8. Security',
            body:
                'Local data is stored in your device\'s private app storage, '
                'which other apps cannot access without root access.\n\n'
                'All network communication (Google Drive, Google Sign-In, '
                'Google Play) uses HTTPS/TLS encryption.\n\n'
                'Purchase status is stored using the platform\'s secure '
                'encrypted storage (flutter_secure_storage).',
          ),
          _Section(
            title: '9. Children\'s Privacy',
            body:
                'Feloosy is not directed at children under the age of 13. '
                'We do not knowingly collect personal information from children. '
                'If you believe a child has provided personal information through '
                'this app, please contact us so we can address it.',
          ),
          _Section(
            title: '10. Changes to This Policy',
            body:
                'We may update this Privacy Policy from time to time. When we '
                'do, the effective date at the top of this page will be updated. '
                'Continued use of the app after any changes constitutes '
                'acceptance of the revised policy. Significant changes will be '
                'notified via an in-app notice.',
          ),
          _Section(
            title: '11. Contact Us',
            body:
                'If you have any questions or concerns about this Privacy Policy '
                'or how your data is handled, please contact us at:\n\n'
                'Email: privacy@feloosy.com\n\n'
                'We aim to respond within 5 business days.',
          ),
          SizedBox(height: 8),
          _EffectiveDateFooter(),
        ],
      ),
    );
  }
}

class _PolicyHeader extends StatelessWidget {
  const _PolicyHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = AppTheme.primaryText(cs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 20, color: accentColor),
            const SizedBox(width: 8),
            Text(
              'FELOOSY PRIVACY POLICY',
              style: tt.labelSmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Effective Date: June 10, 2026',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 14, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your data stays on your device. We have no servers '
                  'and never see your financial information.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.6,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectiveDateFooter extends StatelessWidget {
  const _EffectiveDateFooter();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Text(
      'Last updated: June 10, 2026 · Feloosy v1.4.1',
      style: tt.labelSmall?.copyWith(
        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
