import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Modern, deep, sophisticated color palette
  static const Color _primaryLight = Color(0xFF0F4C81); // Classic Blue
  static const Color _secondaryLight = Color(0xFF00B4D8); // Vibrant accent
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _backgroundLight = Color(0xFFF8F9FA); // Clean breathing light mode

  static const Color _primaryDark = Color(0xFF48CAE4); // Bright cyan for dark mode
  static const Color _secondaryDark = Color(0xFF90E0EF);
  static const Color _surfaceDark = Color(0xFF1B2028); // Deep sophisticated dark
  static const Color _backgroundDark = Color(0xFF111418);

  static TextTheme _buildTextTheme(TextTheme base, bool isArabic) {
    final textTheme = isArabic ? GoogleFonts.cairoTextTheme(base) : GoogleFonts.interTextTheme(base);
    // Enforcing proper vertical hierarchy and weights
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      displaySmall: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      bodySmall: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
      labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  // Soft geometry rules
  static final _smallRadius = BorderRadius.circular(12);
  static final _mediumRadius = BorderRadius.circular(20);

  // Soft translucent shadow for layering
  static final List<BoxShadow> _softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData light({bool isArabic = false}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryLight,
        primary: _primaryLight,
        secondary: _secondaryLight,
        surface: _surfaceLight,
        brightness: Brightness.light,
      ).copyWith(surfaceContainerHighest: const Color(0xFFEDF2F7)),
      scaffoldBackgroundColor: _backgroundLight,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme, isArabic),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: _mediumRadius),
        color: _surfaceLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: _smallRadius,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _smallRadius,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _smallRadius,
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _smallRadius,
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        floatingLabelStyle: const TextStyle(fontWeight: FontWeight.w600, color: _primaryLight),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _smallRadius),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _smallRadius),
          side: const BorderSide(color: _primaryLight),
        ),
      ),
    );
  }

  static ThemeData dark({bool isArabic = false}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryDark,
        primary: _primaryDark,
        secondary: _secondaryDark,
        surface: _surfaceDark,
        brightness: Brightness.dark,
      ).copyWith(surfaceContainerHighest: const Color(0xFF2C323A)),
      scaffoldBackgroundColor: _backgroundDark,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme, isArabic),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: _mediumRadius),
        color: _surfaceDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: _smallRadius,
          borderSide: const BorderSide(color: Color(0xFF3A424A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _smallRadius,
          borderSide: const BorderSide(color: Color(0xFF3A424A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _smallRadius,
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _smallRadius,
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        floatingLabelStyle: const TextStyle(fontWeight: FontWeight.w600, color: _primaryDark),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _smallRadius),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _smallRadius),
          side: const BorderSide(color: _primaryDark),
        ),
      ),
    );
  }

  // Expose the soft shadow so other custom containers can use it
  static List<BoxShadow> get softShadow => _softShadow;
}
