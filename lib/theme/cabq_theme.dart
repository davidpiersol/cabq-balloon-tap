import 'package:flutter/material.dart';

abstract final class CabqTheme {
  static const Color skyTop = Color(0xFF87CEEB);
  static const Color skyBottom = Color(0xFFE8B86D);
  static const Color primary = Color(0xFF0A5F73);
  static const Color accent = Color(0xFFD94E1F);
  static const Color sand = Color(0xFFF4EDE4);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: sand,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: sand,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
    return base;
  }
}
