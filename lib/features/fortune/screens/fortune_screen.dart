import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/fortune_provider.dart';
import '../widgets/fortune_card.dart';
import 'my_saju_screen.dart';
import 'compatibility_check_screen.dart';
import 'fortune_report_screen.dart';

class FortuneScreen extends ConsumerWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fortuneProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a0533),
              Color(0xFF0d1b4b),
              Color(0xFF0a2744),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(fortuneProvider.notifier).loadDailyFortune(forceRefresh: true),
            color: const Color(0xFFD4A8FF),
            child: CustomScrollView(
              slivers: [
                _buildHeader(context),
                if (state.isDailyLoading)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFFD4A8FF))))
                else if (state.dailyError != null)
                  SliverFillRemaining(child: _buildError(context, ref, state.dailyError!))
                else if (state.dailyFortune != null) ...[
                  _buildOverallSection(context, state.dailyFortune!),
                  _buildFortuneCards(context, state.dailyFortune!),
                  _buildLuckyInfo(context, state.dailyFortune!),
                  _buildAdviceSection(context, state.dailyFortune!),
                  _buildQuickActions(context),
                  _buildMonthlyPreviews(context, state),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 운세',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${now.year}년 ${now.month}월 ${now.day}일 ($weekday)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('🔮', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSection(BuildContext context, DailyFortune fortune) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9B59B6).withOpacity(0.3),
                    const Color(0xFF3498DB).withOpacity(0.2),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircularScore(fortune.overallScore),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '총운',
                              style: TextStyle(
                                color: Color(0xFFD4A8FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              fortune.overall,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularScore(int score) {
    Color scoreColor;
    if (score >= 80) scoreColor = const Color(0xFFFFD700);
    else if (score >= 65) scoreColor = const Color(0xFF9B59B6);
    else scoreColor = const Color(0xFF3498DB);

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 6,
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '점',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneCards(BuildContext context, DailyFortune fortune) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          FortuneCard(
            title: fortune.love.name,
            icon: fortune.love.icon,
            score: fortune.love.score,
            description: fortune.love.description,
            accentColor: const Color(0xFFFF6B9D),
          ),
          const SizedBox(height: 12),
          FortuneCard(
            title: fortune.money.name,
            icon: fortune.money.icon,
            score: fortune.money.score,
            description: fortune.money.description,
            accentColor: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 12),
          FortuneCard(
            title: fortune.health.name,
            icon: fortune.health.icon,
            score: fortune.health.score,
            description: fortune.health.description,
            accentColor: const Color(0xFF2ECC71),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildLuckyInfo(BuildContext context, DailyFortune fortune) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '행운의 열쇠 🗝️',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: LuckyInfoChip(
                    label: '행운의 시간',
                    value: fortune.luckyTime,
                    icon: Icons.access_time_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LuckyInfoChip(
                    label: '행운의 색',
                    value: fortune.luckyColor,
                    icon: Icons.palette_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LuckyInfoChip(
                    label: '행운의 숫자',
                    value: fortune.luckyNumber,
                    icon: Icons.tag_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceSection(BuildContext context, DailyFortune fortune) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 조언',
                          style: TextStyle(
                            color: Color(0xFFD4A8FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fortune.advice,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '더 알아보기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: '🀄',
                    title: '내 사주',
                    subtitle: '사주 원국 분석',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MySajuScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    icon: '💑',
                    title: '궁합 보기',
                    subtitle: '상대방과의 궁합',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CompatibilityCheckScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    icon: '📋',
                    title: '월간 리포트',
                    subtitle: '상세 운세 보기',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FortuneReportScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyPreviews(BuildContext context, FortuneState state) {
    if (state.monthlyPreviews.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '앞으로의 운세 미리보기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...state.monthlyPreviews.map((preview) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MonthlyPreviewTile(preview: preview),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😢', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(fortuneProvider.notifier).loadDailyFortune(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyPreviewTile extends StatelessWidget {
  final MonthlyFortunePreview preview;

  const _MonthlyPreviewTile({required this.preview});

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    if (preview.score >= 80) scoreColor = const Color(0xFFFFD700);
    else if (preview.score >= 65) scoreColor = const Color(0xFF9B59B6);
    else scoreColor = const Color(0xFF3498DB);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${preview.month}월',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preview.headline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '키워드: ${preview.keyword}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${preview.score}점',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}