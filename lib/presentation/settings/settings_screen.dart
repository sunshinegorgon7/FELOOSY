import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_info.dart';
import '../../core/constants/currencies.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/app_settings.dart';
import '../../domain/services/local_export_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/firebase_sync_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';
import 'feedback_sheet.dart';

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
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.push('/categories');
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
      children: [
        // ── Appearance ──────────────────────────────────────────────────
        const _SectionHeader('Appearance'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Brightness', style: tt.bodyMedium),
              const Gap(10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'light',
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: 'system',
                    icon: Icon(Icons.brightness_auto_outlined),
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: 'dark',
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark'),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) =>
                    _save(ref, settings.copyWith(themeMode: s.first)),
              ),
            ],
          ),
        ),

        // ── Budget ───────────────────────────────────────────────────────
        const _SectionHeader('Budget'),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('Currency'),
          subtitle: Text(
              '${settings.currencySymbol} — ${_currencyName(settings.currencyCode)}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCurrencyPicker(context, ref, settings),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('Month starts on'),
          subtitle: Text(
              'Day ${settings.monthStartDay}${_ordinal(settings.monthStartDay)} of each month'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDayPicker(context, ref, settings),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Day 29–31 not available to ensure February compatibility.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.wallet_outlined),
          title: const Text('Default monthly budget'),
          subtitle: Text(
            settings.defaultMonthlyBudget > 0
                ? '${settings.currencySymbol} ${settings.defaultMonthlyBudget.toStringAsFixed(2)}'
                : 'Not set — tap to configure',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showDefaultBudgetDialog(context, ref, settings),
        ),

        // ── Categories ───────────────────────────────────────────────────
        const _SectionHeader('Categories'),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: const Text('Manage categories'),
          subtitle: const Text('Edit, add or hide spending categories'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateCategories(context),
        ),

        // ── Wallets ──────────────────────────────────────────────────────
        const _SectionHeader('Wallets'),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Manage wallets'),
          subtitle: const Text('Add, edit, delete wallets and set favorite'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/accounts'),
        ),
        _AccountTile(isModal: isModal),

        // ── Data ─────────────────────────────────────────────────────────
        const _SectionHeader('Data'),
        _LocalBackupTile(isModal: isModal),

        // ── About ────────────────────────────────────────────────────────
        const _SectionHeader('About'),
        ListTile(
          leading: const Icon(Icons.chat_bubble_outline),
          title: const Text('Send feedback'),
          subtitle: const Text('Share a bug, idea, or question'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final sent = await showFeedbackSheet(context);
            if (sent == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thanks - your feedback was sent.'),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('App version'),
          trailing: Text(
            kAppVersionLabel,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),

        // ── Danger zone ──────────────────────────────────────────────────
        const _SectionHeader('Danger Zone'),
        ListTile(
          leading: Icon(Icons.delete_forever_outlined, color: cs.error),
          title: Text('Reset app',
              style: TextStyle(color: cs.error, fontWeight: FontWeight.w500)),
          subtitle: const Text(
              'Erase all transactions & budgets, restore default settings'),
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
                color: Colors.grey.shade300,
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
                        color: isSelected ? Colors.white : null,
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
          'Settings will be restored to defaults.\n\n'
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

// ── Account tile ─────────────────────────────────────────────────────────────

class _AccountTile extends ConsumerStatefulWidget {
  final bool isModal;
  const _AccountTile({this.isModal = false});

  @override
  ConsumerState<_AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends ConsumerState<_AccountTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;

    if (user != null) {
      return ListTile(
        leading: user.photoURL != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
                radius: 18,
              )
            : const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person_outline, size: 18),
              ),
        title: Text(user.displayName ?? 'Signed in',
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(user.email ?? '',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        trailing: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: _signOut,
                child: const Text('Sign out'),
              ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.account_circle_outlined),
      title: const Text('Sign in with Google'),
      subtitle: const Text('Sync your data across devices'),
      trailing: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: _busy ? null : _signIn,
    );
  }

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      final user = await ref.read(googleAuthActionsProvider).signIn();
      if (user != null && mounted) {
        await ref.read(syncOrchestratorProvider).onSignIn(user.uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    try {
      await ref.read(googleAuthActionsProvider).signOut();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;

    // Parse to get preview counts before asking confirmation
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

    // Confirmation dialog
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
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Export backup'),
          subtitle: const Text('Save all data as a JSON file'),
          trailing: _exporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: busy ? null : _export,
        ),
        ListTile(
          leading: const Icon(Icons.upload_outlined),
          title: const Text('Import backup'),
          subtitle: const Text('Restore from a previously exported file'),
          trailing: _importing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: busy ? null : _pickAndImport,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
