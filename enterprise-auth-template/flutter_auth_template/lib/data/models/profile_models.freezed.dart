// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) {
  return _ProfileResponse.fromJson(json);
}

/// @nodoc
mixin _$ProfileResponse {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  List<String> get roles => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  String? get lastLogin => throw _privateConstructorUsedError;

  /// Serializes this ProfileResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileResponseCopyWith<ProfileResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileResponseCopyWith<$Res> {
  factory $ProfileResponseCopyWith(
    ProfileResponse value,
    $Res Function(ProfileResponse) then,
  ) = _$ProfileResponseCopyWithImpl<$Res, ProfileResponse>;
  @useResult
  $Res call({
    String id,
    String email,
    String firstName,
    String lastName,
    String? phoneNumber,
    String? bio,
    String? avatarUrl,
    String? timezone,
    String? language,
    bool isActive,
    bool isVerified,
    List<String> roles,
    String createdAt,
    String updatedAt,
    String? lastLogin,
  });
}

/// @nodoc
class _$ProfileResponseCopyWithImpl<$Res, $Val extends ProfileResponse>
    implements $ProfileResponseCopyWith<$Res> {
  _$ProfileResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phoneNumber = freezed,
    Object? bio = freezed,
    Object? avatarUrl = freezed,
    Object? timezone = freezed,
    Object? language = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? roles = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLogin = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            timezone: freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String?,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            lastLogin: freezed == lastLogin
                ? _value.lastLogin
                : lastLogin // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileResponseImplCopyWith<$Res>
    implements $ProfileResponseCopyWith<$Res> {
  factory _$$ProfileResponseImplCopyWith(
    _$ProfileResponseImpl value,
    $Res Function(_$ProfileResponseImpl) then,
  ) = __$$ProfileResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String firstName,
    String lastName,
    String? phoneNumber,
    String? bio,
    String? avatarUrl,
    String? timezone,
    String? language,
    bool isActive,
    bool isVerified,
    List<String> roles,
    String createdAt,
    String updatedAt,
    String? lastLogin,
  });
}

/// @nodoc
class __$$ProfileResponseImplCopyWithImpl<$Res>
    extends _$ProfileResponseCopyWithImpl<$Res, _$ProfileResponseImpl>
    implements _$$ProfileResponseImplCopyWith<$Res> {
  __$$ProfileResponseImplCopyWithImpl(
    _$ProfileResponseImpl _value,
    $Res Function(_$ProfileResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? phoneNumber = freezed,
    Object? bio = freezed,
    Object? avatarUrl = freezed,
    Object? timezone = freezed,
    Object? language = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? roles = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLogin = freezed,
  }) {
    return _then(
      _$ProfileResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        timezone: freezed == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String?,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        lastLogin: freezed == lastLogin
            ? _value.lastLogin
            : lastLogin // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileResponseImpl implements _ProfileResponse {
  const _$ProfileResponseImpl({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.bio,
    this.avatarUrl,
    this.timezone,
    this.language,
    required this.isActive,
    required this.isVerified,
    required final List<String> roles,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  }) : _roles = roles;

  factory _$ProfileResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? phoneNumber;
  @override
  final String? bio;
  @override
  final String? avatarUrl;
  @override
  final String? timezone;
  @override
  final String? language;
  @override
  final bool isActive;
  @override
  final bool isVerified;
  final List<String> _roles;
  @override
  List<String> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  final String? lastLogin;

  @override
  String toString() {
    return 'ProfileResponse(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, bio: $bio, avatarUrl: $avatarUrl, timezone: $timezone, language: $language, isActive: $isActive, isVerified: $isVerified, roles: $roles, createdAt: $createdAt, updatedAt: $updatedAt, lastLogin: $lastLogin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    firstName,
    lastName,
    phoneNumber,
    bio,
    avatarUrl,
    timezone,
    language,
    isActive,
    isVerified,
    const DeepCollectionEquality().hash(_roles),
    createdAt,
    updatedAt,
    lastLogin,
  );

  /// Create a copy of ProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileResponseImplCopyWith<_$ProfileResponseImpl> get copyWith =>
      __$$ProfileResponseImplCopyWithImpl<_$ProfileResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileResponseImplToJson(this);
  }
}

abstract class _ProfileResponse implements ProfileResponse {
  const factory _ProfileResponse({
    required final String id,
    required final String email,
    required final String firstName,
    required final String lastName,
    final String? phoneNumber,
    final String? bio,
    final String? avatarUrl,
    final String? timezone,
    final String? language,
    required final bool isActive,
    required final bool isVerified,
    required final List<String> roles,
    required final String createdAt,
    required final String updatedAt,
    final String? lastLogin,
  }) = _$ProfileResponseImpl;

  factory _ProfileResponse.fromJson(Map<String, dynamic> json) =
      _$ProfileResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String? get phoneNumber;
  @override
  String? get bio;
  @override
  String? get avatarUrl;
  @override
  String? get timezone;
  @override
  String? get language;
  @override
  bool get isActive;
  @override
  bool get isVerified;
  @override
  List<String> get roles;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  String? get lastLogin;

  /// Create a copy of ProfileResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileResponseImplCopyWith<_$ProfileResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileUpdateRequest _$ProfileUpdateRequestFromJson(Map<String, dynamic> json) {
  return _ProfileUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ProfileUpdateRequest {
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;

  /// Serializes this ProfileUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileUpdateRequestCopyWith<ProfileUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileUpdateRequestCopyWith<$Res> {
  factory $ProfileUpdateRequestCopyWith(
    ProfileUpdateRequest value,
    $Res Function(ProfileUpdateRequest) then,
  ) = _$ProfileUpdateRequestCopyWithImpl<$Res, ProfileUpdateRequest>;
  @useResult
  $Res call({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    String? timezone,
    String? language,
  });
}

/// @nodoc
class _$ProfileUpdateRequestCopyWithImpl<
  $Res,
  $Val extends ProfileUpdateRequest
>
    implements $ProfileUpdateRequestCopyWith<$Res> {
  _$ProfileUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? bio = freezed,
    Object? timezone = freezed,
    Object? language = freezed,
  }) {
    return _then(
      _value.copyWith(
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            timezone: freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String?,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileUpdateRequestImplCopyWith<$Res>
    implements $ProfileUpdateRequestCopyWith<$Res> {
  factory _$$ProfileUpdateRequestImplCopyWith(
    _$ProfileUpdateRequestImpl value,
    $Res Function(_$ProfileUpdateRequestImpl) then,
  ) = __$$ProfileUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    String? timezone,
    String? language,
  });
}

/// @nodoc
class __$$ProfileUpdateRequestImplCopyWithImpl<$Res>
    extends _$ProfileUpdateRequestCopyWithImpl<$Res, _$ProfileUpdateRequestImpl>
    implements _$$ProfileUpdateRequestImplCopyWith<$Res> {
  __$$ProfileUpdateRequestImplCopyWithImpl(
    _$ProfileUpdateRequestImpl _value,
    $Res Function(_$ProfileUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? bio = freezed,
    Object? timezone = freezed,
    Object? language = freezed,
  }) {
    return _then(
      _$ProfileUpdateRequestImpl(
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        timezone: freezed == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String?,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileUpdateRequestImpl implements _ProfileUpdateRequest {
  const _$ProfileUpdateRequestImpl({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.bio,
    this.timezone,
    this.language,
  });

  factory _$ProfileUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileUpdateRequestImplFromJson(json);

  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? phoneNumber;
  @override
  final String? bio;
  @override
  final String? timezone;
  @override
  final String? language;

  @override
  String toString() {
    return 'ProfileUpdateRequest(firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, bio: $bio, timezone: $timezone, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileUpdateRequestImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    firstName,
    lastName,
    phoneNumber,
    bio,
    timezone,
    language,
  );

  /// Create a copy of ProfileUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileUpdateRequestImplCopyWith<_$ProfileUpdateRequestImpl>
  get copyWith =>
      __$$ProfileUpdateRequestImplCopyWithImpl<_$ProfileUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileUpdateRequestImplToJson(this);
  }
}

abstract class _ProfileUpdateRequest implements ProfileUpdateRequest {
  const factory _ProfileUpdateRequest({
    final String? firstName,
    final String? lastName,
    final String? phoneNumber,
    final String? bio,
    final String? timezone,
    final String? language,
  }) = _$ProfileUpdateRequestImpl;

  factory _ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$ProfileUpdateRequestImpl.fromJson;

  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get phoneNumber;
  @override
  String? get bio;
  @override
  String? get timezone;
  @override
  String? get language;

  /// Create a copy of ProfileUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileUpdateRequestImplCopyWith<_$ProfileUpdateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PasswordChangeRequest _$PasswordChangeRequestFromJson(
  Map<String, dynamic> json,
) {
  return _PasswordChangeRequest.fromJson(json);
}

/// @nodoc
mixin _$PasswordChangeRequest {
  String get currentPassword => throw _privateConstructorUsedError;
  String get newPassword => throw _privateConstructorUsedError;

  /// Serializes this PasswordChangeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PasswordChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasswordChangeRequestCopyWith<PasswordChangeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordChangeRequestCopyWith<$Res> {
  factory $PasswordChangeRequestCopyWith(
    PasswordChangeRequest value,
    $Res Function(PasswordChangeRequest) then,
  ) = _$PasswordChangeRequestCopyWithImpl<$Res, PasswordChangeRequest>;
  @useResult
  $Res call({String currentPassword, String newPassword});
}

/// @nodoc
class _$PasswordChangeRequestCopyWithImpl<
  $Res,
  $Val extends PasswordChangeRequest
>
    implements $PasswordChangeRequestCopyWith<$Res> {
  _$PasswordChangeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasswordChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? currentPassword = null, Object? newPassword = null}) {
    return _then(
      _value.copyWith(
            currentPassword: null == currentPassword
                ? _value.currentPassword
                : currentPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            newPassword: null == newPassword
                ? _value.newPassword
                : newPassword // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PasswordChangeRequestImplCopyWith<$Res>
    implements $PasswordChangeRequestCopyWith<$Res> {
  factory _$$PasswordChangeRequestImplCopyWith(
    _$PasswordChangeRequestImpl value,
    $Res Function(_$PasswordChangeRequestImpl) then,
  ) = __$$PasswordChangeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String currentPassword, String newPassword});
}

/// @nodoc
class __$$PasswordChangeRequestImplCopyWithImpl<$Res>
    extends
        _$PasswordChangeRequestCopyWithImpl<$Res, _$PasswordChangeRequestImpl>
    implements _$$PasswordChangeRequestImplCopyWith<$Res> {
  __$$PasswordChangeRequestImplCopyWithImpl(
    _$PasswordChangeRequestImpl _value,
    $Res Function(_$PasswordChangeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PasswordChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? currentPassword = null, Object? newPassword = null}) {
    return _then(
      _$PasswordChangeRequestImpl(
        currentPassword: null == currentPassword
            ? _value.currentPassword
            : currentPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        newPassword: null == newPassword
            ? _value.newPassword
            : newPassword // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PasswordChangeRequestImpl implements _PasswordChangeRequest {
  const _$PasswordChangeRequestImpl({
    required this.currentPassword,
    required this.newPassword,
  });

  factory _$PasswordChangeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PasswordChangeRequestImplFromJson(json);

  @override
  final String currentPassword;
  @override
  final String newPassword;

  @override
  String toString() {
    return 'PasswordChangeRequest(currentPassword: $currentPassword, newPassword: $newPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordChangeRequestImpl &&
            (identical(other.currentPassword, currentPassword) ||
                other.currentPassword == currentPassword) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentPassword, newPassword);

  /// Create a copy of PasswordChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordChangeRequestImplCopyWith<_$PasswordChangeRequestImpl>
  get copyWith =>
      __$$PasswordChangeRequestImplCopyWithImpl<_$PasswordChangeRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PasswordChangeRequestImplToJson(this);
  }
}

abstract class _PasswordChangeRequest implements PasswordChangeRequest {
  const factory _PasswordChangeRequest({
    required final String currentPassword,
    required final String newPassword,
  }) = _$PasswordChangeRequestImpl;

  factory _PasswordChangeRequest.fromJson(Map<String, dynamic> json) =
      _$PasswordChangeRequestImpl.fromJson;

  @override
  String get currentPassword;
  @override
  String get newPassword;

  /// Create a copy of PasswordChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordChangeRequestImplCopyWith<_$PasswordChangeRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

EmailChangeRequest _$EmailChangeRequestFromJson(Map<String, dynamic> json) {
  return _EmailChangeRequest.fromJson(json);
}

/// @nodoc
mixin _$EmailChangeRequest {
  String get newEmail => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this EmailChangeRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmailChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmailChangeRequestCopyWith<EmailChangeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailChangeRequestCopyWith<$Res> {
  factory $EmailChangeRequestCopyWith(
    EmailChangeRequest value,
    $Res Function(EmailChangeRequest) then,
  ) = _$EmailChangeRequestCopyWithImpl<$Res, EmailChangeRequest>;
  @useResult
  $Res call({String newEmail, String password});
}

/// @nodoc
class _$EmailChangeRequestCopyWithImpl<$Res, $Val extends EmailChangeRequest>
    implements $EmailChangeRequestCopyWith<$Res> {
  _$EmailChangeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmailChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? newEmail = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            newEmail: null == newEmail
                ? _value.newEmail
                : newEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EmailChangeRequestImplCopyWith<$Res>
    implements $EmailChangeRequestCopyWith<$Res> {
  factory _$$EmailChangeRequestImplCopyWith(
    _$EmailChangeRequestImpl value,
    $Res Function(_$EmailChangeRequestImpl) then,
  ) = __$$EmailChangeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String newEmail, String password});
}

/// @nodoc
class __$$EmailChangeRequestImplCopyWithImpl<$Res>
    extends _$EmailChangeRequestCopyWithImpl<$Res, _$EmailChangeRequestImpl>
    implements _$$EmailChangeRequestImplCopyWith<$Res> {
  __$$EmailChangeRequestImplCopyWithImpl(
    _$EmailChangeRequestImpl _value,
    $Res Function(_$EmailChangeRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? newEmail = null, Object? password = null}) {
    return _then(
      _$EmailChangeRequestImpl(
        newEmail: null == newEmail
            ? _value.newEmail
            : newEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmailChangeRequestImpl implements _EmailChangeRequest {
  const _$EmailChangeRequestImpl({
    required this.newEmail,
    required this.password,
  });

  factory _$EmailChangeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmailChangeRequestImplFromJson(json);

  @override
  final String newEmail;
  @override
  final String password;

  @override
  String toString() {
    return 'EmailChangeRequest(newEmail: $newEmail, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailChangeRequestImpl &&
            (identical(other.newEmail, newEmail) ||
                other.newEmail == newEmail) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, newEmail, password);

  /// Create a copy of EmailChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailChangeRequestImplCopyWith<_$EmailChangeRequestImpl> get copyWith =>
      __$$EmailChangeRequestImplCopyWithImpl<_$EmailChangeRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EmailChangeRequestImplToJson(this);
  }
}

abstract class _EmailChangeRequest implements EmailChangeRequest {
  const factory _EmailChangeRequest({
    required final String newEmail,
    required final String password,
  }) = _$EmailChangeRequestImpl;

  factory _EmailChangeRequest.fromJson(Map<String, dynamic> json) =
      _$EmailChangeRequestImpl.fromJson;

  @override
  String get newEmail;
  @override
  String get password;

  /// Create a copy of EmailChangeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailChangeRequestImplCopyWith<_$EmailChangeRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationPreferencesRequest _$NotificationPreferencesRequestFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationPreferencesRequest.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferencesRequest {
  bool get emailNotifications => throw _privateConstructorUsedError;
  bool get pushNotifications => throw _privateConstructorUsedError;
  bool get smsNotifications => throw _privateConstructorUsedError;
  bool get marketingEmails => throw _privateConstructorUsedError;
  bool get securityAlerts => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreferencesRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferencesRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesRequestCopyWith<NotificationPreferencesRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesRequestCopyWith<$Res> {
  factory $NotificationPreferencesRequestCopyWith(
    NotificationPreferencesRequest value,
    $Res Function(NotificationPreferencesRequest) then,
  ) =
      _$NotificationPreferencesRequestCopyWithImpl<
        $Res,
        NotificationPreferencesRequest
      >;
  @useResult
  $Res call({
    bool emailNotifications,
    bool pushNotifications,
    bool smsNotifications,
    bool marketingEmails,
    bool securityAlerts,
  });
}

/// @nodoc
class _$NotificationPreferencesRequestCopyWithImpl<
  $Res,
  $Val extends NotificationPreferencesRequest
>
    implements $NotificationPreferencesRequestCopyWith<$Res> {
  _$NotificationPreferencesRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferencesRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailNotifications = null,
    Object? pushNotifications = null,
    Object? smsNotifications = null,
    Object? marketingEmails = null,
    Object? securityAlerts = null,
  }) {
    return _then(
      _value.copyWith(
            emailNotifications: null == emailNotifications
                ? _value.emailNotifications
                : emailNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            pushNotifications: null == pushNotifications
                ? _value.pushNotifications
                : pushNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            smsNotifications: null == smsNotifications
                ? _value.smsNotifications
                : smsNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            marketingEmails: null == marketingEmails
                ? _value.marketingEmails
                : marketingEmails // ignore: cast_nullable_to_non_nullable
                      as bool,
            securityAlerts: null == securityAlerts
                ? _value.securityAlerts
                : securityAlerts // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationPreferencesRequestImplCopyWith<$Res>
    implements $NotificationPreferencesRequestCopyWith<$Res> {
  factory _$$NotificationPreferencesRequestImplCopyWith(
    _$NotificationPreferencesRequestImpl value,
    $Res Function(_$NotificationPreferencesRequestImpl) then,
  ) = __$$NotificationPreferencesRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool emailNotifications,
    bool pushNotifications,
    bool smsNotifications,
    bool marketingEmails,
    bool securityAlerts,
  });
}

/// @nodoc
class __$$NotificationPreferencesRequestImplCopyWithImpl<$Res>
    extends
        _$NotificationPreferencesRequestCopyWithImpl<
          $Res,
          _$NotificationPreferencesRequestImpl
        >
    implements _$$NotificationPreferencesRequestImplCopyWith<$Res> {
  __$$NotificationPreferencesRequestImplCopyWithImpl(
    _$NotificationPreferencesRequestImpl _value,
    $Res Function(_$NotificationPreferencesRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationPreferencesRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailNotifications = null,
    Object? pushNotifications = null,
    Object? smsNotifications = null,
    Object? marketingEmails = null,
    Object? securityAlerts = null,
  }) {
    return _then(
      _$NotificationPreferencesRequestImpl(
        emailNotifications: null == emailNotifications
            ? _value.emailNotifications
            : emailNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        pushNotifications: null == pushNotifications
            ? _value.pushNotifications
            : pushNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        smsNotifications: null == smsNotifications
            ? _value.smsNotifications
            : smsNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        marketingEmails: null == marketingEmails
            ? _value.marketingEmails
            : marketingEmails // ignore: cast_nullable_to_non_nullable
                  as bool,
        securityAlerts: null == securityAlerts
            ? _value.securityAlerts
            : securityAlerts // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferencesRequestImpl
    implements _NotificationPreferencesRequest {
  const _$NotificationPreferencesRequestImpl({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.marketingEmails = false,
    this.securityAlerts = true,
  });

  factory _$NotificationPreferencesRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$NotificationPreferencesRequestImplFromJson(json);

  @override
  @JsonKey()
  final bool emailNotifications;
  @override
  @JsonKey()
  final bool pushNotifications;
  @override
  @JsonKey()
  final bool smsNotifications;
  @override
  @JsonKey()
  final bool marketingEmails;
  @override
  @JsonKey()
  final bool securityAlerts;

  @override
  String toString() {
    return 'NotificationPreferencesRequest(emailNotifications: $emailNotifications, pushNotifications: $pushNotifications, smsNotifications: $smsNotifications, marketingEmails: $marketingEmails, securityAlerts: $securityAlerts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesRequestImpl &&
            (identical(other.emailNotifications, emailNotifications) ||
                other.emailNotifications == emailNotifications) &&
            (identical(other.pushNotifications, pushNotifications) ||
                other.pushNotifications == pushNotifications) &&
            (identical(other.smsNotifications, smsNotifications) ||
                other.smsNotifications == smsNotifications) &&
            (identical(other.marketingEmails, marketingEmails) ||
                other.marketingEmails == marketingEmails) &&
            (identical(other.securityAlerts, securityAlerts) ||
                other.securityAlerts == securityAlerts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    emailNotifications,
    pushNotifications,
    smsNotifications,
    marketingEmails,
    securityAlerts,
  );

  /// Create a copy of NotificationPreferencesRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesRequestImplCopyWith<
    _$NotificationPreferencesRequestImpl
  >
  get copyWith =>
      __$$NotificationPreferencesRequestImplCopyWithImpl<
        _$NotificationPreferencesRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesRequestImplToJson(this);
  }
}

abstract class _NotificationPreferencesRequest
    implements NotificationPreferencesRequest {
  const factory _NotificationPreferencesRequest({
    final bool emailNotifications,
    final bool pushNotifications,
    final bool smsNotifications,
    final bool marketingEmails,
    final bool securityAlerts,
  }) = _$NotificationPreferencesRequestImpl;

  factory _NotificationPreferencesRequest.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesRequestImpl.fromJson;

  @override
  bool get emailNotifications;
  @override
  bool get pushNotifications;
  @override
  bool get smsNotifications;
  @override
  bool get marketingEmails;
  @override
  bool get securityAlerts;

  /// Create a copy of NotificationPreferencesRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesRequestImplCopyWith<
    _$NotificationPreferencesRequestImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

SecuritySettingsResponse _$SecuritySettingsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _SecuritySettingsResponse.fromJson(json);
}

/// @nodoc
mixin _$SecuritySettingsResponse {
  bool get twoFactorEnabled => throw _privateConstructorUsedError;
  bool get loginAlerts => throw _privateConstructorUsedError;
  int get sessionTimeout => throw _privateConstructorUsedError;
  String? get passwordLastChanged => throw _privateConstructorUsedError;
  int get activeSessions => throw _privateConstructorUsedError;

  /// Serializes this SecuritySettingsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecuritySettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecuritySettingsResponseCopyWith<SecuritySettingsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecuritySettingsResponseCopyWith<$Res> {
  factory $SecuritySettingsResponseCopyWith(
    SecuritySettingsResponse value,
    $Res Function(SecuritySettingsResponse) then,
  ) = _$SecuritySettingsResponseCopyWithImpl<$Res, SecuritySettingsResponse>;
  @useResult
  $Res call({
    bool twoFactorEnabled,
    bool loginAlerts,
    int sessionTimeout,
    String? passwordLastChanged,
    int activeSessions,
  });
}

/// @nodoc
class _$SecuritySettingsResponseCopyWithImpl<
  $Res,
  $Val extends SecuritySettingsResponse
>
    implements $SecuritySettingsResponseCopyWith<$Res> {
  _$SecuritySettingsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecuritySettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? twoFactorEnabled = null,
    Object? loginAlerts = null,
    Object? sessionTimeout = null,
    Object? passwordLastChanged = freezed,
    Object? activeSessions = null,
  }) {
    return _then(
      _value.copyWith(
            twoFactorEnabled: null == twoFactorEnabled
                ? _value.twoFactorEnabled
                : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            loginAlerts: null == loginAlerts
                ? _value.loginAlerts
                : loginAlerts // ignore: cast_nullable_to_non_nullable
                      as bool,
            sessionTimeout: null == sessionTimeout
                ? _value.sessionTimeout
                : sessionTimeout // ignore: cast_nullable_to_non_nullable
                      as int,
            passwordLastChanged: freezed == passwordLastChanged
                ? _value.passwordLastChanged
                : passwordLastChanged // ignore: cast_nullable_to_non_nullable
                      as String?,
            activeSessions: null == activeSessions
                ? _value.activeSessions
                : activeSessions // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SecuritySettingsResponseImplCopyWith<$Res>
    implements $SecuritySettingsResponseCopyWith<$Res> {
  factory _$$SecuritySettingsResponseImplCopyWith(
    _$SecuritySettingsResponseImpl value,
    $Res Function(_$SecuritySettingsResponseImpl) then,
  ) = __$$SecuritySettingsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool twoFactorEnabled,
    bool loginAlerts,
    int sessionTimeout,
    String? passwordLastChanged,
    int activeSessions,
  });
}

/// @nodoc
class __$$SecuritySettingsResponseImplCopyWithImpl<$Res>
    extends
        _$SecuritySettingsResponseCopyWithImpl<
          $Res,
          _$SecuritySettingsResponseImpl
        >
    implements _$$SecuritySettingsResponseImplCopyWith<$Res> {
  __$$SecuritySettingsResponseImplCopyWithImpl(
    _$SecuritySettingsResponseImpl _value,
    $Res Function(_$SecuritySettingsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecuritySettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? twoFactorEnabled = null,
    Object? loginAlerts = null,
    Object? sessionTimeout = null,
    Object? passwordLastChanged = freezed,
    Object? activeSessions = null,
  }) {
    return _then(
      _$SecuritySettingsResponseImpl(
        twoFactorEnabled: null == twoFactorEnabled
            ? _value.twoFactorEnabled
            : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        loginAlerts: null == loginAlerts
            ? _value.loginAlerts
            : loginAlerts // ignore: cast_nullable_to_non_nullable
                  as bool,
        sessionTimeout: null == sessionTimeout
            ? _value.sessionTimeout
            : sessionTimeout // ignore: cast_nullable_to_non_nullable
                  as int,
        passwordLastChanged: freezed == passwordLastChanged
            ? _value.passwordLastChanged
            : passwordLastChanged // ignore: cast_nullable_to_non_nullable
                  as String?,
        activeSessions: null == activeSessions
            ? _value.activeSessions
            : activeSessions // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SecuritySettingsResponseImpl implements _SecuritySettingsResponse {
  const _$SecuritySettingsResponseImpl({
    required this.twoFactorEnabled,
    required this.loginAlerts,
    required this.sessionTimeout,
    this.passwordLastChanged,
    required this.activeSessions,
  });

  factory _$SecuritySettingsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecuritySettingsResponseImplFromJson(json);

  @override
  final bool twoFactorEnabled;
  @override
  final bool loginAlerts;
  @override
  final int sessionTimeout;
  @override
  final String? passwordLastChanged;
  @override
  final int activeSessions;

  @override
  String toString() {
    return 'SecuritySettingsResponse(twoFactorEnabled: $twoFactorEnabled, loginAlerts: $loginAlerts, sessionTimeout: $sessionTimeout, passwordLastChanged: $passwordLastChanged, activeSessions: $activeSessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecuritySettingsResponseImpl &&
            (identical(other.twoFactorEnabled, twoFactorEnabled) ||
                other.twoFactorEnabled == twoFactorEnabled) &&
            (identical(other.loginAlerts, loginAlerts) ||
                other.loginAlerts == loginAlerts) &&
            (identical(other.sessionTimeout, sessionTimeout) ||
                other.sessionTimeout == sessionTimeout) &&
            (identical(other.passwordLastChanged, passwordLastChanged) ||
                other.passwordLastChanged == passwordLastChanged) &&
            (identical(other.activeSessions, activeSessions) ||
                other.activeSessions == activeSessions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    twoFactorEnabled,
    loginAlerts,
    sessionTimeout,
    passwordLastChanged,
    activeSessions,
  );

  /// Create a copy of SecuritySettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecuritySettingsResponseImplCopyWith<_$SecuritySettingsResponseImpl>
  get copyWith =>
      __$$SecuritySettingsResponseImplCopyWithImpl<
        _$SecuritySettingsResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SecuritySettingsResponseImplToJson(this);
  }
}

abstract class _SecuritySettingsResponse implements SecuritySettingsResponse {
  const factory _SecuritySettingsResponse({
    required final bool twoFactorEnabled,
    required final bool loginAlerts,
    required final int sessionTimeout,
    final String? passwordLastChanged,
    required final int activeSessions,
  }) = _$SecuritySettingsResponseImpl;

  factory _SecuritySettingsResponse.fromJson(Map<String, dynamic> json) =
      _$SecuritySettingsResponseImpl.fromJson;

  @override
  bool get twoFactorEnabled;
  @override
  bool get loginAlerts;
  @override
  int get sessionTimeout;
  @override
  String? get passwordLastChanged;
  @override
  int get activeSessions;

  /// Create a copy of SecuritySettingsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecuritySettingsResponseImplCopyWith<_$SecuritySettingsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AvatarUploadResponse _$AvatarUploadResponseFromJson(Map<String, dynamic> json) {
  return _AvatarUploadResponse.fromJson(json);
}

/// @nodoc
mixin _$AvatarUploadResponse {
  String get avatarUrl => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this AvatarUploadResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AvatarUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvatarUploadResponseCopyWith<AvatarUploadResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvatarUploadResponseCopyWith<$Res> {
  factory $AvatarUploadResponseCopyWith(
    AvatarUploadResponse value,
    $Res Function(AvatarUploadResponse) then,
  ) = _$AvatarUploadResponseCopyWithImpl<$Res, AvatarUploadResponse>;
  @useResult
  $Res call({String avatarUrl, String message});
}

/// @nodoc
class _$AvatarUploadResponseCopyWithImpl<
  $Res,
  $Val extends AvatarUploadResponse
>
    implements $AvatarUploadResponseCopyWith<$Res> {
  _$AvatarUploadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvatarUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? avatarUrl = null, Object? message = null}) {
    return _then(
      _value.copyWith(
            avatarUrl: null == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AvatarUploadResponseImplCopyWith<$Res>
    implements $AvatarUploadResponseCopyWith<$Res> {
  factory _$$AvatarUploadResponseImplCopyWith(
    _$AvatarUploadResponseImpl value,
    $Res Function(_$AvatarUploadResponseImpl) then,
  ) = __$$AvatarUploadResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String avatarUrl, String message});
}

/// @nodoc
class __$$AvatarUploadResponseImplCopyWithImpl<$Res>
    extends _$AvatarUploadResponseCopyWithImpl<$Res, _$AvatarUploadResponseImpl>
    implements _$$AvatarUploadResponseImplCopyWith<$Res> {
  __$$AvatarUploadResponseImplCopyWithImpl(
    _$AvatarUploadResponseImpl _value,
    $Res Function(_$AvatarUploadResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AvatarUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? avatarUrl = null, Object? message = null}) {
    return _then(
      _$AvatarUploadResponseImpl(
        avatarUrl: null == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AvatarUploadResponseImpl implements _AvatarUploadResponse {
  const _$AvatarUploadResponseImpl({
    required this.avatarUrl,
    required this.message,
  });

  factory _$AvatarUploadResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvatarUploadResponseImplFromJson(json);

  @override
  final String avatarUrl;
  @override
  final String message;

  @override
  String toString() {
    return 'AvatarUploadResponse(avatarUrl: $avatarUrl, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvatarUploadResponseImpl &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, avatarUrl, message);

  /// Create a copy of AvatarUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvatarUploadResponseImplCopyWith<_$AvatarUploadResponseImpl>
  get copyWith =>
      __$$AvatarUploadResponseImplCopyWithImpl<_$AvatarUploadResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AvatarUploadResponseImplToJson(this);
  }
}

abstract class _AvatarUploadResponse implements AvatarUploadResponse {
  const factory _AvatarUploadResponse({
    required final String avatarUrl,
    required final String message,
  }) = _$AvatarUploadResponseImpl;

  factory _AvatarUploadResponse.fromJson(Map<String, dynamic> json) =
      _$AvatarUploadResponseImpl.fromJson;

  @override
  String get avatarUrl;
  @override
  String get message;

  /// Create a copy of AvatarUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvatarUploadResponseImplCopyWith<_$AvatarUploadResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProfileCompletionStatus _$ProfileCompletionStatusFromJson(
  Map<String, dynamic> json,
) {
  return _ProfileCompletionStatus.fromJson(json);
}

/// @nodoc
mixin _$ProfileCompletionStatus {
  double get completionPercentage => throw _privateConstructorUsedError;
  List<String> get completedFields => throw _privateConstructorUsedError;
  List<String> get missingFields => throw _privateConstructorUsedError;
  List<String> get suggestions => throw _privateConstructorUsedError;

  /// Serializes this ProfileCompletionStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileCompletionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCompletionStatusCopyWith<ProfileCompletionStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCompletionStatusCopyWith<$Res> {
  factory $ProfileCompletionStatusCopyWith(
    ProfileCompletionStatus value,
    $Res Function(ProfileCompletionStatus) then,
  ) = _$ProfileCompletionStatusCopyWithImpl<$Res, ProfileCompletionStatus>;
  @useResult
  $Res call({
    double completionPercentage,
    List<String> completedFields,
    List<String> missingFields,
    List<String> suggestions,
  });
}

/// @nodoc
class _$ProfileCompletionStatusCopyWithImpl<
  $Res,
  $Val extends ProfileCompletionStatus
>
    implements $ProfileCompletionStatusCopyWith<$Res> {
  _$ProfileCompletionStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileCompletionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completionPercentage = null,
    Object? completedFields = null,
    Object? missingFields = null,
    Object? suggestions = null,
  }) {
    return _then(
      _value.copyWith(
            completionPercentage: null == completionPercentage
                ? _value.completionPercentage
                : completionPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            completedFields: null == completedFields
                ? _value.completedFields
                : completedFields // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            missingFields: null == missingFields
                ? _value.missingFields
                : missingFields // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            suggestions: null == suggestions
                ? _value.suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileCompletionStatusImplCopyWith<$Res>
    implements $ProfileCompletionStatusCopyWith<$Res> {
  factory _$$ProfileCompletionStatusImplCopyWith(
    _$ProfileCompletionStatusImpl value,
    $Res Function(_$ProfileCompletionStatusImpl) then,
  ) = __$$ProfileCompletionStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double completionPercentage,
    List<String> completedFields,
    List<String> missingFields,
    List<String> suggestions,
  });
}

/// @nodoc
class __$$ProfileCompletionStatusImplCopyWithImpl<$Res>
    extends
        _$ProfileCompletionStatusCopyWithImpl<
          $Res,
          _$ProfileCompletionStatusImpl
        >
    implements _$$ProfileCompletionStatusImplCopyWith<$Res> {
  __$$ProfileCompletionStatusImplCopyWithImpl(
    _$ProfileCompletionStatusImpl _value,
    $Res Function(_$ProfileCompletionStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileCompletionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completionPercentage = null,
    Object? completedFields = null,
    Object? missingFields = null,
    Object? suggestions = null,
  }) {
    return _then(
      _$ProfileCompletionStatusImpl(
        completionPercentage: null == completionPercentage
            ? _value.completionPercentage
            : completionPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        completedFields: null == completedFields
            ? _value._completedFields
            : completedFields // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        missingFields: null == missingFields
            ? _value._missingFields
            : missingFields // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        suggestions: null == suggestions
            ? _value._suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileCompletionStatusImpl implements _ProfileCompletionStatus {
  const _$ProfileCompletionStatusImpl({
    required this.completionPercentage,
    required final List<String> completedFields,
    required final List<String> missingFields,
    required final List<String> suggestions,
  }) : _completedFields = completedFields,
       _missingFields = missingFields,
       _suggestions = suggestions;

  factory _$ProfileCompletionStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileCompletionStatusImplFromJson(json);

  @override
  final double completionPercentage;
  final List<String> _completedFields;
  @override
  List<String> get completedFields {
    if (_completedFields is EqualUnmodifiableListView) return _completedFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedFields);
  }

  final List<String> _missingFields;
  @override
  List<String> get missingFields {
    if (_missingFields is EqualUnmodifiableListView) return _missingFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_missingFields);
  }

  final List<String> _suggestions;
  @override
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  String toString() {
    return 'ProfileCompletionStatus(completionPercentage: $completionPercentage, completedFields: $completedFields, missingFields: $missingFields, suggestions: $suggestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileCompletionStatusImpl &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage) &&
            const DeepCollectionEquality().equals(
              other._completedFields,
              _completedFields,
            ) &&
            const DeepCollectionEquality().equals(
              other._missingFields,
              _missingFields,
            ) &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    completionPercentage,
    const DeepCollectionEquality().hash(_completedFields),
    const DeepCollectionEquality().hash(_missingFields),
    const DeepCollectionEquality().hash(_suggestions),
  );

  /// Create a copy of ProfileCompletionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileCompletionStatusImplCopyWith<_$ProfileCompletionStatusImpl>
  get copyWith =>
      __$$ProfileCompletionStatusImplCopyWithImpl<
        _$ProfileCompletionStatusImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileCompletionStatusImplToJson(this);
  }
}

abstract class _ProfileCompletionStatus implements ProfileCompletionStatus {
  const factory _ProfileCompletionStatus({
    required final double completionPercentage,
    required final List<String> completedFields,
    required final List<String> missingFields,
    required final List<String> suggestions,
  }) = _$ProfileCompletionStatusImpl;

  factory _ProfileCompletionStatus.fromJson(Map<String, dynamic> json) =
      _$ProfileCompletionStatusImpl.fromJson;

  @override
  double get completionPercentage;
  @override
  List<String> get completedFields;
  @override
  List<String> get missingFields;
  @override
  List<String> get suggestions;

  /// Create a copy of ProfileCompletionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileCompletionStatusImplCopyWith<_$ProfileCompletionStatusImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) {
  return _PrivacySettings.fromJson(json);
}

/// @nodoc
mixin _$PrivacySettings {
  bool get profilePublic => throw _privateConstructorUsedError;
  bool get showEmail => throw _privateConstructorUsedError;
  bool get showPhone => throw _privateConstructorUsedError;
  bool get showName => throw _privateConstructorUsedError;
  bool get showLocation => throw _privateConstructorUsedError;
  bool get allowMessaging => throw _privateConstructorUsedError;
  bool get allowFriendRequests => throw _privateConstructorUsedError;

  /// Serializes this PrivacySettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrivacySettingsCopyWith<PrivacySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrivacySettingsCopyWith<$Res> {
  factory $PrivacySettingsCopyWith(
    PrivacySettings value,
    $Res Function(PrivacySettings) then,
  ) = _$PrivacySettingsCopyWithImpl<$Res, PrivacySettings>;
  @useResult
  $Res call({
    bool profilePublic,
    bool showEmail,
    bool showPhone,
    bool showName,
    bool showLocation,
    bool allowMessaging,
    bool allowFriendRequests,
  });
}

/// @nodoc
class _$PrivacySettingsCopyWithImpl<$Res, $Val extends PrivacySettings>
    implements $PrivacySettingsCopyWith<$Res> {
  _$PrivacySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profilePublic = null,
    Object? showEmail = null,
    Object? showPhone = null,
    Object? showName = null,
    Object? showLocation = null,
    Object? allowMessaging = null,
    Object? allowFriendRequests = null,
  }) {
    return _then(
      _value.copyWith(
            profilePublic: null == profilePublic
                ? _value.profilePublic
                : profilePublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            showEmail: null == showEmail
                ? _value.showEmail
                : showEmail // ignore: cast_nullable_to_non_nullable
                      as bool,
            showPhone: null == showPhone
                ? _value.showPhone
                : showPhone // ignore: cast_nullable_to_non_nullable
                      as bool,
            showName: null == showName
                ? _value.showName
                : showName // ignore: cast_nullable_to_non_nullable
                      as bool,
            showLocation: null == showLocation
                ? _value.showLocation
                : showLocation // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowMessaging: null == allowMessaging
                ? _value.allowMessaging
                : allowMessaging // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowFriendRequests: null == allowFriendRequests
                ? _value.allowFriendRequests
                : allowFriendRequests // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrivacySettingsImplCopyWith<$Res>
    implements $PrivacySettingsCopyWith<$Res> {
  factory _$$PrivacySettingsImplCopyWith(
    _$PrivacySettingsImpl value,
    $Res Function(_$PrivacySettingsImpl) then,
  ) = __$$PrivacySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool profilePublic,
    bool showEmail,
    bool showPhone,
    bool showName,
    bool showLocation,
    bool allowMessaging,
    bool allowFriendRequests,
  });
}

/// @nodoc
class __$$PrivacySettingsImplCopyWithImpl<$Res>
    extends _$PrivacySettingsCopyWithImpl<$Res, _$PrivacySettingsImpl>
    implements _$$PrivacySettingsImplCopyWith<$Res> {
  __$$PrivacySettingsImplCopyWithImpl(
    _$PrivacySettingsImpl _value,
    $Res Function(_$PrivacySettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profilePublic = null,
    Object? showEmail = null,
    Object? showPhone = null,
    Object? showName = null,
    Object? showLocation = null,
    Object? allowMessaging = null,
    Object? allowFriendRequests = null,
  }) {
    return _then(
      _$PrivacySettingsImpl(
        profilePublic: null == profilePublic
            ? _value.profilePublic
            : profilePublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        showEmail: null == showEmail
            ? _value.showEmail
            : showEmail // ignore: cast_nullable_to_non_nullable
                  as bool,
        showPhone: null == showPhone
            ? _value.showPhone
            : showPhone // ignore: cast_nullable_to_non_nullable
                  as bool,
        showName: null == showName
            ? _value.showName
            : showName // ignore: cast_nullable_to_non_nullable
                  as bool,
        showLocation: null == showLocation
            ? _value.showLocation
            : showLocation // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowMessaging: null == allowMessaging
            ? _value.allowMessaging
            : allowMessaging // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowFriendRequests: null == allowFriendRequests
            ? _value.allowFriendRequests
            : allowFriendRequests // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacySettingsImpl implements _PrivacySettings {
  const _$PrivacySettingsImpl({
    this.profilePublic = false,
    this.showEmail = false,
    this.showPhone = false,
    this.showName = true,
    this.showLocation = false,
    this.allowMessaging = true,
    this.allowFriendRequests = true,
  });

  factory _$PrivacySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacySettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool profilePublic;
  @override
  @JsonKey()
  final bool showEmail;
  @override
  @JsonKey()
  final bool showPhone;
  @override
  @JsonKey()
  final bool showName;
  @override
  @JsonKey()
  final bool showLocation;
  @override
  @JsonKey()
  final bool allowMessaging;
  @override
  @JsonKey()
  final bool allowFriendRequests;

  @override
  String toString() {
    return 'PrivacySettings(profilePublic: $profilePublic, showEmail: $showEmail, showPhone: $showPhone, showName: $showName, showLocation: $showLocation, allowMessaging: $allowMessaging, allowFriendRequests: $allowFriendRequests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacySettingsImpl &&
            (identical(other.profilePublic, profilePublic) ||
                other.profilePublic == profilePublic) &&
            (identical(other.showEmail, showEmail) ||
                other.showEmail == showEmail) &&
            (identical(other.showPhone, showPhone) ||
                other.showPhone == showPhone) &&
            (identical(other.showName, showName) ||
                other.showName == showName) &&
            (identical(other.showLocation, showLocation) ||
                other.showLocation == showLocation) &&
            (identical(other.allowMessaging, allowMessaging) ||
                other.allowMessaging == allowMessaging) &&
            (identical(other.allowFriendRequests, allowFriendRequests) ||
                other.allowFriendRequests == allowFriendRequests));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    profilePublic,
    showEmail,
    showPhone,
    showName,
    showLocation,
    allowMessaging,
    allowFriendRequests,
  );

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      __$$PrivacySettingsImplCopyWithImpl<_$PrivacySettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PrivacySettingsImplToJson(this);
  }
}

abstract class _PrivacySettings implements PrivacySettings {
  const factory _PrivacySettings({
    final bool profilePublic,
    final bool showEmail,
    final bool showPhone,
    final bool showName,
    final bool showLocation,
    final bool allowMessaging,
    final bool allowFriendRequests,
  }) = _$PrivacySettingsImpl;

  factory _PrivacySettings.fromJson(Map<String, dynamic> json) =
      _$PrivacySettingsImpl.fromJson;

  @override
  bool get profilePublic;
  @override
  bool get showEmail;
  @override
  bool get showPhone;
  @override
  bool get showName;
  @override
  bool get showLocation;
  @override
  bool get allowMessaging;
  @override
  bool get allowFriendRequests;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccountSettings _$AccountSettingsFromJson(Map<String, dynamic> json) {
  return _AccountSettings.fromJson(json);
}

/// @nodoc
mixin _$AccountSettings {
  String get language => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  String get dateFormat => throw _privateConstructorUsedError;
  String get timeFormat => throw _privateConstructorUsedError;
  bool get use24HourTime => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get locale => throw _privateConstructorUsedError;

  /// Serializes this AccountSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AccountSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountSettingsCopyWith<AccountSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountSettingsCopyWith<$Res> {
  factory $AccountSettingsCopyWith(
    AccountSettings value,
    $Res Function(AccountSettings) then,
  ) = _$AccountSettingsCopyWithImpl<$Res, AccountSettings>;
  @useResult
  $Res call({
    String language,
    String timezone,
    String dateFormat,
    String timeFormat,
    bool use24HourTime,
    String currency,
    String locale,
  });
}

/// @nodoc
class _$AccountSettingsCopyWithImpl<$Res, $Val extends AccountSettings>
    implements $AccountSettingsCopyWith<$Res> {
  _$AccountSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? timezone = null,
    Object? dateFormat = null,
    Object? timeFormat = null,
    Object? use24HourTime = null,
    Object? currency = null,
    Object? locale = null,
  }) {
    return _then(
      _value.copyWith(
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String,
            dateFormat: null == dateFormat
                ? _value.dateFormat
                : dateFormat // ignore: cast_nullable_to_non_nullable
                      as String,
            timeFormat: null == timeFormat
                ? _value.timeFormat
                : timeFormat // ignore: cast_nullable_to_non_nullable
                      as String,
            use24HourTime: null == use24HourTime
                ? _value.use24HourTime
                : use24HourTime // ignore: cast_nullable_to_non_nullable
                      as bool,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            locale: null == locale
                ? _value.locale
                : locale // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AccountSettingsImplCopyWith<$Res>
    implements $AccountSettingsCopyWith<$Res> {
  factory _$$AccountSettingsImplCopyWith(
    _$AccountSettingsImpl value,
    $Res Function(_$AccountSettingsImpl) then,
  ) = __$$AccountSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String language,
    String timezone,
    String dateFormat,
    String timeFormat,
    bool use24HourTime,
    String currency,
    String locale,
  });
}

/// @nodoc
class __$$AccountSettingsImplCopyWithImpl<$Res>
    extends _$AccountSettingsCopyWithImpl<$Res, _$AccountSettingsImpl>
    implements _$$AccountSettingsImplCopyWith<$Res> {
  __$$AccountSettingsImplCopyWithImpl(
    _$AccountSettingsImpl _value,
    $Res Function(_$AccountSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AccountSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? timezone = null,
    Object? dateFormat = null,
    Object? timeFormat = null,
    Object? use24HourTime = null,
    Object? currency = null,
    Object? locale = null,
  }) {
    return _then(
      _$AccountSettingsImpl(
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String,
        dateFormat: null == dateFormat
            ? _value.dateFormat
            : dateFormat // ignore: cast_nullable_to_non_nullable
                  as String,
        timeFormat: null == timeFormat
            ? _value.timeFormat
            : timeFormat // ignore: cast_nullable_to_non_nullable
                  as String,
        use24HourTime: null == use24HourTime
            ? _value.use24HourTime
            : use24HourTime // ignore: cast_nullable_to_non_nullable
                  as bool,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        locale: null == locale
            ? _value.locale
            : locale // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountSettingsImpl implements _AccountSettings {
  const _$AccountSettingsImpl({
    required this.language,
    required this.timezone,
    required this.dateFormat,
    required this.timeFormat,
    this.use24HourTime = true,
    this.currency = 'USD',
    this.locale = 'en_US',
  });

  factory _$AccountSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountSettingsImplFromJson(json);

  @override
  final String language;
  @override
  final String timezone;
  @override
  final String dateFormat;
  @override
  final String timeFormat;
  @override
  @JsonKey()
  final bool use24HourTime;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final String locale;

  @override
  String toString() {
    return 'AccountSettings(language: $language, timezone: $timezone, dateFormat: $dateFormat, timeFormat: $timeFormat, use24HourTime: $use24HourTime, currency: $currency, locale: $locale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountSettingsImpl &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.dateFormat, dateFormat) ||
                other.dateFormat == dateFormat) &&
            (identical(other.timeFormat, timeFormat) ||
                other.timeFormat == timeFormat) &&
            (identical(other.use24HourTime, use24HourTime) ||
                other.use24HourTime == use24HourTime) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    language,
    timezone,
    dateFormat,
    timeFormat,
    use24HourTime,
    currency,
    locale,
  );

  /// Create a copy of AccountSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountSettingsImplCopyWith<_$AccountSettingsImpl> get copyWith =>
      __$$AccountSettingsImplCopyWithImpl<_$AccountSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountSettingsImplToJson(this);
  }
}

abstract class _AccountSettings implements AccountSettings {
  const factory _AccountSettings({
    required final String language,
    required final String timezone,
    required final String dateFormat,
    required final String timeFormat,
    final bool use24HourTime,
    final String currency,
    final String locale,
  }) = _$AccountSettingsImpl;

  factory _AccountSettings.fromJson(Map<String, dynamic> json) =
      _$AccountSettingsImpl.fromJson;

  @override
  String get language;
  @override
  String get timezone;
  @override
  String get dateFormat;
  @override
  String get timeFormat;
  @override
  bool get use24HourTime;
  @override
  String get currency;
  @override
  String get locale;

  /// Create a copy of AccountSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountSettingsImplCopyWith<_$AccountSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileStatistics _$ProfileStatisticsFromJson(Map<String, dynamic> json) {
  return _ProfileStatistics.fromJson(json);
}

/// @nodoc
mixin _$ProfileStatistics {
  int get loginCount => throw _privateConstructorUsedError;
  int get sessionCount => throw _privateConstructorUsedError;
  String get accountAge => throw _privateConstructorUsedError;
  String get lastPasswordChange => throw _privateConstructorUsedError;
  int get securityScore => throw _privateConstructorUsedError;
  Map<String, int> get activityBreakdown => throw _privateConstructorUsedError;

  /// Serializes this ProfileStatistics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStatisticsCopyWith<ProfileStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStatisticsCopyWith<$Res> {
  factory $ProfileStatisticsCopyWith(
    ProfileStatistics value,
    $Res Function(ProfileStatistics) then,
  ) = _$ProfileStatisticsCopyWithImpl<$Res, ProfileStatistics>;
  @useResult
  $Res call({
    int loginCount,
    int sessionCount,
    String accountAge,
    String lastPasswordChange,
    int securityScore,
    Map<String, int> activityBreakdown,
  });
}

/// @nodoc
class _$ProfileStatisticsCopyWithImpl<$Res, $Val extends ProfileStatistics>
    implements $ProfileStatisticsCopyWith<$Res> {
  _$ProfileStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginCount = null,
    Object? sessionCount = null,
    Object? accountAge = null,
    Object? lastPasswordChange = null,
    Object? securityScore = null,
    Object? activityBreakdown = null,
  }) {
    return _then(
      _value.copyWith(
            loginCount: null == loginCount
                ? _value.loginCount
                : loginCount // ignore: cast_nullable_to_non_nullable
                      as int,
            sessionCount: null == sessionCount
                ? _value.sessionCount
                : sessionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            accountAge: null == accountAge
                ? _value.accountAge
                : accountAge // ignore: cast_nullable_to_non_nullable
                      as String,
            lastPasswordChange: null == lastPasswordChange
                ? _value.lastPasswordChange
                : lastPasswordChange // ignore: cast_nullable_to_non_nullable
                      as String,
            securityScore: null == securityScore
                ? _value.securityScore
                : securityScore // ignore: cast_nullable_to_non_nullable
                      as int,
            activityBreakdown: null == activityBreakdown
                ? _value.activityBreakdown
                : activityBreakdown // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileStatisticsImplCopyWith<$Res>
    implements $ProfileStatisticsCopyWith<$Res> {
  factory _$$ProfileStatisticsImplCopyWith(
    _$ProfileStatisticsImpl value,
    $Res Function(_$ProfileStatisticsImpl) then,
  ) = __$$ProfileStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int loginCount,
    int sessionCount,
    String accountAge,
    String lastPasswordChange,
    int securityScore,
    Map<String, int> activityBreakdown,
  });
}

/// @nodoc
class __$$ProfileStatisticsImplCopyWithImpl<$Res>
    extends _$ProfileStatisticsCopyWithImpl<$Res, _$ProfileStatisticsImpl>
    implements _$$ProfileStatisticsImplCopyWith<$Res> {
  __$$ProfileStatisticsImplCopyWithImpl(
    _$ProfileStatisticsImpl _value,
    $Res Function(_$ProfileStatisticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginCount = null,
    Object? sessionCount = null,
    Object? accountAge = null,
    Object? lastPasswordChange = null,
    Object? securityScore = null,
    Object? activityBreakdown = null,
  }) {
    return _then(
      _$ProfileStatisticsImpl(
        loginCount: null == loginCount
            ? _value.loginCount
            : loginCount // ignore: cast_nullable_to_non_nullable
                  as int,
        sessionCount: null == sessionCount
            ? _value.sessionCount
            : sessionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        accountAge: null == accountAge
            ? _value.accountAge
            : accountAge // ignore: cast_nullable_to_non_nullable
                  as String,
        lastPasswordChange: null == lastPasswordChange
            ? _value.lastPasswordChange
            : lastPasswordChange // ignore: cast_nullable_to_non_nullable
                  as String,
        securityScore: null == securityScore
            ? _value.securityScore
            : securityScore // ignore: cast_nullable_to_non_nullable
                  as int,
        activityBreakdown: null == activityBreakdown
            ? _value._activityBreakdown
            : activityBreakdown // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileStatisticsImpl implements _ProfileStatistics {
  const _$ProfileStatisticsImpl({
    required this.loginCount,
    required this.sessionCount,
    required this.accountAge,
    required this.lastPasswordChange,
    required this.securityScore,
    required final Map<String, int> activityBreakdown,
  }) : _activityBreakdown = activityBreakdown;

  factory _$ProfileStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileStatisticsImplFromJson(json);

  @override
  final int loginCount;
  @override
  final int sessionCount;
  @override
  final String accountAge;
  @override
  final String lastPasswordChange;
  @override
  final int securityScore;
  final Map<String, int> _activityBreakdown;
  @override
  Map<String, int> get activityBreakdown {
    if (_activityBreakdown is EqualUnmodifiableMapView)
      return _activityBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_activityBreakdown);
  }

  @override
  String toString() {
    return 'ProfileStatistics(loginCount: $loginCount, sessionCount: $sessionCount, accountAge: $accountAge, lastPasswordChange: $lastPasswordChange, securityScore: $securityScore, activityBreakdown: $activityBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStatisticsImpl &&
            (identical(other.loginCount, loginCount) ||
                other.loginCount == loginCount) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            (identical(other.accountAge, accountAge) ||
                other.accountAge == accountAge) &&
            (identical(other.lastPasswordChange, lastPasswordChange) ||
                other.lastPasswordChange == lastPasswordChange) &&
            (identical(other.securityScore, securityScore) ||
                other.securityScore == securityScore) &&
            const DeepCollectionEquality().equals(
              other._activityBreakdown,
              _activityBreakdown,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    loginCount,
    sessionCount,
    accountAge,
    lastPasswordChange,
    securityScore,
    const DeepCollectionEquality().hash(_activityBreakdown),
  );

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStatisticsImplCopyWith<_$ProfileStatisticsImpl> get copyWith =>
      __$$ProfileStatisticsImplCopyWithImpl<_$ProfileStatisticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileStatisticsImplToJson(this);
  }
}

abstract class _ProfileStatistics implements ProfileStatistics {
  const factory _ProfileStatistics({
    required final int loginCount,
    required final int sessionCount,
    required final String accountAge,
    required final String lastPasswordChange,
    required final int securityScore,
    required final Map<String, int> activityBreakdown,
  }) = _$ProfileStatisticsImpl;

  factory _ProfileStatistics.fromJson(Map<String, dynamic> json) =
      _$ProfileStatisticsImpl.fromJson;

  @override
  int get loginCount;
  @override
  int get sessionCount;
  @override
  String get accountAge;
  @override
  String get lastPasswordChange;
  @override
  int get securityScore;
  @override
  Map<String, int> get activityBreakdown;

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStatisticsImplCopyWith<_$ProfileStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
