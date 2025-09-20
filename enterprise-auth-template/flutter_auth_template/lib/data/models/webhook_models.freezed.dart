// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webhook_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Webhook _$WebhookFromJson(Map<String, dynamic> json) {
  return _Webhook.fromJson(json);
}

/// @nodoc
mixin _$Webhook {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get secret => throw _privateConstructorUsedError;
  List<String>? get events => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  String? get httpMethod => throw _privateConstructorUsedError;
  Map<String, String>? get headers => throw _privateConstructorUsedError;
  int? get timeoutSeconds => throw _privateConstructorUsedError;
  int? get maxRetries => throw _privateConstructorUsedError;
  bool? get verifyTls => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastTriggeredAt => throw _privateConstructorUsedError;
  WebhookStatus? get status => throw _privateConstructorUsedError;
  int? get successCount => throw _privateConstructorUsedError;
  int? get failureCount => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Webhook to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Webhook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookCopyWith<Webhook> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookCopyWith<$Res> {
  factory $WebhookCopyWith(Webhook value, $Res Function(Webhook) then) =
      _$WebhookCopyWithImpl<$Res, Webhook>;
  @useResult
  $Res call({
    String? id,
    String? name,
    String? description,
    String? url,
    String? secret,
    List<String>? events,
    bool? isActive,
    String? httpMethod,
    Map<String, String>? headers,
    int? timeoutSeconds,
    int? maxRetries,
    bool? verifyTls,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTriggeredAt,
    WebhookStatus? status,
    int? successCount,
    int? failureCount,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$WebhookCopyWithImpl<$Res, $Val extends Webhook>
    implements $WebhookCopyWith<$Res> {
  _$WebhookCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Webhook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? url = freezed,
    Object? secret = freezed,
    Object? events = freezed,
    Object? isActive = freezed,
    Object? httpMethod = freezed,
    Object? headers = freezed,
    Object? timeoutSeconds = freezed,
    Object? maxRetries = freezed,
    Object? verifyTls = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastTriggeredAt = freezed,
    Object? status = freezed,
    Object? successCount = freezed,
    Object? failureCount = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            secret: freezed == secret
                ? _value.secret
                : secret // ignore: cast_nullable_to_non_nullable
                      as String?,
            events: freezed == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
            httpMethod: freezed == httpMethod
                ? _value.httpMethod
                : httpMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            headers: freezed == headers
                ? _value.headers
                : headers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            timeoutSeconds: freezed == timeoutSeconds
                ? _value.timeoutSeconds
                : timeoutSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxRetries: freezed == maxRetries
                ? _value.maxRetries
                : maxRetries // ignore: cast_nullable_to_non_nullable
                      as int?,
            verifyTls: freezed == verifyTls
                ? _value.verifyTls
                : verifyTls // ignore: cast_nullable_to_non_nullable
                      as bool?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastTriggeredAt: freezed == lastTriggeredAt
                ? _value.lastTriggeredAt
                : lastTriggeredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as WebhookStatus?,
            successCount: freezed == successCount
                ? _value.successCount
                : successCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            failureCount: freezed == failureCount
                ? _value.failureCount
                : failureCount // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$WebhookImplCopyWith<$Res> implements $WebhookCopyWith<$Res> {
  factory _$$WebhookImplCopyWith(
    _$WebhookImpl value,
    $Res Function(_$WebhookImpl) then,
  ) = __$$WebhookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? name,
    String? description,
    String? url,
    String? secret,
    List<String>? events,
    bool? isActive,
    String? httpMethod,
    Map<String, String>? headers,
    int? timeoutSeconds,
    int? maxRetries,
    bool? verifyTls,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTriggeredAt,
    WebhookStatus? status,
    int? successCount,
    int? failureCount,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$WebhookImplCopyWithImpl<$Res>
    extends _$WebhookCopyWithImpl<$Res, _$WebhookImpl>
    implements _$$WebhookImplCopyWith<$Res> {
  __$$WebhookImplCopyWithImpl(
    _$WebhookImpl _value,
    $Res Function(_$WebhookImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Webhook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? url = freezed,
    Object? secret = freezed,
    Object? events = freezed,
    Object? isActive = freezed,
    Object? httpMethod = freezed,
    Object? headers = freezed,
    Object? timeoutSeconds = freezed,
    Object? maxRetries = freezed,
    Object? verifyTls = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastTriggeredAt = freezed,
    Object? status = freezed,
    Object? successCount = freezed,
    Object? failureCount = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$WebhookImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        secret: freezed == secret
            ? _value.secret
            : secret // ignore: cast_nullable_to_non_nullable
                  as String?,
        events: freezed == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
        httpMethod: freezed == httpMethod
            ? _value.httpMethod
            : httpMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        headers: freezed == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        timeoutSeconds: freezed == timeoutSeconds
            ? _value.timeoutSeconds
            : timeoutSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxRetries: freezed == maxRetries
            ? _value.maxRetries
            : maxRetries // ignore: cast_nullable_to_non_nullable
                  as int?,
        verifyTls: freezed == verifyTls
            ? _value.verifyTls
            : verifyTls // ignore: cast_nullable_to_non_nullable
                  as bool?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastTriggeredAt: freezed == lastTriggeredAt
            ? _value.lastTriggeredAt
            : lastTriggeredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as WebhookStatus?,
        successCount: freezed == successCount
            ? _value.successCount
            : successCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        failureCount: freezed == failureCount
            ? _value.failureCount
            : failureCount // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$WebhookImpl implements _Webhook {
  const _$WebhookImpl({
    this.id,
    this.name,
    this.description,
    this.url,
    this.secret,
    final List<String>? events,
    this.isActive,
    this.httpMethod,
    final Map<String, String>? headers,
    this.timeoutSeconds,
    this.maxRetries,
    this.verifyTls,
    this.createdAt,
    this.updatedAt,
    this.lastTriggeredAt,
    this.status,
    this.successCount,
    this.failureCount,
    final Map<String, dynamic>? metadata,
  }) : _events = events,
       _headers = headers,
       _metadata = metadata;

  factory _$WebhookImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? url;
  @override
  final String? secret;
  final List<String>? _events;
  @override
  List<String>? get events {
    final value = _events;
    if (value == null) return null;
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isActive;
  @override
  final String? httpMethod;
  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int? timeoutSeconds;
  @override
  final int? maxRetries;
  @override
  final bool? verifyTls;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? lastTriggeredAt;
  @override
  final WebhookStatus? status;
  @override
  final int? successCount;
  @override
  final int? failureCount;
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
    return 'Webhook(id: $id, name: $name, description: $description, url: $url, secret: $secret, events: $events, isActive: $isActive, httpMethod: $httpMethod, headers: $headers, timeoutSeconds: $timeoutSeconds, maxRetries: $maxRetries, verifyTls: $verifyTls, createdAt: $createdAt, updatedAt: $updatedAt, lastTriggeredAt: $lastTriggeredAt, status: $status, successCount: $successCount, failureCount: $failureCount, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.secret, secret) || other.secret == secret) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.httpMethod, httpMethod) ||
                other.httpMethod == httpMethod) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            (identical(other.timeoutSeconds, timeoutSeconds) ||
                other.timeoutSeconds == timeoutSeconds) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.verifyTls, verifyTls) ||
                other.verifyTls == verifyTls) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastTriggeredAt, lastTriggeredAt) ||
                other.lastTriggeredAt == lastTriggeredAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    url,
    secret,
    const DeepCollectionEquality().hash(_events),
    isActive,
    httpMethod,
    const DeepCollectionEquality().hash(_headers),
    timeoutSeconds,
    maxRetries,
    verifyTls,
    createdAt,
    updatedAt,
    lastTriggeredAt,
    status,
    successCount,
    failureCount,
    const DeepCollectionEquality().hash(_metadata),
  ]);

  /// Create a copy of Webhook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookImplCopyWith<_$WebhookImpl> get copyWith =>
      __$$WebhookImplCopyWithImpl<_$WebhookImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookImplToJson(this);
  }
}

abstract class _Webhook implements Webhook {
  const factory _Webhook({
    final String? id,
    final String? name,
    final String? description,
    final String? url,
    final String? secret,
    final List<String>? events,
    final bool? isActive,
    final String? httpMethod,
    final Map<String, String>? headers,
    final int? timeoutSeconds,
    final int? maxRetries,
    final bool? verifyTls,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final DateTime? lastTriggeredAt,
    final WebhookStatus? status,
    final int? successCount,
    final int? failureCount,
    final Map<String, dynamic>? metadata,
  }) = _$WebhookImpl;

  factory _Webhook.fromJson(Map<String, dynamic> json) = _$WebhookImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  String? get description;
  @override
  String? get url;
  @override
  String? get secret;
  @override
  List<String>? get events;
  @override
  bool? get isActive;
  @override
  String? get httpMethod;
  @override
  Map<String, String>? get headers;
  @override
  int? get timeoutSeconds;
  @override
  int? get maxRetries;
  @override
  bool? get verifyTls;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get lastTriggeredAt;
  @override
  WebhookStatus? get status;
  @override
  int? get successCount;
  @override
  int? get failureCount;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Webhook
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookImplCopyWith<_$WebhookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebhookCreateRequest _$WebhookCreateRequestFromJson(Map<String, dynamic> json) {
  return _WebhookCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$WebhookCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get secret => throw _privateConstructorUsedError;
  List<String> get events => throw _privateConstructorUsedError;
  String get httpMethod => throw _privateConstructorUsedError;
  Map<String, String> get headers => throw _privateConstructorUsedError;
  int get timeoutSeconds => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;
  bool get verifyTls => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this WebhookCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookCreateRequestCopyWith<WebhookCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookCreateRequestCopyWith<$Res> {
  factory $WebhookCreateRequestCopyWith(
    WebhookCreateRequest value,
    $Res Function(WebhookCreateRequest) then,
  ) = _$WebhookCreateRequestCopyWithImpl<$Res, WebhookCreateRequest>;
  @useResult
  $Res call({
    String name,
    String description,
    String url,
    String secret,
    List<String> events,
    String httpMethod,
    Map<String, String> headers,
    int timeoutSeconds,
    int maxRetries,
    bool verifyTls,
    bool isActive,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$WebhookCreateRequestCopyWithImpl<
  $Res,
  $Val extends WebhookCreateRequest
>
    implements $WebhookCreateRequestCopyWith<$Res> {
  _$WebhookCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? url = null,
    Object? secret = null,
    Object? events = null,
    Object? httpMethod = null,
    Object? headers = null,
    Object? timeoutSeconds = null,
    Object? maxRetries = null,
    Object? verifyTls = null,
    Object? isActive = null,
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
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            secret: null == secret
                ? _value.secret
                : secret // ignore: cast_nullable_to_non_nullable
                      as String,
            events: null == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            httpMethod: null == httpMethod
                ? _value.httpMethod
                : httpMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            headers: null == headers
                ? _value.headers
                : headers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            timeoutSeconds: null == timeoutSeconds
                ? _value.timeoutSeconds
                : timeoutSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            maxRetries: null == maxRetries
                ? _value.maxRetries
                : maxRetries // ignore: cast_nullable_to_non_nullable
                      as int,
            verifyTls: null == verifyTls
                ? _value.verifyTls
                : verifyTls // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$WebhookCreateRequestImplCopyWith<$Res>
    implements $WebhookCreateRequestCopyWith<$Res> {
  factory _$$WebhookCreateRequestImplCopyWith(
    _$WebhookCreateRequestImpl value,
    $Res Function(_$WebhookCreateRequestImpl) then,
  ) = __$$WebhookCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String description,
    String url,
    String secret,
    List<String> events,
    String httpMethod,
    Map<String, String> headers,
    int timeoutSeconds,
    int maxRetries,
    bool verifyTls,
    bool isActive,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$WebhookCreateRequestImplCopyWithImpl<$Res>
    extends _$WebhookCreateRequestCopyWithImpl<$Res, _$WebhookCreateRequestImpl>
    implements _$$WebhookCreateRequestImplCopyWith<$Res> {
  __$$WebhookCreateRequestImplCopyWithImpl(
    _$WebhookCreateRequestImpl _value,
    $Res Function(_$WebhookCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? url = null,
    Object? secret = null,
    Object? events = null,
    Object? httpMethod = null,
    Object? headers = null,
    Object? timeoutSeconds = null,
    Object? maxRetries = null,
    Object? verifyTls = null,
    Object? isActive = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$WebhookCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        secret: null == secret
            ? _value.secret
            : secret // ignore: cast_nullable_to_non_nullable
                  as String,
        events: null == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        httpMethod: null == httpMethod
            ? _value.httpMethod
            : httpMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        headers: null == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        timeoutSeconds: null == timeoutSeconds
            ? _value.timeoutSeconds
            : timeoutSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        maxRetries: null == maxRetries
            ? _value.maxRetries
            : maxRetries // ignore: cast_nullable_to_non_nullable
                  as int,
        verifyTls: null == verifyTls
            ? _value.verifyTls
            : verifyTls // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$WebhookCreateRequestImpl implements _WebhookCreateRequest {
  const _$WebhookCreateRequestImpl({
    required this.name,
    required this.description,
    required this.url,
    required this.secret,
    required final List<String> events,
    this.httpMethod = 'POST',
    final Map<String, String> headers = const {},
    this.timeoutSeconds = 30,
    this.maxRetries = 3,
    this.verifyTls = true,
    this.isActive = true,
    final Map<String, dynamic>? metadata,
  }) : _events = events,
       _headers = headers,
       _metadata = metadata;

  factory _$WebhookCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  @override
  final String url;
  @override
  final String secret;
  final List<String> _events;
  @override
  List<String> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  @JsonKey()
  final String httpMethod;
  final Map<String, String> _headers;
  @override
  @JsonKey()
  Map<String, String> get headers {
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_headers);
  }

  @override
  @JsonKey()
  final int timeoutSeconds;
  @override
  @JsonKey()
  final int maxRetries;
  @override
  @JsonKey()
  final bool verifyTls;
  @override
  @JsonKey()
  final bool isActive;
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
    return 'WebhookCreateRequest(name: $name, description: $description, url: $url, secret: $secret, events: $events, httpMethod: $httpMethod, headers: $headers, timeoutSeconds: $timeoutSeconds, maxRetries: $maxRetries, verifyTls: $verifyTls, isActive: $isActive, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.secret, secret) || other.secret == secret) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.httpMethod, httpMethod) ||
                other.httpMethod == httpMethod) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            (identical(other.timeoutSeconds, timeoutSeconds) ||
                other.timeoutSeconds == timeoutSeconds) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.verifyTls, verifyTls) ||
                other.verifyTls == verifyTls) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    url,
    secret,
    const DeepCollectionEquality().hash(_events),
    httpMethod,
    const DeepCollectionEquality().hash(_headers),
    timeoutSeconds,
    maxRetries,
    verifyTls,
    isActive,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of WebhookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookCreateRequestImplCopyWith<_$WebhookCreateRequestImpl>
  get copyWith =>
      __$$WebhookCreateRequestImplCopyWithImpl<_$WebhookCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookCreateRequestImplToJson(this);
  }
}

abstract class _WebhookCreateRequest implements WebhookCreateRequest {
  const factory _WebhookCreateRequest({
    required final String name,
    required final String description,
    required final String url,
    required final String secret,
    required final List<String> events,
    final String httpMethod,
    final Map<String, String> headers,
    final int timeoutSeconds,
    final int maxRetries,
    final bool verifyTls,
    final bool isActive,
    final Map<String, dynamic>? metadata,
  }) = _$WebhookCreateRequestImpl;

  factory _WebhookCreateRequest.fromJson(Map<String, dynamic> json) =
      _$WebhookCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  String get url;
  @override
  String get secret;
  @override
  List<String> get events;
  @override
  String get httpMethod;
  @override
  Map<String, String> get headers;
  @override
  int get timeoutSeconds;
  @override
  int get maxRetries;
  @override
  bool get verifyTls;
  @override
  bool get isActive;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of WebhookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookCreateRequestImplCopyWith<_$WebhookCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

WebhookUpdateRequest _$WebhookUpdateRequestFromJson(Map<String, dynamic> json) {
  return _WebhookUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$WebhookUpdateRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get secret => throw _privateConstructorUsedError;
  List<String>? get events => throw _privateConstructorUsedError;
  String? get httpMethod => throw _privateConstructorUsedError;
  Map<String, String>? get headers => throw _privateConstructorUsedError;
  int? get timeoutSeconds => throw _privateConstructorUsedError;
  int? get maxRetries => throw _privateConstructorUsedError;
  bool? get verifyTls => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this WebhookUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookUpdateRequestCopyWith<WebhookUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookUpdateRequestCopyWith<$Res> {
  factory $WebhookUpdateRequestCopyWith(
    WebhookUpdateRequest value,
    $Res Function(WebhookUpdateRequest) then,
  ) = _$WebhookUpdateRequestCopyWithImpl<$Res, WebhookUpdateRequest>;
  @useResult
  $Res call({
    String? name,
    String? description,
    String? url,
    String? secret,
    List<String>? events,
    String? httpMethod,
    Map<String, String>? headers,
    int? timeoutSeconds,
    int? maxRetries,
    bool? verifyTls,
    bool? isActive,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$WebhookUpdateRequestCopyWithImpl<
  $Res,
  $Val extends WebhookUpdateRequest
>
    implements $WebhookUpdateRequestCopyWith<$Res> {
  _$WebhookUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? url = freezed,
    Object? secret = freezed,
    Object? events = freezed,
    Object? httpMethod = freezed,
    Object? headers = freezed,
    Object? timeoutSeconds = freezed,
    Object? maxRetries = freezed,
    Object? verifyTls = freezed,
    Object? isActive = freezed,
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
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            secret: freezed == secret
                ? _value.secret
                : secret // ignore: cast_nullable_to_non_nullable
                      as String?,
            events: freezed == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            httpMethod: freezed == httpMethod
                ? _value.httpMethod
                : httpMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            headers: freezed == headers
                ? _value.headers
                : headers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            timeoutSeconds: freezed == timeoutSeconds
                ? _value.timeoutSeconds
                : timeoutSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxRetries: freezed == maxRetries
                ? _value.maxRetries
                : maxRetries // ignore: cast_nullable_to_non_nullable
                      as int?,
            verifyTls: freezed == verifyTls
                ? _value.verifyTls
                : verifyTls // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
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
abstract class _$$WebhookUpdateRequestImplCopyWith<$Res>
    implements $WebhookUpdateRequestCopyWith<$Res> {
  factory _$$WebhookUpdateRequestImplCopyWith(
    _$WebhookUpdateRequestImpl value,
    $Res Function(_$WebhookUpdateRequestImpl) then,
  ) = __$$WebhookUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? description,
    String? url,
    String? secret,
    List<String>? events,
    String? httpMethod,
    Map<String, String>? headers,
    int? timeoutSeconds,
    int? maxRetries,
    bool? verifyTls,
    bool? isActive,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$WebhookUpdateRequestImplCopyWithImpl<$Res>
    extends _$WebhookUpdateRequestCopyWithImpl<$Res, _$WebhookUpdateRequestImpl>
    implements _$$WebhookUpdateRequestImplCopyWith<$Res> {
  __$$WebhookUpdateRequestImplCopyWithImpl(
    _$WebhookUpdateRequestImpl _value,
    $Res Function(_$WebhookUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? url = freezed,
    Object? secret = freezed,
    Object? events = freezed,
    Object? httpMethod = freezed,
    Object? headers = freezed,
    Object? timeoutSeconds = freezed,
    Object? maxRetries = freezed,
    Object? verifyTls = freezed,
    Object? isActive = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$WebhookUpdateRequestImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        secret: freezed == secret
            ? _value.secret
            : secret // ignore: cast_nullable_to_non_nullable
                  as String?,
        events: freezed == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        httpMethod: freezed == httpMethod
            ? _value.httpMethod
            : httpMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        headers: freezed == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        timeoutSeconds: freezed == timeoutSeconds
            ? _value.timeoutSeconds
            : timeoutSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxRetries: freezed == maxRetries
            ? _value.maxRetries
            : maxRetries // ignore: cast_nullable_to_non_nullable
                  as int?,
        verifyTls: freezed == verifyTls
            ? _value.verifyTls
            : verifyTls // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
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
class _$WebhookUpdateRequestImpl implements _WebhookUpdateRequest {
  const _$WebhookUpdateRequestImpl({
    this.name,
    this.description,
    this.url,
    this.secret,
    final List<String>? events,
    this.httpMethod,
    final Map<String, String>? headers,
    this.timeoutSeconds,
    this.maxRetries,
    this.verifyTls,
    this.isActive,
    final Map<String, dynamic>? metadata,
  }) : _events = events,
       _headers = headers,
       _metadata = metadata;

  factory _$WebhookUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookUpdateRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? url;
  @override
  final String? secret;
  final List<String>? _events;
  @override
  List<String>? get events {
    final value = _events;
    if (value == null) return null;
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? httpMethod;
  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int? timeoutSeconds;
  @override
  final int? maxRetries;
  @override
  final bool? verifyTls;
  @override
  final bool? isActive;
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
    return 'WebhookUpdateRequest(name: $name, description: $description, url: $url, secret: $secret, events: $events, httpMethod: $httpMethod, headers: $headers, timeoutSeconds: $timeoutSeconds, maxRetries: $maxRetries, verifyTls: $verifyTls, isActive: $isActive, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookUpdateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.secret, secret) || other.secret == secret) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.httpMethod, httpMethod) ||
                other.httpMethod == httpMethod) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            (identical(other.timeoutSeconds, timeoutSeconds) ||
                other.timeoutSeconds == timeoutSeconds) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.verifyTls, verifyTls) ||
                other.verifyTls == verifyTls) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    url,
    secret,
    const DeepCollectionEquality().hash(_events),
    httpMethod,
    const DeepCollectionEquality().hash(_headers),
    timeoutSeconds,
    maxRetries,
    verifyTls,
    isActive,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of WebhookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookUpdateRequestImplCopyWith<_$WebhookUpdateRequestImpl>
  get copyWith =>
      __$$WebhookUpdateRequestImplCopyWithImpl<_$WebhookUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookUpdateRequestImplToJson(this);
  }
}

abstract class _WebhookUpdateRequest implements WebhookUpdateRequest {
  const factory _WebhookUpdateRequest({
    final String? name,
    final String? description,
    final String? url,
    final String? secret,
    final List<String>? events,
    final String? httpMethod,
    final Map<String, String>? headers,
    final int? timeoutSeconds,
    final int? maxRetries,
    final bool? verifyTls,
    final bool? isActive,
    final Map<String, dynamic>? metadata,
  }) = _$WebhookUpdateRequestImpl;

  factory _WebhookUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$WebhookUpdateRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  String? get url;
  @override
  String? get secret;
  @override
  List<String>? get events;
  @override
  String? get httpMethod;
  @override
  Map<String, String>? get headers;
  @override
  int? get timeoutSeconds;
  @override
  int? get maxRetries;
  @override
  bool? get verifyTls;
  @override
  bool? get isActive;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of WebhookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookUpdateRequestImplCopyWith<_$WebhookUpdateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

WebhookListResponse _$WebhookListResponseFromJson(Map<String, dynamic> json) {
  return _WebhookListResponse.fromJson(json);
}

/// @nodoc
mixin _$WebhookListResponse {
  List<Webhook> get webhooks => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrevious => throw _privateConstructorUsedError;

  /// Serializes this WebhookListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookListResponseCopyWith<WebhookListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookListResponseCopyWith<$Res> {
  factory $WebhookListResponseCopyWith(
    WebhookListResponse value,
    $Res Function(WebhookListResponse) then,
  ) = _$WebhookListResponseCopyWithImpl<$Res, WebhookListResponse>;
  @useResult
  $Res call({
    List<Webhook> webhooks,
    int total,
    int page,
    int limit,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class _$WebhookListResponseCopyWithImpl<$Res, $Val extends WebhookListResponse>
    implements $WebhookListResponseCopyWith<$Res> {
  _$WebhookListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? webhooks = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _value.copyWith(
            webhooks: null == webhooks
                ? _value.webhooks
                : webhooks // ignore: cast_nullable_to_non_nullable
                      as List<Webhook>,
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
abstract class _$$WebhookListResponseImplCopyWith<$Res>
    implements $WebhookListResponseCopyWith<$Res> {
  factory _$$WebhookListResponseImplCopyWith(
    _$WebhookListResponseImpl value,
    $Res Function(_$WebhookListResponseImpl) then,
  ) = __$$WebhookListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Webhook> webhooks,
    int total,
    int page,
    int limit,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class __$$WebhookListResponseImplCopyWithImpl<$Res>
    extends _$WebhookListResponseCopyWithImpl<$Res, _$WebhookListResponseImpl>
    implements _$$WebhookListResponseImplCopyWith<$Res> {
  __$$WebhookListResponseImplCopyWithImpl(
    _$WebhookListResponseImpl _value,
    $Res Function(_$WebhookListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? webhooks = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _$WebhookListResponseImpl(
        webhooks: null == webhooks
            ? _value._webhooks
            : webhooks // ignore: cast_nullable_to_non_nullable
                  as List<Webhook>,
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
class _$WebhookListResponseImpl implements _WebhookListResponse {
  const _$WebhookListResponseImpl({
    required final List<Webhook> webhooks,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  }) : _webhooks = webhooks;

  factory _$WebhookListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookListResponseImplFromJson(json);

  final List<Webhook> _webhooks;
  @override
  List<Webhook> get webhooks {
    if (_webhooks is EqualUnmodifiableListView) return _webhooks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_webhooks);
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
    return 'WebhookListResponse(webhooks: $webhooks, total: $total, page: $page, limit: $limit, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookListResponseImpl &&
            const DeepCollectionEquality().equals(other._webhooks, _webhooks) &&
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
    const DeepCollectionEquality().hash(_webhooks),
    total,
    page,
    limit,
    hasNext,
    hasPrevious,
  );

  /// Create a copy of WebhookListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookListResponseImplCopyWith<_$WebhookListResponseImpl> get copyWith =>
      __$$WebhookListResponseImplCopyWithImpl<_$WebhookListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookListResponseImplToJson(this);
  }
}

abstract class _WebhookListResponse implements WebhookListResponse {
  const factory _WebhookListResponse({
    required final List<Webhook> webhooks,
    required final int total,
    required final int page,
    required final int limit,
    required final bool hasNext,
    required final bool hasPrevious,
  }) = _$WebhookListResponseImpl;

  factory _WebhookListResponse.fromJson(Map<String, dynamic> json) =
      _$WebhookListResponseImpl.fromJson;

  @override
  List<Webhook> get webhooks;
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

  /// Create a copy of WebhookListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookListResponseImplCopyWith<_$WebhookListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebhookDelivery _$WebhookDeliveryFromJson(Map<String, dynamic> json) {
  return _WebhookDelivery.fromJson(json);
}

/// @nodoc
mixin _$WebhookDelivery {
  String? get id => throw _privateConstructorUsedError;
  String? get webhookId => throw _privateConstructorUsedError;
  String? get event => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;
  int? get statusCode => throw _privateConstructorUsedError;
  String? get response => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  bool? get success => throw _privateConstructorUsedError;
  int? get attempt => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int? get responseTime => throw _privateConstructorUsedError;
  Map<String, String>? get requestHeaders => throw _privateConstructorUsedError;
  Map<String, String>? get responseHeaders =>
      throw _privateConstructorUsedError;

  /// Serializes this WebhookDelivery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookDelivery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookDeliveryCopyWith<WebhookDelivery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookDeliveryCopyWith<$Res> {
  factory $WebhookDeliveryCopyWith(
    WebhookDelivery value,
    $Res Function(WebhookDelivery) then,
  ) = _$WebhookDeliveryCopyWithImpl<$Res, WebhookDelivery>;
  @useResult
  $Res call({
    String? id,
    String? webhookId,
    String? event,
    Map<String, dynamic>? payload,
    int? statusCode,
    String? response,
    DateTime? createdAt,
    DateTime? deliveredAt,
    bool? success,
    int? attempt,
    String? error,
    int? responseTime,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
  });
}

/// @nodoc
class _$WebhookDeliveryCopyWithImpl<$Res, $Val extends WebhookDelivery>
    implements $WebhookDeliveryCopyWith<$Res> {
  _$WebhookDeliveryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookDelivery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? webhookId = freezed,
    Object? event = freezed,
    Object? payload = freezed,
    Object? statusCode = freezed,
    Object? response = freezed,
    Object? createdAt = freezed,
    Object? deliveredAt = freezed,
    Object? success = freezed,
    Object? attempt = freezed,
    Object? error = freezed,
    Object? responseTime = freezed,
    Object? requestHeaders = freezed,
    Object? responseHeaders = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            webhookId: freezed == webhookId
                ? _value.webhookId
                : webhookId // ignore: cast_nullable_to_non_nullable
                      as String?,
            event: freezed == event
                ? _value.event
                : event // ignore: cast_nullable_to_non_nullable
                      as String?,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            statusCode: freezed == statusCode
                ? _value.statusCode
                : statusCode // ignore: cast_nullable_to_non_nullable
                      as int?,
            response: freezed == response
                ? _value.response
                : response // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            success: freezed == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool?,
            attempt: freezed == attempt
                ? _value.attempt
                : attempt // ignore: cast_nullable_to_non_nullable
                      as int?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            responseTime: freezed == responseTime
                ? _value.responseTime
                : responseTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            requestHeaders: freezed == requestHeaders
                ? _value.requestHeaders
                : requestHeaders // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            responseHeaders: freezed == responseHeaders
                ? _value.responseHeaders
                : responseHeaders // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebhookDeliveryImplCopyWith<$Res>
    implements $WebhookDeliveryCopyWith<$Res> {
  factory _$$WebhookDeliveryImplCopyWith(
    _$WebhookDeliveryImpl value,
    $Res Function(_$WebhookDeliveryImpl) then,
  ) = __$$WebhookDeliveryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? webhookId,
    String? event,
    Map<String, dynamic>? payload,
    int? statusCode,
    String? response,
    DateTime? createdAt,
    DateTime? deliveredAt,
    bool? success,
    int? attempt,
    String? error,
    int? responseTime,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
  });
}

/// @nodoc
class __$$WebhookDeliveryImplCopyWithImpl<$Res>
    extends _$WebhookDeliveryCopyWithImpl<$Res, _$WebhookDeliveryImpl>
    implements _$$WebhookDeliveryImplCopyWith<$Res> {
  __$$WebhookDeliveryImplCopyWithImpl(
    _$WebhookDeliveryImpl _value,
    $Res Function(_$WebhookDeliveryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookDelivery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? webhookId = freezed,
    Object? event = freezed,
    Object? payload = freezed,
    Object? statusCode = freezed,
    Object? response = freezed,
    Object? createdAt = freezed,
    Object? deliveredAt = freezed,
    Object? success = freezed,
    Object? attempt = freezed,
    Object? error = freezed,
    Object? responseTime = freezed,
    Object? requestHeaders = freezed,
    Object? responseHeaders = freezed,
  }) {
    return _then(
      _$WebhookDeliveryImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        webhookId: freezed == webhookId
            ? _value.webhookId
            : webhookId // ignore: cast_nullable_to_non_nullable
                  as String?,
        event: freezed == event
            ? _value.event
            : event // ignore: cast_nullable_to_non_nullable
                  as String?,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
        response: freezed == response
            ? _value.response
            : response // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        success: freezed == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool?,
        attempt: freezed == attempt
            ? _value.attempt
            : attempt // ignore: cast_nullable_to_non_nullable
                  as int?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        responseTime: freezed == responseTime
            ? _value.responseTime
            : responseTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        requestHeaders: freezed == requestHeaders
            ? _value._requestHeaders
            : requestHeaders // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        responseHeaders: freezed == responseHeaders
            ? _value._responseHeaders
            : responseHeaders // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebhookDeliveryImpl implements _WebhookDelivery {
  const _$WebhookDeliveryImpl({
    this.id,
    this.webhookId,
    this.event,
    final Map<String, dynamic>? payload,
    this.statusCode,
    this.response,
    this.createdAt,
    this.deliveredAt,
    this.success,
    this.attempt,
    this.error,
    this.responseTime,
    final Map<String, String>? requestHeaders,
    final Map<String, String>? responseHeaders,
  }) : _payload = payload,
       _requestHeaders = requestHeaders,
       _responseHeaders = responseHeaders;

  factory _$WebhookDeliveryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookDeliveryImplFromJson(json);

  @override
  final String? id;
  @override
  final String? webhookId;
  @override
  final String? event;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int? statusCode;
  @override
  final String? response;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? deliveredAt;
  @override
  final bool? success;
  @override
  final int? attempt;
  @override
  final String? error;
  @override
  final int? responseTime;
  final Map<String, String>? _requestHeaders;
  @override
  Map<String, String>? get requestHeaders {
    final value = _requestHeaders;
    if (value == null) return null;
    if (_requestHeaders is EqualUnmodifiableMapView) return _requestHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, String>? _responseHeaders;
  @override
  Map<String, String>? get responseHeaders {
    final value = _responseHeaders;
    if (value == null) return null;
    if (_responseHeaders is EqualUnmodifiableMapView) return _responseHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'WebhookDelivery(id: $id, webhookId: $webhookId, event: $event, payload: $payload, statusCode: $statusCode, response: $response, createdAt: $createdAt, deliveredAt: $deliveredAt, success: $success, attempt: $attempt, error: $error, responseTime: $responseTime, requestHeaders: $requestHeaders, responseHeaders: $responseHeaders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookDeliveryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.webhookId, webhookId) ||
                other.webhookId == webhookId) &&
            (identical(other.event, event) || other.event == event) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.response, response) ||
                other.response == response) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.attempt, attempt) || other.attempt == attempt) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            const DeepCollectionEquality().equals(
              other._requestHeaders,
              _requestHeaders,
            ) &&
            const DeepCollectionEquality().equals(
              other._responseHeaders,
              _responseHeaders,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    webhookId,
    event,
    const DeepCollectionEquality().hash(_payload),
    statusCode,
    response,
    createdAt,
    deliveredAt,
    success,
    attempt,
    error,
    responseTime,
    const DeepCollectionEquality().hash(_requestHeaders),
    const DeepCollectionEquality().hash(_responseHeaders),
  );

  /// Create a copy of WebhookDelivery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookDeliveryImplCopyWith<_$WebhookDeliveryImpl> get copyWith =>
      __$$WebhookDeliveryImplCopyWithImpl<_$WebhookDeliveryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookDeliveryImplToJson(this);
  }
}

abstract class _WebhookDelivery implements WebhookDelivery {
  const factory _WebhookDelivery({
    final String? id,
    final String? webhookId,
    final String? event,
    final Map<String, dynamic>? payload,
    final int? statusCode,
    final String? response,
    final DateTime? createdAt,
    final DateTime? deliveredAt,
    final bool? success,
    final int? attempt,
    final String? error,
    final int? responseTime,
    final Map<String, String>? requestHeaders,
    final Map<String, String>? responseHeaders,
  }) = _$WebhookDeliveryImpl;

  factory _WebhookDelivery.fromJson(Map<String, dynamic> json) =
      _$WebhookDeliveryImpl.fromJson;

  @override
  String? get id;
  @override
  String? get webhookId;
  @override
  String? get event;
  @override
  Map<String, dynamic>? get payload;
  @override
  int? get statusCode;
  @override
  String? get response;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get deliveredAt;
  @override
  bool? get success;
  @override
  int? get attempt;
  @override
  String? get error;
  @override
  int? get responseTime;
  @override
  Map<String, String>? get requestHeaders;
  @override
  Map<String, String>? get responseHeaders;

  /// Create a copy of WebhookDelivery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookDeliveryImplCopyWith<_$WebhookDeliveryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebhookEvent _$WebhookEventFromJson(Map<String, dynamic> json) {
  return _WebhookEvent.fromJson(json);
}

/// @nodoc
mixin _$WebhookEvent {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  Map<String, dynamic>? get samplePayload => throw _privateConstructorUsedError;
  bool? get isEnabled => throw _privateConstructorUsedError;

  /// Serializes this WebhookEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookEventCopyWith<WebhookEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookEventCopyWith<$Res> {
  factory $WebhookEventCopyWith(
    WebhookEvent value,
    $Res Function(WebhookEvent) then,
  ) = _$WebhookEventCopyWithImpl<$Res, WebhookEvent>;
  @useResult
  $Res call({
    String? id,
    String? name,
    String? description,
    String? category,
    Map<String, dynamic>? samplePayload,
    bool? isEnabled,
  });
}

/// @nodoc
class _$WebhookEventCopyWithImpl<$Res, $Val extends WebhookEvent>
    implements $WebhookEventCopyWith<$Res> {
  _$WebhookEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? samplePayload = freezed,
    Object? isEnabled = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            samplePayload: freezed == samplePayload
                ? _value.samplePayload
                : samplePayload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            isEnabled: freezed == isEnabled
                ? _value.isEnabled
                : isEnabled // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebhookEventImplCopyWith<$Res>
    implements $WebhookEventCopyWith<$Res> {
  factory _$$WebhookEventImplCopyWith(
    _$WebhookEventImpl value,
    $Res Function(_$WebhookEventImpl) then,
  ) = __$$WebhookEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? name,
    String? description,
    String? category,
    Map<String, dynamic>? samplePayload,
    bool? isEnabled,
  });
}

/// @nodoc
class __$$WebhookEventImplCopyWithImpl<$Res>
    extends _$WebhookEventCopyWithImpl<$Res, _$WebhookEventImpl>
    implements _$$WebhookEventImplCopyWith<$Res> {
  __$$WebhookEventImplCopyWithImpl(
    _$WebhookEventImpl _value,
    $Res Function(_$WebhookEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? samplePayload = freezed,
    Object? isEnabled = freezed,
  }) {
    return _then(
      _$WebhookEventImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        samplePayload: freezed == samplePayload
            ? _value._samplePayload
            : samplePayload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        isEnabled: freezed == isEnabled
            ? _value.isEnabled
            : isEnabled // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebhookEventImpl implements _WebhookEvent {
  const _$WebhookEventImpl({
    this.id,
    this.name,
    this.description,
    this.category,
    final Map<String, dynamic>? samplePayload,
    this.isEnabled,
  }) : _samplePayload = samplePayload;

  factory _$WebhookEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookEventImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? category;
  final Map<String, dynamic>? _samplePayload;
  @override
  Map<String, dynamic>? get samplePayload {
    final value = _samplePayload;
    if (value == null) return null;
    if (_samplePayload is EqualUnmodifiableMapView) return _samplePayload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? isEnabled;

  @override
  String toString() {
    return 'WebhookEvent(id: $id, name: $name, description: $description, category: $category, samplePayload: $samplePayload, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(
              other._samplePayload,
              _samplePayload,
            ) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    category,
    const DeepCollectionEquality().hash(_samplePayload),
    isEnabled,
  );

  /// Create a copy of WebhookEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookEventImplCopyWith<_$WebhookEventImpl> get copyWith =>
      __$$WebhookEventImplCopyWithImpl<_$WebhookEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookEventImplToJson(this);
  }
}

abstract class _WebhookEvent implements WebhookEvent {
  const factory _WebhookEvent({
    final String? id,
    final String? name,
    final String? description,
    final String? category,
    final Map<String, dynamic>? samplePayload,
    final bool? isEnabled,
  }) = _$WebhookEventImpl;

  factory _WebhookEvent.fromJson(Map<String, dynamic> json) =
      _$WebhookEventImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  String? get description;
  @override
  String? get category;
  @override
  Map<String, dynamic>? get samplePayload;
  @override
  bool? get isEnabled;

  /// Create a copy of WebhookEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookEventImplCopyWith<_$WebhookEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebhookStats _$WebhookStatsFromJson(Map<String, dynamic> json) {
  return _WebhookStats.fromJson(json);
}

/// @nodoc
mixin _$WebhookStats {
  String? get webhookId => throw _privateConstructorUsedError;
  int? get totalDeliveries => throw _privateConstructorUsedError;
  int? get successfulDeliveries => throw _privateConstructorUsedError;
  int? get failedDeliveries => throw _privateConstructorUsedError;
  double? get successRate => throw _privateConstructorUsedError;
  double? get averageResponseTime => throw _privateConstructorUsedError;
  DateTime? get lastDelivery => throw _privateConstructorUsedError;
  Map<String, int>? get deliveriesByDay => throw _privateConstructorUsedError;
  Map<String, int>? get deliveriesByEvent => throw _privateConstructorUsedError;
  List<WebhookDelivery>? get recentDeliveries =>
      throw _privateConstructorUsedError;

  /// Serializes this WebhookStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookStatsCopyWith<WebhookStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookStatsCopyWith<$Res> {
  factory $WebhookStatsCopyWith(
    WebhookStats value,
    $Res Function(WebhookStats) then,
  ) = _$WebhookStatsCopyWithImpl<$Res, WebhookStats>;
  @useResult
  $Res call({
    String? webhookId,
    int? totalDeliveries,
    int? successfulDeliveries,
    int? failedDeliveries,
    double? successRate,
    double? averageResponseTime,
    DateTime? lastDelivery,
    Map<String, int>? deliveriesByDay,
    Map<String, int>? deliveriesByEvent,
    List<WebhookDelivery>? recentDeliveries,
  });
}

/// @nodoc
class _$WebhookStatsCopyWithImpl<$Res, $Val extends WebhookStats>
    implements $WebhookStatsCopyWith<$Res> {
  _$WebhookStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? webhookId = freezed,
    Object? totalDeliveries = freezed,
    Object? successfulDeliveries = freezed,
    Object? failedDeliveries = freezed,
    Object? successRate = freezed,
    Object? averageResponseTime = freezed,
    Object? lastDelivery = freezed,
    Object? deliveriesByDay = freezed,
    Object? deliveriesByEvent = freezed,
    Object? recentDeliveries = freezed,
  }) {
    return _then(
      _value.copyWith(
            webhookId: freezed == webhookId
                ? _value.webhookId
                : webhookId // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalDeliveries: freezed == totalDeliveries
                ? _value.totalDeliveries
                : totalDeliveries // ignore: cast_nullable_to_non_nullable
                      as int?,
            successfulDeliveries: freezed == successfulDeliveries
                ? _value.successfulDeliveries
                : successfulDeliveries // ignore: cast_nullable_to_non_nullable
                      as int?,
            failedDeliveries: freezed == failedDeliveries
                ? _value.failedDeliveries
                : failedDeliveries // ignore: cast_nullable_to_non_nullable
                      as int?,
            successRate: freezed == successRate
                ? _value.successRate
                : successRate // ignore: cast_nullable_to_non_nullable
                      as double?,
            averageResponseTime: freezed == averageResponseTime
                ? _value.averageResponseTime
                : averageResponseTime // ignore: cast_nullable_to_non_nullable
                      as double?,
            lastDelivery: freezed == lastDelivery
                ? _value.lastDelivery
                : lastDelivery // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveriesByDay: freezed == deliveriesByDay
                ? _value.deliveriesByDay
                : deliveriesByDay // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>?,
            deliveriesByEvent: freezed == deliveriesByEvent
                ? _value.deliveriesByEvent
                : deliveriesByEvent // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>?,
            recentDeliveries: freezed == recentDeliveries
                ? _value.recentDeliveries
                : recentDeliveries // ignore: cast_nullable_to_non_nullable
                      as List<WebhookDelivery>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebhookStatsImplCopyWith<$Res>
    implements $WebhookStatsCopyWith<$Res> {
  factory _$$WebhookStatsImplCopyWith(
    _$WebhookStatsImpl value,
    $Res Function(_$WebhookStatsImpl) then,
  ) = __$$WebhookStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? webhookId,
    int? totalDeliveries,
    int? successfulDeliveries,
    int? failedDeliveries,
    double? successRate,
    double? averageResponseTime,
    DateTime? lastDelivery,
    Map<String, int>? deliveriesByDay,
    Map<String, int>? deliveriesByEvent,
    List<WebhookDelivery>? recentDeliveries,
  });
}

/// @nodoc
class __$$WebhookStatsImplCopyWithImpl<$Res>
    extends _$WebhookStatsCopyWithImpl<$Res, _$WebhookStatsImpl>
    implements _$$WebhookStatsImplCopyWith<$Res> {
  __$$WebhookStatsImplCopyWithImpl(
    _$WebhookStatsImpl _value,
    $Res Function(_$WebhookStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? webhookId = freezed,
    Object? totalDeliveries = freezed,
    Object? successfulDeliveries = freezed,
    Object? failedDeliveries = freezed,
    Object? successRate = freezed,
    Object? averageResponseTime = freezed,
    Object? lastDelivery = freezed,
    Object? deliveriesByDay = freezed,
    Object? deliveriesByEvent = freezed,
    Object? recentDeliveries = freezed,
  }) {
    return _then(
      _$WebhookStatsImpl(
        webhookId: freezed == webhookId
            ? _value.webhookId
            : webhookId // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalDeliveries: freezed == totalDeliveries
            ? _value.totalDeliveries
            : totalDeliveries // ignore: cast_nullable_to_non_nullable
                  as int?,
        successfulDeliveries: freezed == successfulDeliveries
            ? _value.successfulDeliveries
            : successfulDeliveries // ignore: cast_nullable_to_non_nullable
                  as int?,
        failedDeliveries: freezed == failedDeliveries
            ? _value.failedDeliveries
            : failedDeliveries // ignore: cast_nullable_to_non_nullable
                  as int?,
        successRate: freezed == successRate
            ? _value.successRate
            : successRate // ignore: cast_nullable_to_non_nullable
                  as double?,
        averageResponseTime: freezed == averageResponseTime
            ? _value.averageResponseTime
            : averageResponseTime // ignore: cast_nullable_to_non_nullable
                  as double?,
        lastDelivery: freezed == lastDelivery
            ? _value.lastDelivery
            : lastDelivery // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveriesByDay: freezed == deliveriesByDay
            ? _value._deliveriesByDay
            : deliveriesByDay // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>?,
        deliveriesByEvent: freezed == deliveriesByEvent
            ? _value._deliveriesByEvent
            : deliveriesByEvent // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>?,
        recentDeliveries: freezed == recentDeliveries
            ? _value._recentDeliveries
            : recentDeliveries // ignore: cast_nullable_to_non_nullable
                  as List<WebhookDelivery>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebhookStatsImpl implements _WebhookStats {
  const _$WebhookStatsImpl({
    this.webhookId,
    this.totalDeliveries,
    this.successfulDeliveries,
    this.failedDeliveries,
    this.successRate,
    this.averageResponseTime,
    this.lastDelivery,
    final Map<String, int>? deliveriesByDay,
    final Map<String, int>? deliveriesByEvent,
    final List<WebhookDelivery>? recentDeliveries,
  }) : _deliveriesByDay = deliveriesByDay,
       _deliveriesByEvent = deliveriesByEvent,
       _recentDeliveries = recentDeliveries;

  factory _$WebhookStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookStatsImplFromJson(json);

  @override
  final String? webhookId;
  @override
  final int? totalDeliveries;
  @override
  final int? successfulDeliveries;
  @override
  final int? failedDeliveries;
  @override
  final double? successRate;
  @override
  final double? averageResponseTime;
  @override
  final DateTime? lastDelivery;
  final Map<String, int>? _deliveriesByDay;
  @override
  Map<String, int>? get deliveriesByDay {
    final value = _deliveriesByDay;
    if (value == null) return null;
    if (_deliveriesByDay is EqualUnmodifiableMapView) return _deliveriesByDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, int>? _deliveriesByEvent;
  @override
  Map<String, int>? get deliveriesByEvent {
    final value = _deliveriesByEvent;
    if (value == null) return null;
    if (_deliveriesByEvent is EqualUnmodifiableMapView)
      return _deliveriesByEvent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<WebhookDelivery>? _recentDeliveries;
  @override
  List<WebhookDelivery>? get recentDeliveries {
    final value = _recentDeliveries;
    if (value == null) return null;
    if (_recentDeliveries is EqualUnmodifiableListView)
      return _recentDeliveries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'WebhookStats(webhookId: $webhookId, totalDeliveries: $totalDeliveries, successfulDeliveries: $successfulDeliveries, failedDeliveries: $failedDeliveries, successRate: $successRate, averageResponseTime: $averageResponseTime, lastDelivery: $lastDelivery, deliveriesByDay: $deliveriesByDay, deliveriesByEvent: $deliveriesByEvent, recentDeliveries: $recentDeliveries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookStatsImpl &&
            (identical(other.webhookId, webhookId) ||
                other.webhookId == webhookId) &&
            (identical(other.totalDeliveries, totalDeliveries) ||
                other.totalDeliveries == totalDeliveries) &&
            (identical(other.successfulDeliveries, successfulDeliveries) ||
                other.successfulDeliveries == successfulDeliveries) &&
            (identical(other.failedDeliveries, failedDeliveries) ||
                other.failedDeliveries == failedDeliveries) &&
            (identical(other.successRate, successRate) ||
                other.successRate == successRate) &&
            (identical(other.averageResponseTime, averageResponseTime) ||
                other.averageResponseTime == averageResponseTime) &&
            (identical(other.lastDelivery, lastDelivery) ||
                other.lastDelivery == lastDelivery) &&
            const DeepCollectionEquality().equals(
              other._deliveriesByDay,
              _deliveriesByDay,
            ) &&
            const DeepCollectionEquality().equals(
              other._deliveriesByEvent,
              _deliveriesByEvent,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentDeliveries,
              _recentDeliveries,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    webhookId,
    totalDeliveries,
    successfulDeliveries,
    failedDeliveries,
    successRate,
    averageResponseTime,
    lastDelivery,
    const DeepCollectionEquality().hash(_deliveriesByDay),
    const DeepCollectionEquality().hash(_deliveriesByEvent),
    const DeepCollectionEquality().hash(_recentDeliveries),
  );

  /// Create a copy of WebhookStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookStatsImplCopyWith<_$WebhookStatsImpl> get copyWith =>
      __$$WebhookStatsImplCopyWithImpl<_$WebhookStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookStatsImplToJson(this);
  }
}

abstract class _WebhookStats implements WebhookStats {
  const factory _WebhookStats({
    final String? webhookId,
    final int? totalDeliveries,
    final int? successfulDeliveries,
    final int? failedDeliveries,
    final double? successRate,
    final double? averageResponseTime,
    final DateTime? lastDelivery,
    final Map<String, int>? deliveriesByDay,
    final Map<String, int>? deliveriesByEvent,
    final List<WebhookDelivery>? recentDeliveries,
  }) = _$WebhookStatsImpl;

  factory _WebhookStats.fromJson(Map<String, dynamic> json) =
      _$WebhookStatsImpl.fromJson;

  @override
  String? get webhookId;
  @override
  int? get totalDeliveries;
  @override
  int? get successfulDeliveries;
  @override
  int? get failedDeliveries;
  @override
  double? get successRate;
  @override
  double? get averageResponseTime;
  @override
  DateTime? get lastDelivery;
  @override
  Map<String, int>? get deliveriesByDay;
  @override
  Map<String, int>? get deliveriesByEvent;
  @override
  List<WebhookDelivery>? get recentDeliveries;

  /// Create a copy of WebhookStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookStatsImplCopyWith<_$WebhookStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebhookTestRequest _$WebhookTestRequestFromJson(Map<String, dynamic> json) {
  return _WebhookTestRequest.fromJson(json);
}

/// @nodoc
mixin _$WebhookTestRequest {
  String get event => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customPayload => throw _privateConstructorUsedError;

  /// Serializes this WebhookTestRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookTestRequestCopyWith<WebhookTestRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookTestRequestCopyWith<$Res> {
  factory $WebhookTestRequestCopyWith(
    WebhookTestRequest value,
    $Res Function(WebhookTestRequest) then,
  ) = _$WebhookTestRequestCopyWithImpl<$Res, WebhookTestRequest>;
  @useResult
  $Res call({String event, Map<String, dynamic>? customPayload});
}

/// @nodoc
class _$WebhookTestRequestCopyWithImpl<$Res, $Val extends WebhookTestRequest>
    implements $WebhookTestRequestCopyWith<$Res> {
  _$WebhookTestRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? event = null, Object? customPayload = freezed}) {
    return _then(
      _value.copyWith(
            event: null == event
                ? _value.event
                : event // ignore: cast_nullable_to_non_nullable
                      as String,
            customPayload: freezed == customPayload
                ? _value.customPayload
                : customPayload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebhookTestRequestImplCopyWith<$Res>
    implements $WebhookTestRequestCopyWith<$Res> {
  factory _$$WebhookTestRequestImplCopyWith(
    _$WebhookTestRequestImpl value,
    $Res Function(_$WebhookTestRequestImpl) then,
  ) = __$$WebhookTestRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String event, Map<String, dynamic>? customPayload});
}

/// @nodoc
class __$$WebhookTestRequestImplCopyWithImpl<$Res>
    extends _$WebhookTestRequestCopyWithImpl<$Res, _$WebhookTestRequestImpl>
    implements _$$WebhookTestRequestImplCopyWith<$Res> {
  __$$WebhookTestRequestImplCopyWithImpl(
    _$WebhookTestRequestImpl _value,
    $Res Function(_$WebhookTestRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? event = null, Object? customPayload = freezed}) {
    return _then(
      _$WebhookTestRequestImpl(
        event: null == event
            ? _value.event
            : event // ignore: cast_nullable_to_non_nullable
                  as String,
        customPayload: freezed == customPayload
            ? _value._customPayload
            : customPayload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebhookTestRequestImpl implements _WebhookTestRequest {
  const _$WebhookTestRequestImpl({
    required this.event,
    final Map<String, dynamic>? customPayload,
  }) : _customPayload = customPayload;

  factory _$WebhookTestRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookTestRequestImplFromJson(json);

  @override
  final String event;
  final Map<String, dynamic>? _customPayload;
  @override
  Map<String, dynamic>? get customPayload {
    final value = _customPayload;
    if (value == null) return null;
    if (_customPayload is EqualUnmodifiableMapView) return _customPayload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'WebhookTestRequest(event: $event, customPayload: $customPayload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookTestRequestImpl &&
            (identical(other.event, event) || other.event == event) &&
            const DeepCollectionEquality().equals(
              other._customPayload,
              _customPayload,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    event,
    const DeepCollectionEquality().hash(_customPayload),
  );

  /// Create a copy of WebhookTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookTestRequestImplCopyWith<_$WebhookTestRequestImpl> get copyWith =>
      __$$WebhookTestRequestImplCopyWithImpl<_$WebhookTestRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookTestRequestImplToJson(this);
  }
}

abstract class _WebhookTestRequest implements WebhookTestRequest {
  const factory _WebhookTestRequest({
    required final String event,
    final Map<String, dynamic>? customPayload,
  }) = _$WebhookTestRequestImpl;

  factory _WebhookTestRequest.fromJson(Map<String, dynamic> json) =
      _$WebhookTestRequestImpl.fromJson;

  @override
  String get event;
  @override
  Map<String, dynamic>? get customPayload;

  /// Create a copy of WebhookTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookTestRequestImplCopyWith<_$WebhookTestRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebhookTestResponse _$WebhookTestResponseFromJson(Map<String, dynamic> json) {
  return _WebhookTestResponse.fromJson(json);
}

/// @nodoc
mixin _$WebhookTestResponse {
  bool? get success => throw _privateConstructorUsedError;
  int? get statusCode => throw _privateConstructorUsedError;
  String? get response => throw _privateConstructorUsedError;
  int? get responseTime => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, String>? get requestHeaders => throw _privateConstructorUsedError;
  Map<String, String>? get responseHeaders =>
      throw _privateConstructorUsedError;

  /// Serializes this WebhookTestResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookTestResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookTestResponseCopyWith<WebhookTestResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookTestResponseCopyWith<$Res> {
  factory $WebhookTestResponseCopyWith(
    WebhookTestResponse value,
    $Res Function(WebhookTestResponse) then,
  ) = _$WebhookTestResponseCopyWithImpl<$Res, WebhookTestResponse>;
  @useResult
  $Res call({
    bool? success,
    int? statusCode,
    String? response,
    int? responseTime,
    String? error,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
  });
}

/// @nodoc
class _$WebhookTestResponseCopyWithImpl<$Res, $Val extends WebhookTestResponse>
    implements $WebhookTestResponseCopyWith<$Res> {
  _$WebhookTestResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookTestResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? statusCode = freezed,
    Object? response = freezed,
    Object? responseTime = freezed,
    Object? error = freezed,
    Object? requestHeaders = freezed,
    Object? responseHeaders = freezed,
  }) {
    return _then(
      _value.copyWith(
            success: freezed == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool?,
            statusCode: freezed == statusCode
                ? _value.statusCode
                : statusCode // ignore: cast_nullable_to_non_nullable
                      as int?,
            response: freezed == response
                ? _value.response
                : response // ignore: cast_nullable_to_non_nullable
                      as String?,
            responseTime: freezed == responseTime
                ? _value.responseTime
                : responseTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            requestHeaders: freezed == requestHeaders
                ? _value.requestHeaders
                : requestHeaders // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            responseHeaders: freezed == responseHeaders
                ? _value.responseHeaders
                : responseHeaders // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebhookTestResponseImplCopyWith<$Res>
    implements $WebhookTestResponseCopyWith<$Res> {
  factory _$$WebhookTestResponseImplCopyWith(
    _$WebhookTestResponseImpl value,
    $Res Function(_$WebhookTestResponseImpl) then,
  ) = __$$WebhookTestResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool? success,
    int? statusCode,
    String? response,
    int? responseTime,
    String? error,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
  });
}

/// @nodoc
class __$$WebhookTestResponseImplCopyWithImpl<$Res>
    extends _$WebhookTestResponseCopyWithImpl<$Res, _$WebhookTestResponseImpl>
    implements _$$WebhookTestResponseImplCopyWith<$Res> {
  __$$WebhookTestResponseImplCopyWithImpl(
    _$WebhookTestResponseImpl _value,
    $Res Function(_$WebhookTestResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookTestResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? statusCode = freezed,
    Object? response = freezed,
    Object? responseTime = freezed,
    Object? error = freezed,
    Object? requestHeaders = freezed,
    Object? responseHeaders = freezed,
  }) {
    return _then(
      _$WebhookTestResponseImpl(
        success: freezed == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool?,
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
        response: freezed == response
            ? _value.response
            : response // ignore: cast_nullable_to_non_nullable
                  as String?,
        responseTime: freezed == responseTime
            ? _value.responseTime
            : responseTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestHeaders: freezed == requestHeaders
            ? _value._requestHeaders
            : requestHeaders // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        responseHeaders: freezed == responseHeaders
            ? _value._responseHeaders
            : responseHeaders // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebhookTestResponseImpl implements _WebhookTestResponse {
  const _$WebhookTestResponseImpl({
    this.success,
    this.statusCode,
    this.response,
    this.responseTime,
    this.error,
    final Map<String, String>? requestHeaders,
    final Map<String, String>? responseHeaders,
  }) : _requestHeaders = requestHeaders,
       _responseHeaders = responseHeaders;

  factory _$WebhookTestResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookTestResponseImplFromJson(json);

  @override
  final bool? success;
  @override
  final int? statusCode;
  @override
  final String? response;
  @override
  final int? responseTime;
  @override
  final String? error;
  final Map<String, String>? _requestHeaders;
  @override
  Map<String, String>? get requestHeaders {
    final value = _requestHeaders;
    if (value == null) return null;
    if (_requestHeaders is EqualUnmodifiableMapView) return _requestHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, String>? _responseHeaders;
  @override
  Map<String, String>? get responseHeaders {
    final value = _responseHeaders;
    if (value == null) return null;
    if (_responseHeaders is EqualUnmodifiableMapView) return _responseHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'WebhookTestResponse(success: $success, statusCode: $statusCode, response: $response, responseTime: $responseTime, error: $error, requestHeaders: $requestHeaders, responseHeaders: $responseHeaders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookTestResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.response, response) ||
                other.response == response) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(
              other._requestHeaders,
              _requestHeaders,
            ) &&
            const DeepCollectionEquality().equals(
              other._responseHeaders,
              _responseHeaders,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    statusCode,
    response,
    responseTime,
    error,
    const DeepCollectionEquality().hash(_requestHeaders),
    const DeepCollectionEquality().hash(_responseHeaders),
  );

  /// Create a copy of WebhookTestResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookTestResponseImplCopyWith<_$WebhookTestResponseImpl> get copyWith =>
      __$$WebhookTestResponseImplCopyWithImpl<_$WebhookTestResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookTestResponseImplToJson(this);
  }
}

abstract class _WebhookTestResponse implements WebhookTestResponse {
  const factory _WebhookTestResponse({
    final bool? success,
    final int? statusCode,
    final String? response,
    final int? responseTime,
    final String? error,
    final Map<String, String>? requestHeaders,
    final Map<String, String>? responseHeaders,
  }) = _$WebhookTestResponseImpl;

  factory _WebhookTestResponse.fromJson(Map<String, dynamic> json) =
      _$WebhookTestResponseImpl.fromJson;

  @override
  bool? get success;
  @override
  int? get statusCode;
  @override
  String? get response;
  @override
  int? get responseTime;
  @override
  String? get error;
  @override
  Map<String, String>? get requestHeaders;
  @override
  Map<String, String>? get responseHeaders;

  /// Create a copy of WebhookTestResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookTestResponseImplCopyWith<_$WebhookTestResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebhookTemplate _$WebhookTemplateFromJson(Map<String, dynamic> json) {
  return _WebhookTemplate.fromJson(json);
}

/// @nodoc
mixin _$WebhookTemplate {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  List<String>? get events => throw _privateConstructorUsedError;
  Map<String, String>? get headers => throw _privateConstructorUsedError;
  Map<String, dynamic>? get config => throw _privateConstructorUsedError;
  String? get documentation => throw _privateConstructorUsedError;

  /// Serializes this WebhookTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebhookTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebhookTemplateCopyWith<WebhookTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebhookTemplateCopyWith<$Res> {
  factory $WebhookTemplateCopyWith(
    WebhookTemplate value,
    $Res Function(WebhookTemplate) then,
  ) = _$WebhookTemplateCopyWithImpl<$Res, WebhookTemplate>;
  @useResult
  $Res call({
    String? id,
    String? name,
    String? description,
    String? category,
    String? url,
    List<String>? events,
    Map<String, String>? headers,
    Map<String, dynamic>? config,
    String? documentation,
  });
}

/// @nodoc
class _$WebhookTemplateCopyWithImpl<$Res, $Val extends WebhookTemplate>
    implements $WebhookTemplateCopyWith<$Res> {
  _$WebhookTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebhookTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? url = freezed,
    Object? events = freezed,
    Object? headers = freezed,
    Object? config = freezed,
    Object? documentation = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            events: freezed == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            headers: freezed == headers
                ? _value.headers
                : headers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            config: freezed == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            documentation: freezed == documentation
                ? _value.documentation
                : documentation // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebhookTemplateImplCopyWith<$Res>
    implements $WebhookTemplateCopyWith<$Res> {
  factory _$$WebhookTemplateImplCopyWith(
    _$WebhookTemplateImpl value,
    $Res Function(_$WebhookTemplateImpl) then,
  ) = __$$WebhookTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? name,
    String? description,
    String? category,
    String? url,
    List<String>? events,
    Map<String, String>? headers,
    Map<String, dynamic>? config,
    String? documentation,
  });
}

/// @nodoc
class __$$WebhookTemplateImplCopyWithImpl<$Res>
    extends _$WebhookTemplateCopyWithImpl<$Res, _$WebhookTemplateImpl>
    implements _$$WebhookTemplateImplCopyWith<$Res> {
  __$$WebhookTemplateImplCopyWithImpl(
    _$WebhookTemplateImpl _value,
    $Res Function(_$WebhookTemplateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebhookTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? category = freezed,
    Object? url = freezed,
    Object? events = freezed,
    Object? headers = freezed,
    Object? config = freezed,
    Object? documentation = freezed,
  }) {
    return _then(
      _$WebhookTemplateImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        events: freezed == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        headers: freezed == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        config: freezed == config
            ? _value._config
            : config // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        documentation: freezed == documentation
            ? _value.documentation
            : documentation // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebhookTemplateImpl implements _WebhookTemplate {
  const _$WebhookTemplateImpl({
    this.id,
    this.name,
    this.description,
    this.category,
    this.url,
    final List<String>? events,
    final Map<String, String>? headers,
    final Map<String, dynamic>? config,
    this.documentation,
  }) : _events = events,
       _headers = headers,
       _config = config;

  factory _$WebhookTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebhookTemplateImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final String? url;
  final List<String>? _events;
  @override
  List<String>? get events {
    final value = _events;
    if (value == null) return null;
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _config;
  @override
  Map<String, dynamic>? get config {
    final value = _config;
    if (value == null) return null;
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? documentation;

  @override
  String toString() {
    return 'WebhookTemplate(id: $id, name: $name, description: $description, category: $category, url: $url, events: $events, headers: $headers, config: $config, documentation: $documentation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebhookTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            (identical(other.documentation, documentation) ||
                other.documentation == documentation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    category,
    url,
    const DeepCollectionEquality().hash(_events),
    const DeepCollectionEquality().hash(_headers),
    const DeepCollectionEquality().hash(_config),
    documentation,
  );

  /// Create a copy of WebhookTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebhookTemplateImplCopyWith<_$WebhookTemplateImpl> get copyWith =>
      __$$WebhookTemplateImplCopyWithImpl<_$WebhookTemplateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WebhookTemplateImplToJson(this);
  }
}

abstract class _WebhookTemplate implements WebhookTemplate {
  const factory _WebhookTemplate({
    final String? id,
    final String? name,
    final String? description,
    final String? category,
    final String? url,
    final List<String>? events,
    final Map<String, String>? headers,
    final Map<String, dynamic>? config,
    final String? documentation,
  }) = _$WebhookTemplateImpl;

  factory _WebhookTemplate.fromJson(Map<String, dynamic> json) =
      _$WebhookTemplateImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  String? get description;
  @override
  String? get category;
  @override
  String? get url;
  @override
  List<String>? get events;
  @override
  Map<String, String>? get headers;
  @override
  Map<String, dynamic>? get config;
  @override
  String? get documentation;

  /// Create a copy of WebhookTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebhookTemplateImplCopyWith<_$WebhookTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
