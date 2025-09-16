// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return _LoginRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this LoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginRequestCopyWith<LoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestCopyWith<$Res> {
  factory $LoginRequestCopyWith(
    LoginRequest value,
    $Res Function(LoginRequest) then,
  ) = _$LoginRequestCopyWithImpl<$Res, LoginRequest>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginRequestCopyWithImpl<$Res, $Val extends LoginRequest>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginRequestImplCopyWith<$Res>
    implements $LoginRequestCopyWith<$Res> {
  factory _$$LoginRequestImplCopyWith(
    _$LoginRequestImpl value,
    $Res Function(_$LoginRequestImpl) then,
  ) = __$$LoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginRequestImplCopyWithImpl<$Res>
    extends _$LoginRequestCopyWithImpl<$Res, _$LoginRequestImpl>
    implements _$$LoginRequestImplCopyWith<$Res> {
  __$$LoginRequestImplCopyWithImpl(
    _$LoginRequestImpl _value,
    $Res Function(_$LoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _$LoginRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestImpl implements _LoginRequest {
  const _$LoginRequestImpl({required this.email, required this.password});

  factory _$LoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      __$$LoginRequestImplCopyWithImpl<_$LoginRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestImplToJson(this);
  }
}

abstract class _LoginRequest implements LoginRequest {
  const factory _LoginRequest({
    required final String email,
    required final String password,
  }) = _$LoginRequestImpl;

  factory _LoginRequest.fromJson(Map<String, dynamic> json) =
      _$LoginRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;

  /// Create a copy of LoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) {
  return _RegisterRequest.fromJson(json);
}

/// @nodoc
mixin _$RegisterRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'confirm_password')
  String get confirmPassword => throw _privateConstructorUsedError;
  String? get organization => throw _privateConstructorUsedError;
  @JsonKey(name: 'agree_to_terms')
  bool get agreeToTerms => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscribe_newsletter')
  bool? get subscribeNewsletter => throw _privateConstructorUsedError;

  /// Serializes this RegisterRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterRequestCopyWith<RegisterRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterRequestCopyWith<$Res> {
  factory $RegisterRequestCopyWith(
    RegisterRequest value,
    $Res Function(RegisterRequest) then,
  ) = _$RegisterRequestCopyWithImpl<$Res, RegisterRequest>;
  @useResult
  $Res call({
    String email,
    String password,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'confirm_password') String confirmPassword,
    String? organization,
    @JsonKey(name: 'agree_to_terms') bool agreeToTerms,
    @JsonKey(name: 'subscribe_newsletter') bool? subscribeNewsletter,
  });
}

/// @nodoc
class _$RegisterRequestCopyWithImpl<$Res, $Val extends RegisterRequest>
    implements $RegisterRequestCopyWith<$Res> {
  _$RegisterRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? fullName = null,
    Object? confirmPassword = null,
    Object? organization = freezed,
    Object? agreeToTerms = null,
    Object? subscribeNewsletter = freezed,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            confirmPassword: null == confirmPassword
                ? _value.confirmPassword
                : confirmPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            organization: freezed == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                      as String?,
            agreeToTerms: null == agreeToTerms
                ? _value.agreeToTerms
                : agreeToTerms // ignore: cast_nullable_to_non_nullable
                      as bool,
            subscribeNewsletter: freezed == subscribeNewsletter
                ? _value.subscribeNewsletter
                : subscribeNewsletter // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegisterRequestImplCopyWith<$Res>
    implements $RegisterRequestCopyWith<$Res> {
  factory _$$RegisterRequestImplCopyWith(
    _$RegisterRequestImpl value,
    $Res Function(_$RegisterRequestImpl) then,
  ) = __$$RegisterRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String email,
    String password,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'confirm_password') String confirmPassword,
    String? organization,
    @JsonKey(name: 'agree_to_terms') bool agreeToTerms,
    @JsonKey(name: 'subscribe_newsletter') bool? subscribeNewsletter,
  });
}

/// @nodoc
class __$$RegisterRequestImplCopyWithImpl<$Res>
    extends _$RegisterRequestCopyWithImpl<$Res, _$RegisterRequestImpl>
    implements _$$RegisterRequestImplCopyWith<$Res> {
  __$$RegisterRequestImplCopyWithImpl(
    _$RegisterRequestImpl _value,
    $Res Function(_$RegisterRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? fullName = null,
    Object? confirmPassword = null,
    Object? organization = freezed,
    Object? agreeToTerms = null,
    Object? subscribeNewsletter = freezed,
  }) {
    return _then(
      _$RegisterRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        confirmPassword: null == confirmPassword
            ? _value.confirmPassword
            : confirmPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        organization: freezed == organization
            ? _value.organization
            : organization // ignore: cast_nullable_to_non_nullable
                  as String?,
        agreeToTerms: null == agreeToTerms
            ? _value.agreeToTerms
            : agreeToTerms // ignore: cast_nullable_to_non_nullable
                  as bool,
        subscribeNewsletter: freezed == subscribeNewsletter
            ? _value.subscribeNewsletter
            : subscribeNewsletter // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterRequestImpl implements _RegisterRequest {
  const _$RegisterRequestImpl({
    required this.email,
    required this.password,
    @JsonKey(name: 'full_name') required this.fullName,
    @JsonKey(name: 'confirm_password') required this.confirmPassword,
    this.organization,
    @JsonKey(name: 'agree_to_terms') required this.agreeToTerms,
    @JsonKey(name: 'subscribe_newsletter') this.subscribeNewsletter,
  });

  factory _$RegisterRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;
  @override
  final String? organization;
  @override
  @JsonKey(name: 'agree_to_terms')
  final bool agreeToTerms;
  @override
  @JsonKey(name: 'subscribe_newsletter')
  final bool? subscribeNewsletter;

  @override
  String toString() {
    return 'RegisterRequest(email: $email, password: $password, fullName: $fullName, confirmPassword: $confirmPassword, organization: $organization, agreeToTerms: $agreeToTerms, subscribeNewsletter: $subscribeNewsletter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.confirmPassword, confirmPassword) ||
                other.confirmPassword == confirmPassword) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.agreeToTerms, agreeToTerms) ||
                other.agreeToTerms == agreeToTerms) &&
            (identical(other.subscribeNewsletter, subscribeNewsletter) ||
                other.subscribeNewsletter == subscribeNewsletter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    email,
    password,
    fullName,
    confirmPassword,
    organization,
    agreeToTerms,
    subscribeNewsletter,
  );

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      __$$RegisterRequestImplCopyWithImpl<_$RegisterRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterRequestImplToJson(this);
  }
}

abstract class _RegisterRequest implements RegisterRequest {
  const factory _RegisterRequest({
    required final String email,
    required final String password,
    @JsonKey(name: 'full_name') required final String fullName,
    @JsonKey(name: 'confirm_password') required final String confirmPassword,
    final String? organization,
    @JsonKey(name: 'agree_to_terms') required final bool agreeToTerms,
    @JsonKey(name: 'subscribe_newsletter') final bool? subscribeNewsletter,
  }) = _$RegisterRequestImpl;

  factory _RegisterRequest.fromJson(Map<String, dynamic> json) =
      _$RegisterRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'confirm_password')
  String get confirmPassword;
  @override
  String? get organization;
  @override
  @JsonKey(name: 'agree_to_terms')
  bool get agreeToTerms;
  @override
  @JsonKey(name: 'subscribe_newsletter')
  bool? get subscribeNewsletter;

  /// Create a copy of RegisterRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterRequestImplCopyWith<_$RegisterRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ForgotPasswordRequest.fromJson(json);
}

/// @nodoc
mixin _$ForgotPasswordRequest {
  String get email => throw _privateConstructorUsedError;

  /// Serializes this ForgotPasswordRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForgotPasswordRequestCopyWith<ForgotPasswordRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForgotPasswordRequestCopyWith<$Res> {
  factory $ForgotPasswordRequestCopyWith(
    ForgotPasswordRequest value,
    $Res Function(ForgotPasswordRequest) then,
  ) = _$ForgotPasswordRequestCopyWithImpl<$Res, ForgotPasswordRequest>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$ForgotPasswordRequestCopyWithImpl<
  $Res,
  $Val extends ForgotPasswordRequest
>
    implements $ForgotPasswordRequestCopyWith<$Res> {
  _$ForgotPasswordRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ForgotPasswordRequestImplCopyWith<$Res>
    implements $ForgotPasswordRequestCopyWith<$Res> {
  factory _$$ForgotPasswordRequestImplCopyWith(
    _$ForgotPasswordRequestImpl value,
    $Res Function(_$ForgotPasswordRequestImpl) then,
  ) = __$$ForgotPasswordRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$ForgotPasswordRequestImplCopyWithImpl<$Res>
    extends
        _$ForgotPasswordRequestCopyWithImpl<$Res, _$ForgotPasswordRequestImpl>
    implements _$$ForgotPasswordRequestImplCopyWith<$Res> {
  __$$ForgotPasswordRequestImplCopyWithImpl(
    _$ForgotPasswordRequestImpl _value,
    $Res Function(_$ForgotPasswordRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _$ForgotPasswordRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ForgotPasswordRequestImpl implements _ForgotPasswordRequest {
  const _$ForgotPasswordRequestImpl({required this.email});

  factory _$ForgotPasswordRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ForgotPasswordRequestImplFromJson(json);

  @override
  final String email;

  @override
  String toString() {
    return 'ForgotPasswordRequest(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForgotPasswordRequestImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForgotPasswordRequestImplCopyWith<_$ForgotPasswordRequestImpl>
  get copyWith =>
      __$$ForgotPasswordRequestImplCopyWithImpl<_$ForgotPasswordRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ForgotPasswordRequestImplToJson(this);
  }
}

abstract class _ForgotPasswordRequest implements ForgotPasswordRequest {
  const factory _ForgotPasswordRequest({required final String email}) =
      _$ForgotPasswordRequestImpl;

  factory _ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =
      _$ForgotPasswordRequestImpl.fromJson;

  @override
  String get email;

  /// Create a copy of ForgotPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForgotPasswordRequestImplCopyWith<_$ForgotPasswordRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ResetPasswordRequest _$ResetPasswordRequestFromJson(Map<String, dynamic> json) {
  return _ResetPasswordRequest.fromJson(json);
}

/// @nodoc
mixin _$ResetPasswordRequest {
  String get token => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this ResetPasswordRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResetPasswordRequestCopyWith<ResetPasswordRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResetPasswordRequestCopyWith<$Res> {
  factory $ResetPasswordRequestCopyWith(
    ResetPasswordRequest value,
    $Res Function(ResetPasswordRequest) then,
  ) = _$ResetPasswordRequestCopyWithImpl<$Res, ResetPasswordRequest>;
  @useResult
  $Res call({String token, String password});
}

/// @nodoc
class _$ResetPasswordRequestCopyWithImpl<
  $Res,
  $Val extends ResetPasswordRequest
>
    implements $ResetPasswordRequestCopyWith<$Res> {
  _$ResetPasswordRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResetPasswordRequestImplCopyWith<$Res>
    implements $ResetPasswordRequestCopyWith<$Res> {
  factory _$$ResetPasswordRequestImplCopyWith(
    _$ResetPasswordRequestImpl value,
    $Res Function(_$ResetPasswordRequestImpl) then,
  ) = __$$ResetPasswordRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String password});
}

/// @nodoc
class __$$ResetPasswordRequestImplCopyWithImpl<$Res>
    extends _$ResetPasswordRequestCopyWithImpl<$Res, _$ResetPasswordRequestImpl>
    implements _$$ResetPasswordRequestImplCopyWith<$Res> {
  __$$ResetPasswordRequestImplCopyWithImpl(
    _$ResetPasswordRequestImpl _value,
    $Res Function(_$ResetPasswordRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null, Object? password = null}) {
    return _then(
      _$ResetPasswordRequestImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResetPasswordRequestImpl implements _ResetPasswordRequest {
  const _$ResetPasswordRequestImpl({
    required this.token,
    required this.password,
  });

  factory _$ResetPasswordRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResetPasswordRequestImplFromJson(json);

  @override
  final String token;
  @override
  final String password;

  @override
  String toString() {
    return 'ResetPasswordRequest(token: $token, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetPasswordRequestImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, password);

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetPasswordRequestImplCopyWith<_$ResetPasswordRequestImpl>
  get copyWith =>
      __$$ResetPasswordRequestImplCopyWithImpl<_$ResetPasswordRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResetPasswordRequestImplToJson(this);
  }
}

abstract class _ResetPasswordRequest implements ResetPasswordRequest {
  const factory _ResetPasswordRequest({
    required final String token,
    required final String password,
  }) = _$ResetPasswordRequestImpl;

  factory _ResetPasswordRequest.fromJson(Map<String, dynamic> json) =
      _$ResetPasswordRequestImpl.fromJson;

  @override
  String get token;
  @override
  String get password;

  /// Create a copy of ResetPasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResetPasswordRequestImplCopyWith<_$ResetPasswordRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OAuthLoginRequest _$OAuthLoginRequestFromJson(Map<String, dynamic> json) {
  return _OAuthLoginRequest.fromJson(json);
}

/// @nodoc
mixin _$OAuthLoginRequest {
  String get provider => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;

  /// Serializes this OAuthLoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OAuthLoginRequestCopyWith<OAuthLoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OAuthLoginRequestCopyWith<$Res> {
  factory $OAuthLoginRequestCopyWith(
    OAuthLoginRequest value,
    $Res Function(OAuthLoginRequest) then,
  ) = _$OAuthLoginRequestCopyWithImpl<$Res, OAuthLoginRequest>;
  @useResult
  $Res call({String provider, String code, String? state});
}

/// @nodoc
class _$OAuthLoginRequestCopyWithImpl<$Res, $Val extends OAuthLoginRequest>
    implements $OAuthLoginRequestCopyWith<$Res> {
  _$OAuthLoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? code = null,
    Object? state = freezed,
  }) {
    return _then(
      _value.copyWith(
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            state: freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OAuthLoginRequestImplCopyWith<$Res>
    implements $OAuthLoginRequestCopyWith<$Res> {
  factory _$$OAuthLoginRequestImplCopyWith(
    _$OAuthLoginRequestImpl value,
    $Res Function(_$OAuthLoginRequestImpl) then,
  ) = __$$OAuthLoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String provider, String code, String? state});
}

/// @nodoc
class __$$OAuthLoginRequestImplCopyWithImpl<$Res>
    extends _$OAuthLoginRequestCopyWithImpl<$Res, _$OAuthLoginRequestImpl>
    implements _$$OAuthLoginRequestImplCopyWith<$Res> {
  __$$OAuthLoginRequestImplCopyWithImpl(
    _$OAuthLoginRequestImpl _value,
    $Res Function(_$OAuthLoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? code = null,
    Object? state = freezed,
  }) {
    return _then(
      _$OAuthLoginRequestImpl(
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        state: freezed == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OAuthLoginRequestImpl implements _OAuthLoginRequest {
  const _$OAuthLoginRequestImpl({
    required this.provider,
    required this.code,
    this.state,
  });

  factory _$OAuthLoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OAuthLoginRequestImplFromJson(json);

  @override
  final String provider;
  @override
  final String code;
  @override
  final String? state;

  @override
  String toString() {
    return 'OAuthLoginRequest(provider: $provider, code: $code, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OAuthLoginRequestImpl &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.state, state) || other.state == state));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, provider, code, state);

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OAuthLoginRequestImplCopyWith<_$OAuthLoginRequestImpl> get copyWith =>
      __$$OAuthLoginRequestImplCopyWithImpl<_$OAuthLoginRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OAuthLoginRequestImplToJson(this);
  }
}

abstract class _OAuthLoginRequest implements OAuthLoginRequest {
  const factory _OAuthLoginRequest({
    required final String provider,
    required final String code,
    final String? state,
  }) = _$OAuthLoginRequestImpl;

  factory _OAuthLoginRequest.fromJson(Map<String, dynamic> json) =
      _$OAuthLoginRequestImpl.fromJson;

  @override
  String get provider;
  @override
  String get code;
  @override
  String? get state;

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OAuthLoginRequestImplCopyWith<_$OAuthLoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MagicLinkRequest _$MagicLinkRequestFromJson(Map<String, dynamic> json) {
  return _MagicLinkRequest.fromJson(json);
}

/// @nodoc
mixin _$MagicLinkRequest {
  String get email => throw _privateConstructorUsedError;

  /// Serializes this MagicLinkRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MagicLinkRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MagicLinkRequestCopyWith<MagicLinkRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MagicLinkRequestCopyWith<$Res> {
  factory $MagicLinkRequestCopyWith(
    MagicLinkRequest value,
    $Res Function(MagicLinkRequest) then,
  ) = _$MagicLinkRequestCopyWithImpl<$Res, MagicLinkRequest>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$MagicLinkRequestCopyWithImpl<$Res, $Val extends MagicLinkRequest>
    implements $MagicLinkRequestCopyWith<$Res> {
  _$MagicLinkRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MagicLinkRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MagicLinkRequestImplCopyWith<$Res>
    implements $MagicLinkRequestCopyWith<$Res> {
  factory _$$MagicLinkRequestImplCopyWith(
    _$MagicLinkRequestImpl value,
    $Res Function(_$MagicLinkRequestImpl) then,
  ) = __$$MagicLinkRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$MagicLinkRequestImplCopyWithImpl<$Res>
    extends _$MagicLinkRequestCopyWithImpl<$Res, _$MagicLinkRequestImpl>
    implements _$$MagicLinkRequestImplCopyWith<$Res> {
  __$$MagicLinkRequestImplCopyWithImpl(
    _$MagicLinkRequestImpl _value,
    $Res Function(_$MagicLinkRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MagicLinkRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _$MagicLinkRequestImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MagicLinkRequestImpl implements _MagicLinkRequest {
  const _$MagicLinkRequestImpl({required this.email});

  factory _$MagicLinkRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MagicLinkRequestImplFromJson(json);

  @override
  final String email;

  @override
  String toString() {
    return 'MagicLinkRequest(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MagicLinkRequestImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of MagicLinkRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MagicLinkRequestImplCopyWith<_$MagicLinkRequestImpl> get copyWith =>
      __$$MagicLinkRequestImplCopyWithImpl<_$MagicLinkRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MagicLinkRequestImplToJson(this);
  }
}

abstract class _MagicLinkRequest implements MagicLinkRequest {
  const factory _MagicLinkRequest({required final String email}) =
      _$MagicLinkRequestImpl;

  factory _MagicLinkRequest.fromJson(Map<String, dynamic> json) =
      _$MagicLinkRequestImpl.fromJson;

  @override
  String get email;

  /// Create a copy of MagicLinkRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MagicLinkRequestImplCopyWith<_$MagicLinkRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VerifyTwoFactorRequest _$VerifyTwoFactorRequestFromJson(
  Map<String, dynamic> json,
) {
  return _VerifyTwoFactorRequest.fromJson(json);
}

/// @nodoc
mixin _$VerifyTwoFactorRequest {
  String get code => throw _privateConstructorUsedError;
  String? get token => throw _privateConstructorUsedError;
  bool? get isBackup => throw _privateConstructorUsedError;

  /// Serializes this VerifyTwoFactorRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerifyTwoFactorRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifyTwoFactorRequestCopyWith<VerifyTwoFactorRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyTwoFactorRequestCopyWith<$Res> {
  factory $VerifyTwoFactorRequestCopyWith(
    VerifyTwoFactorRequest value,
    $Res Function(VerifyTwoFactorRequest) then,
  ) = _$VerifyTwoFactorRequestCopyWithImpl<$Res, VerifyTwoFactorRequest>;
  @useResult
  $Res call({String code, String? token, bool? isBackup});
}

/// @nodoc
class _$VerifyTwoFactorRequestCopyWithImpl<
  $Res,
  $Val extends VerifyTwoFactorRequest
>
    implements $VerifyTwoFactorRequestCopyWith<$Res> {
  _$VerifyTwoFactorRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifyTwoFactorRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? token = freezed,
    Object? isBackup = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            token: freezed == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String?,
            isBackup: freezed == isBackup
                ? _value.isBackup
                : isBackup // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VerifyTwoFactorRequestImplCopyWith<$Res>
    implements $VerifyTwoFactorRequestCopyWith<$Res> {
  factory _$$VerifyTwoFactorRequestImplCopyWith(
    _$VerifyTwoFactorRequestImpl value,
    $Res Function(_$VerifyTwoFactorRequestImpl) then,
  ) = __$$VerifyTwoFactorRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String? token, bool? isBackup});
}

/// @nodoc
class __$$VerifyTwoFactorRequestImplCopyWithImpl<$Res>
    extends
        _$VerifyTwoFactorRequestCopyWithImpl<$Res, _$VerifyTwoFactorRequestImpl>
    implements _$$VerifyTwoFactorRequestImplCopyWith<$Res> {
  __$$VerifyTwoFactorRequestImplCopyWithImpl(
    _$VerifyTwoFactorRequestImpl _value,
    $Res Function(_$VerifyTwoFactorRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VerifyTwoFactorRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? token = freezed,
    Object? isBackup = freezed,
  }) {
    return _then(
      _$VerifyTwoFactorRequestImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        token: freezed == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String?,
        isBackup: freezed == isBackup
            ? _value.isBackup
            : isBackup // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VerifyTwoFactorRequestImpl implements _VerifyTwoFactorRequest {
  const _$VerifyTwoFactorRequestImpl({
    required this.code,
    this.token,
    this.isBackup,
  });

  factory _$VerifyTwoFactorRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerifyTwoFactorRequestImplFromJson(json);

  @override
  final String code;
  @override
  final String? token;
  @override
  final bool? isBackup;

  @override
  String toString() {
    return 'VerifyTwoFactorRequest(code: $code, token: $token, isBackup: $isBackup)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyTwoFactorRequestImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.isBackup, isBackup) ||
                other.isBackup == isBackup));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, token, isBackup);

  /// Create a copy of VerifyTwoFactorRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyTwoFactorRequestImplCopyWith<_$VerifyTwoFactorRequestImpl>
  get copyWith =>
      __$$VerifyTwoFactorRequestImplCopyWithImpl<_$VerifyTwoFactorRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VerifyTwoFactorRequestImplToJson(this);
  }
}

abstract class _VerifyTwoFactorRequest implements VerifyTwoFactorRequest {
  const factory _VerifyTwoFactorRequest({
    required final String code,
    final String? token,
    final bool? isBackup,
  }) = _$VerifyTwoFactorRequestImpl;

  factory _VerifyTwoFactorRequest.fromJson(Map<String, dynamic> json) =
      _$VerifyTwoFactorRequestImpl.fromJson;

  @override
  String get code;
  @override
  String? get token;
  @override
  bool? get isBackup;

  /// Create a copy of VerifyTwoFactorRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyTwoFactorRequestImplCopyWith<_$VerifyTwoFactorRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ChangePasswordRequest _$ChangePasswordRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ChangePasswordRequest.fromJson(json);
}

/// @nodoc
mixin _$ChangePasswordRequest {
  @JsonKey(name: 'current_password')
  String get currentPassword => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_password')
  String get newPassword => throw _privateConstructorUsedError;
  @JsonKey(name: 'confirm_password')
  String get confirmPassword => throw _privateConstructorUsedError;

  /// Serializes this ChangePasswordRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChangePasswordRequestCopyWith<ChangePasswordRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangePasswordRequestCopyWith<$Res> {
  factory $ChangePasswordRequestCopyWith(
    ChangePasswordRequest value,
    $Res Function(ChangePasswordRequest) then,
  ) = _$ChangePasswordRequestCopyWithImpl<$Res, ChangePasswordRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'current_password') String currentPassword,
    @JsonKey(name: 'new_password') String newPassword,
    @JsonKey(name: 'confirm_password') String confirmPassword,
  });
}

/// @nodoc
class _$ChangePasswordRequestCopyWithImpl<
  $Res,
  $Val extends ChangePasswordRequest
>
    implements $ChangePasswordRequestCopyWith<$Res> {
  _$ChangePasswordRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPassword = null,
    Object? newPassword = null,
    Object? confirmPassword = null,
  }) {
    return _then(
      _value.copyWith(
            currentPassword: null == currentPassword
                ? _value.currentPassword
                : currentPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            newPassword: null == newPassword
                ? _value.newPassword
                : newPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            confirmPassword: null == confirmPassword
                ? _value.confirmPassword
                : confirmPassword // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChangePasswordRequestImplCopyWith<$Res>
    implements $ChangePasswordRequestCopyWith<$Res> {
  factory _$$ChangePasswordRequestImplCopyWith(
    _$ChangePasswordRequestImpl value,
    $Res Function(_$ChangePasswordRequestImpl) then,
  ) = __$$ChangePasswordRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'current_password') String currentPassword,
    @JsonKey(name: 'new_password') String newPassword,
    @JsonKey(name: 'confirm_password') String confirmPassword,
  });
}

/// @nodoc
class __$$ChangePasswordRequestImplCopyWithImpl<$Res>
    extends
        _$ChangePasswordRequestCopyWithImpl<$Res, _$ChangePasswordRequestImpl>
    implements _$$ChangePasswordRequestImplCopyWith<$Res> {
  __$$ChangePasswordRequestImplCopyWithImpl(
    _$ChangePasswordRequestImpl _value,
    $Res Function(_$ChangePasswordRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPassword = null,
    Object? newPassword = null,
    Object? confirmPassword = null,
  }) {
    return _then(
      _$ChangePasswordRequestImpl(
        currentPassword: null == currentPassword
            ? _value.currentPassword
            : currentPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        newPassword: null == newPassword
            ? _value.newPassword
            : newPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        confirmPassword: null == confirmPassword
            ? _value.confirmPassword
            : confirmPassword // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChangePasswordRequestImpl implements _ChangePasswordRequest {
  const _$ChangePasswordRequestImpl({
    @JsonKey(name: 'current_password') required this.currentPassword,
    @JsonKey(name: 'new_password') required this.newPassword,
    @JsonKey(name: 'confirm_password') required this.confirmPassword,
  });

  factory _$ChangePasswordRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChangePasswordRequestImplFromJson(json);

  @override
  @JsonKey(name: 'current_password')
  final String currentPassword;
  @override
  @JsonKey(name: 'new_password')
  final String newPassword;
  @override
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  @override
  String toString() {
    return 'ChangePasswordRequest(currentPassword: $currentPassword, newPassword: $newPassword, confirmPassword: $confirmPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangePasswordRequestImpl &&
            (identical(other.currentPassword, currentPassword) ||
                other.currentPassword == currentPassword) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword) &&
            (identical(other.confirmPassword, confirmPassword) ||
                other.confirmPassword == confirmPassword));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentPassword, newPassword, confirmPassword);

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangePasswordRequestImplCopyWith<_$ChangePasswordRequestImpl>
  get copyWith =>
      __$$ChangePasswordRequestImplCopyWithImpl<_$ChangePasswordRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChangePasswordRequestImplToJson(this);
  }
}

abstract class _ChangePasswordRequest implements ChangePasswordRequest {
  const factory _ChangePasswordRequest({
    @JsonKey(name: 'current_password') required final String currentPassword,
    @JsonKey(name: 'new_password') required final String newPassword,
    @JsonKey(name: 'confirm_password') required final String confirmPassword,
  }) = _$ChangePasswordRequestImpl;

  factory _ChangePasswordRequest.fromJson(Map<String, dynamic> json) =
      _$ChangePasswordRequestImpl.fromJson;

  @override
  @JsonKey(name: 'current_password')
  String get currentPassword;
  @override
  @JsonKey(name: 'new_password')
  String get newPassword;
  @override
  @JsonKey(name: 'confirm_password')
  String get confirmPassword;

  /// Create a copy of ChangePasswordRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangePasswordRequestImplCopyWith<_$ChangePasswordRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) {
  return _VerifyEmailRequest.fromJson(json);
}

/// @nodoc
mixin _$VerifyEmailRequest {
  String get token => throw _privateConstructorUsedError;

  /// Serializes this VerifyEmailRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerifyEmailRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifyEmailRequestCopyWith<VerifyEmailRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyEmailRequestCopyWith<$Res> {
  factory $VerifyEmailRequestCopyWith(
    VerifyEmailRequest value,
    $Res Function(VerifyEmailRequest) then,
  ) = _$VerifyEmailRequestCopyWithImpl<$Res, VerifyEmailRequest>;
  @useResult
  $Res call({String token});
}

/// @nodoc
class _$VerifyEmailRequestCopyWithImpl<$Res, $Val extends VerifyEmailRequest>
    implements $VerifyEmailRequestCopyWith<$Res> {
  _$VerifyEmailRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifyEmailRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null}) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VerifyEmailRequestImplCopyWith<$Res>
    implements $VerifyEmailRequestCopyWith<$Res> {
  factory _$$VerifyEmailRequestImplCopyWith(
    _$VerifyEmailRequestImpl value,
    $Res Function(_$VerifyEmailRequestImpl) then,
  ) = __$$VerifyEmailRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token});
}

/// @nodoc
class __$$VerifyEmailRequestImplCopyWithImpl<$Res>
    extends _$VerifyEmailRequestCopyWithImpl<$Res, _$VerifyEmailRequestImpl>
    implements _$$VerifyEmailRequestImplCopyWith<$Res> {
  __$$VerifyEmailRequestImplCopyWithImpl(
    _$VerifyEmailRequestImpl _value,
    $Res Function(_$VerifyEmailRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VerifyEmailRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null}) {
    return _then(
      _$VerifyEmailRequestImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VerifyEmailRequestImpl implements _VerifyEmailRequest {
  const _$VerifyEmailRequestImpl({required this.token});

  factory _$VerifyEmailRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerifyEmailRequestImplFromJson(json);

  @override
  final String token;

  @override
  String toString() {
    return 'VerifyEmailRequest(token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyEmailRequestImpl &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token);

  /// Create a copy of VerifyEmailRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyEmailRequestImplCopyWith<_$VerifyEmailRequestImpl> get copyWith =>
      __$$VerifyEmailRequestImplCopyWithImpl<_$VerifyEmailRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VerifyEmailRequestImplToJson(this);
  }
}

abstract class _VerifyEmailRequest implements VerifyEmailRequest {
  const factory _VerifyEmailRequest({required final String token}) =
      _$VerifyEmailRequestImpl;

  factory _VerifyEmailRequest.fromJson(Map<String, dynamic> json) =
      _$VerifyEmailRequestImpl.fromJson;

  @override
  String get token;

  /// Create a copy of VerifyEmailRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyEmailRequestImplCopyWith<_$VerifyEmailRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
