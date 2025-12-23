import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const themeColor = Colors.pink;
const secondaryColor = Colors.tealAccent;
const dividerColor = Color(0xFFE8E8E8);
const backgroundColor = Color(0xfff8f8f8);

class AppColors {
  AppColors._();
  static const primaryGradientStart = Color(0xFFFF6B9D);
  static const primaryGradientEnd = Color(0xFFFF8EAC);

  static const secondaryGradientStart = Color(0xFFFF528E);
  static const secondaryGradientEnd = Color(0xFF5FD38C);

  static const textDark = Color(0xFF2D3142);
  static const textLight = Color(0xFF9094A6);
  static const bgLight = Color(0xFFFFFBFC);
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
}

class AppTheme {
  AppTheme._();
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: themeColor,
      secondary: secondaryColor,
      surface: AppColors.bgLight,
    ),
    fontFamily: GoogleFonts.fredoka().fontFamily,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textDark,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android dark icons
        statusBarBrightness: Brightness.light, // iOS dark icons
      ),
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    dividerTheme: DividerThemeData(color: Colors.grey[200], thickness: 1),
    textTheme: GoogleFonts.fredokaTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: AppColors.textDark),
        displayMedium: TextStyle(color: AppColors.textDark),
        displaySmall: TextStyle(color: AppColors.textDark),
        headlineLarge: TextStyle(color: AppColors.textDark),
        headlineMedium: TextStyle(color: AppColors.textDark),
        headlineSmall: TextStyle(color: AppColors.textDark),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textLight),
        bodySmall: TextStyle(color: AppColors.textLight),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: themeColor,
      secondary: secondaryColor,
    ),
    fontFamily: GoogleFonts.fredoka().fontFamily,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.pink, // Darker pink
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android light icons
        statusBarBrightness: Brightness.dark, // iOS light icons
      ),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey[900], thickness: 1),
    textTheme: GoogleFonts.fredokaTextTheme(ThemeData.dark().textTheme),
  );
}
