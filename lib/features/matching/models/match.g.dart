// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchImpl _$$MatchImplFromJson(Map<String, dynamic> json) => _$MatchImpl(
      matchId: json['matchId'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      grade: $enumDecode(_$MatchGradeEnumMap, json['grade']),
      aiSummary: json['aiSummary'] as String,
      compatibilityResult: json['compatibilityResult'] == null
          ? null
          : CompatibilityResult.fromJson(
              json['compatibilityResult'] as Map<String, dynamic>),
      status: $enumDecodeNullable(_$MatchStatusEnumMap, json['status']) ??
          MatchStatus.pending,
      initiatorId: json['initiatorId'] as String?,
      createdAt: _timestampToDateTime(json['createdAt']),
      acceptedAt: _timestampToDateTimeNullable(json['acceptedAt']),
      expiresAt: _timestampToDateTimeNullable(json['expiresAt']),
    );

Map<String, dynamic> _$$MatchImplToJson(_$MatchImpl instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'participants': instance.participants,
      'compatibilityScore': instance.compatibilityScore,
      'grade': _$MatchGradeEnumMap[instance.grade]!,
      'aiSummary': instance.aiSummary,
      'compatibilityResult': instance.compatibilityResult,
      'status': _$MatchStatusEnumMap[instance.status]!,
      'initiatorId': instance.initiatorId,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'acceptedAt': _dateTimeToTimestampNullable(instance.acceptedAt),
      'expiresAt': _dateTimeToTimestampNullable(instance.expiresAt),
    };

const _$MatchGradeEnumMap = {
  MatchGrade.excellent: 'excellent',
  MatchGrade.good: 'good',
  MatchGrade.average: 'average',
  MatchGrade.poor: 'poor',
};

const _$MatchStatusEnumMap = {
  MatchStatus.pending: 'pending',
  MatchStatus.accepted: 'accepted',
  MatchStatus.rejected: 'rejected',
  MatchStatus.expired: 'expired',
};
