// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  bool get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  AuthResponseData? get data => throw _privateConstructorUsedError;
  AuthResponseError? get error => throw _privateConstructorUsedError;

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
    AuthResponse value,
    $Res Function(AuthResponse) then,
  ) = _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call({
    bool success,
    String? message,
    AuthResponseData? data,
    AuthResponseError? error,
  });

  $AuthResponseDataCopyWith<$Res>? get data;
  $AuthResponseErrorCopyWith<$Res>? get error;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = freezed,
    Object? data = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as AuthResponseData?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as AuthResponseError?,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthResponseDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $AuthResponseDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthResponseErrorCopyWith<$Res>? get error {
    if (_value.error == null) {
      return null;
    }

    return $AuthResponseErrorCopyWith<$Res>(_value.error!, (value) {
      return _then(_value.copyWith(error: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
    _$AuthResponseImpl value,
    $Res Function(_$AuthResponseImpl) then,
  ) = __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String? message,
    AuthResponseData? data,
    AuthResponseError? error,
  });

  @override
  $AuthResponseDataCopyWith<$Res>? get data;
  @override
  $AuthResponseErrorCopyWith<$Res>? get error;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
    _$AuthResponseImpl _value,
    $Res Function(_$AuthResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = freezed,
    Object? data = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$AuthResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as AuthResponseData?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as AuthResponseError?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String? message;
  @override
  final AuthResponseData? data;
  @override
  final AuthResponseError? error;

  @override
  String toString() {
    return 'AuthResponse(success: $success, message: $message, data: $data, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, data, error);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(this);
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse({
    required final bool success,
    final String? message,
    final AuthResponseData? data,
    final AuthResponseError? error,
  }) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String? get message;
  @override
  AuthResponseData? get data;
  @override
  AuthResponseError? get error;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResponseData _$AuthResponseDataFromJson(Map<String, dynamic> json) {
  return _AuthResponseData.fromJson(json);
}

/// @nodoc
mixin _$AuthResponseData {
  User get user => throw _privateConstructorUsedError;
  String get accessToken => throw _privateConstructorUsedError;
  String? get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this AuthResponseData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponseData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseDataCopyWith<AuthResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseDataCopyWith<$Res> {
  factory $AuthResponseDataCopyWith(
    AuthResponseData value,
    $Res Function(AuthResponseData) then,
  ) = _$AuthResponseDataCopyWithImpl<$Res, AuthResponseData>;
  @useResult
  $Res call({User user, String accessToken, String? refreshToken});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseDataCopyWithImpl<$Res, $Val extends AuthResponseData>
    implements $AuthResponseDataCopyWith<$Res> {
  _$AuthResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponseData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? accessToken = null,
    Object? refreshToken = freezed,
  }) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User,
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: freezed == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthResponseData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseDataImplCopyWith<$Res>
    implements $AuthResponseDataCopyWith<$Res> {
  factory _$$AuthResponseDataImplCopyWith(
    _$AuthResponseDataImpl value,
    $Res Function(_$AuthResponseDataImpl) then,
  ) = __$$AuthResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({User user, String accessToken, String? refreshToken});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseDataImplCopyWithImpl<$Res>
    extends _$AuthResponseDataCopyWithImpl<$Res, _$AuthResponseDataImpl>
    implements _$$AuthResponseDataImplCopyWith<$Res> {
  __$$AuthResponseDataImplCopyWithImpl(
    _$AuthResponseDataImpl _value,
    $Res Function(_$AuthResponseDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponseData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? accessToken = null,
    Object? refreshToken = freezed,
  }) {
    return _then(
      _$AuthResponseDataImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: freezed == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseDataImpl implements _AuthResponseData {
  const _$AuthResponseDataImpl({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory _$AuthResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseDataImplFromJson(json);

  @override
  final User user;
  @override
  final String accessToken;
  @override
  final String? refreshToken;

  @override
  String toString() {
    return 'AuthResponseData(user: $user, accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseDataImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, accessToken, refreshToken);

  /// Create a copy of AuthResponseData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseDataImplCopyWith<_$AuthResponseDataImpl> get copyWith =>
      __$$AuthResponseDataImplCopyWithImpl<_$AuthResponseDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseDataImplToJson(this);
  }
}

abstract class _AuthResponseData implements AuthResponseData {
  const factory _AuthResponseData({
    required final User user,
    required final String accessToken,
    final String? refreshToken,
  }) = _$AuthResponseDataImpl;

  factory _AuthResponseData.fromJson(Map<String, dynamic> json) =
      _$AuthResponseDataImpl.fromJson;

  @override
  User get user;
  @override
  String get accessToken;
  @override
  String? get refreshToken;

  /// Create a copy of AuthResponseData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseDataImplCopyWith<_$AuthResponseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResponseError _$AuthResponseErrorFromJson(Map<String, dynamic> json) {
  return _AuthResponseError.fromJson(json);
}

/// @nodoc
mixin _$AuthResponseError {
  String get code => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  Map<String, dynamic>? get details => throw _privateConstructorUsedError;

  /// Serializes this AuthResponseError to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponseError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseErrorCopyWith<AuthResponseError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseErrorCopyWith<$Res> {
  factory $AuthResponseErrorCopyWith(
    AuthResponseError value,
    $Res Function(AuthResponseError) then,
  ) = _$AuthResponseErrorCopyWithImpl<$Res, AuthResponseError>;
  @useResult
  $Res call({String code, String message, Map<String, dynamic>? details});
}

/// @nodoc
class _$AuthResponseErrorCopyWithImpl<$Res, $Val extends AuthResponseError>
    implements $AuthResponseErrorCopyWith<$Res> {
  _$AuthResponseErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponseError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$AuthResponseErrorImplCopyWith<$Res>
    implements $AuthResponseErrorCopyWith<$Res> {
  factory _$$AuthResponseErrorImplCopyWith(
    _$AuthResponseErrorImpl value,
    $Res Function(_$AuthResponseErrorImpl) then,
  ) = __$$AuthResponseErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String message, Map<String, dynamic>? details});
}

/// @nodoc
class __$$AuthResponseErrorImplCopyWithImpl<$Res>
    extends _$AuthResponseErrorCopyWithImpl<$Res, _$AuthResponseErrorImpl>
    implements _$$AuthResponseErrorImplCopyWith<$Res> {
  __$$AuthResponseErrorImplCopyWithImpl(
    _$AuthResponseErrorImpl _value,
    $Res Function(_$AuthResponseErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponseError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(
      _$AuthResponseErrorImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        details: freezed == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseErrorImpl implements _AuthResponseError {
  const _$AuthResponseErrorImpl({
    required this.code,
    required this.message,
    final Map<String, dynamic>? details,
  }) : _details = details;

  factory _$AuthResponseErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseErrorImplFromJson(json);

  @override
  final String code;
  @override
  final String message;
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
    return 'AuthResponseError(code: $code, message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseErrorImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    message,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of AuthResponseError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseErrorImplCopyWith<_$AuthResponseErrorImpl> get copyWith =>
      __$$AuthResponseErrorImplCopyWithImpl<_$AuthResponseErrorImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseErrorImplToJson(this);
  }
}

abstract class _AuthResponseError implements AuthResponseError {
  const factory _AuthResponseError({
    required final String code,
    required final String message,
    final Map<String, dynamic>? details,
  }) = _$AuthResponseErrorImpl;

  factory _AuthResponseError.fromJson(Map<String, dynamic> json) =
      _$AuthResponseErrorImpl.fromJson;

  @override
  String get code;
  @override
  String get message;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of AuthResponseError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseErrorImplCopyWith<_$AuthResponseErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TwoFactorSetupResponse _$TwoFactorSetupResponseFromJson(
  Map<String, dynamic> json,
) {
  return _TwoFactorSetupResponse.fromJson(json);
}

/// @nodoc
mixin _$TwoFactorSetupResponse {
  String get secret => throw _privateConstructorUsedError;
  String get qrCode => throw _privateConstructorUsedError;
  List<String> get backupCodes => throw _privateConstructorUsedError;

  /// Serializes this TwoFactorSetupResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TwoFactorSetupResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TwoFactorSetupResponseCopyWith<TwoFactorSetupResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TwoFactorSetupResponseCopyWith<$Res> {
  factory $TwoFactorSetupResponseCopyWith(
    TwoFactorSetupResponse value,
    $Res Function(TwoFactorSetupResponse) then,
  ) = _$TwoFactorSetupResponseCopyWithImpl<$Res, TwoFactorSetupResponse>;
  @useResult
  $Res call({String secret, String qrCode, List<String> backupCodes});
}

/// @nodoc
class _$TwoFactorSetupResponseCopyWithImpl<
  $Res,
  $Val extends TwoFactorSetupResponse
>
    implements $TwoFactorSetupResponseCopyWith<$Res> {
  _$TwoFactorSetupResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TwoFactorSetupResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? secret = null,
    Object? qrCode = null,
    Object? backupCodes = null,
  }) {
    return _then(
      _value.copyWith(
            secret: null == secret
                ? _value.secret
                : secret // ignore: cast_nullable_to_non_nullable
                      as String,
            qrCode: null == qrCode
                ? _value.qrCode
                : qrCode // ignore: cast_nullable_to_non_nullable
                      as String,
            backupCodes: null == backupCodes
                ? _value.backupCodes
                : backupCodes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TwoFactorSetupResponseImplCopyWith<$Res>
    implements $TwoFactorSetupResponseCopyWith<$Res> {
  factory _$$TwoFactorSetupResponseImplCopyWith(
    _$TwoFactorSetupResponseImpl value,
    $Res Function(_$TwoFactorSetupResponseImpl) then,
  ) = __$$TwoFactorSetupResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String secret, String qrCode, List<String> backupCodes});
}

/// @nodoc
class __$$TwoFactorSetupResponseImplCopyWithImpl<$Res>
    extends
        _$TwoFactorSetupResponseCopyWithImpl<$Res, _$TwoFactorSetupResponseImpl>
    implements _$$TwoFactorSetupResponseImplCopyWith<$Res> {
  __$$TwoFactorSetupResponseImplCopyWithImpl(
    _$TwoFactorSetupResponseImpl _value,
    $Res Function(_$TwoFactorSetupResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TwoFactorSetupResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? secret = null,
    Object? qrCode = null,
    Object? backupCodes = null,
  }) {
    return _then(
      _$TwoFactorSetupResponseImpl(
        secret: null == secret
            ? _value.secret
            : secret // ignore: cast_nullable_to_non_nullable
                  as String,
        qrCode: null == qrCode
            ? _value.qrCode
            : qrCode // ignore: cast_nullable_to_non_nullable
                  as String,
        backupCodes: null == backupCodes
            ? _value._backupCodes
            : backupCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TwoFactorSetupResponseImpl extends _TwoFactorSetupResponse {
  const _$TwoFactorSetupResponseImpl({
    required this.secret,
    required this.qrCode,
    required final List<String> backupCodes,
  }) : _backupCodes = backupCodes,
       super._();

  factory _$TwoFactorSetupResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TwoFactorSetupResponseImplFromJson(json);

  @override
  final String secret;
  @override
  final String qrCode;
  final List<String> _backupCodes;
  @override
  List<String> get backupCodes {
    if (_backupCodes is EqualUnmodifiableListView) return _backupCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_backupCodes);
  }

  @override
  String toString() {
    return 'TwoFactorSetupResponse(secret: $secret, qrCode: $qrCode, backupCodes: $backupCodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TwoFactorSetupResponseImpl &&
            (identical(other.secret, secret) || other.secret == secret) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode) &&
            const DeepCollectionEquality().equals(
              other._backupCodes,
              _backupCodes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    secret,
    qrCode,
    const DeepCollectionEquality().hash(_backupCodes),
  );

  /// Create a copy of TwoFactorSetupResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TwoFactorSetupResponseImplCopyWith<_$TwoFactorSetupResponseImpl>
  get copyWith =>
      __$$TwoFactorSetupResponseImplCopyWithImpl<_$TwoFactorSetupResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TwoFactorSetupResponseImplToJson(this);
  }
}

abstract class _TwoFactorSetupResponse extends TwoFactorSetupResponse {
  const factory _TwoFactorSetupResponse({
    required final String secret,
    required final String qrCode,
    required final List<String> backupCodes,
  }) = _$TwoFactorSetupResponseImpl;
  const _TwoFactorSetupResponse._() : super._();

  factory _TwoFactorSetupResponse.fromJson(Map<String, dynamic> json) =
      _$TwoFactorSetupResponseImpl.fromJson;

  @override
  String get secret;
  @override
  String get qrCode;
  @override
  List<String> get backupCodes;

  /// Create a copy of TwoFactorSetupResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TwoFactorSetupResponseImplCopyWith<_$TwoFactorSetupResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

WebAuthnRegistrationResponse _$WebAuthnRegistrationResponseFromJson(
  Map<String, dynamic> json,
) {
  return _WebAuthnRegistrationResponse.fromJson(json);
}

/// @nodoc
mixin _$WebAuthnRegistrationResponse {
  String get challenge => throw _privateConstructorUsedError;
  Map<String, dynamic> get publicKeyCredentialCreationOptions =>
      throw _privateConstructorUsedError;

  /// Serializes this WebAuthnRegistrationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebAuthnRegistrationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebAuthnRegistrationResponseCopyWith<WebAuthnRegistrationResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebAuthnRegistrationResponseCopyWith<$Res> {
  factory $WebAuthnRegistrationResponseCopyWith(
    WebAuthnRegistrationResponse value,
    $Res Function(WebAuthnRegistrationResponse) then,
  ) =
      _$WebAuthnRegistrationResponseCopyWithImpl<
        $Res,
        WebAuthnRegistrationResponse
      >;
  @useResult
  $Res call({
    String challenge,
    Map<String, dynamic> publicKeyCredentialCreationOptions,
  });
}

/// @nodoc
class _$WebAuthnRegistrationResponseCopyWithImpl<
  $Res,
  $Val extends WebAuthnRegistrationResponse
>
    implements $WebAuthnRegistrationResponseCopyWith<$Res> {
  _$WebAuthnRegistrationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebAuthnRegistrationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenge = null,
    Object? publicKeyCredentialCreationOptions = null,
  }) {
    return _then(
      _value.copyWith(
            challenge: null == challenge
                ? _value.challenge
                : challenge // ignore: cast_nullable_to_non_nullable
                      as String,
            publicKeyCredentialCreationOptions:
                null == publicKeyCredentialCreationOptions
                ? _value.publicKeyCredentialCreationOptions
                : publicKeyCredentialCreationOptions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebAuthnRegistrationResponseImplCopyWith<$Res>
    implements $WebAuthnRegistrationResponseCopyWith<$Res> {
  factory _$$WebAuthnRegistrationResponseImplCopyWith(
    _$WebAuthnRegistrationResponseImpl value,
    $Res Function(_$WebAuthnRegistrationResponseImpl) then,
  ) = __$$WebAuthnRegistrationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String challenge,
    Map<String, dynamic> publicKeyCredentialCreationOptions,
  });
}

/// @nodoc
class __$$WebAuthnRegistrationResponseImplCopyWithImpl<$Res>
    extends
        _$WebAuthnRegistrationResponseCopyWithImpl<
          $Res,
          _$WebAuthnRegistrationResponseImpl
        >
    implements _$$WebAuthnRegistrationResponseImplCopyWith<$Res> {
  __$$WebAuthnRegistrationResponseImplCopyWithImpl(
    _$WebAuthnRegistrationResponseImpl _value,
    $Res Function(_$WebAuthnRegistrationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebAuthnRegistrationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenge = null,
    Object? publicKeyCredentialCreationOptions = null,
  }) {
    return _then(
      _$WebAuthnRegistrationResponseImpl(
        challenge: null == challenge
            ? _value.challenge
            : challenge // ignore: cast_nullable_to_non_nullable
                  as String,
        publicKeyCredentialCreationOptions:
            null == publicKeyCredentialCreationOptions
            ? _value._publicKeyCredentialCreationOptions
            : publicKeyCredentialCreationOptions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebAuthnRegistrationResponseImpl extends _WebAuthnRegistrationResponse {
  const _$WebAuthnRegistrationResponseImpl({
    required this.challenge,
    required final Map<String, dynamic> publicKeyCredentialCreationOptions,
  }) : _publicKeyCredentialCreationOptions = publicKeyCredentialCreationOptions,
       super._();

  factory _$WebAuthnRegistrationResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$WebAuthnRegistrationResponseImplFromJson(json);

  @override
  final String challenge;
  final Map<String, dynamic> _publicKeyCredentialCreationOptions;
  @override
  Map<String, dynamic> get publicKeyCredentialCreationOptions {
    if (_publicKeyCredentialCreationOptions is EqualUnmodifiableMapView)
      return _publicKeyCredentialCreationOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_publicKeyCredentialCreationOptions);
  }

  @override
  String toString() {
    return 'WebAuthnRegistrationResponse(challenge: $challenge, publicKeyCredentialCreationOptions: $publicKeyCredentialCreationOptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebAuthnRegistrationResponseImpl &&
            (identical(other.challenge, challenge) ||
                other.challenge == challenge) &&
            const DeepCollectionEquality().equals(
              other._publicKeyCredentialCreationOptions,
              _publicKeyCredentialCreationOptions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    challenge,
    const DeepCollectionEquality().hash(_publicKeyCredentialCreationOptions),
  );

  /// Create a copy of WebAuthnRegistrationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebAuthnRegistrationResponseImplCopyWith<
    _$WebAuthnRegistrationResponseImpl
  >
  get copyWith =>
      __$$WebAuthnRegistrationResponseImplCopyWithImpl<
        _$WebAuthnRegistrationResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebAuthnRegistrationResponseImplToJson(this);
  }
}

abstract class _WebAuthnRegistrationResponse
    extends WebAuthnRegistrationResponse {
  const factory _WebAuthnRegistrationResponse({
    required final String challenge,
    required final Map<String, dynamic> publicKeyCredentialCreationOptions,
  }) = _$WebAuthnRegistrationResponseImpl;
  const _WebAuthnRegistrationResponse._() : super._();

  factory _WebAuthnRegistrationResponse.fromJson(Map<String, dynamic> json) =
      _$WebAuthnRegistrationResponseImpl.fromJson;

  @override
  String get challenge;
  @override
  Map<String, dynamic> get publicKeyCredentialCreationOptions;

  /// Create a copy of WebAuthnRegistrationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebAuthnRegistrationResponseImplCopyWith<
    _$WebAuthnRegistrationResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

WebAuthnAuthenticationResponse _$WebAuthnAuthenticationResponseFromJson(
  Map<String, dynamic> json,
) {
  return _WebAuthnAuthenticationResponse.fromJson(json);
}

/// @nodoc
mixin _$WebAuthnAuthenticationResponse {
  String get challenge => throw _privateConstructorUsedError;
  Map<String, dynamic> get publicKeyCredentialRequestOptions =>
      throw _privateConstructorUsedError;

  /// Serializes this WebAuthnAuthenticationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebAuthnAuthenticationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebAuthnAuthenticationResponseCopyWith<WebAuthnAuthenticationResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebAuthnAuthenticationResponseCopyWith<$Res> {
  factory $WebAuthnAuthenticationResponseCopyWith(
    WebAuthnAuthenticationResponse value,
    $Res Function(WebAuthnAuthenticationResponse) then,
  ) =
      _$WebAuthnAuthenticationResponseCopyWithImpl<
        $Res,
        WebAuthnAuthenticationResponse
      >;
  @useResult
  $Res call({
    String challenge,
    Map<String, dynamic> publicKeyCredentialRequestOptions,
  });
}

/// @nodoc
class _$WebAuthnAuthenticationResponseCopyWithImpl<
  $Res,
  $Val extends WebAuthnAuthenticationResponse
>
    implements $WebAuthnAuthenticationResponseCopyWith<$Res> {
  _$WebAuthnAuthenticationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebAuthnAuthenticationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenge = null,
    Object? publicKeyCredentialRequestOptions = null,
  }) {
    return _then(
      _value.copyWith(
            challenge: null == challenge
                ? _value.challenge
                : challenge // ignore: cast_nullable_to_non_nullable
                      as String,
            publicKeyCredentialRequestOptions:
                null == publicKeyCredentialRequestOptions
                ? _value.publicKeyCredentialRequestOptions
                : publicKeyCredentialRequestOptions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebAuthnAuthenticationResponseImplCopyWith<$Res>
    implements $WebAuthnAuthenticationResponseCopyWith<$Res> {
  factory _$$WebAuthnAuthenticationResponseImplCopyWith(
    _$WebAuthnAuthenticationResponseImpl value,
    $Res Function(_$WebAuthnAuthenticationResponseImpl) then,
  ) = __$$WebAuthnAuthenticationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String challenge,
    Map<String, dynamic> publicKeyCredentialRequestOptions,
  });
}

/// @nodoc
class __$$WebAuthnAuthenticationResponseImplCopyWithImpl<$Res>
    extends
        _$WebAuthnAuthenticationResponseCopyWithImpl<
          $Res,
          _$WebAuthnAuthenticationResponseImpl
        >
    implements _$$WebAuthnAuthenticationResponseImplCopyWith<$Res> {
  __$$WebAuthnAuthenticationResponseImplCopyWithImpl(
    _$WebAuthnAuthenticationResponseImpl _value,
    $Res Function(_$WebAuthnAuthenticationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebAuthnAuthenticationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenge = null,
    Object? publicKeyCredentialRequestOptions = null,
  }) {
    return _then(
      _$WebAuthnAuthenticationResponseImpl(
        challenge: null == challenge
            ? _value.challenge
            : challenge // ignore: cast_nullable_to_non_nullable
                  as String,
        publicKeyCredentialRequestOptions:
            null == publicKeyCredentialRequestOptions
            ? _value._publicKeyCredentialRequestOptions
            : publicKeyCredentialRequestOptions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebAuthnAuthenticationResponseImpl
    extends _WebAuthnAuthenticationResponse {
  const _$WebAuthnAuthenticationResponseImpl({
    required this.challenge,
    required final Map<String, dynamic> publicKeyCredentialRequestOptions,
  }) : _publicKeyCredentialRequestOptions = publicKeyCredentialRequestOptions,
       super._();

  factory _$WebAuthnAuthenticationResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$WebAuthnAuthenticationResponseImplFromJson(json);

  @override
  final String challenge;
  final Map<String, dynamic> _publicKeyCredentialRequestOptions;
  @override
  Map<String, dynamic> get publicKeyCredentialRequestOptions {
    if (_publicKeyCredentialRequestOptions is EqualUnmodifiableMapView)
      return _publicKeyCredentialRequestOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_publicKeyCredentialRequestOptions);
  }

  @override
  String toString() {
    return 'WebAuthnAuthenticationResponse(challenge: $challenge, publicKeyCredentialRequestOptions: $publicKeyCredentialRequestOptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebAuthnAuthenticationResponseImpl &&
            (identical(other.challenge, challenge) ||
                other.challenge == challenge) &&
            const DeepCollectionEquality().equals(
              other._publicKeyCredentialRequestOptions,
              _publicKeyCredentialRequestOptions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    challenge,
    const DeepCollectionEquality().hash(_publicKeyCredentialRequestOptions),
  );

  /// Create a copy of WebAuthnAuthenticationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebAuthnAuthenticationResponseImplCopyWith<
    _$WebAuthnAuthenticationResponseImpl
  >
  get copyWith =>
      __$$WebAuthnAuthenticationResponseImplCopyWithImpl<
        _$WebAuthnAuthenticationResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebAuthnAuthenticationResponseImplToJson(this);
  }
}

abstract class _WebAuthnAuthenticationResponse
    extends WebAuthnAuthenticationResponse {
  const factory _WebAuthnAuthenticationResponse({
    required final String challenge,
    required final Map<String, dynamic> publicKeyCredentialRequestOptions,
  }) = _$WebAuthnAuthenticationResponseImpl;
  const _WebAuthnAuthenticationResponse._() : super._();

  factory _WebAuthnAuthenticationResponse.fromJson(Map<String, dynamic> json) =
      _$WebAuthnAuthenticationResponseImpl.fromJson;

  @override
  String get challenge;
  @override
  Map<String, dynamic> get publicKeyCredentialRequestOptions;

  /// Create a copy of WebAuthnAuthenticationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebAuthnAuthenticationResponseImplCopyWith<
    _$WebAuthnAuthenticationResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
