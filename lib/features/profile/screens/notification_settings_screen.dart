import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/services/firebase_service.dart';

class NotificationSettingsModel {
  final bool matchRequest;
  final bool matchAccepted;
  final bool newMessage;
  final bool profileLike;
  final bool meetingReminder;
  final bool marketing;

  const NotificationSettingsModel({
    this.matchRequest = true,
    this.matchAccepted = true,
    this.newMessage = true,
    this.profileLike = true,
    this.meetingReminder = true,
    this.marketing = false,
  });

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      matchRequest: map['matchRequest'] as bool? ?? true,
      matchAccepted: map['matchAccepted'] as bool? ?? true,
      newMessage: map['newMessage'] as bool? ?? true,
      profileLike: map['profileLike'] as bool? ?? true,
      meetingReminder: map['meetingReminder'] as bool? ?? true,
      marketing: map['marketing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'matchRequest': matchRequest,
        'matchAccepted': matchAccepted,
        'newMessage': newMessage,
        'profileLike': profileLike,
        'meetingReminder': meetingReminder,
        'marketing': marketing,
      };

  NotificationSettingsModel copyWith({
    bool? matchRequest,
    bool? matchAccepted,
    bool? newMessage,
    bool? profileLike,
    bool? meetingReminder,
    bool? marketing,
  }) {
    return NotificationSettingsModel(
      matchRequest: matchRequest ?? this.matchRequest,
      matchAccepted: matchAccepted ?? this.matchAccepted,
      newMessage: newMessage ?? this.newMessage,
      profileLike: profileLike ?? this.profileLike,
      meetingReminder: meetingReminder ?? this.meetingReminder,
      marketing: marketing ?? this.marketing,
    );
  }
}

final _notificationSettingsProvider =
    AsyncNotifierProvider.autoDispose<_NotificationSettingsNotifier, NotificationSettingsModel>(
        _NotificationSettingsNotifier.new);

class _NotificationSettingsNotifier
    extends AutoDisposeAsyncNotifier<NotificationSettingsModel> {
  @override
  Future<NotificationSettingsModel> build() async {
    final firebase = FirebaseService();
    final uid = firebase.currentUserId;
    if (uid == null) return const NotificationSettingsModel();

    final doc = await firebase.getDocument('users/$uid');
    if (!doc.exists) return const NotificationSettingsModel();

    final data = doc.data()!;
    final notifData = data['notificationSettings'] as Map<String, dynamic>?;
    if (notifData == null) return const NotificationSettingsModel();

    return NotificationSettingsModel.fromMap(notifData);
  }

  Future<void> toggle(String field, bool value) async {
    final current = state.valueOrNull ?? const NotificationSettingsModel();
    final updated = switch (field) {
      'matchRequest' => current.copyWith(matchRequest: value),
      'matchAccepted' => current.copyWith(matchAccepted: value),
      'newMessage' => current.copyWith(newMessage: value),
      'profileLike' => current.copyWith(profileLike: value),
      'meetingReminder' => current.copyWith(meetingReminder: value),
      'marketing' => current.copyWith(marketing: value),
      _ => current,
    };
    state = AsyncValue.data(updated);
    await _save(updated);
  }

  Future<void> _save(NotificationSettingsModel settings) async {
    final firebase = FirebaseService();
    final uid = firebase.currentUserId;
    if (uid == null) return;
    await firebase.updateDocument('users/$uid', {
      'notificationSettings': settings.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(_notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (settings) => ListView(
          children: [
            _SectionHeader(title: '매칭 알림'),
            _NotifTile(
              title: '매칭 신청',
              subtitle: '누군가 나에게 매칭을 신청했을 때',
              value: settings.matchRequest,
              onChanged: (v) => ref.read(_notificationSettingsProvider.notifier).toggle('matchRequest', v),
            ),
            _NotifTile(
              title: '매칭 수락',
              subtitle: '내 매칭 신청이 수락되었을 때',
              value: settings.matchAccepted,
              onChanged: (v) => ref.read(_notificationSettingsProvider.notifier).toggle('matchAccepted', v),
            ),
            _SectionHeader(title: '채팅 알림'),
            _NotifTile(
              title: '새 메시지',
              subtitle: '새로운 채팅 메시지가 도착했을 때',
              value: settings.newMessage,
              onChanged: (v) => ref.read(_notificationSettingsProvider.notifier).toggle('newMessage', v),
            ),
            _SectionHeader(title: '활동 알림'),
            _NotifTile(
              title: '프로필 좋아요',
              subtitle: '누군가 내 프로필을 좋아요 했을 때',
              value: settings.profileLike,
              onChanged: (v) => ref.read(_notificationSettingsProvider.notifier).toggle('profileLike', v),
            ),
            _NotifTile(
              title: '만남 일정 알림',
              subtitle: '약속된 만남 일정 전 알림',
              value: settings.meetingReminder,
              onChanged: (v) => ref.read(_notificationSettingsProvider.notifier).toggle('meetingReminder', v),
            ),
            _SectionHeader(title: '기타'),
            _NotifTile(
              title: '마케팅 알림',
              subtitle: '이벤트, 프로모션 등 혜택 정보',
              value: settings.marketing,
              onChanged: (v) => ref.read(_notificationSettingsProvider.notifier).toggle('marketing', v),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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

class _NotifTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}