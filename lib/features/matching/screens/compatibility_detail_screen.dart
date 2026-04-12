import 'package:flutter/material.dart';
import '../providers/matching_provider.dart';
import '../widgets/compatibility_badge.dart';
import 'dart:math' as math;

class CompatibilityDetailScreen extends StatefulWidget {
  final FeedUser user;

  const CompatibilityDetailScreen({super.key, required this.user});

  @override
  State<CompatibilityDetailScreen> createState() => _CompatibilityDetailScreenState();
}

class _CompatibilityDetailScreenState extends State<CompatibilityDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late List<Animation<double>> _barAnimations;

  final List<_CategoryScore> _categories = [];

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final compat = widget.user.compatibility;
    _categories.addAll([
      _CategoryScore('❤️ 연애운', compat.love, '두 사람의 연애 에너지가 얼마나 잘 맞는지 나타냅니다.'),
      _CategoryScore('💬 소통력', compat.communication, '대화 스타일과 감정 표현 방식의 궁합입니다.'),
      _CategoryScore('🌟 가치관', compat.values, '삶의 방향과 중요하게 여기는 것들의 일치도입니다.'),
      _CategoryScore('🏡 미래비전', compat.future, '결혼, 가정, 미래 계획에 대한 호환성입니다.'),
      _CategoryScore('🎯 전체궁합', compat.overall, '사주 오행을 종합한 전체 궁합 점수입니다.'),
    ]);

    _barAnimations = _categories.map((_) =>
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _barController, curve: Curves.easeOut),
      )
    ).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _barController.forward();
    });
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  Color _scoreColor(int score) {
    if (score >= 90) return const Color(0xFFFF6B9D);
    if (score >= 80) return const Color(0xFFFF8E53);
    if (score >= 70) return const Color(0xFF7B68EE);
    if (score >= 60) return const Color(0xFF4ECDC4);
    return const Color(0xFF95A5A6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0520),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0520),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.user.nickname}님과의 궁합',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeroScore(),
            const SizedBox(height: 24),
            _buildScoreCards(),
            const SizedBox(height: 24),
            _buildAiInterpretation(),
            const SizedBox(height: 24),
            _buildCompatibilityChart(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroScore() {
    final compat = widget.user.compatibility;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.2),
            const Color(0xFF7B68EE).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '${compat.overall}점',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          CompatibilityBadge(
            grade: compat.grade,
            score: compat.overall,
            large: true,
          ),
          const SizedBox(height: 12),
          Text(
            compat.comment,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리별 궁합',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._categories.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          return AnimatedBuilder(
            animation: _barAnimations[i],
            builder: (context, _) {
              return _buildScoreBar(cat, _barAnimations[i].value);
            },
          );
        }),
      ],
    );
  }

  Widget _buildScoreBar(_CategoryScore cat, double animationValue) {
    final color = _scoreColor(cat.score);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(cat.label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '${cat.score}점',
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (cat.score / 100) * animationValue,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(cat.description, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildAiInterpretation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7B68EE).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B68EE).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🤖', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              const Text('AI 궁합 해석', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.user.compatibility.aiInterpretation,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 12),
          Text(
            '* 본 궁합 분석은 사주 오행 이론을 기반으로 하며, 참고용으로만 활용해 주세요.',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('궁합 레이더', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _barController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: _RadarChartPainter(
                    scores: [
                      widget.user.compatibility.love / 100,
                      widget.user.compatibility.communication / 100,
                      widget.user.compatibility.values / 100,
                      widget.user.compatibility.future / 100,
                      widget.user.compatibility.overall / 100,
                    ],
                    animationValue: _barController.value,
                    labels: const ['연애', '소통', '가치관', '미래', '전체'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryScore {
  final String label;
  final int score;
  final String description;
  _CategoryScore(this.label, this.score, this.description);
}

class _RadarChartPainter extends CustomPainter {
  final List<double> scores;
  final double animationValue;
  final List<String> labels;

  _RadarChartPainter({
    required this.scores,
    required this.animationValue,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 24;
    final n = scores.length;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int ring = 1; ring <= 4; ring++) {
      final r = maxRadius * ring / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = 2 * math.pi * i / n - math.pi / 2;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1;
    for (int i = 0; i < n; i++) {
      final angle = 2 * math.pi * i / n - math.pi / 2;
      canvas.drawLine(
        center,
        Offset(center.dx + maxRadius * math.cos(angle), center.dy + maxRadius * math.sin(angle)),
        axisPaint,
      );
    }

    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final angle = 2 * math.pi * i / n - math.pi / 2;
      final r = maxRadius * scores[i] * animationValue;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) dataPath.moveTo(x, y); else dataPath.lineTo(x, y);
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..color = const Color(0xFFFF6B9D).withOpacity(0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = const Color(0xFFFF6B9D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final angle = 2 * math.pi * i / n - math.pi / 2;
      final x = center.dx + (maxRadius + 18) * math.cos(angle);
      final y = center.dy + (maxRadius + 18) * math.sin(angle);
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RadarChartPainter old) =>
    old.animationValue != animationValue;
}