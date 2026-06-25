import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ══════════════════════════════════════════════════════════════════════════
  // Inspiration palette
  // ══════════════════════════════════════════════════════════════════════════

  // Dark mode — Genesis Forest Green: deep, jewel-toned, premium forest
  static const Color genesisForest    = Color(0xFF0E2018); // rich surface lowest
  static const Color emeraldHighlight = Color(0xFF4CC490); // vivid emerald accent

  // Light mode — Hyundai N Ice Blue: crisp, sporty, crystalline
  static const Color nPerformanceBlue = Color(0xFF0065B5); // N performance blue
  static const Color iceWhite         = Color(0xFFEDF5FA); // ice background

  // Legacy name aliases kept for existing widget references
  static const Color forestGreen        = genesisForest;
  static const Color icePerformanceBlue = nPerformanceBlue;
  static const Color ghazelBlood        = Color(0xFFA8192D); // expense red
  static const Color royalBlue          = Color(0xFF1E4FA3); // kept for cat bars
  static const Color mossGreen          = Color(0xFF2C7848); // income green

  // ── Dark surface scale (Genesis Forest) ───────────────────────────────────
  static const Color darkPrimary        = Color(0xFF060D0A);
  static const Color darkSecondary      = Color(0xFF7AC4AE);
  static const Color darkBackground     = Color(0xFF060D0A);
  static const Color darkAccent         = emeraldHighlight;
  static const Color darkSurfaceLow     = Color(0xFF142B1D);
  static const Color darkSurface        = Color(0xFF1A3222);
  static const Color darkSurfaceHigh    = Color(0xFF203B28);
  static const Color darkSurfaceHighest = Color(0xFF274430);
  static const Color darkText           = Color(0xFFDAF0E7);
  static const Color darkMuted          = Color(0xFF7BAF93);

  // ── Light surface scale (Hyundai N Ice) ───────────────────────────────────
  static const Color lightPrimary        = nPerformanceBlue;
  static const Color lightSecondary      = Color(0xFF2D88BE);
  static const Color lightBackground     = iceWhite;
  static const Color lightAccent         = Color(0xFFCBE5F5);
  static const Color lightSurfaceLowest  = Color(0xFFF5FBFE);
  static const Color lightSurfaceLow     = Color(0xFFDEEFF8);
  static const Color lightSurfaceHigh    = Color(0xFFCBE5F5);
  static const Color lightText           = Color(0xFF071422);
  static const Color lightMuted          = Color(0xFF4A6E8A);
  static const Color lightOutline        = Color(0xFF6896B2);
  static const Color lightOutlineVariant = Color(0xFFB2D5EA);

  // ── Backward-compatible aliases (used by existing widgets) ─────────────────
  static const Color fern                = lightPrimary;
  static const Color washedSage          = lightSecondary;
  static const Color forestDeep          = lightAccent;
  static const Color mintMist            = lightBackground;
  static const Color mintLift            = lightSurfaceLowest;
  static const Color paleGrove           = lightSurfaceLow;
  static const Color paleGroveHigh       = lightSurfaceHigh;
  static const Color inkDeep             = lightText;
  static const Color groveShadow         = lightMuted;
  static const Color groveOutline        = lightOutline;
  static const Color groveOutlineVariant = lightOutlineVariant;

  static const Color iceGlow             = darkAccent;
  static const Color deepNimbus          = darkBackground;
  static const Color nimbusLowest        = genesisForest;
  static const Color nimbusSurface       = darkSurfaceLow;
  static const Color nimbusMid           = darkSurface;
  static const Color nimbusHigh          = darkSurfaceHigh;
  static const Color nimbusHighest       = darkSurfaceHighest;
  static const Color mistText            = darkText;
  static const Color mistVariant         = darkMuted;

  // ── Semantic colors ───────────────────────────────────────────────────────
  static const Color ledgerRed        = ghazelBlood;
  static const Color ledgerGreen      = mossGreen;
  static const Color amberMark        = Color(0xFFB07A1A);
  static const Color destructiveColor = Color(0xFFB01C2E);
  static const Color expenseColor     = ledgerRed;
  static const Color incomeColor      = ledgerGreen;
  static const Color warningColor     = amberMark;

  // Text-safe semantic variants for small text on tinted surfaces
  static const Color fernText            = lightPrimary;
  static const Color iceGlowText         = darkAccent;
  static const Color ledgerRedText       = Color(0xFF9B1424);
  static const Color ledgerRedTextDark   = Color(0xFFFF8090);
  static const Color ledgerGreenText     = Color(0xFF1E6038);
  static const Color ledgerGreenTextDark = Color(0xFF72D4A0);
  static const Color amberText           = Color(0xFF7D5012);

  static final ThemeData dark  = _buildDark();
  static final ThemeData light = _buildLight();

  static ThemeMode resolveMode(String stored) => switch (stored) {
        'light' => ThemeMode.light,
        'dark'  => ThemeMode.dark,
        _       => ThemeMode.system,
      };

  static Color primaryText(ColorScheme cs) =>
      cs.brightness == Brightness.dark ? iceGlowText : fernText;

  static Color expenseText(ColorScheme cs) =>
      cs.brightness == Brightness.dark ? ledgerRedTextDark : ledgerRedText;

  static Color incomeText(ColorScheme cs) =>
      cs.brightness == Brightness.dark ? ledgerGreenTextDark : ledgerGreenText;

  static Color warningText(ColorScheme cs) =>
      cs.brightness == Brightness.dark ? amberMark : amberText;

  static Color readableOn(Color background) =>
      background.computeLuminance() > 0.45 ? lightText : lightBackground;

  // Single source of truth for how a category's colour is rendered across the
  // app — home screen (group headers + expanded transactions), Manage Categories,
  // add-transaction, SMS screens, and the home widget all go through this so the
  // result is identical everywhere. The category's own colour is authoritative;
  // a subtle nudge only lightens very dark picks in dark mode (and darkens very
  // light picks in light mode) so the icon stays legible. For typical mid-tone
  // colours this is a no-op, so the colour shown matches the colour picked.
  // `uuid` is retained for call-site compatibility but does not affect output.
  static Color categoryBarColor({
    required String uuid,
    required int colorValue,
    required ColorScheme colorScheme,
  }) {
    final base = Color(colorValue);
    final luminance = base.computeLuminance();
    if (colorScheme.brightness == Brightness.dark && luminance < 0.30) {
      return Color.lerp(base, const Color(0xFFDDDDDD), 0.36)!;
    }
    if (colorScheme.brightness == Brightness.light && luminance > 0.70) {
      return Color.lerp(base, const Color(0xFF222222), 0.22)!;
    }
    return base;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Theme builders
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData _buildDark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        surfaceTint: Colors.transparent,
        // Emerald as the primary interactive color — FABs, buttons, selection
        primary: emeraldHighlight,
        onPrimary: Color(0xFF031A0C),
        primaryContainer: darkSurfaceHigh,
        onPrimaryContainer: Color(0xFFAEECD0),
        secondary: darkSecondary,
        onSecondary: Color(0xFF062819),
        secondaryContainer: Color(0xFF0C2A22),
        onSecondaryContainer: Color(0xFFC4EAE0),
        tertiary: Color(0xFF72D4A0),
        onTertiary: Color(0xFF042215),
        tertiaryContainer: Color(0xFF0C2A1E),
        onTertiaryContainer: Color(0xFFC0EAD4),
        error: Color(0xFFFF6B7A),
        onError: Color(0xFF4A0010),
        errorContainer: Color(0xFF5A0E1C),
        onErrorContainer: Color(0xFFFFDADC),
        // Surface layering — deepest forest to elevated surfaces
        surface: darkBackground,
        onSurface: darkText,
        surfaceContainerLowest: genesisForest,    // rich forest green lowest
        surfaceContainerLow: darkSurfaceLow,
        surfaceContainer: darkSurface,
        surfaceContainerHigh: darkSurfaceHigh,
        surfaceContainerHighest: darkSurfaceHighest,
        onSurfaceVariant: darkMuted,
        outline: Color(0xFF3D6050),
        outlineVariant: darkSurfaceHighest,
        inverseSurface: lightSurfaceLow,
        onInverseSurface: lightText,
        inversePrimary: nPerformanceBlue,
        scrim: Color(0xFF000000),
        shadow: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: darkBackground,
      canvasColor: darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkBackground,
        foregroundColor: darkText,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: darkSurfaceLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: darkSurfaceHighest),
        ),
      ),
      textTheme: GoogleFonts.geistTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
    );
  }

  static ThemeData _buildLight() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        surfaceTint: Colors.transparent,
        // N Performance Blue as the primary interactive color
        primary: lightPrimary,
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: lightSurfaceHigh,
        onPrimaryContainer: Color(0xFF003570),
        secondary: lightSecondary,
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFCCE8F5),
        onSecondaryContainer: Color(0xFF0C3D60),
        tertiary: Color(0xFF1E7A45),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFC4EBD5),
        onTertiaryContainer: Color(0xFF083D20),
        error: destructiveColor,
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDADE),
        onErrorContainer: Color(0xFF6E0010),
        // Surface layering — ice-white atmosphere
        surface: lightBackground,
        onSurface: lightText,
        surfaceContainerLowest: lightSurfaceLowest,
        surfaceContainerLow: lightSurfaceLow,
        surfaceContainer: lightSurfaceLow,
        surfaceContainerHigh: lightSurfaceHigh,
        surfaceContainerHighest: lightSurfaceHigh,
        onSurfaceVariant: lightMuted,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
        inverseSurface: genesisForest,
        onInverseSurface: lightSurfaceLow,
        inversePrimary: emeraldHighlight,
        scrim: Color(0xFF000000),
        shadow: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: lightBackground,
      canvasColor: lightBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: lightBackground,
        foregroundColor: lightText,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: lightSurfaceLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: lightOutlineVariant),
        ),
      ),
      textTheme: GoogleFonts.geistTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: lightText,
        displayColor: lightText,
      ),
    );
  }
}
