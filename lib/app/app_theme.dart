import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Grove palette, light theme.
  static const Color fern = Color(0xFF639922);
  static const Color washedSage = Color(0xFF7A9A7A);
  static const Color forestDeep = Color(0xFF5A8A40);
  static const Color mintMist = Color(0xFFF4F7F1);
  static const Color mintLift = Color(0xFFFAFCF7);
  static const Color paleGrove = Color(0xFFE4EBDE);
  static const Color paleGroveHigh = Color(0xFFC4D4C4);
  static const Color inkDeep = Color(0xFF2C2C2C);
  static const Color groveShadow = Color(0xFF4A5E40);
  static const Color groveOutline = Color(0xFF7A9A5A);
  static const Color groveOutlineVariant = Color(0xFFBED4A4);

  // Nimbus palette, dark theme.
  static const Color iceGlow = Color(0xFF4D7FA8);
  static const Color deepNimbus = Color(0xFF111922);
  static const Color nimbusLowest = Color(0xFF060C11);
  static const Color nimbusSurface = Color(0xFF1E2E3D);
  static const Color nimbusMid = Color(0xFF243547);
  static const Color nimbusHigh = Color(0xFF2A3D52);
  static const Color nimbusHighest = Color(0xFF30455C);
  static const Color mistText = Color(0xFFC4D0DC);
  static const Color mistVariant = Color(0xFF9AB0C4);

  // Semantic colors.
  static const Color ledgerRed = Color(0xFFD64545);
  static const Color ledgerGreen = Color(0xFF4A9955);
  static const Color amberMark = Color(0xFFCC8830);
  static const Color destructiveColor = Color(0xFFC73535);

  // Text-safe variants for small semantic text on tinted surfaces.
  static const Color fernText = Color(0xFF3F6329);
  static const Color iceGlowText = Color(0xFF7AAECF);
  static const Color ledgerRedText = Color(0xFFB23636);
  static const Color ledgerRedTextDark = Color(0xFFF07171);
  static const Color ledgerGreenText = Color(0xFF2F7139);
  static const Color ledgerGreenTextDark = Color(0xFF72B879);
  static const Color amberText = Color(0xFF8F5F22);

  static const Color expenseColor = ledgerRed;
  static const Color incomeColor = ledgerGreen;
  static const Color warningColor = amberMark;

  static final ThemeData dark = _buildDark();
  static final ThemeData light = _buildLight();

  static ThemeMode resolveMode(String stored) => switch (stored) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
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
      background.computeLuminance() > 0.45 ? inkDeep : mintMist;

  static ThemeData _buildDark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        surfaceTint: Colors.transparent,
        primary: iceGlow,
        onPrimary: nimbusLowest,
        primaryContainer: nimbusHigh,
        onPrimaryContainer: iceGlowText,
        secondary: mistVariant,
        onSecondary: nimbusLowest,
        secondaryContainer: nimbusMid,
        onSecondaryContainer: mistText,
        tertiary: ledgerGreen,
        onTertiary: nimbusLowest,
        tertiaryContainer: nimbusMid,
        onTertiaryContainer: ledgerGreenTextDark,
        error: destructiveColor,
        onError: mintMist,
        errorContainer: Color(0xFF5C1A1A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: deepNimbus,
        onSurface: mistText,
        surfaceContainerLowest: nimbusLowest,
        surfaceContainerLow: nimbusSurface,
        surfaceContainer: nimbusSurface,
        surfaceContainerHigh: nimbusMid,
        surfaceContainerHighest: nimbusHigh,
        onSurfaceVariant: mistVariant,
        outline: nimbusHighest,
        outlineVariant: nimbusHigh,
        inverseSurface: mintMist,
        onInverseSurface: deepNimbus,
        inversePrimary: fern,
        scrim: nimbusLowest,
        shadow: nimbusLowest,
      ),
      scaffoldBackgroundColor: deepNimbus,
      canvasColor: deepNimbus,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: deepNimbus,
        foregroundColor: mistText,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: nimbusSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: nimbusHigh),
        ),
      ),
      textTheme: GoogleFonts.geistTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: mistText,
        displayColor: mistText,
      ),
    );
  }

  static ThemeData _buildLight() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        surfaceTint: Colors.transparent,
        primary: fern,
        onPrimary: Color(0xFF162008),
        primaryContainer: paleGroveHigh,
        onPrimaryContainer: fernText,
        secondary: washedSage,
        onSecondary: Color(0xFF162008),
        secondaryContainer: paleGrove,
        onSecondaryContainer: inkDeep,
        tertiary: ledgerGreen,
        onTertiary: Color(0xFF162008),
        tertiaryContainer: Color(0xFFE5F2E7),
        onTertiaryContainer: ledgerGreenText,
        error: destructiveColor,
        onError: mintMist,
        errorContainer: Color(0xFFF9DEDC),
        onErrorContainer: Color(0xFF8C1D18),
        surface: mintMist,
        onSurface: inkDeep,
        surfaceContainerLowest: mintLift,
        surfaceContainerLow: paleGrove,
        surfaceContainer: paleGrove,
        surfaceContainerHigh: paleGroveHigh,
        surfaceContainerHighest: paleGroveHigh,
        onSurfaceVariant: groveShadow,
        outline: groveOutline,
        outlineVariant: groveOutlineVariant,
        inverseSurface: inkDeep,
        onInverseSurface: mintMist,
        inversePrimary: iceGlow,
        scrim: Color(0xFF162008),
        shadow: Color(0xFF162008),
      ),
      scaffoldBackgroundColor: mintMist,
      canvasColor: mintMist,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: mintMist,
        foregroundColor: inkDeep,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: paleGroveHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: groveOutlineVariant),
        ),
      ),
      textTheme: GoogleFonts.geistTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: inkDeep,
        displayColor: inkDeep,
      ),
    );
  }
}
