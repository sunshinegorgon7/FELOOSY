import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'app_flavor.dart';
import 'app_theme.dart';
import 'router.dart';

class FeloosyApp extends ConsumerWidget {
  const FeloosyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull;
    final themeMode = switch (settings?.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final colorTheme = settings?.colorTheme ?? 'green2';

    return MaterialApp.router(
      title: 'FELOOSY',
      debugShowCheckedModeBanner: !AppFlavor.isProd,
      theme: AppTheme.light(colorTheme),
      darkTheme: AppTheme.dark(colorTheme),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
