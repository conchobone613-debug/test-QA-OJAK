import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String uid;
  final String name;
  final String gender;
  final DateTime birthDate;
  final int? birthHour;
  final String? photoUrl;
  final String bio;
  final String mbti;
  final String religion;
  final String job;
  final RangeValues preferredAgeRange;
  final List<String> preferredElements;
  final Map<String, double> sajuElements;
  final List<String> sajuPillars;
  final List<String> aiAnalysis;
  final bool profileComplete;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.birthHour,
    this.photoUrl,
    required this.bio,
    required this.mbti,
    required this.religion,
    required this.job,
    required this.preferredAgeRange,
    required this.preferredElements,
    required this.sajuElements,
    required this.sajuPillars,
    required this.aiAnalysis,
    required this.profileComplete,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? name,
    String? gender,
    DateTime? birthDate,
    int? birthHour,
    String? photoUrl,
    String? bio,
    String? mbti,
    String? religion,
    String? job,
    RangeValues? preferredAgeRange,
    List<String>? preferredElements,
    Map<String, double>? sajuElements,
    List<String>? sajuPillars,
    List<String>? aiAnalysis,
    bool? profileComplete,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthHour: birthHour ?? this.birthHour,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      mbti: mbti ?? this.mbti,
      religion: religion ?? this.religion,
      job: job ?? this.job,
      preferredAgeRange: preferredAgeRange ?? this.preferredAgeRange,
      preferredElements: preferredElements ?? this.preferredElements,
      sajuElements: sajuElements ?? this.sajuElements,
      sajuPillars: sajuPillars ?? this.sajuPillars,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      profileComplete: profileComplete ?? this.profileComplete,
      createdAt: createdAt,
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      gender: data['gender'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      birthHour: data['birthHour'],
      photoUrl: data['photoUrl'],
      bio: data['bio'] ?? '',
      mbti: data['mbti'] ?? '',
      religion: data['religion'] ?? '',
      job: data['job'] ?? '',
      preferredAgeRange: RangeValues(
        (data['preferredAgeMin'] ?? 25).toDouble(),
        (data['preferredAgeMax'] ?? 35).toDouble(),
      ),
      preferredElements:
          List<String>.from(data['preferredElements'] ?? []),
      sajuElements: Map<String, double>.from(
          (data['sajuElements'] ?? {}).map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()))),
      sajuPillars: List<String>.from(data['sajuPillars'] ?? []),
      aiAnalysis: List<String>.from(data['aiAnalysis'] ?? []),
      profileComplete: data['profileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'gender': gender,
      'birthDate': Timestamp.fromDate(birthDate),
      'birthHour': birthHour,
      'photoUrl': photoUrl,
      'bio': bio,
      'mbti': mbti,
      'religion': religion,
      'job': job,
      'preferredAgeMin': preferredAgeRange.start,
      'preferredAgeMax': preferredAgeRange.end,
      'preferredElements': preferredElements,
      'sajuElements': sajuElements,
      'sajuPillars': sajuPillars,
      'aiAnalysis': aiAnalysis,
      'profileComplete': profileComplete,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class SajuData {
  final String dayMaster;
  final String dayPillar;
  final String dayPillarKorean;
  final String dominantElement;
  final Map<String, double> elements;
  final List<String> aiAnalysis;
  final List<SajuPillar> pillars;

  const SajuData({
    required this.dayMaster,
    required this.dayPillar,
    required this.dayPillarKorean,
    required this.dominantElement,
    required this.elements,
    required this.aiAnalysis,
    required this.pillars,
  });

  factory SajuData.dummy() {
    return SajuData(
      dayMaster: '甲',
      dayPillar: '甲子',
      dayPillarKorean: '갑자',
      dominantElement: '목(木)',
      elements: {
        '목': 0.35,
        '화': 0.20,
        '토': 0.15,
        '금': 0.10,
        '수': 0.20,
      },
      aiAnalysis: [
        '강한 목(木) 기운으로 창의적이고 성장 지향적인 성격입니다. 새로운 시작을 두려워하지 않으며 리더십이 뛰어납니다.',
        '수(水)와 목(木)의 조화로 지적 호기심이 강하고 감수성이 풍부합니다. 예술적 재능이 있으며 공감 능력이 높습니다.',
        '화(火)가 보조하여 열정적이고 표현력이 좋습니다. 사람들과의 관계에서 에너지를 얻으며 따뜻한 인간관계를 형성합니다.',
      ],
      pillars: [
        SajuPillar(hanja: '甲子', korean: '갑자', element: '목', position: '년주'),
        SajuPillar(hanja: '丙午', korean: '병오', element: '화', position: '월주'),
        SajuPillar(hanja: '甲子', korean: '갑자', element: '목', position: '일주'),
        SajuPillar(hanja: '壬申', korean: '임신', element: '수', position: '시주'),
      ],
    );
  }

  factory SajuData.fromProfile(UserProfile profile) {
    return SajuData(
      dayMaster: profile.sajuPillars.isNotEmpty ? profile.sajuPillars[0] : '甲',
      dayPillar: profile.sajuPillars.length > 2 ? profile.sajuPillars[2] : '甲子',
      dayPillarKorean: '갑자',
      dominantElement: '목(木)',
      elements: profile.sajuElements.isNotEmpty
          ? profile.sajuElements
          : {'목': 0.2, '화': 0.2, '토': 0.2, '금': 0.2, '수': 0.2},
      aiAnalysis: profile.aiAnalysis,
      pillars: [],
    );
  }
}

class SajuPillar {
  final String hanja;
  final String korean;
  final String element;
  final String position;

  const SajuPillar({
    required this.hanja,
    required this.korean,
    required this.element,
    required this.position,
  });
}

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<UserProfile?> build() async {
    return _fetchProfile();
  }

  Future<UserProfile?> _fetchProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<void> createProfile({
    required String name,
    required String gender,
    required DateTime birthDate,
    int? birthHour,
    File? profileImage,
    required String bio,
    required String mbti,
    required String religion,
    required String job,
    required RangeValues preferredAgeRange,
    required List<String> preferredElements,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('로그인이 필요합니다');

    state = const AsyncValue.loading();

    try {
      String? photoUrl;
      if (profileImage != null) {
        photoUrl = await _uploadImage(uid, profileImage);
      }

      // TODO: 실제 사주 계산 로직 (서버 함수 호출)
      final sajuElements = _calculateSajuElements(birthDate, birthHour);
      final sajuPillars = _calculateSajuPillars(birthDate, birthHour);
      final aiAnalysis = _generateAiAnalysis(sajuElements);

      final profile = UserProfile(
        uid: uid,
        name: name,
        gender: gender,
        birthDate: birthDate,
        birthHour: birthHour,
        photoUrl: photoUrl,
        bio: bio,
        mbti: mbti,
        religion: religion,
        job: job,
        preferredAgeRange: preferredAgeRange,
        preferredElements: preferredElements,
        sajuElements: sajuElements,
        sajuPillars: sajuPillars,
        aiAnalysis: aiAnalysis,
        profileComplete: true,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(profile.toFirestore());

      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final updated = await _fetchProfile();
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfilePhoto(File image) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final photoUrl = await _uploadImage(uid, image);
      await updateProfile({'photoUrl': photoUrl});
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteProfile() async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).delete();
    state = const AsyncValue.data(null);
  }

  Future<String> _uploadImage(String uid, File image) async {
    final ref = _storage.ref('profiles/$uid/avatar.jpg');
    final task = await ref.putFile(image);
    return await task.ref.getDownloadURL();
  }

  Map<String, double> _calculateSajuElements(DateTime birth, int? hour) {
    // TODO: 실제 사주 오행 계산 (천간/지지 기반)
    final year = birth.year;
    final month = birth.month;
    final day = birth.day;
    final seed = (year + month + day + (hour ?? 12)) % 100;
    return {
      '목': (seed % 5 + 1) / 15.0,
      '화': ((seed + 1) % 5 + 1) / 15.0,
      '토': ((seed + 2) % 5 + 1) / 15.0,
      '금': ((seed + 3) % 5 + 1) / 15.0,
      '수': ((seed + 4) % 5 + 1) / 15.0,
    };
  }

  List<String> _calculateSajuPillars(DateTime birth, int? hour) {
    // TODO: 실제 만세력 기반 사주 기둥 계산
    const heavenlyStems = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];
    const earthlyBranches = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
    final yearStem = heavenlyStems[(birth.year - 4) % 10];
    final yearBranch = earthlyBranches[(birth.year - 4) % 12];
    return [
      '$yearStem$yearBranch',
      '丙午',
      '甲子',
      '壬申',
    ];
  }

  List<String> _generateAiAnalysis(Map<String, double> elements) {
    // TODO: 실제 AI API 호출
    return [
      '강한 목(木) 기운으로 창의적이고 성장 지향적인 성격입니다.',
      '수(水)의 지혜로 직관적이며 깊은 사고를 즐깁니다.',
      '화(火)의 열정으로 인간관계에서 따뜻한 에너지를 발산합니다.',
    ];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final profile = await _fetchProfile();
    state = AsyncValue.data(profile);
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);