import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Inspiration palette.
  static const Color forestGreen = Color(0xFF0E3B2E);
  static const Color icePerformanceBlue = Color(0xFF8FD5E6);
  static const Color ghazelBlood = Color(0xFFA6192E);
  static const Color royalBlue = Color(0xFF1E4FA3);
  static const Color mossGreen = Color(0xFF647A43);

  // Light theme.
  static const Color lightPrimary = forestGreen;
  static const Color lightSecondary = royalBlue;
  static const Color lightBackground = Color(0xFFF3F6EF);
  static const Color lightAccent = icePerformanceBlue;
  static const Color lightSurfaceLowest = Color(0xFFFBFDF8);
  static const Color lightSurfaceLow = Color(0xFFE8EFE2);
  static const Color lightSurfaceHigh = Color(0xFFD9E4D1);
  static const Color lightText = Color(0xFF202823);
  static const Color lightMuted = Color(0xFF566156);
  static const Color lightOutline = Color(0xFF81917E);
  static const Color lightOutlineVariant = Color(0xFFC8D5C3);

  // Dark theme.
  static const Color darkPrimary = forestGreen;
  static const Color darkSecondary = Color(0xFF6F8FEA);
  static const Color darkBackground = Color(0xFF0D1513);
  static const Color darkAccent = icePerformanceBlue;
  static const Color darkSurfaceLow = Color(0xFF151E1B);
  static const Color darkSurface = Color(0xFF1C2824);
  static const Color darkSurfaceHigh = Color(0xFF24312C);
  static const Color darkSurfaceHighest = Color(0xFF2C3A34);
  static const Color darkText = Color(0xFFE3ECE8);
  static const Color darkMuted = Color(0xFFAAB7B1);

  // Backward-compatible aliases used by existing widgets.
  static const Color fern = lightPrimary;
  static const Color washedSage = lightSecondary;
  static const Color forestDeep = lightAccent;
  static const Color mintMist = lightBackground;
  static const Color mintLift = lightSurfaceLowest;
  static const Color paleGrove = lightSurfaceLow;
  static const Color paleGroveHigh = lightSurfaceHigh;
  static const Color inkDeep = lightText;
  static const Color groveShadow = lightMuted;
  static const Color groveOutline = lightOutline;
  static const Color groveOutlineVariant = lightOutlineVariant;

  static const Color iceGlow = darkAccent;
  static const Color deepNimbus = darkBackground;
  static const Color nimbusLowest = darkPrimary;
  static const Color nimbusSurface = darkSurfaceLow;
  static const Color nimbusMid = darkSurface;
  static const Color nimbusHigh = darkSurfaceHigh;
  static const Color nimbusHighest = darkSurfaceHighest;
  static const Color mistText = darkText;
  static const Color mistVariant = darkMuted;

  // Semantic colors.
  static const Color ledgerRed = ghazelBlood;
  static const Color ledgerGreen = mossGreen;
  static const Color amberMark = Color(0xFFB47A2B);
  static const Color destructiveColor = Color(0xFFB11C2E);

  // Text-safe variants for small semantic text on tinted surfaces.
  static const Color fernText = lightPrimary;
  static const Color iceGlowText = darkAccent;
  static const Color ledgerRedText = ghazelBlood;
  static const Color ledgerRedTextDark = Color(0xFFFF7885);
  static const Color ledgerGreenText = Color(0xFF4B612C);
  static const Color ledgerGreenTextDark = Color(0xFFA8BE72);
  static const Color amberText = Color(0xFF80531B);

  static const Color expenseColor = ledgerRed;
  static const Color incomeColor = ledgerGreen;
  static const Color warningColor = amberMark;

  static const List<Color> categoryBarsLight = [
    forestGreen,
    royalBlue,
    Color(0xFF8B6048),
    Color(0xFF3A7F92),
    Color(0xFF9B6F2E),
    mossGreen,
    Color(0xFF425F8F),
    ghazelBlood,
    Color(0xFF7B5D88),
    Color(0xFF9E654C),
    Color(0xFF5260A7),
    Color(0xFF3D8174),
    Color(0xFF2F6A9B),
    forestGreen,
    mossGreen,
    Color(0xFF3D8174),
    royalBlue,
    Color(0xFF7B5D88),
  ];

  static const List<Color> categoryBarsDark = [
    Color(0xFF5FAF8A),
    darkSecondary,
    Color(0xFFD09A78),
    darkAccent,
    Color(0xFFC99A50),
    Color(0xFFA8BE72),
    Color(0xFF85A0E8),
    Color(0xFFFF7885),
    Color(0xFFB28CC5),
    Color(0xFFD49276),
    Color(0xFF9CA8F2),
    Color(0xFF75C3B3),
    Color(0xFF78B8E0),
    Color(0xFF5FAF8A),
    Color(0xFFA8BE72),
    Color(0xFF75C3B3),
    darkSecondary,
    Color(0xFFB28CC5),
  ];

  static const Map<String, int> _defaultCategoryBarIndex = {
    '00000000-0000-0000-0000-000000000001': 0,
    '00000000-0000-0000-0000-000000000002': 1,
    '00000000-0000-0000-0000-000000000003': 2,
    '00000000-0000-0000-0000-000000000004': 3,
    '00000000-0000-0000-0000-000000000005': 4,
    '00000000-0000-0000-0000-000000000006': 5,
    '00000000-0000-0000-0000-000000000007': 6,
    '00000000-0000-0000-0000-000000000008': 7,
    '00000000-0000-0000-0000-000000000009': 8,
    '00000000-0000-0000-0000-000000000010': 9,
    '00000000-0000-0000-0000-000000000011': 10,
    '00000000-0000-0000-0000-000000000012': 11,
    '00000000-0000-0000-0000-000000000013': 12,
    '00000000-0000-0000-0000-000000000014': 13,
    '00000000-0000-0000-0000-000000000015': 14,
    '00000000-0000-0000-0000-000000000016': 15,
    '00000000-0000-0000-0000-000000000017': 16,
    '00000000-0000-0000-0000-000000000018': 17,
  };

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
      background.computeLuminance() > 0.45 ? lightText : lightBackground;

  static Color categoryBarColor({
    required String uuid,
    required int colorValue,
    required ColorScheme colorScheme,
  }) {
    final index = _defaultCategoryBarIndex[uuid];
    if (index != null) {
      final palette = colorScheme.brightness == Brightness.dark
          ? categoryBarsDark
          : categoryBarsLight;
      return palette[index % palette.length];
    }
    return _customCategoryBarColor(Color(colorValue), colorScheme);
  }

  static Color _customCategoryBarColor(
    Color base,
    ColorScheme colorScheme,
  ) {
    final luminance = base.computeLuminance();
    if (colorScheme.brightness == Brightness.dark && luminance < 0.30) {
      return Color.lerp(base, darkText, 0.36)!;
    }
    if (colorScheme.brightness == Brightness.light && luminance > 0.70) {
      return Color.lerp(base, lightText, 0.22)!;
    }
    return base;
  }

  static ThemeData _buildDark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        surfaceTint: Colors.transparent,
        primary: darkAccent,
        onPrimary: darkPrimary,
        primaryContainer: darkPrimary,
        onPrimaryContainer: darkAccent,
        secondary: darkSecondary,
        onSecondary: darkPrimary,
        secondaryContainer: Color(0xFF1A2F63),
        onSecondaryContainer: Color(0xFFD8E2FF),
        tertiary: Color(0xFFA8BE72),
        onTertiary: Color(0xFF18230F),
        tertiaryContainer: Color(0xFF2C3B20),
        onTertiaryContainer: Color(0xFFDDE9BC),
        error: destructiveColor,
        onError: lightBackground,
        errorContainer: Color(0xFF5A111C),
        onErrorContainer: Color(0xFFFFDADC),
        surface: darkBackground,
        onSurface: darkText,
        surfaceContainerLowest: darkPrimary,
        surfaceContainerLow: darkSurfaceLow,
        surfaceContainer: darkSurface,
        surfaceContainerHigh: darkSurfaceHigh,
        surfaceContainerHighest: darkSurfaceHighest,
        onSurfaceVariant: darkMuted,
        outline: Color(0xFF5A6A64),
        outlineVariant: darkSurfaceHighest,
        inverseSurface: lightBackground,
        onInverseSurface: darkPrimary,
        inversePrimary: forestGreen,
        scrim: darkPrimary,
        shadow: darkPrimary,
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
        primary: lightPrimary,
        onPrimary: lightBackground,
        primaryContainer: Color(0xFFD4E3D9),
        onPrimaryContainer: lightPrimary,
        secondary: lightSecondary,
        onSecondary: lightBackground,
        secondaryContainer: Color(0xFFDDE6FF),
        onSecondaryContainer: Color(0xFF17356E),
        tertiary: mossGreen,
        onTertiary: lightBackground,
        tertiaryContainer: Color(0xFFE1EBCD),
        onTertiaryContainer: Color(0xFF34441F),
        error: destructiveColor,
        onError: lightBackground,
        errorContainer: Color(0xFFFFDADC),
        onErrorContainer: Color(0xFF6E0E19),
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
        inverseSurface: darkPrimary,
        onInverseSurface: lightBackground,
        inversePrimary: darkAccent,
        scrim: darkPrimary,
        shadow: darkPrimary,
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
        color: lightSurfaceHigh,
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
