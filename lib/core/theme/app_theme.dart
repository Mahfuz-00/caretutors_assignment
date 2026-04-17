import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF006D39); // Deep Emerald
  static const Color secondaryBlue = Color(0xFF1A1C2E); // Midnight Navy
  static const Color surfaceLight = Color(0xFFF8F9FE);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceLight,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: secondaryBlue,
        onSecondary: Colors.white,
        surface: Colors.white,
        background: surfaceLight,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(), // More modern than Inter
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: secondaryBlue,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF45D08E), // Vibrant Mint for Dark Mode
        onPrimary: secondaryBlue,
        secondary: const Color(0xFF8BB7FF),
        surface: const Color(0xFF25273D),
        background: secondaryBlue,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryBlue,
        elevation: 0,
      ),
    );
  }
}