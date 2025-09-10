// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'two_factor_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TwoFactorSetupResponseImpl _$$TwoFactorSetupResponseImplFromJson(
  Map<String, dynamic> json,
) => _$TwoFactorSetupResponseImpl(
  secret: json['secret'] as String,
  qrCode: json['qrCode'] as String,
  backupCodes: (json['backupCodes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  setupKey: json['setupKey'] as String? ?? '',
);

Map<String, dynamic> _$$TwoFactorSetupResponseImplToJson(
  _$TwoFactorSetupResponseImpl instance,
) => <String, dynamic>{
  'secret': instance.secret,
  'qrCode': instance.qrCode,
  'backupCodes': instance.backupCodes,
  'setupKey': instance.setupKey,
};

_$TwoFactorStatusImpl _$$TwoFactorStatusImplFromJson(
  Map<String, dynamic> json,
) => _$TwoFactorStatusImpl(
  enabled: json['enabled'] as bool? ?? false,
  hasBackupCodes: json['hasBackupCodes'] as bool? ?? false,
  backupCodesUsed: (json['backupCodesUsed'] as num?)?.toInt() ?? 0,
  backupCodesRemaining: (json['backupCodesRemaining'] as num?)?.toInt() ?? 0,
  lastUsed: json['lastUsed'] == null
      ? null
      : DateTime.parse(json['lastUsed'] as String),
  method: json['method'] as String?,
);

Map<String, dynamic> _$$TwoFactorStatusImplToJson(
  _$TwoFactorStatusImpl instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'hasBackupCodes': instance.hasBackupCodes,
  'backupCodesUsed': instance.backupCodesUsed,
  'backupCodesRemaining': instance.backupCodesRemaining,
  if (instance.lastUsed?.toIso8601String() case final value?) 'lastUsed': value,
  if (instance.method case final value?) 'method': value,
};

_$TwoFactorVerifyRequestImpl _$$TwoFactorVerifyRequestImplFromJson(
  Map<String, dynamic> json,
) => _$TwoFactorVerifyRequestImpl(
  code: json['code'] as String,
  isBackupCode: json['isBackupCode'] as bool? ?? false,
  method: json['method'] as String?,
);

Map<String, dynamic> _$$TwoFactorVerifyRequestImplToJson(
  _$TwoFactorVerifyRequestImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'isBackupCode': instance.isBackupCode,
  if (instance.method case final value?) 'method': value,
};

_$TwoFactorEnableRequestImpl _$$TwoFactorEnableRequestImplFromJson(
  Map<String, dynamic> json,
) => _$TwoFactorEnableRequestImpl(
  code: json['code'] as String,
  password: json['password'] as String?,
);

Map<String, dynamic> _$$TwoFactorEnableRequestImplToJson(
  _$TwoFactorEnableRequestImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  if (instance.password case final value?) 'password': value,
};

_$BackupCodesResponseImpl _$$BackupCodesResponseImplFromJson(
  Map<String, dynamic> json,
) => _$BackupCodesResponseImpl(
  codes: (json['codes'] as List<dynamic>).map((e) => e as String).toList(),
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$$BackupCodesResponseImplToJson(
  _$BackupCodesResponseImpl instance,
) => <String, dynamic>{'codes': instance.codes, 'message': instance.message};
