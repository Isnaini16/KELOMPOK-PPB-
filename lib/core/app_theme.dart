import 'package:flutter/material.dart';

class Palette {
  static const primary = Color(0xFF7853BD);
  static const primaryDark = Color(0xFF603DA4);
  static const lavender = Color(0xFFE8D8FA);
  static const background = Color(0xFFFBF9FF);
  static const ink = Color(0xFF2C2340);
  static const softInk = Color(0xFF756B82);
  static const success = Color(0xFF2F9465);
  static const danger = Color(0xFFC84E5D);
  static const warning = Color(0xFFB58B31);
  static const white = Colors.white;
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: Palette.primary,
      surface: Palette.background,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Palette.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Palette.background,
        foregroundColor: Palette.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Palette.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE9E1F3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Palette.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shadowColor: const Color(0xFF5E3989).withValues(alpha: .09),
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Palette.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 49),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Palette.primary,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: Palette.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Palette.lavender,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, color: Palette.ink),
        ),
      ),
    );
  }
}
