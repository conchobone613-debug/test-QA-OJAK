// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      preferredGenders: (json['preferredGenders'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GenderEnumMap, e))
              .toList() ??
          const [],
      minAge: (json['minAge'] as num?)?.toInt() ?? 20,
      maxAge: (json['maxAge'] as num?)?.toInt() ?? 40,
      minHeight: (json['minHeight'] as num?)?.toDouble() ?? 150.0,
      maxHeight: (json['maxHeight'] as num?)?.toDouble() ?? 200.0,
      preferredRegions: (json['preferredRegions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredOccupations: (json['preferredOccupations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      onlySajuCompatible: json['onlySajuCompatible'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'preferredGenders':
          instance.preferredGenders.map((e) => _$GenderEnumMap[e]!).toList(),
      'minAge': instance.minAge,
      'maxAge': instance.maxAge,
      'minHeight': instance.minHeight,
      'maxHeight': instance.maxHeight,
      'preferredRegions': instance.preferredRegions,
      'preferredOccupations': instance.preferredOccupations,
      'onlySajuCompatible': instance.onlySajuCompatible,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      birthDateTime: _timestampToDateTime(json['birthDateTime']),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      height: (json['height'] as num).toDouble(),
      occupation: $enumDecode(_$OccupationEnumMap, json['occupation']),
      region: json['region'] as String,
      bio: json['bio'] as String? ?? '',
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sajuPillar: json['sajuPillar'] == null
          ? null
          : SajuPillar.fromJson(json['sajuPillar'] as Map<String, dynamic>),
      preferences: json['preferences'] == null
          ? null
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>),
      isPremium: json['isPremium'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      premiumExpiresAt: _timestampToDateTimeNullable(json['premiumExpiresAt']),
      createdAt: _timestampToDateTime(json['createdAt']),
      updatedAt: _timestampToDateTimeNullable(json['updatedAt']),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'birthDateTime': _dateTimeToTimestamp(instance.birthDateTime),
      'gender': _$GenderEnumMap[instance.gender]!,
      'height': instance.height,
      'occupation': _$OccupationEnumMap[instance.occupation]!,
      'region': instance.region,
      'bio': instance.bio,
      'interests': instance.interests,
      'photos': instance.photos,
      'sajuPillar': instance.sajuPillar,
      'preferences': instance.preferences,
      'isPremium': instance.isPremium,
      'isActive': instance.isActive,
      'premiumExpiresAt':
          _dateTimeToTimestampNullable(instance.premiumExpiresAt),
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'updatedAt': _dateTimeToTimestampNullable(instance.updatedAt),
    };

const _$OccupationEnumMap = {
  Occupation.student: 'student',
  Occupation.employee: 'employee',
  Occupation.selfEmployed: 'selfEmployed',
  Occupation.professional: 'professional',
  Occupation.creative: 'creative',
  Occupation.other: 'other',
};
