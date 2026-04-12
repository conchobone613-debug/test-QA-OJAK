import 'package:flutter/material.dart';
import '../providers/matching_provider.dart';
import '../widgets/compatibility_badge.dart';
import 'compatibility_detail_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final FeedUser user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late PageController _photoController;
  int _currentPhotoIndex = 0;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _photoController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _photoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0520),
      body: FadeTransition(
        opacity: _fadeController,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildBasicInfo(),
                  _buildCompatibilitySection(),
                  _buildBioSection(),
                  _buildSajuSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      backgroundColor: const Color(0xFF0D0520),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            _buildPhotoGallery(),
            _buildPhotoIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    final photos = widget.user.photoUrls;
    if (photos.isEmpty) {
      return Container(
        color: const Color(0xFF2A1A4E),
        child: Center(
          child: Icon(Icons.person, size: 100, color: Colors.white.withOpacity(0.3)),
        ),
      );
    }
    return PageView.builder(
      controller: _photoController,
      itemCount: photos.length,
      onPageChanged: (i) => setState(() => _currentPhotoIndex = i),
      itemBuilder: (context, index) {
        return Image.network(
          photos[index],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF2A1A4E),
            child: const Icon(Icons.image_not_supported, color: Colors.white38, size: 60),
          ),
        );
      },
    );
  }

  Widget _buildPhotoIndicator() {
    final count = widget.user.photoUrls.length;
    if (count <= 1) return const SizedBox();
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: i == _currentPhotoIndex ? 20 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == _currentPhotoIndex
                ? const Color(0xFFFF6B9D)
                : Colors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        )),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.user.nickname}, ${widget.user.age}세',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.user.sajuData['mbti'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.user.sajuData['mbti'],
                    style: const TextStyle(color: Color(0xFFFF6B9D), fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          CompatibilityBadge(
            grade: widget.user.compatibility.grade,
            score: widget.user.compatibility.overall,
            large: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilitySection() {
    final compat = widget.user.compatibility;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.15),
            const Color(0xFF7B68EE).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💕 궁합 분석', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompatibilityDetailScreen(user: widget.user),
                  ),
                ),
                child: const Text('자세히 보기 >', style: TextStyle(color: Color(0xFFFF6B9D), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            compat.comment,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildMiniScoreBar('연애운', compat.love),
          const SizedBox(height: 6),
          _buildMiniScoreBar('소통', compat.communication),
          const SizedBox(height: 6),
          _buildMiniScoreBar('가치관', compat.values),
        ],
      ),
    );
  }

  Widget _buildMiniScoreBar(String label, int score) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B9D)),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$score', style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildBioSection() {
    if (widget.user.bio.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✏️ 자기소개', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.user.bio, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSajuSection() {
    final saju = widget.user.sajuData;
    if (saju.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔮 오행 분석', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildWuXingChart(saju),
        ],
      ),
    );
  }

  Widget _buildWuXingChart(Map<String, dynamic> saju) {
    final elements = [
      ('木 목', saju['wood'] ?? 20, const Color(0xFF4CAF50)),
      ('火 화', saju['fire'] ?? 20, const Color(0xFFFF5722)),
      ('土 토', saju['earth'] ?? 20, const Color(0xFFFF9800)),
      ('金 금', saju['metal'] ?? 20, const Color(0xFFFFD700)),
      ('水 수', saju['water'] ?? 20, const Color(0xFF2196F3)),
    ];

    return Column(
      children: elements.map((e) {
        final (label, value, color) = e;
        final score = (value as num).toDouble();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${score.toInt()}%', style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0D0520),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6B7280)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('패스', style: TextStyle(color: Color(0xFF6B7280))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('좋아요', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}