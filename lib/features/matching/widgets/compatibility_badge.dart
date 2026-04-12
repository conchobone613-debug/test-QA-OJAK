import 'package:flutter/material.dart';

class CompatibilityBadge extends StatelessWidget {
  final String grade;
  final int score;
  final bool large;

  const CompatibilityBadge({
    super.key,
    required this.grade,
    required this.score,
    this.large = false,
  });

  Color get _gradeColor {
    switch (grade) {
      case 'S': return const Color(0xFFFF6B9D);
      case 'A': return const Color(0xFFFF8C42);
      case 'B': return const Color(0xFF7B68EE);
      case 'C': return const Color(0xFF4ECDC4);
      default: return const Color(0xFF95A5A6);
    }
  }

  List<Color> get _gradientColors {
    switch (grade) {
      case 'S': return [const Color(0xFFFF6B9D), const Color(0xFFFF8E53)];
      case 'A': return [const Color(0xFFFF8C42), const Color(0xFFFFD700)];
      case 'B': return [const Color(0xFF7B68EE), const Color(0xFF9B59B6)];
      case 'C': return [const Color(0xFF4ECDC4), const Color(0xFF44A08D)];
      default: return [const Color(0xFF95A5A6), const Color(0xFF7F8C8D)];
    }
  }

  String get _gradeLabel {
    switch (grade) {
      case 'S': return '✨ 천생연분';
      case 'A': return '💕 좋은궁합';
      case 'B': return '💫 보통궁합';
      case 'C': return '🌱 발전가능';
      default: return '🍀 신중하게';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _gradientColors),
        borderRadius: BorderRadius.circular(large ? 20 : 12),
        boxShadow: [
          BoxShadow(
            color: _gradeColor.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            grade,
            style: TextStyle(
              color: Colors.white,
              fontSize: large ? 20 : 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          SizedBox(width: large ? 8 : 4),
          Text(
            '$score점',
            style: TextStyle(
              color: Colors.white,
              fontSize: large ? 16 : 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (large) ...[
            const SizedBox(width: 8),
            Text(
              _gradeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}