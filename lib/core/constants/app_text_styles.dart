import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// make standard styles according to the ui design for headings, sizes, and other components
class AppTextStyles {
  //private we can't make instance from this class just access static methods and proprieties
  AppTextStyles._();

  // === Base Font (Cairo) ===
  static TextStyle get _base => GoogleFonts.cairo();

  // === Headings ===
  // globalize the heading across the app
  static TextStyle get h1 => _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // === Body ===
  static TextStyle get bodyLarge => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // === Special ===
  static TextStyle get label => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get button => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get caption => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static TextStyle get gold => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
  );
}
