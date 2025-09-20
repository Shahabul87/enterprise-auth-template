// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      address: json['address'] as String?,
      timezone: json['timezone'] as String?,
      locale: json['locale'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferences: json['preferences'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      if (instance.firstName case final value?) 'firstName': value,
      if (instance.lastName case final value?) 'lastName': value,
      if (instance.fullName case final value?) 'fullName': value,
      if (instance.phoneNumber case final value?) 'phoneNumber': value,
      if (instance.bio case final value?) 'bio': value,
      if (instance.profileImageUrl case final value?) 'profileImageUrl': value,
      if (instance.dateOfBirth?.toIso8601String() case final value?)
        'dateOfBirth': value,
      if (instance.address case final value?) 'address': value,
      if (instance.timezone case final value?) 'timezone': value,
      if (instance.locale case final value?) 'locale': value,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'isEmailVerified': instance.isEmailVerified,
      'isTwoFactorEnabled': instance.isTwoFactorEnabled,
      if (instance.roles case final value?) 'roles': value,
      if (instance.preferences case final value?) 'preferences': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

_$UserProfileUpdateImpl _$$UserProfileUpdateImplFromJson(
  Map<String, dynamic> json,
) => _$UserProfileUpdateImpl(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  bio: json['bio'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  address: json['address'] as String?,
  timezone: json['timezone'] as String?,
  locale: json['locale'] as String?,
  preferences: json['preferences'] as Map<String, dynamic>?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$UserProfileUpdateImplToJson(
  _$UserProfileUpdateImpl instance,
) => <String, dynamic>{
  if (instance.firstName case final value?) 'firstName': value,
  if (instance.lastName case final value?) 'lastName': value,
  if (instance.phoneNumber case final value?) 'phoneNumber': value,
  if (instance.bio case final value?) 'bio': value,
  if (instance.profileImageUrl case final value?) 'profileImageUrl': value,
  if (instance.dateOfBirth?.toIso8601String() case final value?)
    'dateOfBirth': value,
  if (instance.address case final value?) 'address': value,
  if (instance.timezone case final value?) 'timezone': value,
  if (instance.locale case final value?) 'locale': value,
  if (instance.preferences case final value?) 'preferences': value,
  if (instance.metadata case final value?) 'metadata': value,
};
