import 'dart:io';

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
import '../../core/extensions/localizations_extension.dart';
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
import '../../providers/purchase_provider.dart';

const _languages = [
  ('', 'System default'),
  ('en', 'English'),
  ('ar', 'العربية'),
];

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
      appBar: AppBar(title: Text(context.l10n.settings)),
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
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final currentLangName = _languages
        .where((e) => e.$1 == settings.languageCode)
        .firstOrNull
        ?.$2 ?? 'System default';

    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 16),
      children: [
        _SectionHeader(l10n.settingsAppearance),
        _AppearanceSection(settings: settings),
        _SettingsRow(
          title: l10n.settingsLanguage,
          value: currentLangName,
          onTap: () => _showLanguagePicker(context, ref, settings),
        ),
        _SectionHeader(l10n.budget),
        _SettingsRow(
          title: l10n.currency,
          value:
              '${settings.currencySymbol}  ${_currencyName(settings.currencyCode)}',
          onTap: () => _showCurrencyPicker(context, ref, settings),
        ),
        _SettingsRow(
          title: l10n.settingsMonthStartsOn,
          value: l10n.settingsMonthStartDay(settings.monthStartDay, _ordinal(settings.monthStartDay)),
          onTap: () => _showDayPicker(context, ref, settings),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            l10n.settingsDaysFebNote,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        _SectionHeader(l10n.categories),
        _SettingsRow(
          title: l10n.settingsManageCategories,
          onTap: () => _navigateCategories(context),
        ),

        _SectionHeader(l10n.settingsWallets),
        _SettingsRow(
          title: l10n.settingsManageWallets,
          onTap: () => context.push('/settings/accounts'),
        ),

        if (Platform.isAndroid) ...[
          _SectionHeader(l10n.settingsAutomations),
          _SmsToggleTile(isModal: isModal),
          if (settings.smsOptIn) _SmsRulesTile(isModal: isModal),
        ],

        _SectionHeader(l10n.settingsData),
        _DriveBackupTile(isModal: isModal),
        _LocalBackupTile(isModal: isModal),

        _SectionHeader(l10n.settingsAbout),
        _InfoRow(title: l10n.version, value: kAppVersionLabel),
        _SettingsRow(
          title: l10n.settingsPrivacyPolicy,
          onTap: () => context.push('/settings/privacy'),
        ),
        _SettingsRow(
          title: 'Replay tutorial',
          subtitle: 'Walk through the onboarding tour again',
          onTap: () {
            ref.read(settingsProvider.notifier).resetTutorial();
            if (isModal) Navigator.of(context).pop();
          },
        ),

        if (AppFlavor.isDev) ...[
          _SectionHeader(l10n.settingsDeveloperTools),
          const _DevSnapshotTile(),
          _SettingsRow(
            title: 'License Keys',
            subtitle: 'Generate and manage Ed25519 license keys',
            onTap: () => context.push('/admin/licenses'),
          ),
        ],

        _SectionHeader(l10n.settingsDangerZone, danger: true),
        _SettingsRow(
          title: l10n.settingsResetApp,
          subtitle: l10n.settingsResetAppDesc,
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

  void _showLanguagePicker(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.85,
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
              child: Text(l10n.settingsSelectLanguage,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _languages.length,
                itemBuilder: (context, i) {
                  final (code, name) = _languages[i];
                  final isSelected = code == settings.languageCode;
                  return ListTile(
                    title: Text(name),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () async {
                      await ref.read(settingsProvider.notifier).updateLanguage(code);
                      if (context.mounted) Navigator.pop(context);
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
              child: Text(context.l10n.settingsSelectCurrency,
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
        title: Text(context.l10n.settingsMonthStartOnDay),
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
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 32),
        title: Text(l10n.settingsResetTitle),
        content: Text(l10n.settingsResetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await _resetApp(context, ref);
            },
            child: Text(l10n.settingsResetConfirm),
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
    final l10n = ctx.l10n;
    showDialog(
      context: ctx,
      builder: (warnCtx) => AlertDialog(
        title: Text(l10n.settingsChangeStartDayTitle),
        content: Text(l10n.settingsChangeStartDayMessage(settings.monthStartDay, newDay)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(warnCtx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              _save(ref, settings.copyWith(monthStartDay: newDay));
              Navigator.pop(warnCtx);
              Navigator.pop(ctx);
            },
            child: Text(l10n.change),
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
          content: Text('Sign-in failed: ${e.toString()}'),
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
          case BackupCreated(:final createdAt):
            setState(() => _lastBackupTime = createdAt);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.settingsBackupSaved)),
              );
            }
          case BackupSkipped():
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.settingsBackupNoChanges)),
              );
            }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.settingsBackupFailed(e.toString())),
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
          content: Text(context.l10n.settingsListBackupsFailed(e.toString())),
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
        content: Text(context.l10n.settingsNoBackupFound),
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
            title: Text(context.l10n.settingsReplaceLocalTitle),
            content: Text(context.l10n.settingsReplaceLocalMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: cs.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.settingsReplaceMyData),
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
          SnackBar(content: Text(context.l10n.settingsDataRestored)),
        );
        if (widget.isModal) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.settingsRestoreFailed(e.toString())),
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
        title: Text(context.l10n.settingsSelectBackup),
        children: [
          ...backups.map(
            (b) => SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, b.id),
              child: Text(_formatBackupTimestamp(b.modifiedTime)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBackupTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final min = local.minute.toString().padLeft(2, '0');
    final amPm = local.hour < 12 ? 'AM' : 'PM';
    return '$day/$month/$year, $hour:$min $amPm';
  }

  String _formatBackupTime(DateTime dt) {
    final l10n = context.l10n;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.settingsJustNow;
    if (diff.inHours < 1) return l10n.settingsMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.settingsHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.yesterday;
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(googleAccountProvider);
    final cs = Theme.of(context).colorScheme;
    final anyBusy = _signingIn || _backingUp || _restoring || _loadingBackups;

    if (account == null) {
      return _SettingsRow(
        title: context.l10n.settingsGoogleSignIn,
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
        ? context.l10n.settingsLastBackup(_formatBackupTime(_lastBackupTime!))
        : context.l10n.settingsNoBackupYet;

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
                      child: Text(context.l10n.settingsSignOut,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
            ],
          ),
        ),
        _SettingsRow(
          title: context.l10n.settingsBackupToDrive,
          value: lastBackupLabel,
          busy: _backingUp,
          onTap: anyBusy ? null : _backup,
        ),
        _SettingsRow(
          title: context.l10n.settingsRestoreFromDrive,
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
      final savedName = await _svc.export();
      if (mounted && savedName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.settingsExportSuccess(savedName))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.settingsExportFailed(e.toString())),
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
      allowedExtensions: ['feloosybkp', 'json'],
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
            content: Text(context.l10n.settingsCannotReadFile(e.toString())),
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
        title: Text(context.l10n.settingsImportTitle),
        content: Text(context.l10n.settingsImportFound(summary.transactions, summary.budgets, summary.categories)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.settingsImportConfirm),
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
            content: Text(context.l10n.settingsImportDone(done.transactions)),
          ),
        );
        if (widget.isModal) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.settingsImportFailed(e.toString())),
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
    final signedIn = ref.watch(googleAccountProvider) != null;
    if (signedIn) return const SizedBox.shrink();

    final busy = _exporting || _importing;
    return Column(
      children: [
        _SettingsRow(
          title: context.l10n.settingsExportBackup,
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
          title: context.l10n.settingsRestoreFromFile,
          busy: _importing,
          onTap: busy ? null : _pickAndImport,
        ),
      ],
    );
  }
}

// ── SMS Toggle tile ───────────────────────────────────────────────────────────

class _SmsToggleTile extends ConsumerWidget {
  final bool isModal;
  const _SmsToggleTile({this.isModal = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final smsOptIn =
        ref.watch(settingsProvider).whenOrNull(data: (s) => s.smsOptIn) ??
            false;

    return SwitchListTile(
      title: Text(l10n.smsToggleLabel),
      subtitle: Text(l10n.smsToggleSubtitle),
      value: smsOptIn,
      onChanged: (enabled) async {
        if (enabled) {
          final accepted = await showDialog<bool>(
            context: context,
            builder: (_) => const _SmsTermsDialog(),
          );
          if (accepted == true) {
            await ref.read(settingsProvider.notifier).setSmsOptIn(true);
          }
        } else {
          await ref.read(settingsProvider.notifier).setSmsOptIn(false);
        }
      },
    );
  }
}

class _SmsTermsDialog extends StatelessWidget {
  const _SmsTermsDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.smsTermsTitle),
      content: Text(l10n.smsTermsBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.smsTermsEnable),
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
    final isPro =
        ref.read(purchaseProvider).asData?.value ?? AppFlavor.isDev;
    if (!isPro) {
      if (isModal) {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.push('/paywall');
        });
      } else {
        context.push('/paywall');
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
      title: context.l10n.settingsSmsRules,
      subtitle: context.l10n.settingsSmsRulesDesc,
      onTap: () => _navigate(context, ref),
    );
  }
}

// ── Appearance segmented control ──────────────────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  final AppSettings settings;
  const _AppearanceSection({required this.settings});

  // Labels resolved in build() from l10n
  static const _segmentValues = ['light', 'system', 'dark'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final current = settings.themeMode;

    final segments = [
      ('light', l10n.settingsThemeLight),
      ('system', l10n.settingsThemeAuto),
      ('dark', l10n.settingsThemeDark),
    ];

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
          children: segments.map((seg) {
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
