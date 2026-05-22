import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    // === Colors ===
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,

    // === Font ===
    textTheme: GoogleFonts.cairoTextTheme(),

    // === AppBar ===
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary, // green background
      foregroundColor: AppColors.textOnPrimary, // white content
      elevation: 0, // no shadow
      centerTitle: true, // text center
      titleTextStyle: GoogleFonts.cairo(
        // cairo for bar text
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      ),
    ),

    // === Button ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // green background
        foregroundColor: AppColors.textOnPrimary, //white content
        minimumSize: const Size(
          double.infinity,
          52,
        ), // full width, with 52 hight
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // === Input Fields ===
    inputDecorationTheme: InputDecorationTheme(
      filled: true, // filled background
      fillColor: AppColors.surface, // white background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.cairo(color: AppColors.textLight, fontSize: 14),
    ),

    // === Card ===
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),

    // === RTL ===
    useMaterial3: true, // newer version of useMaterial2
  );
}
