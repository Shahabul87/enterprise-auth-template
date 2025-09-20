import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/domain/entities/auth_state.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/data/models/auth_response.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/auth_service.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/core/security/account_lockout_service.dart';
import 'package:flutter_auth_template/core/security/device_fingerprint_service.dart';
import 'package:flutter_auth_template/core/security/rate_limiter.dart';

// Authentication state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final oauthService = ref.watch(oauthServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final accountLockout = ref.watch(accountLockoutServiceProvider);
  final deviceFingerprint = ref.watch(deviceFingerprintServiceProvider);
  final rateLimiter = ref.watch(rateLimiterProvider);
  return AuthNotifier(authService, oauthService, secureStorage, accountLockout, deviceFingerprint, rateLimiter);
});

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final OAuthService _oauthService;
  final SecureStorageService _secureStorage;
  final AccountLockoutService _accountLockout;
  final DeviceFingerprintService _deviceFingerprint;
  final RateLimiter _rateLimiter;

  AuthNotifier(
    this._authService,
    this._oauthService,
    this._secureStorage,
    this._accountLockout,
    this._deviceFingerprint,
    this._rateLimiter,
  ) : super(const AuthState.unauthenticated()) {
    _initializeAuth();
  }

  /// Initialize authentication state on app start
  Future<void> _initializeAuth() async {
    state = const AuthState.authenticating();
    
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        final response = await _authService.getCurrentUser();
        
        response.when(
          success: (user, _) {
            state = AuthState.authenticated(
              user: user,
              accessToken: '', // Token is managed internally
            );
          },
          error: (message, code, _, __) {
            state = const AuthState.unauthenticated();
          },
          loading: () {
            state = const AuthState.authenticating();
          },
        );
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AuthState.authenticating();

    // Check rate limit
    final rateLimitResult = await _rateLimiter.checkLimit(
      endpoint: '/api/auth/login',
      clientId: email,
      metadata: {'ip': 'client-ip'}, // In production, get actual IP
    );

    if (!rateLimitResult.allowed) {
      state = AuthState.error(
        rateLimitResult.reason ?? 'Too many attempts. Please try again later.',
      );
      return;
    }

    // Check if account is locked
    if (await _accountLockout.isAccountLocked()) {
      final minutes = await _accountLockout.getRemainingLockoutMinutes();
      state = AuthState.error(
        'Account is locked. Please try again in $minutes minutes.',
      );
      return;
    }

    final request = LoginRequest(email: email, password: password);
    final response = await _authService.login(request);

    await response.when(
      success: (user, message) async {
        // Clear failed attempts and rate limit on successful login
        await _accountLockout.clearFailedAttempts(email);
        _rateLimiter.recordSuccess(
          endpoint: '/api/auth/login',
          clientId: email,
        );

        // Generate and verify device fingerprint
        try {
          final fingerprint = await _deviceFingerprint.generateFingerprint();

          // Check if this device is trusted
          final isTrusted = await _deviceFingerprint.isDeviceTrusted(user.id);

          if (!isTrusted) {
            // For new devices, you might want to send verification email
            // or require additional authentication
            // For now, we'll automatically trust the device
            await _deviceFingerprint.trustDevice(
              userId: user.id,
              customName: '${fingerprint.deviceModel} - ${fingerprint.platform}',
            );
          } else {
            // Record that the device was verified
            await _deviceFingerprint.recordDeviceVerification();
          }
        } catch (e) {
          // Don't fail login if device fingerprinting fails
          // Just log the error
          print('Device fingerprinting error: $e');
        }

        // Update state to authenticated
        state = AuthState.authenticated(
          user: user,
          accessToken: '', // Token is managed internally
        );
        // Force a small delay to ensure state is propagated
        await Future.delayed(const Duration(milliseconds: 100));
      },
      error: (message, code, _, __) async {
        // Record failed attempt
        final lockoutStatus = await _accountLockout.recordFailedAttempt(email);

        // Use lockout message if account is locked, otherwise use original error
        final errorMessage = lockoutStatus.isLocked
            ? lockoutStatus.message
            : message;

        state = AuthState.error(errorMessage);
        // Don't throw here - let the UI handle the error state
      },
      loading: () async {
        state = const AuthState.authenticating();
      },
    );
  }

  /// Register new user
  Future<void> register(String email, String password, String name) async {
    state = const AuthState.authenticating();

    // Check rate limit for registration
    final rateLimitResult = await _rateLimiter.checkLimit(
      endpoint: '/api/auth/register',
      clientId: email,
      metadata: {'ip': 'client-ip'}, // In production, get actual IP
    );

    if (!rateLimitResult.allowed) {
      state = AuthState.error(
        rateLimitResult.reason ?? 'Too many registration attempts. Please try again later.',
      );
      throw Exception(rateLimitResult.reason ?? 'Rate limit exceeded');
    }

    final request = RegisterRequest(
      email: email,
      password: password,
      fullName: name,
      confirmPassword: password,
      agreeToTerms: true,
    );
    final response = await _authService.register(request);
    
    response.when(
      success: (user, message) {
        state = AuthState.authenticated(
          user: user,
          accessToken: '', // Token is managed internally
        );
      },
      error: (message, code, _, __) {
        state = AuthState.error(message);
        throw Exception(message);
      },
      loading: () {
        state = const AuthState.authenticating();
      },
    );
  }

  /// Base logout method (will be overridden)
  Future<void> _baseLogout() async {
    state = const AuthState.authenticating();

    final response = await _authService.logout();
    state = const AuthState.unauthenticated();
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    // Check rate limit for forgot password
    final rateLimitResult = await _rateLimiter.checkLimit(
      endpoint: '/api/auth/forgot-password',
      clientId: email,
      metadata: {'ip': 'client-ip'}, // In production, get actual IP
    );

    if (!rateLimitResult.allowed) {
      throw Exception(rateLimitResult.reason ?? 'Too many password reset attempts. Please try again later.');
    }

    final request = ForgotPasswordRequest(email: email);
    final response = await _authService.forgotPassword(request);
    
    response.when(
      success: (message, _) {
        // Success handled by UI
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// Reset password with token
  Future<void> resetPassword(String token, String password) async {
    final request = ResetPasswordRequest(token: token, password: password);
    final response = await _authService.resetPassword(request);
    
    response.when(
      success: (message, _) {
        // Success handled by UI
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: newPassword,
    );
    final response = await _authService.changePassword(request);
    
    response.when(
      success: (message, _) {
        // Success handled by UI
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// Verify email
  Future<void> verifyEmail(String token) async {
    final request = VerifyEmailRequest(token: token);
    final response = await _authService.verifyEmail(request);
    
    response.when(
      success: (message, _) {
        // Refresh user data
        refreshUser();
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// Resend email verification
  Future<void> resendEmailVerification(String email) async {
    final response = await _authService.resendEmailVerification(email);
    
    response.when(
      success: (message, _) {
        // Success handled by UI
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// Setup Two-Factor Authentication
  Future<TwoFactorSetupResponse> setup2FA() async {
    final response = await _authService.setup2FA();
    
    return response.when(
      success: (setupData, _) {
        return setupData;
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        throw Exception('Loading...');
      },
    );
  }

  /// Enable Two-Factor Authentication
  Future<void> enable2FA(String code) async {
    final response = await _authService.enable2FA(code);
    
    response.when(
      success: (message, _) {
        refreshUser();
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// Verify Two-Factor Authentication code
  Future<void> verify2FA(String code, {String? token, bool isBackup = false}) async {
    state = const AuthState.authenticating();

    // Check rate limit for 2FA verification
    final rateLimitResult = await _rateLimiter.checkLimit(
      endpoint: '/api/auth/verify-2fa',
      clientId: token ?? 'unknown',
      metadata: {'ip': 'client-ip'}, // In production, get actual IP
    );

    if (!rateLimitResult.allowed) {
      state = AuthState.error(
        rateLimitResult.reason ?? 'Too many verification attempts. Please try again later.',
      );
      throw Exception(rateLimitResult.reason ?? 'Rate limit exceeded');
    }

    final request = VerifyTwoFactorRequest(
      code: code,
      token: token,
      isBackup: isBackup,
    );
    final response = await _authService.verify2FA(request);
    
    response.when(
      success: (user, message) {
        state = AuthState.authenticated(
          user: user,
          accessToken: '', // Token is managed internally
        );
      },
      error: (message, code, _, __) {
        state = AuthState.error(message);
        throw Exception(message);
      },
      loading: () {
        state = const AuthState.authenticating();
      },
    );
  }

  /// Disable Two-Factor Authentication
  Future<void> disable2FA(String password) async {
    final response = await _authService.disable2FA(password);
    
    response.when(
      success: (message, _) {
        refreshUser();
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// OAuth login
  Future<void> oauthLogin(String provider, String code, {String? state}) async {
    this.state = const AuthState.authenticating();
    
    final request = OAuthLoginRequest(
      provider: provider,
      code: code,
      state: state,
    );
    final response = await _authService.oauthLogin(request);
    
    response.when(
      success: (user, message) {
        this.state = AuthState.authenticated(
          user: user,
          accessToken: '', // Token is managed internally
        );
      },
      error: (message, code, _, __) {
        this.state = AuthState.error(message);
        throw Exception(message);
      },
      loading: () {
        this.state = const AuthState.authenticating();
      },
    );
  }

  /// Request magic link
  Future<void> requestMagicLink(String email) async {
    // Check rate limit for magic link
    final rateLimitResult = await _rateLimiter.checkLimit(
      endpoint: '/api/auth/magic-link',
      clientId: email,
      metadata: {'ip': 'client-ip'}, // In production, get actual IP
    );

    if (!rateLimitResult.allowed) {
      throw Exception(rateLimitResult.reason ?? 'Too many magic link requests. Please try again later.');
    }

    final request = MagicLinkRequest(email: email);
    final response = await _authService.requestMagicLink(request);
    
    response.when(
      success: (message, _) {
        // Success handled by UI
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// Verify magic link
  Future<void> verifyMagicLink(String token) async {
    state = const AuthState.authenticating();
    
    final response = await _authService.verifyMagicLink(token);
    
    response.when(
      success: (user, message) {
        state = AuthState.authenticated(
          user: user,
          accessToken: '', // Token is managed internally
        );
      },
      error: (message, code, _, __) {
        state = AuthState.error(message);
        throw Exception(message);
      },
      loading: () {
        state = const AuthState.authenticating();
      },
    );
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final response = await _authService.updateProfile(data);
    
    response.when(
      success: (user, _) {
        if (state is Authenticated) {
          final currentState = state as Authenticated;
          state = currentState.copyWith(user: user);
        }
      },
      error: (message, code, _, __) {
        throw Exception(message);
      },
      loading: () {
        // Loading handled by UI
      },
    );
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (state is Authenticated) {
      try {
        final response = await _authService.getCurrentUser();

        response.when(
          success: (user, _) {
            final currentState = state as Authenticated;
            state = currentState.copyWith(user: user);
          },
          error: (_, __, ___, ____) {
            // Don't change state on refresh error
          },
          loading: () {
            // Don't change state during refresh
          },
        );
      } catch (e) {
        // Ignore refresh errors
      }
    }
  }

  /// Refresh authentication token
  Future<void> refreshToken() async {
    state = const AuthState.authenticating();

    // Check rate limit for token refresh
    final rateLimitResult = await _rateLimiter.checkLimit(
      endpoint: '/api/auth/refresh-token',
      clientId: 'refresh',
      metadata: {'ip': 'client-ip'}, // In production, get actual IP
    );

    if (!rateLimitResult.allowed) {
      state = const AuthState.unauthenticated();
      throw Exception(rateLimitResult.reason ?? 'Too many refresh attempts. Please login again.');
    }

    try {
      // Get stored refresh token
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        state = const AuthState.unauthenticated();
        throw Exception('No refresh token available');
      }

      // Call backend to refresh the token
      final response = await _authService.refreshToken(refreshToken);

      await response.when(
        success: (user, message) async {
          state = AuthState.authenticated(
            user: user,
            accessToken: '', // Token is managed internally
          );
        },
        error: (message, code, _, __) async {
          state = const AuthState.unauthenticated();
          throw Exception(message);
        },
        loading: () async {
          state = const AuthState.authenticating();
        },
      );
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AuthState.authenticating();

    try {
      // First, sign in with Google to get the tokens
      final googleSignInResponse = await _oauthService.signInWithGoogle();
      
      final googleResult = googleSignInResponse.when(
        success: (data, _) => data,
        error: (message, code, _, __) {
          throw Exception(message);
        },
        loading: () {
          throw Exception('Google Sign-In is loading...');
        },
      );

      // Now authenticate with our backend using the Google tokens
      final request = OAuthLoginRequest(
        provider: 'google',
        code: googleResult.accessToken, // Using access token as code
        state: null,
      );

      final response = await _authService.oauthLogin(request);

      response.when(
        success: (user, message) {
          state = AuthState.authenticated(
            user: user,
            accessToken: '', // Token is managed internally
          );
        },
        error: (message, code, _, __) {
          state = AuthState.error(message);
          throw Exception(message);
        },
        loading: () {
          state = const AuthState.authenticating();
        },
      );
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  /// Sign out from all OAuth providers
  Future<void> signOutFromOAuth() async {
    try {
      // Sign out from Google if signed in
      if (await _oauthService.isGoogleSignedIn()) {
        await _oauthService.signOutFromGoogle();
      }
      
      // Add other OAuth provider sign-outs here when implemented
    } catch (e) {
      // Ignore OAuth sign-out errors
    }
  }

  /// Logout to include OAuth sign-out
  Future<void> logout() async {
    state = const AuthState.authenticating();
    
    // Sign out from OAuth providers
    await signOutFromOAuth();
    
    // Sign out from our backend
    final response = await _authService.logout();
    state = const AuthState.unauthenticated();
  }

  /// Clear error state
  void clearError() {
    if (state is AuthError) {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Convenience providers for specific auth state
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    unauthenticated: () => null,
    authenticating: () => null,
    authenticated: (user, _, __) => user,
    error: (_) => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    unauthenticated: () => false,
    authenticating: () => false,
    authenticated: (_, __, ___) => true,
    error: (_) => false,
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    unauthenticated: () => false,
    authenticating: () => true,
    authenticated: (_, __, ___) => false,
    error: (_) => false,
  );
});