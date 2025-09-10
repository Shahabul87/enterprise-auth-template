import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_request.freezed.dart';
part 'auth_request.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    required String name,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
class ForgotPasswordRequest with _$ForgotPasswordRequest {
  const factory ForgotPasswordRequest({required String email}) =
      _ForgotPasswordRequest;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
}

@freezed
class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String token,
    required String password,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}

@freezed
class OAuthLoginRequest with _$OAuthLoginRequest {
  const factory OAuthLoginRequest({
    required String provider,
    required String code,
    String? state,
  }) = _OAuthLoginRequest;

  factory OAuthLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$OAuthLoginRequestFromJson(json);
}

@freezed
class MagicLinkRequest with _$MagicLinkRequest {
  const factory MagicLinkRequest({required String email}) = _MagicLinkRequest;

  factory MagicLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$MagicLinkRequestFromJson(json);
}

@freezed
class VerifyTwoFactorRequest with _$VerifyTwoFactorRequest {
  const factory VerifyTwoFactorRequest({
    required String code,
    String? token,
    bool? isBackup,
  }) = _VerifyTwoFactorRequest;

  factory VerifyTwoFactorRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyTwoFactorRequestFromJson(json);
}

@freezed
class VerifyEmailRequest with _$VerifyEmailRequest {
  const factory VerifyEmailRequest({required String token}) = _VerifyEmailRequest;

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);
}

@freezed
class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}
