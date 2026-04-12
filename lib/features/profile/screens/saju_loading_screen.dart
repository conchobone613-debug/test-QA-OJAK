import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SajuLoadingScreen extends StatefulWidget {
  const SajuLoadingScreen({super.key});

  @override
  State<SajuLoadingScreen> createState() => _SajuLoadingScreenState();
}

class _SajuLoadingScreenState extends State<SajuLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _textController;
  late Animation<double> _pulseAnimation;

  int _currentMessageIndex = 0;
  final List<String> _messages = [
    '당신의 사주를 분석하고 있어요...',
    '오행의 기운을 읽고 있어요...',
    '천간과 지지를 계산하고 있어요...',
    '타고난 운명을 해석하고 있어요...',
    '당신만의 사주 원국을 완성하고 있어요...',
  ];

  static const List<_ElementData> _elements = [
    _ElementData('木', '목', Color(0xFF4CAF50), 0),
    _ElementData('火', '화', Color(0xFFE53935), 72),
    _ElementData('土', '토', Color(0xFFFF9800), 144),
    _ElementData('金', '금', Color(0xFFB0BEC5), 216),
    _ElementData('水', '수', Color(0xFF1E88E5), 288),
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startMessageCycle();
    _navigateAfterDelay();
  }

  void _startMessageCycle() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return false;
      await _textController.forward();
      setState(() {
        _currentMessageIndex =
            (_currentMessageIndex + 1) % _messages.length;
      });
      await _textController.reverse();
      return mounted;
    });
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      context.go('/saju-result');
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            _buildTitle(),
            const Spacer(flex: 1),
            _buildAnimationCore(),
            const Spacer(flex: 1),
            _buildMessageArea(),
            const Spacer(flex: 2),
            _buildProgressBar(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFE8B84B), Color(0xFFFFD700)],
          ).createShader(bounds),
          child: const Text(
            '사주 분석 중',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '잠시만 기다려 주세요',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAnimationCore() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 광채
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8B84B).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 오행 궤도
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, _) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    children: _elements.map((e) {
                      final angle = (e.baseAngle * pi / 180);
                      final radius = 90.0;
                      final dx = 110 + radius * cos(angle) - 28;
                      final dy = 110 + radius * sin(angle) - 28;
                      return Positioned(
                        left: dx,
                        top: dy,
                        child: Transform.rotate(
                          angle: -_rotationController.value * 2 * pi,
                          child: _ElementOrb(data: e),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          // 중앙 태극 심볼
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8B84B), Color(0xFFB8860B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8B84B).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '☯',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_textController),
        child: Text(
          _messages[_currentMessageIndex],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _rotationController,
            builder: (_, __) {
              return LinearProgressIndicator(
                value: _rotationController.value,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFE8B84B)),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ElementData {
  final String hanja;
  final String korean;
  final Color color;
  final double baseAngle;

  const _ElementData(this.hanja, this.korean, this.color, this.baseAngle);
}

class _ElementOrb extends StatelessWidget {
  final _ElementData data;
  const _ElementOrb({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: data.color.withOpacity(0.2),
        border: Border.all(color: data.color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data.hanja,
              style: TextStyle(
                  color: data.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(data.korean,
              style: TextStyle(color: data.color.withOpacity(0.7), fontSize: 9)),
        ],
      ),
    );
  }
}