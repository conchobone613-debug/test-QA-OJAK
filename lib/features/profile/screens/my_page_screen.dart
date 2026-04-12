import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscription/providers/subscription_provider.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final subscription = ref.watch(subscriptionProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(user: user),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _SubscriptionBanner(tier: subscription.tier),
                const SizedBox(height: 8),
                _MenuSection(
                  title: '프로필',
                  items: [
                    _MenuItem(
                      icon: Icons.edit,
                      label: '프로필 편집',
                      onTap: () => context.push('/edit-profile'),
                    ),
                    _MenuItem(
                      icon: Icons.auto_awesome,
                      label: '사주 정보',
                      onTap: () => context.push('/saju-detail'),
                    ),
                  ],
                ),
                _MenuSection(
                  title: '활동',
                  items: [
                    _MenuItem(
                      icon: Icons.favorite_border,
                      label: '받은 좋아요',
                      onTap: () => context.push('/received-likes'),
                    ),
                    _MenuItem(
                      icon: Icons.history,
                      label: '매칭 히스토리',
                      onTap: () => context.push('/match-history'),
                    ),
                  ],
                ),
                _MenuSection(
                  title: '구독',
                  items: [
                    _MenuItem(
                      icon: Icons.workspace_premium,
                      label: '구독 관리',
                      trailing: _TierBadge(tier: subscription.tier),
                      onTap: () => context.push('/subscription'),
                    ),
                  ],
                ),
                _MenuSection(
                  title: '지원',
                  items: [
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: '고객센터',
                      onTap: () => context.push('/support'),
                    ),
                    _MenuItem(
                      icon: Icons.description_outlined,
                      label: '이용약관',
                      onTap: () => context.push('/terms'),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: '개인정보처리방침',
                      onTap: () => context.push('/privacy'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _ProfileAvatar(photoUrl: user?.photoUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.nickname ?? '닉네임 없음',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.sajuOneLiner ?? '사주 정보를 입력해주세요',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _OhangIcons(ohang: user?.ohang),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  const _ProfileAvatar({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white24,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? const Icon(Icons.person, size: 40, color: Colors.white)
          : null,
    );
  }
}

class _OhangIcons extends StatelessWidget {
  final Map<String, dynamic>? ohang;
  const _OhangIcons({this.ohang});

  static const Map<String, String> _emojis = {
    'wood': '🌳',
    'fire': '🔥',
    'earth': '🌍',
    'metal': '⚙️',
    'water': '💧',
  };

  @override
  Widget build(BuildContext context) {
    if (ohang == null) return const SizedBox.shrink();
    return Row(
      children: _emojis.entries.map((e) {
        final count = ohang![e.key] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            '${e.value}$count',
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        );
      }).toList(),
    );
  }
}

class _SubscriptionBanner extends StatelessWidget {
  final String tier;
  const _SubscriptionBanner({required this.tier});

  @override
  Widget build(BuildContext context) {
    if (tier == 'premium') return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tier == 'plus'
                  ? 'Premium으로 업그레이드하여 더 많은 기능을 이용하세요!'
                  : 'Plus 또는 Premium으로 업그레이드하세요!',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/subscription'),
            child: const Text('보기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: items
                .map((item) => _MenuItemTile(item: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, color: AppColors.primary),
      title: Text(item.label, style: const TextStyle(fontSize: 15)),
      trailing: item.trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: item.onTap,
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'free': [Colors.grey.shade400, Colors.grey.shade600],
      'plus': [Colors.blue.shade300, Colors.blue.shade600],
      'premium': [const Color(0xFFFFD700), const Color(0xFFFFA500)],
    };
    final c = colors[tier] ?? colors['free']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: c),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tier.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}