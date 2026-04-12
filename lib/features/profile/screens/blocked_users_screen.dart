import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/services/firebase_service.dart';

final _blockedUsersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final firebase = FirebaseService();
  final uid = firebase.currentUserId;
  if (uid == null) return [];

  final doc = await firebase.getDocument('users/$uid');
  if (!doc.exists) return [];

  final data = doc.data()!;
  final blockedIds = List<String>.from(data['blockedUsers'] ?? []);
  if (blockedIds.isEmpty) return [];

  final futures = blockedIds.map((id) => firebase.getDocument('users/$id'));
  final docs = await Future.wait(futures);

  return docs
      .where((d) => d.exists)
      .map((d) => {'uid': d.id, ...d.data()!})
      .toList();
});

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedAsync = ref.watch(_blockedUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('차단 사용자 관리'),
        centerTitle: true,
      ),
      body: blockedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류가 발생했습니다: $e')),
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('차단한 사용자가 없습니다.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return _BlockedUserTile(
                user: user,
                onUnblock: () => _unblockUser(context, ref, user['uid'] as String),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _unblockUser(BuildContext context, WidgetRef ref, String targetUid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('차단 해제'),
        content: const Text('이 사용자의 차단을 해제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('해제', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final firebase = FirebaseService();
      final uid = firebase.currentUserId;
      if (uid == null) return;

      await firebase.updateDocument('users/$uid', {
        'blockedUsers': FieldValue.arrayRemove([targetUid]),
      });
      ref.invalidate(_blockedUsersProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('차단이 해제되었습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('차단 해제 실패: $e')),
        );
      }
    }
  }
}

class _BlockedUserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUnblock;

  const _BlockedUserTile({required this.user, required this.onUnblock});

  @override
  Widget build(BuildContext context) {
    final nickname = user['nickname'] as String? ?? '알 수 없음';
    final profileImages = user['profileImages'] as List?;
    final photoUrl = profileImages != null && profileImages.isNotEmpty
        ? profileImages.first as String
        : null;

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(nickname),
      subtitle: Text(user['bio'] as String? ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: OutlinedButton(
        onPressed: onUnblock,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          side: const BorderSide(color: Colors.blue),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('차단 해제'),
      ),
    );
  }
}