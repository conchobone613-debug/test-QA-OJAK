import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ojak/features/matching/models/compatibility_result.dart';

part 'match.freezed.dart';
part 'match.g.dart';

enum MatchGrade { excellent, good, average, poor }

enum MatchStatus { pending, accepted, rejected, expired }

@freezed
class Match with _$Match {
  const factory Match({
    required String matchId,
    required List<String> participants,
    required double compatibilityScore,
    required MatchGrade grade,
    required String aiSummary,
    CompatibilityResult? compatibilityResult,
    @Default(MatchStatus.pending) MatchStatus status,
    String? initiatorId,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampToDateTimeNullable, toJson: _dateTimeToTimestampNullable)
    DateTime? acceptedAt,
    @JsonKey(fromJson: _timestampToDateTimeNullable, toJson: _dateTimeToTimestampNullable)
    DateTime? expiresAt,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
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