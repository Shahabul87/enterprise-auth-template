// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppException {
  String get message => throw _privateConstructorUsedError;
  Map<String, dynamic>? get details => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppExceptionCopyWith<AppException> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppExceptionCopyWith<$Res> {
  factory $AppExceptionCopyWith(
    AppException value,
    $Res Function(AppException) then,
  ) = _$AppExceptionCopyWithImpl<$Res, AppException>;
  @useResult
  $Res call({String message, Map<String, dynamic>? details});
}

/// @nodoc
class _$AppExceptionCopyWithImpl<$Res, $Val extends AppException>
    implements $AppExceptionCopyWith<$Res> {
  _$AppExceptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? details = freezed}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            details: freezed == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$NetworkExceptionImplCopyWith(
    _$NetworkExceptionImpl value,
    $Res Function(_$NetworkExceptionImpl) then,
  ) = __$$NetworkExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    int? statusCode,
    String? endpoint,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$NetworkExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$NetworkExceptionImpl>
    implements _$$NetworkExceptionImplCopyWith<$Res> {
  __$$NetworkExceptionImplCopyWithImpl(
    _$NetworkExceptionImpl _value,
    $Res Function(_$NetworkExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? endpoint = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$NetworkExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
        endpoint: freezed == endpoint
            ? _value.endpoint
            : endpoint // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$NetworkExceptionImpl implements NetworkException {
  const _$NetworkExceptionImpl({
    required this.message,
    this.statusCode,
    this.endpoint,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? endpoint;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.network(message: $message, statusCode: $statusCode, endpoint: $endpoint, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    statusCode,
    endpoint,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      __$$NetworkExceptionImplCopyWithImpl<_$NetworkExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return network(message, statusCode, endpoint, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return network?.call(message, statusCode, endpoint, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, statusCode, endpoint, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkException implements AppException {
  const factory NetworkException({
    required final String message,
    final int? statusCode,
    final String? endpoint,
    final Map<String, dynamic>? details,
  }) = _$NetworkExceptionImpl;

  @override
  String get message;
  int? get statusCode;
  String? get endpoint;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthenticationExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$AuthenticationExceptionImplCopyWith(
    _$AuthenticationExceptionImpl value,
    $Res Function(_$AuthenticationExceptionImpl) then,
  ) = __$$AuthenticationExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? reason, Map<String, dynamic>? details});
}

/// @nodoc
class __$$AuthenticationExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$AuthenticationExceptionImpl>
    implements _$$AuthenticationExceptionImplCopyWith<$Res> {
  __$$AuthenticationExceptionImplCopyWithImpl(
    _$AuthenticationExceptionImpl _value,
    $Res Function(_$AuthenticationExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? reason = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$AuthenticationExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$AuthenticationExceptionImpl implements AuthenticationException {
  const _$AuthenticationExceptionImpl({
    required this.message,
    this.reason,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final String? reason;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.authentication(message: $message, reason: $reason, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticationExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    reason,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticationExceptionImplCopyWith<_$AuthenticationExceptionImpl>
  get copyWith =>
      __$$AuthenticationExceptionImplCopyWithImpl<
        _$AuthenticationExceptionImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return authentication(message, reason, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return authentication?.call(message, reason, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (authentication != null) {
      return authentication(message, reason, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return authentication(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return authentication?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (authentication != null) {
      return authentication(this);
    }
    return orElse();
  }
}

abstract class AuthenticationException implements AppException {
  const factory AuthenticationException({
    required final String message,
    final String? reason,
    final Map<String, dynamic>? details,
  }) = _$AuthenticationExceptionImpl;

  @override
  String get message;
  String? get reason;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticationExceptionImplCopyWith<_$AuthenticationExceptionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthorizationExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$AuthorizationExceptionImplCopyWith(
    _$AuthorizationExceptionImpl value,
    $Res Function(_$AuthorizationExceptionImpl) then,
  ) = __$$AuthorizationExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    String? requiredPermission,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$AuthorizationExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$AuthorizationExceptionImpl>
    implements _$$AuthorizationExceptionImplCopyWith<$Res> {
  __$$AuthorizationExceptionImplCopyWithImpl(
    _$AuthorizationExceptionImpl _value,
    $Res Function(_$AuthorizationExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? requiredPermission = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$AuthorizationExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        requiredPermission: freezed == requiredPermission
            ? _value.requiredPermission
            : requiredPermission // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$AuthorizationExceptionImpl implements AuthorizationException {
  const _$AuthorizationExceptionImpl({
    required this.message,
    this.requiredPermission,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final String? requiredPermission;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.authorization(message: $message, requiredPermission: $requiredPermission, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizationExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.requiredPermission, requiredPermission) ||
                other.requiredPermission == requiredPermission) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    requiredPermission,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizationExceptionImplCopyWith<_$AuthorizationExceptionImpl>
  get copyWith =>
      __$$AuthorizationExceptionImplCopyWithImpl<_$AuthorizationExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return authorization(message, requiredPermission, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return authorization?.call(message, requiredPermission, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (authorization != null) {
      return authorization(message, requiredPermission, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return authorization(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return authorization?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (authorization != null) {
      return authorization(this);
    }
    return orElse();
  }
}

abstract class AuthorizationException implements AppException {
  const factory AuthorizationException({
    required final String message,
    final String? requiredPermission,
    final Map<String, dynamic>? details,
  }) = _$AuthorizationExceptionImpl;

  @override
  String get message;
  String? get requiredPermission;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthorizationExceptionImplCopyWith<_$AuthorizationExceptionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ValidationExceptionImplCopyWith(
    _$ValidationExceptionImpl value,
    $Res Function(_$ValidationExceptionImpl) then,
  ) = __$$ValidationExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    Map<String, List<String>>? fieldErrors,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$ValidationExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ValidationExceptionImpl>
    implements _$$ValidationExceptionImplCopyWith<$Res> {
  __$$ValidationExceptionImplCopyWithImpl(
    _$ValidationExceptionImpl _value,
    $Res Function(_$ValidationExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? fieldErrors = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$ValidationExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        fieldErrors: freezed == fieldErrors
            ? _value._fieldErrors
            : fieldErrors // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<String>>?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$ValidationExceptionImpl implements ValidationException {
  const _$ValidationExceptionImpl({
    required this.message,
    final Map<String, List<String>>? fieldErrors,
    final Map<String, dynamic>? details,
  }) : _fieldErrors = fieldErrors,
       _details = details;

  @override
  final String message;
  final Map<String, List<String>>? _fieldErrors;
  @override
  Map<String, List<String>>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.validation(message: $message, fieldErrors: $fieldErrors, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(
              other._fieldErrors,
              _fieldErrors,
            ) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(_fieldErrors),
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationExceptionImplCopyWith<_$ValidationExceptionImpl> get copyWith =>
      __$$ValidationExceptionImplCopyWithImpl<_$ValidationExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return validation(message, fieldErrors, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return validation?.call(message, fieldErrors, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, fieldErrors, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationException implements AppException {
  const factory ValidationException({
    required final String message,
    final Map<String, List<String>>? fieldErrors,
    final Map<String, dynamic>? details,
  }) = _$ValidationExceptionImpl;

  @override
  String get message;
  Map<String, List<String>>? get fieldErrors;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationExceptionImplCopyWith<_$ValidationExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$NotFoundExceptionImplCopyWith(
    _$NotFoundExceptionImpl value,
    $Res Function(_$NotFoundExceptionImpl) then,
  ) = __$$NotFoundExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? resource, Map<String, dynamic>? details});
}

/// @nodoc
class __$$NotFoundExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$NotFoundExceptionImpl>
    implements _$$NotFoundExceptionImplCopyWith<$Res> {
  __$$NotFoundExceptionImplCopyWithImpl(
    _$NotFoundExceptionImpl _value,
    $Res Function(_$NotFoundExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? resource = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$NotFoundExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        resource: freezed == resource
            ? _value.resource
            : resource // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$NotFoundExceptionImpl implements NotFoundException {
  const _$NotFoundExceptionImpl({
    required this.message,
    this.resource,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final String? resource;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.notFound(message: $message, resource: $resource, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.resource, resource) ||
                other.resource == resource) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    resource,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundExceptionImplCopyWith<_$NotFoundExceptionImpl> get copyWith =>
      __$$NotFoundExceptionImplCopyWithImpl<_$NotFoundExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return notFound(message, resource, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return notFound?.call(message, resource, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message, resource, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundException implements AppException {
  const factory NotFoundException({
    required final String message,
    final String? resource,
    final Map<String, dynamic>? details,
  }) = _$NotFoundExceptionImpl;

  @override
  String get message;
  String? get resource;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundExceptionImplCopyWith<_$NotFoundExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ServerExceptionImplCopyWith(
    _$ServerExceptionImpl value,
    $Res Function(_$ServerExceptionImpl) then,
  ) = __$$ServerExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    int? statusCode,
    String? errorCode,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$ServerExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ServerExceptionImpl>
    implements _$$ServerExceptionImplCopyWith<$Res> {
  __$$ServerExceptionImplCopyWithImpl(
    _$ServerExceptionImpl _value,
    $Res Function(_$ServerExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? errorCode = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$ServerExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
        errorCode: freezed == errorCode
            ? _value.errorCode
            : errorCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$ServerExceptionImpl implements ServerException {
  const _$ServerExceptionImpl({
    required this.message,
    this.statusCode,
    this.errorCode,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? errorCode;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.server(message: $message, statusCode: $statusCode, errorCode: $errorCode, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    statusCode,
    errorCode,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerExceptionImplCopyWith<_$ServerExceptionImpl> get copyWith =>
      __$$ServerExceptionImplCopyWithImpl<_$ServerExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return server(message, statusCode, errorCode, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return server?.call(message, statusCode, errorCode, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(message, statusCode, errorCode, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerException implements AppException {
  const factory ServerException({
    required final String message,
    final int? statusCode,
    final String? errorCode,
    final Map<String, dynamic>? details,
  }) = _$ServerExceptionImpl;

  @override
  String get message;
  int? get statusCode;
  String? get errorCode;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerExceptionImplCopyWith<_$ServerExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TimeoutExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$TimeoutExceptionImplCopyWith(
    _$TimeoutExceptionImpl value,
    $Res Function(_$TimeoutExceptionImpl) then,
  ) = __$$TimeoutExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    Duration? duration,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$TimeoutExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$TimeoutExceptionImpl>
    implements _$$TimeoutExceptionImplCopyWith<$Res> {
  __$$TimeoutExceptionImplCopyWithImpl(
    _$TimeoutExceptionImpl _value,
    $Res Function(_$TimeoutExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? duration = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$TimeoutExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as Duration?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$TimeoutExceptionImpl implements TimeoutException {
  const _$TimeoutExceptionImpl({
    required this.message,
    this.duration,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final Duration? duration;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.timeout(message: $message, duration: $duration, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeoutExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    duration,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeoutExceptionImplCopyWith<_$TimeoutExceptionImpl> get copyWith =>
      __$$TimeoutExceptionImplCopyWithImpl<_$TimeoutExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return timeout(message, duration, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return timeout?.call(message, duration, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (timeout != null) {
      return timeout(message, duration, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return timeout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return timeout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (timeout != null) {
      return timeout(this);
    }
    return orElse();
  }
}

abstract class TimeoutException implements AppException {
  const factory TimeoutException({
    required final String message,
    final Duration? duration,
    final Map<String, dynamic>? details,
  }) = _$TimeoutExceptionImpl;

  @override
  String get message;
  Duration? get duration;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeoutExceptionImplCopyWith<_$TimeoutExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectivityExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$ConnectivityExceptionImplCopyWith(
    _$ConnectivityExceptionImpl value,
    $Res Function(_$ConnectivityExceptionImpl) then,
  ) = __$$ConnectivityExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? type, Map<String, dynamic>? details});
}

/// @nodoc
class __$$ConnectivityExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$ConnectivityExceptionImpl>
    implements _$$ConnectivityExceptionImplCopyWith<$Res> {
  __$$ConnectivityExceptionImplCopyWithImpl(
    _$ConnectivityExceptionImpl _value,
    $Res Function(_$ConnectivityExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? type = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$ConnectivityExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$ConnectivityExceptionImpl implements ConnectivityException {
  const _$ConnectivityExceptionImpl({
    required this.message,
    this.type,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final String? type;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.connectivity(message: $message, type: $type, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectivityExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    type,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectivityExceptionImplCopyWith<_$ConnectivityExceptionImpl>
  get copyWith =>
      __$$ConnectivityExceptionImplCopyWithImpl<_$ConnectivityExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return connectivity(message, type, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return connectivity?.call(message, type, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (connectivity != null) {
      return connectivity(message, type, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return connectivity(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return connectivity?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (connectivity != null) {
      return connectivity(this);
    }
    return orElse();
  }
}

abstract class ConnectivityException implements AppException {
  const factory ConnectivityException({
    required final String message,
    final String? type,
    final Map<String, dynamic>? details,
  }) = _$ConnectivityExceptionImpl;

  @override
  String get message;
  String? get type;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectivityExceptionImplCopyWith<_$ConnectivityExceptionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StorageExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$StorageExceptionImplCopyWith(
    _$StorageExceptionImpl value,
    $Res Function(_$StorageExceptionImpl) then,
  ) = __$$StorageExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? operation, Map<String, dynamic>? details});
}

/// @nodoc
class __$$StorageExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$StorageExceptionImpl>
    implements _$$StorageExceptionImplCopyWith<$Res> {
  __$$StorageExceptionImplCopyWithImpl(
    _$StorageExceptionImpl _value,
    $Res Function(_$StorageExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? operation = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$StorageExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        operation: freezed == operation
            ? _value.operation
            : operation // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$StorageExceptionImpl implements StorageException {
  const _$StorageExceptionImpl({
    required this.message,
    this.operation,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final String? operation;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.storage(message: $message, operation: $operation, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.operation, operation) ||
                other.operation == operation) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    operation,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageExceptionImplCopyWith<_$StorageExceptionImpl> get copyWith =>
      __$$StorageExceptionImplCopyWithImpl<_$StorageExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return storage(message, operation, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return storage?.call(message, operation, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(message, operation, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return storage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return storage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(this);
    }
    return orElse();
  }
}

abstract class StorageException implements AppException {
  const factory StorageException({
    required final String message,
    final String? operation,
    final Map<String, dynamic>? details,
  }) = _$StorageExceptionImpl;

  @override
  String get message;
  String? get operation;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StorageExceptionImplCopyWith<_$StorageExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PermissionExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$PermissionExceptionImplCopyWith(
    _$PermissionExceptionImpl value,
    $Res Function(_$PermissionExceptionImpl) then,
  ) = __$$PermissionExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    String? permission,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$PermissionExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$PermissionExceptionImpl>
    implements _$$PermissionExceptionImplCopyWith<$Res> {
  __$$PermissionExceptionImplCopyWithImpl(
    _$PermissionExceptionImpl _value,
    $Res Function(_$PermissionExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? permission = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$PermissionExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        permission: freezed == permission
            ? _value.permission
            : permission // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$PermissionExceptionImpl implements PermissionException {
  const _$PermissionExceptionImpl({
    required this.message,
    this.permission,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final String? permission;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.permission(message: $message, permission: $permission, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.permission, permission) ||
                other.permission == permission) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    permission,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionExceptionImplCopyWith<_$PermissionExceptionImpl> get copyWith =>
      __$$PermissionExceptionImplCopyWithImpl<_$PermissionExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return permission(message, this.permission, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return permission?.call(message, this.permission, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(message, this.permission, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return permission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return permission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(this);
    }
    return orElse();
  }
}

abstract class PermissionException implements AppException {
  const factory PermissionException({
    required final String message,
    final String? permission,
    final Map<String, dynamic>? details,
  }) = _$PermissionExceptionImpl;

  @override
  String get message;
  String? get permission;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionExceptionImplCopyWith<_$PermissionExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RateLimitedExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$RateLimitedExceptionImplCopyWith(
    _$RateLimitedExceptionImpl value,
    $Res Function(_$RateLimitedExceptionImpl) then,
  ) = __$$RateLimitedExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    Duration? retryAfter,
    int? limit,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$RateLimitedExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$RateLimitedExceptionImpl>
    implements _$$RateLimitedExceptionImplCopyWith<$Res> {
  __$$RateLimitedExceptionImplCopyWithImpl(
    _$RateLimitedExceptionImpl _value,
    $Res Function(_$RateLimitedExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? retryAfter = freezed,
    Object? limit = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$RateLimitedExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        retryAfter: freezed == retryAfter
            ? _value.retryAfter
            : retryAfter // ignore: cast_nullable_to_non_nullable
                  as Duration?,
        limit: freezed == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$RateLimitedExceptionImpl implements RateLimitedException {
  const _$RateLimitedExceptionImpl({
    required this.message,
    this.retryAfter,
    this.limit,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final Duration? retryAfter;
  @override
  final int? limit;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.rateLimited(message: $message, retryAfter: $retryAfter, limit: $limit, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitedExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.retryAfter, retryAfter) ||
                other.retryAfter == retryAfter) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    retryAfter,
    limit,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitedExceptionImplCopyWith<_$RateLimitedExceptionImpl>
  get copyWith =>
      __$$RateLimitedExceptionImplCopyWithImpl<_$RateLimitedExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return rateLimited(message, retryAfter, limit, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return rateLimited?.call(message, retryAfter, limit, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (rateLimited != null) {
      return rateLimited(message, retryAfter, limit, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return rateLimited(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return rateLimited?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (rateLimited != null) {
      return rateLimited(this);
    }
    return orElse();
  }
}

abstract class RateLimitedException implements AppException {
  const factory RateLimitedException({
    required final String message,
    final Duration? retryAfter,
    final int? limit,
    final Map<String, dynamic>? details,
  }) = _$RateLimitedExceptionImpl;

  @override
  String get message;
  Duration? get retryAfter;
  int? get limit;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitedExceptionImplCopyWith<_$RateLimitedExceptionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BusinessExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$BusinessExceptionImplCopyWith(
    _$BusinessExceptionImpl value,
    $Res Function(_$BusinessExceptionImpl) then,
  ) = __$$BusinessExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? details});
}

/// @nodoc
class __$$BusinessExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$BusinessExceptionImpl>
    implements _$$BusinessExceptionImplCopyWith<$Res> {
  __$$BusinessExceptionImplCopyWithImpl(
    _$BusinessExceptionImpl _value,
    $Res Function(_$BusinessExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$BusinessExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$BusinessExceptionImpl implements BusinessException {
  const _$BusinessExceptionImpl({
    required this.message,
    this.code,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.business(message: $message, code: $code, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessExceptionImplCopyWith<_$BusinessExceptionImpl> get copyWith =>
      __$$BusinessExceptionImplCopyWithImpl<_$BusinessExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return business(message, code, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return business?.call(message, code, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (business != null) {
      return business(message, code, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return business(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return business?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (business != null) {
      return business(this);
    }
    return orElse();
  }
}

abstract class BusinessException implements AppException {
  const factory BusinessException({
    required final String message,
    final String? code,
    final Map<String, dynamic>? details,
  }) = _$BusinessExceptionImpl;

  @override
  String get message;
  String? get code;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessExceptionImplCopyWith<_$BusinessExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$UnknownExceptionImplCopyWith(
    _$UnknownExceptionImpl value,
    $Res Function(_$UnknownExceptionImpl) then,
  ) = __$$UnknownExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String message,
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$UnknownExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$UnknownExceptionImpl>
    implements _$$UnknownExceptionImplCopyWith<$Res> {
  __$$UnknownExceptionImplCopyWithImpl(
    _$UnknownExceptionImpl _value,
    $Res Function(_$UnknownExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? originalError = freezed,
    Object? stackTrace = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$UnknownExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        originalError: freezed == originalError
            ? _value.originalError
            : originalError,
        stackTrace: freezed == stackTrace
            ? _value.stackTrace
            : stackTrace // ignore: cast_nullable_to_non_nullable
                  as StackTrace?,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

class _$UnknownExceptionImpl implements UnknownException {
  const _$UnknownExceptionImpl({
    required this.message,
    this.originalError,
    this.stackTrace,
    final Map<String, dynamic>? details,
  }) : _details = details;

  @override
  final String message;
  @override
  final Object? originalError;
  @override
  final StackTrace? stackTrace;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppException.unknown(message: $message, originalError: $originalError, stackTrace: $stackTrace, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(
              other.originalError,
              originalError,
            ) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(originalError),
    stackTrace,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith =>
      __$$UnknownExceptionImplCopyWithImpl<_$UnknownExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )
    network,
    required TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )
    authentication,
    required TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )
    authorization,
    required TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )
    validation,
    required TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )
    notFound,
    required TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )
    server,
    required TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )
    timeout,
    required TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )
    connectivity,
    required TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )
    storage,
    required TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )
    permission,
    required TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )
    rateLimited,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )
    business,
    required TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )
    unknown,
  }) {
    return unknown(message, originalError, stackTrace, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult? Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult? Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult? Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult? Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult? Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult? Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult? Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult? Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult? Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult? Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult? Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
  }) {
    return unknown?.call(message, originalError, stackTrace, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String message,
      int? statusCode,
      String? endpoint,
      Map<String, dynamic>? details,
    )?
    network,
    TResult Function(
      String message,
      String? reason,
      Map<String, dynamic>? details,
    )?
    authentication,
    TResult Function(
      String message,
      String? requiredPermission,
      Map<String, dynamic>? details,
    )?
    authorization,
    TResult Function(
      String message,
      Map<String, List<String>>? fieldErrors,
      Map<String, dynamic>? details,
    )?
    validation,
    TResult Function(
      String message,
      String? resource,
      Map<String, dynamic>? details,
    )?
    notFound,
    TResult Function(
      String message,
      int? statusCode,
      String? errorCode,
      Map<String, dynamic>? details,
    )?
    server,
    TResult Function(
      String message,
      Duration? duration,
      Map<String, dynamic>? details,
    )?
    timeout,
    TResult Function(
      String message,
      String? type,
      Map<String, dynamic>? details,
    )?
    connectivity,
    TResult Function(
      String message,
      String? operation,
      Map<String, dynamic>? details,
    )?
    storage,
    TResult Function(
      String message,
      String? permission,
      Map<String, dynamic>? details,
    )?
    permission,
    TResult Function(
      String message,
      Duration? retryAfter,
      int? limit,
      Map<String, dynamic>? details,
    )?
    rateLimited,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? details,
    )?
    business,
    TResult Function(
      String message,
      Object? originalError,
      StackTrace? stackTrace,
      Map<String, dynamic>? details,
    )?
    unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, originalError, stackTrace, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthenticationException value) authentication,
    required TResult Function(AuthorizationException value) authorization,
    required TResult Function(ValidationException value) validation,
    required TResult Function(NotFoundException value) notFound,
    required TResult Function(ServerException value) server,
    required TResult Function(TimeoutException value) timeout,
    required TResult Function(ConnectivityException value) connectivity,
    required TResult Function(StorageException value) storage,
    required TResult Function(PermissionException value) permission,
    required TResult Function(RateLimitedException value) rateLimited,
    required TResult Function(BusinessException value) business,
    required TResult Function(UnknownException value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthenticationException value)? authentication,
    TResult? Function(AuthorizationException value)? authorization,
    TResult? Function(ValidationException value)? validation,
    TResult? Function(NotFoundException value)? notFound,
    TResult? Function(ServerException value)? server,
    TResult? Function(TimeoutException value)? timeout,
    TResult? Function(ConnectivityException value)? connectivity,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PermissionException value)? permission,
    TResult? Function(RateLimitedException value)? rateLimited,
    TResult? Function(BusinessException value)? business,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthenticationException value)? authentication,
    TResult Function(AuthorizationException value)? authorization,
    TResult Function(ValidationException value)? validation,
    TResult Function(NotFoundException value)? notFound,
    TResult Function(ServerException value)? server,
    TResult Function(TimeoutException value)? timeout,
    TResult Function(ConnectivityException value)? connectivity,
    TResult Function(StorageException value)? storage,
    TResult Function(PermissionException value)? permission,
    TResult Function(RateLimitedException value)? rateLimited,
    TResult Function(BusinessException value)? business,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownException implements AppException {
  const factory UnknownException({
    required final String message,
    final Object? originalError,
    final StackTrace? stackTrace,
    final Map<String, dynamic>? details,
  }) = _$UnknownExceptionImpl;

  @override
  String get message;
  Object? get originalError;
  StackTrace? get stackTrace;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
