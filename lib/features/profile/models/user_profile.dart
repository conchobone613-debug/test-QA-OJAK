import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ojak/features/profile/models/saju_profile.dart';
import 'package:ojak/shared/models/five_elements.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum Gender { male, female, other }

enum Occupation {
  student,
  employee,
  selfEmployed,
  professional,
  creative,
  other,
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default([]) List<Gender> preferredGenders,
    @Default(20) int minAge,
    @Default(40) int maxAge,
    @Default(150.0) double minHeight,
    @Default(200.0) double maxHeight,
    @Default([]) List<String> preferredRegions,
    @Default([]) List<String> preferredOccupations,
    @Default(false) bool onlySajuCompatible,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String displayName,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    required DateTime birthDateTime,
    required Gender gender,
    required double height,
    required Occupation occupation,
    required String region,
    @Default('') String bio,
    @Default([]) List<String> interests,
    @Default([]) List<String> photos,
    SajuPillar? sajuPillar,
    UserPreferences? preferences,
    @Default(false) bool isPremium,
    @Default(true) bool isActive,
    @JsonKey(fromJson: _timestampToDateTimeNullable, toJson: _dateTimeToTimestampNullable)
    DateTime? premiumExpiresAt,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampToDateTimeNullable, toJson: _dateTimeToTimestampNullable)
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

DateTime _timestampToDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

dynamic _dateTimeToTimestamp(DateTime dt) => Timestamp.fromDate(dt);

DateTime? _timestampToDateTimeNullable(dynamic value) {
  if (value == null) return null;
  return _timestampToDateTime(value);
}

dynamic _dateTimeToTimestampNullable(DateTime? dt) {
  if (dt == null) return null;
  return Timestamp.fromDate(dt);
}