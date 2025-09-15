// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_key_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApiKey _$ApiKeyFromJson(Map<String, dynamic> json) {
  return _ApiKey.fromJson(json);
}

/// @nodoc
mixin _$ApiKey {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get keyPrefix => throw _privateConstructorUsedError;
  String? get keyHash => throw _privateConstructorUsedError;
  List<String> get permissions => throw _privateConstructorUsedError;
  List<String> get scopes => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastUsedAt => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  String? get ipWhitelist => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ApiKey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyCopyWith<ApiKey> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyCopyWith<$Res> {
  factory $ApiKeyCopyWith(ApiKey value, $Res Function(ApiKey) then) =
      _$ApiKeyCopyWithImpl<$Res, ApiKey>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String keyPrefix,
    String? keyHash,
    List<String> permissions,
    List<String> scopes,
    bool isActive,
    DateTime? expiresAt,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastUsedAt,
    int usageCount,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ApiKeyCopyWithImpl<$Res, $Val extends ApiKey>
    implements $ApiKeyCopyWith<$Res> {
  _$ApiKeyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? keyPrefix = null,
    Object? keyHash = freezed,
    Object? permissions = null,
    Object? scopes = null,
    Object? isActive = null,
    Object? expiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastUsedAt = freezed,
    Object? usageCount = null,
    Object? ipWhitelist = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            keyPrefix: null == keyPrefix
                ? _value.keyPrefix
                : keyPrefix // ignore: cast_nullable_to_non_nullable
                      as String,
            keyHash: freezed == keyHash
                ? _value.keyHash
                : keyHash // ignore: cast_nullable_to_non_nullable
                      as String?,
            permissions: null == permissions
                ? _value.permissions
                : permissions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            scopes: null == scopes
                ? _value.scopes
                : scopes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastUsedAt: freezed == lastUsedAt
                ? _value.lastUsedAt
                : lastUsedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            usageCount: null == usageCount
                ? _value.usageCount
                : usageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            ipWhitelist: freezed == ipWhitelist
                ? _value.ipWhitelist
                : ipWhitelist // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ApiKeyImplCopyWith<$Res> implements $ApiKeyCopyWith<$Res> {
  factory _$$ApiKeyImplCopyWith(
    _$ApiKeyImpl value,
    $Res Function(_$ApiKeyImpl) then,
  ) = __$$ApiKeyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String keyPrefix,
    String? keyHash,
    List<String> permissions,
    List<String> scopes,
    bool isActive,
    DateTime? expiresAt,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastUsedAt,
    int usageCount,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ApiKeyImplCopyWithImpl<$Res>
    extends _$ApiKeyCopyWithImpl<$Res, _$ApiKeyImpl>
    implements _$$ApiKeyImplCopyWith<$Res> {
  __$$ApiKeyImplCopyWithImpl(
    _$ApiKeyImpl _value,
    $Res Function(_$ApiKeyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? keyPrefix = null,
    Object? keyHash = freezed,
    Object? permissions = null,
    Object? scopes = null,
    Object? isActive = null,
    Object? expiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastUsedAt = freezed,
    Object? usageCount = null,
    Object? ipWhitelist = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ApiKeyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        keyPrefix: null == keyPrefix
            ? _value.keyPrefix
            : keyPrefix // ignore: cast_nullable_to_non_nullable
                  as String,
        keyHash: freezed == keyHash
            ? _value.keyHash
            : keyHash // ignore: cast_nullable_to_non_nullable
                  as String?,
        permissions: null == permissions
            ? _value._permissions
            : permissions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        scopes: null == scopes
            ? _value._scopes
            : scopes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastUsedAt: freezed == lastUsedAt
            ? _value.lastUsedAt
            : lastUsedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        usageCount: null == usageCount
            ? _value.usageCount
            : usageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        ipWhitelist: freezed == ipWhitelist
            ? _value.ipWhitelist
            : ipWhitelist // ignore: cast_nullable_to_non_nullable
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
class _$ApiKeyImpl implements _ApiKey {
  const _$ApiKeyImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.keyPrefix,
    this.keyHash,
    required final List<String> permissions,
    required final List<String> scopes,
    required this.isActive,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastUsedAt,
    required this.usageCount,
    this.ipWhitelist,
    final Map<String, dynamic>? metadata,
  }) : _permissions = permissions,
       _scopes = scopes,
       _metadata = metadata;

  factory _$ApiKeyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String keyPrefix;
  @override
  final String? keyHash;
  final List<String> _permissions;
  @override
  List<String> get permissions {
    if (_permissions is EqualUnmodifiableListView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_permissions);
  }

  final List<String> _scopes;
  @override
  List<String> get scopes {
    if (_scopes is EqualUnmodifiableListView) return _scopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scopes);
  }

  @override
  final bool isActive;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? lastUsedAt;
  @override
  final int usageCount;
  @override
  final String? ipWhitelist;
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
    return 'ApiKey(id: $id, name: $name, description: $description, keyPrefix: $keyPrefix, keyHash: $keyHash, permissions: $permissions, scopes: $scopes, isActive: $isActive, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, lastUsedAt: $lastUsedAt, usageCount: $usageCount, ipWhitelist: $ipWhitelist, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.keyPrefix, keyPrefix) ||
                other.keyPrefix == keyPrefix) &&
            (identical(other.keyHash, keyHash) || other.keyHash == keyHash) &&
            const DeepCollectionEquality().equals(
              other._permissions,
              _permissions,
            ) &&
            const DeepCollectionEquality().equals(other._scopes, _scopes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.ipWhitelist, ipWhitelist) ||
                other.ipWhitelist == ipWhitelist) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    keyPrefix,
    keyHash,
    const DeepCollectionEquality().hash(_permissions),
    const DeepCollectionEquality().hash(_scopes),
    isActive,
    expiresAt,
    createdAt,
    updatedAt,
    lastUsedAt,
    usageCount,
    ipWhitelist,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyImplCopyWith<_$ApiKeyImpl> get copyWith =>
      __$$ApiKeyImplCopyWithImpl<_$ApiKeyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyImplToJson(this);
  }
}

abstract class _ApiKey implements ApiKey {
  const factory _ApiKey({
    required final String id,
    required final String name,
    required final String description,
    required final String keyPrefix,
    final String? keyHash,
    required final List<String> permissions,
    required final List<String> scopes,
    required final bool isActive,
    final DateTime? expiresAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? lastUsedAt,
    required final int usageCount,
    final String? ipWhitelist,
    final Map<String, dynamic>? metadata,
  }) = _$ApiKeyImpl;

  factory _ApiKey.fromJson(Map<String, dynamic> json) = _$ApiKeyImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get keyPrefix;
  @override
  String? get keyHash;
  @override
  List<String> get permissions;
  @override
  List<String> get scopes;
  @override
  bool get isActive;
  @override
  DateTime? get expiresAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get lastUsedAt;
  @override
  int get usageCount;
  @override
  String? get ipWhitelist;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyImplCopyWith<_$ApiKeyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiKeyCreateRequest _$ApiKeyCreateRequestFromJson(Map<String, dynamic> json) {
  return _ApiKeyCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get permissions => throw _privateConstructorUsedError;
  List<String> get scopes => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String? get ipWhitelist => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyCreateRequestCopyWith<ApiKeyCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyCreateRequestCopyWith<$Res> {
  factory $ApiKeyCreateRequestCopyWith(
    ApiKeyCreateRequest value,
    $Res Function(ApiKeyCreateRequest) then,
  ) = _$ApiKeyCreateRequestCopyWithImpl<$Res, ApiKeyCreateRequest>;
  @useResult
  $Res call({
    String name,
    String description,
    List<String> permissions,
    List<String> scopes,
    DateTime? expiresAt,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ApiKeyCreateRequestCopyWithImpl<$Res, $Val extends ApiKeyCreateRequest>
    implements $ApiKeyCreateRequestCopyWith<$Res> {
  _$ApiKeyCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? permissions = null,
    Object? scopes = null,
    Object? expiresAt = freezed,
    Object? ipWhitelist = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            permissions: null == permissions
                ? _value.permissions
                : permissions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            scopes: null == scopes
                ? _value.scopes
                : scopes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ipWhitelist: freezed == ipWhitelist
                ? _value.ipWhitelist
                : ipWhitelist // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ApiKeyCreateRequestImplCopyWith<$Res>
    implements $ApiKeyCreateRequestCopyWith<$Res> {
  factory _$$ApiKeyCreateRequestImplCopyWith(
    _$ApiKeyCreateRequestImpl value,
    $Res Function(_$ApiKeyCreateRequestImpl) then,
  ) = __$$ApiKeyCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String description,
    List<String> permissions,
    List<String> scopes,
    DateTime? expiresAt,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ApiKeyCreateRequestImplCopyWithImpl<$Res>
    extends _$ApiKeyCreateRequestCopyWithImpl<$Res, _$ApiKeyCreateRequestImpl>
    implements _$$ApiKeyCreateRequestImplCopyWith<$Res> {
  __$$ApiKeyCreateRequestImplCopyWithImpl(
    _$ApiKeyCreateRequestImpl _value,
    $Res Function(_$ApiKeyCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? permissions = null,
    Object? scopes = null,
    Object? expiresAt = freezed,
    Object? ipWhitelist = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ApiKeyCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        permissions: null == permissions
            ? _value._permissions
            : permissions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        scopes: null == scopes
            ? _value._scopes
            : scopes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ipWhitelist: freezed == ipWhitelist
            ? _value.ipWhitelist
            : ipWhitelist // ignore: cast_nullable_to_non_nullable
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
class _$ApiKeyCreateRequestImpl implements _ApiKeyCreateRequest {
  const _$ApiKeyCreateRequestImpl({
    required this.name,
    required this.description,
    required final List<String> permissions,
    required final List<String> scopes,
    this.expiresAt,
    this.ipWhitelist,
    final Map<String, dynamic>? metadata,
  }) : _permissions = permissions,
       _scopes = scopes,
       _metadata = metadata;

  factory _$ApiKeyCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  final List<String> _permissions;
  @override
  List<String> get permissions {
    if (_permissions is EqualUnmodifiableListView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_permissions);
  }

  final List<String> _scopes;
  @override
  List<String> get scopes {
    if (_scopes is EqualUnmodifiableListView) return _scopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scopes);
  }

  @override
  final DateTime? expiresAt;
  @override
  final String? ipWhitelist;
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
    return 'ApiKeyCreateRequest(name: $name, description: $description, permissions: $permissions, scopes: $scopes, expiresAt: $expiresAt, ipWhitelist: $ipWhitelist, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._permissions,
              _permissions,
            ) &&
            const DeepCollectionEquality().equals(other._scopes, _scopes) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.ipWhitelist, ipWhitelist) ||
                other.ipWhitelist == ipWhitelist) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    const DeepCollectionEquality().hash(_permissions),
    const DeepCollectionEquality().hash(_scopes),
    expiresAt,
    ipWhitelist,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ApiKeyCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyCreateRequestImplCopyWith<_$ApiKeyCreateRequestImpl> get copyWith =>
      __$$ApiKeyCreateRequestImplCopyWithImpl<_$ApiKeyCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyCreateRequestImplToJson(this);
  }
}

abstract class _ApiKeyCreateRequest implements ApiKeyCreateRequest {
  const factory _ApiKeyCreateRequest({
    required final String name,
    required final String description,
    required final List<String> permissions,
    required final List<String> scopes,
    final DateTime? expiresAt,
    final String? ipWhitelist,
    final Map<String, dynamic>? metadata,
  }) = _$ApiKeyCreateRequestImpl;

  factory _ApiKeyCreateRequest.fromJson(Map<String, dynamic> json) =
      _$ApiKeyCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  List<String> get permissions;
  @override
  List<String> get scopes;
  @override
  DateTime? get expiresAt;
  @override
  String? get ipWhitelist;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ApiKeyCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyCreateRequestImplCopyWith<_$ApiKeyCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiKeyUpdateRequest _$ApiKeyUpdateRequestFromJson(Map<String, dynamic> json) {
  return _ApiKeyUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyUpdateRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String>? get permissions => throw _privateConstructorUsedError;
  List<String>? get scopes => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String? get ipWhitelist => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyUpdateRequestCopyWith<ApiKeyUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyUpdateRequestCopyWith<$Res> {
  factory $ApiKeyUpdateRequestCopyWith(
    ApiKeyUpdateRequest value,
    $Res Function(ApiKeyUpdateRequest) then,
  ) = _$ApiKeyUpdateRequestCopyWithImpl<$Res, ApiKeyUpdateRequest>;
  @useResult
  $Res call({
    String? name,
    String? description,
    List<String>? permissions,
    List<String>? scopes,
    bool? isActive,
    DateTime? expiresAt,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ApiKeyUpdateRequestCopyWithImpl<$Res, $Val extends ApiKeyUpdateRequest>
    implements $ApiKeyUpdateRequestCopyWith<$Res> {
  _$ApiKeyUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? permissions = freezed,
    Object? scopes = freezed,
    Object? isActive = freezed,
    Object? expiresAt = freezed,
    Object? ipWhitelist = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            permissions: freezed == permissions
                ? _value.permissions
                : permissions // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            scopes: freezed == scopes
                ? _value.scopes
                : scopes // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ipWhitelist: freezed == ipWhitelist
                ? _value.ipWhitelist
                : ipWhitelist // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ApiKeyUpdateRequestImplCopyWith<$Res>
    implements $ApiKeyUpdateRequestCopyWith<$Res> {
  factory _$$ApiKeyUpdateRequestImplCopyWith(
    _$ApiKeyUpdateRequestImpl value,
    $Res Function(_$ApiKeyUpdateRequestImpl) then,
  ) = __$$ApiKeyUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? description,
    List<String>? permissions,
    List<String>? scopes,
    bool? isActive,
    DateTime? expiresAt,
    String? ipWhitelist,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ApiKeyUpdateRequestImplCopyWithImpl<$Res>
    extends _$ApiKeyUpdateRequestCopyWithImpl<$Res, _$ApiKeyUpdateRequestImpl>
    implements _$$ApiKeyUpdateRequestImplCopyWith<$Res> {
  __$$ApiKeyUpdateRequestImplCopyWithImpl(
    _$ApiKeyUpdateRequestImpl _value,
    $Res Function(_$ApiKeyUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? permissions = freezed,
    Object? scopes = freezed,
    Object? isActive = freezed,
    Object? expiresAt = freezed,
    Object? ipWhitelist = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ApiKeyUpdateRequestImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        permissions: freezed == permissions
            ? _value._permissions
            : permissions // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        scopes: freezed == scopes
            ? _value._scopes
            : scopes // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ipWhitelist: freezed == ipWhitelist
            ? _value.ipWhitelist
            : ipWhitelist // ignore: cast_nullable_to_non_nullable
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
class _$ApiKeyUpdateRequestImpl implements _ApiKeyUpdateRequest {
  const _$ApiKeyUpdateRequestImpl({
    this.name,
    this.description,
    final List<String>? permissions,
    final List<String>? scopes,
    this.isActive,
    this.expiresAt,
    this.ipWhitelist,
    final Map<String, dynamic>? metadata,
  }) : _permissions = permissions,
       _scopes = scopes,
       _metadata = metadata;

  factory _$ApiKeyUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyUpdateRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  final List<String>? _permissions;
  @override
  List<String>? get permissions {
    final value = _permissions;
    if (value == null) return null;
    if (_permissions is EqualUnmodifiableListView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _scopes;
  @override
  List<String>? get scopes {
    final value = _scopes;
    if (value == null) return null;
    if (_scopes is EqualUnmodifiableListView) return _scopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isActive;
  @override
  final DateTime? expiresAt;
  @override
  final String? ipWhitelist;
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
    return 'ApiKeyUpdateRequest(name: $name, description: $description, permissions: $permissions, scopes: $scopes, isActive: $isActive, expiresAt: $expiresAt, ipWhitelist: $ipWhitelist, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyUpdateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._permissions,
              _permissions,
            ) &&
            const DeepCollectionEquality().equals(other._scopes, _scopes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.ipWhitelist, ipWhitelist) ||
                other.ipWhitelist == ipWhitelist) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    const DeepCollectionEquality().hash(_permissions),
    const DeepCollectionEquality().hash(_scopes),
    isActive,
    expiresAt,
    ipWhitelist,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ApiKeyUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyUpdateRequestImplCopyWith<_$ApiKeyUpdateRequestImpl> get copyWith =>
      __$$ApiKeyUpdateRequestImplCopyWithImpl<_$ApiKeyUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyUpdateRequestImplToJson(this);
  }
}

abstract class _ApiKeyUpdateRequest implements ApiKeyUpdateRequest {
  const factory _ApiKeyUpdateRequest({
    final String? name,
    final String? description,
    final List<String>? permissions,
    final List<String>? scopes,
    final bool? isActive,
    final DateTime? expiresAt,
    final String? ipWhitelist,
    final Map<String, dynamic>? metadata,
  }) = _$ApiKeyUpdateRequestImpl;

  factory _ApiKeyUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$ApiKeyUpdateRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  List<String>? get permissions;
  @override
  List<String>? get scopes;
  @override
  bool? get isActive;
  @override
  DateTime? get expiresAt;
  @override
  String? get ipWhitelist;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ApiKeyUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyUpdateRequestImplCopyWith<_$ApiKeyUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiKeyCreateResponse _$ApiKeyCreateResponseFromJson(Map<String, dynamic> json) {
  return _ApiKeyCreateResponse.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyCreateResponse {
  ApiKey get apiKey => throw _privateConstructorUsedError;
  String get plainTextKey => throw _privateConstructorUsedError;
  String get warning => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyCreateResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyCreateResponseCopyWith<ApiKeyCreateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyCreateResponseCopyWith<$Res> {
  factory $ApiKeyCreateResponseCopyWith(
    ApiKeyCreateResponse value,
    $Res Function(ApiKeyCreateResponse) then,
  ) = _$ApiKeyCreateResponseCopyWithImpl<$Res, ApiKeyCreateResponse>;
  @useResult
  $Res call({ApiKey apiKey, String plainTextKey, String warning});

  $ApiKeyCopyWith<$Res> get apiKey;
}

/// @nodoc
class _$ApiKeyCreateResponseCopyWithImpl<
  $Res,
  $Val extends ApiKeyCreateResponse
>
    implements $ApiKeyCreateResponseCopyWith<$Res> {
  _$ApiKeyCreateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKey = null,
    Object? plainTextKey = null,
    Object? warning = null,
  }) {
    return _then(
      _value.copyWith(
            apiKey: null == apiKey
                ? _value.apiKey
                : apiKey // ignore: cast_nullable_to_non_nullable
                      as ApiKey,
            plainTextKey: null == plainTextKey
                ? _value.plainTextKey
                : plainTextKey // ignore: cast_nullable_to_non_nullable
                      as String,
            warning: null == warning
                ? _value.warning
                : warning // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ApiKeyCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ApiKeyCopyWith<$Res> get apiKey {
    return $ApiKeyCopyWith<$Res>(_value.apiKey, (value) {
      return _then(_value.copyWith(apiKey: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApiKeyCreateResponseImplCopyWith<$Res>
    implements $ApiKeyCreateResponseCopyWith<$Res> {
  factory _$$ApiKeyCreateResponseImplCopyWith(
    _$ApiKeyCreateResponseImpl value,
    $Res Function(_$ApiKeyCreateResponseImpl) then,
  ) = __$$ApiKeyCreateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ApiKey apiKey, String plainTextKey, String warning});

  @override
  $ApiKeyCopyWith<$Res> get apiKey;
}

/// @nodoc
class __$$ApiKeyCreateResponseImplCopyWithImpl<$Res>
    extends _$ApiKeyCreateResponseCopyWithImpl<$Res, _$ApiKeyCreateResponseImpl>
    implements _$$ApiKeyCreateResponseImplCopyWith<$Res> {
  __$$ApiKeyCreateResponseImplCopyWithImpl(
    _$ApiKeyCreateResponseImpl _value,
    $Res Function(_$ApiKeyCreateResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKey = null,
    Object? plainTextKey = null,
    Object? warning = null,
  }) {
    return _then(
      _$ApiKeyCreateResponseImpl(
        apiKey: null == apiKey
            ? _value.apiKey
            : apiKey // ignore: cast_nullable_to_non_nullable
                  as ApiKey,
        plainTextKey: null == plainTextKey
            ? _value.plainTextKey
            : plainTextKey // ignore: cast_nullable_to_non_nullable
                  as String,
        warning: null == warning
            ? _value.warning
            : warning // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiKeyCreateResponseImpl implements _ApiKeyCreateResponse {
  const _$ApiKeyCreateResponseImpl({
    required this.apiKey,
    required this.plainTextKey,
    required this.warning,
  });

  factory _$ApiKeyCreateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyCreateResponseImplFromJson(json);

  @override
  final ApiKey apiKey;
  @override
  final String plainTextKey;
  @override
  final String warning;

  @override
  String toString() {
    return 'ApiKeyCreateResponse(apiKey: $apiKey, plainTextKey: $plainTextKey, warning: $warning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyCreateResponseImpl &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.plainTextKey, plainTextKey) ||
                other.plainTextKey == plainTextKey) &&
            (identical(other.warning, warning) || other.warning == warning));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, apiKey, plainTextKey, warning);

  /// Create a copy of ApiKeyCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyCreateResponseImplCopyWith<_$ApiKeyCreateResponseImpl>
  get copyWith =>
      __$$ApiKeyCreateResponseImplCopyWithImpl<_$ApiKeyCreateResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyCreateResponseImplToJson(this);
  }
}

abstract class _ApiKeyCreateResponse implements ApiKeyCreateResponse {
  const factory _ApiKeyCreateResponse({
    required final ApiKey apiKey,
    required final String plainTextKey,
    required final String warning,
  }) = _$ApiKeyCreateResponseImpl;

  factory _ApiKeyCreateResponse.fromJson(Map<String, dynamic> json) =
      _$ApiKeyCreateResponseImpl.fromJson;

  @override
  ApiKey get apiKey;
  @override
  String get plainTextKey;
  @override
  String get warning;

  /// Create a copy of ApiKeyCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyCreateResponseImplCopyWith<_$ApiKeyCreateResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ApiKeyListResponse _$ApiKeyListResponseFromJson(Map<String, dynamic> json) {
  return _ApiKeyListResponse.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyListResponse {
  List<ApiKey> get apiKeys => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrevious => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyListResponseCopyWith<ApiKeyListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyListResponseCopyWith<$Res> {
  factory $ApiKeyListResponseCopyWith(
    ApiKeyListResponse value,
    $Res Function(ApiKeyListResponse) then,
  ) = _$ApiKeyListResponseCopyWithImpl<$Res, ApiKeyListResponse>;
  @useResult
  $Res call({
    List<ApiKey> apiKeys,
    int total,
    int page,
    int limit,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class _$ApiKeyListResponseCopyWithImpl<$Res, $Val extends ApiKeyListResponse>
    implements $ApiKeyListResponseCopyWith<$Res> {
  _$ApiKeyListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKeys = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _value.copyWith(
            apiKeys: null == apiKeys
                ? _value.apiKeys
                : apiKeys // ignore: cast_nullable_to_non_nullable
                      as List<ApiKey>,
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
abstract class _$$ApiKeyListResponseImplCopyWith<$Res>
    implements $ApiKeyListResponseCopyWith<$Res> {
  factory _$$ApiKeyListResponseImplCopyWith(
    _$ApiKeyListResponseImpl value,
    $Res Function(_$ApiKeyListResponseImpl) then,
  ) = __$$ApiKeyListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ApiKey> apiKeys,
    int total,
    int page,
    int limit,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class __$$ApiKeyListResponseImplCopyWithImpl<$Res>
    extends _$ApiKeyListResponseCopyWithImpl<$Res, _$ApiKeyListResponseImpl>
    implements _$$ApiKeyListResponseImplCopyWith<$Res> {
  __$$ApiKeyListResponseImplCopyWithImpl(
    _$ApiKeyListResponseImpl _value,
    $Res Function(_$ApiKeyListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKeys = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _$ApiKeyListResponseImpl(
        apiKeys: null == apiKeys
            ? _value._apiKeys
            : apiKeys // ignore: cast_nullable_to_non_nullable
                  as List<ApiKey>,
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
class _$ApiKeyListResponseImpl implements _ApiKeyListResponse {
  const _$ApiKeyListResponseImpl({
    required final List<ApiKey> apiKeys,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  }) : _apiKeys = apiKeys;

  factory _$ApiKeyListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyListResponseImplFromJson(json);

  final List<ApiKey> _apiKeys;
  @override
  List<ApiKey> get apiKeys {
    if (_apiKeys is EqualUnmodifiableListView) return _apiKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_apiKeys);
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
    return 'ApiKeyListResponse(apiKeys: $apiKeys, total: $total, page: $page, limit: $limit, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyListResponseImpl &&
            const DeepCollectionEquality().equals(other._apiKeys, _apiKeys) &&
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
    const DeepCollectionEquality().hash(_apiKeys),
    total,
    page,
    limit,
    hasNext,
    hasPrevious,
  );

  /// Create a copy of ApiKeyListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyListResponseImplCopyWith<_$ApiKeyListResponseImpl> get copyWith =>
      __$$ApiKeyListResponseImplCopyWithImpl<_$ApiKeyListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyListResponseImplToJson(this);
  }
}

abstract class _ApiKeyListResponse implements ApiKeyListResponse {
  const factory _ApiKeyListResponse({
    required final List<ApiKey> apiKeys,
    required final int total,
    required final int page,
    required final int limit,
    required final bool hasNext,
    required final bool hasPrevious,
  }) = _$ApiKeyListResponseImpl;

  factory _ApiKeyListResponse.fromJson(Map<String, dynamic> json) =
      _$ApiKeyListResponseImpl.fromJson;

  @override
  List<ApiKey> get apiKeys;
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

  /// Create a copy of ApiKeyListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyListResponseImplCopyWith<_$ApiKeyListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiKeyUsageStats _$ApiKeyUsageStatsFromJson(Map<String, dynamic> json) {
  return _ApiKeyUsageStats.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyUsageStats {
  String get apiKeyId => throw _privateConstructorUsedError;
  int get totalRequests => throw _privateConstructorUsedError;
  int get successfulRequests => throw _privateConstructorUsedError;
  int get failedRequests => throw _privateConstructorUsedError;
  Map<String, int> get requestsByEndpoint => throw _privateConstructorUsedError;
  Map<String, int> get requestsByDay => throw _privateConstructorUsedError;
  DateTime get lastUsed => throw _privateConstructorUsedError;
  double get averageResponseTime => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyUsageStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyUsageStatsCopyWith<ApiKeyUsageStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyUsageStatsCopyWith<$Res> {
  factory $ApiKeyUsageStatsCopyWith(
    ApiKeyUsageStats value,
    $Res Function(ApiKeyUsageStats) then,
  ) = _$ApiKeyUsageStatsCopyWithImpl<$Res, ApiKeyUsageStats>;
  @useResult
  $Res call({
    String apiKeyId,
    int totalRequests,
    int successfulRequests,
    int failedRequests,
    Map<String, int> requestsByEndpoint,
    Map<String, int> requestsByDay,
    DateTime lastUsed,
    double averageResponseTime,
  });
}

/// @nodoc
class _$ApiKeyUsageStatsCopyWithImpl<$Res, $Val extends ApiKeyUsageStats>
    implements $ApiKeyUsageStatsCopyWith<$Res> {
  _$ApiKeyUsageStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKeyId = null,
    Object? totalRequests = null,
    Object? successfulRequests = null,
    Object? failedRequests = null,
    Object? requestsByEndpoint = null,
    Object? requestsByDay = null,
    Object? lastUsed = null,
    Object? averageResponseTime = null,
  }) {
    return _then(
      _value.copyWith(
            apiKeyId: null == apiKeyId
                ? _value.apiKeyId
                : apiKeyId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalRequests: null == totalRequests
                ? _value.totalRequests
                : totalRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            successfulRequests: null == successfulRequests
                ? _value.successfulRequests
                : successfulRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            failedRequests: null == failedRequests
                ? _value.failedRequests
                : failedRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            requestsByEndpoint: null == requestsByEndpoint
                ? _value.requestsByEndpoint
                : requestsByEndpoint // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            requestsByDay: null == requestsByDay
                ? _value.requestsByDay
                : requestsByDay // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            lastUsed: null == lastUsed
                ? _value.lastUsed
                : lastUsed // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            averageResponseTime: null == averageResponseTime
                ? _value.averageResponseTime
                : averageResponseTime // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiKeyUsageStatsImplCopyWith<$Res>
    implements $ApiKeyUsageStatsCopyWith<$Res> {
  factory _$$ApiKeyUsageStatsImplCopyWith(
    _$ApiKeyUsageStatsImpl value,
    $Res Function(_$ApiKeyUsageStatsImpl) then,
  ) = __$$ApiKeyUsageStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String apiKeyId,
    int totalRequests,
    int successfulRequests,
    int failedRequests,
    Map<String, int> requestsByEndpoint,
    Map<String, int> requestsByDay,
    DateTime lastUsed,
    double averageResponseTime,
  });
}

/// @nodoc
class __$$ApiKeyUsageStatsImplCopyWithImpl<$Res>
    extends _$ApiKeyUsageStatsCopyWithImpl<$Res, _$ApiKeyUsageStatsImpl>
    implements _$$ApiKeyUsageStatsImplCopyWith<$Res> {
  __$$ApiKeyUsageStatsImplCopyWithImpl(
    _$ApiKeyUsageStatsImpl _value,
    $Res Function(_$ApiKeyUsageStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKeyId = null,
    Object? totalRequests = null,
    Object? successfulRequests = null,
    Object? failedRequests = null,
    Object? requestsByEndpoint = null,
    Object? requestsByDay = null,
    Object? lastUsed = null,
    Object? averageResponseTime = null,
  }) {
    return _then(
      _$ApiKeyUsageStatsImpl(
        apiKeyId: null == apiKeyId
            ? _value.apiKeyId
            : apiKeyId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalRequests: null == totalRequests
            ? _value.totalRequests
            : totalRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        successfulRequests: null == successfulRequests
            ? _value.successfulRequests
            : successfulRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        failedRequests: null == failedRequests
            ? _value.failedRequests
            : failedRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        requestsByEndpoint: null == requestsByEndpoint
            ? _value._requestsByEndpoint
            : requestsByEndpoint // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        requestsByDay: null == requestsByDay
            ? _value._requestsByDay
            : requestsByDay // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        lastUsed: null == lastUsed
            ? _value.lastUsed
            : lastUsed // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        averageResponseTime: null == averageResponseTime
            ? _value.averageResponseTime
            : averageResponseTime // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiKeyUsageStatsImpl implements _ApiKeyUsageStats {
  const _$ApiKeyUsageStatsImpl({
    required this.apiKeyId,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required final Map<String, int> requestsByEndpoint,
    required final Map<String, int> requestsByDay,
    required this.lastUsed,
    required this.averageResponseTime,
  }) : _requestsByEndpoint = requestsByEndpoint,
       _requestsByDay = requestsByDay;

  factory _$ApiKeyUsageStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyUsageStatsImplFromJson(json);

  @override
  final String apiKeyId;
  @override
  final int totalRequests;
  @override
  final int successfulRequests;
  @override
  final int failedRequests;
  final Map<String, int> _requestsByEndpoint;
  @override
  Map<String, int> get requestsByEndpoint {
    if (_requestsByEndpoint is EqualUnmodifiableMapView)
      return _requestsByEndpoint;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_requestsByEndpoint);
  }

  final Map<String, int> _requestsByDay;
  @override
  Map<String, int> get requestsByDay {
    if (_requestsByDay is EqualUnmodifiableMapView) return _requestsByDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_requestsByDay);
  }

  @override
  final DateTime lastUsed;
  @override
  final double averageResponseTime;

  @override
  String toString() {
    return 'ApiKeyUsageStats(apiKeyId: $apiKeyId, totalRequests: $totalRequests, successfulRequests: $successfulRequests, failedRequests: $failedRequests, requestsByEndpoint: $requestsByEndpoint, requestsByDay: $requestsByDay, lastUsed: $lastUsed, averageResponseTime: $averageResponseTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyUsageStatsImpl &&
            (identical(other.apiKeyId, apiKeyId) ||
                other.apiKeyId == apiKeyId) &&
            (identical(other.totalRequests, totalRequests) ||
                other.totalRequests == totalRequests) &&
            (identical(other.successfulRequests, successfulRequests) ||
                other.successfulRequests == successfulRequests) &&
            (identical(other.failedRequests, failedRequests) ||
                other.failedRequests == failedRequests) &&
            const DeepCollectionEquality().equals(
              other._requestsByEndpoint,
              _requestsByEndpoint,
            ) &&
            const DeepCollectionEquality().equals(
              other._requestsByDay,
              _requestsByDay,
            ) &&
            (identical(other.lastUsed, lastUsed) ||
                other.lastUsed == lastUsed) &&
            (identical(other.averageResponseTime, averageResponseTime) ||
                other.averageResponseTime == averageResponseTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    apiKeyId,
    totalRequests,
    successfulRequests,
    failedRequests,
    const DeepCollectionEquality().hash(_requestsByEndpoint),
    const DeepCollectionEquality().hash(_requestsByDay),
    lastUsed,
    averageResponseTime,
  );

  /// Create a copy of ApiKeyUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyUsageStatsImplCopyWith<_$ApiKeyUsageStatsImpl> get copyWith =>
      __$$ApiKeyUsageStatsImplCopyWithImpl<_$ApiKeyUsageStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyUsageStatsImplToJson(this);
  }
}

abstract class _ApiKeyUsageStats implements ApiKeyUsageStats {
  const factory _ApiKeyUsageStats({
    required final String apiKeyId,
    required final int totalRequests,
    required final int successfulRequests,
    required final int failedRequests,
    required final Map<String, int> requestsByEndpoint,
    required final Map<String, int> requestsByDay,
    required final DateTime lastUsed,
    required final double averageResponseTime,
  }) = _$ApiKeyUsageStatsImpl;

  factory _ApiKeyUsageStats.fromJson(Map<String, dynamic> json) =
      _$ApiKeyUsageStatsImpl.fromJson;

  @override
  String get apiKeyId;
  @override
  int get totalRequests;
  @override
  int get successfulRequests;
  @override
  int get failedRequests;
  @override
  Map<String, int> get requestsByEndpoint;
  @override
  Map<String, int> get requestsByDay;
  @override
  DateTime get lastUsed;
  @override
  double get averageResponseTime;

  /// Create a copy of ApiKeyUsageStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyUsageStatsImplCopyWith<_$ApiKeyUsageStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiKeyPermission _$ApiKeyPermissionFromJson(Map<String, dynamic> json) {
  return _ApiKeyPermission.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyPermission {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;
  List<String>? get subPermissions => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyPermission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyPermission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyPermissionCopyWith<ApiKeyPermission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyPermissionCopyWith<$Res> {
  factory $ApiKeyPermissionCopyWith(
    ApiKeyPermission value,
    $Res Function(ApiKeyPermission) then,
  ) = _$ApiKeyPermissionCopyWithImpl<$Res, ApiKeyPermission>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String category,
    bool isRequired,
    List<String>? subPermissions,
  });
}

/// @nodoc
class _$ApiKeyPermissionCopyWithImpl<$Res, $Val extends ApiKeyPermission>
    implements $ApiKeyPermissionCopyWith<$Res> {
  _$ApiKeyPermissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyPermission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? isRequired = null,
    Object? subPermissions = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            isRequired: null == isRequired
                ? _value.isRequired
                : isRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
            subPermissions: freezed == subPermissions
                ? _value.subPermissions
                : subPermissions // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiKeyPermissionImplCopyWith<$Res>
    implements $ApiKeyPermissionCopyWith<$Res> {
  factory _$$ApiKeyPermissionImplCopyWith(
    _$ApiKeyPermissionImpl value,
    $Res Function(_$ApiKeyPermissionImpl) then,
  ) = __$$ApiKeyPermissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String category,
    bool isRequired,
    List<String>? subPermissions,
  });
}

/// @nodoc
class __$$ApiKeyPermissionImplCopyWithImpl<$Res>
    extends _$ApiKeyPermissionCopyWithImpl<$Res, _$ApiKeyPermissionImpl>
    implements _$$ApiKeyPermissionImplCopyWith<$Res> {
  __$$ApiKeyPermissionImplCopyWithImpl(
    _$ApiKeyPermissionImpl _value,
    $Res Function(_$ApiKeyPermissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyPermission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? isRequired = null,
    Object? subPermissions = freezed,
  }) {
    return _then(
      _$ApiKeyPermissionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        isRequired: null == isRequired
            ? _value.isRequired
            : isRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        subPermissions: freezed == subPermissions
            ? _value._subPermissions
            : subPermissions // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiKeyPermissionImpl implements _ApiKeyPermission {
  const _$ApiKeyPermissionImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isRequired,
    final List<String>? subPermissions,
  }) : _subPermissions = subPermissions;

  factory _$ApiKeyPermissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyPermissionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String category;
  @override
  final bool isRequired;
  final List<String>? _subPermissions;
  @override
  List<String>? get subPermissions {
    final value = _subPermissions;
    if (value == null) return null;
    if (_subPermissions is EqualUnmodifiableListView) return _subPermissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ApiKeyPermission(id: $id, name: $name, description: $description, category: $category, isRequired: $isRequired, subPermissions: $subPermissions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyPermissionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            const DeepCollectionEquality().equals(
              other._subPermissions,
              _subPermissions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    category,
    isRequired,
    const DeepCollectionEquality().hash(_subPermissions),
  );

  /// Create a copy of ApiKeyPermission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyPermissionImplCopyWith<_$ApiKeyPermissionImpl> get copyWith =>
      __$$ApiKeyPermissionImplCopyWithImpl<_$ApiKeyPermissionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyPermissionImplToJson(this);
  }
}

abstract class _ApiKeyPermission implements ApiKeyPermission {
  const factory _ApiKeyPermission({
    required final String id,
    required final String name,
    required final String description,
    required final String category,
    required final bool isRequired,
    final List<String>? subPermissions,
  }) = _$ApiKeyPermissionImpl;

  factory _ApiKeyPermission.fromJson(Map<String, dynamic> json) =
      _$ApiKeyPermissionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get category;
  @override
  bool get isRequired;
  @override
  List<String>? get subPermissions;

  /// Create a copy of ApiKeyPermission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyPermissionImplCopyWith<_$ApiKeyPermissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiKeyScope _$ApiKeyScopeFromJson(Map<String, dynamic> json) {
  return _ApiKeyScope.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyScope {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get endpoints => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyScope to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyScope
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyScopeCopyWith<ApiKeyScope> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyScopeCopyWith<$Res> {
  factory $ApiKeyScopeCopyWith(
    ApiKeyScope value,
    $Res Function(ApiKeyScope) then,
  ) = _$ApiKeyScopeCopyWithImpl<$Res, ApiKeyScope>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    List<String> endpoints,
    bool isDefault,
  });
}

/// @nodoc
class _$ApiKeyScopeCopyWithImpl<$Res, $Val extends ApiKeyScope>
    implements $ApiKeyScopeCopyWith<$Res> {
  _$ApiKeyScopeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyScope
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? endpoints = null,
    Object? isDefault = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            endpoints: null == endpoints
                ? _value.endpoints
                : endpoints // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiKeyScopeImplCopyWith<$Res>
    implements $ApiKeyScopeCopyWith<$Res> {
  factory _$$ApiKeyScopeImplCopyWith(
    _$ApiKeyScopeImpl value,
    $Res Function(_$ApiKeyScopeImpl) then,
  ) = __$$ApiKeyScopeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    List<String> endpoints,
    bool isDefault,
  });
}

/// @nodoc
class __$$ApiKeyScopeImplCopyWithImpl<$Res>
    extends _$ApiKeyScopeCopyWithImpl<$Res, _$ApiKeyScopeImpl>
    implements _$$ApiKeyScopeImplCopyWith<$Res> {
  __$$ApiKeyScopeImplCopyWithImpl(
    _$ApiKeyScopeImpl _value,
    $Res Function(_$ApiKeyScopeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyScope
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? endpoints = null,
    Object? isDefault = null,
  }) {
    return _then(
      _$ApiKeyScopeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        endpoints: null == endpoints
            ? _value._endpoints
            : endpoints // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiKeyScopeImpl implements _ApiKeyScope {
  const _$ApiKeyScopeImpl({
    required this.id,
    required this.name,
    required this.description,
    required final List<String> endpoints,
    required this.isDefault,
  }) : _endpoints = endpoints;

  factory _$ApiKeyScopeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyScopeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  final List<String> _endpoints;
  @override
  List<String> get endpoints {
    if (_endpoints is EqualUnmodifiableListView) return _endpoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_endpoints);
  }

  @override
  final bool isDefault;

  @override
  String toString() {
    return 'ApiKeyScope(id: $id, name: $name, description: $description, endpoints: $endpoints, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyScopeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._endpoints,
              _endpoints,
            ) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    const DeepCollectionEquality().hash(_endpoints),
    isDefault,
  );

  /// Create a copy of ApiKeyScope
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyScopeImplCopyWith<_$ApiKeyScopeImpl> get copyWith =>
      __$$ApiKeyScopeImplCopyWithImpl<_$ApiKeyScopeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyScopeImplToJson(this);
  }
}

abstract class _ApiKeyScope implements ApiKeyScope {
  const factory _ApiKeyScope({
    required final String id,
    required final String name,
    required final String description,
    required final List<String> endpoints,
    required final bool isDefault,
  }) = _$ApiKeyScopeImpl;

  factory _ApiKeyScope.fromJson(Map<String, dynamic> json) =
      _$ApiKeyScopeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  List<String> get endpoints;
  @override
  bool get isDefault;

  /// Create a copy of ApiKeyScope
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyScopeImplCopyWith<_$ApiKeyScopeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiKeyActivity _$ApiKeyActivityFromJson(Map<String, dynamic> json) {
  return _ApiKeyActivity.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyActivity {
  String get id => throw _privateConstructorUsedError;
  String get apiKeyId => throw _privateConstructorUsedError;
  String get endpoint => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  int get statusCode => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  String get userAgent => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get responseTime => throw _privateConstructorUsedError;
  Map<String, dynamic>? get requestData => throw _privateConstructorUsedError;
  Map<String, dynamic>? get responseData => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyActivityCopyWith<ApiKeyActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyActivityCopyWith<$Res> {
  factory $ApiKeyActivityCopyWith(
    ApiKeyActivity value,
    $Res Function(ApiKeyActivity) then,
  ) = _$ApiKeyActivityCopyWithImpl<$Res, ApiKeyActivity>;
  @useResult
  $Res call({
    String id,
    String apiKeyId,
    String endpoint,
    String method,
    int statusCode,
    String ipAddress,
    String userAgent,
    DateTime timestamp,
    int responseTime,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  });
}

/// @nodoc
class _$ApiKeyActivityCopyWithImpl<$Res, $Val extends ApiKeyActivity>
    implements $ApiKeyActivityCopyWith<$Res> {
  _$ApiKeyActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? apiKeyId = null,
    Object? endpoint = null,
    Object? method = null,
    Object? statusCode = null,
    Object? ipAddress = null,
    Object? userAgent = null,
    Object? timestamp = null,
    Object? responseTime = null,
    Object? requestData = freezed,
    Object? responseData = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            apiKeyId: null == apiKeyId
                ? _value.apiKeyId
                : apiKeyId // ignore: cast_nullable_to_non_nullable
                      as String,
            endpoint: null == endpoint
                ? _value.endpoint
                : endpoint // ignore: cast_nullable_to_non_nullable
                      as String,
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            statusCode: null == statusCode
                ? _value.statusCode
                : statusCode // ignore: cast_nullable_to_non_nullable
                      as int,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            userAgent: null == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            responseTime: null == responseTime
                ? _value.responseTime
                : responseTime // ignore: cast_nullable_to_non_nullable
                      as int,
            requestData: freezed == requestData
                ? _value.requestData
                : requestData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            responseData: freezed == responseData
                ? _value.responseData
                : responseData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiKeyActivityImplCopyWith<$Res>
    implements $ApiKeyActivityCopyWith<$Res> {
  factory _$$ApiKeyActivityImplCopyWith(
    _$ApiKeyActivityImpl value,
    $Res Function(_$ApiKeyActivityImpl) then,
  ) = __$$ApiKeyActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String apiKeyId,
    String endpoint,
    String method,
    int statusCode,
    String ipAddress,
    String userAgent,
    DateTime timestamp,
    int responseTime,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  });
}

/// @nodoc
class __$$ApiKeyActivityImplCopyWithImpl<$Res>
    extends _$ApiKeyActivityCopyWithImpl<$Res, _$ApiKeyActivityImpl>
    implements _$$ApiKeyActivityImplCopyWith<$Res> {
  __$$ApiKeyActivityImplCopyWithImpl(
    _$ApiKeyActivityImpl _value,
    $Res Function(_$ApiKeyActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? apiKeyId = null,
    Object? endpoint = null,
    Object? method = null,
    Object? statusCode = null,
    Object? ipAddress = null,
    Object? userAgent = null,
    Object? timestamp = null,
    Object? responseTime = null,
    Object? requestData = freezed,
    Object? responseData = freezed,
  }) {
    return _then(
      _$ApiKeyActivityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        apiKeyId: null == apiKeyId
            ? _value.apiKeyId
            : apiKeyId // ignore: cast_nullable_to_non_nullable
                  as String,
        endpoint: null == endpoint
            ? _value.endpoint
            : endpoint // ignore: cast_nullable_to_non_nullable
                  as String,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        statusCode: null == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        userAgent: null == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        responseTime: null == responseTime
            ? _value.responseTime
            : responseTime // ignore: cast_nullable_to_non_nullable
                  as int,
        requestData: freezed == requestData
            ? _value._requestData
            : requestData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        responseData: freezed == responseData
            ? _value._responseData
            : responseData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiKeyActivityImpl implements _ApiKeyActivity {
  const _$ApiKeyActivityImpl({
    required this.id,
    required this.apiKeyId,
    required this.endpoint,
    required this.method,
    required this.statusCode,
    required this.ipAddress,
    required this.userAgent,
    required this.timestamp,
    required this.responseTime,
    final Map<String, dynamic>? requestData,
    final Map<String, dynamic>? responseData,
  }) : _requestData = requestData,
       _responseData = responseData;

  factory _$ApiKeyActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String apiKeyId;
  @override
  final String endpoint;
  @override
  final String method;
  @override
  final int statusCode;
  @override
  final String ipAddress;
  @override
  final String userAgent;
  @override
  final DateTime timestamp;
  @override
  final int responseTime;
  final Map<String, dynamic>? _requestData;
  @override
  Map<String, dynamic>? get requestData {
    final value = _requestData;
    if (value == null) return null;
    if (_requestData is EqualUnmodifiableMapView) return _requestData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _responseData;
  @override
  Map<String, dynamic>? get responseData {
    final value = _responseData;
    if (value == null) return null;
    if (_responseData is EqualUnmodifiableMapView) return _responseData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ApiKeyActivity(id: $id, apiKeyId: $apiKeyId, endpoint: $endpoint, method: $method, statusCode: $statusCode, ipAddress: $ipAddress, userAgent: $userAgent, timestamp: $timestamp, responseTime: $responseTime, requestData: $requestData, responseData: $responseData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.apiKeyId, apiKeyId) ||
                other.apiKeyId == apiKeyId) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            const DeepCollectionEquality().equals(
              other._requestData,
              _requestData,
            ) &&
            const DeepCollectionEquality().equals(
              other._responseData,
              _responseData,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    apiKeyId,
    endpoint,
    method,
    statusCode,
    ipAddress,
    userAgent,
    timestamp,
    responseTime,
    const DeepCollectionEquality().hash(_requestData),
    const DeepCollectionEquality().hash(_responseData),
  );

  /// Create a copy of ApiKeyActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyActivityImplCopyWith<_$ApiKeyActivityImpl> get copyWith =>
      __$$ApiKeyActivityImplCopyWithImpl<_$ApiKeyActivityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyActivityImplToJson(this);
  }
}

abstract class _ApiKeyActivity implements ApiKeyActivity {
  const factory _ApiKeyActivity({
    required final String id,
    required final String apiKeyId,
    required final String endpoint,
    required final String method,
    required final int statusCode,
    required final String ipAddress,
    required final String userAgent,
    required final DateTime timestamp,
    required final int responseTime,
    final Map<String, dynamic>? requestData,
    final Map<String, dynamic>? responseData,
  }) = _$ApiKeyActivityImpl;

  factory _ApiKeyActivity.fromJson(Map<String, dynamic> json) =
      _$ApiKeyActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get apiKeyId;
  @override
  String get endpoint;
  @override
  String get method;
  @override
  int get statusCode;
  @override
  String get ipAddress;
  @override
  String get userAgent;
  @override
  DateTime get timestamp;
  @override
  int get responseTime;
  @override
  Map<String, dynamic>? get requestData;
  @override
  Map<String, dynamic>? get responseData;

  /// Create a copy of ApiKeyActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyActivityImplCopyWith<_$ApiKeyActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
