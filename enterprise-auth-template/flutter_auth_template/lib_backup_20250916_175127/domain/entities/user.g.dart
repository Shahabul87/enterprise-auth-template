// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  bio: json['bio'] as String?,
  profilePicture: json['profilePicture'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool,
  isTwoFactorEnabled: json['isTwoFactorEnabled'] as bool,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      if (instance.firstName case final value?) 'firstName': value,
      if (instance.lastName case final value?) 'lastName': value,
      if (instance.phoneNumber case final value?) 'phoneNumber': value,
      if (instance.bio case final value?) 'bio': value,
      if (instance.profilePicture case final value?) 'profilePicture': value,
      if (instance.profileImageUrl case final value?) 'profileImageUrl': value,
      'isEmailVerified': instance.isEmailVerified,
      'isTwoFactorEnabled': instance.isTwoFactorEnabled,
      'roles': instance.roles,
      'permissions': instance.permissions,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.lastLoginAt?.toIso8601String() case final value?)
        'lastLoginAt': value,
    };
