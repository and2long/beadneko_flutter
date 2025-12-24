import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const themeColor = Colors.pink;
const secondaryColor = Colors.tealAccent;
const dividerColor = Color(0xFFE8E8E8);
const backgroundColor = Color(0xfff8f8f8);

class AppColors {
  AppColors._();

  // Common colors (used in both themes)
  static const primaryGradientStart = Color(0xFFFF6B9D);
  static const primaryGradientEnd = Color(0xFFFF8EAC);
  static const secondaryGradientStart = Color(0xFFFF528E);
  static const secondaryGradientEnd = Color(0xFF5FD38C);

  // Light theme colors
  static const textDark = Color(0xFF2D3142);
  static const textLight = Color(0xFF9094A6);
  static const bgLight = Color(0xFFFFFBFC);

  // Dark theme colors
  static const textDarkDark = Color(0xFFE8E6EA);
  static const textLightDark = Color(0xFF8E8E93);
  static const bgDark = Color(0xFF1C1C1E);
  static const surfaceDark = Color(0xFF2C2C2E);
  static const cardDark = Color(0xFF2C2C2E);
}

class AppGradients {
  AppGradients._();
  static const primary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
  );

  static const mainAction = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondaryGradientStart, AppColors.secondaryGradientEnd],
  );

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF5F9), // Very subtle pink
      Color(0xFFF5FFF9), // Very subtle green
    ],
  );

  static const backgroundDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1C1C1E), // Dark background
      Color(0xFF252528), // Slightly lighter
    ],
  );
}

class AppTheme {
  AppTheme._();
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: themeColor,
    ),
    fontFamily: GoogleFonts.fredoka().fontFamily,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 1),
    dividerTheme: DividerThemeData(color: Colors.grey[200], thickness: 1),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: themeColor,
    ),
    fontFamily: GoogleFonts.fredoka().fontFamily,
    scaffoldBackgroundColor: AppColors.bgDark,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 1,
      backgroundColor: AppColors.bgDark,
      foregroundColor: AppColors.textDarkDark,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey[800], thickness: 1),
    cardTheme: const CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
    ),
  );
}
