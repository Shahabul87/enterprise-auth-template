// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceImpl _$$DeviceImplFromJson(Map<String, dynamic> json) => _$DeviceImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  deviceName: json['deviceName'] as String,
  deviceType: json['deviceType'] as String,
  platform: json['platform'] as String,
  userAgent: json['userAgent'] as String,
  ipAddress: json['ipAddress'] as String,
  location: json['location'] as String?,
  browser: json['browser'] as String?,
  browserVersion: json['browserVersion'] as String?,
  os: json['os'] as String?,
  osVersion: json['osVersion'] as String?,
  isActive: json['isActive'] as bool,
  isTrusted: json['isTrusted'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
  deviceFingerprint: json['deviceFingerprint'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$DeviceImplToJson(
  _$DeviceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'deviceName': instance.deviceName,
  'deviceType': instance.deviceType,
  'platform': instance.platform,
  'userAgent': instance.userAgent,
  'ipAddress': instance.ipAddress,
  if (instance.location case final value?) 'location': value,
  if (instance.browser case final value?) 'browser': value,
  if (instance.browserVersion case final value?) 'browserVersion': value,
  if (instance.os case final value?) 'os': value,
  if (instance.osVersion case final value?) 'osVersion': value,
  'isActive': instance.isActive,
  'isTrusted': instance.isTrusted,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  if (instance.lastSeenAt?.toIso8601String() case final value?)
    'lastSeenAt': value,
  if (instance.deviceFingerprint case final value?) 'deviceFingerprint': value,
  if (instance.metadata case final value?) 'metadata': value,
};

_$DeviceRegistrationRequestImpl _$$DeviceRegistrationRequestImplFromJson(
  Map<String, dynamic> json,
) => _$DeviceRegistrationRequestImpl(
  deviceName: json['deviceName'] as String,
  deviceType: json['deviceType'] as String,
  platform: json['platform'] as String,
  userAgent: json['userAgent'] as String,
  deviceFingerprint: json['deviceFingerprint'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$DeviceRegistrationRequestImplToJson(
  _$DeviceRegistrationRequestImpl instance,
) => <String, dynamic>{
  'deviceName': instance.deviceName,
  'deviceType': instance.deviceType,
  'platform': instance.platform,
  'userAgent': instance.userAgent,
  if (instance.deviceFingerprint case final value?) 'deviceFingerprint': value,
  if (instance.metadata case final value?) 'metadata': value,
};

_$DeviceUpdateRequestImpl _$$DeviceUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$DeviceUpdateRequestImpl(
  deviceName: json['deviceName'] as String?,
  isTrusted: json['isTrusted'] as bool?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$DeviceUpdateRequestImplToJson(
  _$DeviceUpdateRequestImpl instance,
) => <String, dynamic>{
  if (instance.deviceName case final value?) 'deviceName': value,
  if (instance.isTrusted case final value?) 'isTrusted': value,
  if (instance.metadata case final value?) 'metadata': value,
};

_$DeviceListResponseImpl _$$DeviceListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DeviceListResponseImpl(
  devices: (json['devices'] as List<dynamic>)
      .map((e) => Device.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  hasNext: json['hasNext'] as bool,
  hasPrevious: json['hasPrevious'] as bool,
);

Map<String, dynamic> _$$DeviceListResponseImplToJson(
  _$DeviceListResponseImpl instance,
) => <String, dynamic>{
  'devices': instance.devices.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'hasNext': instance.hasNext,
  'hasPrevious': instance.hasPrevious,
};

_$DeviceStatsImpl _$$DeviceStatsImplFromJson(Map<String, dynamic> json) =>
    _$DeviceStatsImpl(
      totalDevices: (json['totalDevices'] as num).toInt(),
      activeDevices: (json['activeDevices'] as num).toInt(),
      trustedDevices: (json['trustedDevices'] as num).toInt(),
      unknownDevices: (json['unknownDevices'] as num).toInt(),
      devicesByPlatform: Map<String, int>.from(
        json['devicesByPlatform'] as Map,
      ),
      devicesByType: Map<String, int>.from(json['devicesByType'] as Map),
      topLocations: (json['topLocations'] as List<dynamic>)
          .map((e) => DeviceLocationStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DeviceStatsImplToJson(_$DeviceStatsImpl instance) =>
    <String, dynamic>{
      'totalDevices': instance.totalDevices,
      'activeDevices': instance.activeDevices,
      'trustedDevices': instance.trustedDevices,
      'unknownDevices': instance.unknownDevices,
      'devicesByPlatform': instance.devicesByPlatform,
      'devicesByType': instance.devicesByType,
      'topLocations': instance.topLocations.map((e) => e.toJson()).toList(),
    };

_$DeviceLocationStatImpl _$$DeviceLocationStatImplFromJson(
  Map<String, dynamic> json,
) => _$DeviceLocationStatImpl(
  location: json['location'] as String,
  count: (json['count'] as num).toInt(),
  percentage: (json['percentage'] as num).toDouble(),
);

Map<String, dynamic> _$$DeviceLocationStatImplToJson(
  _$DeviceLocationStatImpl instance,
) => <String, dynamic>{
  'location': instance.location,
  'count': instance.count,
  'percentage': instance.percentage,
};

_$DeviceSecurityAlertImpl _$$DeviceSecurityAlertImplFromJson(
  Map<String, dynamic> json,
) => _$DeviceSecurityAlertImpl(
  id: json['id'] as String,
  deviceId: json['deviceId'] as String,
  alertType: json['alertType'] as String,
  severity: json['severity'] as String,
  message: json['message'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isResolved: json['isResolved'] as bool,
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$DeviceSecurityAlertImplToJson(
  _$DeviceSecurityAlertImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'deviceId': instance.deviceId,
  'alertType': instance.alertType,
  'severity': instance.severity,
  'message': instance.message,
  'createdAt': instance.createdAt.toIso8601String(),
  'isResolved': instance.isResolved,
  if (instance.resolvedAt?.toIso8601String() case final value?)
    'resolvedAt': value,
  if (instance.metadata case final value?) 'metadata': value,
};
