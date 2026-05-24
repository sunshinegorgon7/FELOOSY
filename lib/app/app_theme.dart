import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // User supplied palette, light theme.
  static const Color lightPrimary = Color(0xFF0F4C81);
  static const Color lightSecondary = Color(0xFFFF6F61);
  static const Color lightBackground = Color(0xFFF7F3E8);
  static const Color lightAccent = Color(0xFF88B04B);
  static const Color lightSurfaceLowest = Color(0xFFFFFCF4);
  static const Color lightSurfaceLow = Color(0xFFF0E8D7);
  static const Color lightSurfaceHigh = Color(0xFFE3D8C3);
  static const Color lightText = Color(0xFF25282C);
  static const Color lightMuted = Color(0xFF5F584C);
  static const Color lightOutline = Color(0xFF918574);
  static const Color lightOutlineVariant = Color(0xFFD5C9B4);

  // User supplied palette, dark theme.
  static const Color darkPrimary = Color(0xFF101820);
  static const Color darkSecondary = Color(0xFF5F4B8B);
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkAccent = Color(0xFF45B8AC);
  static const Color darkSurfaceLow = Color(0xFF252529);
  static const Color darkSurface = Color(0xFF2B2B30);
  static const Color darkSurfaceHigh = Color(0xFF34343B);
  static const Color darkSurfaceHighest = Color(0xFF3D3D46);
  static const Color darkText = Color(0xFFE7E8EA);
  static const Color darkMuted = Color(0xFFB6B6BE);

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
  static const Color ledgerRed = Color(0xFFD64545);
  static const Color ledgerGreen = Color(0xFF4A9955);
  static const Color amberMark = Color(0xFFCC8830);
  static const Color destructiveColor = Color(0xFFC73535);

  // Text-safe variants for small semantic text on tinted surfaces.
  static const Color fernText = lightPrimary;
  static const Color iceGlowText = darkAccent;
  static const Color ledgerRedText = Color(0xFFB23636);
  static const Color ledgerRedTextDark = Color(0xFFF07171);
  static const Color ledgerGreenText = Color(0xFF2F7139);
  static const Color ledgerGreenTextDark = Color(0xFF72B879);
  static const Color amberText = Color(0xFF8F5F22);

  static const Color expenseColor = ledgerRed;
  static const Color incomeColor = ledgerGreen;
  static const Color warningColor = amberMark;

  static const List<Color> categoryBarsLight = [
    lightAccent,
    lightSecondary,
    Color(0xFF9A6F55),
    lightPrimary,
    Color(0xFFB48139),
    darkSecondary,
    Color(0xFF4F6B9A),
    Color(0xFFC65F78),
    Color(0xFF7E679A),
    Color(0xFFB66D50),
    Color(0xFF7C5FA6),
    Color(0xFF3F8A7E),
    Color(0xFF3E78A2),
    lightPrimary,
    lightAccent,
    darkAccent,
    darkSecondary,
    Color(0xFF7E679A),
  ];

  static const List<Color> categoryBarsDark = [
    Color(0xFFA2C56A),
    Color(0xFFFF8A7F),
    Color(0xFFC78B6A),
    Color(0xFF6FA9D4),
    Color(0xFFC49A55),
    Color(0xFF8E78C3),
    Color(0xFF7F96CC),
    Color(0xFFE1889E),
    Color(0xFFA78BC5),
    Color(0xFFC88D72),
    Color(0xFFA393D6),
    Color(0xFF65B8AD),
    Color(0xFF78ACD0),
    darkAccent,
    Color(0xFFA2C56A),
    Color(0xFF65B8AD),
    Color(0xFF8E78C3),
    Color(0xFFA78BC5),
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
        onSecondary: darkText,
        secondaryContainer: Color(0xFF342B4B),
        onSecondaryContainer: darkText,
        tertiary: darkAccent,
        onTertiary: darkPrimary,
        tertiaryContainer: Color(0xFF143E3B),
        onTertiaryContainer: Color(0xFFBDEDE8),
        error: destructiveColor,
        onError: lightBackground,
        errorContainer: Color(0xFF5C1A1A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: darkBackground,
        onSurface: darkText,
        surfaceContainerLowest: darkPrimary,
        surfaceContainerLow: darkSurfaceLow,
        surfaceContainer: darkSurface,
        surfaceContainerHigh: darkSurfaceHigh,
        surfaceContainerHighest: darkSurfaceHighest,
        onSurfaceVariant: darkMuted,
        outline: Color(0xFF67616F),
        outlineVariant: darkSurfaceHighest,
        inverseSurface: lightBackground,
        onInverseSurface: darkPrimary,
        inversePrimary: lightPrimary,
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
        primaryContainer: Color(0xFFD9E7F2),
        onPrimaryContainer: lightPrimary,
        secondary: lightSecondary,
        onSecondary: Color(0xFF301512),
        secondaryContainer: Color(0xFFFFDAD5),
        onSecondaryContainer: lightText,
        tertiary: lightAccent,
        onTertiary: Color(0xFF223011),
        tertiaryContainer: Color(0xFFE6EFCF),
        onTertiaryContainer: Color(0xFF354B17),
        error: destructiveColor,
        onError: lightBackground,
        errorContainer: Color(0xFFF9DEDC),
        onErrorContainer: Color(0xFF8C1D18),
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
