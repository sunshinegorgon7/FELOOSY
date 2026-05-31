import 'dart:async';

import 'package:flutter/material.dart';
import 'package:feloosy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dev/seed_snapshot_service.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/database_provider.dart';
import '../providers/drive_backup_provider.dart';
import '../providers/google_auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transactions_provider.dart';
import '../services/home_widget_sync_service.dart';
import '../services/recurring_transaction_service.dart';
import '../services/sms_transaction_service.dart';
import 'app_flavor.dart';
import 'app_theme.dart';
import 'router.dart';

class FeloosyApp extends ConsumerStatefulWidget {
  const FeloosyApp({super.key});

  @override
  ConsumerState<FeloosyApp> createState() => _FeloosyAppState();
}

class _FeloosyAppState extends ConsumerState<FeloosyApp>
    with WidgetsBindingObserver {
  Timer? _widgetSyncDebounce;
  final _smsService = SmsTransactionService();

  void _scheduleWidgetSync() {
    _widgetSyncDebounce?.cancel();
    _widgetSyncDebounce = Timer(
      const Duration(milliseconds: 400),
      () => syncWidget(ref),
    );
  }

  Future<void> _generateRecurring() async {
    try {
      await RecurringTransactionService.generatePending(
        txRepo: ref.read(transactionRepositoryProvider),
        ruleRepo: ref.read(recurringRuleRepositoryProvider),
      );
      ref.invalidate(transactionsProvider);
    } catch (e) {
      debugPrint('RecurringTransactionService error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(_scheduleWidgetSync);
    Future<void>.microtask(_generateRecurring);
    ref.listenManual(accountsProvider, (_, _) => _scheduleWidgetSync());
    ref.listenManual(transactionsProvider, (_, _) => _scheduleWidgetSync());
    ref.listenManual(currentBudgetProvider, (_, _) => _scheduleWidgetSync());
    ref.listenManual(settingsProvider, (_, _) => _scheduleWidgetSync());
    _smsService.start(ref);
  }

  @override
  void dispose() {
    _widgetSyncDebounce?.cancel();
    _smsService.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleWidgetSync();
      _generateRecurring();
    }
    if (state == AppLifecycleState.paused &&
        ref.read(googleAccountProvider) != null) {
      ref.read(googleDriveBackupProvider).backup(silent: true).ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = settingsAsync.maybeWhen(
      data: (s) => AppTheme.resolveMode(s.themeMode),
      orElse: () => ThemeMode.system,
    );
    final locale = settingsAsync.maybeWhen(
      data: (s) => s.languageCode.isEmpty ? null : Locale(s.languageCode),
      orElse: () => null,
    );

    final snapshotActive = AppFlavor.isDev
        ? (ref.watch(snapshotModeProvider).value ?? false)
        : false;

    return MaterialApp.router(
      title: 'FELOOSY',
      debugShowCheckedModeBanner: !AppFlavor.isProd,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: AppFlavor.isDev && snapshotActive
          ? (context, child) => Column(
                children: [
                  const _SnapshotBanner(),
                  Expanded(child: child!),
                ],
              )
          : null,
    );
  }
}

class _SnapshotBanner extends ConsumerWidget {
  const _SnapshotBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.paddingOf(context).top;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: top > 0 ? 0 : 4, bottom: 4, left: 16, right: 8),
          child: Row(
            children: [
              Icon(Icons.science_outlined, size: 14, color: cs.onPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'SNAPSHOT MODE — edits are temporary',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => SeedSnapshotService.exitSnapshot(ref),
                style: TextButton.styleFrom(
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
