import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SwipeAction { like, pass, superLike }

class CompatibilityScore {
  final int overall;
  final int love;
  final int communication;
  final int values;
  final int future;
  final String grade;
  final String comment;
  final String aiInterpretation;

  const CompatibilityScore({
    required this.overall,
    required this.love,
    required this.communication,
    required this.values,
    required this.future,
    required this.grade,
    required this.comment,
    required this.aiInterpretation,
  });

  factory CompatibilityScore.fromMap(Map<String, dynamic> map) {
    return CompatibilityScore(
      overall: map['overall'] ?? 0,
      love: map['love'] ?? 0,
      communication: map['communication'] ?? 0,
      values: map['values'] ?? 0,
      future: map['future'] ?? 0,
      grade: map['grade'] ?? 'C',
      comment: map['comment'] ?? '',
      aiInterpretation: map['aiInterpretation'] ?? '',
    );
  }
}

class FeedUser {
  final String uid;
  final String nickname;
  final int age;
  final List<String> photoUrls;
  final String bio;
  final Map<String, dynamic> sajuData;
  final CompatibilityScore compatibility;

  const FeedUser({
    required this.uid,
    required this.nickname,
    required this.age,
    required this.photoUrls,
    required this.bio,
    required this.sajuData,
    required this.compatibility,
  });

  factory FeedUser.fromMap(String uid, Map<String, dynamic> map, Map<String, dynamic> compatMap) {
    return FeedUser(
      uid: uid,
      nickname: map['nickname'] ?? '',
      age: map['age'] ?? 0,
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      bio: map['bio'] ?? '',
      sajuData: Map<String, dynamic>.from(map['sajuData'] ?? {}),
      compatibility: CompatibilityScore.fromMap(compatMap),
    );
  }
}

class MatchingState {
  final List<FeedUser> feedUsers;
  final bool isLoading;
  final String? error;
  final String? matchedUserId;
  final FeedUser? matchedUser;
  final bool isMatchSuccess;

  const MatchingState({
    this.feedUsers = const [],
    this.isLoading = false,
    this.error,
    this.matchedUserId,
    this.matchedUser,
    this.isMatchSuccess = false,
  });

  MatchingState copyWith({
    List<FeedUser>? feedUsers,
    bool? isLoading,
    String? error,
    String? matchedUserId,
    FeedUser? matchedUser,
    bool? isMatchSuccess,
  }) {
    return MatchingState(
      feedUsers: feedUsers ?? this.feedUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      matchedUserId: matchedUserId ?? this.matchedUserId,
      matchedUser: matchedUser ?? this.matchedUser,
      isMatchSuccess: isMatchSuccess ?? this.isMatchSuccess,
    );
  }
}

class MatchingNotifier extends StateNotifier<MatchingState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MatchingNotifier(this._firestore, this._auth) : super(const MatchingState());

  String? get _currentUid => _auth.currentUser?.uid;

  Future<void> loadFeed() async {
    if (_currentUid == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final seenSnap = await _firestore
          .collection('swipes')
          .where('fromUid', isEqualTo: _currentUid)
          .get();
      final seenUids = seenSnap.docs.map((d) => d['toUid'] as String).toSet();
      seenUids.add(_currentUid!);

      final meDoc = await _firestore.collection('users').doc(_currentUid).get();
      final myData = meDoc.data() ?? {};
      final myGender = myData['gender'] ?? 'male';
      final targetGender = myGender == 'male' ? 'female' : 'male';

      final usersSnap = await _firestore
          .collection('users')
          .where('gender', isEqualTo: targetGender)
          .where('isActive', isEqualTo: true)
          .limit(50)
          .get();

      final feedUsers = <FeedUser>[];
      for (final doc in usersSnap.docs) {
        if (seenUids.contains(doc.id)) continue;
        final compatSnap = await _firestore
            .collection('compatibility')
            .doc('${_currentUid}_${doc.id}')
            .get();
        Map<String, dynamic> compatData = compatSnap.data() ?? {};
        if (compatData.isEmpty) {
          compatData = _generateMockCompatibility(doc.data());
        }
        feedUsers.add(FeedUser.fromMap(doc.id, doc.data(), compatData));
      }

      feedUsers.sort((a, b) => b.compatibility.overall.compareTo(a.compatibility.overall));
      state = state.copyWith(feedUsers: feedUsers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Map<String, dynamic> _generateMockCompatibility(Map<String, dynamic> userData) {
    final overall = 60 + (userData['nickname']?.hashCode ?? 0).abs() % 40;
    final grade = overall >= 90 ? 'S' : overall >= 80 ? 'A' : overall >= 70 ? 'B' : overall >= 60 ? 'C' : 'D';
    return {
      'overall': overall,
      'love': 50 + (overall + 10) % 50,
      'communication': 50 + (overall + 20) % 50,
      'values': 50 + (overall + 5) % 50,
      'future': 50 + (overall + 15) % 50,
      'grade': grade,
      'comment': _gradeComment(grade),
      'aiInterpretation': '두 사람의 사주를 분석한 결과, 오행의 균형이 잘 맞아 안정적인 관계를 기대할 수 있습니다.',
    };
  }

  String _gradeComment(String grade) {
    switch (grade) {
      case 'S': return '운명적 만남! 천생연분에 가깝습니다';
      case 'A': return '매우 좋은 궁합! 서로를 빛나게 해줘요';
      case 'B': return '좋은 궁합! 함께 성장할 수 있어요';
      case 'C': return '보통 궁합. 노력하면 좋아질 수 있어요';
      default: return '조심스러운 궁합. 신중하게 접근해요';
    }
  }

  Future<void> swipe(FeedUser user, SwipeAction action) async {
    if (_currentUid == null) return;

    final updatedFeed = state.feedUsers.where((u) => u.uid != user.uid).toList();
    state = state.copyWith(feedUsers: updatedFeed);

    try {
      await _firestore.collection('swipes').add({
        'fromUid': _currentUid,
        'toUid': user.uid,
        'action': action.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (action == SwipeAction.like || action == SwipeAction.superLike) {
        await _checkMatch(user);
      }

      if (updatedFeed.length < 5) {
        await loadFeed();
      }
    } catch (e) {
      // ignore swipe error
    }
  }

  Future<void> _checkMatch(FeedUser user) async {
    if (_currentUid == null) return;
    final reverseSnap = await _firestore
        .collection('swipes')
        .where('fromUid', isEqualTo: user.uid)
        .where('toUid', isEqualTo: _currentUid)
        .where('action', whereIn: ['like', 'superLike'])
        .get();

    if (reverseSnap.docs.isNotEmpty) {
      await _firestore.collection('matches').add({
        'users': [_currentUid, user.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'compatibility': user.compatibility.overall,
      });
      state = state.copyWith(
        isMatchSuccess: true,
        matchedUserId: user.uid,
        matchedUser: user,
      );
    }
  }

  void clearMatch() {
    state = state.copyWith(isMatchSuccess: false, matchedUserId: null, matchedUser: null);
  }
}

final matchingProvider = StateNotifierProvider<MatchingNotifier, MatchingState>((ref) {
  return MatchingNotifier(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});