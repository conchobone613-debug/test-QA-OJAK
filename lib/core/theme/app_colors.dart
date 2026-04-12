import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const Color primary = Color(0xFF1B1464);
  static const Color primaryLight = Color(0xFF2D2199);
  static const Color primaryDark = Color(0xFF110D3F);

  // Secondary (Fortune Gold)
  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFE8CC6E);
  static const Color secondaryDark = Color(0xFFA88A2B);

  // Accent (Blossom Pink)
  static const Color accent = Color(0xFFFF6B8A);
  static const Color accentLight = Color(0xFFFF99B0);
  static const Color accentDark = Color(0xFFCC4466);

  // Background
  static const Color background = Color(0xFF0A0E27);
  static const Color backgroundLight = Color(0xFF111636);
  static const Color backgroundElevated = Color(0xFF161B3D);
  static const Color surface = Color(0xFF1C2148);
  static const Color surfaceLight = Color(0xFF252B5A);
  static const Color surfaceBright = Color(0xFF2E356C);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB0B3C6);
  static const Color textTertiary = Color(0xFF6B6F8A);
  static const Color textDisabled = Color(0xFF3E4263);

  // 오행 5색 (Five Elements)
  static const Color elementWood = Color(0xFF4CAF50);
  static const Color elementFire = Color(0xFFFF5252);
  static const Color elementEarth = Color(0xFFFFB74D);
  static const Color elementMetal = Color(0xFFE0E0E0);
  static const Color elementWater = Color(0xFF42A5F5);

  // 궁합 등급 5색 (Compatibility Grades)
  static const Color gradeDestiny = Color(0xFFFFD700);
  static const Color gradeExcellent = Color(0xFFFF6B8A);
  static const Color gradeGood = Color(0xFF7C4DFF);
  static const Color gradeNormal = Color(0xFF42A5F5);
  static const Color gradeCaution = Color(0xFF78909C);

  // Glass Morphism
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassOverlay = Color(0x0DFFFFFF);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Divider / Border
  static const Color divider = Color(0x1AFFFFFF);
  static const Color border = Color(0x33FFFFFF);

  // Shadow
  static const Color shadow = Color(0x40000000);
  static const Color shadowPrimary = Color(0x401B1464);
  static const Color shadowGold = Color(0x40D4AF37);
}