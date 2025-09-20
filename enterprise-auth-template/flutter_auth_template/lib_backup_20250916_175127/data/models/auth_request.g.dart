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
  fullName: json['full_name'] as String,
  confirmPassword: json['confirm_password'] as String,
  organization: json['organization'] as String?,
  agreeToTerms: json['agree_to_terms'] as bool,
  subscribeNewsletter: json['subscribe_newsletter'] as bool?,
);

Map<String, dynamic> _$$RegisterRequestImplToJson(
  _$RegisterRequestImpl instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'full_name': instance.fullName,
  'confirm_password': instance.confirmPassword,
  if (instance.organization case final value?) 'organization': value,
  'agree_to_terms': instance.agreeToTerms,
  if (instance.subscribeNewsletter case final value?)
    'subscribe_newsletter': value,
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

_$ChangePasswordRequestImpl _$$ChangePasswordRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ChangePasswordRequestImpl(
  currentPassword: json['current_password'] as String,
  newPassword: json['new_password'] as String,
  confirmPassword: json['confirm_password'] as String,
);

Map<String, dynamic> _$$ChangePasswordRequestImplToJson(
  _$ChangePasswordRequestImpl instance,
) => <String, dynamic>{
  'current_password': instance.currentPassword,
  'new_password': instance.newPassword,
  'confirm_password': instance.confirmPassword,
};

_$VerifyEmailRequestImpl _$$VerifyEmailRequestImplFromJson(
  Map<String, dynamic> json,
) => _$VerifyEmailRequestImpl(token: json['token'] as String);

Map<String, dynamic> _$$VerifyEmailRequestImplToJson(
  _$VerifyEmailRequestImpl instance,
) => <String, dynamic>{'token': instance.token};
