import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../providers/matching_provider.dart';
import '../widgets/match_animation.dart';
import '../widgets/compatibility_badge.dart';

class MatchSuccessScreen extends StatefulWidget {
  final FeedUser matchedUser;

  const MatchSuccessScreen({super.key, required this.matchedUser});

  @override
  State<MatchSuccessScreen> createState() => _MatchSuccessScreenState();
}

class _MatchSuccessScreenState extends State<MatchSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late Animation<double> _entranceScale;
  late Animation<double> _entranceOpacity;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _entranceScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _entranceOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeIn),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0520),
      body: Stack(
        children: [
          _buildStarBackground(),
          AnimatedBuilder(
            animation: _confettiController,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ConfettiPainter(_confettiController.value),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _entranceOpacity,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _entranceScale,
                    child: _buildMatchTitle(),
                  ),
                  const SizedBox(height: 24),
                  _buildProfilePair(),
                  const SizedBox(height: 24),
                  OjakgoBridgeAnimation(
                    onComplete: () {},
                  ),
                  const SizedBox(height: 24),
                  ScaleTransition(
                    scale: _pulseScale,
                    child: _buildCompatibilityScore(),
                  ),
                  const Spacer(),
                  _buildActions(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchTitle() {
    return Column(
      children: [
        const Text('✨', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        const Text(
          '인연이 이어졌어요!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오작교가 두 분을 연결했습니다',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProfilePair() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProfileCircle('나', null, const Color(0xFF7B68EE)),
        const SizedBox(width: 16),
        const Text('💕', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 16),
        _buildProfileCircle(
          widget.matchedUser.nickname,
          widget.matchedUser.photoUrls.isNotEmpty ? widget.matchedUser.photoUrls.first : null,
          const Color(0xFFFF6B9D),
        ),
      ],
    );
  }

  Widget _buildProfileCircle(String name, String? photoUrl, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16)],
          ),
          child: ClipOval(
            child: photoUrl != null
                ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatarFallback(color))
                : _avatarFallback(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _avatarFallback(Color color) {
    return Container(
      color: color.withOpacity(0.2),
      child: Icon(Icons.person, color: color, size: 40),
    );
  }

  Widget _buildCompatibilityScore() {
    final score = widget.matchedUser.compatibility.overall;
    final grade = widget.matchedUser.compatibility.grade;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFF7B68EE)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('궁합 점수', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '$score점',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          CompatibilityBadge(grade: grade, score: score, large: true),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to chat screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 8,
                shadowColor: const Color(0xFFFF6B9D).withOpacity(0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    '대화 시작하기',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 둘러보기', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildStarBackground() {
    return CustomPaint(
      size: Size.infinite,
      painter: _StaticStarPainter(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(12);
    final colors = [
      const Color(0xFFFF6B9D),
      const Color(0xFF7B68EE),
      const Color(0xFFFFD700),
      const Color(0xFF4ECDC4),
      const Color(0xFFFF8E53),
    ];
    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final startY = -20.0;
      final speed = rng.nextDouble() * 0.6 + 0.2;
      final y = startY + (size.height + 40) * ((progress * speed + rng.nextDouble()) % 1.0);
      final color = colors[i % colors.length];
      final paint = Paint()..color = color.withOpacity(0.8);
      final rotation = progress * math.pi * 4 + i;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRect(const Rect.fromLTWH(-4, -2, 8, 4), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _StaticStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rng = math.Random(55);
    for (int i = 0; i < 100; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.5 + 0.3;
      paint.color = Colors.white.withOpacity(rng.nextDouble() * 0.4 + 0.1);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StaticStarPainter old) => false;
}