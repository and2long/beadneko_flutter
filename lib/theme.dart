import 'package:flutter/material.dart';
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
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 1),
    dividerTheme: DividerThemeData(color: Colors.grey[900], thickness: 1),
  );
}
