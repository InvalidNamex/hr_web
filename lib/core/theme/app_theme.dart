import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryColor = Color(0xFF1E6091);
  static const Color _secondaryColor = Color(0xFF2ECC71);

  static TextTheme _textTheme(TextTheme base, bool isArabic) =>
      isArabic ? GoogleFonts.cairoTextTheme(base) : base;

  static ThemeData light({bool isArabic = false}) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
        secondary: _secondaryColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
    return base.copyWith(textTheme: _textTheme(base.textTheme, isArabic));
  }

  static ThemeData dark({bool isArabic = false}) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        secondary: _secondaryColor,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
    return base.copyWith(textTheme: _textTheme(base.textTheme, isArabic));
  }
}
