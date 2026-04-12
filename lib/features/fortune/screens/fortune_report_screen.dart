import 'package:flutter/material.dart';
import 'dart:ui';

class FortuneReportScreen extends StatefulWidget {
  const FortuneReportScreen({super.key});

  @override
  State<FortuneReportScreen> createState() => _FortuneReportScreenState();
}

class _FortuneReportScreenState extends State<FortuneReportScreen> {
  bool _isMonthly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0533), Color(0xFF0d1b4b), Color(0xFF0a2744)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              _buildToggle(),
              _buildPremiumBanner(),
              _buildFreePreview(),
              _buildLockedContent(),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              _isMonthly ? '월간 운세 리포트' : '연간 운세 리포트',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Text('📋', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(child: _ToggleButton(label: '월간', selected: _isMonthly, onTap: () => setState(() => _isMonthly = true))),
                  Expanded(child: _ToggleButton(label: '연간', selected: !_isMonthly, onTap: () => setState(() => _isMonthly = false))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    final now = DateTime.now();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9B59B6).withOpacity(0.4),
                    const Color(0xFF3498DB).withOpacity(0.3),
                  ],
                ),
                border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isMonthly
                              ? '${now.year}년 ${now.month}월 운세'
                              : '${now.year}년 연간 운세',
                          style: const TextStyle(
                            color: Color(0xFFD4A8FF),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isMonthly ? '이번 달의 상세 운세 분석' : '올해의 전체 운세 흐름',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isMonthly
                              ? '연애, 재물, 건강, 직업 등 분야별 심층 분석'
                              : '12개월 운세 흐름 + 대운(大運) 분석',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('🔮', style: TextStyle(fontSize: 40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFreePreview() {
    final previewItems = _isMonthly ? _monthlyPreviewItems() : _yearlyPreviewItems();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('무료 미리보기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('FREE', style: TextStyle(color: Color(0xFF2ECC71), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...previewItems.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReportItem(
                title: item['title']!,
                content: item['content']!,
                icon: item['icon']!,
                isLocked: false,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedContent() {
    final allItems = _isMonthly ? _monthlyPreviewItems() : _yearlyPreviewItems();
    final lockedItems = allItems.skip(2).toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('프리미엄 전용', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 12),
                      SizedBox(width: 3),
                      Text('PREMIUM', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...lockedItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReportItem(
                title: item['title']!,
                content: item['content']!,
                icon: item['icon']!,
                isLocked: true,
              ),
            )),
            const SizedBox(height: 20),
            _buildUnlockButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockButton() {
    return GestureDetector(
      onTap: () => _showPremiumDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFF39C12)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              '프리미엄으로 전체 리포트 보기',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a0533),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('⭐', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('프리미엄 구독', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '월간/연간 상세 운세 리포트를 포함한 모든 프리미엄 기능을 이용하세요.',
              style: TextStyle(color: Colors.white.withOpacity(0.75), height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '월 ₩9,900 / 연 ₩79,900',
                style: TextStyle(color: Color(0xFFD4A8FF), fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('나중에', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6),
            ),
            child: const Text('구독하기'),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _monthlyPreviewItems() => [
    {'icon': '🌟', 'title': '이달의 총운', 'content': '이번 달은 새로운 시작의 기운이 강합니다. 적극적인 도전이 좋은 결과를 가져올 것입니다.'},
    {'icon': '💕', 'title': '연애/결혼운', 'content': '인연을 만날 수 있는 좋은 기회의 달입니다. 솔직한 감정 표현이 관계 발전에 도움이 됩니다.'},
    {'icon': '💰', 'title': '재물/직업운', 'content': '수입이 늘어날 수 있는 기회가 생깁니다. 새로운 프로젝트나 부업에 도전해보세요. (프리미엄 전용)'},
    {'icon': '🌿', 'title': '건강운', 'content': '체력 관리에 특히 신경 써야 하는 시기입니다. 규칙적인 운동을 시작하기 좋은 달입니다. (프리미엄 전용)'},
    {'icon': '🎯', 'title': '이달의 주의사항', 'content': '충동적인 결정을 피하고 신중하게 행동하세요. 특히 중순 이후 신중함이 필요합니다. (프리미엄 전용)'},
    {'icon': '📅', 'title': '주간별 운세 흐름', 'content': '1~2주차: 상승세 / 3주차: 안정기 / 4주차: 마무리 시기. (프리미엄 전용)'},
  ];

  List<Map<String, String>> _yearlyPreviewItems() => [
    {'icon': '🌟', 'title': '올해의 대운(大運)', 'content': '올해는 변화와 성장의 해입니다. 새로운 기회가 많이 찾아오는 한 해가 될 것입니다.'},
    {'icon': '💫', 'title': '상반기 운세', 'content': '1~6월은 기반을 다지는 시기입니다. 준비하고 실력을 쌓으면 하반기에 빛을 발합니다.'},
    {'icon': '🔥', 'title': '하반기 운세', 'content': '7~12월은 그동안의 노력이 결실을 맺는 시기입니다. 적극적인 활동이 권장됩니다. (프리미엄 전용)'},
    {'icon': '💰', 'title': '올해의 재물운', 'content': '재물의 흐름이 좋은 해입니다. 투자보다는 저축과 안정적인 재무 계획이 유리합니다. (프리미엄 전용)'},
    {'icon': '💕', 'title': '올해의 인연운', 'content': '중요한 인연이 찾아오는 해입니다. 봄과 가을에 특별한 만남이 예상됩니다. (프리미엄 전용)'},
    {'icon': '📊', 'title': '월별 운세 그래프', 'content': '12개월 운세 점수 그래프와 최고/최저 시기 분석. (프리미엄 전용)'},
  ];
}

class _ReportItem extends StatelessWidget {
  final String title;
  final String content;
  final String icon;
  final bool isLocked;

  const _ReportItem({
    required this.title,
    required this.content,
    required this.icon,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.white.withOpacity(0.04)
                    : Colors.white.withOpacity(0.09),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLocked
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    icon,
                    style: TextStyle(
                      fontSize: 22,
                      color: isLocked ? null : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isLocked ? Colors.white.withOpacity(0.4) : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        isLocked
                            ? Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                            : Text(
                                content,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                        if (isLocked) ...[
                          const SizedBox(height: 6),
                          Container(
                            height: 12,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isLocked) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 18),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF9B59B6).withOpacity(0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}