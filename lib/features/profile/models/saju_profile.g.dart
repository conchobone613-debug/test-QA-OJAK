// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saju_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SajuPillarImpl _$$SajuPillarImplFromJson(Map<String, dynamic> json) =>
    _$SajuPillarImpl(
      yearStem: $enumDecode(_$HeavenlyStemEnumMap, json['yearStem']),
      yearBranch: $enumDecode(_$EarthlyBranchEnumMap, json['yearBranch']),
      monthStem: $enumDecode(_$HeavenlyStemEnumMap, json['monthStem']),
      monthBranch: $enumDecode(_$EarthlyBranchEnumMap, json['monthBranch']),
      dayStem: $enumDecode(_$HeavenlyStemEnumMap, json['dayStem']),
      dayBranch: $enumDecode(_$EarthlyBranchEnumMap, json['dayBranch']),
      hourStem: $enumDecode(_$HeavenlyStemEnumMap, json['hourStem']),
      hourBranch: $enumDecode(_$EarthlyBranchEnumMap, json['hourBranch']),
      fiveElements:
          FiveElements.fromJson(json['fiveElements'] as Map<String, dynamic>),
      yongShin: json['yongShin'] as String? ?? '',
      dayMaster: json['dayMaster'] as String? ?? '',
      sajuSummary: json['sajuSummary'] as String? ?? '',
    );

Map<String, dynamic> _$$SajuPillarImplToJson(_$SajuPillarImpl instance) =>
    <String, dynamic>{
      'yearStem': _$HeavenlyStemEnumMap[instance.yearStem]!,
      'yearBranch': _$EarthlyBranchEnumMap[instance.yearBranch]!,
      'monthStem': _$HeavenlyStemEnumMap[instance.monthStem]!,
      'monthBranch': _$EarthlyBranchEnumMap[instance.monthBranch]!,
      'dayStem': _$HeavenlyStemEnumMap[instance.dayStem]!,
      'dayBranch': _$EarthlyBranchEnumMap[instance.dayBranch]!,
      'hourStem': _$HeavenlyStemEnumMap[instance.hourStem]!,
      'hourBranch': _$EarthlyBranchEnumMap[instance.hourBranch]!,
      'fiveElements': instance.fiveElements,
      'yongShin': instance.yongShin,
      'dayMaster': instance.dayMaster,
      'sajuSummary': instance.sajuSummary,
    };

const _$HeavenlyStemEnumMap = {
  HeavenlyStem.gap: 'gap',
  HeavenlyStem.eul: 'eul',
  HeavenlyStem.byeong: 'byeong',
  HeavenlyStem.jeong: 'jeong',
  HeavenlyStem.mu: 'mu',
  HeavenlyStem.gi: 'gi',
  HeavenlyStem.gyeong: 'gyeong',
  HeavenlyStem.sin: 'sin',
  HeavenlyStem.im: 'im',
  HeavenlyStem.gye: 'gye',
};

const _$EarthlyBranchEnumMap = {
  EarthlyBranch.ja: 'ja',
  EarthlyBranch.chuk: 'chuk',
  EarthlyBranch.in_: 'in_',
  EarthlyBranch.myo: 'myo',
  EarthlyBranch.jin: 'jin',
  EarthlyBranch.sa: 'sa',
  EarthlyBranch.o: 'o',
  EarthlyBranch.mi: 'mi',
  EarthlyBranch.sin_: 'sin_',
  EarthlyBranch.yu: 'yu',
  EarthlyBranch.sul: 'sul',
  EarthlyBranch.hae: 'hae',
};
