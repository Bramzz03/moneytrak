import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F5);
  static const card = Color(0xFFF0F0F0);
  static const cardBorder = Color(0xFFE0E0E0);
  static const cardGreen = Color(0xFF1A6B6B);
  static const cardGreenDark = Color(0xFF124D4D);
  static const primary = Color(0xFF1A6B6B);
  static const primaryDark = Color(0xFF124D4D);
  static const accent = Color(0xFF6C63FF);
  static const income = Color(0xFF2ECC71);
  static const expense = Color(0xFFFF4757);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF555555);
  static const textMuted = Color(0xFF999999);
  static const navBg = Color(0xFFFFFFFF);

  static const categoryColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFBE0B),
    Color(0xFF845EC2),
    Color(0xFFFF9671),
    Color(0xFF0081CF),
    Color(0xFFFF4B4B),
    Color(0xFF2ECC71),
    Color(0xFF9E9E9E),
  ];
}

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
}
