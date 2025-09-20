// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SystemStats _$SystemStatsFromJson(Map<String, dynamic> json) {
  return _SystemStats.fromJson(json);
}

/// @nodoc
mixin _$SystemStats {
  Map<String, int> get users => throw _privateConstructorUsedError;
  Map<String, int> get sessions => throw _privateConstructorUsedError;
  Map<String, int> get organizations => throw _privateConstructorUsedError;
  Map<String, int> get apiKeys => throw _privateConstructorUsedError;
  Map<String, int> get auditLogs => throw _privateConstructorUsedError;

  /// Serializes this SystemStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemStatsCopyWith<SystemStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemStatsCopyWith<$Res> {
  factory $SystemStatsCopyWith(
    SystemStats value,
    $Res Function(SystemStats) then,
  ) = _$SystemStatsCopyWithImpl<$Res, SystemStats>;
  @useResult
  $Res call({
    Map<String, int> users,
    Map<String, int> sessions,
    Map<String, int> organizations,
    Map<String, int> apiKeys,
    Map<String, int> auditLogs,
  });
}

/// @nodoc
class _$SystemStatsCopyWithImpl<$Res, $Val extends SystemStats>
    implements $SystemStatsCopyWith<$Res> {
  _$SystemStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? sessions = null,
    Object? organizations = null,
    Object? apiKeys = null,
    Object? auditLogs = null,
  }) {
    return _then(
      _value.copyWith(
            users: null == users
                ? _value.users
                : users // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            sessions: null == sessions
                ? _value.sessions
                : sessions // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            organizations: null == organizations
                ? _value.organizations
                : organizations // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            apiKeys: null == apiKeys
                ? _value.apiKeys
                : apiKeys // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            auditLogs: null == auditLogs
                ? _value.auditLogs
                : auditLogs // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SystemStatsImplCopyWith<$Res>
    implements $SystemStatsCopyWith<$Res> {
  factory _$$SystemStatsImplCopyWith(
    _$SystemStatsImpl value,
    $Res Function(_$SystemStatsImpl) then,
  ) = __$$SystemStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, int> users,
    Map<String, int> sessions,
    Map<String, int> organizations,
    Map<String, int> apiKeys,
    Map<String, int> auditLogs,
  });
}

/// @nodoc
class __$$SystemStatsImplCopyWithImpl<$Res>
    extends _$SystemStatsCopyWithImpl<$Res, _$SystemStatsImpl>
    implements _$$SystemStatsImplCopyWith<$Res> {
  __$$SystemStatsImplCopyWithImpl(
    _$SystemStatsImpl _value,
    $Res Function(_$SystemStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? sessions = null,
    Object? organizations = null,
    Object? apiKeys = null,
    Object? auditLogs = null,
  }) {
    return _then(
      _$SystemStatsImpl(
        users: null == users
            ? _value._users
            : users // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        sessions: null == sessions
            ? _value._sessions
            : sessions // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        organizations: null == organizations
            ? _value._organizations
            : organizations // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        apiKeys: null == apiKeys
            ? _value._apiKeys
            : apiKeys // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        auditLogs: null == auditLogs
            ? _value._auditLogs
            : auditLogs // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemStatsImpl implements _SystemStats {
  const _$SystemStatsImpl({
    required final Map<String, int> users,
    required final Map<String, int> sessions,
    required final Map<String, int> organizations,
    required final Map<String, int> apiKeys,
    required final Map<String, int> auditLogs,
  }) : _users = users,
       _sessions = sessions,
       _organizations = organizations,
       _apiKeys = apiKeys,
       _auditLogs = auditLogs;

  factory _$SystemStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemStatsImplFromJson(json);

  final Map<String, int> _users;
  @override
  Map<String, int> get users {
    if (_users is EqualUnmodifiableMapView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_users);
  }

  final Map<String, int> _sessions;
  @override
  Map<String, int> get sessions {
    if (_sessions is EqualUnmodifiableMapView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sessions);
  }

  final Map<String, int> _organizations;
  @override
  Map<String, int> get organizations {
    if (_organizations is EqualUnmodifiableMapView) return _organizations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_organizations);
  }

  final Map<String, int> _apiKeys;
  @override
  Map<String, int> get apiKeys {
    if (_apiKeys is EqualUnmodifiableMapView) return _apiKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_apiKeys);
  }

  final Map<String, int> _auditLogs;
  @override
  Map<String, int> get auditLogs {
    if (_auditLogs is EqualUnmodifiableMapView) return _auditLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_auditLogs);
  }

  @override
  String toString() {
    return 'SystemStats(users: $users, sessions: $sessions, organizations: $organizations, apiKeys: $apiKeys, auditLogs: $auditLogs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemStatsImpl &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            const DeepCollectionEquality().equals(other._sessions, _sessions) &&
            const DeepCollectionEquality().equals(
              other._organizations,
              _organizations,
            ) &&
            const DeepCollectionEquality().equals(other._apiKeys, _apiKeys) &&
            const DeepCollectionEquality().equals(
              other._auditLogs,
              _auditLogs,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_users),
    const DeepCollectionEquality().hash(_sessions),
    const DeepCollectionEquality().hash(_organizations),
    const DeepCollectionEquality().hash(_apiKeys),
    const DeepCollectionEquality().hash(_auditLogs),
  );

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemStatsImplCopyWith<_$SystemStatsImpl> get copyWith =>
      __$$SystemStatsImplCopyWithImpl<_$SystemStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemStatsImplToJson(this);
  }
}

abstract class _SystemStats implements SystemStats {
  const factory _SystemStats({
    required final Map<String, int> users,
    required final Map<String, int> sessions,
    required final Map<String, int> organizations,
    required final Map<String, int> apiKeys,
    required final Map<String, int> auditLogs,
  }) = _$SystemStatsImpl;

  factory _SystemStats.fromJson(Map<String, dynamic> json) =
      _$SystemStatsImpl.fromJson;

  @override
  Map<String, int> get users;
  @override
  Map<String, int> get sessions;
  @override
  Map<String, int> get organizations;
  @override
  Map<String, int> get apiKeys;
  @override
  Map<String, int> get auditLogs;

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemStatsImplCopyWith<_$SystemStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserManagementRequest _$UserManagementRequestFromJson(
  Map<String, dynamic> json,
) {
  return _UserManagementRequest.fromJson(json);
}

/// @nodoc
mixin _$UserManagementRequest {
  String? get email => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  bool? get isSuperuser => throw _privateConstructorUsedError;
  bool? get isVerified => throw _privateConstructorUsedError;
  bool? get twoFactorEnabled => throw _privateConstructorUsedError;
  List<String>? get roles => throw _privateConstructorUsedError;
  String? get organizationId => throw _privateConstructorUsedError;

  /// Serializes this UserManagementRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserManagementRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserManagementRequestCopyWith<UserManagementRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserManagementRequestCopyWith<$Res> {
  factory $UserManagementRequestCopyWith(
    UserManagementRequest value,
    $Res Function(UserManagementRequest) then,
  ) = _$UserManagementRequestCopyWithImpl<$Res, UserManagementRequest>;
  @useResult
  $Res call({
    String? email,
    String? name,
    String? password,
    bool? isActive,
    bool? isSuperuser,
    bool? isVerified,
    bool? twoFactorEnabled,
    List<String>? roles,
    String? organizationId,
  });
}

/// @nodoc
class _$UserManagementRequestCopyWithImpl<
  $Res,
  $Val extends UserManagementRequest
>
    implements $UserManagementRequestCopyWith<$Res> {
  _$UserManagementRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserManagementRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = freezed,
    Object? name = freezed,
    Object? password = freezed,
    Object? isActive = freezed,
    Object? isSuperuser = freezed,
    Object? isVerified = freezed,
    Object? twoFactorEnabled = freezed,
    Object? roles = freezed,
    Object? organizationId = freezed,
  }) {
    return _then(
      _value.copyWith(
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isSuperuser: freezed == isSuperuser
                ? _value.isSuperuser
                : isSuperuser // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isVerified: freezed == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool?,
            twoFactorEnabled: freezed == twoFactorEnabled
                ? _value.twoFactorEnabled
                : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
                      as bool?,
            roles: freezed == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            organizationId: freezed == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserManagementRequestImplCopyWith<$Res>
    implements $UserManagementRequestCopyWith<$Res> {
  factory _$$UserManagementRequestImplCopyWith(
    _$UserManagementRequestImpl value,
    $Res Function(_$UserManagementRequestImpl) then,
  ) = __$$UserManagementRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? email,
    String? name,
    String? password,
    bool? isActive,
    bool? isSuperuser,
    bool? isVerified,
    bool? twoFactorEnabled,
    List<String>? roles,
    String? organizationId,
  });
}

/// @nodoc
class __$$UserManagementRequestImplCopyWithImpl<$Res>
    extends
        _$UserManagementRequestCopyWithImpl<$Res, _$UserManagementRequestImpl>
    implements _$$UserManagementRequestImplCopyWith<$Res> {
  __$$UserManagementRequestImplCopyWithImpl(
    _$UserManagementRequestImpl _value,
    $Res Function(_$UserManagementRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserManagementRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = freezed,
    Object? name = freezed,
    Object? password = freezed,
    Object? isActive = freezed,
    Object? isSuperuser = freezed,
    Object? isVerified = freezed,
    Object? twoFactorEnabled = freezed,
    Object? roles = freezed,
    Object? organizationId = freezed,
  }) {
    return _then(
      _$UserManagementRequestImpl(
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isSuperuser: freezed == isSuperuser
            ? _value.isSuperuser
            : isSuperuser // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isVerified: freezed == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool?,
        twoFactorEnabled: freezed == twoFactorEnabled
            ? _value.twoFactorEnabled
            : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
                  as bool?,
        roles: freezed == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        organizationId: freezed == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserManagementRequestImpl implements _UserManagementRequest {
  const _$UserManagementRequestImpl({
    this.email,
    this.name,
    this.password,
    this.isActive,
    this.isSuperuser,
    this.isVerified,
    this.twoFactorEnabled,
    final List<String>? roles,
    this.organizationId,
  }) : _roles = roles;

  factory _$UserManagementRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserManagementRequestImplFromJson(json);

  @override
  final String? email;
  @override
  final String? name;
  @override
  final String? password;
  @override
  final bool? isActive;
  @override
  final bool? isSuperuser;
  @override
  final bool? isVerified;
  @override
  final bool? twoFactorEnabled;
  final List<String>? _roles;
  @override
  List<String>? get roles {
    final value = _roles;
    if (value == null) return null;
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? organizationId;

  @override
  String toString() {
    return 'UserManagementRequest(email: $email, name: $name, password: $password, isActive: $isActive, isSuperuser: $isSuperuser, isVerified: $isVerified, twoFactorEnabled: $twoFactorEnabled, roles: $roles, organizationId: $organizationId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserManagementRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isSuperuser, isSuperuser) ||
                other.isSuperuser == isSuperuser) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.twoFactorEnabled, twoFactorEnabled) ||
                other.twoFactorEnabled == twoFactorEnabled) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    email,
    name,
    password,
    isActive,
    isSuperuser,
    isVerified,
    twoFactorEnabled,
    const DeepCollectionEquality().hash(_roles),
    organizationId,
  );

  /// Create a copy of UserManagementRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserManagementRequestImplCopyWith<_$UserManagementRequestImpl>
  get copyWith =>
      __$$UserManagementRequestImplCopyWithImpl<_$UserManagementRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserManagementRequestImplToJson(this);
  }
}

abstract class _UserManagementRequest implements UserManagementRequest {
  const factory _UserManagementRequest({
    final String? email,
    final String? name,
    final String? password,
    final bool? isActive,
    final bool? isSuperuser,
    final bool? isVerified,
    final bool? twoFactorEnabled,
    final List<String>? roles,
    final String? organizationId,
  }) = _$UserManagementRequestImpl;

  factory _UserManagementRequest.fromJson(Map<String, dynamic> json) =
      _$UserManagementRequestImpl.fromJson;

  @override
  String? get email;
  @override
  String? get name;
  @override
  String? get password;
  @override
  bool? get isActive;
  @override
  bool? get isSuperuser;
  @override
  bool? get isVerified;
  @override
  bool? get twoFactorEnabled;
  @override
  List<String>? get roles;
  @override
  String? get organizationId;

  /// Create a copy of UserManagementRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserManagementRequestImplCopyWith<_$UserManagementRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UserManagementResponse _$UserManagementResponseFromJson(
  Map<String, dynamic> json,
) {
  return _UserManagementResponse.fromJson(json);
}

/// @nodoc
mixin _$UserManagementResponse {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  bool get isSuperuser => throw _privateConstructorUsedError;
  bool get isSuspended => throw _privateConstructorUsedError;
  bool get twoFactorEnabled => throw _privateConstructorUsedError;
  List<Map<String, String>> get roles => throw _privateConstructorUsedError;
  String? get organizationId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastLogin => throw _privateConstructorUsedError;
  String? get suspensionReason => throw _privateConstructorUsedError;
  DateTime? get suspendedUntil => throw _privateConstructorUsedError;

  /// Serializes this UserManagementResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserManagementResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserManagementResponseCopyWith<UserManagementResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserManagementResponseCopyWith<$Res> {
  factory $UserManagementResponseCopyWith(
    UserManagementResponse value,
    $Res Function(UserManagementResponse) then,
  ) = _$UserManagementResponseCopyWithImpl<$Res, UserManagementResponse>;
  @useResult
  $Res call({
    String id,
    String email,
    String? name,
    bool isActive,
    bool isVerified,
    bool isSuperuser,
    bool isSuspended,
    bool twoFactorEnabled,
    List<Map<String, String>> roles,
    String? organizationId,
    DateTime createdAt,
    DateTime? lastLogin,
    String? suspensionReason,
    DateTime? suspendedUntil,
  });
}

/// @nodoc
class _$UserManagementResponseCopyWithImpl<
  $Res,
  $Val extends UserManagementResponse
>
    implements $UserManagementResponseCopyWith<$Res> {
  _$UserManagementResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserManagementResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? isSuperuser = null,
    Object? isSuspended = null,
    Object? twoFactorEnabled = null,
    Object? roles = null,
    Object? organizationId = freezed,
    Object? createdAt = null,
    Object? lastLogin = freezed,
    Object? suspensionReason = freezed,
    Object? suspendedUntil = freezed,
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
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSuperuser: null == isSuperuser
                ? _value.isSuperuser
                : isSuperuser // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSuspended: null == isSuspended
                ? _value.isSuspended
                : isSuspended // ignore: cast_nullable_to_non_nullable
                      as bool,
            twoFactorEnabled: null == twoFactorEnabled
                ? _value.twoFactorEnabled
                : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, String>>,
            organizationId: freezed == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastLogin: freezed == lastLogin
                ? _value.lastLogin
                : lastLogin // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            suspensionReason: freezed == suspensionReason
                ? _value.suspensionReason
                : suspensionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            suspendedUntil: freezed == suspendedUntil
                ? _value.suspendedUntil
                : suspendedUntil // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserManagementResponseImplCopyWith<$Res>
    implements $UserManagementResponseCopyWith<$Res> {
  factory _$$UserManagementResponseImplCopyWith(
    _$UserManagementResponseImpl value,
    $Res Function(_$UserManagementResponseImpl) then,
  ) = __$$UserManagementResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? name,
    bool isActive,
    bool isVerified,
    bool isSuperuser,
    bool isSuspended,
    bool twoFactorEnabled,
    List<Map<String, String>> roles,
    String? organizationId,
    DateTime createdAt,
    DateTime? lastLogin,
    String? suspensionReason,
    DateTime? suspendedUntil,
  });
}

/// @nodoc
class __$$UserManagementResponseImplCopyWithImpl<$Res>
    extends
        _$UserManagementResponseCopyWithImpl<$Res, _$UserManagementResponseImpl>
    implements _$$UserManagementResponseImplCopyWith<$Res> {
  __$$UserManagementResponseImplCopyWithImpl(
    _$UserManagementResponseImpl _value,
    $Res Function(_$UserManagementResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserManagementResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? isSuperuser = null,
    Object? isSuspended = null,
    Object? twoFactorEnabled = null,
    Object? roles = null,
    Object? organizationId = freezed,
    Object? createdAt = null,
    Object? lastLogin = freezed,
    Object? suspensionReason = freezed,
    Object? suspendedUntil = freezed,
  }) {
    return _then(
      _$UserManagementResponseImpl(
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
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSuperuser: null == isSuperuser
            ? _value.isSuperuser
            : isSuperuser // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSuspended: null == isSuspended
            ? _value.isSuspended
            : isSuspended // ignore: cast_nullable_to_non_nullable
                  as bool,
        twoFactorEnabled: null == twoFactorEnabled
            ? _value.twoFactorEnabled
            : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, String>>,
        organizationId: freezed == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastLogin: freezed == lastLogin
            ? _value.lastLogin
            : lastLogin // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        suspensionReason: freezed == suspensionReason
            ? _value.suspensionReason
            : suspensionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        suspendedUntil: freezed == suspendedUntil
            ? _value.suspendedUntil
            : suspendedUntil // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserManagementResponseImpl implements _UserManagementResponse {
  const _$UserManagementResponseImpl({
    required this.id,
    required this.email,
    this.name,
    required this.isActive,
    required this.isVerified,
    required this.isSuperuser,
    required this.isSuspended,
    required this.twoFactorEnabled,
    required final List<Map<String, String>> roles,
    this.organizationId,
    required this.createdAt,
    this.lastLogin,
    this.suspensionReason,
    this.suspendedUntil,
  }) : _roles = roles;

  factory _$UserManagementResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserManagementResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? name;
  @override
  final bool isActive;
  @override
  final bool isVerified;
  @override
  final bool isSuperuser;
  @override
  final bool isSuspended;
  @override
  final bool twoFactorEnabled;
  final List<Map<String, String>> _roles;
  @override
  List<Map<String, String>> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  @override
  final String? organizationId;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastLogin;
  @override
  final String? suspensionReason;
  @override
  final DateTime? suspendedUntil;

  @override
  String toString() {
    return 'UserManagementResponse(id: $id, email: $email, name: $name, isActive: $isActive, isVerified: $isVerified, isSuperuser: $isSuperuser, isSuspended: $isSuspended, twoFactorEnabled: $twoFactorEnabled, roles: $roles, organizationId: $organizationId, createdAt: $createdAt, lastLogin: $lastLogin, suspensionReason: $suspensionReason, suspendedUntil: $suspendedUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserManagementResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isSuperuser, isSuperuser) ||
                other.isSuperuser == isSuperuser) &&
            (identical(other.isSuspended, isSuspended) ||
                other.isSuspended == isSuspended) &&
            (identical(other.twoFactorEnabled, twoFactorEnabled) ||
                other.twoFactorEnabled == twoFactorEnabled) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin) &&
            (identical(other.suspensionReason, suspensionReason) ||
                other.suspensionReason == suspensionReason) &&
            (identical(other.suspendedUntil, suspendedUntil) ||
                other.suspendedUntil == suspendedUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    name,
    isActive,
    isVerified,
    isSuperuser,
    isSuspended,
    twoFactorEnabled,
    const DeepCollectionEquality().hash(_roles),
    organizationId,
    createdAt,
    lastLogin,
    suspensionReason,
    suspendedUntil,
  );

  /// Create a copy of UserManagementResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserManagementResponseImplCopyWith<_$UserManagementResponseImpl>
  get copyWith =>
      __$$UserManagementResponseImplCopyWithImpl<_$UserManagementResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserManagementResponseImplToJson(this);
  }
}

abstract class _UserManagementResponse implements UserManagementResponse {
  const factory _UserManagementResponse({
    required final String id,
    required final String email,
    final String? name,
    required final bool isActive,
    required final bool isVerified,
    required final bool isSuperuser,
    required final bool isSuspended,
    required final bool twoFactorEnabled,
    required final List<Map<String, String>> roles,
    final String? organizationId,
    required final DateTime createdAt,
    final DateTime? lastLogin,
    final String? suspensionReason,
    final DateTime? suspendedUntil,
  }) = _$UserManagementResponseImpl;

  factory _UserManagementResponse.fromJson(Map<String, dynamic> json) =
      _$UserManagementResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get name;
  @override
  bool get isActive;
  @override
  bool get isVerified;
  @override
  bool get isSuperuser;
  @override
  bool get isSuspended;
  @override
  bool get twoFactorEnabled;
  @override
  List<Map<String, String>> get roles;
  @override
  String? get organizationId;
  @override
  DateTime get createdAt;
  @override
  DateTime? get lastLogin;
  @override
  String? get suspensionReason;
  @override
  DateTime? get suspendedUntil;

  /// Create a copy of UserManagementResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserManagementResponseImplCopyWith<_$UserManagementResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

BulkUserOperation _$BulkUserOperationFromJson(Map<String, dynamic> json) {
  return _BulkUserOperation.fromJson(json);
}

/// @nodoc
mixin _$BulkUserOperation {
  List<String> get userIds => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this BulkUserOperation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BulkUserOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BulkUserOperationCopyWith<BulkUserOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BulkUserOperationCopyWith<$Res> {
  factory $BulkUserOperationCopyWith(
    BulkUserOperation value,
    $Res Function(BulkUserOperation) then,
  ) = _$BulkUserOperationCopyWithImpl<$Res, BulkUserOperation>;
  @useResult
  $Res call({List<String> userIds, String action, String? reason});
}

/// @nodoc
class _$BulkUserOperationCopyWithImpl<$Res, $Val extends BulkUserOperation>
    implements $BulkUserOperationCopyWith<$Res> {
  _$BulkUserOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BulkUserOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userIds = null,
    Object? action = null,
    Object? reason = freezed,
  }) {
    return _then(
      _value.copyWith(
            userIds: null == userIds
                ? _value.userIds
                : userIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BulkUserOperationImplCopyWith<$Res>
    implements $BulkUserOperationCopyWith<$Res> {
  factory _$$BulkUserOperationImplCopyWith(
    _$BulkUserOperationImpl value,
    $Res Function(_$BulkUserOperationImpl) then,
  ) = __$$BulkUserOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> userIds, String action, String? reason});
}

/// @nodoc
class __$$BulkUserOperationImplCopyWithImpl<$Res>
    extends _$BulkUserOperationCopyWithImpl<$Res, _$BulkUserOperationImpl>
    implements _$$BulkUserOperationImplCopyWith<$Res> {
  __$$BulkUserOperationImplCopyWithImpl(
    _$BulkUserOperationImpl _value,
    $Res Function(_$BulkUserOperationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BulkUserOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userIds = null,
    Object? action = null,
    Object? reason = freezed,
  }) {
    return _then(
      _$BulkUserOperationImpl(
        userIds: null == userIds
            ? _value._userIds
            : userIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BulkUserOperationImpl implements _BulkUserOperation {
  const _$BulkUserOperationImpl({
    required final List<String> userIds,
    required this.action,
    this.reason,
  }) : _userIds = userIds;

  factory _$BulkUserOperationImpl.fromJson(Map<String, dynamic> json) =>
      _$$BulkUserOperationImplFromJson(json);

  final List<String> _userIds;
  @override
  List<String> get userIds {
    if (_userIds is EqualUnmodifiableListView) return _userIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userIds);
  }

  @override
  final String action;
  @override
  final String? reason;

  @override
  String toString() {
    return 'BulkUserOperation(userIds: $userIds, action: $action, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BulkUserOperationImpl &&
            const DeepCollectionEquality().equals(other._userIds, _userIds) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_userIds),
    action,
    reason,
  );

  /// Create a copy of BulkUserOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BulkUserOperationImplCopyWith<_$BulkUserOperationImpl> get copyWith =>
      __$$BulkUserOperationImplCopyWithImpl<_$BulkUserOperationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BulkUserOperationImplToJson(this);
  }
}

abstract class _BulkUserOperation implements BulkUserOperation {
  const factory _BulkUserOperation({
    required final List<String> userIds,
    required final String action,
    final String? reason,
  }) = _$BulkUserOperationImpl;

  factory _BulkUserOperation.fromJson(Map<String, dynamic> json) =
      _$BulkUserOperationImpl.fromJson;

  @override
  List<String> get userIds;
  @override
  String get action;
  @override
  String? get reason;

  /// Create a copy of BulkUserOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BulkUserOperationImplCopyWith<_$BulkUserOperationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SystemConfigUpdate _$SystemConfigUpdateFromJson(Map<String, dynamic> json) {
  return _SystemConfigUpdate.fromJson(json);
}

/// @nodoc
mixin _$SystemConfigUpdate {
  Map<String, dynamic>? get authConfig => throw _privateConstructorUsedError;
  Map<String, bool>? get featureFlags => throw _privateConstructorUsedError;
  Map<String, int>? get rateLimits => throw _privateConstructorUsedError;
  bool? get maintenanceMode => throw _privateConstructorUsedError;
  String? get maintenanceMessage => throw _privateConstructorUsedError;

  /// Serializes this SystemConfigUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemConfigUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemConfigUpdateCopyWith<SystemConfigUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemConfigUpdateCopyWith<$Res> {
  factory $SystemConfigUpdateCopyWith(
    SystemConfigUpdate value,
    $Res Function(SystemConfigUpdate) then,
  ) = _$SystemConfigUpdateCopyWithImpl<$Res, SystemConfigUpdate>;
  @useResult
  $Res call({
    Map<String, dynamic>? authConfig,
    Map<String, bool>? featureFlags,
    Map<String, int>? rateLimits,
    bool? maintenanceMode,
    String? maintenanceMessage,
  });
}

/// @nodoc
class _$SystemConfigUpdateCopyWithImpl<$Res, $Val extends SystemConfigUpdate>
    implements $SystemConfigUpdateCopyWith<$Res> {
  _$SystemConfigUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemConfigUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authConfig = freezed,
    Object? featureFlags = freezed,
    Object? rateLimits = freezed,
    Object? maintenanceMode = freezed,
    Object? maintenanceMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            authConfig: freezed == authConfig
                ? _value.authConfig
                : authConfig // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            featureFlags: freezed == featureFlags
                ? _value.featureFlags
                : featureFlags // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>?,
            rateLimits: freezed == rateLimits
                ? _value.rateLimits
                : rateLimits // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>?,
            maintenanceMode: freezed == maintenanceMode
                ? _value.maintenanceMode
                : maintenanceMode // ignore: cast_nullable_to_non_nullable
                      as bool?,
            maintenanceMessage: freezed == maintenanceMessage
                ? _value.maintenanceMessage
                : maintenanceMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SystemConfigUpdateImplCopyWith<$Res>
    implements $SystemConfigUpdateCopyWith<$Res> {
  factory _$$SystemConfigUpdateImplCopyWith(
    _$SystemConfigUpdateImpl value,
    $Res Function(_$SystemConfigUpdateImpl) then,
  ) = __$$SystemConfigUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, dynamic>? authConfig,
    Map<String, bool>? featureFlags,
    Map<String, int>? rateLimits,
    bool? maintenanceMode,
    String? maintenanceMessage,
  });
}

/// @nodoc
class __$$SystemConfigUpdateImplCopyWithImpl<$Res>
    extends _$SystemConfigUpdateCopyWithImpl<$Res, _$SystemConfigUpdateImpl>
    implements _$$SystemConfigUpdateImplCopyWith<$Res> {
  __$$SystemConfigUpdateImplCopyWithImpl(
    _$SystemConfigUpdateImpl _value,
    $Res Function(_$SystemConfigUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemConfigUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authConfig = freezed,
    Object? featureFlags = freezed,
    Object? rateLimits = freezed,
    Object? maintenanceMode = freezed,
    Object? maintenanceMessage = freezed,
  }) {
    return _then(
      _$SystemConfigUpdateImpl(
        authConfig: freezed == authConfig
            ? _value._authConfig
            : authConfig // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        featureFlags: freezed == featureFlags
            ? _value._featureFlags
            : featureFlags // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>?,
        rateLimits: freezed == rateLimits
            ? _value._rateLimits
            : rateLimits // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>?,
        maintenanceMode: freezed == maintenanceMode
            ? _value.maintenanceMode
            : maintenanceMode // ignore: cast_nullable_to_non_nullable
                  as bool?,
        maintenanceMessage: freezed == maintenanceMessage
            ? _value.maintenanceMessage
            : maintenanceMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemConfigUpdateImpl implements _SystemConfigUpdate {
  const _$SystemConfigUpdateImpl({
    final Map<String, dynamic>? authConfig,
    final Map<String, bool>? featureFlags,
    final Map<String, int>? rateLimits,
    this.maintenanceMode,
    this.maintenanceMessage,
  }) : _authConfig = authConfig,
       _featureFlags = featureFlags,
       _rateLimits = rateLimits;

  factory _$SystemConfigUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemConfigUpdateImplFromJson(json);

  final Map<String, dynamic>? _authConfig;
  @override
  Map<String, dynamic>? get authConfig {
    final value = _authConfig;
    if (value == null) return null;
    if (_authConfig is EqualUnmodifiableMapView) return _authConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, bool>? _featureFlags;
  @override
  Map<String, bool>? get featureFlags {
    final value = _featureFlags;
    if (value == null) return null;
    if (_featureFlags is EqualUnmodifiableMapView) return _featureFlags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, int>? _rateLimits;
  @override
  Map<String, int>? get rateLimits {
    final value = _rateLimits;
    if (value == null) return null;
    if (_rateLimits is EqualUnmodifiableMapView) return _rateLimits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? maintenanceMode;
  @override
  final String? maintenanceMessage;

  @override
  String toString() {
    return 'SystemConfigUpdate(authConfig: $authConfig, featureFlags: $featureFlags, rateLimits: $rateLimits, maintenanceMode: $maintenanceMode, maintenanceMessage: $maintenanceMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemConfigUpdateImpl &&
            const DeepCollectionEquality().equals(
              other._authConfig,
              _authConfig,
            ) &&
            const DeepCollectionEquality().equals(
              other._featureFlags,
              _featureFlags,
            ) &&
            const DeepCollectionEquality().equals(
              other._rateLimits,
              _rateLimits,
            ) &&
            (identical(other.maintenanceMode, maintenanceMode) ||
                other.maintenanceMode == maintenanceMode) &&
            (identical(other.maintenanceMessage, maintenanceMessage) ||
                other.maintenanceMessage == maintenanceMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_authConfig),
    const DeepCollectionEquality().hash(_featureFlags),
    const DeepCollectionEquality().hash(_rateLimits),
    maintenanceMode,
    maintenanceMessage,
  );

  /// Create a copy of SystemConfigUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemConfigUpdateImplCopyWith<_$SystemConfigUpdateImpl> get copyWith =>
      __$$SystemConfigUpdateImplCopyWithImpl<_$SystemConfigUpdateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemConfigUpdateImplToJson(this);
  }
}

abstract class _SystemConfigUpdate implements SystemConfigUpdate {
  const factory _SystemConfigUpdate({
    final Map<String, dynamic>? authConfig,
    final Map<String, bool>? featureFlags,
    final Map<String, int>? rateLimits,
    final bool? maintenanceMode,
    final String? maintenanceMessage,
  }) = _$SystemConfigUpdateImpl;

  factory _SystemConfigUpdate.fromJson(Map<String, dynamic> json) =
      _$SystemConfigUpdateImpl.fromJson;

  @override
  Map<String, dynamic>? get authConfig;
  @override
  Map<String, bool>? get featureFlags;
  @override
  Map<String, int>? get rateLimits;
  @override
  bool? get maintenanceMode;
  @override
  String? get maintenanceMessage;

  /// Create a copy of SystemConfigUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemConfigUpdateImplCopyWith<_$SystemConfigUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdminDashboardData _$AdminDashboardDataFromJson(Map<String, dynamic> json) {
  return _AdminDashboardData.fromJson(json);
}

/// @nodoc
mixin _$AdminDashboardData {
  int get totalUsers => throw _privateConstructorUsedError;
  int get activeUsers => throw _privateConstructorUsedError;
  int get suspendedUsers => throw _privateConstructorUsedError;
  int get activeSessions => throw _privateConstructorUsedError;
  int get recentRegistrations => throw _privateConstructorUsedError;
  int get failedLoginAttempts => throw _privateConstructorUsedError;
  Map<String, int> get roleDistribution => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get recentAuditLogs =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> get systemHealth => throw _privateConstructorUsedError;

  /// Serializes this AdminDashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminDashboardDataCopyWith<AdminDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminDashboardDataCopyWith<$Res> {
  factory $AdminDashboardDataCopyWith(
    AdminDashboardData value,
    $Res Function(AdminDashboardData) then,
  ) = _$AdminDashboardDataCopyWithImpl<$Res, AdminDashboardData>;
  @useResult
  $Res call({
    int totalUsers,
    int activeUsers,
    int suspendedUsers,
    int activeSessions,
    int recentRegistrations,
    int failedLoginAttempts,
    Map<String, int> roleDistribution,
    List<Map<String, dynamic>> recentAuditLogs,
    Map<String, dynamic> systemHealth,
  });
}

/// @nodoc
class _$AdminDashboardDataCopyWithImpl<$Res, $Val extends AdminDashboardData>
    implements $AdminDashboardDataCopyWith<$Res> {
  _$AdminDashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? activeUsers = null,
    Object? suspendedUsers = null,
    Object? activeSessions = null,
    Object? recentRegistrations = null,
    Object? failedLoginAttempts = null,
    Object? roleDistribution = null,
    Object? recentAuditLogs = null,
    Object? systemHealth = null,
  }) {
    return _then(
      _value.copyWith(
            totalUsers: null == totalUsers
                ? _value.totalUsers
                : totalUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            activeUsers: null == activeUsers
                ? _value.activeUsers
                : activeUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            suspendedUsers: null == suspendedUsers
                ? _value.suspendedUsers
                : suspendedUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            activeSessions: null == activeSessions
                ? _value.activeSessions
                : activeSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            recentRegistrations: null == recentRegistrations
                ? _value.recentRegistrations
                : recentRegistrations // ignore: cast_nullable_to_non_nullable
                      as int,
            failedLoginAttempts: null == failedLoginAttempts
                ? _value.failedLoginAttempts
                : failedLoginAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            roleDistribution: null == roleDistribution
                ? _value.roleDistribution
                : roleDistribution // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            recentAuditLogs: null == recentAuditLogs
                ? _value.recentAuditLogs
                : recentAuditLogs // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            systemHealth: null == systemHealth
                ? _value.systemHealth
                : systemHealth // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminDashboardDataImplCopyWith<$Res>
    implements $AdminDashboardDataCopyWith<$Res> {
  factory _$$AdminDashboardDataImplCopyWith(
    _$AdminDashboardDataImpl value,
    $Res Function(_$AdminDashboardDataImpl) then,
  ) = __$$AdminDashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalUsers,
    int activeUsers,
    int suspendedUsers,
    int activeSessions,
    int recentRegistrations,
    int failedLoginAttempts,
    Map<String, int> roleDistribution,
    List<Map<String, dynamic>> recentAuditLogs,
    Map<String, dynamic> systemHealth,
  });
}

/// @nodoc
class __$$AdminDashboardDataImplCopyWithImpl<$Res>
    extends _$AdminDashboardDataCopyWithImpl<$Res, _$AdminDashboardDataImpl>
    implements _$$AdminDashboardDataImplCopyWith<$Res> {
  __$$AdminDashboardDataImplCopyWithImpl(
    _$AdminDashboardDataImpl _value,
    $Res Function(_$AdminDashboardDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? activeUsers = null,
    Object? suspendedUsers = null,
    Object? activeSessions = null,
    Object? recentRegistrations = null,
    Object? failedLoginAttempts = null,
    Object? roleDistribution = null,
    Object? recentAuditLogs = null,
    Object? systemHealth = null,
  }) {
    return _then(
      _$AdminDashboardDataImpl(
        totalUsers: null == totalUsers
            ? _value.totalUsers
            : totalUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        activeUsers: null == activeUsers
            ? _value.activeUsers
            : activeUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        suspendedUsers: null == suspendedUsers
            ? _value.suspendedUsers
            : suspendedUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        activeSessions: null == activeSessions
            ? _value.activeSessions
            : activeSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        recentRegistrations: null == recentRegistrations
            ? _value.recentRegistrations
            : recentRegistrations // ignore: cast_nullable_to_non_nullable
                  as int,
        failedLoginAttempts: null == failedLoginAttempts
            ? _value.failedLoginAttempts
            : failedLoginAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        roleDistribution: null == roleDistribution
            ? _value._roleDistribution
            : roleDistribution // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        recentAuditLogs: null == recentAuditLogs
            ? _value._recentAuditLogs
            : recentAuditLogs // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        systemHealth: null == systemHealth
            ? _value._systemHealth
            : systemHealth // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminDashboardDataImpl implements _AdminDashboardData {
  const _$AdminDashboardDataImpl({
    required this.totalUsers,
    required this.activeUsers,
    required this.suspendedUsers,
    required this.activeSessions,
    required this.recentRegistrations,
    required this.failedLoginAttempts,
    required final Map<String, int> roleDistribution,
    required final List<Map<String, dynamic>> recentAuditLogs,
    required final Map<String, dynamic> systemHealth,
  }) : _roleDistribution = roleDistribution,
       _recentAuditLogs = recentAuditLogs,
       _systemHealth = systemHealth;

  factory _$AdminDashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminDashboardDataImplFromJson(json);

  @override
  final int totalUsers;
  @override
  final int activeUsers;
  @override
  final int suspendedUsers;
  @override
  final int activeSessions;
  @override
  final int recentRegistrations;
  @override
  final int failedLoginAttempts;
  final Map<String, int> _roleDistribution;
  @override
  Map<String, int> get roleDistribution {
    if (_roleDistribution is EqualUnmodifiableMapView) return _roleDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_roleDistribution);
  }

  final List<Map<String, dynamic>> _recentAuditLogs;
  @override
  List<Map<String, dynamic>> get recentAuditLogs {
    if (_recentAuditLogs is EqualUnmodifiableListView) return _recentAuditLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentAuditLogs);
  }

  final Map<String, dynamic> _systemHealth;
  @override
  Map<String, dynamic> get systemHealth {
    if (_systemHealth is EqualUnmodifiableMapView) return _systemHealth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_systemHealth);
  }

  @override
  String toString() {
    return 'AdminDashboardData(totalUsers: $totalUsers, activeUsers: $activeUsers, suspendedUsers: $suspendedUsers, activeSessions: $activeSessions, recentRegistrations: $recentRegistrations, failedLoginAttempts: $failedLoginAttempts, roleDistribution: $roleDistribution, recentAuditLogs: $recentAuditLogs, systemHealth: $systemHealth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminDashboardDataImpl &&
            (identical(other.totalUsers, totalUsers) ||
                other.totalUsers == totalUsers) &&
            (identical(other.activeUsers, activeUsers) ||
                other.activeUsers == activeUsers) &&
            (identical(other.suspendedUsers, suspendedUsers) ||
                other.suspendedUsers == suspendedUsers) &&
            (identical(other.activeSessions, activeSessions) ||
                other.activeSessions == activeSessions) &&
            (identical(other.recentRegistrations, recentRegistrations) ||
                other.recentRegistrations == recentRegistrations) &&
            (identical(other.failedLoginAttempts, failedLoginAttempts) ||
                other.failedLoginAttempts == failedLoginAttempts) &&
            const DeepCollectionEquality().equals(
              other._roleDistribution,
              _roleDistribution,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentAuditLogs,
              _recentAuditLogs,
            ) &&
            const DeepCollectionEquality().equals(
              other._systemHealth,
              _systemHealth,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalUsers,
    activeUsers,
    suspendedUsers,
    activeSessions,
    recentRegistrations,
    failedLoginAttempts,
    const DeepCollectionEquality().hash(_roleDistribution),
    const DeepCollectionEquality().hash(_recentAuditLogs),
    const DeepCollectionEquality().hash(_systemHealth),
  );

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminDashboardDataImplCopyWith<_$AdminDashboardDataImpl> get copyWith =>
      __$$AdminDashboardDataImplCopyWithImpl<_$AdminDashboardDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminDashboardDataImplToJson(this);
  }
}

abstract class _AdminDashboardData implements AdminDashboardData {
  const factory _AdminDashboardData({
    required final int totalUsers,
    required final int activeUsers,
    required final int suspendedUsers,
    required final int activeSessions,
    required final int recentRegistrations,
    required final int failedLoginAttempts,
    required final Map<String, int> roleDistribution,
    required final List<Map<String, dynamic>> recentAuditLogs,
    required final Map<String, dynamic> systemHealth,
  }) = _$AdminDashboardDataImpl;

  factory _AdminDashboardData.fromJson(Map<String, dynamic> json) =
      _$AdminDashboardDataImpl.fromJson;

  @override
  int get totalUsers;
  @override
  int get activeUsers;
  @override
  int get suspendedUsers;
  @override
  int get activeSessions;
  @override
  int get recentRegistrations;
  @override
  int get failedLoginAttempts;
  @override
  Map<String, int> get roleDistribution;
  @override
  List<Map<String, dynamic>> get recentAuditLogs;
  @override
  Map<String, dynamic> get systemHealth;

  /// Create a copy of AdminDashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminDashboardDataImplCopyWith<_$AdminDashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserActivityReport _$UserActivityReportFromJson(Map<String, dynamic> json) {
  return _UserActivityReport.fromJson(json);
}

/// @nodoc
mixin _$UserActivityReport {
  int get periodDays => throw _privateConstructorUsedError;
  int get totalActions => throw _privateConstructorUsedError;
  Map<String, int> get actionsByType => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get dailyActivity =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get mostActiveUsers =>
      throw _privateConstructorUsedError;

  /// Serializes this UserActivityReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserActivityReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserActivityReportCopyWith<UserActivityReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserActivityReportCopyWith<$Res> {
  factory $UserActivityReportCopyWith(
    UserActivityReport value,
    $Res Function(UserActivityReport) then,
  ) = _$UserActivityReportCopyWithImpl<$Res, UserActivityReport>;
  @useResult
  $Res call({
    int periodDays,
    int totalActions,
    Map<String, int> actionsByType,
    List<Map<String, dynamic>> dailyActivity,
    List<Map<String, dynamic>> mostActiveUsers,
  });
}

/// @nodoc
class _$UserActivityReportCopyWithImpl<$Res, $Val extends UserActivityReport>
    implements $UserActivityReportCopyWith<$Res> {
  _$UserActivityReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserActivityReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodDays = null,
    Object? totalActions = null,
    Object? actionsByType = null,
    Object? dailyActivity = null,
    Object? mostActiveUsers = null,
  }) {
    return _then(
      _value.copyWith(
            periodDays: null == periodDays
                ? _value.periodDays
                : periodDays // ignore: cast_nullable_to_non_nullable
                      as int,
            totalActions: null == totalActions
                ? _value.totalActions
                : totalActions // ignore: cast_nullable_to_non_nullable
                      as int,
            actionsByType: null == actionsByType
                ? _value.actionsByType
                : actionsByType // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            dailyActivity: null == dailyActivity
                ? _value.dailyActivity
                : dailyActivity // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            mostActiveUsers: null == mostActiveUsers
                ? _value.mostActiveUsers
                : mostActiveUsers // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserActivityReportImplCopyWith<$Res>
    implements $UserActivityReportCopyWith<$Res> {
  factory _$$UserActivityReportImplCopyWith(
    _$UserActivityReportImpl value,
    $Res Function(_$UserActivityReportImpl) then,
  ) = __$$UserActivityReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int periodDays,
    int totalActions,
    Map<String, int> actionsByType,
    List<Map<String, dynamic>> dailyActivity,
    List<Map<String, dynamic>> mostActiveUsers,
  });
}

/// @nodoc
class __$$UserActivityReportImplCopyWithImpl<$Res>
    extends _$UserActivityReportCopyWithImpl<$Res, _$UserActivityReportImpl>
    implements _$$UserActivityReportImplCopyWith<$Res> {
  __$$UserActivityReportImplCopyWithImpl(
    _$UserActivityReportImpl _value,
    $Res Function(_$UserActivityReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserActivityReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodDays = null,
    Object? totalActions = null,
    Object? actionsByType = null,
    Object? dailyActivity = null,
    Object? mostActiveUsers = null,
  }) {
    return _then(
      _$UserActivityReportImpl(
        periodDays: null == periodDays
            ? _value.periodDays
            : periodDays // ignore: cast_nullable_to_non_nullable
                  as int,
        totalActions: null == totalActions
            ? _value.totalActions
            : totalActions // ignore: cast_nullable_to_non_nullable
                  as int,
        actionsByType: null == actionsByType
            ? _value._actionsByType
            : actionsByType // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        dailyActivity: null == dailyActivity
            ? _value._dailyActivity
            : dailyActivity // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        mostActiveUsers: null == mostActiveUsers
            ? _value._mostActiveUsers
            : mostActiveUsers // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserActivityReportImpl implements _UserActivityReport {
  const _$UserActivityReportImpl({
    required this.periodDays,
    required this.totalActions,
    required final Map<String, int> actionsByType,
    required final List<Map<String, dynamic>> dailyActivity,
    required final List<Map<String, dynamic>> mostActiveUsers,
  }) : _actionsByType = actionsByType,
       _dailyActivity = dailyActivity,
       _mostActiveUsers = mostActiveUsers;

  factory _$UserActivityReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserActivityReportImplFromJson(json);

  @override
  final int periodDays;
  @override
  final int totalActions;
  final Map<String, int> _actionsByType;
  @override
  Map<String, int> get actionsByType {
    if (_actionsByType is EqualUnmodifiableMapView) return _actionsByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_actionsByType);
  }

  final List<Map<String, dynamic>> _dailyActivity;
  @override
  List<Map<String, dynamic>> get dailyActivity {
    if (_dailyActivity is EqualUnmodifiableListView) return _dailyActivity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyActivity);
  }

  final List<Map<String, dynamic>> _mostActiveUsers;
  @override
  List<Map<String, dynamic>> get mostActiveUsers {
    if (_mostActiveUsers is EqualUnmodifiableListView) return _mostActiveUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mostActiveUsers);
  }

  @override
  String toString() {
    return 'UserActivityReport(periodDays: $periodDays, totalActions: $totalActions, actionsByType: $actionsByType, dailyActivity: $dailyActivity, mostActiveUsers: $mostActiveUsers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserActivityReportImpl &&
            (identical(other.periodDays, periodDays) ||
                other.periodDays == periodDays) &&
            (identical(other.totalActions, totalActions) ||
                other.totalActions == totalActions) &&
            const DeepCollectionEquality().equals(
              other._actionsByType,
              _actionsByType,
            ) &&
            const DeepCollectionEquality().equals(
              other._dailyActivity,
              _dailyActivity,
            ) &&
            const DeepCollectionEquality().equals(
              other._mostActiveUsers,
              _mostActiveUsers,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    periodDays,
    totalActions,
    const DeepCollectionEquality().hash(_actionsByType),
    const DeepCollectionEquality().hash(_dailyActivity),
    const DeepCollectionEquality().hash(_mostActiveUsers),
  );

  /// Create a copy of UserActivityReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserActivityReportImplCopyWith<_$UserActivityReportImpl> get copyWith =>
      __$$UserActivityReportImplCopyWithImpl<_$UserActivityReportImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserActivityReportImplToJson(this);
  }
}

abstract class _UserActivityReport implements UserActivityReport {
  const factory _UserActivityReport({
    required final int periodDays,
    required final int totalActions,
    required final Map<String, int> actionsByType,
    required final List<Map<String, dynamic>> dailyActivity,
    required final List<Map<String, dynamic>> mostActiveUsers,
  }) = _$UserActivityReportImpl;

  factory _UserActivityReport.fromJson(Map<String, dynamic> json) =
      _$UserActivityReportImpl.fromJson;

  @override
  int get periodDays;
  @override
  int get totalActions;
  @override
  Map<String, int> get actionsByType;
  @override
  List<Map<String, dynamic>> get dailyActivity;
  @override
  List<Map<String, dynamic>> get mostActiveUsers;

  /// Create a copy of UserActivityReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserActivityReportImplCopyWith<_$UserActivityReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SecurityReport _$SecurityReportFromJson(Map<String, dynamic> json) {
  return _SecurityReport.fromJson(json);
}

/// @nodoc
mixin _$SecurityReport {
  int get periodDays => throw _privateConstructorUsedError;
  int get failedLoginAttempts => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get suspiciousIps =>
      throw _privateConstructorUsedError;
  int get lockedAccounts => throw _privateConstructorUsedError;
  double get twoFaAdoptionRate => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get recentSecurityEvents =>
      throw _privateConstructorUsedError;

  /// Serializes this SecurityReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SecurityReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecurityReportCopyWith<SecurityReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecurityReportCopyWith<$Res> {
  factory $SecurityReportCopyWith(
    SecurityReport value,
    $Res Function(SecurityReport) then,
  ) = _$SecurityReportCopyWithImpl<$Res, SecurityReport>;
  @useResult
  $Res call({
    int periodDays,
    int failedLoginAttempts,
    List<Map<String, dynamic>> suspiciousIps,
    int lockedAccounts,
    double twoFaAdoptionRate,
    List<Map<String, dynamic>> recentSecurityEvents,
  });
}

/// @nodoc
class _$SecurityReportCopyWithImpl<$Res, $Val extends SecurityReport>
    implements $SecurityReportCopyWith<$Res> {
  _$SecurityReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecurityReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodDays = null,
    Object? failedLoginAttempts = null,
    Object? suspiciousIps = null,
    Object? lockedAccounts = null,
    Object? twoFaAdoptionRate = null,
    Object? recentSecurityEvents = null,
  }) {
    return _then(
      _value.copyWith(
            periodDays: null == periodDays
                ? _value.periodDays
                : periodDays // ignore: cast_nullable_to_non_nullable
                      as int,
            failedLoginAttempts: null == failedLoginAttempts
                ? _value.failedLoginAttempts
                : failedLoginAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            suspiciousIps: null == suspiciousIps
                ? _value.suspiciousIps
                : suspiciousIps // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            lockedAccounts: null == lockedAccounts
                ? _value.lockedAccounts
                : lockedAccounts // ignore: cast_nullable_to_non_nullable
                      as int,
            twoFaAdoptionRate: null == twoFaAdoptionRate
                ? _value.twoFaAdoptionRate
                : twoFaAdoptionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            recentSecurityEvents: null == recentSecurityEvents
                ? _value.recentSecurityEvents
                : recentSecurityEvents // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SecurityReportImplCopyWith<$Res>
    implements $SecurityReportCopyWith<$Res> {
  factory _$$SecurityReportImplCopyWith(
    _$SecurityReportImpl value,
    $Res Function(_$SecurityReportImpl) then,
  ) = __$$SecurityReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int periodDays,
    int failedLoginAttempts,
    List<Map<String, dynamic>> suspiciousIps,
    int lockedAccounts,
    double twoFaAdoptionRate,
    List<Map<String, dynamic>> recentSecurityEvents,
  });
}

/// @nodoc
class __$$SecurityReportImplCopyWithImpl<$Res>
    extends _$SecurityReportCopyWithImpl<$Res, _$SecurityReportImpl>
    implements _$$SecurityReportImplCopyWith<$Res> {
  __$$SecurityReportImplCopyWithImpl(
    _$SecurityReportImpl _value,
    $Res Function(_$SecurityReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecurityReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodDays = null,
    Object? failedLoginAttempts = null,
    Object? suspiciousIps = null,
    Object? lockedAccounts = null,
    Object? twoFaAdoptionRate = null,
    Object? recentSecurityEvents = null,
  }) {
    return _then(
      _$SecurityReportImpl(
        periodDays: null == periodDays
            ? _value.periodDays
            : periodDays // ignore: cast_nullable_to_non_nullable
                  as int,
        failedLoginAttempts: null == failedLoginAttempts
            ? _value.failedLoginAttempts
            : failedLoginAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        suspiciousIps: null == suspiciousIps
            ? _value._suspiciousIps
            : suspiciousIps // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        lockedAccounts: null == lockedAccounts
            ? _value.lockedAccounts
            : lockedAccounts // ignore: cast_nullable_to_non_nullable
                  as int,
        twoFaAdoptionRate: null == twoFaAdoptionRate
            ? _value.twoFaAdoptionRate
            : twoFaAdoptionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        recentSecurityEvents: null == recentSecurityEvents
            ? _value._recentSecurityEvents
            : recentSecurityEvents // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SecurityReportImpl implements _SecurityReport {
  const _$SecurityReportImpl({
    required this.periodDays,
    required this.failedLoginAttempts,
    required final List<Map<String, dynamic>> suspiciousIps,
    required this.lockedAccounts,
    required this.twoFaAdoptionRate,
    required final List<Map<String, dynamic>> recentSecurityEvents,
  }) : _suspiciousIps = suspiciousIps,
       _recentSecurityEvents = recentSecurityEvents;

  factory _$SecurityReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$SecurityReportImplFromJson(json);

  @override
  final int periodDays;
  @override
  final int failedLoginAttempts;
  final List<Map<String, dynamic>> _suspiciousIps;
  @override
  List<Map<String, dynamic>> get suspiciousIps {
    if (_suspiciousIps is EqualUnmodifiableListView) return _suspiciousIps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suspiciousIps);
  }

  @override
  final int lockedAccounts;
  @override
  final double twoFaAdoptionRate;
  final List<Map<String, dynamic>> _recentSecurityEvents;
  @override
  List<Map<String, dynamic>> get recentSecurityEvents {
    if (_recentSecurityEvents is EqualUnmodifiableListView)
      return _recentSecurityEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentSecurityEvents);
  }

  @override
  String toString() {
    return 'SecurityReport(periodDays: $periodDays, failedLoginAttempts: $failedLoginAttempts, suspiciousIps: $suspiciousIps, lockedAccounts: $lockedAccounts, twoFaAdoptionRate: $twoFaAdoptionRate, recentSecurityEvents: $recentSecurityEvents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecurityReportImpl &&
            (identical(other.periodDays, periodDays) ||
                other.periodDays == periodDays) &&
            (identical(other.failedLoginAttempts, failedLoginAttempts) ||
                other.failedLoginAttempts == failedLoginAttempts) &&
            const DeepCollectionEquality().equals(
              other._suspiciousIps,
              _suspiciousIps,
            ) &&
            (identical(other.lockedAccounts, lockedAccounts) ||
                other.lockedAccounts == lockedAccounts) &&
            (identical(other.twoFaAdoptionRate, twoFaAdoptionRate) ||
                other.twoFaAdoptionRate == twoFaAdoptionRate) &&
            const DeepCollectionEquality().equals(
              other._recentSecurityEvents,
              _recentSecurityEvents,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    periodDays,
    failedLoginAttempts,
    const DeepCollectionEquality().hash(_suspiciousIps),
    lockedAccounts,
    twoFaAdoptionRate,
    const DeepCollectionEquality().hash(_recentSecurityEvents),
  );

  /// Create a copy of SecurityReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecurityReportImplCopyWith<_$SecurityReportImpl> get copyWith =>
      __$$SecurityReportImplCopyWithImpl<_$SecurityReportImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SecurityReportImplToJson(this);
  }
}

abstract class _SecurityReport implements SecurityReport {
  const factory _SecurityReport({
    required final int periodDays,
    required final int failedLoginAttempts,
    required final List<Map<String, dynamic>> suspiciousIps,
    required final int lockedAccounts,
    required final double twoFaAdoptionRate,
    required final List<Map<String, dynamic>> recentSecurityEvents,
  }) = _$SecurityReportImpl;

  factory _SecurityReport.fromJson(Map<String, dynamic> json) =
      _$SecurityReportImpl.fromJson;

  @override
  int get periodDays;
  @override
  int get failedLoginAttempts;
  @override
  List<Map<String, dynamic>> get suspiciousIps;
  @override
  int get lockedAccounts;
  @override
  double get twoFaAdoptionRate;
  @override
  List<Map<String, dynamic>> get recentSecurityEvents;

  /// Create a copy of SecurityReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecurityReportImplCopyWith<_$SecurityReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SystemHealthCheck _$SystemHealthCheckFromJson(Map<String, dynamic> json) {
  return _SystemHealthCheck.fromJson(json);
}

/// @nodoc
mixin _$SystemHealthCheck {
  String get status => throw _privateConstructorUsedError;
  Map<String, Map<String, dynamic>> get components =>
      throw _privateConstructorUsedError;
  String get uptime => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  String get lastCheck => throw _privateConstructorUsedError;

  /// Serializes this SystemHealthCheck to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemHealthCheck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemHealthCheckCopyWith<SystemHealthCheck> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemHealthCheckCopyWith<$Res> {
  factory $SystemHealthCheckCopyWith(
    SystemHealthCheck value,
    $Res Function(SystemHealthCheck) then,
  ) = _$SystemHealthCheckCopyWithImpl<$Res, SystemHealthCheck>;
  @useResult
  $Res call({
    String status,
    Map<String, Map<String, dynamic>> components,
    String uptime,
    String version,
    String lastCheck,
  });
}

/// @nodoc
class _$SystemHealthCheckCopyWithImpl<$Res, $Val extends SystemHealthCheck>
    implements $SystemHealthCheckCopyWith<$Res> {
  _$SystemHealthCheckCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemHealthCheck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? components = null,
    Object? uptime = null,
    Object? version = null,
    Object? lastCheck = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            components: null == components
                ? _value.components
                : components // ignore: cast_nullable_to_non_nullable
                      as Map<String, Map<String, dynamic>>,
            uptime: null == uptime
                ? _value.uptime
                : uptime // ignore: cast_nullable_to_non_nullable
                      as String,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
            lastCheck: null == lastCheck
                ? _value.lastCheck
                : lastCheck // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SystemHealthCheckImplCopyWith<$Res>
    implements $SystemHealthCheckCopyWith<$Res> {
  factory _$$SystemHealthCheckImplCopyWith(
    _$SystemHealthCheckImpl value,
    $Res Function(_$SystemHealthCheckImpl) then,
  ) = __$$SystemHealthCheckImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String status,
    Map<String, Map<String, dynamic>> components,
    String uptime,
    String version,
    String lastCheck,
  });
}

/// @nodoc
class __$$SystemHealthCheckImplCopyWithImpl<$Res>
    extends _$SystemHealthCheckCopyWithImpl<$Res, _$SystemHealthCheckImpl>
    implements _$$SystemHealthCheckImplCopyWith<$Res> {
  __$$SystemHealthCheckImplCopyWithImpl(
    _$SystemHealthCheckImpl _value,
    $Res Function(_$SystemHealthCheckImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SystemHealthCheck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? components = null,
    Object? uptime = null,
    Object? version = null,
    Object? lastCheck = null,
  }) {
    return _then(
      _$SystemHealthCheckImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        components: null == components
            ? _value._components
            : components // ignore: cast_nullable_to_non_nullable
                  as Map<String, Map<String, dynamic>>,
        uptime: null == uptime
            ? _value.uptime
            : uptime // ignore: cast_nullable_to_non_nullable
                  as String,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
        lastCheck: null == lastCheck
            ? _value.lastCheck
            : lastCheck // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemHealthCheckImpl implements _SystemHealthCheck {
  const _$SystemHealthCheckImpl({
    required this.status,
    required final Map<String, Map<String, dynamic>> components,
    required this.uptime,
    required this.version,
    required this.lastCheck,
  }) : _components = components;

  factory _$SystemHealthCheckImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemHealthCheckImplFromJson(json);

  @override
  final String status;
  final Map<String, Map<String, dynamic>> _components;
  @override
  Map<String, Map<String, dynamic>> get components {
    if (_components is EqualUnmodifiableMapView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_components);
  }

  @override
  final String uptime;
  @override
  final String version;
  @override
  final String lastCheck;

  @override
  String toString() {
    return 'SystemHealthCheck(status: $status, components: $components, uptime: $uptime, version: $version, lastCheck: $lastCheck)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemHealthCheckImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._components,
              _components,
            ) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.lastCheck, lastCheck) ||
                other.lastCheck == lastCheck));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    const DeepCollectionEquality().hash(_components),
    uptime,
    version,
    lastCheck,
  );

  /// Create a copy of SystemHealthCheck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemHealthCheckImplCopyWith<_$SystemHealthCheckImpl> get copyWith =>
      __$$SystemHealthCheckImplCopyWithImpl<_$SystemHealthCheckImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemHealthCheckImplToJson(this);
  }
}

abstract class _SystemHealthCheck implements SystemHealthCheck {
  const factory _SystemHealthCheck({
    required final String status,
    required final Map<String, Map<String, dynamic>> components,
    required final String uptime,
    required final String version,
    required final String lastCheck,
  }) = _$SystemHealthCheckImpl;

  factory _SystemHealthCheck.fromJson(Map<String, dynamic> json) =
      _$SystemHealthCheckImpl.fromJson;

  @override
  String get status;
  @override
  Map<String, Map<String, dynamic>> get components;
  @override
  String get uptime;
  @override
  String get version;
  @override
  String get lastCheck;

  /// Create a copy of SystemHealthCheck
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemHealthCheckImplCopyWith<_$SystemHealthCheckImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionData _$SessionDataFromJson(Map<String, dynamic> json) {
  return _SessionData.fromJson(json);
}

/// @nodoc
mixin _$SessionData {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get deviceInfo => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastActivity => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this SessionData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionDataCopyWith<SessionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionDataCopyWith<$Res> {
  factory $SessionDataCopyWith(
    SessionData value,
    $Res Function(SessionData) then,
  ) = _$SessionDataCopyWithImpl<$Res, SessionData>;
  @useResult
  $Res call({
    String id,
    String userId,
    String deviceInfo,
    String ipAddress,
    DateTime createdAt,
    DateTime lastActivity,
    bool isActive,
  });
}

/// @nodoc
class _$SessionDataCopyWithImpl<$Res, $Val extends SessionData>
    implements $SessionDataCopyWith<$Res> {
  _$SessionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? deviceInfo = null,
    Object? ipAddress = null,
    Object? createdAt = null,
    Object? lastActivity = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceInfo: null == deviceInfo
                ? _value.deviceInfo
                : deviceInfo // ignore: cast_nullable_to_non_nullable
                      as String,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastActivity: null == lastActivity
                ? _value.lastActivity
                : lastActivity // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionDataImplCopyWith<$Res>
    implements $SessionDataCopyWith<$Res> {
  factory _$$SessionDataImplCopyWith(
    _$SessionDataImpl value,
    $Res Function(_$SessionDataImpl) then,
  ) = __$$SessionDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String deviceInfo,
    String ipAddress,
    DateTime createdAt,
    DateTime lastActivity,
    bool isActive,
  });
}

/// @nodoc
class __$$SessionDataImplCopyWithImpl<$Res>
    extends _$SessionDataCopyWithImpl<$Res, _$SessionDataImpl>
    implements _$$SessionDataImplCopyWith<$Res> {
  __$$SessionDataImplCopyWithImpl(
    _$SessionDataImpl _value,
    $Res Function(_$SessionDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? deviceInfo = null,
    Object? ipAddress = null,
    Object? createdAt = null,
    Object? lastActivity = null,
    Object? isActive = null,
  }) {
    return _then(
      _$SessionDataImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceInfo: null == deviceInfo
            ? _value.deviceInfo
            : deviceInfo // ignore: cast_nullable_to_non_nullable
                  as String,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastActivity: null == lastActivity
            ? _value.lastActivity
            : lastActivity // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionDataImpl implements _SessionData {
  const _$SessionDataImpl({
    required this.id,
    required this.userId,
    required this.deviceInfo,
    required this.ipAddress,
    required this.createdAt,
    required this.lastActivity,
    required this.isActive,
  });

  factory _$SessionDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionDataImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String deviceInfo;
  @override
  final String ipAddress;
  @override
  final DateTime createdAt;
  @override
  final DateTime lastActivity;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'SessionData(id: $id, userId: $userId, deviceInfo: $deviceInfo, ipAddress: $ipAddress, createdAt: $createdAt, lastActivity: $lastActivity, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    deviceInfo,
    ipAddress,
    createdAt,
    lastActivity,
    isActive,
  );

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionDataImplCopyWith<_$SessionDataImpl> get copyWith =>
      __$$SessionDataImplCopyWithImpl<_$SessionDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionDataImplToJson(this);
  }
}

abstract class _SessionData implements SessionData {
  const factory _SessionData({
    required final String id,
    required final String userId,
    required final String deviceInfo,
    required final String ipAddress,
    required final DateTime createdAt,
    required final DateTime lastActivity,
    required final bool isActive,
  }) = _$SessionDataImpl;

  factory _SessionData.fromJson(Map<String, dynamic> json) =
      _$SessionDataImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get deviceInfo;
  @override
  String get ipAddress;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastActivity;
  @override
  bool get isActive;

  /// Create a copy of SessionData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionDataImplCopyWith<_$SessionDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuditLogEntry _$AuditLogEntryFromJson(Map<String, dynamic> json) {
  return _AuditLogEntry.fromJson(json);
}

/// @nodoc
mixin _$AuditLogEntry {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String get resourceType => throw _privateConstructorUsedError;
  String? get resourceId => throw _privateConstructorUsedError;
  Map<String, dynamic> get details => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get userEmail => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;

  /// Serializes this AuditLogEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogEntryCopyWith<AuditLogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogEntryCopyWith<$Res> {
  factory $AuditLogEntryCopyWith(
    AuditLogEntry value,
    $Res Function(AuditLogEntry) then,
  ) = _$AuditLogEntryCopyWithImpl<$Res, AuditLogEntry>;
  @useResult
  $Res call({
    String id,
    String userId,
    String action,
    String resourceType,
    String? resourceId,
    Map<String, dynamic> details,
    DateTime timestamp,
    String userEmail,
    String ipAddress,
  });
}

/// @nodoc
class _$AuditLogEntryCopyWithImpl<$Res, $Val extends AuditLogEntry>
    implements $AuditLogEntryCopyWith<$Res> {
  _$AuditLogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? action = null,
    Object? resourceType = null,
    Object? resourceId = freezed,
    Object? details = null,
    Object? timestamp = null,
    Object? userEmail = null,
    Object? ipAddress = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            resourceType: null == resourceType
                ? _value.resourceType
                : resourceType // ignore: cast_nullable_to_non_nullable
                      as String,
            resourceId: freezed == resourceId
                ? _value.resourceId
                : resourceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            details: null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userEmail: null == userEmail
                ? _value.userEmail
                : userEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuditLogEntryImplCopyWith<$Res>
    implements $AuditLogEntryCopyWith<$Res> {
  factory _$$AuditLogEntryImplCopyWith(
    _$AuditLogEntryImpl value,
    $Res Function(_$AuditLogEntryImpl) then,
  ) = __$$AuditLogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String action,
    String resourceType,
    String? resourceId,
    Map<String, dynamic> details,
    DateTime timestamp,
    String userEmail,
    String ipAddress,
  });
}

/// @nodoc
class __$$AuditLogEntryImplCopyWithImpl<$Res>
    extends _$AuditLogEntryCopyWithImpl<$Res, _$AuditLogEntryImpl>
    implements _$$AuditLogEntryImplCopyWith<$Res> {
  __$$AuditLogEntryImplCopyWithImpl(
    _$AuditLogEntryImpl _value,
    $Res Function(_$AuditLogEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? action = null,
    Object? resourceType = null,
    Object? resourceId = freezed,
    Object? details = null,
    Object? timestamp = null,
    Object? userEmail = null,
    Object? ipAddress = null,
  }) {
    return _then(
      _$AuditLogEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        resourceType: null == resourceType
            ? _value.resourceType
            : resourceType // ignore: cast_nullable_to_non_nullable
                  as String,
        resourceId: freezed == resourceId
            ? _value.resourceId
            : resourceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: null == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userEmail: null == userEmail
            ? _value.userEmail
            : userEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditLogEntryImpl implements _AuditLogEntry {
  const _$AuditLogEntryImpl({
    required this.id,
    required this.userId,
    required this.action,
    required this.resourceType,
    this.resourceId,
    required final Map<String, dynamic> details,
    required this.timestamp,
    required this.userEmail,
    required this.ipAddress,
  }) : _details = details;

  factory _$AuditLogEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditLogEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String action;
  @override
  final String resourceType;
  @override
  final String? resourceId;
  final Map<String, dynamic> _details;
  @override
  Map<String, dynamic> get details {
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_details);
  }

  @override
  final DateTime timestamp;
  @override
  final String userEmail;
  @override
  final String ipAddress;

  @override
  String toString() {
    return 'AuditLogEntry(id: $id, userId: $userId, action: $action, resourceType: $resourceType, resourceId: $resourceId, details: $details, timestamp: $timestamp, userEmail: $userEmail, ipAddress: $ipAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.resourceType, resourceType) ||
                other.resourceType == resourceType) &&
            (identical(other.resourceId, resourceId) ||
                other.resourceId == resourceId) &&
            const DeepCollectionEquality().equals(other._details, _details) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    action,
    resourceType,
    resourceId,
    const DeepCollectionEquality().hash(_details),
    timestamp,
    userEmail,
    ipAddress,
  );

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogEntryImplCopyWith<_$AuditLogEntryImpl> get copyWith =>
      __$$AuditLogEntryImplCopyWithImpl<_$AuditLogEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditLogEntryImplToJson(this);
  }
}

abstract class _AuditLogEntry implements AuditLogEntry {
  const factory _AuditLogEntry({
    required final String id,
    required final String userId,
    required final String action,
    required final String resourceType,
    final String? resourceId,
    required final Map<String, dynamic> details,
    required final DateTime timestamp,
    required final String userEmail,
    required final String ipAddress,
  }) = _$AuditLogEntryImpl;

  factory _AuditLogEntry.fromJson(Map<String, dynamic> json) =
      _$AuditLogEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get action;
  @override
  String get resourceType;
  @override
  String? get resourceId;
  @override
  Map<String, dynamic> get details;
  @override
  DateTime get timestamp;
  @override
  String get userEmail;
  @override
  String get ipAddress;

  /// Create a copy of AuditLogEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogEntryImplCopyWith<_$AuditLogEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BulkOperationResult _$BulkOperationResultFromJson(Map<String, dynamic> json) {
  return _BulkOperationResult.fromJson(json);
}

/// @nodoc
mixin _$BulkOperationResult {
  int get totalProcessed => throw _privateConstructorUsedError;
  int get successful => throw _privateConstructorUsedError;
  int get failed => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this BulkOperationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BulkOperationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BulkOperationResultCopyWith<BulkOperationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BulkOperationResultCopyWith<$Res> {
  factory $BulkOperationResultCopyWith(
    BulkOperationResult value,
    $Res Function(BulkOperationResult) then,
  ) = _$BulkOperationResultCopyWithImpl<$Res, BulkOperationResult>;
  @useResult
  $Res call({
    int totalProcessed,
    int successful,
    int failed,
    List<String> errors,
    String message,
  });
}

/// @nodoc
class _$BulkOperationResultCopyWithImpl<$Res, $Val extends BulkOperationResult>
    implements $BulkOperationResultCopyWith<$Res> {
  _$BulkOperationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BulkOperationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProcessed = null,
    Object? successful = null,
    Object? failed = null,
    Object? errors = null,
    Object? message = null,
  }) {
    return _then(
      _value.copyWith(
            totalProcessed: null == totalProcessed
                ? _value.totalProcessed
                : totalProcessed // ignore: cast_nullable_to_non_nullable
                      as int,
            successful: null == successful
                ? _value.successful
                : successful // ignore: cast_nullable_to_non_nullable
                      as int,
            failed: null == failed
                ? _value.failed
                : failed // ignore: cast_nullable_to_non_nullable
                      as int,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$BulkOperationResultImplCopyWith<$Res>
    implements $BulkOperationResultCopyWith<$Res> {
  factory _$$BulkOperationResultImplCopyWith(
    _$BulkOperationResultImpl value,
    $Res Function(_$BulkOperationResultImpl) then,
  ) = __$$BulkOperationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalProcessed,
    int successful,
    int failed,
    List<String> errors,
    String message,
  });
}

/// @nodoc
class __$$BulkOperationResultImplCopyWithImpl<$Res>
    extends _$BulkOperationResultCopyWithImpl<$Res, _$BulkOperationResultImpl>
    implements _$$BulkOperationResultImplCopyWith<$Res> {
  __$$BulkOperationResultImplCopyWithImpl(
    _$BulkOperationResultImpl _value,
    $Res Function(_$BulkOperationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BulkOperationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProcessed = null,
    Object? successful = null,
    Object? failed = null,
    Object? errors = null,
    Object? message = null,
  }) {
    return _then(
      _$BulkOperationResultImpl(
        totalProcessed: null == totalProcessed
            ? _value.totalProcessed
            : totalProcessed // ignore: cast_nullable_to_non_nullable
                  as int,
        successful: null == successful
            ? _value.successful
            : successful // ignore: cast_nullable_to_non_nullable
                  as int,
        failed: null == failed
            ? _value.failed
            : failed // ignore: cast_nullable_to_non_nullable
                  as int,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
class _$BulkOperationResultImpl implements _BulkOperationResult {
  const _$BulkOperationResultImpl({
    required this.totalProcessed,
    required this.successful,
    required this.failed,
    required final List<String> errors,
    required this.message,
  }) : _errors = errors;

  factory _$BulkOperationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$BulkOperationResultImplFromJson(json);

  @override
  final int totalProcessed;
  @override
  final int successful;
  @override
  final int failed;
  final List<String> _errors;
  @override
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  final String message;

  @override
  String toString() {
    return 'BulkOperationResult(totalProcessed: $totalProcessed, successful: $successful, failed: $failed, errors: $errors, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BulkOperationResultImpl &&
            (identical(other.totalProcessed, totalProcessed) ||
                other.totalProcessed == totalProcessed) &&
            (identical(other.successful, successful) ||
                other.successful == successful) &&
            (identical(other.failed, failed) || other.failed == failed) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalProcessed,
    successful,
    failed,
    const DeepCollectionEquality().hash(_errors),
    message,
  );

  /// Create a copy of BulkOperationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BulkOperationResultImplCopyWith<_$BulkOperationResultImpl> get copyWith =>
      __$$BulkOperationResultImplCopyWithImpl<_$BulkOperationResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BulkOperationResultImplToJson(this);
  }
}

abstract class _BulkOperationResult implements BulkOperationResult {
  const factory _BulkOperationResult({
    required final int totalProcessed,
    required final int successful,
    required final int failed,
    required final List<String> errors,
    required final String message,
  }) = _$BulkOperationResultImpl;

  factory _BulkOperationResult.fromJson(Map<String, dynamic> json) =
      _$BulkOperationResultImpl.fromJson;

  @override
  int get totalProcessed;
  @override
  int get successful;
  @override
  int get failed;
  @override
  List<String> get errors;
  @override
  String get message;

  /// Create a copy of BulkOperationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BulkOperationResultImplCopyWith<_$BulkOperationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
