import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ojak/shared/models/five_elements.dart';

part 'saju_profile.freezed.dart';
part 'saju_profile.g.dart';

enum HeavenlyStem {
  gap, eul, byeong, jeong, mu, gi, gyeong, sin, im, gye,
}

enum EarthlyBranch {
  ja, chuk, in_, myo, jin, sa, o, mi, sin_, yu, sul, hae,
}

@freezed
class SajuPillar with _$SajuPillar {
  const factory SajuPillar({
    required HeavenlyStem yearStem,
    required EarthlyBranch yearBranch,
    required HeavenlyStem monthStem,
    required EarthlyBranch monthBranch,
    required HeavenlyStem dayStem,
    required EarthlyBranch dayBranch,
    required HeavenlyStem hourStem,
    required EarthlyBranch hourBranch,
    required FiveElements fiveElements,
    @Default('') String yongShin,
    @Default('') String dayMaster,
    @Default('') String sajuSummary,
  }) = _SajuPillar;

  factory SajuPillar.fromJson(Map<String, dynamic> json) =>
      _$SajuPillarFromJson(json);
}