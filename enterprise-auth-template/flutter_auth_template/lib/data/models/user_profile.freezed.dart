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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  bool get emailVerified => throw _privateConstructorUsedError;
  bool get phoneVerified => throw _privateConstructorUsedError;
  bool get twoFactorEnabled => throw _privateConstructorUsedError;
  List<String> get roles => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  ProfileSettings? get settings => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    String id,
    String email,
    String? name,
    String? avatarUrl,
    String? phone,
    String? bio,
    bool emailVerified,
    bool phoneVerified,
    bool twoFactorEnabled,
    List<String> roles,
    Map<String, dynamic> metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    ProfileSettings? settings,
  });

  $ProfileSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = freezed,
    Object? avatarUrl = freezed,
    Object? phone = freezed,
    Object? bio = freezed,
    Object? emailVerified = null,
    Object? phoneVerified = null,
    Object? twoFactorEnabled = null,
    Object? roles = null,
    Object? metadata = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastLoginAt = freezed,
    Object? settings = freezed,
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
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailVerified: null == emailVerified
                ? _value.emailVerified
                : emailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            phoneVerified: null == phoneVerified
                ? _value.phoneVerified
                : phoneVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            twoFactorEnabled: null == twoFactorEnabled
                ? _value.twoFactorEnabled
                : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastLoginAt: freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as ProfileSettings?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileSettingsCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $ProfileSettingsCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? name,
    String? avatarUrl,
    String? phone,
    String? bio,
    bool emailVerified,
    bool phoneVerified,
    bool twoFactorEnabled,
    List<String> roles,
    Map<String, dynamic> metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    ProfileSettings? settings,
  });

  @override
  $ProfileSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = freezed,
    Object? avatarUrl = freezed,
    Object? phone = freezed,
    Object? bio = freezed,
    Object? emailVerified = null,
    Object? phoneVerified = null,
    Object? twoFactorEnabled = null,
    Object? roles = null,
    Object? metadata = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastLoginAt = freezed,
    Object? settings = freezed,
  }) {
    return _then(
      _$UserProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailVerified: null == emailVerified
            ? _value.emailVerified
            : emailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        phoneVerified: null == phoneVerified
            ? _value.phoneVerified
            : phoneVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        twoFactorEnabled: null == twoFactorEnabled
            ? _value.twoFactorEnabled
            : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastLoginAt: freezed == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        settings: freezed == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as ProfileSettings?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl extends _UserProfile {
  const _$UserProfileImpl({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.twoFactorEnabled = false,
    final List<String> roles = const [],
    final Map<String, dynamic> metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.settings,
  }) : _roles = roles,
       _metadata = metadata,
       super._();

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? name;
  @override
  final String? avatarUrl;
  @override
  final String? phone;
  @override
  final String? bio;
  @override
  @JsonKey()
  final bool emailVerified;
  @override
  @JsonKey()
  final bool phoneVerified;
  @override
  @JsonKey()
  final bool twoFactorEnabled;
  final List<String> _roles;
  @override
  @JsonKey()
  List<String> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? lastLoginAt;
  @override
  final ProfileSettings? settings;

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, name: $name, avatarUrl: $avatarUrl, phone: $phone, bio: $bio, emailVerified: $emailVerified, phoneVerified: $phoneVerified, twoFactorEnabled: $twoFactorEnabled, roles: $roles, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified) &&
            (identical(other.phoneVerified, phoneVerified) ||
                other.phoneVerified == phoneVerified) &&
            (identical(other.twoFactorEnabled, twoFactorEnabled) ||
                other.twoFactorEnabled == twoFactorEnabled) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.settings, settings) ||
                other.settings == settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    name,
    avatarUrl,
    phone,
    bio,
    emailVerified,
    phoneVerified,
    twoFactorEnabled,
    const DeepCollectionEquality().hash(_roles),
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
    updatedAt,
    lastLoginAt,
    settings,
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(this);
  }
}

abstract class _UserProfile extends UserProfile {
  const factory _UserProfile({
    required final String id,
    required final String email,
    final String? name,
    final String? avatarUrl,
    final String? phone,
    final String? bio,
    final bool emailVerified,
    final bool phoneVerified,
    final bool twoFactorEnabled,
    final List<String> roles,
    final Map<String, dynamic> metadata,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final DateTime? lastLoginAt,
    final ProfileSettings? settings,
  }) = _$UserProfileImpl;
  const _UserProfile._() : super._();

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get name;
  @override
  String? get avatarUrl;
  @override
  String? get phone;
  @override
  String? get bio;
  @override
  bool get emailVerified;
  @override
  bool get phoneVerified;
  @override
  bool get twoFactorEnabled;
  @override
  List<String> get roles;
  @override
  Map<String, dynamic> get metadata;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get lastLoginAt;
  @override
  ProfileSettings? get settings;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileSettings _$ProfileSettingsFromJson(Map<String, dynamic> json) {
  return _ProfileSettings.fromJson(json);
}

/// @nodoc
mixin _$ProfileSettings {
  bool get emailNotifications => throw _privateConstructorUsedError;
  bool get pushNotifications => throw _privateConstructorUsedError;
  bool get smsNotifications => throw _privateConstructorUsedError;
  bool get marketingEmails => throw _privateConstructorUsedError;
  bool get securityAlerts => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  Map<String, dynamic> get preferences => throw _privateConstructorUsedError;

  /// Serializes this ProfileSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileSettingsCopyWith<ProfileSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileSettingsCopyWith<$Res> {
  factory $ProfileSettingsCopyWith(
    ProfileSettings value,
    $Res Function(ProfileSettings) then,
  ) = _$ProfileSettingsCopyWithImpl<$Res, ProfileSettings>;
  @useResult
  $Res call({
    bool emailNotifications,
    bool pushNotifications,
    bool smsNotifications,
    bool marketingEmails,
    bool securityAlerts,
    String language,
    String timezone,
    String theme,
    Map<String, dynamic> preferences,
  });
}

/// @nodoc
class _$ProfileSettingsCopyWithImpl<$Res, $Val extends ProfileSettings>
    implements $ProfileSettingsCopyWith<$Res> {
  _$ProfileSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailNotifications = null,
    Object? pushNotifications = null,
    Object? smsNotifications = null,
    Object? marketingEmails = null,
    Object? securityAlerts = null,
    Object? language = null,
    Object? timezone = null,
    Object? theme = null,
    Object? preferences = null,
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
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String,
            theme: null == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as String,
            preferences: null == preferences
                ? _value.preferences
                : preferences // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileSettingsImplCopyWith<$Res>
    implements $ProfileSettingsCopyWith<$Res> {
  factory _$$ProfileSettingsImplCopyWith(
    _$ProfileSettingsImpl value,
    $Res Function(_$ProfileSettingsImpl) then,
  ) = __$$ProfileSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool emailNotifications,
    bool pushNotifications,
    bool smsNotifications,
    bool marketingEmails,
    bool securityAlerts,
    String language,
    String timezone,
    String theme,
    Map<String, dynamic> preferences,
  });
}

/// @nodoc
class __$$ProfileSettingsImplCopyWithImpl<$Res>
    extends _$ProfileSettingsCopyWithImpl<$Res, _$ProfileSettingsImpl>
    implements _$$ProfileSettingsImplCopyWith<$Res> {
  __$$ProfileSettingsImplCopyWithImpl(
    _$ProfileSettingsImpl _value,
    $Res Function(_$ProfileSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailNotifications = null,
    Object? pushNotifications = null,
    Object? smsNotifications = null,
    Object? marketingEmails = null,
    Object? securityAlerts = null,
    Object? language = null,
    Object? timezone = null,
    Object? theme = null,
    Object? preferences = null,
  }) {
    return _then(
      _$ProfileSettingsImpl(
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
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String,
        theme: null == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as String,
        preferences: null == preferences
            ? _value._preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileSettingsImpl implements _ProfileSettings {
  const _$ProfileSettingsImpl({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.marketingEmails = true,
    this.securityAlerts = true,
    this.language = 'en',
    this.timezone = 'UTC',
    this.theme = 'light',
    final Map<String, dynamic> preferences = const {},
  }) : _preferences = preferences;

  factory _$ProfileSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileSettingsImplFromJson(json);

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
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final String timezone;
  @override
  @JsonKey()
  final String theme;
  final Map<String, dynamic> _preferences;
  @override
  @JsonKey()
  Map<String, dynamic> get preferences {
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_preferences);
  }

  @override
  String toString() {
    return 'ProfileSettings(emailNotifications: $emailNotifications, pushNotifications: $pushNotifications, smsNotifications: $smsNotifications, marketingEmails: $marketingEmails, securityAlerts: $securityAlerts, language: $language, timezone: $timezone, theme: $theme, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileSettingsImpl &&
            (identical(other.emailNotifications, emailNotifications) ||
                other.emailNotifications == emailNotifications) &&
            (identical(other.pushNotifications, pushNotifications) ||
                other.pushNotifications == pushNotifications) &&
            (identical(other.smsNotifications, smsNotifications) ||
                other.smsNotifications == smsNotifications) &&
            (identical(other.marketingEmails, marketingEmails) ||
                other.marketingEmails == marketingEmails) &&
            (identical(other.securityAlerts, securityAlerts) ||
                other.securityAlerts == securityAlerts) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            const DeepCollectionEquality().equals(
              other._preferences,
              _preferences,
            ));
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
    language,
    timezone,
    theme,
    const DeepCollectionEquality().hash(_preferences),
  );

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileSettingsImplCopyWith<_$ProfileSettingsImpl> get copyWith =>
      __$$ProfileSettingsImplCopyWithImpl<_$ProfileSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileSettingsImplToJson(this);
  }
}

abstract class _ProfileSettings implements ProfileSettings {
  const factory _ProfileSettings({
    final bool emailNotifications,
    final bool pushNotifications,
    final bool smsNotifications,
    final bool marketingEmails,
    final bool securityAlerts,
    final String language,
    final String timezone,
    final String theme,
    final Map<String, dynamic> preferences,
  }) = _$ProfileSettingsImpl;

  factory _ProfileSettings.fromJson(Map<String, dynamic> json) =
      _$ProfileSettingsImpl.fromJson;

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
  @override
  String get language;
  @override
  String get timezone;
  @override
  String get theme;
  @override
  Map<String, dynamic> get preferences;

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileSettingsImplCopyWith<_$ProfileSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileUpdateRequest _$ProfileUpdateRequestFromJson(Map<String, dynamic> json) {
  return _ProfileUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ProfileUpdateRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  ProfileSettings? get settings => throw _privateConstructorUsedError;

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
    String? name,
    String? phone,
    String? bio,
    Map<String, dynamic>? metadata,
    ProfileSettings? settings,
  });

  $ProfileSettingsCopyWith<$Res>? get settings;
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
    Object? name = freezed,
    Object? phone = freezed,
    Object? bio = freezed,
    Object? metadata = freezed,
    Object? settings = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as ProfileSettings?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProfileUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileSettingsCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $ProfileSettingsCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
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
    String? name,
    String? phone,
    String? bio,
    Map<String, dynamic>? metadata,
    ProfileSettings? settings,
  });

  @override
  $ProfileSettingsCopyWith<$Res>? get settings;
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
    Object? name = freezed,
    Object? phone = freezed,
    Object? bio = freezed,
    Object? metadata = freezed,
    Object? settings = freezed,
  }) {
    return _then(
      _$ProfileUpdateRequestImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        settings: freezed == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as ProfileSettings?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileUpdateRequestImpl implements _ProfileUpdateRequest {
  const _$ProfileUpdateRequestImpl({
    this.name,
    this.phone,
    this.bio,
    final Map<String, dynamic>? metadata,
    this.settings,
  }) : _metadata = metadata;

  factory _$ProfileUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileUpdateRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? phone;
  @override
  final String? bio;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final ProfileSettings? settings;

  @override
  String toString() {
    return 'ProfileUpdateRequest(name: $name, phone: $phone, bio: $bio, metadata: $metadata, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileUpdateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.settings, settings) ||
                other.settings == settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    phone,
    bio,
    const DeepCollectionEquality().hash(_metadata),
    settings,
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
    final String? name,
    final String? phone,
    final String? bio,
    final Map<String, dynamic>? metadata,
    final ProfileSettings? settings,
  }) = _$ProfileUpdateRequestImpl;

  factory _ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$ProfileUpdateRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get phone;
  @override
  String? get bio;
  @override
  Map<String, dynamic>? get metadata;
  @override
  ProfileSettings? get settings;

  /// Create a copy of ProfileUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileUpdateRequestImplCopyWith<_$ProfileUpdateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProfileStatistics _$ProfileStatisticsFromJson(Map<String, dynamic> json) {
  return _ProfileStatistics.fromJson(json);
}

/// @nodoc
mixin _$ProfileStatistics {
  int get loginCount => throw _privateConstructorUsedError;
  int get sessionsActive => throw _privateConstructorUsedError;
  int get devicesLinked => throw _privateConstructorUsedError;
  DateTime? get lastPasswordChange => throw _privateConstructorUsedError;
  DateTime? get last2FAChange => throw _privateConstructorUsedError;
  List<LoginHistory> get recentLogins => throw _privateConstructorUsedError;
  Map<String, int> get activityStats => throw _privateConstructorUsedError;

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
    int sessionsActive,
    int devicesLinked,
    DateTime? lastPasswordChange,
    DateTime? last2FAChange,
    List<LoginHistory> recentLogins,
    Map<String, int> activityStats,
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
    Object? sessionsActive = null,
    Object? devicesLinked = null,
    Object? lastPasswordChange = freezed,
    Object? last2FAChange = freezed,
    Object? recentLogins = null,
    Object? activityStats = null,
  }) {
    return _then(
      _value.copyWith(
            loginCount: null == loginCount
                ? _value.loginCount
                : loginCount // ignore: cast_nullable_to_non_nullable
                      as int,
            sessionsActive: null == sessionsActive
                ? _value.sessionsActive
                : sessionsActive // ignore: cast_nullable_to_non_nullable
                      as int,
            devicesLinked: null == devicesLinked
                ? _value.devicesLinked
                : devicesLinked // ignore: cast_nullable_to_non_nullable
                      as int,
            lastPasswordChange: freezed == lastPasswordChange
                ? _value.lastPasswordChange
                : lastPasswordChange // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            last2FAChange: freezed == last2FAChange
                ? _value.last2FAChange
                : last2FAChange // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            recentLogins: null == recentLogins
                ? _value.recentLogins
                : recentLogins // ignore: cast_nullable_to_non_nullable
                      as List<LoginHistory>,
            activityStats: null == activityStats
                ? _value.activityStats
                : activityStats // ignore: cast_nullable_to_non_nullable
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
    int sessionsActive,
    int devicesLinked,
    DateTime? lastPasswordChange,
    DateTime? last2FAChange,
    List<LoginHistory> recentLogins,
    Map<String, int> activityStats,
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
    Object? sessionsActive = null,
    Object? devicesLinked = null,
    Object? lastPasswordChange = freezed,
    Object? last2FAChange = freezed,
    Object? recentLogins = null,
    Object? activityStats = null,
  }) {
    return _then(
      _$ProfileStatisticsImpl(
        loginCount: null == loginCount
            ? _value.loginCount
            : loginCount // ignore: cast_nullable_to_non_nullable
                  as int,
        sessionsActive: null == sessionsActive
            ? _value.sessionsActive
            : sessionsActive // ignore: cast_nullable_to_non_nullable
                  as int,
        devicesLinked: null == devicesLinked
            ? _value.devicesLinked
            : devicesLinked // ignore: cast_nullable_to_non_nullable
                  as int,
        lastPasswordChange: freezed == lastPasswordChange
            ? _value.lastPasswordChange
            : lastPasswordChange // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        last2FAChange: freezed == last2FAChange
            ? _value.last2FAChange
            : last2FAChange // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        recentLogins: null == recentLogins
            ? _value._recentLogins
            : recentLogins // ignore: cast_nullable_to_non_nullable
                  as List<LoginHistory>,
        activityStats: null == activityStats
            ? _value._activityStats
            : activityStats // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileStatisticsImpl implements _ProfileStatistics {
  const _$ProfileStatisticsImpl({
    this.loginCount = 0,
    this.sessionsActive = 0,
    this.devicesLinked = 0,
    this.lastPasswordChange,
    this.last2FAChange,
    final List<LoginHistory> recentLogins = const [],
    final Map<String, int> activityStats = const {},
  }) : _recentLogins = recentLogins,
       _activityStats = activityStats;

  factory _$ProfileStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileStatisticsImplFromJson(json);

  @override
  @JsonKey()
  final int loginCount;
  @override
  @JsonKey()
  final int sessionsActive;
  @override
  @JsonKey()
  final int devicesLinked;
  @override
  final DateTime? lastPasswordChange;
  @override
  final DateTime? last2FAChange;
  final List<LoginHistory> _recentLogins;
  @override
  @JsonKey()
  List<LoginHistory> get recentLogins {
    if (_recentLogins is EqualUnmodifiableListView) return _recentLogins;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentLogins);
  }

  final Map<String, int> _activityStats;
  @override
  @JsonKey()
  Map<String, int> get activityStats {
    if (_activityStats is EqualUnmodifiableMapView) return _activityStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_activityStats);
  }

  @override
  String toString() {
    return 'ProfileStatistics(loginCount: $loginCount, sessionsActive: $sessionsActive, devicesLinked: $devicesLinked, lastPasswordChange: $lastPasswordChange, last2FAChange: $last2FAChange, recentLogins: $recentLogins, activityStats: $activityStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStatisticsImpl &&
            (identical(other.loginCount, loginCount) ||
                other.loginCount == loginCount) &&
            (identical(other.sessionsActive, sessionsActive) ||
                other.sessionsActive == sessionsActive) &&
            (identical(other.devicesLinked, devicesLinked) ||
                other.devicesLinked == devicesLinked) &&
            (identical(other.lastPasswordChange, lastPasswordChange) ||
                other.lastPasswordChange == lastPasswordChange) &&
            (identical(other.last2FAChange, last2FAChange) ||
                other.last2FAChange == last2FAChange) &&
            const DeepCollectionEquality().equals(
              other._recentLogins,
              _recentLogins,
            ) &&
            const DeepCollectionEquality().equals(
              other._activityStats,
              _activityStats,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    loginCount,
    sessionsActive,
    devicesLinked,
    lastPasswordChange,
    last2FAChange,
    const DeepCollectionEquality().hash(_recentLogins),
    const DeepCollectionEquality().hash(_activityStats),
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
    final int loginCount,
    final int sessionsActive,
    final int devicesLinked,
    final DateTime? lastPasswordChange,
    final DateTime? last2FAChange,
    final List<LoginHistory> recentLogins,
    final Map<String, int> activityStats,
  }) = _$ProfileStatisticsImpl;

  factory _ProfileStatistics.fromJson(Map<String, dynamic> json) =
      _$ProfileStatisticsImpl.fromJson;

  @override
  int get loginCount;
  @override
  int get sessionsActive;
  @override
  int get devicesLinked;
  @override
  DateTime? get lastPasswordChange;
  @override
  DateTime? get last2FAChange;
  @override
  List<LoginHistory> get recentLogins;
  @override
  Map<String, int> get activityStats;

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStatisticsImplCopyWith<_$ProfileStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginHistory _$LoginHistoryFromJson(Map<String, dynamic> json) {
  return _LoginHistory.fromJson(json);
}

/// @nodoc
mixin _$LoginHistory {
  String get id => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get userAgent => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get device => throw _privateConstructorUsedError;
  bool get successful => throw _privateConstructorUsedError;
  String? get failureReason => throw _privateConstructorUsedError;

  /// Serializes this LoginHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginHistoryCopyWith<LoginHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginHistoryCopyWith<$Res> {
  factory $LoginHistoryCopyWith(
    LoginHistory value,
    $Res Function(LoginHistory) then,
  ) = _$LoginHistoryCopyWithImpl<$Res, LoginHistory>;
  @useResult
  $Res call({
    String id,
    DateTime timestamp,
    String? ipAddress,
    String? userAgent,
    String? location,
    String? device,
    bool successful,
    String? failureReason,
  });
}

/// @nodoc
class _$LoginHistoryCopyWithImpl<$Res, $Val extends LoginHistory>
    implements $LoginHistoryCopyWith<$Res> {
  _$LoginHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? location = freezed,
    Object? device = freezed,
    Object? successful = null,
    Object? failureReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            userAgent: freezed == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            device: freezed == device
                ? _value.device
                : device // ignore: cast_nullable_to_non_nullable
                      as String?,
            successful: null == successful
                ? _value.successful
                : successful // ignore: cast_nullable_to_non_nullable
                      as bool,
            failureReason: freezed == failureReason
                ? _value.failureReason
                : failureReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginHistoryImplCopyWith<$Res>
    implements $LoginHistoryCopyWith<$Res> {
  factory _$$LoginHistoryImplCopyWith(
    _$LoginHistoryImpl value,
    $Res Function(_$LoginHistoryImpl) then,
  ) = __$$LoginHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime timestamp,
    String? ipAddress,
    String? userAgent,
    String? location,
    String? device,
    bool successful,
    String? failureReason,
  });
}

/// @nodoc
class __$$LoginHistoryImplCopyWithImpl<$Res>
    extends _$LoginHistoryCopyWithImpl<$Res, _$LoginHistoryImpl>
    implements _$$LoginHistoryImplCopyWith<$Res> {
  __$$LoginHistoryImplCopyWithImpl(
    _$LoginHistoryImpl _value,
    $Res Function(_$LoginHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? location = freezed,
    Object? device = freezed,
    Object? successful = null,
    Object? failureReason = freezed,
  }) {
    return _then(
      _$LoginHistoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        userAgent: freezed == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        device: freezed == device
            ? _value.device
            : device // ignore: cast_nullable_to_non_nullable
                  as String?,
        successful: null == successful
            ? _value.successful
            : successful // ignore: cast_nullable_to_non_nullable
                  as bool,
        failureReason: freezed == failureReason
            ? _value.failureReason
            : failureReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginHistoryImpl implements _LoginHistory {
  const _$LoginHistoryImpl({
    required this.id,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.location,
    this.device,
    this.successful = true,
    this.failureReason,
  });

  factory _$LoginHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginHistoryImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime timestamp;
  @override
  final String? ipAddress;
  @override
  final String? userAgent;
  @override
  final String? location;
  @override
  final String? device;
  @override
  @JsonKey()
  final bool successful;
  @override
  final String? failureReason;

  @override
  String toString() {
    return 'LoginHistory(id: $id, timestamp: $timestamp, ipAddress: $ipAddress, userAgent: $userAgent, location: $location, device: $device, successful: $successful, failureReason: $failureReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.successful, successful) ||
                other.successful == successful) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timestamp,
    ipAddress,
    userAgent,
    location,
    device,
    successful,
    failureReason,
  );

  /// Create a copy of LoginHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginHistoryImplCopyWith<_$LoginHistoryImpl> get copyWith =>
      __$$LoginHistoryImplCopyWithImpl<_$LoginHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginHistoryImplToJson(this);
  }
}

abstract class _LoginHistory implements LoginHistory {
  const factory _LoginHistory({
    required final String id,
    required final DateTime timestamp,
    final String? ipAddress,
    final String? userAgent,
    final String? location,
    final String? device,
    final bool successful,
    final String? failureReason,
  }) = _$LoginHistoryImpl;

  factory _LoginHistory.fromJson(Map<String, dynamic> json) =
      _$LoginHistoryImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get timestamp;
  @override
  String? get ipAddress;
  @override
  String? get userAgent;
  @override
  String? get location;
  @override
  String? get device;
  @override
  bool get successful;
  @override
  String? get failureReason;

  /// Create a copy of LoginHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginHistoryImplCopyWith<_$LoginHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) {
  return _PrivacySettings.fromJson(json);
}

/// @nodoc
mixin _$PrivacySettings {
  String get profileVisibility =>
      throw _privateConstructorUsedError; // public, friends, private
  bool get showEmail => throw _privateConstructorUsedError;
  bool get showPhone => throw _privateConstructorUsedError;
  bool get showLastSeen => throw _privateConstructorUsedError;
  bool get showOnlineStatus => throw _privateConstructorUsedError;
  List<String> get blockedUsers => throw _privateConstructorUsedError;
  Map<String, bool> get dataSharing => throw _privateConstructorUsedError;

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
    String profileVisibility,
    bool showEmail,
    bool showPhone,
    bool showLastSeen,
    bool showOnlineStatus,
    List<String> blockedUsers,
    Map<String, bool> dataSharing,
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
    Object? profileVisibility = null,
    Object? showEmail = null,
    Object? showPhone = null,
    Object? showLastSeen = null,
    Object? showOnlineStatus = null,
    Object? blockedUsers = null,
    Object? dataSharing = null,
  }) {
    return _then(
      _value.copyWith(
            profileVisibility: null == profileVisibility
                ? _value.profileVisibility
                : profileVisibility // ignore: cast_nullable_to_non_nullable
                      as String,
            showEmail: null == showEmail
                ? _value.showEmail
                : showEmail // ignore: cast_nullable_to_non_nullable
                      as bool,
            showPhone: null == showPhone
                ? _value.showPhone
                : showPhone // ignore: cast_nullable_to_non_nullable
                      as bool,
            showLastSeen: null == showLastSeen
                ? _value.showLastSeen
                : showLastSeen // ignore: cast_nullable_to_non_nullable
                      as bool,
            showOnlineStatus: null == showOnlineStatus
                ? _value.showOnlineStatus
                : showOnlineStatus // ignore: cast_nullable_to_non_nullable
                      as bool,
            blockedUsers: null == blockedUsers
                ? _value.blockedUsers
                : blockedUsers // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dataSharing: null == dataSharing
                ? _value.dataSharing
                : dataSharing // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
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
    String profileVisibility,
    bool showEmail,
    bool showPhone,
    bool showLastSeen,
    bool showOnlineStatus,
    List<String> blockedUsers,
    Map<String, bool> dataSharing,
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
    Object? profileVisibility = null,
    Object? showEmail = null,
    Object? showPhone = null,
    Object? showLastSeen = null,
    Object? showOnlineStatus = null,
    Object? blockedUsers = null,
    Object? dataSharing = null,
  }) {
    return _then(
      _$PrivacySettingsImpl(
        profileVisibility: null == profileVisibility
            ? _value.profileVisibility
            : profileVisibility // ignore: cast_nullable_to_non_nullable
                  as String,
        showEmail: null == showEmail
            ? _value.showEmail
            : showEmail // ignore: cast_nullable_to_non_nullable
                  as bool,
        showPhone: null == showPhone
            ? _value.showPhone
            : showPhone // ignore: cast_nullable_to_non_nullable
                  as bool,
        showLastSeen: null == showLastSeen
            ? _value.showLastSeen
            : showLastSeen // ignore: cast_nullable_to_non_nullable
                  as bool,
        showOnlineStatus: null == showOnlineStatus
            ? _value.showOnlineStatus
            : showOnlineStatus // ignore: cast_nullable_to_non_nullable
                  as bool,
        blockedUsers: null == blockedUsers
            ? _value._blockedUsers
            : blockedUsers // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dataSharing: null == dataSharing
            ? _value._dataSharing
            : dataSharing // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrivacySettingsImpl implements _PrivacySettings {
  const _$PrivacySettingsImpl({
    this.profileVisibility = 'public',
    this.showEmail = true,
    this.showPhone = false,
    this.showLastSeen = true,
    this.showOnlineStatus = true,
    final List<String> blockedUsers = const [],
    final Map<String, bool> dataSharing = const {},
  }) : _blockedUsers = blockedUsers,
       _dataSharing = dataSharing;

  factory _$PrivacySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrivacySettingsImplFromJson(json);

  @override
  @JsonKey()
  final String profileVisibility;
  // public, friends, private
  @override
  @JsonKey()
  final bool showEmail;
  @override
  @JsonKey()
  final bool showPhone;
  @override
  @JsonKey()
  final bool showLastSeen;
  @override
  @JsonKey()
  final bool showOnlineStatus;
  final List<String> _blockedUsers;
  @override
  @JsonKey()
  List<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedUsers);
  }

  final Map<String, bool> _dataSharing;
  @override
  @JsonKey()
  Map<String, bool> get dataSharing {
    if (_dataSharing is EqualUnmodifiableMapView) return _dataSharing;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dataSharing);
  }

  @override
  String toString() {
    return 'PrivacySettings(profileVisibility: $profileVisibility, showEmail: $showEmail, showPhone: $showPhone, showLastSeen: $showLastSeen, showOnlineStatus: $showOnlineStatus, blockedUsers: $blockedUsers, dataSharing: $dataSharing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrivacySettingsImpl &&
            (identical(other.profileVisibility, profileVisibility) ||
                other.profileVisibility == profileVisibility) &&
            (identical(other.showEmail, showEmail) ||
                other.showEmail == showEmail) &&
            (identical(other.showPhone, showPhone) ||
                other.showPhone == showPhone) &&
            (identical(other.showLastSeen, showLastSeen) ||
                other.showLastSeen == showLastSeen) &&
            (identical(other.showOnlineStatus, showOnlineStatus) ||
                other.showOnlineStatus == showOnlineStatus) &&
            const DeepCollectionEquality().equals(
              other._blockedUsers,
              _blockedUsers,
            ) &&
            const DeepCollectionEquality().equals(
              other._dataSharing,
              _dataSharing,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    profileVisibility,
    showEmail,
    showPhone,
    showLastSeen,
    showOnlineStatus,
    const DeepCollectionEquality().hash(_blockedUsers),
    const DeepCollectionEquality().hash(_dataSharing),
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
    final String profileVisibility,
    final bool showEmail,
    final bool showPhone,
    final bool showLastSeen,
    final bool showOnlineStatus,
    final List<String> blockedUsers,
    final Map<String, bool> dataSharing,
  }) = _$PrivacySettingsImpl;

  factory _PrivacySettings.fromJson(Map<String, dynamic> json) =
      _$PrivacySettingsImpl.fromJson;

  @override
  String get profileVisibility; // public, friends, private
  @override
  bool get showEmail;
  @override
  bool get showPhone;
  @override
  bool get showLastSeen;
  @override
  bool get showOnlineStatus;
  @override
  List<String> get blockedUsers;
  @override
  Map<String, bool> get dataSharing;

  /// Create a copy of PrivacySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrivacySettingsImplCopyWith<_$PrivacySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
