import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

abstract final class CabqTheme {
  CabqTheme._();

  // Sky — Fiesta
  static const Color skyTop = Color(0xFF87CEEB);
  static const Color skyHorizon = Color(0xFFFFE8CC);
  static const Color skyBottom = Color(0xFFE8B86D);

  // Primary / Accent
  static const Color primary = Color(0xFF0A5F73);
  static const Color accent = Color(0xFFD94E1F);
  static const Color sand = Color(0xFFF4EDE4);

  // NM collectible motifs
  static const Color chileRed = Color(0xFFB71C1C);
  static const Color chileGreen = Color(0xFF2E7D32);
  static const Color gold = Color(0xFFFFD700);

  // Glassmorphism
  static const Color glassWhite = Color(0x29FFFFFF);
  static const Color glassBorder = Color(0x3DFFFFFF);
  static const double glassBlurSigma = 12.0;

  // Ridge palette (parallax layers, far → near)
  static const Color ridgeFar = Color(0xFF7B9BA8);
  static const Color ridgeMid = Color(0xFF5C6B73);
  static const Color ridgeNear = Color(0xFF3D4549);
  static const Color ridgeGround = Color(0xFF2A3035);

  static ImageFilter get glassBlur =>
      ImageFilter.blur(sigmaX: glassBlurSigma, sigmaY: glassBlurSigma);

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      );

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
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
    return base;
  }
}
