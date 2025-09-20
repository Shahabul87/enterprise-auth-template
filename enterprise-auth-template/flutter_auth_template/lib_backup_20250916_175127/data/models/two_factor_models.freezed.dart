// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'two_factor_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

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
  String get setupKey => throw _privateConstructorUsedError;

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
  $Res call({
    String secret,
    String qrCode,
    List<String> backupCodes,
    String setupKey,
  });
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
    Object? setupKey = null,
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
            setupKey: null == setupKey
                ? _value.setupKey
                : setupKey // ignore: cast_nullable_to_non_nullable
                      as String,
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
  $Res call({
    String secret,
    String qrCode,
    List<String> backupCodes,
    String setupKey,
  });
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
    Object? setupKey = null,
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
        setupKey: null == setupKey
            ? _value.setupKey
            : setupKey // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TwoFactorSetupResponseImpl implements _TwoFactorSetupResponse {
  const _$TwoFactorSetupResponseImpl({
    required this.secret,
    required this.qrCode,
    required final List<String> backupCodes,
    this.setupKey = '',
  }) : _backupCodes = backupCodes;

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
  @JsonKey()
  final String setupKey;

  @override
  String toString() {
    return 'TwoFactorSetupResponse(secret: $secret, qrCode: $qrCode, backupCodes: $backupCodes, setupKey: $setupKey)';
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
            ) &&
            (identical(other.setupKey, setupKey) ||
                other.setupKey == setupKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    secret,
    qrCode,
    const DeepCollectionEquality().hash(_backupCodes),
    setupKey,
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

abstract class _TwoFactorSetupResponse implements TwoFactorSetupResponse {
  const factory _TwoFactorSetupResponse({
    required final String secret,
    required final String qrCode,
    required final List<String> backupCodes,
    final String setupKey,
  }) = _$TwoFactorSetupResponseImpl;

  factory _TwoFactorSetupResponse.fromJson(Map<String, dynamic> json) =
      _$TwoFactorSetupResponseImpl.fromJson;

  @override
  String get secret;
  @override
  String get qrCode;
  @override
  List<String> get backupCodes;
  @override
  String get setupKey;

  /// Create a copy of TwoFactorSetupResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TwoFactorSetupResponseImplCopyWith<_$TwoFactorSetupResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TwoFactorStatus _$TwoFactorStatusFromJson(Map<String, dynamic> json) {
  return _TwoFactorStatus.fromJson(json);
}

/// @nodoc
mixin _$TwoFactorStatus {
  bool get enabled => throw _privateConstructorUsedError;
  bool get hasBackupCodes => throw _privateConstructorUsedError;
  int get backupCodesUsed => throw _privateConstructorUsedError;
  int get backupCodesRemaining => throw _privateConstructorUsedError;
  DateTime? get lastUsed => throw _privateConstructorUsedError;
  String? get method => throw _privateConstructorUsedError;

  /// Serializes this TwoFactorStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TwoFactorStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TwoFactorStatusCopyWith<TwoFactorStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TwoFactorStatusCopyWith<$Res> {
  factory $TwoFactorStatusCopyWith(
    TwoFactorStatus value,
    $Res Function(TwoFactorStatus) then,
  ) = _$TwoFactorStatusCopyWithImpl<$Res, TwoFactorStatus>;
  @useResult
  $Res call({
    bool enabled,
    bool hasBackupCodes,
    int backupCodesUsed,
    int backupCodesRemaining,
    DateTime? lastUsed,
    String? method,
  });
}

/// @nodoc
class _$TwoFactorStatusCopyWithImpl<$Res, $Val extends TwoFactorStatus>
    implements $TwoFactorStatusCopyWith<$Res> {
  _$TwoFactorStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TwoFactorStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? hasBackupCodes = null,
    Object? backupCodesUsed = null,
    Object? backupCodesRemaining = null,
    Object? lastUsed = freezed,
    Object? method = freezed,
  }) {
    return _then(
      _value.copyWith(
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasBackupCodes: null == hasBackupCodes
                ? _value.hasBackupCodes
                : hasBackupCodes // ignore: cast_nullable_to_non_nullable
                      as bool,
            backupCodesUsed: null == backupCodesUsed
                ? _value.backupCodesUsed
                : backupCodesUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            backupCodesRemaining: null == backupCodesRemaining
                ? _value.backupCodesRemaining
                : backupCodesRemaining // ignore: cast_nullable_to_non_nullable
                      as int,
            lastUsed: freezed == lastUsed
                ? _value.lastUsed
                : lastUsed // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            method: freezed == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TwoFactorStatusImplCopyWith<$Res>
    implements $TwoFactorStatusCopyWith<$Res> {
  factory _$$TwoFactorStatusImplCopyWith(
    _$TwoFactorStatusImpl value,
    $Res Function(_$TwoFactorStatusImpl) then,
  ) = __$$TwoFactorStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool enabled,
    bool hasBackupCodes,
    int backupCodesUsed,
    int backupCodesRemaining,
    DateTime? lastUsed,
    String? method,
  });
}

/// @nodoc
class __$$TwoFactorStatusImplCopyWithImpl<$Res>
    extends _$TwoFactorStatusCopyWithImpl<$Res, _$TwoFactorStatusImpl>
    implements _$$TwoFactorStatusImplCopyWith<$Res> {
  __$$TwoFactorStatusImplCopyWithImpl(
    _$TwoFactorStatusImpl _value,
    $Res Function(_$TwoFactorStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TwoFactorStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? hasBackupCodes = null,
    Object? backupCodesUsed = null,
    Object? backupCodesRemaining = null,
    Object? lastUsed = freezed,
    Object? method = freezed,
  }) {
    return _then(
      _$TwoFactorStatusImpl(
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasBackupCodes: null == hasBackupCodes
            ? _value.hasBackupCodes
            : hasBackupCodes // ignore: cast_nullable_to_non_nullable
                  as bool,
        backupCodesUsed: null == backupCodesUsed
            ? _value.backupCodesUsed
            : backupCodesUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        backupCodesRemaining: null == backupCodesRemaining
            ? _value.backupCodesRemaining
            : backupCodesRemaining // ignore: cast_nullable_to_non_nullable
                  as int,
        lastUsed: freezed == lastUsed
            ? _value.lastUsed
            : lastUsed // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        method: freezed == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TwoFactorStatusImpl implements _TwoFactorStatus {
  const _$TwoFactorStatusImpl({
    this.enabled = false,
    this.hasBackupCodes = false,
    this.backupCodesUsed = 0,
    this.backupCodesRemaining = 0,
    this.lastUsed,
    this.method,
  });

  factory _$TwoFactorStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$TwoFactorStatusImplFromJson(json);

  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final bool hasBackupCodes;
  @override
  @JsonKey()
  final int backupCodesUsed;
  @override
  @JsonKey()
  final int backupCodesRemaining;
  @override
  final DateTime? lastUsed;
  @override
  final String? method;

  @override
  String toString() {
    return 'TwoFactorStatus(enabled: $enabled, hasBackupCodes: $hasBackupCodes, backupCodesUsed: $backupCodesUsed, backupCodesRemaining: $backupCodesRemaining, lastUsed: $lastUsed, method: $method)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TwoFactorStatusImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.hasBackupCodes, hasBackupCodes) ||
                other.hasBackupCodes == hasBackupCodes) &&
            (identical(other.backupCodesUsed, backupCodesUsed) ||
                other.backupCodesUsed == backupCodesUsed) &&
            (identical(other.backupCodesRemaining, backupCodesRemaining) ||
                other.backupCodesRemaining == backupCodesRemaining) &&
            (identical(other.lastUsed, lastUsed) ||
                other.lastUsed == lastUsed) &&
            (identical(other.method, method) || other.method == method));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enabled,
    hasBackupCodes,
    backupCodesUsed,
    backupCodesRemaining,
    lastUsed,
    method,
  );

  /// Create a copy of TwoFactorStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TwoFactorStatusImplCopyWith<_$TwoFactorStatusImpl> get copyWith =>
      __$$TwoFactorStatusImplCopyWithImpl<_$TwoFactorStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TwoFactorStatusImplToJson(this);
  }
}

abstract class _TwoFactorStatus implements TwoFactorStatus {
  const factory _TwoFactorStatus({
    final bool enabled,
    final bool hasBackupCodes,
    final int backupCodesUsed,
    final int backupCodesRemaining,
    final DateTime? lastUsed,
    final String? method,
  }) = _$TwoFactorStatusImpl;

  factory _TwoFactorStatus.fromJson(Map<String, dynamic> json) =
      _$TwoFactorStatusImpl.fromJson;

  @override
  bool get enabled;
  @override
  bool get hasBackupCodes;
  @override
  int get backupCodesUsed;
  @override
  int get backupCodesRemaining;
  @override
  DateTime? get lastUsed;
  @override
  String? get method;

  /// Create a copy of TwoFactorStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TwoFactorStatusImplCopyWith<_$TwoFactorStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TwoFactorVerifyRequest _$TwoFactorVerifyRequestFromJson(
  Map<String, dynamic> json,
) {
  return _TwoFactorVerifyRequest.fromJson(json);
}

/// @nodoc
mixin _$TwoFactorVerifyRequest {
  String get code => throw _privateConstructorUsedError;
  bool get isBackupCode => throw _privateConstructorUsedError;
  String? get method => throw _privateConstructorUsedError;

  /// Serializes this TwoFactorVerifyRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TwoFactorVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TwoFactorVerifyRequestCopyWith<TwoFactorVerifyRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TwoFactorVerifyRequestCopyWith<$Res> {
  factory $TwoFactorVerifyRequestCopyWith(
    TwoFactorVerifyRequest value,
    $Res Function(TwoFactorVerifyRequest) then,
  ) = _$TwoFactorVerifyRequestCopyWithImpl<$Res, TwoFactorVerifyRequest>;
  @useResult
  $Res call({String code, bool isBackupCode, String? method});
}

/// @nodoc
class _$TwoFactorVerifyRequestCopyWithImpl<
  $Res,
  $Val extends TwoFactorVerifyRequest
>
    implements $TwoFactorVerifyRequestCopyWith<$Res> {
  _$TwoFactorVerifyRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TwoFactorVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? isBackupCode = null,
    Object? method = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            isBackupCode: null == isBackupCode
                ? _value.isBackupCode
                : isBackupCode // ignore: cast_nullable_to_non_nullable
                      as bool,
            method: freezed == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TwoFactorVerifyRequestImplCopyWith<$Res>
    implements $TwoFactorVerifyRequestCopyWith<$Res> {
  factory _$$TwoFactorVerifyRequestImplCopyWith(
    _$TwoFactorVerifyRequestImpl value,
    $Res Function(_$TwoFactorVerifyRequestImpl) then,
  ) = __$$TwoFactorVerifyRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, bool isBackupCode, String? method});
}

/// @nodoc
class __$$TwoFactorVerifyRequestImplCopyWithImpl<$Res>
    extends
        _$TwoFactorVerifyRequestCopyWithImpl<$Res, _$TwoFactorVerifyRequestImpl>
    implements _$$TwoFactorVerifyRequestImplCopyWith<$Res> {
  __$$TwoFactorVerifyRequestImplCopyWithImpl(
    _$TwoFactorVerifyRequestImpl _value,
    $Res Function(_$TwoFactorVerifyRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TwoFactorVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? isBackupCode = null,
    Object? method = freezed,
  }) {
    return _then(
      _$TwoFactorVerifyRequestImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        isBackupCode: null == isBackupCode
            ? _value.isBackupCode
            : isBackupCode // ignore: cast_nullable_to_non_nullable
                  as bool,
        method: freezed == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TwoFactorVerifyRequestImpl implements _TwoFactorVerifyRequest {
  const _$TwoFactorVerifyRequestImpl({
    required this.code,
    this.isBackupCode = false,
    this.method,
  });

  factory _$TwoFactorVerifyRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TwoFactorVerifyRequestImplFromJson(json);

  @override
  final String code;
  @override
  @JsonKey()
  final bool isBackupCode;
  @override
  final String? method;

  @override
  String toString() {
    return 'TwoFactorVerifyRequest(code: $code, isBackupCode: $isBackupCode, method: $method)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TwoFactorVerifyRequestImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.isBackupCode, isBackupCode) ||
                other.isBackupCode == isBackupCode) &&
            (identical(other.method, method) || other.method == method));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, isBackupCode, method);

  /// Create a copy of TwoFactorVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TwoFactorVerifyRequestImplCopyWith<_$TwoFactorVerifyRequestImpl>
  get copyWith =>
      __$$TwoFactorVerifyRequestImplCopyWithImpl<_$TwoFactorVerifyRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TwoFactorVerifyRequestImplToJson(this);
  }
}

abstract class _TwoFactorVerifyRequest implements TwoFactorVerifyRequest {
  const factory _TwoFactorVerifyRequest({
    required final String code,
    final bool isBackupCode,
    final String? method,
  }) = _$TwoFactorVerifyRequestImpl;

  factory _TwoFactorVerifyRequest.fromJson(Map<String, dynamic> json) =
      _$TwoFactorVerifyRequestImpl.fromJson;

  @override
  String get code;
  @override
  bool get isBackupCode;
  @override
  String? get method;

  /// Create a copy of TwoFactorVerifyRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TwoFactorVerifyRequestImplCopyWith<_$TwoFactorVerifyRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TwoFactorEnableRequest _$TwoFactorEnableRequestFromJson(
  Map<String, dynamic> json,
) {
  return _TwoFactorEnableRequest.fromJson(json);
}

/// @nodoc
mixin _$TwoFactorEnableRequest {
  String get code => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;

  /// Serializes this TwoFactorEnableRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TwoFactorEnableRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TwoFactorEnableRequestCopyWith<TwoFactorEnableRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TwoFactorEnableRequestCopyWith<$Res> {
  factory $TwoFactorEnableRequestCopyWith(
    TwoFactorEnableRequest value,
    $Res Function(TwoFactorEnableRequest) then,
  ) = _$TwoFactorEnableRequestCopyWithImpl<$Res, TwoFactorEnableRequest>;
  @useResult
  $Res call({String code, String? password});
}

/// @nodoc
class _$TwoFactorEnableRequestCopyWithImpl<
  $Res,
  $Val extends TwoFactorEnableRequest
>
    implements $TwoFactorEnableRequestCopyWith<$Res> {
  _$TwoFactorEnableRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TwoFactorEnableRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = null, Object? password = freezed}) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TwoFactorEnableRequestImplCopyWith<$Res>
    implements $TwoFactorEnableRequestCopyWith<$Res> {
  factory _$$TwoFactorEnableRequestImplCopyWith(
    _$TwoFactorEnableRequestImpl value,
    $Res Function(_$TwoFactorEnableRequestImpl) then,
  ) = __$$TwoFactorEnableRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String? password});
}

/// @nodoc
class __$$TwoFactorEnableRequestImplCopyWithImpl<$Res>
    extends
        _$TwoFactorEnableRequestCopyWithImpl<$Res, _$TwoFactorEnableRequestImpl>
    implements _$$TwoFactorEnableRequestImplCopyWith<$Res> {
  __$$TwoFactorEnableRequestImplCopyWithImpl(
    _$TwoFactorEnableRequestImpl _value,
    $Res Function(_$TwoFactorEnableRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TwoFactorEnableRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = null, Object? password = freezed}) {
    return _then(
      _$TwoFactorEnableRequestImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TwoFactorEnableRequestImpl implements _TwoFactorEnableRequest {
  const _$TwoFactorEnableRequestImpl({required this.code, this.password});

  factory _$TwoFactorEnableRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TwoFactorEnableRequestImplFromJson(json);

  @override
  final String code;
  @override
  final String? password;

  @override
  String toString() {
    return 'TwoFactorEnableRequest(code: $code, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TwoFactorEnableRequestImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, password);

  /// Create a copy of TwoFactorEnableRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TwoFactorEnableRequestImplCopyWith<_$TwoFactorEnableRequestImpl>
  get copyWith =>
      __$$TwoFactorEnableRequestImplCopyWithImpl<_$TwoFactorEnableRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TwoFactorEnableRequestImplToJson(this);
  }
}

abstract class _TwoFactorEnableRequest implements TwoFactorEnableRequest {
  const factory _TwoFactorEnableRequest({
    required final String code,
    final String? password,
  }) = _$TwoFactorEnableRequestImpl;

  factory _TwoFactorEnableRequest.fromJson(Map<String, dynamic> json) =
      _$TwoFactorEnableRequestImpl.fromJson;

  @override
  String get code;
  @override
  String? get password;

  /// Create a copy of TwoFactorEnableRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TwoFactorEnableRequestImplCopyWith<_$TwoFactorEnableRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

BackupCodesResponse _$BackupCodesResponseFromJson(Map<String, dynamic> json) {
  return _BackupCodesResponse.fromJson(json);
}

/// @nodoc
mixin _$BackupCodesResponse {
  List<String> get codes => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this BackupCodesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupCodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupCodesResponseCopyWith<BackupCodesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupCodesResponseCopyWith<$Res> {
  factory $BackupCodesResponseCopyWith(
    BackupCodesResponse value,
    $Res Function(BackupCodesResponse) then,
  ) = _$BackupCodesResponseCopyWithImpl<$Res, BackupCodesResponse>;
  @useResult
  $Res call({List<String> codes, String message});
}

/// @nodoc
class _$BackupCodesResponseCopyWithImpl<$Res, $Val extends BackupCodesResponse>
    implements $BackupCodesResponseCopyWith<$Res> {
  _$BackupCodesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupCodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? codes = null, Object? message = null}) {
    return _then(
      _value.copyWith(
            codes: null == codes
                ? _value.codes
                : codes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$BackupCodesResponseImplCopyWith<$Res>
    implements $BackupCodesResponseCopyWith<$Res> {
  factory _$$BackupCodesResponseImplCopyWith(
    _$BackupCodesResponseImpl value,
    $Res Function(_$BackupCodesResponseImpl) then,
  ) = __$$BackupCodesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> codes, String message});
}

/// @nodoc
class __$$BackupCodesResponseImplCopyWithImpl<$Res>
    extends _$BackupCodesResponseCopyWithImpl<$Res, _$BackupCodesResponseImpl>
    implements _$$BackupCodesResponseImplCopyWith<$Res> {
  __$$BackupCodesResponseImplCopyWithImpl(
    _$BackupCodesResponseImpl _value,
    $Res Function(_$BackupCodesResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupCodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? codes = null, Object? message = null}) {
    return _then(
      _$BackupCodesResponseImpl(
        codes: null == codes
            ? _value._codes
            : codes // ignore: cast_nullable_to_non_nullable
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
class _$BackupCodesResponseImpl implements _BackupCodesResponse {
  const _$BackupCodesResponseImpl({
    required final List<String> codes,
    this.message = '',
  }) : _codes = codes;

  factory _$BackupCodesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupCodesResponseImplFromJson(json);

  final List<String> _codes;
  @override
  List<String> get codes {
    if (_codes is EqualUnmodifiableListView) return _codes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_codes);
  }

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'BackupCodesResponse(codes: $codes, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupCodesResponseImpl &&
            const DeepCollectionEquality().equals(other._codes, _codes) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_codes),
    message,
  );

  /// Create a copy of BackupCodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupCodesResponseImplCopyWith<_$BackupCodesResponseImpl> get copyWith =>
      __$$BackupCodesResponseImplCopyWithImpl<_$BackupCodesResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupCodesResponseImplToJson(this);
  }
}

abstract class _BackupCodesResponse implements BackupCodesResponse {
  const factory _BackupCodesResponse({
    required final List<String> codes,
    final String message,
  }) = _$BackupCodesResponseImpl;

  factory _BackupCodesResponse.fromJson(Map<String, dynamic> json) =
      _$BackupCodesResponseImpl.fromJson;

  @override
  List<String> get codes;
  @override
  String get message;

  /// Create a copy of BackupCodesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupCodesResponseImplCopyWith<_$BackupCodesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
