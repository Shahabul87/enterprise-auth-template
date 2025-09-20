// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SuccessImpl<T> _$$SuccessImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _$SuccessImpl<T>(
  data: fromJsonT(json['data']),
  message: json['message'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$SuccessImplToJson<T>(
  _$SuccessImpl<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': toJsonT(instance.data),
  if (instance.message case final value?) 'message': value,
  'runtimeType': instance.$type,
};

_$ErrorImpl<T> _$$ErrorImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _$ErrorImpl<T>(
  message: json['message'] as String,
  code: json['code'] as String?,
  originalError: json['originalError'],
  details: json['details'] as Map<String, dynamic>?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$ErrorImplToJson<T>(
  _$ErrorImpl<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'message': instance.message,
  if (instance.code case final value?) 'code': value,
  if (instance.originalError case final value?) 'originalError': value,
  if (instance.details case final value?) 'details': value,
  'runtimeType': instance.$type,
};

_$LoadingImpl<T> _$$LoadingImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _$LoadingImpl<T>($type: json['runtimeType'] as String?);

Map<String, dynamic> _$$LoadingImplToJson<T>(
  _$LoadingImpl<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{'runtimeType': instance.$type};
