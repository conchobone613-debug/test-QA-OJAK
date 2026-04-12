import 'package:flutter/material.dart';
import 'dart:ui';

class FortuneCard extends StatelessWidget {
  final String title;
  final String icon;
  final int score;
  final String description;
  final Color accentColor;
  final VoidCallback? onTap;

  const FortuneCard({
    super.key,
    required this.title,
    required this.icon,
    required this.score,
    required this.description,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _ScoreBadge(score: score, color: accentColor),
                  ],
                ),
                const SizedBox(height: 12),
                _ScoreBar(score: score, color: accentColor),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreBadge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$score점',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreBar({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        FractionallySizedBox(
          widthFactor: score / 100,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LuckyInfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const LuckyInfoChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}