import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_flavor.dart';
import '../../app/app_theme.dart';
import '../../core/constants/app_info.dart';
import '../../core/constants/currencies.dart';
import '../../data/database/database_helper.dart';
import '../../dev/seed_snapshot_service.dart';
import '../../data/models/app_settings.dart';
import '../../domain/services/google_drive_backup_service.dart';
import '../../domain/services/local_export_service.dart';
import '../../providers/budget_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/drive_backup_provider.dart';
import '../../providers/google_auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/access_tier_provider.dart';
import '../../providers/sms_subscription_provider.dart';
import '../paywall/paywall_screen.dart' show PaywallFocus;

class SettingsScreen extends ConsumerWidget {
  final bool isModal;
  const SettingsScreen({super.key, this.isModal = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    final body = settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (settings) =>
          _SettingsBody(settings: settings, isModal: isModal),
    );

    if (isModal) return body;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Settings')),
      body: body,
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final AppSettings settings;
  final bool isModal;
  const _SettingsBody({required this.settings, this.isModal = false});

  void _save(WidgetRef ref, AppSettings updated) {
    ref.read(settingsProvider.notifier).saveSettings(updated);
  }

  void _navigateCategories(BuildContext context) {
    if (isModal) {
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.push('/categories');
      });
    } else {
      context.push('/categories');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 16),
      children: [
        const _SectionHeader('Appearance'),
        _AppearanceSection(settings: settings),
        const _SectionHeader('Budget'),
        _SettingsRow(
          title: 'Currency',
          value:
              '${settings.currencySymbol}  ${_currencyName(settings.currencyCode)}',
          onTap: () => _showCurrencyPicker(context, ref, settings),
        ),
        _SettingsRow(
          title: 'Month starts on',
          value:
              'Day ${settings.monthStartDay}${_ordinal(settings.monthStartDay)}',
          onTap: () => _showDayPicker(context, ref, settings),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            'Days 29–31 unavailable to ensure February compatibility.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        _SettingsRow(
          title: 'Default monthly budget',
          value: settings.defaultMonthlyBudget > 0
              ? '${settings.currencySymbol} ${settings.defaultMonthlyBudget.toStringAsFixed(2)}'
              : 'Not set',
          onTap: () => _showDefaultBudgetDialog(context, ref, settings),
        ),

        const _SectionHeader('Categories'),
        _SettingsRow(
          title: 'Manage categories',
          onTap: () => _navigateCategories(context),
        ),

        const _SectionHeader('Wallets'),
        _SettingsRow(
          title: 'Manage wallets',
          onTap: () => context.push('/settings/accounts'),
        ),

        if (AppFlavor.isDev) ...[
          const _SectionHeader('Automations'),
          _SmsRulesTile(isModal: isModal),
        ],

        const _SectionHeader('Data'),
        _DriveBackupTile(isModal: isModal),
        _LocalBackupTile(isModal: isModal),

        const _SectionHeader('About'),
        const _InfoRow(title: 'Version', value: kAppVersionLabel),
        _SettingsRow(
          title: 'Privacy Policy',
          onTap: () => context.push('/settings/privacy'),
        ),

        if (AppFlavor.isDev) ...[
          const _SectionHeader('Developer Tools'),
          const _DevSnapshotTile(),
        ],

        const _SectionHeader('Danger Zone', danger: true),
        _SettingsRow(
          title: 'Reset app',
          subtitle: 'Erase all transactions and budgets, restore defaults',
          danger: true,
          onTap: () => _showResetConfirmation(context, ref),
        ),

        const Gap(32),
      ],
    );
  }

  String _currencyName(String code) {
    return kCurrencies
            .where((c) => c.code == code)
            .firstOrNull
            ?.name ??
        code;
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th';
    return switch (n % 10) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' };
  }

  void _showDefaultBudgetDialog(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    final ctrl = TextEditingController(
      text: settings.defaultMonthlyBudget > 0
          ? settings.defaultMonthlyBudget.toStringAsFixed(2)
          : '',
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Default monthly budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applied automatically when no budget has been set for the current month.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '${settings.currencySymbol}  ',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (settings.defaultMonthlyBudget > 0)
            TextButton(
              onPressed: () {
                _save(ref, settings.copyWith(defaultMonthlyBudget: 0));
                Navigator.pop(ctx);
              },
              child: const Text('Clear'),
            ),
          FilledButton(
            onPressed: () {
              final amount =
                  double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;
              _save(ref, settings.copyWith(defaultMonthlyBudget: amount));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Select Currency',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: kCurrencies.length,
                itemBuilder: (context, i) {
                  final c = kCurrencies[i];
                  final isSelected = c.code == settings.currencyCode;
                  return ListTile(
                    leading: SizedBox(
                      width: 48,
                      child: Text(
                        c.symbol,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    title: Text(c.name),
                    subtitle: Text(c.code),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      _save(
                        ref,
                        settings.copyWith(
                          currencyCode: c.code,
                          currencySymbol: c.symbol,
                          currencySymbolLeading: c.symbolLeading,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayPicker(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Month starts on day…'),
        content: SizedBox(
          width: 280,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 28,
            itemBuilder: (context, i) {
              final day = i + 1;
              final isSelected = day == settings.monthStartDay;
              return InkWell(
                onTap: () {
                  if (day != settings.monthStartDay) {
                    _showDayChangeWarning(ctx, ref, settings, day);
                  } else {
                    Navigator.pop(ctx);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 32),
        title: const Text('Reset app?'),
        content: const Text(
          'This will permanently delete:\n'
          '  • All transactions\n'
          '  • All budgets\n'
          '  • All custom categories\n\n'
          'Settings will be restored to defaults and you will be '
          'signed out of Google. Sign in again afterwards to restore '
          'from a backup.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await _resetApp(context, ref);
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetApp(BuildContext context, WidgetRef ref) async {
    await DatabaseHelper.instance.resetAll();
    await ref.read(googleAccountProvider.notifier).signOut();
    ref.invalidate(transactionsProvider);
    ref.invalidate(transactionPeriodOffsetsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(currentBudgetProvider);
    ref.invalidate(settingsProvider);
    if (context.mounted && isModal) {
      Navigator.of(context).pop();
    }
  }

  void _showDayChangeWarning(BuildContext ctx, WidgetRef ref,
      AppSettings settings, int newDay) {
    showDialog(
      context: ctx,
      builder: (warnCtx) => AlertDialog(
        title: const Text('Change start day?'),
        content: Text(
          'Changing from day ${settings.monthStartDay} to day $newDay '
          'will shift the period boundaries for all months. '
          'Existing transactions stay as-is.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(warnCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _save(ref, settings.copyWith(monthStartDay: newDay));
              Navigator.pop(warnCtx);
              Navigator.pop(ctx);
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

// ── Google Drive backup tile ──────────────────────────────────────────────────

class _DriveBackupTile extends ConsumerStatefulWidget {
  final bool isModal;
  const _DriveBackupTile({this.isModal = false});

  @override
  ConsumerState<_DriveBackupTile> createState() => _DriveBackupTileState();
}

class _DriveBackupTileState extends ConsumerState<_DriveBackupTile> {
  bool _signingIn = false;
  bool _backingUp = false;
  bool _restoring = false;
  bool _loadingBackups = false;
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadLastBackupTime();
  }

  Future<void> _loadLastBackupTime() async {
    final account = ref.read(googleAccountProvider);
    if (account == null) return;
    final t = await ref.read(googleDriveBackupProvider).lastBackupTime();
    if (mounted) setState(() => _lastBackupTime = t);
  }

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    try {
      await ref.read(googleAccountProvider.notifier).signIn();
      await _loadLastBackupTime();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign-in failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _signingIn = true);
    try {
      await ref.read(googleAccountProvider.notifier).signOut();
      if (mounted) setState(() => _lastBackupTime = null);
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _backup() async {
    setState(() => _backingUp = true);
    try {
      final result = await ref.read(googleDriveBackupProvider).backup();
      if (mounted) {
        switch (result) {
          case BackupCreated():
            final t =
                await ref.read(googleDriveBackupProvider).lastBackupTime();
            if (!mounted) break;
            setState(() => _lastBackupTime = t);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup saved to Google Drive.')),
            );
          case BackupSkipped():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No changes since last backup — skipped.')),
            );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Backup failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  Future<void> _restore() async {
    final svc = ref.read(googleDriveBackupProvider);

    // Step 1: fetch available backups
    setState(() => _loadingBackups = true);
    List<BackupEntry> backups;
    try {
      backups = await svc.listBackups();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not list backups: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
      if (mounted) setState(() => _loadingBackups = false);
      return;
    }
    if (mounted) setState(() => _loadingBackups = false);

    if (!mounted) return;

    if (backups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('No backup found in Google Drive.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }

    // Step 2: pick which backup to restore (skip picker if only one)
    final String selectedId;
    if (backups.length == 1) {
      selectedId = backups.first.id;
    } else {
      final picked = await _pickBackup(backups);
      if (picked == null || !mounted) return;
      selectedId = picked;
    }

    // Step 3: warn if local data will be overwritten
    final hasLocal = await svc.hasLocalData();
    if (!mounted) return;

    if (hasLocal) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final cs = Theme.of(ctx).colorScheme;
          return AlertDialog(
            icon: Icon(Icons.warning_rounded, color: cs.error, size: 36),
            title: const Text('Replace all local data?'),
            content: const Text(
              'Restoring from Google Drive will permanently delete '
              'everything currently on this device — all transactions, '
              'budgets, and categories — and replace it with the backup.\n\n'
              'This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: cs.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Replace my data'),
              ),
            ],
          );
        },
      );
      if (confirmed != true) return;
    }

    // Step 4: do the restore
    setState(() => _restoring = true);
    try {
      await svc.restore(selectedId);
      ref.invalidate(transactionsProvider);
      ref.invalidate(transactionPeriodOffsetsProvider);
      ref.invalidate(currentBudgetProvider);
      ref.invalidate(settingsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(accountsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data restored from Google Drive.')),
        );
        if (widget.isModal) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Restore failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  void _navigateToPaywall(BuildContext context) {
    if (widget.isModal) {
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.push('/paywall');
      });
    } else {
      context.push('/paywall');
    }
  }

  Future<String?> _pickBackup(List<BackupEntry> backups) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select backup to restore'),
        children: [
          ...backups.map(
            (b) => SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, b.id),
              child: Text(_formatBackupTime(b.modifiedTime)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBackupTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(googleAccountProvider);
    final cs = Theme.of(context).colorScheme;
    final anyBusy = _signingIn || _backingUp || _restoring || _loadingBackups;

    if (account == null) {
      return _SettingsRow(
        title: 'Back up to Google Drive',
        subtitle: 'Sign in to enable backup',
        busy: _signingIn,
        onTap: anyBusy
            ? null
            : () {
                if (!ref.read(accessTierProvider).canBackup) {
                  _navigateToPaywall(context);
                  return;
                }
                _signIn();
              },
      );
    }

    final tt = Theme.of(context).textTheme;
    final lastBackupLabel = _lastBackupTime != null
        ? 'Last backup: ${_formatBackupTime(_lastBackupTime!)}'
        : 'No backup yet';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 6),
          child: Row(
            children: [
              account.photoUrl != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(account.photoUrl!),
                      radius: 18,
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [cs.primary, cs.inversePrimary],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        account.email.isNotEmpty
                            ? account.email[0].toUpperCase()
                            : 'S',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  account.email,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _signingIn
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: anyBusy ? null : _signOut,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryText(cs),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Sign out',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
            ],
          ),
        ),
        _SettingsRow(
          title: 'Back up now',
          value: lastBackupLabel,
          busy: _backingUp,
          onTap: anyBusy ? null : _backup,
        ),
        _SettingsRow(
          title: 'Restore from Drive',
          subtitle: 'Replace local data with Drive backup',
          busy: _restoring || _loadingBackups,
          onTap: anyBusy ? null : _restore,
        ),
      ],
    );
  }
}

// ── Local export / import tile ────────────────────────────────────────────────

class _LocalBackupTile extends ConsumerStatefulWidget {
  final bool isModal;
  const _LocalBackupTile({this.isModal = false});

  @override
  ConsumerState<_LocalBackupTile> createState() => _LocalBackupTileState();
}

class _LocalBackupTileState extends ConsumerState<_LocalBackupTile> {
  bool _exporting = false;
  bool _importing = false;

  final _svc = LocalExportService(DatabaseHelper.instance);

  void _navigateToPaywall(BuildContext context) {
    if (widget.isModal) {
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.push('/paywall');
      });
    } else {
      context.push('/paywall');
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      await _svc.export();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _pickAndImport() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;

    final ImportSummary summary;
    try {
      summary = await _svc.preview(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot read file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.upload_file_outlined,
            color: Theme.of(ctx).colorScheme.primary, size: 32),
        title: const Text('Import backup?'),
        content: Text(
          'Found:\n'
          '  • ${summary.transactions} transaction${summary.transactions == 1 ? '' : 's'}\n'
          '  • ${summary.budgets} budget${summary.budgets == 1 ? '' : 's'}\n'
          '  • ${summary.categories} categor${summary.categories == 1 ? 'y' : 'ies'}\n\n'
          'This will replace all local data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _importing = true);
    try {
      final done = await _svc.commit(path);
      ref.invalidate(transactionsProvider);
      ref.invalidate(transactionPeriodOffsetsProvider);
      ref.invalidate(currentBudgetProvider);
      ref.invalidate(settingsProvider);
      ref.invalidate(categoriesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${done.transactions} transaction${done.transactions == 1 ? '' : 's'} successfully.',
            ),
          ),
        );
        if (widget.isModal) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _exporting || _importing;
    return Column(
      children: [
        _SettingsRow(
          title: 'Export backup',
          subtitle: 'Save all data as a JSON file',
          busy: _exporting,
          onTap: busy
              ? null
              : () {
                  if (!ref.read(accessTierProvider).canExport) {
                    _navigateToPaywall(context);
                    return;
                  }
                  _export();
                },
        ),
        _SettingsRow(
          title: 'Restore from file',
          subtitle: 'Replace local data with an exported backup',
          busy: _importing,
          onTap: busy ? null : _pickAndImport,
        ),
      ],
    );
  }
}

// ── SMS Rules tile ────────────────────────────────────────────────────────────

class _SmsRulesTile extends ConsumerWidget {
  final bool isModal;
  const _SmsRulesTile({this.isModal = false});

  void _navigate(BuildContext context, WidgetRef ref) {
    final isSubscribed =
        ref.read(smsSubscriptionProvider).asData?.value ?? AppFlavor.isDev;
    if (!isSubscribed) {
      if (isModal) {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.push('/paywall', extra: PaywallFocus.sms);
        });
      } else {
        context.push('/paywall', extra: PaywallFocus.sms);
      }
      return;
    }
    if (isModal) {
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.push('/sms-rules');
      });
    } else {
      context.push('/sms-rules');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsRow(
      title: 'SMS Rules',
      subtitle: 'Auto-create transactions from incoming messages',
      onTap: () => _navigate(context, ref),
    );
  }
}

// ── Appearance segmented control ──────────────────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  final AppSettings settings;
  const _AppearanceSection({required this.settings});

  static const _segments = [
    ('light', 'Light'),
    ('system', 'Auto'),
    ('dark', 'Dark'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final current = settings.themeMode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: _segments.map((seg) {
            final (value, label) = seg;
            final isActive = current == value;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (current == value) return;
                  ref.read(settingsProvider.notifier).saveSettings(
                        settings.copyWith(themeMode: value),
                      );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? cs.onPrimary
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? value;
  final bool busy;
  final bool danger;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.title,
    this.subtitle,
    this.value,
    this.busy = false,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = AppTheme.primaryText(cs);

    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        subtitle != null ? 11 : 13,
        16,
        subtitle != null ? 11 : 13,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(
                    color: danger ? cs.error : null,
                    fontWeight: danger ? FontWeight.w500 : null,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                value!,
                style: tt.bodySmall?.copyWith(
                  color: danger ? cs.error : accentColor,
                  fontFamily: 'DM Mono',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.right,
              ),
            ),
          ],
          const SizedBox(width: 6),
          if (busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.chevron_right,
              size: 14,
              color: danger
                  ? cs.error.withValues(alpha: 0.4)
                  : cs.onSurfaceVariant,
            ),
        ],
      ),
    );

    if (danger) {
      return Ink(
        color: cs.errorContainer.withValues(alpha: 0.05),
        child: InkWell(onTap: onTap, child: content),
      );
    }
    return InkWell(onTap: onTap, child: content);
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(child: Text(title, style: tt.bodyMedium)),
          Text(
            value,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DevSnapshotTile extends ConsumerStatefulWidget {
  const _DevSnapshotTile();

  @override
  ConsumerState<_DevSnapshotTile> createState() => _DevSnapshotTileState();
}

class _DevSnapshotTileState extends ConsumerState<_DevSnapshotTile> {
  bool _busy = false;

  Future<void> _enter() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Snapshot Mode?'),
        content: const Text(
          'Your current data will be backed up locally. '
          '3 wallets with 90 days of sample transactions will be seeded. '
          'Tap "Exit" in the snapshot banner at any time to restore your real data.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Seed & Enter')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    await SeedSnapshotService.enterSnapshot(ref);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _exit() async {
    setState(() => _busy = true);
    await SeedSnapshotService.exitSnapshot(ref);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final snapshotActive = ref.watch(snapshotModeProvider).value ?? false;
    return _SettingsRow(
      title: snapshotActive ? 'Exit Snapshot Mode' : 'Seed Test Data',
      subtitle: snapshotActive
          ? 'Restore your real data and discard sample data'
          : 'Seed 3 wallets × 90 days of sample transactions',
      busy: _busy,
      onTap: _busy ? null : (snapshotActive ? _exit : _enter),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool danger;
  const _SectionHeader(this.title, {this.danger = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = AppTheme.primaryText(cs);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 2),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: danger ? cs.error.withValues(alpha: 0.8) : accentColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.10 * 11,
            ),
      ),
    );
  }
}
