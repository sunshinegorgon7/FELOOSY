import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(String colorTheme) => switch (colorTheme) {
        'green3' => _green3Light,
        _ => _green2Light,
      };

  static ThemeData dark(String colorTheme) => switch (colorTheme) {
        'green3' => _green3Dark,
        _ => _green2Dark,
      };

  // ── Sage (green2) — muted 2-color ────────────────────────────────────────

  static final _green2Light = _build(
    brightness: Brightness.light,
    cs: const ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF4E7A58),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFC4D4C4),
      onPrimaryContainer: const Color(0xFF2C2C2C),
      secondary: const Color(0xFF7A9A80),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD8E8D8),
      onSecondaryContainer: const Color(0xFF2C2C2C),
      tertiary: const Color(0xFF8A9A7A),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFDCECD4),
      onTertiaryContainer: const Color(0xFF2C2C2C),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: const Color(0xFFF7F5F0),
      onSurface: const Color(0xFF2C2C2C),
      surfaceContainerLowest: const Color(0xFFFBFAF7),
      surfaceContainerLow: const Color(0xFFF2EFE9),
      surfaceContainer: const Color(0xFFEBE8E0),
      surfaceContainerHigh: const Color(0xFFE4E0D8),
      surfaceContainerHighest: const Color(0xFFDDDAD0),
      onSurfaceVariant: const Color(0xFF4A5A4A),
      outline: const Color(0xFF8A9E8A),
      outlineVariant: const Color(0xFFCCD8CC),
      inverseSurface: const Color(0xFF2C2C2C),
      onInverseSurface: const Color(0xFFF7F5F0),
      inversePrimary: const Color(0xFFC4D4C4),
      scrim: Colors.black,
      shadow: Colors.black,
    ),
    cardBorderColor: const Color(0xFFDDDAD0),
  );

  static final _green2Dark = _build(
    brightness: Brightness.dark,
    cs: const ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFC4D4C4),
      onPrimary: const Color(0xFF1A2E1A),
      primaryContainer: const Color(0xFF3B5C3B),
      onPrimaryContainer: const Color(0xFFD8ECD8),
      secondary: const Color(0xFF8EAA8E),
      onSecondary: const Color(0xFF1A2E1A),
      secondaryContainer: const Color(0xFF2E4A2E),
      onSecondaryContainer: const Color(0xFFC4D4C4),
      tertiary: const Color(0xFFA0B890),
      onTertiary: const Color(0xFF1A2E1A),
      tertiaryContainer: const Color(0xFF2A4030),
      onTertiaryContainer: const Color(0xFFC4D4C4),
      error: const Color(0xFFCF6679),
      onError: const Color(0xFF1A2E1A),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: const Color(0xFF1A2E1A),
      onSurface: const Color(0xFFC4D4C4),
      surfaceContainerLowest: const Color(0xFF142214),
      surfaceContainerLow: const Color(0xFF1E301E),
      surfaceContainer: const Color(0xFF263E26),
      surfaceContainerHigh: const Color(0xFF2E4C2E),
      surfaceContainerHighest: const Color(0xFF3B5C3B),
      onSurfaceVariant: const Color(0xFFA8C0A8),
      outline: const Color(0xFF5A7A5A),
      outlineVariant: const Color(0xFF2E4A2E),
      inverseSurface: const Color(0xFFC4D4C4),
      onInverseSurface: const Color(0xFF1A2E1A),
      inversePrimary: const Color(0xFF4E7A58),
      scrim: Colors.black,
      shadow: Colors.black,
    ),
    cardBorderColor: const Color(0xFF2E4A2E),
  );

  // ── Grove (green3) — vivid 3-color with accent ────────────────────────────

  static final _green3Light = _build(
    brightness: Brightness.light,
    cs: const ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF639922),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD4EAB0),
      onPrimaryContainer: const Color(0xFF2C2C2C),
      secondary: const Color(0xFF7A9A5A),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFC4D4C4),
      onSecondaryContainer: const Color(0xFF2C2C2C),
      tertiary: const Color(0xFF5A8A40),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFCCE4A8),
      onTertiaryContainer: const Color(0xFF2C2C2C),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: const Color(0xFFF4F7F1),
      onSurface: const Color(0xFF2C2C2C),
      surfaceContainerLowest: const Color(0xFFF8FAF6),
      surfaceContainerLow: const Color(0xFFECF1E7),
      surfaceContainer: const Color(0xFFE4EBDE),
      surfaceContainerHigh: const Color(0xFFDCE4D5),
      surfaceContainerHighest: const Color(0xFFC4D4C4),
      onSurfaceVariant: const Color(0xFF4A5E40),
      outline: const Color(0xFF7A9A5A),
      outlineVariant: const Color(0xFFBED4A4),
      inverseSurface: const Color(0xFF2C2C2C),
      onInverseSurface: const Color(0xFFF4F7F1),
      inversePrimary: const Color(0xFF97C459),
      scrim: Colors.black,
      shadow: Colors.black,
    ),
    cardBorderColor: const Color(0xFFDCE4D5),
  );

  static final _green3Dark = _build(
    brightness: Brightness.dark,
    cs: const ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF97C459),
      onPrimary: const Color(0xFF111C11),
      primaryContainer: const Color(0xFF1F3320),
      onPrimaryContainer: const Color(0xFFC0DD97),
      secondary: const Color(0xFF6A9A40),
      onSecondary: const Color(0xFF111C11),
      secondaryContainer: const Color(0xFF1F3320),
      onSecondaryContainer: const Color(0xFFC0DD97),
      tertiary: const Color(0xFF80B050),
      onTertiary: const Color(0xFF111C11),
      tertiaryContainer: const Color(0xFF1A2E18),
      onTertiaryContainer: const Color(0xFFC0DD97),
      error: const Color(0xFFCF6679),
      onError: const Color(0xFF111C11),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: const Color(0xFF111C11),
      onSurface: const Color(0xFFC0DD97),
      surfaceContainerLowest: const Color(0xFF0C150C),
      surfaceContainerLow: const Color(0xFF1F3320),
      surfaceContainer: const Color(0xFF2A4A2A),
      surfaceContainerHigh: const Color(0xFF355235),
      surfaceContainerHighest: const Color(0xFF3E5E3E),
      onSurfaceVariant: const Color(0xFFA0C870),
      outline: const Color(0xFF5A8A30),
      outlineVariant: const Color(0xFF2A4A2A),
      inverseSurface: const Color(0xFFC0DD97),
      onInverseSurface: const Color(0xFF111C11),
      inversePrimary: const Color(0xFF639922),
      scrim: Colors.black,
      shadow: Colors.black,
    ),
    cardBorderColor: const Color(0xFF2A4A2A),
  );

  // ── Builder ───────────────────────────────────────────────────────────────

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme cs,
    required Color cardBorderColor,
  }) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cardBorderColor),
          ),
        ),
      );
}
