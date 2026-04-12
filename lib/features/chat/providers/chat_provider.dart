import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'chat_provider.freezed.dart';

// ── Models ──────────────────────────────────────────────────────────────────

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    required String text,
    String? imageUrl,
    required DateTime createdAt,
    @Default([]) List<String> readBy,
  }) = _ChatMessage;

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: d['senderId'] as String,
      text: d['text'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      readBy: List<String>.from(d['readBy'] as List? ?? []),
    );
  }
}

@freezed
class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required List<String> participants,
    required String otherUserId,
    required String otherUserName,
    String? otherUserPhoto,
    required int compatibilityScore,
    String? lastMessage,
    DateTime? lastMessageAt,
    @Default(0) int unreadCount,
  }) = _ChatRoom;
}

// ── State ────────────────────────────────────────────────────────────────────

@freezed
class ChatListState with _$ChatListState {
  const factory ChatListState({
    @Default([]) List<ChatRoom> rooms,
    @Default(false) bool isLoading,
    String? error,
  }) = _ChatListState;
}

@freezed
class ChatRoomState with _$ChatRoomState {
  const factory ChatRoomState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isSending,
    @Default(false) bool isLoading,
    String? error,
  }) = _ChatRoomState;
}

// ── ChatList Provider ────────────────────────────────────────────────────────

class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier() : super(const ChatListState()) {
    _init();
  }

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription? _sub;

  String get _uid => _auth.currentUser!.uid;

  void _init() {
    state = state.copyWith(isLoading: true);
    _sub = _db
        .collection('chatRooms')
        .where('participants', arrayContains: _uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .listen(_onRoomsSnapshot, onError: _onError);
  }

  Future<void> _onRoomsSnapshot(QuerySnapshot snap) async {
    final rooms = <ChatRoom>[];
    for (final doc in snap.docs) {
      final d = doc.data() as Map<String, dynamic>;
      final participants = List<String>.from(d['participants'] as List);
      final otherId = participants.firstWhere((p) => p != _uid);

      final userDoc = await _db.collection('users').doc(otherId).get();
      final userData = userDoc.data() ?? {};

      final unreadSnap = await _db
          .collection('chatRooms')
          .doc(doc.id)
          .collection('messages')
          .where('readBy', arrayContains: _uid, isEqualTo: false)
          .count()
          .get();

      // unread: messages where readBy does NOT contain _uid
      final unreadQuery = await _db
          .collection('chatRooms')
          .doc(doc.id)
          .collection('messages')
          .get();
      final unread = unreadQuery.docs
          .where((m) =>
              !List<String>.from(
                  (m.data()['readBy'] as List?) ?? []).contains(_uid))
          .length;

      rooms.add(ChatRoom(
        id: doc.id,
        participants: participants,
        otherUserId: otherId,
        otherUserName: userData['name'] as String? ?? '알 수 없음',
        otherUserPhoto: userData['profileImages'] != null &&
                (userData['profileImages'] as List).isNotEmpty
            ? (userData['profileImages'] as List).first as String
            : null,
        compatibilityScore: d['compatibilityScore'] as int? ?? 0,
        lastMessage: d['lastMessage'] as String?,
        lastMessageAt: d['lastMessageAt'] != null
            ? (d['lastMessageAt'] as Timestamp).toDate()
            : null,
        unreadCount: unread,
      ));
    }
    state = state.copyWith(rooms: rooms, isLoading: false);
  }

  void _onError(Object e) {
    state = state.copyWith(error: e.toString(), isLoading: false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatListProvider =
    StateNotifierProvider<ChatListNotifier, ChatListState>(
  (ref) => ChatListNotifier(),
);

// ── ChatRoom Provider ────────────────────────────────────────────────────────

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  ChatRoomNotifier(this.roomId) : super(const ChatRoomState()) {
    _init();
  }

  final String roomId;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription? _sub;

  String get _uid => _auth.currentUser!.uid;

  void _init() {
    state = state.copyWith(isLoading: true);
    _sub = _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(_onMessages, onError: (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    });
  }

  void _onMessages(QuerySnapshot snap) {
    final msgs = snap.docs.map(ChatMessage.fromFirestore).toList();
    state = state.copyWith(messages: msgs, isLoading: false);
    _markRead(snap.docs);
  }

  Future<void> _markRead(List<QueryDocumentSnapshot> docs) async {
    final batch = _db.batch();
    for (final doc in docs) {
      final readBy =
          List<String>.from((doc.data() as Map)['readBy'] as List? ?? []);
      if (!readBy.contains(_uid)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([_uid]),
        });
      }
    }
    await batch.commit();
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSending: true);
    try {
      final ref = _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .doc();
      await ref.set({
        'senderId': _uid,
        'text': text.trim(),
        'imageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': [_uid],
      });
      await _db.collection('chatRooms').doc(roomId).update({
        'lastMessage': text.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  Future<void> sendImage(File file) async {
    state = state.copyWith(isSending: true);
    try {
      final fileName = const Uuid().v4();
      final storageRef =
          _storage.ref().child('chat/$roomId/$fileName.jpg');
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();

      final ref = _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .doc();
      await ref.set({
        'senderId': _uid,
        'text': '',
        'imageUrl': url,
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': [_uid],
      });
      await _db.collection('chatRooms').doc(roomId).update({
        'lastMessage': '📷 사진',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatRoomProvider = StateNotifierProvider.family<ChatRoomNotifier,
    ChatRoomState, String>(
  (ref, roomId) => ChatRoomNotifier(roomId),
);

// ── Icebreaker Provider ──────────────────────────────────────────────────────

final icebreakerQuestionsProvider =
    Provider.family<List<String>, int>((ref, score) {
  if (score >= 80) {
    return [
      '💫 우리 궁합이 ${score}점이래요! 첫 데이트 장소 어디가 좋을까요?',
      '🌙 밤에 주로 뭐 하세요? 저는 별 보는 걸 좋아해요.',
      '☕ 아메리카노파 vs 라떼파, 어느 쪽이에요?',
    ];
  } else if (score >= 60) {
    return [
      '✨ 궁합 ${score}점! 어떤 공통점이 있을지 궁금해요.',
      '🎵 요즘 자주 듣는 노래가 있나요?',
      '🍜 좋아하는 음식은 뭐예요?',
    ];
  } else {
    return [
      '👋 안녕하세요! 자기소개 부탁드려요.',
      '🏙️ 어느 동네에 사세요?',
      '📚 요즘 관심 있는 게 뭔가요?',
    ];
  }
});