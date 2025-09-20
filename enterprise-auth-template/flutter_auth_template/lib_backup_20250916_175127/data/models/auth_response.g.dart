// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : AuthResponseData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] == null
          ? null
          : AuthResponseError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      if (instance.message case final value?) 'message': value,
      if (instance.data?.toJson() case final value?) 'data': value,
      if (instance.error?.toJson() case final value?) 'error': value,
    };

_$AuthResponseDataImpl _$$AuthResponseDataImplFromJson(
  Map<String, dynamic> json,
) => _$AuthResponseDataImpl(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String?,
);

Map<String, dynamic> _$$AuthResponseDataImplToJson(
  _$AuthResponseDataImpl instance,
) => <String, dynamic>{
  'user': instance.user.toJson(),
  'accessToken': instance.accessToken,
  if (instance.refreshToken case final value?) 'refreshToken': value,
};

_$AuthResponseErrorImpl _$$AuthResponseErrorImplFromJson(
  Map<String, dynamic> json,
) => _$AuthResponseErrorImpl(
  code: json['code'] as String,
  message: json['message'] as String,
  details: json['details'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$AuthResponseErrorImplToJson(
  _$AuthResponseErrorImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  if (instance.details case final value?) 'details': value,
};

_$TwoFactorSetupResponseImpl _$$TwoFactorSetupResponseImplFromJson(
  Map<String, dynamic> json,
) => _$TwoFactorSetupResponseImpl(
  secret: json['secret'] as String,
  qrCode: json['qrCode'] as String,
  backupCodes: (json['backupCodes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$TwoFactorSetupResponseImplToJson(
  _$TwoFactorSetupResponseImpl instance,
) => <String, dynamic>{
  'secret': instance.secret,
  'qrCode': instance.qrCode,
  'backupCodes': instance.backupCodes,
};

_$WebAuthnRegistrationResponseImpl _$$WebAuthnRegistrationResponseImplFromJson(
  Map<String, dynamic> json,
) => _$WebAuthnRegistrationResponseImpl(
  challenge: json['challenge'] as String,
  publicKeyCredentialCreationOptions:
      json['publicKeyCredentialCreationOptions'] as Map<String, dynamic>,
);

Map<String, dynamic> _$$WebAuthnRegistrationResponseImplToJson(
  _$WebAuthnRegistrationResponseImpl instance,
) => <String, dynamic>{
  'challenge': instance.challenge,
  'publicKeyCredentialCreationOptions':
      instance.publicKeyCredentialCreationOptions,
};

_$WebAuthnAuthenticationResponseImpl
_$$WebAuthnAuthenticationResponseImplFromJson(Map<String, dynamic> json) =>
    _$WebAuthnAuthenticationResponseImpl(
      challenge: json['challenge'] as String,
      publicKeyCredentialRequestOptions:
          json['publicKeyCredentialRequestOptions'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$WebAuthnAuthenticationResponseImplToJson(
  _$WebAuthnAuthenticationResponseImpl instance,
) => <String, dynamic>{
  'challenge': instance.challenge,
  'publicKeyCredentialRequestOptions':
      instance.publicKeyCredentialRequestOptions,
};
