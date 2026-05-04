import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/drive_backup_provider.dart';
import '../providers/google_auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transactions_provider.dart';
import '../services/home_widget_sync_service.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(() => syncBalanceHomeWidget(ref));
    ref.listenManual(accountsProvider, (_, _) => syncBalanceHomeWidget(ref));
    ref.listenManual(transactionsProvider, (_, _) => syncBalanceHomeWidget(ref));
    ref.listenManual(currentBudgetProvider, (_, _) => syncBalanceHomeWidget(ref));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        ref.read(googleAccountProvider) != null) {
      ref.read(googleDriveBackupProvider).backup().ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = switch (settingsAsync.value?.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'FELOOSY',
      debugShowCheckedModeBanner: !AppFlavor.isProd,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
