// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compatibility_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompatibilityDetail _$CompatibilityDetailFromJson(Map<String, dynamic> json) {
  return _CompatibilityDetail.fromJson(json);
}

/// @nodoc
mixin _$CompatibilityDetail {
  String get category => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get weaknesses => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompatibilityDetailCopyWith<CompatibilityDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompatibilityDetailCopyWith<$Res> {
  factory $CompatibilityDetailCopyWith(
          CompatibilityDetail value, $Res Function(CompatibilityDetail) then) =
      _$CompatibilityDetailCopyWithImpl<$Res, CompatibilityDetail>;
  @useResult
  $Res call(
      {String category,
      double score,
      String description,
      List<String> strengths,
      List<String> weaknesses});
}

/// @nodoc
class _$CompatibilityDetailCopyWithImpl<$Res, $Val extends CompatibilityDetail>
    implements $CompatibilityDetailCopyWith<$Res> {
  _$CompatibilityDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? score = null,
    Object? description = null,
    Object? strengths = null,
    Object? weaknesses = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      strengths: null == strengths
          ? _value.strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weaknesses: null == weaknesses
          ? _value.weaknesses
          : weaknesses // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompatibilityDetailImplCopyWith<$Res>
    implements $CompatibilityDetailCopyWith<$Res> {
  factory _$$CompatibilityDetailImplCopyWith(_$CompatibilityDetailImpl value,
          $Res Function(_$CompatibilityDetailImpl) then) =
      __$$CompatibilityDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String category,
      double score,
      String description,
      List<String> strengths,
      List<String> weaknesses});
}

/// @nodoc
class __$$CompatibilityDetailImplCopyWithImpl<$Res>
    extends _$CompatibilityDetailCopyWithImpl<$Res, _$CompatibilityDetailImpl>
    implements _$$CompatibilityDetailImplCopyWith<$Res> {
  __$$CompatibilityDetailImplCopyWithImpl(_$CompatibilityDetailImpl _value,
      $Res Function(_$CompatibilityDetailImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? score = null,
    Object? description = null,
    Object? strengths = null,
    Object? weaknesses = null,
  }) {
    return _then(_$CompatibilityDetailImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      strengths: null == strengths
          ? _value._strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weaknesses: null == weaknesses
          ? _value._weaknesses
          : weaknesses // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompatibilityDetailImpl implements _CompatibilityDetail {
  const _$CompatibilityDetailImpl(
      {required this.category,
      required this.score,
      required this.description,
      final List<String> strengths = const [],
      final List<String> weaknesses = const []})
      : _strengths = strengths,
        _weaknesses = weaknesses;

  factory _$CompatibilityDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompatibilityDetailImplFromJson(json);

  @override
  final String category;
  @override
  final double score;
  @override
  final String description;
  final List<String> _strengths;
  @override
  @JsonKey()
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _weaknesses;
  @override
  @JsonKey()
  List<String> get weaknesses {
    if (_weaknesses is EqualUnmodifiableListView) return _weaknesses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weaknesses);
  }

  @override
  String toString() {
    return 'CompatibilityDetail(category: $category, score: $score, description: $description, strengths: $strengths, weaknesses: $weaknesses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompatibilityDetailImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._strengths, _strengths) &&
            const DeepCollectionEquality()
                .equals(other._weaknesses, _weaknesses));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      category,
      score,
      description,
      const DeepCollectionEquality().hash(_strengths),
      const DeepCollectionEquality().hash(_weaknesses));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompatibilityDetailImplCopyWith<_$CompatibilityDetailImpl> get copyWith =>
      __$$CompatibilityDetailImplCopyWithImpl<_$CompatibilityDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompatibilityDetailImplToJson(
      this,
    );
  }
}

abstract class _CompatibilityDetail implements CompatibilityDetail {
  const factory _CompatibilityDetail(
      {required final String category,
      required final double score,
      required final String description,
      final List<String> strengths,
      final List<String> weaknesses}) = _$CompatibilityDetailImpl;

  factory _CompatibilityDetail.fromJson(Map<String, dynamic> json) =
      _$CompatibilityDetailImpl.fromJson;

  @override
  String get category;
  @override
  double get score;
  @override
  String get description;
  @override
  List<String> get strengths;
  @override
  List<String> get weaknesses;
  @override
  @JsonKey(ignore: true)
  _$$CompatibilityDetailImplCopyWith<_$CompatibilityDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompatibilityResult _$CompatibilityResultFromJson(Map<String, dynamic> json) {
  return _CompatibilityResult.fromJson(json);
}

/// @nodoc
mixin _$CompatibilityResult {
  double get score => throw _privateConstructorUsedError;
  CompatibilityGrade get grade => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  List<CompatibilityDetail> get details => throw _privateConstructorUsedError;
  String get sajuAnalysis => throw _privateConstructorUsedError;
  String get elementalBalance => throw _privateConstructorUsedError;
  String get relationshipAdvice => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompatibilityResultCopyWith<CompatibilityResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompatibilityResultCopyWith<$Res> {
  factory $CompatibilityResultCopyWith(
          CompatibilityResult value, $Res Function(CompatibilityResult) then) =
      _$CompatibilityResultCopyWithImpl<$Res, CompatibilityResult>;
  @useResult
  $Res call(
      {double score,
      CompatibilityGrade grade,
      String summary,
      List<CompatibilityDetail> details,
      String sajuAnalysis,
      String elementalBalance,
      String relationshipAdvice});
}

/// @nodoc
class _$CompatibilityResultCopyWithImpl<$Res, $Val extends CompatibilityResult>
    implements $CompatibilityResultCopyWith<$Res> {
  _$CompatibilityResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? grade = null,
    Object? summary = null,
    Object? details = null,
    Object? sajuAnalysis = null,
    Object? elementalBalance = null,
    Object? relationshipAdvice = null,
  }) {
    return _then(_value.copyWith(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as CompatibilityGrade,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as List<CompatibilityDetail>,
      sajuAnalysis: null == sajuAnalysis
          ? _value.sajuAnalysis
          : sajuAnalysis // ignore: cast_nullable_to_non_nullable
              as String,
      elementalBalance: null == elementalBalance
          ? _value.elementalBalance
          : elementalBalance // ignore: cast_nullable_to_non_nullable
              as String,
      relationshipAdvice: null == relationshipAdvice
          ? _value.relationshipAdvice
          : relationshipAdvice // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompatibilityResultImplCopyWith<$Res>
    implements $CompatibilityResultCopyWith<$Res> {
  factory _$$CompatibilityResultImplCopyWith(_$CompatibilityResultImpl value,
          $Res Function(_$CompatibilityResultImpl) then) =
      __$$CompatibilityResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double score,
      CompatibilityGrade grade,
      String summary,
      List<CompatibilityDetail> details,
      String sajuAnalysis,
      String elementalBalance,
      String relationshipAdvice});
}

/// @nodoc
class __$$CompatibilityResultImplCopyWithImpl<$Res>
    extends _$CompatibilityResultCopyWithImpl<$Res, _$CompatibilityResultImpl>
    implements _$$CompatibilityResultImplCopyWith<$Res> {
  __$$CompatibilityResultImplCopyWithImpl(_$CompatibilityResultImpl _value,
      $Res Function(_$CompatibilityResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? grade = null,
    Object? summary = null,
    Object? details = null,
    Object? sajuAnalysis = null,
    Object? elementalBalance = null,
    Object? relationshipAdvice = null,
  }) {
    return _then(_$CompatibilityResultImpl(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as CompatibilityGrade,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as List<CompatibilityDetail>,
      sajuAnalysis: null == sajuAnalysis
          ? _value.sajuAnalysis
          : sajuAnalysis // ignore: cast_nullable_to_non_nullable
              as String,
      elementalBalance: null == elementalBalance
          ? _value.elementalBalance
          : elementalBalance // ignore: cast_nullable_to_non_nullable
              as String,
      relationshipAdvice: null == relationshipAdvice
          ? _value.relationshipAdvice
          : relationshipAdvice // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompatibilityResultImpl implements _CompatibilityResult {
  const _$CompatibilityResultImpl(
      {required this.score,
      required this.grade,
      required this.summary,
      final List<CompatibilityDetail> details = const [],
      this.sajuAnalysis = '',
      this.elementalBalance = '',
      this.relationshipAdvice = ''})
      : _details = details;

  factory _$CompatibilityResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompatibilityResultImplFromJson(json);

  @override
  final double score;
  @override
  final CompatibilityGrade grade;
  @override
  final String summary;
  final List<CompatibilityDetail> _details;
  @override
  @JsonKey()
  List<CompatibilityDetail> get details {
    if (_details is EqualUnmodifiableListView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_details);
  }

  @override
  @JsonKey()
  final String sajuAnalysis;
  @override
  @JsonKey()
  final String elementalBalance;
  @override
  @JsonKey()
  final String relationshipAdvice;

  @override
  String toString() {
    return 'CompatibilityResult(score: $score, grade: $grade, summary: $summary, details: $details, sajuAnalysis: $sajuAnalysis, elementalBalance: $elementalBalance, relationshipAdvice: $relationshipAdvice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompatibilityResultImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            (identical(other.sajuAnalysis, sajuAnalysis) ||
                other.sajuAnalysis == sajuAnalysis) &&
            (identical(other.elementalBalance, elementalBalance) ||
                other.elementalBalance == elementalBalance) &&
            (identical(other.relationshipAdvice, relationshipAdvice) ||
                other.relationshipAdvice == relationshipAdvice));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      score,
      grade,
      summary,
      const DeepCollectionEquality().hash(_details),
      sajuAnalysis,
      elementalBalance,
      relationshipAdvice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompatibilityResultImplCopyWith<_$CompatibilityResultImpl> get copyWith =>
      __$$CompatibilityResultImplCopyWithImpl<_$CompatibilityResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompatibilityResultImplToJson(
      this,
    );
  }
}

abstract class _CompatibilityResult implements CompatibilityResult {
  const factory _CompatibilityResult(
      {required final double score,
      required final CompatibilityGrade grade,
      required final String summary,
      final List<CompatibilityDetail> details,
      final String sajuAnalysis,
      final String elementalBalance,
      final String relationshipAdvice}) = _$CompatibilityResultImpl;

  factory _CompatibilityResult.fromJson(Map<String, dynamic> json) =
      _$CompatibilityResultImpl.fromJson;

  @override
  double get score;
  @override
  CompatibilityGrade get grade;
  @override
  String get summary;
  @override
  List<CompatibilityDetail> get details;
  @override
  String get sajuAnalysis;
  @override
  String get elementalBalance;
  @override
  String get relationshipAdvice;
  @override
  @JsonKey(ignore: true)
  _$$CompatibilityResultImplCopyWith<_$CompatibilityResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
