import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color primary = Color(0xFFE31B23);
  static const Color primaryHover = Color(0xFFC7121A);
  static const Color primaryLight = Color(0xFFFFEDED);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color goldDark = Color(0xFFD97706);
  static const Color secondary = Color(0xFF2563EB);
  static const Color secondaryLight = Color(0xFFEFF6FF);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  // Status Badge Colors
  static const Color statusOnline = Color(0xFF10B981);
  static const Color statusBreak = Color(0xFFF59E0B);
  static const Color statusOffline = Color(0xFF64748B);

  // Light Mode Colors
  static const Color bgAppLight = Color(0xFFF8FAFC);
  static const Color bgCardLight = Colors.white;
  static const Color bgInputLight = Color(0xFFF1F5F9);
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textMutedLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Mode Colors
  static const Color bgAppDark = Color(0xFF090D16);
  static const Color bgCardDark = Color(0xFF131B2E);
  static const Color bgInputDark = Color(0xFF1E293B);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textMutedDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF1E293B);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.bgAppLight,
    ),
    scaffoldBackgroundColor: AppColors.bgAppLight,
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textMainLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textMainLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48), // 44pt+ minimum tap target
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      surface: AppColors.bgAppDark,
    ),
    scaffoldBackgroundColor: AppColors.bgAppDark,
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgCardDark,
      foregroundColor: AppColors.textMainDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textMainDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDark),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
  );
}
