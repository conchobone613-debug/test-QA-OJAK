import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final notifier = ref.read(subscriptionProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('구독 관리'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: subscription.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CurrentTierBanner(tier: subscription.tier),
                const SizedBox(height: 24),
                const _SectionHeader('요금제 비교'),
                const SizedBox(height: 16),
                _ComparisonTable(currentTier: subscription.tier),
                const SizedBox(height: 24),
                if (subscription.tier != 'premium') ...[
                  if (subscription.tier != 'plus')
                    _PurchaseButton(
                      label: 'Plus 구독 (₩9,900/월)',
                      color: Colors.blue,
                      onPressed: subscription.isPurchasing
                          ? null
                          : () => notifier.purchasePlus(context),
                    ),
                  const SizedBox(height: 12),
                  _PurchaseButton(
                    label: 'Premium 구독 (₩19,900/월)',
                    color: const Color(0xFFFFA500),
                    onPressed: subscription.isPurchasing
                        ? null
                        : () => notifier.purchasePremium(context),
                  ),
                ],
                if (subscription.tier != 'free') ...[
                  const SizedBox(height: 12),
                  _RestoreButton(
                    onPressed: () => notifier.restorePurchases(context),
                  ),
                ],
                const SizedBox(height: 24),
                const _TermsFooter(),
              ],
            ),
    );
  }
}

class _CurrentTierBanner extends StatelessWidget {
  final String tier;
  const _CurrentTierBanner({required this.tier});

  static const Map<String, Map<String, dynamic>> _tierInfo = {
    'free': {'label': '무료', 'color': Colors.grey, 'icon': Icons.person},
    'plus': {'label': 'Plus', 'color': Colors.blue, 'icon': Icons.star},
    'premium': {
      'label': 'Premium',
      'color': Colors.orange,
      'icon': Icons.workspace_premium,
    },
  };

  @override
  Widget build(BuildContext context) {
    final info = _tierInfo[tier] ?? _tierInfo['free']!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (info['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: info['color'] as Color, width: 2),
      ),
      child: Row(
        children: [
          Icon(info['icon'] as IconData, color: info['color'] as Color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('현재 구독', style: TextStyle(color: Colors.grey)),
              Text(
                info['label'] as String,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: info['color'] as Color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final String currentTier;
  const _ComparisonTable({required this.currentTier});

  static const List<Map<String, dynamic>> _features = [
    {'name': '일일 좋아요', 'free': '5회', 'plus': '30회', 'premium': '무제한'},
    {'name': '사주 궁합 조회', 'free': '3회/일', 'plus': '20회/일', 'premium': '무제한'},
    {'name': '프로필 상세 보기', 'free': '❌', 'plus': '✅', 'premium': '✅'},
    {'name': '읽음 확인', 'free': '❌', 'plus': '✅', 'premium': '✅'},
    {'name': '슈퍼 좋아요', 'free': '❌', 'plus': '1회/일', 'premium': '3회/일'},
    {'name': '광고 제거', 'free': '❌', 'plus': '❌', 'premium': '✅'},
    {'name': 'AI 대화 추천', 'free': '❌', 'plus': '❌', 'premium': '✅'},
    {'name': '월 비용', 'free': '무료', 'plus': '₩9,900', 'premium': '₩19,900'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _TableHeader(currentTier: currentTier),
          const Divider(height: 1),
          ..._features.map((f) => _TableRow(feature: f, currentTier: currentTier)),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String currentTier;
  const _TableHeader({required this.currentTier});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 2, child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('기능', style: TextStyle(fontWeight: FontWeight.bold)),
        )),
        _HeaderCell('무료', isActive: currentTier == 'free', color: Colors.grey),
        _HeaderCell('Plus', isActive: currentTier == 'plus', color: Colors.blue),
        _HeaderCell('Premium', isActive: currentTier == 'premium', color: Colors.orange),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  const _HeaderCell(this.label, {required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isActive
            ? BoxDecoration(color: color.withOpacity(0.1))
            : null,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? color : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final Map<String, dynamic> feature;
  final String currentTier;
  const _TableRow({required this.feature, required this.currentTier});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(feature['name'] as String, style: const TextStyle(fontSize: 13)),
              ),
            ),
            _DataCell(feature['free'] as String, isActive: currentTier == 'free'),
            _DataCell(feature['plus'] as String, isActive: currentTier == 'plus'),
            _DataCell(feature['premium'] as String, isActive: currentTier == 'premium'),
          ],
        ),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}

class _DataCell extends StatelessWidget {
  final String value;
  final bool isActive;
  const _DataCell(this.value, {required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        color: isActive ? Colors.blue.withOpacity(0.05) : null,
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _PurchaseButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _RestoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RestoreButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text('구매 복원'),
    );
  }
}

class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '구독은 Google Play 또는 App Store 계정으로 청구됩니다.\n'
      '구독 기간이 끝나기 24시간 전에 자동으로 갱신됩니다.\n'
      '구독 관리 및 취소는 스토어 계정 설정에서 가능합니다.',
      style: TextStyle(fontSize: 11, color: Colors.grey),
      textAlign: TextAlign.center,
    );
  }
}