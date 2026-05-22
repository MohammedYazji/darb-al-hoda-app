import 'package:flutter/material.dart';

class AppColors {
  //private we can't make instance from this class just access static methods and proprieties
  AppColors._();

  // === Primary ===
  static const Color primary = Color(0xFF1a5c38); // Green
  static const Color primaryLight = Color(0xFF2d7a4f); // LightGreens
  static const Color gold = Color(0xFFc9a84c); // Gold
  static const Color goldLight = Color(0xFFe8c96d); //LightGold

  // === Background ===
  static const Color background = Color(0xFFF5F5F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // === Text ===
  static const Color textPrimary = Color(0xFF1a1a1a);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // === Border ===
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);

  // === Status ===
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF2196F3);
}
