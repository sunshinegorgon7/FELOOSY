import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/currencies.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/app_settings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/firebase_sync_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transactions_provider.dart';

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
              Text('Color theme', style: tt.bodyMedium),
              const Gap(10),
              Row(
                children: [
                  _ColorThemeCard(
                    label: 'Sage',
                    themeKey: 'green2',
                    lightSwatches: const [
                      Color(0xFFF7F5F0),
                      Color(0xFFC4D4C4),
                      Color(0xFF4E7A58),
                    ],
                    darkSwatches: const [
                      Color(0xFF1A2E1A),
                      Color(0xFF3B5C3B),
                      Color(0xFFC4D4C4),
                    ],
                    isSelected: settings.colorTheme == 'green2',
                    onTap: () =>
                        _save(ref, settings.copyWith(colorTheme: 'green2')),
                  ),
                  const Gap(12),
                  _ColorThemeCard(
                    label: 'Grove',
                    themeKey: 'green3',
                    lightSwatches: const [
                      Color(0xFFF4F7F1),
                      Color(0xFFC4D4C4),
                      Color(0xFF639922),
                    ],
                    darkSwatches: const [
                      Color(0xFF111C11),
                      Color(0xFF1F3320),
                      Color(0xFF97C459),
                    ],
                    isSelected: settings.colorTheme == 'green3',
                    onTap: () =>
                        _save(ref, settings.copyWith(colorTheme: 'green3')),
                  ),
                ],
              ),
              const Gap(16),
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

        // ── Account (Firebase) ───────────────────────────────────────────
        const _SectionHeader('Account'),
        _AccountTile(isModal: isModal),

        // ── About ────────────────────────────────────────────────────────
        const _SectionHeader('About'),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snap) {
            final version = snap.hasData
                ? '${snap.data!.version} (${snap.data!.buildNumber})'
                : '—';
            return ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App version'),
              trailing: Text(version,
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            );
          },
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
      final user =
          await ref.read(googleAuthActionsProvider).signIn();
      if (user != null && mounted) {
        await ref
            .read(syncOrchestratorProvider)
            .onSignIn(user.uid);
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

// ── Color theme card ──────────────────────────────────────────────────────────

class _ColorThemeCard extends StatelessWidget {
  final String label;
  final String themeKey;
  final List<Color> lightSwatches;
  final List<Color> darkSwatches;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorThemeCard({
    required this.label,
    required this.themeKey,
    required this.lightSwatches,
    required this.darkSwatches,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final swatches = isDark ? darkSwatches : lightSwatches;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? cs.primary.withValues(alpha: 0.08)
                : cs.surfaceContainerLow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (int i = 0; i < swatches.length; i++) ...[
                    if (i > 0) const Gap(4),
                    _Swatch(color: swatches[i]),
                  ],
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: cs.primary),
                ],
              ),
              const Gap(8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
