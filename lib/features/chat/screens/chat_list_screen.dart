import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text(
          '💌 채팅',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFD4AF37).withOpacity(0.2),
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : state.error != null
              ? _buildError(state.error!)
              : state.rooms.isEmpty
                  ? _buildEmpty()
                  : _buildList(context, state),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text(error, style: const TextStyle(color: Colors.redAccent)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💌', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            '아직 채팅이 없어요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 분과 매칭되면\n채팅을 시작할 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, ChatListState state) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.rooms.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        indent: 80,
      ),
      itemBuilder: (context, index) {
        final room = state.rooms[index];
        return _ChatRoomTile(
          room: room,
          onTap: () => context.push('/chat/${room.id}', extra: room),
        );
      },
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = room.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        room.otherUserName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: hasUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildCompatibilityBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.lastMessage ?? '대화를 시작해보세요',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasUnread
                          ? Colors.white.withOpacity(0.85)
                          : Colors.white.withOpacity(0.45),
                      fontSize: 13,
                      fontWeight: hasUnread
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (room.lastMessageAt != null)
                  Text(
                    _formatTime(room.lastMessageAt!),
                    style: TextStyle(
                      color: hasUnread
                          ? const Color(0xFFD4AF37)
                          : Colors.white.withOpacity(0.35),
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(height: 4),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      room.unreadCount > 99
                          ? '99+'
                          : '${room.unreadCount}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF7B5EA7).withOpacity(0.3),
          backgroundImage: room.otherUserPhoto != null
              ? NetworkImage(room.otherUserPhoto!)
              : null,
          child: room.otherUserPhoto == null
              ? const Icon(Icons.person, color: Color(0xFF7B5EA7), size: 28)
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0D0D1A), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityBadge() {
    final score = room.compatibilityScore;
    final color = score >= 80
        ? const Color(0xFFD4AF37)
        : score >= 60
            ? const Color(0xFF7B5EA7)
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '♥ $score%',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(dt);
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 7) return DateFormat('E', 'ko').format(dt);
    return DateFormat('MM/dd').format(dt);
  }
}