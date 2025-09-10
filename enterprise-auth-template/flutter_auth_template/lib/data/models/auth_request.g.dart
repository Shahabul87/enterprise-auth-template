// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

_$RegisterRequestImpl _$$RegisterRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterRequestImpl(
  email: json['email'] as String,
  password: json['password'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$$RegisterRequestImplToJson(
  _$RegisterRequestImpl instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'name': instance.name,
};

_$ForgotPasswordRequestImpl _$$ForgotPasswordRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ForgotPasswordRequestImpl(email: json['email'] as String);

Map<String, dynamic> _$$ForgotPasswordRequestImplToJson(
  _$ForgotPasswordRequestImpl instance,
) => <String, dynamic>{'email': instance.email};

_$ResetPasswordRequestImpl _$$ResetPasswordRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ResetPasswordRequestImpl(
  token: json['token'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$ResetPasswordRequestImplToJson(
  _$ResetPasswordRequestImpl instance,
) => <String, dynamic>{'token': instance.token, 'password': instance.password};

_$OAuthLoginRequestImpl _$$OAuthLoginRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OAuthLoginRequestImpl(
  provider: json['provider'] as String,
  code: json['code'] as String,
  state: json['state'] as String?,
);

Map<String, dynamic> _$$OAuthLoginRequestImplToJson(
  _$OAuthLoginRequestImpl instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'code': instance.code,
  if (instance.state case final value?) 'state': value,
};

_$MagicLinkRequestImpl _$$MagicLinkRequestImplFromJson(
  Map<String, dynamic> json,
) => _$MagicLinkRequestImpl(email: json['email'] as String);

Map<String, dynamic> _$$MagicLinkRequestImplToJson(
  _$MagicLinkRequestImpl instance,
) => <String, dynamic>{'email': instance.email};

_$VerifyTwoFactorRequestImpl _$$VerifyTwoFactorRequestImplFromJson(
  Map<String, dynamic> json,
) => _$VerifyTwoFactorRequestImpl(
  code: json['code'] as String,
  token: json['token'] as String?,
  isBackup: json['isBackup'] as bool?,
);

Map<String, dynamic> _$$VerifyTwoFactorRequestImplToJson(
  _$VerifyTwoFactorRequestImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  if (instance.token case final value?) 'token': value,
  if (instance.isBackup case final value?) 'isBackup': value,
};

_$VerifyEmailRequestImpl _$$VerifyEmailRequestImplFromJson(
  Map<String, dynamic> json,
) => _$VerifyEmailRequestImpl(token: json['token'] as String);

Map<String, dynamic> _$$VerifyEmailRequestImplToJson(
  _$VerifyEmailRequestImpl instance,
) => <String, dynamic>{'token': instance.token};

_$ChangePasswordRequestImpl _$$ChangePasswordRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ChangePasswordRequestImpl(
  currentPassword: json['currentPassword'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$$ChangePasswordRequestImplToJson(
  _$ChangePasswordRequestImpl instance,
) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};
