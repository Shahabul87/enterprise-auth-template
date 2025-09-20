// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Device _$DeviceFromJson(Map<String, dynamic> json) {
  return _Device.fromJson(json);
}

/// @nodoc
mixin _$Device {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get deviceName => throw _privateConstructorUsedError;
  String get deviceType => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;
  String get userAgent => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get browser => throw _privateConstructorUsedError;
  String? get browserVersion => throw _privateConstructorUsedError;
  String? get os => throw _privateConstructorUsedError;
  String? get osVersion => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isTrusted => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastSeenAt => throw _privateConstructorUsedError;
  String? get deviceFingerprint => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Device to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceCopyWith<Device> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceCopyWith<$Res> {
  factory $DeviceCopyWith(Device value, $Res Function(Device) then) =
      _$DeviceCopyWithImpl<$Res, Device>;
  @useResult
  $Res call({
    String id,
    String userId,
    String deviceName,
    String deviceType,
    String platform,
    String userAgent,
    String ipAddress,
    String? location,
    String? browser,
    String? browserVersion,
    String? os,
    String? osVersion,
    bool isActive,
    bool isTrusted,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastSeenAt,
    String? deviceFingerprint,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DeviceCopyWithImpl<$Res, $Val extends Device>
    implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? deviceName = null,
    Object? deviceType = null,
    Object? platform = null,
    Object? userAgent = null,
    Object? ipAddress = null,
    Object? location = freezed,
    Object? browser = freezed,
    Object? browserVersion = freezed,
    Object? os = freezed,
    Object? osVersion = freezed,
    Object? isActive = null,
    Object? isTrusted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastSeenAt = freezed,
    Object? deviceFingerprint = freezed,
    Object? metadata = freezed,
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
            deviceName: null == deviceName
                ? _value.deviceName
                : deviceName // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceType: null == deviceType
                ? _value.deviceType
                : deviceType // ignore: cast_nullable_to_non_nullable
                      as String,
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as String,
            userAgent: null == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            browser: freezed == browser
                ? _value.browser
                : browser // ignore: cast_nullable_to_non_nullable
                      as String?,
            browserVersion: freezed == browserVersion
                ? _value.browserVersion
                : browserVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            os: freezed == os
                ? _value.os
                : os // ignore: cast_nullable_to_non_nullable
                      as String?,
            osVersion: freezed == osVersion
                ? _value.osVersion
                : osVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isTrusted: null == isTrusted
                ? _value.isTrusted
                : isTrusted // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastSeenAt: freezed == lastSeenAt
                ? _value.lastSeenAt
                : lastSeenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deviceFingerprint: freezed == deviceFingerprint
                ? _value.deviceFingerprint
                : deviceFingerprint // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceImplCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$$DeviceImplCopyWith(
    _$DeviceImpl value,
    $Res Function(_$DeviceImpl) then,
  ) = __$$DeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String deviceName,
    String deviceType,
    String platform,
    String userAgent,
    String ipAddress,
    String? location,
    String? browser,
    String? browserVersion,
    String? os,
    String? osVersion,
    bool isActive,
    bool isTrusted,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastSeenAt,
    String? deviceFingerprint,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DeviceImplCopyWithImpl<$Res>
    extends _$DeviceCopyWithImpl<$Res, _$DeviceImpl>
    implements _$$DeviceImplCopyWith<$Res> {
  __$$DeviceImplCopyWithImpl(
    _$DeviceImpl _value,
    $Res Function(_$DeviceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? deviceName = null,
    Object? deviceType = null,
    Object? platform = null,
    Object? userAgent = null,
    Object? ipAddress = null,
    Object? location = freezed,
    Object? browser = freezed,
    Object? browserVersion = freezed,
    Object? os = freezed,
    Object? osVersion = freezed,
    Object? isActive = null,
    Object? isTrusted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastSeenAt = freezed,
    Object? deviceFingerprint = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DeviceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceName: null == deviceName
            ? _value.deviceName
            : deviceName // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceType: null == deviceType
            ? _value.deviceType
            : deviceType // ignore: cast_nullable_to_non_nullable
                  as String,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as String,
        userAgent: null == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        browser: freezed == browser
            ? _value.browser
            : browser // ignore: cast_nullable_to_non_nullable
                  as String?,
        browserVersion: freezed == browserVersion
            ? _value.browserVersion
            : browserVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        os: freezed == os
            ? _value.os
            : os // ignore: cast_nullable_to_non_nullable
                  as String?,
        osVersion: freezed == osVersion
            ? _value.osVersion
            : osVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isTrusted: null == isTrusted
            ? _value.isTrusted
            : isTrusted // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastSeenAt: freezed == lastSeenAt
            ? _value.lastSeenAt
            : lastSeenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deviceFingerprint: freezed == deviceFingerprint
            ? _value.deviceFingerprint
            : deviceFingerprint // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceImpl implements _Device {
  const _$DeviceImpl({
    required this.id,
    required this.userId,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    required this.userAgent,
    required this.ipAddress,
    this.location,
    this.browser,
    this.browserVersion,
    this.os,
    this.osVersion,
    required this.isActive,
    required this.isTrusted,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeenAt,
    this.deviceFingerprint,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$DeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String deviceName;
  @override
  final String deviceType;
  @override
  final String platform;
  @override
  final String userAgent;
  @override
  final String ipAddress;
  @override
  final String? location;
  @override
  final String? browser;
  @override
  final String? browserVersion;
  @override
  final String? os;
  @override
  final String? osVersion;
  @override
  final bool isActive;
  @override
  final bool isTrusted;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? lastSeenAt;
  @override
  final String? deviceFingerprint;
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
  String toString() {
    return 'Device(id: $id, userId: $userId, deviceName: $deviceName, deviceType: $deviceType, platform: $platform, userAgent: $userAgent, ipAddress: $ipAddress, location: $location, browser: $browser, browserVersion: $browserVersion, os: $os, osVersion: $osVersion, isActive: $isActive, isTrusted: $isTrusted, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt, deviceFingerprint: $deviceFingerprint, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.browser, browser) || other.browser == browser) &&
            (identical(other.browserVersion, browserVersion) ||
                other.browserVersion == browserVersion) &&
            (identical(other.os, os) || other.os == os) &&
            (identical(other.osVersion, osVersion) ||
                other.osVersion == osVersion) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isTrusted, isTrusted) ||
                other.isTrusted == isTrusted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt) &&
            (identical(other.deviceFingerprint, deviceFingerprint) ||
                other.deviceFingerprint == deviceFingerprint) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    deviceName,
    deviceType,
    platform,
    userAgent,
    ipAddress,
    location,
    browser,
    browserVersion,
    os,
    osVersion,
    isActive,
    isTrusted,
    createdAt,
    updatedAt,
    lastSeenAt,
    deviceFingerprint,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      __$$DeviceImplCopyWithImpl<_$DeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceImplToJson(this);
  }
}

abstract class _Device implements Device {
  const factory _Device({
    required final String id,
    required final String userId,
    required final String deviceName,
    required final String deviceType,
    required final String platform,
    required final String userAgent,
    required final String ipAddress,
    final String? location,
    final String? browser,
    final String? browserVersion,
    final String? os,
    final String? osVersion,
    required final bool isActive,
    required final bool isTrusted,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? lastSeenAt,
    final String? deviceFingerprint,
    final Map<String, dynamic>? metadata,
  }) = _$DeviceImpl;

  factory _Device.fromJson(Map<String, dynamic> json) = _$DeviceImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get deviceName;
  @override
  String get deviceType;
  @override
  String get platform;
  @override
  String get userAgent;
  @override
  String get ipAddress;
  @override
  String? get location;
  @override
  String? get browser;
  @override
  String? get browserVersion;
  @override
  String? get os;
  @override
  String? get osVersion;
  @override
  bool get isActive;
  @override
  bool get isTrusted;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get lastSeenAt;
  @override
  String? get deviceFingerprint;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceRegistrationRequest _$DeviceRegistrationRequestFromJson(
  Map<String, dynamic> json,
) {
  return _DeviceRegistrationRequest.fromJson(json);
}

/// @nodoc
mixin _$DeviceRegistrationRequest {
  String get deviceName => throw _privateConstructorUsedError;
  String get deviceType => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;
  String get userAgent => throw _privateConstructorUsedError;
  String? get deviceFingerprint => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this DeviceRegistrationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceRegistrationRequestCopyWith<DeviceRegistrationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceRegistrationRequestCopyWith<$Res> {
  factory $DeviceRegistrationRequestCopyWith(
    DeviceRegistrationRequest value,
    $Res Function(DeviceRegistrationRequest) then,
  ) = _$DeviceRegistrationRequestCopyWithImpl<$Res, DeviceRegistrationRequest>;
  @useResult
  $Res call({
    String deviceName,
    String deviceType,
    String platform,
    String userAgent,
    String? deviceFingerprint,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DeviceRegistrationRequestCopyWithImpl<
  $Res,
  $Val extends DeviceRegistrationRequest
>
    implements $DeviceRegistrationRequestCopyWith<$Res> {
  _$DeviceRegistrationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceName = null,
    Object? deviceType = null,
    Object? platform = null,
    Object? userAgent = null,
    Object? deviceFingerprint = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            deviceName: null == deviceName
                ? _value.deviceName
                : deviceName // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceType: null == deviceType
                ? _value.deviceType
                : deviceType // ignore: cast_nullable_to_non_nullable
                      as String,
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as String,
            userAgent: null == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceFingerprint: freezed == deviceFingerprint
                ? _value.deviceFingerprint
                : deviceFingerprint // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceRegistrationRequestImplCopyWith<$Res>
    implements $DeviceRegistrationRequestCopyWith<$Res> {
  factory _$$DeviceRegistrationRequestImplCopyWith(
    _$DeviceRegistrationRequestImpl value,
    $Res Function(_$DeviceRegistrationRequestImpl) then,
  ) = __$$DeviceRegistrationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String deviceName,
    String deviceType,
    String platform,
    String userAgent,
    String? deviceFingerprint,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DeviceRegistrationRequestImplCopyWithImpl<$Res>
    extends
        _$DeviceRegistrationRequestCopyWithImpl<
          $Res,
          _$DeviceRegistrationRequestImpl
        >
    implements _$$DeviceRegistrationRequestImplCopyWith<$Res> {
  __$$DeviceRegistrationRequestImplCopyWithImpl(
    _$DeviceRegistrationRequestImpl _value,
    $Res Function(_$DeviceRegistrationRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceName = null,
    Object? deviceType = null,
    Object? platform = null,
    Object? userAgent = null,
    Object? deviceFingerprint = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DeviceRegistrationRequestImpl(
        deviceName: null == deviceName
            ? _value.deviceName
            : deviceName // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceType: null == deviceType
            ? _value.deviceType
            : deviceType // ignore: cast_nullable_to_non_nullable
                  as String,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as String,
        userAgent: null == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceFingerprint: freezed == deviceFingerprint
            ? _value.deviceFingerprint
            : deviceFingerprint // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceRegistrationRequestImpl implements _DeviceRegistrationRequest {
  const _$DeviceRegistrationRequestImpl({
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    required this.userAgent,
    this.deviceFingerprint,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$DeviceRegistrationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceRegistrationRequestImplFromJson(json);

  @override
  final String deviceName;
  @override
  final String deviceType;
  @override
  final String platform;
  @override
  final String userAgent;
  @override
  final String? deviceFingerprint;
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
  String toString() {
    return 'DeviceRegistrationRequest(deviceName: $deviceName, deviceType: $deviceType, platform: $platform, userAgent: $userAgent, deviceFingerprint: $deviceFingerprint, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceRegistrationRequestImpl &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.deviceFingerprint, deviceFingerprint) ||
                other.deviceFingerprint == deviceFingerprint) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deviceName,
    deviceType,
    platform,
    userAgent,
    deviceFingerprint,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DeviceRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceRegistrationRequestImplCopyWith<_$DeviceRegistrationRequestImpl>
  get copyWith =>
      __$$DeviceRegistrationRequestImplCopyWithImpl<
        _$DeviceRegistrationRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceRegistrationRequestImplToJson(this);
  }
}

abstract class _DeviceRegistrationRequest implements DeviceRegistrationRequest {
  const factory _DeviceRegistrationRequest({
    required final String deviceName,
    required final String deviceType,
    required final String platform,
    required final String userAgent,
    final String? deviceFingerprint,
    final Map<String, dynamic>? metadata,
  }) = _$DeviceRegistrationRequestImpl;

  factory _DeviceRegistrationRequest.fromJson(Map<String, dynamic> json) =
      _$DeviceRegistrationRequestImpl.fromJson;

  @override
  String get deviceName;
  @override
  String get deviceType;
  @override
  String get platform;
  @override
  String get userAgent;
  @override
  String? get deviceFingerprint;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DeviceRegistrationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceRegistrationRequestImplCopyWith<_$DeviceRegistrationRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

DeviceUpdateRequest _$DeviceUpdateRequestFromJson(Map<String, dynamic> json) {
  return _DeviceUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$DeviceUpdateRequest {
  String? get deviceName => throw _privateConstructorUsedError;
  bool? get isTrusted => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this DeviceUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceUpdateRequestCopyWith<DeviceUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceUpdateRequestCopyWith<$Res> {
  factory $DeviceUpdateRequestCopyWith(
    DeviceUpdateRequest value,
    $Res Function(DeviceUpdateRequest) then,
  ) = _$DeviceUpdateRequestCopyWithImpl<$Res, DeviceUpdateRequest>;
  @useResult
  $Res call({
    String? deviceName,
    bool? isTrusted,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DeviceUpdateRequestCopyWithImpl<$Res, $Val extends DeviceUpdateRequest>
    implements $DeviceUpdateRequestCopyWith<$Res> {
  _$DeviceUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceName = freezed,
    Object? isTrusted = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            deviceName: freezed == deviceName
                ? _value.deviceName
                : deviceName // ignore: cast_nullable_to_non_nullable
                      as String?,
            isTrusted: freezed == isTrusted
                ? _value.isTrusted
                : isTrusted // ignore: cast_nullable_to_non_nullable
                      as bool?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceUpdateRequestImplCopyWith<$Res>
    implements $DeviceUpdateRequestCopyWith<$Res> {
  factory _$$DeviceUpdateRequestImplCopyWith(
    _$DeviceUpdateRequestImpl value,
    $Res Function(_$DeviceUpdateRequestImpl) then,
  ) = __$$DeviceUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? deviceName,
    bool? isTrusted,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DeviceUpdateRequestImplCopyWithImpl<$Res>
    extends _$DeviceUpdateRequestCopyWithImpl<$Res, _$DeviceUpdateRequestImpl>
    implements _$$DeviceUpdateRequestImplCopyWith<$Res> {
  __$$DeviceUpdateRequestImplCopyWithImpl(
    _$DeviceUpdateRequestImpl _value,
    $Res Function(_$DeviceUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceName = freezed,
    Object? isTrusted = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DeviceUpdateRequestImpl(
        deviceName: freezed == deviceName
            ? _value.deviceName
            : deviceName // ignore: cast_nullable_to_non_nullable
                  as String?,
        isTrusted: freezed == isTrusted
            ? _value.isTrusted
            : isTrusted // ignore: cast_nullable_to_non_nullable
                  as bool?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceUpdateRequestImpl implements _DeviceUpdateRequest {
  const _$DeviceUpdateRequestImpl({
    this.deviceName,
    this.isTrusted,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$DeviceUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceUpdateRequestImplFromJson(json);

  @override
  final String? deviceName;
  @override
  final bool? isTrusted;
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
  String toString() {
    return 'DeviceUpdateRequest(deviceName: $deviceName, isTrusted: $isTrusted, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceUpdateRequestImpl &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.isTrusted, isTrusted) ||
                other.isTrusted == isTrusted) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deviceName,
    isTrusted,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DeviceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceUpdateRequestImplCopyWith<_$DeviceUpdateRequestImpl> get copyWith =>
      __$$DeviceUpdateRequestImplCopyWithImpl<_$DeviceUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceUpdateRequestImplToJson(this);
  }
}

abstract class _DeviceUpdateRequest implements DeviceUpdateRequest {
  const factory _DeviceUpdateRequest({
    final String? deviceName,
    final bool? isTrusted,
    final Map<String, dynamic>? metadata,
  }) = _$DeviceUpdateRequestImpl;

  factory _DeviceUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$DeviceUpdateRequestImpl.fromJson;

  @override
  String? get deviceName;
  @override
  bool? get isTrusted;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DeviceUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceUpdateRequestImplCopyWith<_$DeviceUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceListResponse _$DeviceListResponseFromJson(Map<String, dynamic> json) {
  return _DeviceListResponse.fromJson(json);
}

/// @nodoc
mixin _$DeviceListResponse {
  List<Device> get devices => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrevious => throw _privateConstructorUsedError;

  /// Serializes this DeviceListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceListResponseCopyWith<DeviceListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceListResponseCopyWith<$Res> {
  factory $DeviceListResponseCopyWith(
    DeviceListResponse value,
    $Res Function(DeviceListResponse) then,
  ) = _$DeviceListResponseCopyWithImpl<$Res, DeviceListResponse>;
  @useResult
  $Res call({
    List<Device> devices,
    int total,
    int page,
    int limit,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class _$DeviceListResponseCopyWithImpl<$Res, $Val extends DeviceListResponse>
    implements $DeviceListResponseCopyWith<$Res> {
  _$DeviceListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devices = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _value.copyWith(
            devices: null == devices
                ? _value.devices
                : devices // ignore: cast_nullable_to_non_nullable
                      as List<Device>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPrevious: null == hasPrevious
                ? _value.hasPrevious
                : hasPrevious // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceListResponseImplCopyWith<$Res>
    implements $DeviceListResponseCopyWith<$Res> {
  factory _$$DeviceListResponseImplCopyWith(
    _$DeviceListResponseImpl value,
    $Res Function(_$DeviceListResponseImpl) then,
  ) = __$$DeviceListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Device> devices,
    int total,
    int page,
    int limit,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class __$$DeviceListResponseImplCopyWithImpl<$Res>
    extends _$DeviceListResponseCopyWithImpl<$Res, _$DeviceListResponseImpl>
    implements _$$DeviceListResponseImplCopyWith<$Res> {
  __$$DeviceListResponseImplCopyWithImpl(
    _$DeviceListResponseImpl _value,
    $Res Function(_$DeviceListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devices = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _$DeviceListResponseImpl(
        devices: null == devices
            ? _value._devices
            : devices // ignore: cast_nullable_to_non_nullable
                  as List<Device>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPrevious: null == hasPrevious
            ? _value.hasPrevious
            : hasPrevious // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceListResponseImpl implements _DeviceListResponse {
  const _$DeviceListResponseImpl({
    required final List<Device> devices,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  }) : _devices = devices;

  factory _$DeviceListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceListResponseImplFromJson(json);

  final List<Device> _devices;
  @override
  List<Device> get devices {
    if (_devices is EqualUnmodifiableListView) return _devices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_devices);
  }

  @override
  final int total;
  @override
  final int page;
  @override
  final int limit;
  @override
  final bool hasNext;
  @override
  final bool hasPrevious;

  @override
  String toString() {
    return 'DeviceListResponse(devices: $devices, total: $total, page: $page, limit: $limit, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceListResponseImpl &&
            const DeepCollectionEquality().equals(other._devices, _devices) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.hasPrevious, hasPrevious) ||
                other.hasPrevious == hasPrevious));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_devices),
    total,
    page,
    limit,
    hasNext,
    hasPrevious,
  );

  /// Create a copy of DeviceListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceListResponseImplCopyWith<_$DeviceListResponseImpl> get copyWith =>
      __$$DeviceListResponseImplCopyWithImpl<_$DeviceListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceListResponseImplToJson(this);
  }
}

abstract class _DeviceListResponse implements DeviceListResponse {
  const factory _DeviceListResponse({
    required final List<Device> devices,
    required final int total,
    required final int page,
    required final int limit,
    required final bool hasNext,
    required final bool hasPrevious,
  }) = _$DeviceListResponseImpl;

  factory _DeviceListResponse.fromJson(Map<String, dynamic> json) =
      _$DeviceListResponseImpl.fromJson;

  @override
  List<Device> get devices;
  @override
  int get total;
  @override
  int get page;
  @override
  int get limit;
  @override
  bool get hasNext;
  @override
  bool get hasPrevious;

  /// Create a copy of DeviceListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceListResponseImplCopyWith<_$DeviceListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceStats _$DeviceStatsFromJson(Map<String, dynamic> json) {
  return _DeviceStats.fromJson(json);
}

/// @nodoc
mixin _$DeviceStats {
  int get totalDevices => throw _privateConstructorUsedError;
  int get activeDevices => throw _privateConstructorUsedError;
  int get trustedDevices => throw _privateConstructorUsedError;
  int get unknownDevices => throw _privateConstructorUsedError;
  Map<String, int> get devicesByPlatform => throw _privateConstructorUsedError;
  Map<String, int> get devicesByType => throw _privateConstructorUsedError;
  List<DeviceLocationStat> get topLocations =>
      throw _privateConstructorUsedError;

  /// Serializes this DeviceStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceStatsCopyWith<DeviceStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceStatsCopyWith<$Res> {
  factory $DeviceStatsCopyWith(
    DeviceStats value,
    $Res Function(DeviceStats) then,
  ) = _$DeviceStatsCopyWithImpl<$Res, DeviceStats>;
  @useResult
  $Res call({
    int totalDevices,
    int activeDevices,
    int trustedDevices,
    int unknownDevices,
    Map<String, int> devicesByPlatform,
    Map<String, int> devicesByType,
    List<DeviceLocationStat> topLocations,
  });
}

/// @nodoc
class _$DeviceStatsCopyWithImpl<$Res, $Val extends DeviceStats>
    implements $DeviceStatsCopyWith<$Res> {
  _$DeviceStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDevices = null,
    Object? activeDevices = null,
    Object? trustedDevices = null,
    Object? unknownDevices = null,
    Object? devicesByPlatform = null,
    Object? devicesByType = null,
    Object? topLocations = null,
  }) {
    return _then(
      _value.copyWith(
            totalDevices: null == totalDevices
                ? _value.totalDevices
                : totalDevices // ignore: cast_nullable_to_non_nullable
                      as int,
            activeDevices: null == activeDevices
                ? _value.activeDevices
                : activeDevices // ignore: cast_nullable_to_non_nullable
                      as int,
            trustedDevices: null == trustedDevices
                ? _value.trustedDevices
                : trustedDevices // ignore: cast_nullable_to_non_nullable
                      as int,
            unknownDevices: null == unknownDevices
                ? _value.unknownDevices
                : unknownDevices // ignore: cast_nullable_to_non_nullable
                      as int,
            devicesByPlatform: null == devicesByPlatform
                ? _value.devicesByPlatform
                : devicesByPlatform // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            devicesByType: null == devicesByType
                ? _value.devicesByType
                : devicesByType // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            topLocations: null == topLocations
                ? _value.topLocations
                : topLocations // ignore: cast_nullable_to_non_nullable
                      as List<DeviceLocationStat>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceStatsImplCopyWith<$Res>
    implements $DeviceStatsCopyWith<$Res> {
  factory _$$DeviceStatsImplCopyWith(
    _$DeviceStatsImpl value,
    $Res Function(_$DeviceStatsImpl) then,
  ) = __$$DeviceStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalDevices,
    int activeDevices,
    int trustedDevices,
    int unknownDevices,
    Map<String, int> devicesByPlatform,
    Map<String, int> devicesByType,
    List<DeviceLocationStat> topLocations,
  });
}

/// @nodoc
class __$$DeviceStatsImplCopyWithImpl<$Res>
    extends _$DeviceStatsCopyWithImpl<$Res, _$DeviceStatsImpl>
    implements _$$DeviceStatsImplCopyWith<$Res> {
  __$$DeviceStatsImplCopyWithImpl(
    _$DeviceStatsImpl _value,
    $Res Function(_$DeviceStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDevices = null,
    Object? activeDevices = null,
    Object? trustedDevices = null,
    Object? unknownDevices = null,
    Object? devicesByPlatform = null,
    Object? devicesByType = null,
    Object? topLocations = null,
  }) {
    return _then(
      _$DeviceStatsImpl(
        totalDevices: null == totalDevices
            ? _value.totalDevices
            : totalDevices // ignore: cast_nullable_to_non_nullable
                  as int,
        activeDevices: null == activeDevices
            ? _value.activeDevices
            : activeDevices // ignore: cast_nullable_to_non_nullable
                  as int,
        trustedDevices: null == trustedDevices
            ? _value.trustedDevices
            : trustedDevices // ignore: cast_nullable_to_non_nullable
                  as int,
        unknownDevices: null == unknownDevices
            ? _value.unknownDevices
            : unknownDevices // ignore: cast_nullable_to_non_nullable
                  as int,
        devicesByPlatform: null == devicesByPlatform
            ? _value._devicesByPlatform
            : devicesByPlatform // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        devicesByType: null == devicesByType
            ? _value._devicesByType
            : devicesByType // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        topLocations: null == topLocations
            ? _value._topLocations
            : topLocations // ignore: cast_nullable_to_non_nullable
                  as List<DeviceLocationStat>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceStatsImpl implements _DeviceStats {
  const _$DeviceStatsImpl({
    required this.totalDevices,
    required this.activeDevices,
    required this.trustedDevices,
    required this.unknownDevices,
    required final Map<String, int> devicesByPlatform,
    required final Map<String, int> devicesByType,
    required final List<DeviceLocationStat> topLocations,
  }) : _devicesByPlatform = devicesByPlatform,
       _devicesByType = devicesByType,
       _topLocations = topLocations;

  factory _$DeviceStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceStatsImplFromJson(json);

  @override
  final int totalDevices;
  @override
  final int activeDevices;
  @override
  final int trustedDevices;
  @override
  final int unknownDevices;
  final Map<String, int> _devicesByPlatform;
  @override
  Map<String, int> get devicesByPlatform {
    if (_devicesByPlatform is EqualUnmodifiableMapView)
      return _devicesByPlatform;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_devicesByPlatform);
  }

  final Map<String, int> _devicesByType;
  @override
  Map<String, int> get devicesByType {
    if (_devicesByType is EqualUnmodifiableMapView) return _devicesByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_devicesByType);
  }

  final List<DeviceLocationStat> _topLocations;
  @override
  List<DeviceLocationStat> get topLocations {
    if (_topLocations is EqualUnmodifiableListView) return _topLocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topLocations);
  }

  @override
  String toString() {
    return 'DeviceStats(totalDevices: $totalDevices, activeDevices: $activeDevices, trustedDevices: $trustedDevices, unknownDevices: $unknownDevices, devicesByPlatform: $devicesByPlatform, devicesByType: $devicesByType, topLocations: $topLocations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceStatsImpl &&
            (identical(other.totalDevices, totalDevices) ||
                other.totalDevices == totalDevices) &&
            (identical(other.activeDevices, activeDevices) ||
                other.activeDevices == activeDevices) &&
            (identical(other.trustedDevices, trustedDevices) ||
                other.trustedDevices == trustedDevices) &&
            (identical(other.unknownDevices, unknownDevices) ||
                other.unknownDevices == unknownDevices) &&
            const DeepCollectionEquality().equals(
              other._devicesByPlatform,
              _devicesByPlatform,
            ) &&
            const DeepCollectionEquality().equals(
              other._devicesByType,
              _devicesByType,
            ) &&
            const DeepCollectionEquality().equals(
              other._topLocations,
              _topLocations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalDevices,
    activeDevices,
    trustedDevices,
    unknownDevices,
    const DeepCollectionEquality().hash(_devicesByPlatform),
    const DeepCollectionEquality().hash(_devicesByType),
    const DeepCollectionEquality().hash(_topLocations),
  );

  /// Create a copy of DeviceStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceStatsImplCopyWith<_$DeviceStatsImpl> get copyWith =>
      __$$DeviceStatsImplCopyWithImpl<_$DeviceStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceStatsImplToJson(this);
  }
}

abstract class _DeviceStats implements DeviceStats {
  const factory _DeviceStats({
    required final int totalDevices,
    required final int activeDevices,
    required final int trustedDevices,
    required final int unknownDevices,
    required final Map<String, int> devicesByPlatform,
    required final Map<String, int> devicesByType,
    required final List<DeviceLocationStat> topLocations,
  }) = _$DeviceStatsImpl;

  factory _DeviceStats.fromJson(Map<String, dynamic> json) =
      _$DeviceStatsImpl.fromJson;

  @override
  int get totalDevices;
  @override
  int get activeDevices;
  @override
  int get trustedDevices;
  @override
  int get unknownDevices;
  @override
  Map<String, int> get devicesByPlatform;
  @override
  Map<String, int> get devicesByType;
  @override
  List<DeviceLocationStat> get topLocations;

  /// Create a copy of DeviceStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceStatsImplCopyWith<_$DeviceStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceLocationStat _$DeviceLocationStatFromJson(Map<String, dynamic> json) {
  return _DeviceLocationStat.fromJson(json);
}

/// @nodoc
mixin _$DeviceLocationStat {
  String get location => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this DeviceLocationStat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceLocationStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceLocationStatCopyWith<DeviceLocationStat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceLocationStatCopyWith<$Res> {
  factory $DeviceLocationStatCopyWith(
    DeviceLocationStat value,
    $Res Function(DeviceLocationStat) then,
  ) = _$DeviceLocationStatCopyWithImpl<$Res, DeviceLocationStat>;
  @useResult
  $Res call({String location, int count, double percentage});
}

/// @nodoc
class _$DeviceLocationStatCopyWithImpl<$Res, $Val extends DeviceLocationStat>
    implements $DeviceLocationStatCopyWith<$Res> {
  _$DeviceLocationStatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceLocationStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
    Object? count = null,
    Object? percentage = null,
  }) {
    return _then(
      _value.copyWith(
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceLocationStatImplCopyWith<$Res>
    implements $DeviceLocationStatCopyWith<$Res> {
  factory _$$DeviceLocationStatImplCopyWith(
    _$DeviceLocationStatImpl value,
    $Res Function(_$DeviceLocationStatImpl) then,
  ) = __$$DeviceLocationStatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String location, int count, double percentage});
}

/// @nodoc
class __$$DeviceLocationStatImplCopyWithImpl<$Res>
    extends _$DeviceLocationStatCopyWithImpl<$Res, _$DeviceLocationStatImpl>
    implements _$$DeviceLocationStatImplCopyWith<$Res> {
  __$$DeviceLocationStatImplCopyWithImpl(
    _$DeviceLocationStatImpl _value,
    $Res Function(_$DeviceLocationStatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceLocationStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
    Object? count = null,
    Object? percentage = null,
  }) {
    return _then(
      _$DeviceLocationStatImpl(
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceLocationStatImpl implements _DeviceLocationStat {
  const _$DeviceLocationStatImpl({
    required this.location,
    required this.count,
    required this.percentage,
  });

  factory _$DeviceLocationStatImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceLocationStatImplFromJson(json);

  @override
  final String location;
  @override
  final int count;
  @override
  final double percentage;

  @override
  String toString() {
    return 'DeviceLocationStat(location: $location, count: $count, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceLocationStatImpl &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, location, count, percentage);

  /// Create a copy of DeviceLocationStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceLocationStatImplCopyWith<_$DeviceLocationStatImpl> get copyWith =>
      __$$DeviceLocationStatImplCopyWithImpl<_$DeviceLocationStatImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceLocationStatImplToJson(this);
  }
}

abstract class _DeviceLocationStat implements DeviceLocationStat {
  const factory _DeviceLocationStat({
    required final String location,
    required final int count,
    required final double percentage,
  }) = _$DeviceLocationStatImpl;

  factory _DeviceLocationStat.fromJson(Map<String, dynamic> json) =
      _$DeviceLocationStatImpl.fromJson;

  @override
  String get location;
  @override
  int get count;
  @override
  double get percentage;

  /// Create a copy of DeviceLocationStat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceLocationStatImplCopyWith<_$DeviceLocationStatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceSecurityAlert _$DeviceSecurityAlertFromJson(Map<String, dynamic> json) {
  return _DeviceSecurityAlert.fromJson(json);
}

/// @nodoc
mixin _$DeviceSecurityAlert {
  String get id => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  String get alertType => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isResolved => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this DeviceSecurityAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceSecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceSecurityAlertCopyWith<DeviceSecurityAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceSecurityAlertCopyWith<$Res> {
  factory $DeviceSecurityAlertCopyWith(
    DeviceSecurityAlert value,
    $Res Function(DeviceSecurityAlert) then,
  ) = _$DeviceSecurityAlertCopyWithImpl<$Res, DeviceSecurityAlert>;
  @useResult
  $Res call({
    String id,
    String deviceId,
    String alertType,
    String severity,
    String message,
    DateTime createdAt,
    bool isResolved,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DeviceSecurityAlertCopyWithImpl<$Res, $Val extends DeviceSecurityAlert>
    implements $DeviceSecurityAlertCopyWith<$Res> {
  _$DeviceSecurityAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceSecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? alertType = null,
    Object? severity = null,
    Object? message = null,
    Object? createdAt = null,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            alertType: null == alertType
                ? _value.alertType
                : alertType // ignore: cast_nullable_to_non_nullable
                      as String,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isResolved: null == isResolved
                ? _value.isResolved
                : isResolved // ignore: cast_nullable_to_non_nullable
                      as bool,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceSecurityAlertImplCopyWith<$Res>
    implements $DeviceSecurityAlertCopyWith<$Res> {
  factory _$$DeviceSecurityAlertImplCopyWith(
    _$DeviceSecurityAlertImpl value,
    $Res Function(_$DeviceSecurityAlertImpl) then,
  ) = __$$DeviceSecurityAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String deviceId,
    String alertType,
    String severity,
    String message,
    DateTime createdAt,
    bool isResolved,
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DeviceSecurityAlertImplCopyWithImpl<$Res>
    extends _$DeviceSecurityAlertCopyWithImpl<$Res, _$DeviceSecurityAlertImpl>
    implements _$$DeviceSecurityAlertImplCopyWith<$Res> {
  __$$DeviceSecurityAlertImplCopyWithImpl(
    _$DeviceSecurityAlertImpl _value,
    $Res Function(_$DeviceSecurityAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceSecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? alertType = null,
    Object? severity = null,
    Object? message = null,
    Object? createdAt = null,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DeviceSecurityAlertImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        alertType: null == alertType
            ? _value.alertType
            : alertType // ignore: cast_nullable_to_non_nullable
                  as String,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isResolved: null == isResolved
            ? _value.isResolved
            : isResolved // ignore: cast_nullable_to_non_nullable
                  as bool,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceSecurityAlertImpl implements _DeviceSecurityAlert {
  const _$DeviceSecurityAlertImpl({
    required this.id,
    required this.deviceId,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.createdAt,
    required this.isResolved,
    this.resolvedAt,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$DeviceSecurityAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceSecurityAlertImplFromJson(json);

  @override
  final String id;
  @override
  final String deviceId;
  @override
  final String alertType;
  @override
  final String severity;
  @override
  final String message;
  @override
  final DateTime createdAt;
  @override
  final bool isResolved;
  @override
  final DateTime? resolvedAt;
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
  String toString() {
    return 'DeviceSecurityAlert(id: $id, deviceId: $deviceId, alertType: $alertType, severity: $severity, message: $message, createdAt: $createdAt, isResolved: $isResolved, resolvedAt: $resolvedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceSecurityAlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.alertType, alertType) ||
                other.alertType == alertType) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    deviceId,
    alertType,
    severity,
    message,
    createdAt,
    isResolved,
    resolvedAt,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DeviceSecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceSecurityAlertImplCopyWith<_$DeviceSecurityAlertImpl> get copyWith =>
      __$$DeviceSecurityAlertImplCopyWithImpl<_$DeviceSecurityAlertImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceSecurityAlertImplToJson(this);
  }
}

abstract class _DeviceSecurityAlert implements DeviceSecurityAlert {
  const factory _DeviceSecurityAlert({
    required final String id,
    required final String deviceId,
    required final String alertType,
    required final String severity,
    required final String message,
    required final DateTime createdAt,
    required final bool isResolved,
    final DateTime? resolvedAt,
    final Map<String, dynamic>? metadata,
  }) = _$DeviceSecurityAlertImpl;

  factory _DeviceSecurityAlert.fromJson(Map<String, dynamic> json) =
      _$DeviceSecurityAlertImpl.fromJson;

  @override
  String get id;
  @override
  String get deviceId;
  @override
  String get alertType;
  @override
  String get severity;
  @override
  String get message;
  @override
  DateTime get createdAt;
  @override
  bool get isResolved;
  @override
  DateTime? get resolvedAt;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DeviceSecurityAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceSecurityAlertImplCopyWith<_$DeviceSecurityAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
