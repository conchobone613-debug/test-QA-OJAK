// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compatibility_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompatibilityDetailImpl _$$CompatibilityDetailImplFromJson(
        Map<String, dynamic> json) =>
    _$CompatibilityDetailImpl(
      category: json['category'] as String,
      score: (json['score'] as num).toDouble(),
      description: json['description'] as String,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CompatibilityDetailImplToJson(
        _$CompatibilityDetailImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'score': instance.score,
      'description': instance.description,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
    };

_$CompatibilityResultImpl _$$CompatibilityResultImplFromJson(
        Map<String, dynamic> json) =>
    _$CompatibilityResultImpl(
      score: (json['score'] as num).toDouble(),
      grade: $enumDecode(_$CompatibilityGradeEnumMap, json['grade']),
      summary: json['summary'] as String,
      details: (json['details'] as List<dynamic>?)
              ?.map((e) =>
                  CompatibilityDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sajuAnalysis: json['sajuAnalysis'] as String? ?? '',
      elementalBalance: json['elementalBalance'] as String? ?? '',
      relationshipAdvice: json['relationshipAdvice'] as String? ?? '',
    );

Map<String, dynamic> _$$CompatibilityResultImplToJson(
        _$CompatibilityResultImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'grade': _$CompatibilityGradeEnumMap[instance.grade]!,
      'summary': instance.summary,
      'details': instance.details,
      'sajuAnalysis': instance.sajuAnalysis,
      'elementalBalance': instance.elementalBalance,
      'relationshipAdvice': instance.relationshipAdvice,
    };

const _$CompatibilityGradeEnumMap = {
  CompatibilityGrade.excellent: 'excellent',
  CompatibilityGrade.good: 'good',
  CompatibilityGrade.average: 'average',
  CompatibilityGrade.poor: 'poor',
};
