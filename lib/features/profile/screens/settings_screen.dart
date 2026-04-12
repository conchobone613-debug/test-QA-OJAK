import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/firebase_service.dart';
import '../../../shared/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _SectionHeader(title: '알림'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            onTap: () => context.push('/settings/notifications'),
          ),
          const Divider(height: 1),
          _SectionHeader(title: '계정'),
          _SettingsTile(
            icon: Icons.block_outlined,
            title: '차단 사용자 관리',
            onTap: () => context.push('/settings/blocked-users'),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: '앱 버전',
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: '이용약관',
            onTap: () => context.push('/settings/terms'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보처리방침',
            onTap: () => context.push('/settings/privacy'),
          ),
          const Divider(height: 1),
          _SectionHeader(title: '로그인'),
          _SettingsTile(
            icon: Icons.logout,
            title: '로그아웃',
            iconColor: Colors.orange,
            titleColor: Colors.orange,
            onTap: () => _showLogoutDialog(context, ref),
          ),
          _SettingsTile(
            icon: Icons.person_remove_outlined,
            title: '회원 탈퇴',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () => _showDeleteAccountDialog(context, ref),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _logout(context, ref);
            },
            child: const Text('로그아웃', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.\n정말 탈퇴하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAccount(context, ref);
            },
            child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await NotificationService.instance.deleteToken();
      await FirebaseService().signOut();
      if (context.mounted) context.go('/login');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      final firebase = FirebaseService();
      final uid = firebase.currentUserId;
      if (uid != null) {
        await firebase.callFunction('deleteUserAccount', {'uid': uid});
      }
      await NotificationService.instance.deleteToken();
      await firebase.deleteAccount();
      if (context.mounted) context.go('/login');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('탈퇴 처리 실패: $e')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).iconTheme.color),
      title: Text(title, style: TextStyle(color: titleColor)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null),
      onTap: onTap,
    );
  }
}