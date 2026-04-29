import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_provider.dart';
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

class _FeloosyAppState extends ConsumerState<FeloosyApp> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => syncBalanceHomeWidget(ref));
    ref.listenManual(accountsProvider, (_, __) => syncBalanceHomeWidget(ref));
    ref.listenManual(transactionsProvider, (_, __) => syncBalanceHomeWidget(ref));
    ref.listenManual(currentBudgetProvider, (_, __) => syncBalanceHomeWidget(ref));
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
