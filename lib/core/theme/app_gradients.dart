import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  // 궁합 등급별 그라데이션
  static const LinearGradient destiny = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient excellent = LinearGradient(
    colors: [Color(0xFFFF6B8A), Color(0xFFFF4081), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient good = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF651FFF), Color(0xFF6200EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient normal = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient caution = LinearGradient(
    colors: [Color(0xFF90A4AE), Color(0xFF78909C), Color(0xFF607D8B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 배경 그라데이션
  static const LinearGradient backgroundMain = LinearGradient(
    colors: [
      AppColors.background,
      Color(0xFF0F1435),
      AppColors.background,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient backgroundStarfield = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: [
      Color(0xFF1B1464),
      AppColors.background,
    ],
  );

  // 글래스모피즘 그라데이션
  static const LinearGradient glass = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBorder = LinearGradient(
    colors: [
      Color(0x40FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
      Color(0x26FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Primary 그라데이션
  static const LinearGradient primary = LinearGradient(
    colors: [
      AppColors.primaryLight,
      AppColors.primary,
      AppColors.primaryDark,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gold 그라데이션
  static const LinearGradient gold = LinearGradient(
    colors: [
      Color(0xFFE8CC6E),
      AppColors.secondary,
      Color(0xFFA88A2B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 오행 그라데이션
  static const LinearGradient elementWood = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient elementFire = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient elementEarth = LinearGradient(
    colors: [Color(0xFFFFCA28), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient elementMetal = LinearGradient(
    colors: [Color(0xFFF5F5F5), Color(0xFFBDBDBD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient elementWater = LinearGradient(
    colors: [Color(0xFF64B5F6), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 궁합 등급별 그라데이션 매핑 헬퍼
  static LinearGradient forGrade(String grade) {
    switch (grade) {
      case 'destiny':
        return destiny;
      case 'excellent':
        return excellent;
      case 'good':
        return good;
      case 'normal':
        return normal;
      case 'caution':
        return caution;
      default:
        return normal;
    }
  }

  // 오행 그라데이션 매핑 헬퍼
  static LinearGradient forElement(String element) {
    switch (element) {
      case 'wood':
        return elementWood;
      case 'fire':
        return elementFire;
      case 'earth':
        return elementEarth;
      case 'metal':
        return elementMetal;
      case 'water':
        return elementWater;
      default:
        return elementEarth;
    }
  }
}