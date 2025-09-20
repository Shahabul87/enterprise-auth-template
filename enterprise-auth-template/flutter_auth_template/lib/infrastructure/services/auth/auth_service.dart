import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/data/models/auth_response.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/infrastructure/services/api/api_client.dart';

/// Provider for AuthService with dependency injection.
///
/// This provider ensures a single instance of AuthService is created
/// and properly manages its dependencies through Riverpod.
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthService(apiClient, secureStorage);
});

/// Infrastructure service for authentication operations.
///
/// This service implements the technical details of authentication,
/// handling API communication, token management, and secure storage.
/// It serves as the concrete implementation layer in Clean Architecture,
/// bridging the gap between domain requirements and external systems.
///
/// ## Responsibilities:
/// - API communication for auth endpoints
/// - Token storage and management
/// - Response parsing and error handling
/// - Session management
///
/// ## Usage Example:
/// ```dart
/// final authService = ref.read(authServiceProvider);
/// final response = await authService.login(
///   LoginRequest(email: 'user@example.com', password: 'password')
/// );
/// ```
///
/// ## Security Considerations:
/// - All tokens are stored securely using platform-specific encryption
/// - Passwords are never stored locally
/// - Tokens are cleared on logout
/// - Failed login attempts should be rate-limited (handled server-side)
class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  /// Creates an AuthService instance.
  ///
  /// Requires:
  /// - [_apiClient]: For making HTTP requests
  /// - [_secureStorage]: For secure token storage
  AuthService(this._apiClient, this._secureStorage);

  /// Authenticates user with email and password.
  ///
  /// Makes a POST request to the login endpoint with user credentials.
  /// On success, stores authentication tokens securely.
  ///
  /// Parameters:
  /// - [request]: Contains email and password credentials
  ///
  /// Returns:
  /// - [ApiResponse<User>] with authenticated user data on success
  /// - [ApiResponse.error] with appropriate error message on failure
  ///
  /// Throws:
  /// - [NetworkException] for connectivity issues
  /// - [ServerException] for server errors (5xx)
  Future<ApiResponse<User>> login(LoginRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.loginPath, data: request.toJson()),
      (response) => _handleAuthResponse(response),
    );
  }

  /// Register new user
  Future<ApiResponse<User>> register(RegisterRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.registerPath, data: request.toJson()),
      (response) => _handleAuthResponse(response),
    );
  }

  /// Get current user profile
  Future<ApiResponse<User>> getCurrentUser() async {
    return _handleRequest(
      () => _apiClient.get(ApiConstants.userMePath),
      (response) => _parseResponse<User>(
        response,
        (data) => User.fromJson(data as Map<String, dynamic>),
      ),
    );
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> data) async {
    return _handleRequest(
      () => _apiClient.patch(ApiConstants.userMePath, data: data),
      (response) => _parseResponse<User>(
        response,
        (data) => User.fromJson(data as Map<String, dynamic>),
      ),
    );
  }

  /// Logout user and clear tokens
  Future<ApiResponse<String>> logout() async {
    try {
      // Call logout endpoint to invalidate server-side session
      await _apiClient.post(ApiConstants.logoutPath);
    } catch (e) {
      // Continue with local logout even if server call fails
    } finally {
      // Clear all stored tokens and user data
      await _secureStorage.clearAll();
    }
    return const ApiResponse.success(data: 'Logged out successfully');
  }

  /// Forgot password request
  Future<ApiResponse<String>> forgotPassword(ForgotPasswordRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.forgotPasswordPath, data: request.toJson()),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Reset password with token
  Future<ApiResponse<String>> resetPassword(ResetPasswordRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.resetPasswordPath, data: request.toJson()),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Change password
  Future<ApiResponse<String>> changePassword(ChangePasswordRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.profileChangePasswordPath, data: request.toJson()),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Verify email address
  Future<ApiResponse<String>> verifyEmail(VerifyEmailRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.verifyEmailPath, data: request.toJson()),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Resend email verification
  Future<ApiResponse<String>> resendEmailVerification(String email) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.resendVerificationPath, data: {'email': email}),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Setup Two-Factor Authentication
  Future<ApiResponse<TwoFactorSetupResponse>> setup2FA() async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.twoFactorSetupPath),
      (response) => _parseResponse<TwoFactorSetupResponse>(
        response,
        (data) => TwoFactorSetupResponse.fromJson(data as Map<String, dynamic>),
      ),
    );
  }

  /// Enable Two-Factor Authentication
  Future<ApiResponse<String>> enable2FA(String code) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.twoFactorEnablePath, data: {'code': code}),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Verify Two-Factor Authentication code
  Future<ApiResponse<User>> verify2FA(VerifyTwoFactorRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.twoFactorVerifyPath, data: request.toJson()),
      (response) => _handleAuthResponse(response),
    );
  }

  /// Disable Two-Factor Authentication
  Future<ApiResponse<String>> disable2FA(String password) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.twoFactorDisablePath, data: {'password': password}),
      (response) => _parseMessageResponse(response),
    );
  }

  /// OAuth login
  Future<ApiResponse<User>> oauthLogin(OAuthLoginRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.oauthCallbackPath.replaceAll('{provider}', request.provider), 
        data: request.toJson()),
      (response) => _handleAuthResponse(response),
    );
  }

  /// Request magic link
  Future<ApiResponse<String>> requestMagicLink(MagicLinkRequest request) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.magicLinkRequestPath, data: request.toJson()),
      (response) => _parseMessageResponse(response),
    );
  }

  /// Verify magic link
  Future<ApiResponse<User>> verifyMagicLink(String token) async {
    return _handleRequest(
      () => _apiClient.post(ApiConstants.magicLinkVerifyPath.replaceAll('{token}', token), 
        data: {'token': token}),
      (response) => _handleAuthResponse(response),
    );
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _apiClient.post(
        ApiConstants.refreshPath,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final tokenData = data['data'];
          if (tokenData != null) {
            await _secureStorage.storeAccessToken(tokenData['access_token']);
            if (tokenData['refresh_token'] != null) {
              await _secureStorage.storeRefreshToken(tokenData['refresh_token']);
            }
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null) {
        return false;
      }

      // Optionally verify token with server
      final response = await getCurrentUser();
      return response.isSuccess;
    } catch (e) {
      return false;
    }
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
    } catch (e) {
      return ApiResponse.error(
        message: 'Request failed',
        originalError: e,
      );
    }
  }

  /// Handle authentication response and store tokens
  ApiResponse<User> _handleAuthResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool? ?? false;
        
        if (success) {
          final data = responseData['data'] as Map<String, dynamic>?;
          if (data != null) {
            try {
              // Extract user and tokens
              final user = User.fromJson(data['user'] as Map<String, dynamic>);
              // Backend returns camelCase for tokens
              final accessToken = data['accessToken'] as String? ?? data['access_token'] as String?;
              final refreshToken = data['refreshToken'] as String? ?? data['refresh_token'] as String?;

              // Store tokens asynchronously
              if (accessToken != null) {
                _secureStorage.storeAccessToken(accessToken);
              }
              if (refreshToken != null) {
                _secureStorage.storeRefreshToken(refreshToken);
              }

              return ApiResponse.success(data: user);
            } catch (e) {
              return ApiResponse.error(
                message: 'Invalid response format',
                originalError: e,
              );
            }
          }
        }
        
        final error = responseData['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? 'Request failed';
        return ApiResponse.error(message: message);
      }
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Generic response parser
  ApiResponse<T> _parseResponse<T>(
    Response response,
    T Function(dynamic data) parser,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool? ?? false;
        
        if (success) {
          final data = responseData['data'];
          if (data != null) {
            try {
              final parsedData = parser(data);
              return ApiResponse.success(data: parsedData);
            } catch (e) {
              return ApiResponse.error(
                message: 'Invalid response format',
                originalError: e,
              );
            }
          }
        }
        
        final error = responseData['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? 'Request failed';
        return ApiResponse.error(message: message);
      }
    }

    return ApiResponse.error(
      message: 'Request failed with status: ${response.statusCode}',
    );
  }

  /// Parse message response
  ApiResponse<String> _parseMessageResponse(Response response) {
    return _parseResponse<String>(
      response,
      (data) => (data as Map<String, dynamic>)['message'] as String,
    );
  }
}