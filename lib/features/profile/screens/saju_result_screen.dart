import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../widgets/five_elements_chart.dart';
import '../widgets/saju_card.dart';

class SajuResultScreen extends ConsumerWidget {
  const SajuResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: profileAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFE8B84B))),
        error: (e, _) => Center(
            child: Text('오류가 발생했어요', style: TextStyle(color: Colors.white70))),
        data: (profile) => _ResultContent(profile: profile),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final UserProfile? profile;
  const _ResultContent({this.profile});

  @override
  Widget build(BuildContext context) {
    // 더미 사주 데이터 (실제로는 profile에서 계산)
    final sajuData = SajuData.dummy();

    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              _buildSummaryBanner(sajuData),
              const SizedBox(height: 24),
              SajuCard(data: sajuData),
              const SizedBox(height: 24),
              _buildElementsSection(sajuData),
              const SizedBox(height: 24),
              _buildAiAnalysis(sajuData),
              const SizedBox(height: 24),
              _buildCompatibilitySection(),
              const SizedBox(height: 40),
              _buildStartButton(context),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0D1A),
      pinned: true,
      expandedHeight: 120,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFE8B84B), Color(0xFFFFD700)],
          ).createShader(bounds),
          child: const Text(
            '사주 분석 완료',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildSummaryBanner(SajuData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE8B84B).withOpacity(0.2),
            const Color(0xFF1E3A5F).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8B84B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE8B84B), Color(0xFFB8860B)],
              ),
            ),
            child: Center(
              child: Text(
                data.dayMaster,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '일주: ${data.dayPillar}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  data.dayPillarKorean,
                  style: const TextStyle(
                      color: Color(0xFFE8B84B), fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '주원소: ${data.dominantElement}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementsSection(SajuData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('오행 분포'),
        const SizedBox(height: 16),
        FiveElementsChart(elements: data.elements),
        const SizedBox(height: 16),
        _ElementLegend(elements: data.elements),
      ],
    );
  }

  Widget _buildAiAnalysis(SajuData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle('AI 성격 분석'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B84B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8B84B).withOpacity(0.5)),
              ),
              child: const Text('AI',
                  style: TextStyle(color: Color(0xFFE8B84B), fontSize: 10)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...data.aiAnalysis.asMap().entries.map((entry) {
          return _AnalysisItem(
            index: entry.key + 1,
            text: entry.value,
          );
        }),
      ],
    );
  }

  Widget _buildCompatibilitySection() {
    const compatibleElements = ['수(水)', '금(金)'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('궁합 잘 맞는 오행'),
        const SizedBox(height: 12),
        Row(
          children: compatibleElements.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ElementChip(label: e),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => context.go('/home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8B84B),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          '매칭 시작하기 ✨',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _AnalysisItem extends StatelessWidget {
  final int index;
  final String text;
  const _AnalysisItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8B84B).withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                    color: Color(0xFFE8B84B),
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _ElementChip extends StatelessWidget {
  final String label;
  const _ElementChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _elementColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  static Color _elementColor(String e) {
    if (e.contains('목') || e.contains('木')) return const Color(0xFF4CAF50);
    if (e.contains('화') || e.contains('火')) return const Color(0xFFE53935);
    if (e.contains('토') || e.contains('土')) return const Color(0xFFFF9800);
    if (e.contains('금') || e.contains('金')) return const Color(0xFFB0BEC5);
    if (e.contains('수') || e.contains('水')) return const Color(0xFF1E88E5);
    return Colors.white;
  }
}

class _ElementLegend extends StatelessWidget {
  final Map<String, double> elements;
  const _ElementLegend({required this.elements});

  @override
  Widget build(BuildContext context) {
    final colors = {
      '목': const Color(0xFF4CAF50),
      '화': const Color(0xFFE53935),
      '토': const Color(0xFFFF9800),
      '금': const Color(0xFFB0BEC5),
      '수': const Color(0xFF1E88E5),
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: elements.entries.map((e) {
        final color = colors[e.key] ?? Colors.white;
        final pct = (e.value * 100).round();
        return Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color),
            ),
            const SizedBox(height: 4),
            Text(e.key, style: TextStyle(color: color, fontSize: 12)),
            Text('$pct%',
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        );
      }).toList(),
    );
  }
}