import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Forest dark palette ────────────────────────────────────────────────────
  static const Color forest  = Color(0xFF0D2818);
  static const Color forest2 = Color(0xFF143A23);
  static const Color forest3 = Color(0xFF1C4A2E);
  static const Color amber   = Color(0xFFF5A623);
  static const Color amber2  = Color(0xFFE08A10);
  static const Color cream   = Color(0xFFF6F1E3);
  static const Color muted   = Color(0xFF7FA890);
  static const Color muted2  = Color(0xFF5A7D6A);
  static const Color border  = Color(0x14F6F1E3); // rgba(246,241,227,0.08)
  static const Color income  = Color(0xFF4ADE80);

  // ── Semantic colors ────────────────────────────────────────────────────────
  static const Color expenseColor     = amber;
  static const Color incomeColor      = income;
  static const Color warningColor     = amber2;
  static const Color destructiveColor = Color(0xFFC44A4A);

  // ── Single dark theme ──────────────────────────────────────────────────────
  static final ThemeData dark = _build();

  static ThemeData _build() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        surfaceTint: Colors.transparent,
        primary: amber,
        onPrimary: forest,
        primaryContainer: Color(0xFF3A2000),
        onPrimaryContainer: cream,
        secondary: muted,
        onSecondary: forest,
        secondaryContainer: forest2,
        onSecondaryContainer: cream,
        tertiary: income,
        onTertiary: forest,
        tertiaryContainer: forest2,
        onTertiaryContainer: cream,
        error: destructiveColor,
        onError: cream,
        errorContainer: Color(0xFF4A1515),
        onErrorContainer: Color(0xFFFFB4AB),
        surface: forest,
        onSurface: cream,
        surfaceContainerLowest: Color(0xFF081610),
        surfaceContainerLow: forest2,
        surfaceContainer: forest2,
        surfaceContainerHigh: forest3,
        surfaceContainerHighest: forest3,
        onSurfaceVariant: muted,
        outline: muted2,
        outlineVariant: border,
        inverseSurface: cream,
        onInverseSurface: forest,
        inversePrimary: amber2,
        scrim: Colors.black,
        shadow: Colors.black,
      ),
      scaffoldBackgroundColor: forest,
      canvasColor: forest,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: forest,
        foregroundColor: cream,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: forest2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: border),
        ),
      ),
      textTheme: GoogleFonts.geistTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: cream,
        displayColor: cream,
      ),
    );
  }
}
