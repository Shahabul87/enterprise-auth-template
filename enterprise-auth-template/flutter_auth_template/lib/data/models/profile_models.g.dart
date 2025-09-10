// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileResponseImpl _$$ProfileResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileResponseImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  timezone: json['timezone'] as String?,
  language: json['language'] as String?,
  isActive: json['isActive'] as bool,
  isVerified: json['isVerified'] as bool,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  lastLogin: json['lastLogin'] as String?,
);

Map<String, dynamic> _$$ProfileResponseImplToJson(
  _$ProfileResponseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  if (instance.phoneNumber case final value?) 'phoneNumber': value,
  if (instance.bio case final value?) 'bio': value,
  if (instance.avatarUrl case final value?) 'avatarUrl': value,
  if (instance.timezone case final value?) 'timezone': value,
  if (instance.language case final value?) 'language': value,
  'isActive': instance.isActive,
  'isVerified': instance.isVerified,
  'roles': instance.roles,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  if (instance.lastLogin case final value?) 'lastLogin': value,
};

_$ProfileUpdateRequestImpl _$$ProfileUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileUpdateRequestImpl(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  bio: json['bio'] as String?,
  timezone: json['timezone'] as String?,
  language: json['language'] as String?,
);

Map<String, dynamic> _$$ProfileUpdateRequestImplToJson(
  _$ProfileUpdateRequestImpl instance,
) => <String, dynamic>{
  if (instance.firstName case final value?) 'firstName': value,
  if (instance.lastName case final value?) 'lastName': value,
  if (instance.phoneNumber case final value?) 'phoneNumber': value,
  if (instance.bio case final value?) 'bio': value,
  if (instance.timezone case final value?) 'timezone': value,
  if (instance.language case final value?) 'language': value,
};

_$PasswordChangeRequestImpl _$$PasswordChangeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$PasswordChangeRequestImpl(
  currentPassword: json['currentPassword'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$$PasswordChangeRequestImplToJson(
  _$PasswordChangeRequestImpl instance,
) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};

_$EmailChangeRequestImpl _$$EmailChangeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$EmailChangeRequestImpl(
  newEmail: json['newEmail'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$EmailChangeRequestImplToJson(
  _$EmailChangeRequestImpl instance,
) => <String, dynamic>{
  'newEmail': instance.newEmail,
  'password': instance.password,
};

_$NotificationPreferencesRequestImpl
_$$NotificationPreferencesRequestImplFromJson(Map<String, dynamic> json) =>
    _$NotificationPreferencesRequestImpl(
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
      marketingEmails: json['marketingEmails'] as bool? ?? false,
      securityAlerts: json['securityAlerts'] as bool? ?? true,
    );

Map<String, dynamic> _$$NotificationPreferencesRequestImplToJson(
  _$NotificationPreferencesRequestImpl instance,
) => <String, dynamic>{
  'emailNotifications': instance.emailNotifications,
  'pushNotifications': instance.pushNotifications,
  'smsNotifications': instance.smsNotifications,
  'marketingEmails': instance.marketingEmails,
  'securityAlerts': instance.securityAlerts,
};

_$SecuritySettingsResponseImpl _$$SecuritySettingsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SecuritySettingsResponseImpl(
  twoFactorEnabled: json['twoFactorEnabled'] as bool,
  loginAlerts: json['loginAlerts'] as bool,
  sessionTimeout: (json['sessionTimeout'] as num).toInt(),
  passwordLastChanged: json['passwordLastChanged'] as String?,
  activeSessions: (json['activeSessions'] as num).toInt(),
);

Map<String, dynamic> _$$SecuritySettingsResponseImplToJson(
  _$SecuritySettingsResponseImpl instance,
) => <String, dynamic>{
  'twoFactorEnabled': instance.twoFactorEnabled,
  'loginAlerts': instance.loginAlerts,
  'sessionTimeout': instance.sessionTimeout,
  if (instance.passwordLastChanged case final value?)
    'passwordLastChanged': value,
  'activeSessions': instance.activeSessions,
};

_$AvatarUploadResponseImpl _$$AvatarUploadResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AvatarUploadResponseImpl(
  avatarUrl: json['avatarUrl'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$$AvatarUploadResponseImplToJson(
  _$AvatarUploadResponseImpl instance,
) => <String, dynamic>{
  'avatarUrl': instance.avatarUrl,
  'message': instance.message,
};

_$ProfileCompletionStatusImpl _$$ProfileCompletionStatusImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileCompletionStatusImpl(
  completionPercentage: (json['completionPercentage'] as num).toDouble(),
  completedFields: (json['completedFields'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  missingFields: (json['missingFields'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  suggestions: (json['suggestions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$ProfileCompletionStatusImplToJson(
  _$ProfileCompletionStatusImpl instance,
) => <String, dynamic>{
  'completionPercentage': instance.completionPercentage,
  'completedFields': instance.completedFields,
  'missingFields': instance.missingFields,
  'suggestions': instance.suggestions,
};

_$PrivacySettingsImpl _$$PrivacySettingsImplFromJson(
  Map<String, dynamic> json,
) => _$PrivacySettingsImpl(
  profilePublic: json['profilePublic'] as bool? ?? false,
  showEmail: json['showEmail'] as bool? ?? false,
  showPhone: json['showPhone'] as bool? ?? false,
  showName: json['showName'] as bool? ?? true,
  showLocation: json['showLocation'] as bool? ?? false,
  allowMessaging: json['allowMessaging'] as bool? ?? true,
  allowFriendRequests: json['allowFriendRequests'] as bool? ?? true,
);

Map<String, dynamic> _$$PrivacySettingsImplToJson(
  _$PrivacySettingsImpl instance,
) => <String, dynamic>{
  'profilePublic': instance.profilePublic,
  'showEmail': instance.showEmail,
  'showPhone': instance.showPhone,
  'showName': instance.showName,
  'showLocation': instance.showLocation,
  'allowMessaging': instance.allowMessaging,
  'allowFriendRequests': instance.allowFriendRequests,
};

_$AccountSettingsImpl _$$AccountSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$AccountSettingsImpl(
  language: json['language'] as String,
  timezone: json['timezone'] as String,
  dateFormat: json['dateFormat'] as String,
  timeFormat: json['timeFormat'] as String,
  use24HourTime: json['use24HourTime'] as bool? ?? true,
  currency: json['currency'] as String? ?? 'USD',
  locale: json['locale'] as String? ?? 'en_US',
);

Map<String, dynamic> _$$AccountSettingsImplToJson(
  _$AccountSettingsImpl instance,
) => <String, dynamic>{
  'language': instance.language,
  'timezone': instance.timezone,
  'dateFormat': instance.dateFormat,
  'timeFormat': instance.timeFormat,
  'use24HourTime': instance.use24HourTime,
  'currency': instance.currency,
  'locale': instance.locale,
};

_$ProfileStatisticsImpl _$$ProfileStatisticsImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileStatisticsImpl(
  loginCount: (json['loginCount'] as num).toInt(),
  sessionCount: (json['sessionCount'] as num).toInt(),
  accountAge: json['accountAge'] as String,
  lastPasswordChange: json['lastPasswordChange'] as String,
  securityScore: (json['securityScore'] as num).toInt(),
  activityBreakdown: Map<String, int>.from(json['activityBreakdown'] as Map),
);

Map<String, dynamic> _$$ProfileStatisticsImplToJson(
  _$ProfileStatisticsImpl instance,
) => <String, dynamic>{
  'loginCount': instance.loginCount,
  'sessionCount': instance.sessionCount,
  'accountAge': instance.accountAge,
  'lastPasswordChange': instance.lastPasswordChange,
  'securityScore': instance.securityScore,
  'activityBreakdown': instance.activityBreakdown,
};
