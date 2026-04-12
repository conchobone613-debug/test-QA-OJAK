import 'dart:math' as math;
import 'package:flutter/material.dart';

class OjakgoBridgeAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const OjakgoBridgeAnimation({super.key, this.onComplete});

  @override
  State<OjakgoBridgeAnimation> createState() => _OjakgoBridgeAnimationState();
}

class _OjakgoBridgeAnimationState extends State<OjakgoBridgeAnimation>
    with TickerProviderStateMixin {
  late AnimationController _bridgeController;
  late AnimationController _starController;
  late AnimationController _heartController;
  late Animation<double> _bridgeProgress;
  late Animation<double> _starRotation;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _bridgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bridgeProgress = CurvedAnimation(
      parent: _bridgeController,
      curve: Curves.easeInOut,
    );
    _starRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_starController);
    _heartScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    _bridgeController.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _bridgeController.dispose();
    _starController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _starRotation,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(300, 200),
                painter: _StarFieldPainter(_starRotation.value),
              );
            },
          ),
          AnimatedBuilder(
            animation: _bridgeProgress,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(300, 200),
                painter: _BridgePainter(_bridgeProgress.value),
              );
            },
          ),
          AnimatedBuilder(
            animation: _heartScale,
            builder: (context, _) {
              return Center(
                child: Transform.scale(
                  scale: _heartScale.value,
                  child: const Text('💕', style: TextStyle(fontSize: 40)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BridgePainter extends CustomPainter {
  final double progress;
  _BridgePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final gradient = LinearGradient(
      colors: const [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
    );

    final centerY = size.height * 0.6;
    final leftX = size.width * 0.15;
    final rightX = size.width * 0.85;
    final totalWidth = rightX - leftX;

    final path = Path();
    path.moveTo(leftX, centerY);

    final targetX = leftX + totalWidth * progress;
    final midX = leftX + totalWidth / 2;
    final controlY = centerY - 60;

    final currentPath = Path();
    currentPath.moveTo(leftX, centerY);

    for (double t = 0; t <= progress; t += 0.01) {
      final x = leftX + totalWidth * t;
      final bezierT = (x - leftX) / totalWidth;
      final y = centerY + (controlY - centerY) * 2 * bezierT * (1 - bezierT);
      if (t == 0) {
        currentPath.moveTo(x, y);
      } else {
        currentPath.lineTo(x, y);
      }
    }

    final rect = Rect.fromLTWH(leftX, controlY, totalWidth, centerY - controlY + 20);
    paint.shader = gradient.createShader(rect);
    canvas.drawPath(currentPath, paint);

    // Draw magpies
    if (progress < 0.45) {
      _drawBird(canvas, leftX + 10, centerY - 5, const Color(0xFFFF6B9D));
    }
    if (progress > 0.55) {
      _drawBird(canvas, rightX - 10, centerY - 5, const Color(0xFFFF8E53));
    }

    // Stars along bridge
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    final numStars = (progress * 8).floor();
    for (int i = 0; i < numStars; i++) {
      final t = i / 8.0;
      final x = leftX + totalWidth * t;
      final bezierT = (x - leftX) / totalWidth;
      final y = centerY + (controlY - centerY) * 2 * bezierT * (1 - bezierT);
      canvas.drawCircle(Offset(x, y), 2, starPaint);
    }
  }

  void _drawBird(Canvas canvas, double x, double y, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    path.moveTo(x - 8, y);
    path.quadraticBezierTo(x, y - 8, x + 8, y);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BridgePainter old) => old.progress != progress;
}

class _StarFieldPainter extends CustomPainter {
  final double rotation;
  _StarFieldPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final rng = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = rng.nextDouble() * 1.5 + 0.5;
      final opacity = (math.sin(rotation + i) + 1) / 2 * 0.6 + 0.2;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.rotation != rotation;
}