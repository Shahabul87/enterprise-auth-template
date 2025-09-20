import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_auth_template/infrastructure/services/api/api_client.dart';
import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/data/models/profile_models.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';

// Profile API Service Provider
final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileApiService(apiClient);
});

/// API service for profile backend integration
class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService(this._apiClient);

  /// Get current user profile
  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profileMePath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ProfileResponse.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get profile', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error getting profile: ${e.toString()}', null);
    }
  }

  /// Update user profile
  Future<ProfileResponse> updateProfile(ProfileUpdateRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.profileMePath,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ProfileResponse.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to update profile', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error updating profile: ${e.toString()}', null);
    }
  }

  /// Change password
  Future<String> changePassword(PasswordChangeRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.profileChangePasswordPath,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['message'] ?? 'Password changed successfully';
        }
      }

      throw const ServerException('Failed to change password', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error changing password: ${e.toString()}', null);
    }
  }

  /// Change email
  Future<String> changeEmail(EmailChangeRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.profileChangeEmailPath,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['message'] ?? 'Email change verification sent';
        }
      }

      throw const ServerException('Failed to change email', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error changing email: ${e.toString()}', null);
    }
  }

  /// Get security settings
  Future<SecuritySettingsResponse> getSecuritySettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.profileSecurityPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return SecuritySettingsResponse.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get security settings', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting security settings: ${e.toString()}',
        null,
      );
    }
  }

  /// Update notification preferences
  Future<String> updateNotificationPreferences(
    NotificationPreferencesRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.profileNotificationsPath,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['message'] ?? 'Notification preferences updated';
        }
      }

      throw const ServerException(
        'Failed to update notification preferences',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error updating notification preferences: ${e.toString()}',
        null,
      );
    }
  }

  /// Delete account
  Future<String> deleteAccount(String password) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.profileMePath,
        data: {'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['message'] ?? 'Account deleted successfully';
        }
      }

      throw const ServerException('Failed to delete account', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error deleting account: ${e.toString()}', null);
    }
  }

  /// Upload avatar
  Future<AvatarUploadResponse> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        ApiConstants.profileAvatarPath,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AvatarUploadResponse.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to upload avatar', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error uploading avatar: ${e.toString()}', null);
    }
  }

  /// Delete avatar
  Future<String> deleteAvatar() async {
    try {
      final response = await _apiClient.delete(ApiConstants.profileAvatarPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['message'] ?? 'Avatar deleted successfully';
        }
      }

      throw const ServerException('Failed to delete avatar', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('Error deleting avatar: ${e.toString()}', null);
    }
  }

  /// Get profile completion status
  Future<ProfileCompletionStatus> getProfileCompletionStatus() async {
    try {
      final response = await _apiClient.get(ApiConstants.profileCompletionPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ProfileCompletionStatus.fromJson(data['data']);
        }
      }

      throw const ServerException(
        'Failed to get profile completion status',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting profile completion status: ${e.toString()}',
        null,
      );
    }
  }

  /// Get privacy settings
  Future<PrivacySettings> getPrivacySettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.profilePrivacyPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return PrivacySettings.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get privacy settings', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting privacy settings: ${e.toString()}',
        null,
      );
    }
  }

  /// Update privacy settings
  Future<PrivacySettings> updatePrivacySettings(
    PrivacySettings settings,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.profilePrivacyPath,
        data: settings.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return PrivacySettings.fromJson(data['data']);
        }
      }

      throw const ServerException(
        'Failed to update privacy settings',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error updating privacy settings: ${e.toString()}',
        null,
      );
    }
  }

  /// Get account settings
  Future<AccountSettings> getAccountSettings() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.profileAccountSettingsPath,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AccountSettings.fromJson(data['data']);
        }
      }

      throw const ServerException('Failed to get account settings', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting account settings: ${e.toString()}',
        null,
      );
    }
  }

  /// Update account settings
  Future<AccountSettings> updateAccountSettings(
    AccountSettings settings,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.profileAccountSettingsPath,
        data: settings.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AccountSettings.fromJson(data['data']);
        }
      }

      throw const ServerException(
        'Failed to update account settings',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error updating account settings: ${e.toString()}',
        null,
      );
    }
  }

  /// Get profile statistics
  Future<ProfileStatistics> getProfileStatistics() async {
    try {
      final response = await _apiClient.get(ApiConstants.profileStatisticsPath);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ProfileStatistics.fromJson(data['data']);
        }
      }

      throw const ServerException(
        'Failed to get profile statistics',
        null,
        500,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error getting profile statistics: ${e.toString()}',
        null,
      );
    }
  }

  /// Export profile data
  Future<String> exportProfileData({String format = 'json'}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.profileExportPath,
        queryParameters: {'format': format},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['export_url'] ?? '';
        }
      }

      throw const ServerException('Failed to export profile data', null, 500);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        'Error exporting profile data: ${e.toString()}',
        null,
      );
    }
  }
}
