import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'dart:math' as math;
import '../providers/matching_provider.dart';
import '../widgets/swipe_card.dart';
import 'user_detail_screen.dart';
import 'match_success_screen.dart';

class MatchFeedScreen extends ConsumerStatefulWidget {
  const MatchFeedScreen({super.key});

  @override
  ConsumerState<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _MatchFeedScreenState extends ConsumerState<MatchFeedScreen>
    with TickerProviderStateMixin {
  late AppinioSwiperController _swiperController;
  late AnimationController _starController;
  late AnimationController _actionController;
  late Animation<double> _actionScale;

  SwipeAction? _lastAction;
  bool _showActionFeedback = false;

  @override
  void initState() {
    super.initState();
    _swiperController = AppinioSwiperController();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _actionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _actionScale = CurvedAnimation(parent: _actionController, curve: Curves.elasticOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchingProvider.notifier).loadFeed();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _starController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  void _handleSwipe(FeedUser user, SwipeAction action) {
    setState(() {
      _lastAction = action;
      _showActionFeedback = true;
    });
    _actionController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showActionFeedback = false);
    });
    ref.read(matchingProvider.notifier).swipe(user, action);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchingProvider);

    if (state.isMatchSuccess && state.matchedUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MatchSuccessScreen(matchedUser: state.matchedUser!),
          ),
        ).then((_) => ref.read(matchingProvider.notifier).clearMatch());
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0520),
      body: Stack(
        children: [
          _buildStarBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: state.isLoading && state.feedUsers.isEmpty
                      ? _buildLoadingState()
                      : state.feedUsers.isEmpty
                          ? _buildEmptyState()
                          : _buildSwipeArea(state),
                ),
                _buildActionButtons(state),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (_showActionFeedback) _buildActionFeedback(),
        ],
      ),
    );
  }

  Widget _buildStarBackground() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _StarBackgroundPainter(_starController.value),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text(
            '오작교',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const Text(' ✨', style: TextStyle(fontSize: 20)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeArea(MatchingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppinioSwiper(
        controller: _swiperController,
        cardCount: state.feedUsers.length,
        cardBuilder: (context, index) {
          if (index >= state.feedUsers.length) return const SizedBox();
          final user = state.feedUsers[index];
          return SwipeCard(
            user: user,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserDetailScreen(user: user),
              ),
            ),
          );
        },
        onSwipeEnd: (previousIndex, targetIndex, activity) {
          if (previousIndex >= state.feedUsers.length) return;
          final user = state.feedUsers[previousIndex];
          SwipeAction action = SwipeAction.pass;
          if (activity is Swipe) {
            action = activity.direction == AxisDirection.right
                ? SwipeAction.like
                : SwipeAction.pass;
          }
          _handleSwipe(user, action);
        },
        swipeOptions: const SwipeOptions.symmetric(horizontal: true, vertical: false),
        backgroundCardCount: 2,
        backgroundCardScale: 0.9,
        backgroundCardOffset: const Offset(0, -20),
      ),
    );
  }

  Widget _buildActionButtons(MatchingState state) {
    if (state.feedUsers.isEmpty) return const SizedBox(height: 80);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.close,
            color: const Color(0xFF6B7280),
            size: 56,
            onTap: () {
              if (state.feedUsers.isNotEmpty) {
                _handleSwipe(state.feedUsers.first, SwipeAction.pass);
                _swiperController.swipeLeft();
              }
            },
          ),
          _ActionButton(
            icon: Icons.star,
            color: const Color(0xFF7B68EE),
            size: 48,
            onTap: () {
              if (state.feedUsers.isNotEmpty) {
                _handleSwipe(state.feedUsers.first, SwipeAction.superLike);
                _swiperController.swipeTop();
              }
            },
          ),
          _ActionButton(
            icon: Icons.favorite,
            color: const Color(0xFFFF6B9D),
            size: 56,
            onTap: () {
              if (state.feedUsers.isNotEmpty) {
                _handleSwipe(state.feedUsers.first, SwipeAction.like);
                _swiperController.swipeRight();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionFeedback() {
    if (_lastAction == null) return const SizedBox();
    final (icon, color, label) = switch (_lastAction!) {
      SwipeAction.like => (Icons.favorite, const Color(0xFFFF6B9D), 'LIKE'),
      SwipeAction.pass => (Icons.close, const Color(0xFF6B7280), 'PASS'),
      SwipeAction.superLike => (Icons.star, const Color(0xFF7B68EE), 'SUPER'),
    };
    return Center(
      child: ScaleTransition(
        scale: _actionScale,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(icon, color: color, size: 60),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFFFF6B9D)),
          SizedBox(height: 16),
          Text('인연을 찾고 있어요...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌙', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            '오늘의 추천이 모두 끝났어요',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '내일 새로운 인연이 기다려요',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(matchingProvider.notifier).loadFeed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('다시 불러오기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A0A2E),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}

class _StarBackgroundPainter extends CustomPainter {
  final double time;
  _StarBackgroundPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rng = math.Random(99);
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.8 + 0.3;
      final opacity = (math.sin(time * 2 * math.pi + i) + 1) / 2 * 0.5 + 0.15;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarBackgroundPainter old) => old.time != time;
}