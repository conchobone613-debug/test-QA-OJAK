import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSocialLogin(SocialLoginType type) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithSocial(type);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: ${e.toString()}'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0221), Color(0xFF1A0533), Color(0xFF2D1B69)],
          ),
        ),
        child: Stack(
          children: [
            _StarBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LogoSection(),
                          const SizedBox(height: 48),
                          _GlassCard(
                            child: Column(
                              children: [
                                const Text(
                                  '소셜 계정으로 시작하기',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _SocialLoginButton(
                                  type: SocialLoginType.kakao,
                                  onPressed: _isLoading ? null : () => _handleSocialLogin(SocialLoginType.kakao),
                                ),
                                const SizedBox(height: 12),
                                _SocialLoginButton(
                                  type: SocialLoginType.apple,
                                  onPressed: _isLoading ? null : () => _handleSocialLogin(SocialLoginType.apple),
                                ),
                                const SizedBox(height: 12),
                                _SocialLoginButton(
                                  type: SocialLoginType.google,
                                  onPressed: _isLoading ? null : () => _handleSocialLogin(SocialLoginType.google),
                                ),
                                if (_isLoading) ...[
                                  const SizedBox(height: 20),
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE040FB)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '로그인 시 이용약관 및 개인정보처리방침에 동의합니다',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white30, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SimpleStarPainter(),
      size: Size.infinite,
    );
  }
}

class _SimpleStarPainter extends CustomPainter {
  final _positions = [
    [0.1, 0.1], [0.3, 0.05], [0.7, 0.12], [0.9, 0.08],
    [0.05, 0.3], [0.85, 0.25], [0.15, 0.6], [0.95, 0.55],
    [0.4, 0.85], [0.6, 0.9], [0.2, 0.75], [0.8, 0.8],
    [0.5, 0.2], [0.25, 0.45], [0.75, 0.4], [0.55, 0.65],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);
    for (final pos in _positions) {
      canvas.drawCircle(Offset(pos[0] * size.width, pos[1] * size.height), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE040FB).withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Text('오작교', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '사주로 찾는 나의 인연',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '운명이 정해준 그 사람을 만나세요',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.04),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback? onPressed;

  const _SocialLoginButton({required this.type, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: _borderSide,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon,
            const SizedBox(width: 12),
            Text(
              _label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case SocialLoginType.kakao:
        return const Color(0xFFFEE500);
      case SocialLoginType.apple:
        return Colors.white;
      case SocialLoginType.google:
        return const Color(0xFF4285F4);
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case SocialLoginType.kakao:
        return const Color(0xFF3C1E1E);
      case SocialLoginType.apple:
        return Colors.black;
      case SocialLoginType.google:
        return Colors.white;
    }
  }

  BorderSide get _borderSide {
    if (type == SocialLoginType.apple) return const BorderSide(color: Colors.black12);
    return BorderSide.none;
  }

  Widget get _icon {
    switch (type) {
      case SocialLoginType.kakao:
        return const Icon(Icons.chat_bubble, size: 20, color: Color(0xFF3C1E1E));
      case SocialLoginType.apple:
        return const Icon(Icons.apple, size: 22, color: Colors.black);
      case SocialLoginType.google:
        return const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white));
    }
  }

  String get _label {
    switch (type) {
      case SocialLoginType.kakao:
        return '카카오로 계속하기';
      case SocialLoginType.apple:
        return 'Apple로 계속하기';
      case SocialLoginType.google:
        return 'Google로 계속하기';
    }
  }
}