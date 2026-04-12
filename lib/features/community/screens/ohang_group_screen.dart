import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/community_provider.dart';

const Map<String, Map<String, dynamic>> _ohangInfo = {
  '목': {'label': '목(木)', 'emoji': '🌳', 'color': Color(0xFF4CAF50)},
  '화': {'label': '화(火)', 'emoji': '🔥', 'color': Color(0xFFFF5722)},
  '토': {'label': '토(土)', 'emoji': '⛰️', 'color': Color(0xFF795548)},
  '금': {'label': '금(金)', 'emoji': '⚙️', 'color': Color(0xFFD4AF37)},
  '수': {'label': '수(水)', 'emoji': '💧', 'color': Color(0xFF2196F3)},
};

class OhangGroupScreen extends ConsumerStatefulWidget {
  final String? userOhang;

  const OhangGroupScreen({super.key, this.userOhang});

  @override
  ConsumerState<OhangGroupScreen> createState() => _OhangGroupScreenState();
}

class _OhangGroupScreenState extends ConsumerState<OhangGroupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentOhang;

  @override
  void initState() {
    super.initState();
    _currentOhang = widget.userOhang ?? '목';
    final ohangList = _ohangInfo.keys.toList();
    final initialIndex = ohangList.indexOf(_currentOhang).clamp(0, 4);
    _tabController = TabController(
      length: ohangList.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ohangList = _ohangInfo.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '오행 소그룹',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: ohangList.map((key) {
            final info = _ohangInfo[key]!;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(info['emoji'] as String),
                  const SizedBox(width: 4),
                  Text(info['label'] as String),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ohangList
            .map((ohang) => _OhangChatRoom(ohang: ohang))
            .toList(),
      ),
    );
  }
}

class _OhangChatRoom extends ConsumerStatefulWidget {
  final String ohang;

  const _OhangChatRoom({required this.ohang});

  @override
  ConsumerState<_OhangChatRoom> createState() => _OhangChatRoomState();
}

class _OhangChatRoomState extends ConsumerState<_OhangChatRoom> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    _msgController.clear();
    await ref
        .read(communityProvider.notifier)
        .sendGroupMessage(widget.ohang, text);
    setState(() => _sending = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = _ohangInfo[widget.ohang]!;
    final color = info['color'] as Color;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: color.withOpacity(0.1),
          child: Row(
            children: [
              Text(info['emoji'] as String, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '${info['label']} 오행 소그룹',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '같은 일간끼리',
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<GroupMessage>>(
            stream: ref
                .read(communityProvider.notifier)
                .groupMessagesStream(widget.ohang),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                );
              }

              final messages = snapshot.data ?? [];

              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        info['emoji'] as String,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '첫 번째 메시지를 보내보세요!',
                        style: TextStyle(color: color.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToBottom());

              return ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == uid;
                  return _MessageBubble(
                    message: msg,
                    isMe: isMe,
                    color: color,
                  );
                },
              );
            },
          ),
        ),
        _ChatInput(
          controller: _msgController,
          sending: _sending,
          accentColor: color,
          onSend: _sendMessage,
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final GroupMessage message;
  final bool isMe;
  final Color color;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withOpacity(0.3),
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0] : '?',
                style: TextStyle(color: color, fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 2),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? color.withOpacity(0.25)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border: isMe
                        ? Border.all(color: color.withOpacity(0.4))
                        : Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
                  child: Text(
                    timeago.format(message.createdAt, locale: 'ko'),
                    style: const TextStyle(color: Colors.white30, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final Color accentColor;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.sending,
    required this.accentColor,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF13132A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          sending
              ? SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: accentColor),
                )
              : IconButton(
                  onPressed: onSend,
                  icon: Icon(Icons.send_rounded, color: accentColor),
                ),
        ],
      ),
    );
  }
}