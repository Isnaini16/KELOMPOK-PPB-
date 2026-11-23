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
    return ThemeData();
  }
}
