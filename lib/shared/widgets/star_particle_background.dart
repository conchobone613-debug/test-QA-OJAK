import 'dart:math';
import 'package:flutter/material.dart';

class StarParticleBackground extends StatefulWidget {
  final Widget? child;
  final int particleCount;
  final Color primaryColor;
  final Color secondaryColor;
  final bool animate;

  const StarParticleBackground({
    super.key,
    this.child,
    this.particleCount = 80,
    this.primaryColor = const Color(0xFFFFD700),
    this.secondaryColor = const Color(0xFFE8E8FF),
    this.animate = true,
  });

  @override
  State<StarParticleBackground> createState() => _StarParticleBackgroundState();
}

class _StarParticleBackgroundState extends State<StarParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _twinkleController;
  late AnimationController _driftController;
  late List<_StarParticle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (i) => _StarParticle.random(_random, i),
    );
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_twinkleController, _driftController]),
          builder: (context, _) => CustomPaint(
            painter: _StarParticlePainter(
              particles: _particles,
              twinkleValue: _twinkleController.value,
              driftValue: _driftController.value,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _StarParticle {
  final double x;
  final double y;
  final double radius;
  final double twinkleOffset;
  final double driftSpeed;
  final double driftAmplitude;
  final bool isGold;

  const _StarParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.twinkleOffset,
    required this.driftSpeed,
    required this.driftAmplitude,
    required this.isGold,
  });

  factory _StarParticle.random(Random rng, int index) {
    return _StarParticle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      radius: rng.nextDouble() * 2 + 0.5,
      twinkleOffset: rng.nextDouble(),
      driftSpeed: rng.nextDouble() * 0.5 + 0.2,
      driftAmplitude: rng.nextDouble() * 0.01,
      isGold: rng.nextDouble() < 0.2,
    );
  }
}

class _StarParticlePainter extends CustomPainter {
  final List<_StarParticle> particles;
  final double twinkleValue;
  final double driftValue;
  final Color primaryColor;
  final Color secondaryColor;

  _StarParticlePainter({
    required this.particles,
    required this.twinkleValue,
    required this.driftValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final twinkle = (sin((twinkleValue + p.twinkleOffset) * pi * 2) + 1) / 2;
      final opacity = 0.3 + twinkle * 0.7;

      final driftX = p.x + sin(driftValue * 2 * pi * p.driftSpeed) * p.driftAmplitude;
      final driftY = p.y + cos(driftValue * 2 * pi * p.driftSpeed) * p.driftAmplitude;

      final px = driftX * size.width;
      final py = driftY * size.height;

      final color = p.isGold ? primaryColor : secondaryColor;

      if (p.radius > 1.5) {
        _drawStar(canvas, Offset(px, py), p.radius, color.withOpacity(opacity));
      } else {
        final paint = Paint()
          ..color = color.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.5);
        canvas.drawCircle(Offset(px, py), p.radius, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const spikes = 4;
    final outerRadius = radius;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < spikes * 2; i++) {
      final angle = (i * pi / spikes) - pi / 2;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 1.5);
    canvas.drawCircle(center, radius, glowPaint);
  }

  @override
  bool shouldRepaint(_StarParticlePainter oldDelegate) =>
      oldDelegate.twinkleValue != twinkleValue ||
      oldDelegate.driftValue != driftValue;
}