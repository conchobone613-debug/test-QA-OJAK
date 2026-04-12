// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'five_elements.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FiveElements _$FiveElementsFromJson(Map<String, dynamic> json) {
  return _FiveElements.fromJson(json);
}

/// @nodoc
mixin _$FiveElements {
  int get wood => throw _privateConstructorUsedError;
  int get fire => throw _privateConstructorUsedError;
  int get earth => throw _privateConstructorUsedError;
  int get metal => throw _privateConstructorUsedError;
  int get water => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FiveElementsCopyWith<FiveElements> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FiveElementsCopyWith<$Res> {
  factory $FiveElementsCopyWith(
          FiveElements value, $Res Function(FiveElements) then) =
      _$FiveElementsCopyWithImpl<$Res, FiveElements>;
  @useResult
  $Res call({int wood, int fire, int earth, int metal, int water});
}

/// @nodoc
class _$FiveElementsCopyWithImpl<$Res, $Val extends FiveElements>
    implements $FiveElementsCopyWith<$Res> {
  _$FiveElementsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wood = null,
    Object? fire = null,
    Object? earth = null,
    Object? metal = null,
    Object? water = null,
  }) {
    return _then(_value.copyWith(
      wood: null == wood
          ? _value.wood
          : wood // ignore: cast_nullable_to_non_nullable
              as int,
      fire: null == fire
          ? _value.fire
          : fire // ignore: cast_nullable_to_non_nullable
              as int,
      earth: null == earth
          ? _value.earth
          : earth // ignore: cast_nullable_to_non_nullable
              as int,
      metal: null == metal
          ? _value.metal
          : metal // ignore: cast_nullable_to_non_nullable
              as int,
      water: null == water
          ? _value.water
          : water // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FiveElementsImplCopyWith<$Res>
    implements $FiveElementsCopyWith<$Res> {
  factory _$$FiveElementsImplCopyWith(
          _$FiveElementsImpl value, $Res Function(_$FiveElementsImpl) then) =
      __$$FiveElementsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int wood, int fire, int earth, int metal, int water});
}

/// @nodoc
class __$$FiveElementsImplCopyWithImpl<$Res>
    extends _$FiveElementsCopyWithImpl<$Res, _$FiveElementsImpl>
    implements _$$FiveElementsImplCopyWith<$Res> {
  __$$FiveElementsImplCopyWithImpl(
      _$FiveElementsImpl _value, $Res Function(_$FiveElementsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wood = null,
    Object? fire = null,
    Object? earth = null,
    Object? metal = null,
    Object? water = null,
  }) {
    return _then(_$FiveElementsImpl(
      wood: null == wood
          ? _value.wood
          : wood // ignore: cast_nullable_to_non_nullable
              as int,
      fire: null == fire
          ? _value.fire
          : fire // ignore: cast_nullable_to_non_nullable
              as int,
      earth: null == earth
          ? _value.earth
          : earth // ignore: cast_nullable_to_non_nullable
              as int,
      metal: null == metal
          ? _value.metal
          : metal // ignore: cast_nullable_to_non_nullable
              as int,
      water: null == water
          ? _value.water
          : water // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FiveElementsImpl extends _FiveElements {
  const _$FiveElementsImpl(
      {this.wood = 0,
      this.fire = 0,
      this.earth = 0,
      this.metal = 0,
      this.water = 0})
      : super._();

  factory _$FiveElementsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FiveElementsImplFromJson(json);

  @override
  @JsonKey()
  final int wood;
  @override
  @JsonKey()
  final int fire;
  @override
  @JsonKey()
  final int earth;
  @override
  @JsonKey()
  final int metal;
  @override
  @JsonKey()
  final int water;

  @override
  String toString() {
    return 'FiveElements(wood: $wood, fire: $fire, earth: $earth, metal: $metal, water: $water)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FiveElementsImpl &&
            (identical(other.wood, wood) || other.wood == wood) &&
            (identical(other.fire, fire) || other.fire == fire) &&
            (identical(other.earth, earth) || other.earth == earth) &&
            (identical(other.metal, metal) || other.metal == metal) &&
            (identical(other.water, water) || other.water == water));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, wood, fire, earth, metal, water);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FiveElementsImplCopyWith<_$FiveElementsImpl> get copyWith =>
      __$$FiveElementsImplCopyWithImpl<_$FiveElementsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FiveElementsImplToJson(
      this,
    );
  }
}

abstract class _FiveElements extends FiveElements {
  const factory _FiveElements(
      {final int wood,
      final int fire,
      final int earth,
      final int metal,
      final int water}) = _$FiveElementsImpl;
  const _FiveElements._() : super._();

  factory _FiveElements.fromJson(Map<String, dynamic> json) =
      _$FiveElementsImpl.fromJson;

  @override
  int get wood;
  @override
  int get fire;
  @override
  int get earth;
  @override
  int get metal;
  @override
  int get water;
  @override
  @JsonKey(ignore: true)
  _$$FiveElementsImplCopyWith<_$FiveElementsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
