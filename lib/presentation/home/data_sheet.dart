import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../app/app_theme.dart';
import '../../core/extensions/localizations_extension.dart';
import '../../data/database/database_helper.dart';
import '../../domain/services/google_drive_backup_service.dart';
import '../../domain/services/local_export_service.dart';
import '../../providers/access_tier_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/drive_backup_provider.dart';
import '../../providers/google_auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';

void showDataSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (ctx, scrollController) =>
          _DataSheet(scrollController: scrollController),
    ),
  );
}

class _DataSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const _DataSheet({required this.scrollController});

  @override
  ConsumerState<_DataSheet> createState() => _DataSheetState();
}

class _DataSheetState extends ConsumerState<_DataSheet> {
  bool _signingIn = false;
  bool _backingUp = false;
  bool _restoring = false;
  bool _loadingBackups = false;
  DateTime? _lastBackupTime;
  bool _exporting = false;
  bool _importing = false;

  final _localSvc = LocalExportService(DatabaseHelper.instance);

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

  // ── Google Drive actions ──────────────────────────────────────────────────

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
                SnackBar(
                    content: Text(context.l10n.settingsBackupNoChanges)),
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

    final String selectedId;
    if (backups.length == 1) {
      selectedId = backups.first.id;
    } else {
      final picked = await _pickBackup(backups);
      if (picked == null || !mounted) return;
      selectedId = picked;
    }

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

    setState(() => _restoring = true);
    try {
      await svc.restore(selectedId);
      _invalidateAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.settingsDataRestored)),
        );
        Navigator.of(context).pop();
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
              style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  // ── Local export/import actions ───────────────────────────────────────────

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final savedName = await _localSvc.export();
      if (mounted && savedName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.l10n.settingsExportSuccess(savedName))),
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
      summary = await _localSvc.preview(path);
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
        content: Text(context.l10n.settingsImportFound(
            summary.transactions, summary.budgets, summary.categories)),
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
      final done = await _localSvc.commit(path);
      _invalidateAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.settingsImportDone(done.transactions)),
          ),
        );
        Navigator.of(context).pop();
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _invalidateAll() {
    ref.invalidate(transactionsProvider);
    ref.invalidate(transactionPeriodOffsetsProvider);
    ref.invalidate(currentBudgetProvider);
    ref.invalidate(settingsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(accountsProvider);
  }

  void _navigateToPaywall() {
    Navigator.of(context).pop();
    context.push('/paywall');
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(googleAccountProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final anyDriveBusy =
        _signingIn || _backingUp || _restoring || _loadingBackups;
    final anyLocalBusy = _exporting || _importing;

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Text(
            l10n.cloudData,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 24),

        // ── Google Drive section ──────────────────────────────────────────
        _SheetSectionHeader(l10n.cloudGoogleDrive),

        if (account == null)
          _SheetActionRow(
            icon: LucideIcons.logIn,
            title: l10n.cloudSignInWithGoogle,
            busy: _signingIn,
            onTap: anyDriveBusy
                ? null
                : () {
                    if (!ref.read(accessTierProvider).canBackup) {
                      _navigateToPaywall();
                      return;
                    }
                    _signIn();
                  },
          )
        else ...[
          // User info row
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
                    style:
                        tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _signingIn
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: anyDriveBusy ? null : _signOut,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryText(cs),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(l10n.settingsSignOut,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
              ],
            ),
          ),
          _SheetActionRow(
            icon: LucideIcons.uploadCloud,
            title: l10n.settingsBackupToDrive,
            subtitle: _lastBackupTime != null
                ? l10n.settingsLastBackup(
                    _formatBackupTime(_lastBackupTime!))
                : l10n.settingsNoBackupYet,
            busy: _backingUp,
            onTap: anyDriveBusy ? null : _backup,
          ),
          _SheetActionRow(
            icon: LucideIcons.downloadCloud,
            title: l10n.settingsRestoreFromDrive,
            busy: _restoring || _loadingBackups,
            onTap: anyDriveBusy ? null : _restore,
          ),
        ],

        // ── Local section ─────────────────────────────────────────────────
        _SheetSectionHeader(l10n.cloudLocal),
        _SheetActionRow(
          icon: LucideIcons.fileOutput,
          title: l10n.settingsExportBackup,
          busy: _exporting,
          onTap: anyLocalBusy
              ? null
              : () {
                  if (!ref.read(accessTierProvider).canExport) {
                    _navigateToPaywall();
                    return;
                  }
                  _export();
                },
        ),
        _SheetActionRow(
          icon: LucideIcons.fileInput,
          title: l10n.settingsRestoreFromFile,
          busy: _importing,
          onTap: anyLocalBusy ? null : _pickAndImport,
        ),
      ],
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

class _SheetSectionHeader extends StatelessWidget {
  final String title;
  const _SheetSectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 2),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryText(cs),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.10 * 11,
            ),
      ),
    );
  }
}

class _SheetActionRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool busy;
  final VoidCallback? onTap;

  const _SheetActionRow({
    this.icon,
    required this.title,
    this.subtitle,
    this.busy = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          subtitle != null ? 11 : 13,
          16,
          subtitle != null ? 11 : 13,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: tt.bodyMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style:
                          tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
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
                color: cs.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
