// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFD32F2F);
  static const primaryLight = Color(0xFFFF6659);
  static const primaryDark = Color(0xFF9A0007);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);
  static const divider = Color(0xFFEEEEEE);
  static const starYellow = Color(0xFFFFC107);
  static const tagGreen = Color(0xFF43A047);
  static const shadow = Color(0x14000000);
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 50;
}

class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: AppTextStyles.headlineSmall,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}