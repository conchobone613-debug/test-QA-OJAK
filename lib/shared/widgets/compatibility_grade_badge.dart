import 'package:flutter/material.dart';

enum CompatibilityGrade {
  perfect,
  great,
  good,
  caution,
  avoid,
}

class CompatibilityGradeBadge extends StatelessWidget {
  final CompatibilityGrade grade;
  final bool showLabel;
  final bool showScore;
  final int? score;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  static const _gradeData = {
    CompatibilityGrade.perfect: _GradeData(
      label: '천생연분',
      emoji: '💑',
      colors: [Color(0xFFFFD700), Color(0xFFFF6B9D)],
      textColor: Color(0xFF1A1A2E),
    ),
    CompatibilityGrade.great: _GradeData(
      label: '매우좋음',
      emoji: '💕',
      colors: [Color(0xFFE040FB), Color(0xFF7B1FA2)],
      textColor: Colors.white,
    ),
    CompatibilityGrade.good: _GradeData(
      label: '좋음',
      emoji: '💙',
      colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
      textColor: Colors.white,
    ),
    CompatibilityGrade.caution: _GradeData(
      label: '조심지연',
      emoji: '💛',
      colors: [Color(0xFFFFCA28), Color(0xFFE65100)],
      textColor: Color(0xFF1A1A2E),
    ),
    CompatibilityGrade.avoid: _GradeData(
      label: '상극지연',
      emoji: '🔴',
      colors: [Color(0xFFEF5350), Color(0xFF880E4F)],
      textColor: Colors.white,
    ),
  };

  const CompatibilityGradeBadge({
    super.key,
    required this.grade,
    this.showLabel = true,
    this.showScore = false,
    this.score,
    this.fontSize = 12,
    this.padding,
  });

  static CompatibilityGrade fromScore(int score) {
    if (score >= 90) return CompatibilityGrade.perfect;
    if (score >= 75) return CompatibilityGrade.great;
    if (score >= 55) return CompatibilityGrade.good;
    if (score >= 35) return CompatibilityGrade.caution;
    return CompatibilityGrade.avoid;
  }

  @override
  Widget build(BuildContext context) {
    final data = _gradeData[grade]!;

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.colors.first.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(data.emoji, style: TextStyle(fontSize: fontSize + 2)),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              data.label,
              style: TextStyle(
                color: data.textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
          if (showScore && score != null) ...[
            const SizedBox(width: 4),
            Text(
              '$score점',
              style: TextStyle(
                color: data.textColor.withOpacity(0.85),
                fontSize: fontSize - 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GradeData {
  final String label;
  final String emoji;
  final List<Color> colors;
  final Color textColor;

  const _GradeData({
    required this.label,
    required this.emoji,
    required this.colors,
    required this.textColor,
  });
}

class CompatibilityGradeCard extends StatelessWidget {
  final CompatibilityGrade grade;
  final int score;
  final String? description;

  const CompatibilityGradeCard({
    super.key,
    required this.grade,
    required this.score,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final data = CompatibilityGradeBadge._gradeData[grade]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors.map((c) => c.withOpacity(0.15)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.colors.first.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          CompatibilityGradeBadge(
            grade: grade,
            showScore: true,
            score: score,
            fontSize: 14,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}