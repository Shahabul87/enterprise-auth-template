import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required bool success,
    String? message,
    AuthResponseData? data,
    AuthResponseError? error,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class AuthResponseData with _$AuthResponseData {
  const factory AuthResponseData({
    required User user,
    required String accessToken,
    String? refreshToken,
  }) = _AuthResponseData;

  factory AuthResponseData.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDataFromJson(json);
}

@freezed
class AuthResponseError with _$AuthResponseError {
  const factory AuthResponseError({
    required String code,
    required String message,
    Map<String, dynamic>? details,
  }) = _AuthResponseError;

  factory AuthResponseError.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseErrorFromJson(json);
}

@freezed
class TwoFactorSetupResponse with _$TwoFactorSetupResponse {
  const TwoFactorSetupResponse._();

  const factory TwoFactorSetupResponse({
    required String secret,
    required String qrCode,
    required List<String> backupCodes,
  }) = _TwoFactorSetupResponse;

  factory TwoFactorSetupResponse.fromJson(Map<String, dynamic> json) =>
      _$TwoFactorSetupResponseFromJson(json);
}

@freezed
class WebAuthnRegistrationResponse with _$WebAuthnRegistrationResponse {
  const WebAuthnRegistrationResponse._();

  const factory WebAuthnRegistrationResponse({
    required String challenge,
    required Map<String, dynamic> publicKeyCredentialCreationOptions,
  }) = _WebAuthnRegistrationResponse;

  factory WebAuthnRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$WebAuthnRegistrationResponseFromJson(json);
}

@freezed
class WebAuthnAuthenticationResponse with _$WebAuthnAuthenticationResponse {
  const WebAuthnAuthenticationResponse._();

  const factory WebAuthnAuthenticationResponse({
    required String challenge,
    required Map<String, dynamic> publicKeyCredentialRequestOptions,
  }) = _WebAuthnAuthenticationResponse;

  factory WebAuthnAuthenticationResponse.fromJson(Map<String, dynamic> json) =>
      _$WebAuthnAuthenticationResponseFromJson(json);
}
