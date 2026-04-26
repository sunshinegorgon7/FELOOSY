import 'package:flutter/material.dart';

class AppTheme {
  // Single fixed theme — no user selection.
  // Light: Mint Mist bg · Almost Aqua surface · Fern accent · near-black text
  // Dark:  Deep Nimbus bg · Nimbus Surface · Ice Glow accent · muted-blue text

  static final ThemeData light = _build(
    brightness: Brightness.light,
    cs: const ColorScheme(
      brightness: Brightness.light,
      // Fern — primary actions, FAB, selected states
      primary: Color(0xFF639922),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD4EAB0),
      onPrimaryContainer: Color(0xFF2C2C2C),
      // Almost Aqua — secondary / chips
      secondary: Color(0xFF7A9A7A),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFC4D4C4),
      onSecondaryContainer: Color(0xFF2C2C2C),
      tertiary: Color(0xFF5A8A40),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFCCE4A8),
      onTertiaryContainer: Color(0xFF2C2C2C),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      // Mint Mist — main surface / background
      surface: Color(0xFFF4F7F1),
      onSurface: Color(0xFF2C2C2C),
      surfaceContainerLowest: Color(0xFFF8FAF6),
      surfaceContainerLow: Color(0xFFECF1E7),
      surfaceContainer: Color(0xFFE4EBDE),
      // Almost Aqua tint — elevated containers, input fills
      surfaceContainerHigh: Color(0xFFDCE4D5),
      surfaceContainerHighest: Color(0xFFC4D4C4),
      onSurfaceVariant: Color(0xFF4A5E40),
      outline: Color(0xFF7A9A5A),
      outlineVariant: Color(0xFFBED4A4),
      inverseSurface: Color(0xFF2C2C2C),
      onInverseSurface: Color(0xFFF4F7F1),
      inversePrimary: Color(0xFF97C459),
      scrim: Colors.black,
      shadow: Colors.black,
    ),
    cardColor: const Color(0xFFC4D4C4),      // Almost Aqua
    cardBorderColor: const Color(0xFFB8CABC),
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    cs: const ColorScheme(
      brightness: Brightness.dark,
      // Ice Glow — primary actions
      primary: Color(0xFF4D7FA8),
      onPrimary: Color(0xFF111922),
      primaryContainer: Color(0xFF1E2E3D),
      onPrimaryContainer: Color(0xFFC4D0DC),
      secondary: Color(0xFF5A8FAA),
      onSecondary: Color(0xFF111922),
      secondaryContainer: Color(0xFF1E2E3D),
      onSecondaryContainer: Color(0xFFC4D0DC),
      tertiary: Color(0xFF6A9FBA),
      onTertiary: Color(0xFF111922),
      tertiaryContainer: Color(0xFF1A2A38),
      onTertiaryContainer: Color(0xFFC4D0DC),
      error: Color(0xFFCF6679),
      onError: Color(0xFF111922),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      // Deep Nimbus — main background
      surface: Color(0xFF111922),
      onSurface: Color(0xFFC4D0DC),
      surfaceContainerLowest: Color(0xFF0C1318),
      // Nimbus Surface — cards, nav
      surfaceContainerLow: Color(0xFF1E2E3D),
      surfaceContainer: Color(0xFF243547),
      surfaceContainerHigh: Color(0xFF2A3D52),
      surfaceContainerHighest: Color(0xFF30455C),
      onSurfaceVariant: Color(0xFF9AB0C4),
      outline: Color(0xFF4D7FA8),
      outlineVariant: Color(0xFF1E2E3D),
      inverseSurface: Color(0xFFC4D0DC),
      onInverseSurface: Color(0xFF111922),
      inversePrimary: Color(0xFF639922),
      scrim: Colors.black,
      shadow: Colors.black,
    ),
    cardColor: const Color(0xFF1E2E3D),      // Nimbus Surface
    cardBorderColor: const Color(0xFF2A3D52),
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme cs,
    required Color cardColor,
    required Color cardBorderColor,
  }) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        scaffoldBackgroundColor: cs.surface,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: cs.surface,
          foregroundColor: cs.onSurface,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cardBorderColor),
          ),
        ),
      );
}
