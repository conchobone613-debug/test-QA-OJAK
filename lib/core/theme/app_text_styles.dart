import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  // === Pretendard (한글 본문) ===

  static TextStyle get headingXL => _pretendard(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );

  static TextStyle get headingL => _pretendard(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headingM => _pretendard(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.35,
      );

  static TextStyle get headingS => _pretendard(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleL => _pretendard(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleM => _pretendard(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.45,
      );

  static TextStyle get titleS => _pretendard(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get bodyL => _pretendard(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyM => _pretendard(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyS => _pretendard(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get caption => _pretendard(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get label => _pretendard(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.3,
      );

  // === Outfit (영문/숫자) ===

  static TextStyle get numberXL => _outfit(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get numberL => _outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get numberM => _outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get numberS => _outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get percentageDisplay => _outfit(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 1.1,
      );

  // === Noto Serif KR (한자/동양풍) ===

  static TextStyle get hanjaL => _notoSerifKR(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get hanjaM => _notoSerifKR(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get hanjaS => _notoSerifKR(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get fortuneQuote => _notoSerifKR(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.7,
        letterSpacing: 1.0,
      );

  // === Private Helpers ===

  static TextStyle _pretendard({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'Pretendard',
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle _outfit({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle _notoSerifKR({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'NotoSerifKR',
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: AppColors.textPrimary,
    );
  }
}