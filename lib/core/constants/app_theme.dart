import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static TextTheme _buildTextTheme(Color playfairColor, Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        color: playfairColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        color: playfairColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        color: playfairColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        color: playfairColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: playfairColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        color: playfairColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: playfairColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.lightPrimaryTerracotta,
      scaffoldBackgroundColor: AppColors.lightScaffoldBg,
      cardColor: AppColors.lightSurface,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimaryTerracotta,
        secondary: AppColors.lightPrimaryBright,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.lightScaffoldBg,
        onSecondary: AppColors.lightScaffoldBg,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.lightDeleteRed,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(
        AppColors.lightPrimaryTerracotta,
        Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.lightPrimaryTerracotta,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightPrimaryTerracotta),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimaryTerracotta,
          foregroundColor: AppColors.lightScaffoldBg,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimaryTerracotta,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightPrimaryTerracotta.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.lightPrimaryTerracotta,
            width: 1.5,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.lightTextPrimary.withValues(alpha: 0.1),
        thickness: 0.5,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimaryGold,
      scaffoldBackgroundColor: AppColors.darkScaffoldBg,
      cardColor: AppColors.darkSurface,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimaryGold,
        secondary: AppColors.darkPrimaryBright,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkScaffoldBg,
        onSecondary: AppColors.darkScaffoldBg,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.darkDeleteRed,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(AppColors.darkPrimaryGold, Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.darkPrimaryGold,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkPrimaryGold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimaryGold,
          foregroundColor: AppColors.darkScaffoldBg,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimaryGold,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkPrimaryGold.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkPrimaryGold,
            width: 1.5,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkTextPrimary.withValues(alpha: 0.1),
        thickness: 0.5,
      ),
    );
  }
}
