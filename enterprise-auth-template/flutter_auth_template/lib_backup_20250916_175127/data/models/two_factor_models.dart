import 'package:freezed_annotation/freezed_annotation.dart';

part 'two_factor_models.freezed.dart';
part 'two_factor_models.g.dart';

/// Two-factor authentication setup response
@freezed
class TwoFactorSetupResponse with _$TwoFactorSetupResponse {
  const factory TwoFactorSetupResponse({
    required String secret,
    required String qrCode,
    required List<String> backupCodes,
    @Default('') String setupKey,
  }) = _TwoFactorSetupResponse;

  factory TwoFactorSetupResponse.fromJson(Map<String, dynamic> json) =>
      _$TwoFactorSetupResponseFromJson(json);
}

/// Two-factor authentication status
@freezed
class TwoFactorStatus with _$TwoFactorStatus {
  const factory TwoFactorStatus({
    @Default(false) bool enabled,
    @Default(false) bool hasBackupCodes,
    @Default(0) int backupCodesUsed,
    @Default(0) int backupCodesRemaining,
    DateTime? lastUsed,
    String? method, // 'totp', 'sms', etc.
  }) = _TwoFactorStatus;

  factory TwoFactorStatus.fromJson(Map<String, dynamic> json) =>
      _$TwoFactorStatusFromJson(json);
}

/// Two-factor verification request
@freezed
class TwoFactorVerifyRequest with _$TwoFactorVerifyRequest {
  const factory TwoFactorVerifyRequest({
    required String code,
    @Default(false) bool isBackupCode,
    String? method,
  }) = _TwoFactorVerifyRequest;

  factory TwoFactorVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$TwoFactorVerifyRequestFromJson(json);
}

/// Two-factor enable request
@freezed
class TwoFactorEnableRequest with _$TwoFactorEnableRequest {
  const factory TwoFactorEnableRequest({
    required String code,
    String? password, // May require password confirmation
  }) = _TwoFactorEnableRequest;

  factory TwoFactorEnableRequest.fromJson(Map<String, dynamic> json) =>
      _$TwoFactorEnableRequestFromJson(json);
}

/// Backup codes response
@freezed
class BackupCodesResponse with _$BackupCodesResponse {
  const factory BackupCodesResponse({
    required List<String> codes,
    @Default('') String message,
  }) = _BackupCodesResponse;

  factory BackupCodesResponse.fromJson(Map<String, dynamic> json) =>
      _$BackupCodesResponseFromJson(json);
}

/// Two-factor authentication method
enum TwoFactorMethod {
  totp,
  sms,
  backup;

  String get displayName {
    switch (this) {
      case TwoFactorMethod.totp:
        return 'Authenticator App';
      case TwoFactorMethod.sms:
        return 'SMS';
      case TwoFactorMethod.backup:
        return 'Backup Code';
    }
  }

  String get description {
    switch (this) {
      case TwoFactorMethod.totp:
        return 'Use an authenticator app like Google Authenticator or Authy';
      case TwoFactorMethod.sms:
        return 'Receive codes via text message';
      case TwoFactorMethod.backup:
        return 'Use a backup code provided during setup';
    }
  }
}
