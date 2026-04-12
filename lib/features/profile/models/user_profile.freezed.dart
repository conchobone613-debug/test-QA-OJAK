// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  List<Gender> get preferredGenders => throw _privateConstructorUsedError;
  int get minAge => throw _privateConstructorUsedError;
  int get maxAge => throw _privateConstructorUsedError;
  double get minHeight => throw _privateConstructorUsedError;
  double get maxHeight => throw _privateConstructorUsedError;
  List<String> get preferredRegions => throw _privateConstructorUsedError;
  List<String> get preferredOccupations => throw _privateConstructorUsedError;
  bool get onlySajuCompatible => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {List<Gender> preferredGenders,
      int minAge,
      int maxAge,
      double minHeight,
      double maxHeight,
      List<String> preferredRegions,
      List<String> preferredOccupations,
      bool onlySajuCompatible});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preferredGenders = null,
    Object? minAge = null,
    Object? maxAge = null,
    Object? minHeight = null,
    Object? maxHeight = null,
    Object? preferredRegions = null,
    Object? preferredOccupations = null,
    Object? onlySajuCompatible = null,
  }) {
    return _then(_value.copyWith(
      preferredGenders: null == preferredGenders
          ? _value.preferredGenders
          : preferredGenders // ignore: cast_nullable_to_non_nullable
              as List<Gender>,
      minAge: null == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int,
      maxAge: null == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int,
      minHeight: null == minHeight
          ? _value.minHeight
          : minHeight // ignore: cast_nullable_to_non_nullable
              as double,
      maxHeight: null == maxHeight
          ? _value.maxHeight
          : maxHeight // ignore: cast_nullable_to_non_nullable
              as double,
      preferredRegions: null == preferredRegions
          ? _value.preferredRegions
          : preferredRegions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredOccupations: null == preferredOccupations
          ? _value.preferredOccupations
          : preferredOccupations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      onlySajuCompatible: null == onlySajuCompatible
          ? _value.onlySajuCompatible
          : onlySajuCompatible // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Gender> preferredGenders,
      int minAge,
      int maxAge,
      double minHeight,
      double maxHeight,
      List<String> preferredRegions,
      List<String> preferredOccupations,
      bool onlySajuCompatible});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preferredGenders = null,
    Object? minAge = null,
    Object? maxAge = null,
    Object? minHeight = null,
    Object? maxHeight = null,
    Object? preferredRegions = null,
    Object? preferredOccupations = null,
    Object? onlySajuCompatible = null,
  }) {
    return _then(_$UserPreferencesImpl(
      preferredGenders: null == preferredGenders
          ? _value._preferredGenders
          : preferredGenders // ignore: cast_nullable_to_non_nullable
              as List<Gender>,
      minAge: null == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int,
      maxAge: null == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int,
      minHeight: null == minHeight
          ? _value.minHeight
          : minHeight // ignore: cast_nullable_to_non_nullable
              as double,
      maxHeight: null == maxHeight
          ? _value.maxHeight
          : maxHeight // ignore: cast_nullable_to_non_nullable
              as double,
      preferredRegions: null == preferredRegions
          ? _value._preferredRegions
          : preferredRegions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredOccupations: null == preferredOccupations
          ? _value._preferredOccupations
          : preferredOccupations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      onlySajuCompatible: null == onlySajuCompatible
          ? _value.onlySajuCompatible
          : onlySajuCompatible // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {final List<Gender> preferredGenders = const [],
      this.minAge = 20,
      this.maxAge = 40,
      this.minHeight = 150.0,
      this.maxHeight = 200.0,
      final List<String> preferredRegions = const [],
      final List<String> preferredOccupations = const [],
      this.onlySajuCompatible = false})
      : _preferredGenders = preferredGenders,
        _preferredRegions = preferredRegions,
        _preferredOccupations = preferredOccupations;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  final List<Gender> _preferredGenders;
  @override
  @JsonKey()
  List<Gender> get preferredGenders {
    if (_preferredGenders is EqualUnmodifiableListView)
      return _preferredGenders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredGenders);
  }

  @override
  @JsonKey()
  final int minAge;
  @override
  @JsonKey()
  final int maxAge;
  @override
  @JsonKey()
  final double minHeight;
  @override
  @JsonKey()
  final double maxHeight;
  final List<String> _preferredRegions;
  @override
  @JsonKey()
  List<String> get preferredRegions {
    if (_preferredRegions is EqualUnmodifiableListView)
      return _preferredRegions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredRegions);
  }

  final List<String> _preferredOccupations;
  @override
  @JsonKey()
  List<String> get preferredOccupations {
    if (_preferredOccupations is EqualUnmodifiableListView)
      return _preferredOccupations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredOccupations);
  }

  @override
  @JsonKey()
  final bool onlySajuCompatible;

  @override
  String toString() {
    return 'UserPreferences(preferredGenders: $preferredGenders, minAge: $minAge, maxAge: $maxAge, minHeight: $minHeight, maxHeight: $maxHeight, preferredRegions: $preferredRegions, preferredOccupations: $preferredOccupations, onlySajuCompatible: $onlySajuCompatible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            const DeepCollectionEquality()
                .equals(other._preferredGenders, _preferredGenders) &&
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            (identical(other.minHeight, minHeight) ||
                other.minHeight == minHeight) &&
            (identical(other.maxHeight, maxHeight) ||
                other.maxHeight == maxHeight) &&
            const DeepCollectionEquality()
                .equals(other._preferredRegions, _preferredRegions) &&
            const DeepCollectionEquality()
                .equals(other._preferredOccupations, _preferredOccupations) &&
            (identical(other.onlySajuCompatible, onlySajuCompatible) ||
                other.onlySajuCompatible == onlySajuCompatible));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_preferredGenders),
      minAge,
      maxAge,
      minHeight,
      maxHeight,
      const DeepCollectionEquality().hash(_preferredRegions),
      const DeepCollectionEquality().hash(_preferredOccupations),
      onlySajuCompatible);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
      {final List<Gender> preferredGenders,
      final int minAge,
      final int maxAge,
      final double minHeight,
      final double maxHeight,
      final List<String> preferredRegions,
      final List<String> preferredOccupations,
      final bool onlySajuCompatible}) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  List<Gender> get preferredGenders;
  @override
  int get minAge;
  @override
  int get maxAge;
  @override
  double get minHeight;
  @override
  double get maxHeight;
  @override
  List<String> get preferredRegions;
  @override
  List<String> get preferredOccupations;
  @override
  bool get onlySajuCompatible;
  @override
  @JsonKey(ignore: true)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get uid => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime get birthDateTime => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;
  Occupation get occupation => throw _privateConstructorUsedError;
  String get region => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  List<String> get interests => throw _privateConstructorUsedError;
  List<String> get photos => throw _privateConstructorUsedError;
  SajuPillar? get sajuPillar => throw _privateConstructorUsedError;
  UserPreferences? get preferences => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  DateTime? get premiumExpiresAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String uid,
      String displayName,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      DateTime birthDateTime,
      Gender gender,
      double height,
      Occupation occupation,
      String region,
      String bio,
      List<String> interests,
      List<String> photos,
      SajuPillar? sajuPillar,
      UserPreferences? preferences,
      bool isPremium,
      bool isActive,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      DateTime? premiumExpiresAt,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      DateTime createdAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      DateTime? updatedAt});

  $SajuPillarCopyWith<$Res>? get sajuPillar;
  $UserPreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? birthDateTime = null,
    Object? gender = null,
    Object? height = null,
    Object? occupation = null,
    Object? region = null,
    Object? bio = null,
    Object? interests = null,
    Object? photos = null,
    Object? sajuPillar = freezed,
    Object? preferences = freezed,
    Object? isPremium = null,
    Object? isActive = null,
    Object? premiumExpiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      birthDateTime: null == birthDateTime
          ? _value.birthDateTime
          : birthDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      occupation: null == occupation
          ? _value.occupation
          : occupation // ignore: cast_nullable_to_non_nullable
              as Occupation,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      interests: null == interests
          ? _value.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sajuPillar: freezed == sajuPillar
          ? _value.sajuPillar
          : sajuPillar // ignore: cast_nullable_to_non_nullable
              as SajuPillar?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      premiumExpiresAt: freezed == premiumExpiresAt
          ? _value.premiumExpiresAt
          : premiumExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SajuPillarCopyWith<$Res>? get sajuPillar {
    if (_value.sajuPillar == null) {
      return null;
    }

    return $SajuPillarCopyWith<$Res>(_value.sajuPillar!, (value) {
      return _then(_value.copyWith(sajuPillar: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res>? get preferences {
    if (_value.preferences == null) {
      return null;
    }

    return $UserPreferencesCopyWith<$Res>(_value.preferences!, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String displayName,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      DateTime birthDateTime,
      Gender gender,
      double height,
      Occupation occupation,
      String region,
      String bio,
      List<String> interests,
      List<String> photos,
      SajuPillar? sajuPillar,
      UserPreferences? preferences,
      bool isPremium,
      bool isActive,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      DateTime? premiumExpiresAt,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      DateTime createdAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      DateTime? updatedAt});

  @override
  $SajuPillarCopyWith<$Res>? get sajuPillar;
  @override
  $UserPreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? birthDateTime = null,
    Object? gender = null,
    Object? height = null,
    Object? occupation = null,
    Object? region = null,
    Object? bio = null,
    Object? interests = null,
    Object? photos = null,
    Object? sajuPillar = freezed,
    Object? preferences = freezed,
    Object? isPremium = null,
    Object? isActive = null,
    Object? premiumExpiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserProfileImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      birthDateTime: null == birthDateTime
          ? _value.birthDateTime
          : birthDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      occupation: null == occupation
          ? _value.occupation
          : occupation // ignore: cast_nullable_to_non_nullable
              as Occupation,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      interests: null == interests
          ? _value._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sajuPillar: freezed == sajuPillar
          ? _value.sajuPillar
          : sajuPillar // ignore: cast_nullable_to_non_nullable
              as SajuPillar?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      premiumExpiresAt: freezed == premiumExpiresAt
          ? _value.premiumExpiresAt
          : premiumExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.uid,
      required this.displayName,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      required this.birthDateTime,
      required this.gender,
      required this.height,
      required this.occupation,
      required this.region,
      this.bio = '',
      final List<String> interests = const [],
      final List<String> photos = const [],
      this.sajuPillar,
      this.preferences,
      this.isPremium = false,
      this.isActive = true,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      this.premiumExpiresAt,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      required this.createdAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      this.updatedAt})
      : _interests = interests,
        _photos = photos;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String uid;
  @override
  final String displayName;
  @override
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime birthDateTime;
  @override
  final Gender gender;
  @override
  final double height;
  @override
  final Occupation occupation;
  @override
  final String region;
  @override
  @JsonKey()
  final String bio;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  final SajuPillar? sajuPillar;
  @override
  final UserPreferences? preferences;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  final DateTime? premiumExpiresAt;
  @override
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  @override
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, displayName: $displayName, birthDateTime: $birthDateTime, gender: $gender, height: $height, occupation: $occupation, region: $region, bio: $bio, interests: $interests, photos: $photos, sajuPillar: $sajuPillar, preferences: $preferences, isPremium: $isPremium, isActive: $isActive, premiumExpiresAt: $premiumExpiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.birthDateTime, birthDateTime) ||
                other.birthDateTime == birthDateTime) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.occupation, occupation) ||
                other.occupation == occupation) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality()
                .equals(other._interests, _interests) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.sajuPillar, sajuPillar) ||
                other.sajuPillar == sajuPillar) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.premiumExpiresAt, premiumExpiresAt) ||
                other.premiumExpiresAt == premiumExpiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      displayName,
      birthDateTime,
      gender,
      height,
      occupation,
      region,
      bio,
      const DeepCollectionEquality().hash(_interests),
      const DeepCollectionEquality().hash(_photos),
      sajuPillar,
      preferences,
      isPremium,
      isActive,
      premiumExpiresAt,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String uid,
      required final String displayName,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      required final DateTime birthDateTime,
      required final Gender gender,
      required final double height,
      required final Occupation occupation,
      required final String region,
      final String bio,
      final List<String> interests,
      final List<String> photos,
      final SajuPillar? sajuPillar,
      final UserPreferences? preferences,
      final bool isPremium,
      final bool isActive,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      final DateTime? premiumExpiresAt,
      @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
      required final DateTime createdAt,
      @JsonKey(
          fromJson: _timestampToDateTimeNullable,
          toJson: _dateTimeToTimestampNullable)
      final DateTime? updatedAt}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get uid;
  @override
  String get displayName;
  @override
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime get birthDateTime;
  @override
  Gender get gender;
  @override
  double get height;
  @override
  Occupation get occupation;
  @override
  String get region;
  @override
  String get bio;
  @override
  List<String> get interests;
  @override
  List<String> get photos;
  @override
  SajuPillar? get sajuPillar;
  @override
  UserPreferences? get preferences;
  @override
  bool get isPremium;
  @override
  bool get isActive;
  @override
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  DateTime? get premiumExpiresAt;
  @override
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  DateTime get createdAt;
  @override
  @JsonKey(
      fromJson: _timestampToDateTimeNullable,
      toJson: _dateTimeToTimestampNullable)
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
