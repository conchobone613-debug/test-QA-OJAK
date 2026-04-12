import 'package:freezed_annotation/freezed_annotation.dart';

part 'compatibility_result.freezed.dart';
part 'compatibility_result.g.dart';

enum CompatibilityGrade { excellent, good, average, poor }

@freezed
class CompatibilityDetail with _$CompatibilityDetail {
  const factory CompatibilityDetail({
    required String category,
    required double score,
    required String description,
    @Default([]) List<String> strengths,
    @Default([]) List<String> weaknesses,
  }) = _CompatibilityDetail;

  factory CompatibilityDetail.fromJson(Map<String, dynamic> json) =>
      _$CompatibilityDetailFromJson(json);
}

@freezed
class CompatibilityResult with _$CompatibilityResult {
  const factory CompatibilityResult({
    required double score,
    required CompatibilityGrade grade,
    required String summary,
    @Default([]) List<CompatibilityDetail> details,
    @Default('') String sajuAnalysis,
    @Default('') String elementalBalance,
    @Default('') String relationshipAdvice,
  }) = _CompatibilityResult;

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) =>
      _$CompatibilityResultFromJson(json);
}