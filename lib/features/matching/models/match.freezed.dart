// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Match _$MatchFromJson(Map<String, dynamic> json) {
  return _Match.fromJson(json);
}

/// @nodoc
mixin _$Match {
  String get matchId => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  double get compatibilityScore => throw _privateConstructorUsedError;
  MatchGrade get grade => throw _privateConstructorUsedError;
  String get aiSummary => throw _privateConstructorUsedError;
  CompatibilityResult? get compatibilityResult =>
      throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  String? get initiatorId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  DateTime? get acceptedAt => throw _privateConstructorUsedError;
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MatchCopyWith<Match> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchCopyWith<$Res> {
  factory $MatchCopyWith(Match value, $Res Function(Match) then) =
      _$MatchCopyWithImpl<$Res, Match>;
  @useResult
  $Res call(
      {String matchId,
      List<String> participants,
      double compatibilityScore,
      MatchGrade grade,
      String aiSummary,
      CompatibilityResult? compatibilityResult,
      MatchStatus status,
      String? initiatorId,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      DateTime createdAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      DateTime? acceptedAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      DateTime? expiresAt});

  $CompatibilityResultCopyWith<$Res>? get compatibilityResult;
}

/// @nodoc
class _$MatchCopyWithImpl<$Res, $Val extends Match>
    implements $MatchCopyWith<$Res> {
  _$MatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = null,
    Object? participants = null,
    Object? compatibilityScore = null,
    Object? grade = null,
    Object? aiSummary = null,
    Object? compatibilityResult = freezed,
    Object? status = null,
    Object? initiatorId = freezed,
    Object? createdAt = null,
    Object? acceptedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      compatibilityScore: null == compatibilityScore
          ? _value.compatibilityScore
          : compatibilityScore // ignore: cast_nullable_to_non_nullable
              as double,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as MatchGrade,
      aiSummary: null == aiSummary
          ? _value.aiSummary
          : aiSummary // ignore: cast_nullable_to_non_nullable
              as String,
      compatibilityResult: freezed == compatibilityResult
          ? _value.compatibilityResult
          : compatibilityResult // ignore: cast_nullable_to_non_nullable
              as CompatibilityResult?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      initiatorId: freezed == initiatorId
          ? _value.initiatorId
          : initiatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CompatibilityResultCopyWith<$Res>? get compatibilityResult {
    if (_value.compatibilityResult == null) {
      return null;
    }

    return $CompatibilityResultCopyWith<$Res>(_value.compatibilityResult!,
        (value) {
      return _then(_value.copyWith(compatibilityResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchImplCopyWith<$Res> implements $MatchCopyWith<$Res> {
  factory _$$MatchImplCopyWith(
          _$MatchImpl value, $Res Function(_$MatchImpl) then) =
      __$$MatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String matchId,
      List<String> participants,
      double compatibilityScore,
      MatchGrade grade,
      String aiSummary,
      CompatibilityResult? compatibilityResult,
      MatchStatus status,
      String? initiatorId,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      DateTime createdAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      DateTime? acceptedAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      DateTime? expiresAt});

  @override
  $CompatibilityResultCopyWith<$Res>? get compatibilityResult;
}

/// @nodoc
class __$$MatchImplCopyWithImpl<$Res>
    extends _$MatchCopyWithImpl<$Res, _$MatchImpl>
    implements _$$MatchImplCopyWith<$Res> {
  __$$MatchImplCopyWithImpl(
      _$MatchImpl _value, $Res Function(_$MatchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = null,
    Object? participants = null,
    Object? compatibilityScore = null,
    Object? grade = null,
    Object? aiSummary = null,
    Object? compatibilityResult = freezed,
    Object? status = null,
    Object? initiatorId = freezed,
    Object? createdAt = null,
    Object? acceptedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$MatchImpl(
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      compatibilityScore: null == compatibilityScore
          ? _value.compatibilityScore
          : compatibilityScore // ignore: cast_nullable_to_non_nullable
              as double,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as MatchGrade,
      aiSummary: null == aiSummary
          ? _value.aiSummary
          : aiSummary // ignore: cast_nullable_to_non_nullable
              as String,
      compatibilityResult: freezed == compatibilityResult
          ? _value.compatibilityResult
          : compatibilityResult // ignore: cast_nullable_to_non_nullable
              as CompatibilityResult?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      initiatorId: freezed == initiatorId
          ? _value.initiatorId
          : initiatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchImpl implements _Match {
  const _$MatchImpl(
      {required this.matchId,
      required final List<String> participants,
      required this.compatibilityScore,
      required this.grade,
      required this.aiSummary,
      this.compatibilityResult,
      this.status = MatchStatus.pending,
      this.initiatorId,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      required this.createdAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      this.acceptedAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      this.expiresAt})
      : _participants = participants;

  factory _$MatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchImplFromJson(json);

  @override
  final String matchId;
  final List<String> _participants;
  @override
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  final double compatibilityScore;
  @override
  final MatchGrade grade;
  @override
  final String aiSummary;
  @override
  final CompatibilityResult? compatibilityResult;
  @override
  @JsonKey()
  final MatchStatus status;
  @override
  final String? initiatorId;
  @override
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  @override
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  final DateTime? acceptedAt;
  @override
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'Match(matchId: $matchId, participants: $participants, compatibilityScore: $compatibilityScore, grade: $grade, aiSummary: $aiSummary, compatibilityResult: $compatibilityResult, status: $status, initiatorId: $initiatorId, createdAt: $createdAt, acceptedAt: $acceptedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchImpl &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.compatibilityScore, compatibilityScore) ||
                other.compatibilityScore == compatibilityScore) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.aiSummary, aiSummary) ||
                other.aiSummary == aiSummary) &&
            (identical(other.compatibilityResult, compatibilityResult) ||
                other.compatibilityResult == compatibilityResult) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.initiatorId, initiatorId) ||
                other.initiatorId == initiatorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      matchId,
      const DeepCollectionEquality().hash(_participants),
      compatibilityScore,
      grade,
      aiSummary,
      compatibilityResult,
      status,
      initiatorId,
      createdAt,
      acceptedAt,
      expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      __$$MatchImplCopyWithImpl<_$MatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchImplToJson(
      this,
    );
  }
}

abstract class _Match implements Match {
  const factory _Match(
      {required final String matchId,
      required final List<String> participants,
      required final double compatibilityScore,
      required final MatchGrade grade,
      required final String aiSummary,
      final CompatibilityResult? compatibilityResult,
      final MatchStatus status,
      final String? initiatorId,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      required final DateTime createdAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      final DateTime? acceptedAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      final DateTime? expiresAt}) = _$MatchImpl;

  factory _Match.fromJson(Map<String, dynamic> json) = _$MatchImpl.fromJson;

  @override
  String get matchId;
  @override
  List<String> get participants;
  @override
  double get compatibilityScore;
  @override
  MatchGrade get grade;
  @override
  String get aiSummary;
  @override
  CompatibilityResult? get compatibilityResult;
  @override
  MatchStatus get status;
  @override
  String? get initiatorId;
  @override
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime get createdAt;
  @override
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  DateTime? get acceptedAt;
  @override
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  DateTime? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
