// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'five_elements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FiveElementsImpl _$$FiveElementsImplFromJson(Map<String, dynamic> json) =>
    _$FiveElementsImpl(
      wood: (json['wood'] as num?)?.toInt() ?? 0,
      fire: (json['fire'] as num?)?.toInt() ?? 0,
      earth: (json['earth'] as num?)?.toInt() ?? 0,
      metal: (json['metal'] as num?)?.toInt() ?? 0,
      water: (json['water'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FiveElementsImplToJson(_$FiveElementsImpl instance) =>
    <String, dynamic>{
      'wood': instance.wood,
      'fire': instance.fire,
      'earth': instance.earth,
      'metal': instance.metal,
      'water': instance.water,
    };
