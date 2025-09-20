// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      settings: json['settings'] == null
          ? null
          : ProfileSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      if (instance.name case final value?) 'name': value,
      if (instance.avatarUrl case final value?) 'avatarUrl': value,
      if (instance.phone case final value?) 'phone': value,
      if (instance.bio case final value?) 'bio': value,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'twoFactorEnabled': instance.twoFactorEnabled,
      'roles': instance.roles,
      'metadata': instance.metadata,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
      if (instance.lastLoginAt?.toIso8601String() case final value?)
        'lastLoginAt': value,
      if (instance.settings?.toJson() case final value?) 'settings': value,
    };

_$ProfileSettingsImpl _$$ProfileSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileSettingsImpl(
  emailNotifications: json['emailNotifications'] as bool? ?? true,
  pushNotifications: json['pushNotifications'] as bool? ?? true,
  smsNotifications: json['smsNotifications'] as bool? ?? false,
  marketingEmails: json['marketingEmails'] as bool? ?? true,
  securityAlerts: json['securityAlerts'] as bool? ?? true,
  language: json['language'] as String? ?? 'en',
  timezone: json['timezone'] as String? ?? 'UTC',
  theme: json['theme'] as String? ?? 'light',
  preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$ProfileSettingsImplToJson(
  _$ProfileSettingsImpl instance,
) => <String, dynamic>{
  'emailNotifications': instance.emailNotifications,
  'pushNotifications': instance.pushNotifications,
  'smsNotifications': instance.smsNotifications,
  'marketingEmails': instance.marketingEmails,
  'securityAlerts': instance.securityAlerts,
  'language': instance.language,
  'timezone': instance.timezone,
  'theme': instance.theme,
  'preferences': instance.preferences,
};

_$ProfileUpdateRequestImpl _$$ProfileUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileUpdateRequestImpl(
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  bio: json['bio'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  settings: json['settings'] == null
      ? null
      : ProfileSettings.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ProfileUpdateRequestImplToJson(
  _$ProfileUpdateRequestImpl instance,
) => <String, dynamic>{
  if (instance.name case final value?) 'name': value,
  if (instance.phone case final value?) 'phone': value,
  if (instance.bio case final value?) 'bio': value,
  if (instance.metadata case final value?) 'metadata': value,
  if (instance.settings?.toJson() case final value?) 'settings': value,
};

_$ProfileStatisticsImpl _$$ProfileStatisticsImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileStatisticsImpl(
  loginCount: (json['loginCount'] as num?)?.toInt() ?? 0,
  sessionsActive: (json['sessionsActive'] as num?)?.toInt() ?? 0,
  devicesLinked: (json['devicesLinked'] as num?)?.toInt() ?? 0,
  lastPasswordChange: json['lastPasswordChange'] == null
      ? null
      : DateTime.parse(json['lastPasswordChange'] as String),
  last2FAChange: json['last2FAChange'] == null
      ? null
      : DateTime.parse(json['last2FAChange'] as String),
  recentLogins:
      (json['recentLogins'] as List<dynamic>?)
          ?.map((e) => LoginHistory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  activityStats:
      (json['activityStats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$$ProfileStatisticsImplToJson(
  _$ProfileStatisticsImpl instance,
) => <String, dynamic>{
  'loginCount': instance.loginCount,
  'sessionsActive': instance.sessionsActive,
  'devicesLinked': instance.devicesLinked,
  if (instance.lastPasswordChange?.toIso8601String() case final value?)
    'lastPasswordChange': value,
  if (instance.last2FAChange?.toIso8601String() case final value?)
    'last2FAChange': value,
  'recentLogins': instance.recentLogins.map((e) => e.toJson()).toList(),
  'activityStats': instance.activityStats,
};

_$LoginHistoryImpl _$$LoginHistoryImplFromJson(Map<String, dynamic> json) =>
    _$LoginHistoryImpl(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      location: json['location'] as String?,
      device: json['device'] as String?,
      successful: json['successful'] as bool? ?? true,
      failureReason: json['failureReason'] as String?,
    );

Map<String, dynamic> _$$LoginHistoryImplToJson(_$LoginHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      if (instance.ipAddress case final value?) 'ipAddress': value,
      if (instance.userAgent case final value?) 'userAgent': value,
      if (instance.location case final value?) 'location': value,
      if (instance.device case final value?) 'device': value,
      'successful': instance.successful,
      if (instance.failureReason case final value?) 'failureReason': value,
    };

_$PrivacySettingsImpl _$$PrivacySettingsImplFromJson(
  Map<String, dynamic> json,
) => _$PrivacySettingsImpl(
  profileVisibility: json['profileVisibility'] as String? ?? 'public',
  showEmail: json['showEmail'] as bool? ?? true,
  showPhone: json['showPhone'] as bool? ?? false,
  showLastSeen: json['showLastSeen'] as bool? ?? true,
  showOnlineStatus: json['showOnlineStatus'] as bool? ?? true,
  blockedUsers:
      (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  dataSharing:
      (json['dataSharing'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
);

Map<String, dynamic> _$$PrivacySettingsImplToJson(
  _$PrivacySettingsImpl instance,
) => <String, dynamic>{
  'profileVisibility': instance.profileVisibility,
  'showEmail': instance.showEmail,
  'showPhone': instance.showPhone,
  'showLastSeen': instance.showLastSeen,
  'showOnlineStatus': instance.showOnlineStatus,
  'blockedUsers': instance.blockedUsers,
  'dataSharing': instance.dataSharing,
};
