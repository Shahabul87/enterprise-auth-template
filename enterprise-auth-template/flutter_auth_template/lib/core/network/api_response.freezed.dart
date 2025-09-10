// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object?) fromJsonT,
) {
  switch (json['runtimeType']) {
    case 'success':
      return _Success<T>.fromJson(json, fromJsonT);
    case 'error':
      return _Error<T>.fromJson(json, fromJsonT);
    case 'loading':
      return _Loading<T>.fromJson(json, fromJsonT);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'ApiResponse',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$ApiResponse<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data, String? message) success,
    required TResult Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )
    error,
    required TResult Function() loading,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data, String? message)? success,
    TResult? Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )?
    error,
    TResult? Function()? loading,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data, String? message)? success,
    TResult Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )?
    error,
    TResult Function()? loading,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success<T> value) success,
    required TResult Function(_Error<T> value) error,
    required TResult Function(_Loading<T> value) loading,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Success<T> value)? success,
    TResult? Function(_Error<T> value)? error,
    TResult? Function(_Loading<T> value)? loading,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Error<T> value)? error,
    TResult Function(_Loading<T> value)? loading,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ApiResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiResponseCopyWith<T, $Res> {
  factory $ApiResponseCopyWith(
    ApiResponse<T> value,
    $Res Function(ApiResponse<T>) then,
  ) = _$ApiResponseCopyWithImpl<T, $Res, ApiResponse<T>>;
}

/// @nodoc
class _$ApiResponseCopyWithImpl<T, $Res, $Val extends ApiResponse<T>>
    implements $ApiResponseCopyWith<T, $Res> {
  _$ApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<T, $Res> {
  factory _$$SuccessImplCopyWith(
    _$SuccessImpl<T> value,
    $Res Function(_$SuccessImpl<T>) then,
  ) = __$$SuccessImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T data, String? message});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<T, $Res>
    extends _$ApiResponseCopyWithImpl<T, $Res, _$SuccessImpl<T>>
    implements _$$SuccessImplCopyWith<T, $Res> {
  __$$SuccessImplCopyWithImpl(
    _$SuccessImpl<T> _value,
    $Res Function(_$SuccessImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = freezed, Object? message = freezed}) {
    return _then(
      _$SuccessImpl<T>(
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as T,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _$SuccessImpl<T> implements _Success<T> {
  const _$SuccessImpl({required this.data, this.message, final String? $type})
    : $type = $type ?? 'success';

  factory _$SuccessImpl.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$$SuccessImplFromJson(json, fromJsonT);

  @override
  final T data;
  @override
  final String? message;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ApiResponse<$T>.success(data: $data, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(data),
    message,
  );

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<T, _$SuccessImpl<T>> get copyWith =>
      __$$SuccessImplCopyWithImpl<T, _$SuccessImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data, String? message) success,
    required TResult Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )
    error,
    required TResult Function() loading,
  }) {
    return success(data, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data, String? message)? success,
    TResult? Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )?
    error,
    TResult? Function()? loading,
  }) {
    return success?.call(data, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data, String? message)? success,
    TResult Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )?
    error,
    TResult Function()? loading,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(data, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success<T> value) success,
    required TResult Function(_Error<T> value) error,
    required TResult Function(_Loading<T> value) loading,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Success<T> value)? success,
    TResult? Function(_Error<T> value)? error,
    TResult? Function(_Loading<T> value)? loading,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Error<T> value)? error,
    TResult Function(_Loading<T> value)? loading,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$SuccessImplToJson<T>(this, toJsonT);
  }
}

abstract class _Success<T> implements ApiResponse<T> {
  const factory _Success({required final T data, final String? message}) =
      _$SuccessImpl<T>;

  factory _Success.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) = _$SuccessImpl<T>.fromJson;

  T get data;
  String? get message;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<T, _$SuccessImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<T, $Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl<T> value,
    $Res Function(_$ErrorImpl<T>) then,
  ) = __$$ErrorImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({
    String message,
    String? code,
    Object? originalError,
    Map<String, dynamic>? details,
  });
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<T, $Res>
    extends _$ApiResponseCopyWithImpl<T, $Res, _$ErrorImpl<T>>
    implements _$$ErrorImplCopyWith<T, $Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl<T> _value,
    $Res Function(_$ErrorImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? originalError = freezed,
    Object? details = freezed,
  }) {
    return _then(
      _$ErrorImpl<T>(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        originalError: freezed == originalError
            ? _value.originalError
            : originalError,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _$ErrorImpl<T> implements _Error<T> {
  const _$ErrorImpl({
    required this.message,
    this.code,
    this.originalError,
    final Map<String, dynamic>? details,
    final String? $type,
  }) : _details = details,
       $type = $type ?? 'error';

  factory _$ErrorImpl.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$$ErrorImplFromJson(json, fromJsonT);

  @override
  final String message;
  @override
  final String? code;
  @override
  final Object? originalError;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ApiResponse<$T>.error(message: $message, code: $code, originalError: $originalError, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl<T> &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(
              other.originalError,
              originalError,
            ) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(originalError),
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<T, _$ErrorImpl<T>> get copyWith =>
      __$$ErrorImplCopyWithImpl<T, _$ErrorImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data, String? message) success,
    required TResult Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )
    error,
    required TResult Function() loading,
  }) {
    return error(message, code, originalError, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data, String? message)? success,
    TResult? Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )?
    error,
    TResult? Function()? loading,
  }) {
    return error?.call(message, code, originalError, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data, String? message)? success,
    TResult Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )?
    error,
    TResult Function()? loading,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, code, originalError, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success<T> value) success,
    required TResult Function(_Error<T> value) error,
    required TResult Function(_Loading<T> value) loading,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Success<T> value)? success,
    TResult? Function(_Error<T> value)? error,
    TResult? Function(_Loading<T> value)? loading,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Error<T> value)? error,
    TResult Function(_Loading<T> value)? loading,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$ErrorImplToJson<T>(this, toJsonT);
  }
}

abstract class _Error<T> implements ApiResponse<T> {
  const factory _Error({
    required final String message,
    final String? code,
    final Object? originalError,
    final Map<String, dynamic>? details,
  }) = _$ErrorImpl<T>;

  factory _Error.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) = _$ErrorImpl<T>.fromJson;

  String get message;
  String? get code;
  Object? get originalError;
  Map<String, dynamic>? get details;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<T, _$ErrorImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<T, $Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl<T> value,
    $Res Function(_$LoadingImpl<T>) then,
  ) = __$$LoadingImplCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<T, $Res>
    extends _$ApiResponseCopyWithImpl<T, $Res, _$LoadingImpl<T>>
    implements _$$LoadingImplCopyWith<T, $Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl<T> _value,
    $Res Function(_$LoadingImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _$LoadingImpl<T> implements _Loading<T> {
  const _$LoadingImpl({final String? $type}) : $type = $type ?? 'loading';

  factory _$LoadingImpl.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$$LoadingImplFromJson(json, fromJsonT);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'ApiResponse<$T>.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl<T>);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data, String? message) success,
    required TResult Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )
    error,
    required TResult Function() loading,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data, String? message)? success,
    TResult? Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )?
    error,
    TResult? Function()? loading,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data, String? message)? success,
    TResult Function(
      String message,
      String? code,
      Object? originalError,
      Map<String, dynamic>? details,
    )?
    error,
    TResult Function()? loading,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success<T> value) success,
    required TResult Function(_Error<T> value) error,
    required TResult Function(_Loading<T> value) loading,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Success<T> value)? success,
    TResult? Function(_Error<T> value)? error,
    TResult? Function(_Loading<T> value)? loading,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success<T> value)? success,
    TResult Function(_Error<T> value)? error,
    TResult Function(_Loading<T> value)? loading,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$LoadingImplToJson<T>(this, toJsonT);
  }
}

abstract class _Loading<T> implements ApiResponse<T> {
  const factory _Loading() = _$LoadingImpl<T>;

  factory _Loading.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) = _$LoadingImpl<T>.fromJson;
}
