import 'package:material_ui/material_ui.dart';

/// App-wide design tokens and theme definitions.
/// Premium App-Store design language: dark-first, restrained accents,
/// strict 8px grid, consistent radii (12 / 20 / 28), and Plus Jakarta Sans typography.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'PlusJakartaSans';

  // ---- Brand & Semantic Accents
  static const Color brandPrimary = Color(0xFF3B82F6); // Electric Azure
  static const Color brandPrimaryDark = Color(0xFF2563EB);
  static const Color brandPrimaryLight = Color(0xFF60A5FA);

  // Category specific colors (as per strict design language)
  static const Color vocabularyTeal = Color(0xFF14B8A6);
  static const Color phrasesOrange = Color(0xFFF97316);
  static const Color grammarIndigo = Color(0xFF6366F1);

  // Feedback colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ---- Dark Theme Palette (Deep Obsidian / Midnight)
  static const Color darkBackground = Color(0xFF0C0E14);
  static const Color darkSurface = Color(0xFF141824);
  static const Color darkSurfaceElevated = Color(0xFF1C2234);
  static const Color darkSurfaceHighlight = Color(0xFF262E44);
  static const Color darkBorder = Color(0x1FFFFFFF); // 12% white
  static const Color darkBorderSubtle = Color(0x0FFFFFFF); // 6% white
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // ---- Light Theme Palette (Warm Porcelain / Slate)
  static const Color lightBackground = Color(0xFFF8F9FD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F4F9);
  static const Color lightSurfaceHighlight = Color(0xFFE5EAF3);
  static const Color lightBorder = Color(0x140F172A); // 8% slate
  static const Color lightBorderSubtle = Color(0x0A0F172A); // 4% slate
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Radii
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 28.0;

  // Box Shadows
  static List<BoxShadow> get softShadowDark => [
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get softShadowLight => [
        const BoxShadow(
          color: Color(0x0D0F172A),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ];

  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: brandPrimary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF1E293B),
        onPrimaryContainer: Color(0xFFE2E8F0),
        secondary: vocabularyTeal,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF132F2D),
        onSecondaryContainer: Color(0xFF5EEAD4),
        tertiary: phrasesOrange,
        onTertiary: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerLow: darkSurface,
        surfaceContainer: darkSurfaceElevated,
        surfaceContainerHigh: darkSurfaceHighlight,
        surfaceContainerHighest: Color(0xFF2E374E),
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
        outlineVariant: darkBorderSubtle,
        error: error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          minimumSize: const Size(48, 50),
          side: const BorderSide(color: darkBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkTextSecondary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurfaceElevated,
        modalBackgroundColor: darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      textTheme: _buildTextTheme(baseTextTheme, darkTextPrimary, darkTextSecondary),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = Typography.material2021().black;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: brandPrimaryDark,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFEFF6FF),
        onPrimaryContainer: Color(0xFF1E3A8A),
        secondary: vocabularyTeal,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFCCFBF1),
        onSecondaryContainer: Color(0xFF115E59),
        tertiary: phrasesOrange,
        onTertiary: Colors.white,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        surfaceContainerLow: lightSurface,
        surfaceContainer: lightSurfaceElevated,
        surfaceContainerHigh: lightSurfaceHighlight,
        surfaceContainerHighest: Color(0xFFDCE2EE),
        onSurfaceVariant: lightTextSecondary,
        outline: lightBorder,
        outlineVariant: lightBorderSubtle,
        error: error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandPrimaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          minimumSize: const Size(48, 50),
          side: const BorderSide(color: lightBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightTextSecondary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        modalBackgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      textTheme: _buildTextTheme(baseTextTheme, lightTextPrimary, lightTextSecondary),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color primaryText, Color secondaryText) {
    return base.copyWith(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primaryText,
        letterSpacing: -0.6,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.4,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primaryText,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryText,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryText,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryText,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primaryText,
        letterSpacing: 0.2,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryText,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: secondaryText,
        letterSpacing: 0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
