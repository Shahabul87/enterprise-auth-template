import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/core/constants/api_constants.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/auth_service.dart';

// Session Service Provider
final sessionServiceProvider = Provider<SessionService>((ref) {
  final authService = ref.watch(authServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return SessionService(authService, secureStorage);
});

/// Session service for managing user sessions and authentication state
class SessionService {
  final AuthService _authService;
  final SecureStorageService _secureStorage;

  // Session state streams
  final StreamController<SessionState> _sessionStateController =
      StreamController<SessionState>.broadcast();

  // Token refresh timer
  Timer? _tokenRefreshTimer;

  // Session check timer
  Timer? _sessionCheckTimer;

  // Current session state
  SessionState _currentState = const SessionState.unauthenticated();

  SessionService(this._authService, this._secureStorage) {
    _initializeSession();
  }

  /// Session state stream
  Stream<SessionState> get sessionState => _sessionStateController.stream;

  /// Current session state
  SessionState get currentState => _currentState;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _currentState.isAuthenticated;

  /// Get current user if authenticated
  User? get currentUser => _currentState.user;

  /// Initialize session on app start
  Future<void> _initializeSession() async {
    try {
      _updateState(const SessionState.initializing());

      final hasValidTokens = await _hasValidTokens();
      if (!hasValidTokens) {
        _updateState(const SessionState.unauthenticated());
        return;
      }

      // Try to get current user
      final userResponse = await _authService.getCurrentUser();
      if (userResponse.isSuccess) {
        final user = userResponse.dataOrNull!;
        _updateState(SessionState.authenticated(user: user));
        _startTokenRefreshTimer();
        _startSessionCheckTimer();
      } else {
        // Token might be expired, try to refresh
        final refreshSuccess = await _authService.refreshToken();
        if (refreshSuccess) {
          // Try again after refresh
          final refreshedUserResponse = await _authService.getCurrentUser();
          if (refreshedUserResponse.isSuccess) {
            final user = refreshedUserResponse.dataOrNull!;
            _updateState(SessionState.authenticated(user: user));
            _startTokenRefreshTimer();
            _startSessionCheckTimer();
          } else {
            await logout();
          }
        } else {
          await logout();
        }
      }
    } catch (e) {
      debugPrint('Session initialization error: $e');
      _updateState(const SessionState.unauthenticated());
    }
  }

  /// Login with credentials
  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      _updateState(const SessionState.authenticating());

      final loginRequest = LoginRequest(email: email, password: password);
      final response = await _authService.login(loginRequest);

      if (response.isSuccess) {
        final user = response.dataOrNull!;
        _updateState(SessionState.authenticated(user: user));
        _startTokenRefreshTimer();
        _startSessionCheckTimer();
      } else {
        _updateState(SessionState.error(message: response.errorMessage ?? ""));
      }

      return response;
    } catch (e) {
      final errorMessage = 'Login failed: ${e.toString()}';
      _updateState(SessionState.error(message: errorMessage));
      return ApiResponse.error(message: errorMessage, originalError: e);
    }
  }

  /// Register new user
  Future<ApiResponse<User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _updateState(const SessionState.authenticating());

      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        fullName: name,
        confirmPassword: password,
        agreeToTerms: true,
      );
      final response = await _authService.register(registerRequest);

      final user = response.user;
      _updateState(SessionState.authenticated(user: user));
      _startTokenRefreshTimer();
      _startSessionCheckTimer();

      return ApiResponse.success(data: user);
    } catch (e) {
      final errorMessage = 'Registration failed: ${e.toString()}';
      _updateState(SessionState.error(message: errorMessage));
      return ApiResponse.error(message: errorMessage, originalError: e);
    }
  }

  /// OAuth login
  Future<ApiResponse<User>> oauthLogin(OAuthLoginRequest request) async {
    try {
      _updateState(const SessionState.authenticating());

      final response = await _authService.oauthLogin(request);

      if (response.isSuccess) {
        final user = response.dataOrNull!;
        _updateState(SessionState.authenticated(user: user));
        _startTokenRefreshTimer();
        _startSessionCheckTimer();
      } else {
        _updateState(SessionState.error(message: response.errorMessage ?? ""));
      }

      return response;
    } catch (e) {
      final errorMessage = 'OAuth login failed: ${e.toString()}';
      _updateState(SessionState.error(message: errorMessage));
      return ApiResponse.error(message: errorMessage, originalError: e);
    }
  }

  /// Two-factor authentication verification
  Future<ApiResponse<User>> verify2FA(String code) async {
    try {
      _updateState(const SessionState.authenticating());

      final request = VerifyTwoFactorRequest(code: code);
      final response = await _authService.verify2FA(request);

      if (response.isSuccess) {
        final user = response.dataOrNull!;
        _updateState(SessionState.authenticated(user: user));
        _startTokenRefreshTimer();
        _startSessionCheckTimer();
      } else {
        _updateState(SessionState.error(message: response.errorMessage ?? ""));
      }

      return response;
    } catch (e) {
      final errorMessage = '2FA verification failed: ${e.toString()}';
      _updateState(SessionState.error(message: errorMessage));
      return ApiResponse.error(message: errorMessage, originalError: e);
    }
  }

  /// Magic link verification
  Future<ApiResponse<User>> verifyMagicLink(String token) async {
    try {
      _updateState(const SessionState.authenticating());

      final response = await _authService.verifyMagicLink(token);

      if (response.isSuccess) {
        final user = response.dataOrNull!;
        _updateState(SessionState.authenticated(user: user));
        _startTokenRefreshTimer();
        _startSessionCheckTimer();
      } else {
        _updateState(SessionState.error(message: response.errorMessage ?? ""));
      }

      return response;
    } catch (e) {
      final errorMessage = 'Magic link verification failed: ${e.toString()}';
      _updateState(SessionState.error(message: errorMessage));
      return ApiResponse.error(message: errorMessage, originalError: e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _updateState(const SessionState.loggingOut());

      // Call logout service
      await _authService.logout();

      // Clear timers
      _stopTokenRefreshTimer();
      _stopSessionCheckTimer();

      // Update state
      _updateState(const SessionState.unauthenticated());
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if logout fails, clear local state
      _stopTokenRefreshTimer();
      _stopSessionCheckTimer();
      _updateState(const SessionState.unauthenticated());
    }
  }

  /// Update user in session
  void updateUser(User user) {
    if (_currentState.isAuthenticated) {
      _updateState(SessionState.authenticated(user: user));
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      return await _authService.refreshToken();
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  /// Check session validity
  Future<bool> checkSessionValidity() async {
    try {
      final response = await _authService.getCurrentUser();
      if (response.isSuccess) {
        final user = response.dataOrNull!;
        updateUser(user);
        return true;
      } else {
        // Try to refresh token
        final refreshSuccess = await refreshToken();
        if (refreshSuccess) {
          final refreshedResponse = await _authService.getCurrentUser();
          if (refreshedResponse.isSuccess) {
            final user = refreshedResponse.dataOrNull!;
            updateUser(user);
            return true;
          }
        }

        // Session is invalid, logout
        await logout();
        return false;
      }
    } catch (e) {
      debugPrint('Session validity check error: $e');
      return false;
    }
  }

  /// Start token refresh timer
  void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer();

    // Refresh token every 45 minutes (tokens expire in 60 minutes)
    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 45),
      (timer) async {
        final success = await refreshToken();
        if (!success) {
          debugPrint('Token refresh failed, logging out');
          await logout();
        }
      },
    );
  }

  /// Stop token refresh timer
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  /// Start session check timer
  void _startSessionCheckTimer() {
    _stopSessionCheckTimer();

    // Check session validity every 30 minutes
    _sessionCheckTimer = Timer.periodic(
      const Duration(minutes: 30),
      (timer) async {
        await checkSessionValidity();
      },
    );
  }

  /// Stop session check timer
  void _stopSessionCheckTimer() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }

  /// Check if valid tokens exist
  Future<bool> _hasValidTokens() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      return accessToken != null && refreshToken != null;
    } catch (e) {
      debugPrint('Token check error: $e');
      return false;
    }
  }

  /// Update session state
  void _updateState(SessionState newState) {
    _currentState = newState;
    _sessionStateController.add(newState);
  }

  /// Dispose resources
  void dispose() {
    _stopTokenRefreshTimer();
    _stopSessionCheckTimer();
    _sessionStateController.close();
  }
}

/// Session state
class SessionState {
  final SessionStatus status;
  final User? user;
  final String? message;

  const SessionState._({
    required this.status,
    this.user,
    this.message,
  });

  const SessionState.initializing()
      : this._(status: SessionStatus.initializing);

  const SessionState.unauthenticated()
      : this._(status: SessionStatus.unauthenticated);

  const SessionState.authenticating()
      : this._(status: SessionStatus.authenticating);

  const SessionState.authenticated({required User user})
      : this._(status: SessionStatus.authenticated, user: user);

  const SessionState.loggingOut()
      : this._(status: SessionStatus.loggingOut);

  const SessionState.error({required String message})
      : this._(status: SessionStatus.error, message: message);

  bool get isInitializing => status == SessionStatus.initializing;
  bool get isUnauthenticated => status == SessionStatus.unauthenticated;
  bool get isAuthenticating => status == SessionStatus.authenticating;
  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isLoggingOut => status == SessionStatus.loggingOut;
  bool get hasError => status == SessionStatus.error;

  bool get isLoading => isInitializing || isAuthenticating || isLoggingOut;

  @override
  String toString() {
    return 'SessionState(status: $status, user: ${user?.email}, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionState &&
        other.status == status &&
        other.user == user &&
        other.message == message;
  }

  @override
  int get hashCode {
    return status.hashCode ^ user.hashCode ^ message.hashCode;
  }
}

/// Session status enum
enum SessionStatus {
  initializing,
  unauthenticated,
  authenticating,
  authenticated,
  loggingOut,
  error,
}

/// Login request (re-export for convenience)

/// Register request (re-export for convenience)


