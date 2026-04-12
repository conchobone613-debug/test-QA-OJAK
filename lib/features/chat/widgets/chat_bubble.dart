import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../providers/chat_provider.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showReadReceipt,
  });

  final ChatMessage message;
  final bool isMe;
  final bool showReadReceipt;

  static const _myColor = Color(0xFFD4AF37);      // 금색
  static const _otherColor = Color(0xFF7B5EA7);   // 보라색
  static const _myTextColor = Colors.black87;
  static const _otherTextColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _buildBubble(context),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMe && showReadReceipt)
                    const Text('읽음',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFFD4AF37))),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(message.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: _otherColor.withOpacity(0.3),
      child: const Icon(Icons.person, size: 18, color: _otherColor),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final hasImage = message.imageUrl != null && message.imageUrl!.isNotEmpty;
    final hasText = message.text.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: isMe ? _myColor : _otherColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: (isMe ? _myColor : _otherColor).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: message.imageUrl!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (hasText)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  hasImage ? 8 : 10,
                  14,
                  10,
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? _myTextColor : _otherTextColor,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}