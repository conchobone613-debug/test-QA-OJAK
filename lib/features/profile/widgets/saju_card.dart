import 'package:flutter/material.dart';
import '../providers/profile_provider.dart';

class SajuCard extends StatelessWidget {
  final SajuData data;

  const SajuCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A3E), Color(0xFF2D1B4E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8B84B).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B84B).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(),
          const Divider(color: Colors.white12, height: 1),
          _buildPillarsGrid(),
          const Divider(color: Colors.white12, height: 1),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '사주 원국',
                style: TextStyle(
                  color: Color(0xFFE8B84B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '四柱 原局',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8B84B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE8B84B).withOpacity(0.4)),
            ),
            child: Text(
              data.dominantElement,
              style: const TextStyle(
                color: Color(0xFFE8B84B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarsGrid() {
    final positions = ['년주', '월주', '일주', '시주'];
    final pillars = data.pillars.length == 4
        ? data.pillars
        : List.generate(4, (i) {
            if (i < data.pillars.length) return data.pillars[i];
            return SajuPillar(
                hanja: '??', korean: '??', element: '목', position: positions[i]);
          });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: _PillarCell(
              pillar: pillars[i],
              isDay: i == 2,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome,
              color: Color(0xFFE8B84B), size: 14),
          const SizedBox(width: 6),
          Text(
            '일주: ${data.dayPillar} (${data.dayPillarKorean})',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarCell extends StatelessWidget {
  final SajuPillar pillar;
  final bool isDay;

  const _PillarCell({required this.pillar, this.isDay = false});

  @override
  Widget build(BuildContext context) {
    final elementColor = _elementColor(pillar.element);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isDay
            ? const Color(0xFFE8B84B).withOpacity(0.1)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDay
              ? const Color(0xFFE8B84B).withOpacity(0.5)
              : Colors.white12,
          width: isDay ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          // 위치 레이블
          Text(
            pillar.position,
            style: TextStyle(
              color: isDay ? const Color(0xFFE8B84B) : Colors.white38,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          // 천간 한자
          _HanjaChar(
            char: pillar.hanja.length > 0 ? pillar.hanja[0] : '?',
            color: elementColor,
            fontSize: 28,
            isHighlight: isDay,
          ),
          const SizedBox(height: 2),
          // 천간 한글
          Text(
            pillar.korean.length > 0 ? pillar.korean[0] : '?',
            style: TextStyle(
              color: elementColor.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white12),
          const SizedBox(height: 12),
          // 지지 한자
          _HanjaChar(
            char: pillar.hanja.length > 1 ? pillar.hanja[1] : '?',
            color: Colors.white70,
            fontSize: 28,
            isHighlight: false,
          ),
          const SizedBox(height: 2),
          // 지지 한글
          Text(
            pillar.korean.length > 1 ? pillar.korean[1] : '?',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 10),
          // 오행 도트
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: elementColor,
              boxShadow: [
                BoxShadow(
                    color: elementColor.withOpacity(0.6),
                    blurRadius: 4,
                    spreadRadius: 1)
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _elementColor(String element) {
    switch (element) {
      case '목': return const Color(0xFF4CAF50);
      case '화': return const Color(0xFFE53935);
      case '토': return const Color(0xFFFF9800);
      case '금': return const Color(0xFFB0BEC5);
      case '수': return const Color(0xFF1E88E5);
      default: return Colors.white70;
    }
  }
}

class _HanjaChar extends StatelessWidget {
  final String char;
  final Color color;
  final double fontSize;
  final bool isHighlight;

  const _HanjaChar({
    required this.char,
    required this.color,
    required this.fontSize,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      char,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
        shadows: isHighlight
            ? [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                )
              ]
            : null,
      ),
    );
  }
}

class SajuMiniCard extends StatelessWidget {
  final SajuData data;
  const SajuMiniCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8B84B).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: data.pillars.map((p) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.hanja,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(p.position,
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          );
        }).toList(),
      ),
    );
  }
}