import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/infrastructure/services/api/api_client.dart';
import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/data/models/two_factor_models.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';

// Two Factor API Service Provider
final twoFactorApiServiceProvider = Provider<TwoFactorApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TwoFactorApiService(apiClient);
});

/// API service for two-factor authentication backend integration
class TwoFactorApiService {
  final ApiClient _apiClient;

  TwoFactorApiService(this._apiClient);

  /// Get current two-factor authentication status
  Future<TwoFactorStatus> getStatus() async {
    try {
      final response = await _apiClient.get(ApiConstants.twoFactorStatusPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return TwoFactorStatus.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get 2FA status', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error getting 2FA status: ${e.toString()}', null);
    }
  }

  /// Begin two-factor authentication setup
  Future<TwoFactorSetupResponse> setupTwoFactor() async {
    try {
      final response = await _apiClient.post(ApiConstants.twoFactorSetupPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return TwoFactorSetupResponse.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to setup 2FA', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error setting up 2FA: ${e.toString()}', null);
    }
  }

  /// Enable two-factor authentication
  Future<List<String>> enableTwoFactor(TwoFactorEnableRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.twoFactorEnablePath,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final backupCodes = data['data']['backup_codes'] as List;
          return backupCodes.cast<String>();
        }
      }

      throw const ServerException('Failed to enable 2FA', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error enabling 2FA: ${e.toString()}', null);
    }
  }

  /// Verify two-factor authentication code
  Future<void> verifyTwoFactor(TwoFactorVerifyRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.twoFactorVerifyPath,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return;
        }
      }

      throw const ValidationException(
        'Invalid verification code',
        null,
        'INVALID_2FA_CODE',
        null,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error verifying 2FA: ${e.toString()}', null);
    }
  }

  /// Disable two-factor authentication
  Future<void> disableTwoFactor() async {
    try {
      final response = await _apiClient.post(ApiConstants.twoFactorDisablePath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return;
        }
      }

      throw const ServerException('Failed to disable 2FA', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error disabling 2FA: ${e.toString()}', null);
    }
  }

  /// Regenerate backup codes
  Future<List<String>> regenerateBackupCodes() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.twoFactorBackupCodesPath,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final backupCodes = data['data']['backup_codes'] as List;
          return backupCodes.cast<String>();
        }
      }

      throw const ServerException(
        'Failed to regenerate backup codes',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error regenerating backup codes: ${e.toString()}',
        null,
      );
    }
  }
}
