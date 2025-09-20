// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  /// Unique identifier for the user.
  /// Format: UUID v4 (e.g., '123e4567-e89b-12d3-a456-426614174000')
  String get id => throw _privateConstructorUsedError;

  /// User's email address.
  /// Must be unique across the system and in valid email format.
  String get email => throw _privateConstructorUsedError;

  /// Display name for the user.
  /// This is what's shown in the UI (e.g., "John Doe").
  String get name => throw _privateConstructorUsedError;

  /// User's first name.
  /// Optional, used for personalization.
  String? get firstName => throw _privateConstructorUsedError;

  /// User's last name.
  /// Optional, used for personalization.
  String? get lastName => throw _privateConstructorUsedError;

  /// Contact phone number.
  /// Format varies by region, validation should be done at input.
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// User biography or description.
  /// Limited to 500 characters in most implementations.
  String? get bio => throw _privateConstructorUsedError;

  /// @deprecated Use [profileImageUrl] instead.
  /// Local path to profile picture.
  String? get profilePicture => throw _privateConstructorUsedError;

  /// URL to user's profile image.
  /// Should be a secure HTTPS URL pointing to CDN or storage service.
  String? get profileImageUrl => throw _privateConstructorUsedError;

  /// Whether the user's email address has been verified.
  /// Required for certain operations like password reset.
  bool get isEmailVerified => throw _privateConstructorUsedError;

  /// Whether the user account is active.
  /// Inactive accounts cannot login.
  bool? get isActive => throw _privateConstructorUsedError;

  /// Whether two-factor authentication is enabled.
  /// When true, requires additional verification on login.
  bool get isTwoFactorEnabled => throw _privateConstructorUsedError;

  /// List of roles assigned to the user.
  /// Examples: ['user', 'admin', 'moderator']
  /// Used for role-based access control (RBAC).
  List<String> get roles => throw _privateConstructorUsedError;

  /// Single role for backward compatibility.
  /// @deprecated Use roles list instead
  String? get role => throw _privateConstructorUsedError;

  /// List of specific permissions granted to the user.
  /// Examples: ['posts:read', 'posts:write', 'users:delete']
  /// Used for fine-grained access control.
  List<String> get permissions => throw _privateConstructorUsedError;

  /// Timestamp when the user account was created.
  /// Immutable once set.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp of the last profile update.
  /// Updated whenever user information changes.
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Timestamp of the last successful login.
  /// Used for security monitoring and user activity tracking.
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String email,
    String name,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    String? profilePicture,
    String? profileImageUrl,
    bool isEmailVerified,
    bool? isActive,
    bool isTwoFactorEnabled,
    List<String> roles,
    String? role,
    List<String> permissions,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastLoginAt,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? bio = freezed,
    Object? profilePicture = freezed,
    Object? profileImageUrl = freezed,
    Object? isEmailVerified = null,
    Object? isActive = freezed,
    Object? isTwoFactorEnabled = null,
    Object? roles = null,
    Object? role = freezed,
    Object? permissions = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLoginAt = freezed,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
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
            profilePicture: freezed == profilePicture
                ? _value.profilePicture
                : profilePicture // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isEmailVerified: null == isEmailVerified
                ? _value.isEmailVerified
                : isEmailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isTwoFactorEnabled: null == isTwoFactorEnabled
                ? _value.isTwoFactorEnabled
                : isTwoFactorEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            permissions: null == permissions
                ? _value.permissions
                : permissions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastLoginAt: freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String name,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    String? profilePicture,
    String? profileImageUrl,
    bool isEmailVerified,
    bool? isActive,
    bool isTwoFactorEnabled,
    List<String> roles,
    String? role,
    List<String> permissions,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastLoginAt,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? bio = freezed,
    Object? profilePicture = freezed,
    Object? profileImageUrl = freezed,
    Object? isEmailVerified = null,
    Object? isActive = freezed,
    Object? isTwoFactorEnabled = null,
    Object? roles = null,
    Object? role = freezed,
    Object? permissions = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLoginAt = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
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
        profilePicture: freezed == profilePicture
            ? _value.profilePicture
            : profilePicture // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isEmailVerified: null == isEmailVerified
            ? _value.isEmailVerified
            : isEmailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isTwoFactorEnabled: null == isTwoFactorEnabled
            ? _value.isTwoFactorEnabled
            : isTwoFactorEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        permissions: null == permissions
            ? _value._permissions
            : permissions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastLoginAt: freezed == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    required this.id,
    required this.email,
    required this.name,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.bio,
    this.profilePicture,
    this.profileImageUrl,
    required this.isEmailVerified,
    this.isActive = true,
    required this.isTwoFactorEnabled,
    required final List<String> roles,
    this.role,
    required final List<String> permissions,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  }) : _roles = roles,
       _permissions = permissions;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  /// Unique identifier for the user.
  /// Format: UUID v4 (e.g., '123e4567-e89b-12d3-a456-426614174000')
  @override
  final String id;

  /// User's email address.
  /// Must be unique across the system and in valid email format.
  @override
  final String email;

  /// Display name for the user.
  /// This is what's shown in the UI (e.g., "John Doe").
  @override
  final String name;

  /// User's first name.
  /// Optional, used for personalization.
  @override
  final String? firstName;

  /// User's last name.
  /// Optional, used for personalization.
  @override
  final String? lastName;

  /// Contact phone number.
  /// Format varies by region, validation should be done at input.
  @override
  final String? phoneNumber;

  /// User biography or description.
  /// Limited to 500 characters in most implementations.
  @override
  final String? bio;

  /// @deprecated Use [profileImageUrl] instead.
  /// Local path to profile picture.
  @override
  final String? profilePicture;

  /// URL to user's profile image.
  /// Should be a secure HTTPS URL pointing to CDN or storage service.
  @override
  final String? profileImageUrl;

  /// Whether the user's email address has been verified.
  /// Required for certain operations like password reset.
  @override
  final bool isEmailVerified;

  /// Whether the user account is active.
  /// Inactive accounts cannot login.
  @override
  @JsonKey()
  final bool? isActive;

  /// Whether two-factor authentication is enabled.
  /// When true, requires additional verification on login.
  @override
  final bool isTwoFactorEnabled;

  /// List of roles assigned to the user.
  /// Examples: ['user', 'admin', 'moderator']
  /// Used for role-based access control (RBAC).
  final List<String> _roles;

  /// List of roles assigned to the user.
  /// Examples: ['user', 'admin', 'moderator']
  /// Used for role-based access control (RBAC).
  @override
  List<String> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  /// Single role for backward compatibility.
  /// @deprecated Use roles list instead
  @override
  final String? role;

  /// List of specific permissions granted to the user.
  /// Examples: ['posts:read', 'posts:write', 'users:delete']
  /// Used for fine-grained access control.
  final List<String> _permissions;

  /// List of specific permissions granted to the user.
  /// Examples: ['posts:read', 'posts:write', 'users:delete']
  /// Used for fine-grained access control.
  @override
  List<String> get permissions {
    if (_permissions is EqualUnmodifiableListView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_permissions);
  }

  /// Timestamp when the user account was created.
  /// Immutable once set.
  @override
  final DateTime createdAt;

  /// Timestamp of the last profile update.
  /// Updated whenever user information changes.
  @override
  final DateTime updatedAt;

  /// Timestamp of the last successful login.
  /// Used for security monitoring and user activity tracking.
  @override
  final DateTime? lastLoginAt;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, bio: $bio, profilePicture: $profilePicture, profileImageUrl: $profileImageUrl, isEmailVerified: $isEmailVerified, isActive: $isActive, isTwoFactorEnabled: $isTwoFactorEnabled, roles: $roles, role: $role, permissions: $permissions, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isTwoFactorEnabled, isTwoFactorEnabled) ||
                other.isTwoFactorEnabled == isTwoFactorEnabled) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            (identical(other.role, role) || other.role == role) &&
            const DeepCollectionEquality().equals(
              other._permissions,
              _permissions,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    name,
    firstName,
    lastName,
    phoneNumber,
    bio,
    profilePicture,
    profileImageUrl,
    isEmailVerified,
    isActive,
    isTwoFactorEnabled,
    const DeepCollectionEquality().hash(_roles),
    role,
    const DeepCollectionEquality().hash(_permissions),
    createdAt,
    updatedAt,
    lastLoginAt,
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    required final String id,
    required final String email,
    required final String name,
    final String? firstName,
    final String? lastName,
    final String? phoneNumber,
    final String? bio,
    final String? profilePicture,
    final String? profileImageUrl,
    required final bool isEmailVerified,
    final bool? isActive,
    required final bool isTwoFactorEnabled,
    required final List<String> roles,
    final String? role,
    required final List<String> permissions,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? lastLoginAt,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  /// Unique identifier for the user.
  /// Format: UUID v4 (e.g., '123e4567-e89b-12d3-a456-426614174000')
  @override
  String get id;

  /// User's email address.
  /// Must be unique across the system and in valid email format.
  @override
  String get email;

  /// Display name for the user.
  /// This is what's shown in the UI (e.g., "John Doe").
  @override
  String get name;

  /// User's first name.
  /// Optional, used for personalization.
  @override
  String? get firstName;

  /// User's last name.
  /// Optional, used for personalization.
  @override
  String? get lastName;

  /// Contact phone number.
  /// Format varies by region, validation should be done at input.
  @override
  String? get phoneNumber;

  /// User biography or description.
  /// Limited to 500 characters in most implementations.
  @override
  String? get bio;

  /// @deprecated Use [profileImageUrl] instead.
  /// Local path to profile picture.
  @override
  String? get profilePicture;

  /// URL to user's profile image.
  /// Should be a secure HTTPS URL pointing to CDN or storage service.
  @override
  String? get profileImageUrl;

  /// Whether the user's email address has been verified.
  /// Required for certain operations like password reset.
  @override
  bool get isEmailVerified;

  /// Whether the user account is active.
  /// Inactive accounts cannot login.
  @override
  bool? get isActive;

  /// Whether two-factor authentication is enabled.
  /// When true, requires additional verification on login.
  @override
  bool get isTwoFactorEnabled;

  /// List of roles assigned to the user.
  /// Examples: ['user', 'admin', 'moderator']
  /// Used for role-based access control (RBAC).
  @override
  List<String> get roles;

  /// Single role for backward compatibility.
  /// @deprecated Use roles list instead
  @override
  String? get role;

  /// List of specific permissions granted to the user.
  /// Examples: ['posts:read', 'posts:write', 'users:delete']
  /// Used for fine-grained access control.
  @override
  List<String> get permissions;

  /// Timestamp when the user account was created.
  /// Immutable once set.
  @override
  DateTime get createdAt;

  /// Timestamp of the last profile update.
  /// Updated whenever user information changes.
  @override
  DateTime get updatedAt;

  /// Timestamp of the last successful login.
  /// Used for security monitoring and user activity tracking.
  @override
  DateTime? get lastLoginAt;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
