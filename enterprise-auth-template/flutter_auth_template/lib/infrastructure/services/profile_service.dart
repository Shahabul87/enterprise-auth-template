import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'api/api_client.dart';

// Profile Service Provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileService(apiClient);
});

/// Profile service for managing user profile operations
class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  /// Get user profile
  Future<ApiResponse<User>> getProfile() async {
    return _handleRequest(
      () => _apiClient.get(ApiConstants.userMePath),
      (response) => _parseUserResponse(response),
    );
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile(ProfileUpdateRequest request) async {
    return _handleRequest(
      () => _apiClient.patch(ApiConstants.userMePath, data: request.toJson()),
      (response) => _parseUserResponse(response),
    );
  }

  /// Upload profile avatar
  Future<ApiResponse<String>> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar.${_getFileExtension(imageFile.path)}',
        ),
      });

      final response = await _apiClient.post(
        ApiConstants.profileAvatarPath,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final avatarUrl = data['data']?['avatar_url'] as String?;
          if (avatarUrl != null) {
            return ApiResponse.success(data: avatarUrl);
          }
        }
      }

      return ApiResponse.error(
        message: 'Failed to upload avatar',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Avatar upload failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete profile avatar
  Future<ApiResponse<String>> deleteAvatar() async {
    return _handleRequest(
      () => _apiClient.delete(ApiConstants.profileAvatarPath),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Change password
  Future<ApiResponse<String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final requestData = {
      'current_password': currentPassword,
      'new_password': newPassword,
    };

    return _handleRequest(
      () => _apiClient.post(ApiConstants.profileChangePasswordPath, data: requestData),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Update email address
  Future<ApiResponse<String>> updateEmail(String newEmail) async {
    return _handleRequest(
      () => _apiClient.patch(ApiConstants.profileEmailPath, data: {'email': newEmail}),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Verify new email address
  Future<ApiResponse<String>> verifyEmailUpdate(String token) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.profileVerifyEmailPath, data: {'token': token}),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Delete user account
  Future<ApiResponse<String>> deleteAccount(String password) async {
    return _handleRequest(
      () => _apiClient.delete(ApiConstants.userMePath, data: {'password': password}),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Get user activities/audit log
  Future<ApiResponse<List<UserActivity>>> getUserActivities({
    int page = 1,
    int limit = 20,
  }) async {
    return _handleRequest(
      () => _apiClient.get(
        ApiConstants.profileActivitiesPath,
        queryParameters: {'page': page, 'limit': limit},
      ),
      (response) => _parseActivitiesResponse(response),
    );
  }

  /// Get user sessions
  Future<ApiResponse<List<UserSession>>> getUserSessions() async {
    return _handleRequest(
      () => _apiClient.get(ApiConstants.profileSessionsPath),
      (response) => _parseSessionsResponse(response),
    );
  }

  /// Revoke user session
  Future<ApiResponse<String>> revokeSession(String sessionId) async {
    return _handleRequest(
      () => _apiClient.delete(ApiConstants.profileSessionsPath.replaceAll('{id}', sessionId)),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Revoke all other sessions
  Future<ApiResponse<String>> revokeAllOtherSessions() async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.profileRevokeAllSessionsPath),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Get user's connected accounts (OAuth)
  Future<ApiResponse<List<ConnectedAccount>>> getConnectedAccounts() async {
    return _handleRequest(
      () => _apiClient.get(ApiConstants.profileConnectedAccountsPath),
      (response) => _parseConnectedAccountsResponse(response),
    );
  }

  /// Disconnect OAuth account
  Future<ApiResponse<String>> disconnectAccount(String provider) async {
    return _handleRequest(
      () => _apiClient.delete(
        ApiConstants.profileConnectedAccountsPath.replaceAll('{provider}', provider),
      ),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Get user preferences
  Future<ApiResponse<UserPreferences>> getPreferences() async {
    return _handleRequest(
      () => _apiClient.get(ApiConstants.profilePreferencesPath),
      (response) => _parsePreferencesResponse(response),
    );
  }

  /// Update user preferences
  Future<ApiResponse<UserPreferences>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    return _handleRequest(
      () => _apiClient.patch(ApiConstants.profilePreferencesPath, data: preferences),
      (response) => _parsePreferencesResponse(response),
    );
  }

  /// Export user data (GDPR compliance)
  Future<ApiResponse<String>> requestDataExport() async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.profileExportDataPath),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Get data export status
  Future<ApiResponse<DataExportStatus>> getDataExportStatus() async {
    return _handleRequest(
      () => _apiClient.get(ApiConstants.profileExportStatusPath),
      (response) => _parseExportStatusResponse(response),
    );
  }

  /// Generic request handler with error handling
  Future<ApiResponse<T>> _handleRequest<T>(
    Future<Response> Function() request,
    ApiResponse<T> Function(Response response) parser,
  ) async {
    try {
      final response = await request();
      return parser(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Request failed',
        originalError: e,
      );
    }
  }

  /// Handle Dio errors
  ApiResponse<T> _handleDioError<T>(DioException e) {
    if (e.error is AppException) {
      final appError = e.error as AppException;
      return ApiResponse.error(
        message: appError.message,
        code: appError.toString(),
        originalError: e,
      );
    }
    return ApiResponse.error(
      message: e.message ?? 'Request failed',
      originalError: e,
    );
  }

  /// Parse user response
  ApiResponse<User> _parseUserResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final userData = data['data'];
        if (userData != null) {
          try {
            final user = User.fromJson(userData as Map<String, dynamic>);
            return ApiResponse.success(data: user);
          } catch (e) {
            return ApiResponse.error(
              message: 'Invalid user data format',
              originalError: e,
            );
          }
        }
      }

      final error = data?['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Request failed';
      return ApiResponse.error(message: message);
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Parse message response
  ApiResponse<String> _parseMessageResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final message = data['data']?['message'] as String? ?? 'Operation successful';
        return ApiResponse.success(data: message);
      }

      final error = data?['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Request failed';
      return ApiResponse.error(message: message);
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Parse activities response
  ApiResponse<List<UserActivity>> _parseActivitiesResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final activitiesData = data['data'] as List?;
        if (activitiesData != null) {
          try {
            final activities = activitiesData
                .cast<Map<String, dynamic>>()
                .map((actData) => UserActivity.fromJson(actData))
                .toList();
            return ApiResponse.success(data: activities);
          } catch (e) {
            return ApiResponse.error(
              message: 'Invalid activities data format',
              originalError: e,
            );
          }
        }
      }

      final error = data?['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Request failed';
      return ApiResponse.error(message: message);
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Parse sessions response
  ApiResponse<List<UserSession>> _parseSessionsResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final sessionsData = data['data'] as List?;
        if (sessionsData != null) {
          try {
            final sessions = sessionsData
                .cast<Map<String, dynamic>>()
                .map((sessionData) => UserSession.fromJson(sessionData))
                .toList();
            return ApiResponse.success(data: sessions);
          } catch (e) {
            return ApiResponse.error(
              message: 'Invalid sessions data format',
              originalError: e,
            );
          }
        }
      }

      final error = data?['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Request failed';
      return ApiResponse.error(message: message);
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Parse connected accounts response
  ApiResponse<List<ConnectedAccount>> _parseConnectedAccountsResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final accountsData = data['data'] as List?;
        if (accountsData != null) {
          try {
            final accounts = accountsData
                .cast<Map<String, dynamic>>()
                .map((accountData) => ConnectedAccount.fromJson(accountData))
                .toList();
            return ApiResponse.success(data: accounts);
          } catch (e) {
            return ApiResponse.error(
              message: 'Invalid connected accounts data format',
              originalError: e,
            );
          }
        }
      }

      final error = data?['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Request failed';
      return ApiResponse.error(message: message);
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Parse preferences response
  ApiResponse<UserPreferences> _parsePreferencesResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final preferencesData = data['data'];
        if (preferencesData != null) {
          try {
            final preferences = UserPreferences.fromJson(preferencesData as Map<String, dynamic>);
            return ApiResponse.success(data: preferences);
          } catch (e) {
            return ApiResponse.error(
              message: 'Invalid preferences data format',
              originalError: e,
            );
          }
        }
      }

      final error = data?['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Request failed';
      return ApiResponse.error(message: message);
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Parse export status response
  ApiResponse<DataExportStatus> _parseExportStatusResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final statusData = data['data'];
        if (statusData != null) {
          try {
            final status = DataExportStatus.fromJson(statusData as Map<String, dynamic>);
            return ApiResponse.success(data: status);
          } catch (e) {
            return ApiResponse.error(
              message: 'Invalid export status data format',
              originalError: e,
            );
          }
        }
      }

      final error = data?['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Request failed';
      return ApiResponse.error(message: message);
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Get file extension from path
  String _getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }
}

/// Profile update request
class ProfileUpdateRequest {
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? bio;
  final String? location;
  final String? website;
  final String? timezone;
  final String? language;

  ProfileUpdateRequest({
    this.name,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.bio,
    this.location,
    this.website,
    this.timezone,
    this.language,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;
    if (bio != null) data['bio'] = bio;
    if (location != null) data['location'] = location;
    if (website != null) data['website'] = website;
    if (timezone != null) data['timezone'] = timezone;
    if (language != null) data['language'] = language;
    return data;
  }
}

/// User activity
class UserActivity {
  final String id;
  final String action;
  final String description;
  final String timestamp;
  final String? ipAddress;
  final String? userAgent;
  final String? location;

  UserActivity({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.location,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      timestamp: json['timestamp'] as String,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      location: json['location'] as String?,
    );
  }
}

/// User session
class UserSession {
  final String id;
  final String deviceInfo;
  final String ipAddress;
  final String location;
  final String createdAt;
  final String lastActivity;
  final bool isCurrent;

  UserSession({
    required this.id,
    required this.deviceInfo,
    required this.ipAddress,
    required this.location,
    required this.createdAt,
    required this.lastActivity,
    required this.isCurrent,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as String,
      deviceInfo: json['device_info'] as String,
      ipAddress: json['ip_address'] as String,
      location: json['location'] as String,
      createdAt: json['created_at'] as String,
      lastActivity: json['last_activity'] as String,
      isCurrent: json['is_current'] as bool,
    );
  }
}

/// Connected account
class ConnectedAccount {
  final String provider;
  final String providerUserId;
  final String? email;
  final String? name;
  final String connectedAt;

  ConnectedAccount({
    required this.provider,
    required this.providerUserId,
    this.email,
    this.name,
    required this.connectedAt,
  });

  factory ConnectedAccount.fromJson(Map<String, dynamic> json) {
    return ConnectedAccount(
      provider: json['provider'] as String,
      providerUserId: json['provider_user_id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      connectedAt: json['connected_at'] as String,
    );
  }
}

/// User preferences
class UserPreferences {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool marketingEmails;
  final String theme;
  final String language;
  final String timezone;
  final bool twoFactorEnabled;

  UserPreferences({
    required this.emailNotifications,
    required this.pushNotifications,
    required this.smsNotifications,
    required this.marketingEmails,
    required this.theme,
    required this.language,
    required this.timezone,
    required this.twoFactorEnabled,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      emailNotifications: json['email_notifications'] as bool,
      pushNotifications: json['push_notifications'] as bool,
      smsNotifications: json['sms_notifications'] as bool,
      marketingEmails: json['marketing_emails'] as bool,
      theme: json['theme'] as String,
      language: json['language'] as String,
      timezone: json['timezone'] as String,
      twoFactorEnabled: json['two_factor_enabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'marketing_emails': marketingEmails,
      'theme': theme,
      'language': language,
      'timezone': timezone,
      'two_factor_enabled': twoFactorEnabled,
    };
  }
}

/// Data export status
class DataExportStatus {
  final String status;
  final String? downloadUrl;
  final String? requestedAt;
  final String? completedAt;
  final String? expiresAt;

  DataExportStatus({
    required this.status,
    this.downloadUrl,
    this.requestedAt,
    this.completedAt,
    this.expiresAt,
  });

  factory DataExportStatus.fromJson(Map<String, dynamic> json) {
    return DataExportStatus(
      status: json['status'] as String,
      downloadUrl: json['download_url'] as String?,
      requestedAt: json['requested_at'] as String?,
      completedAt: json['completed_at'] as String?,
      expiresAt: json['expires_at'] as String?,
    );
  }
}