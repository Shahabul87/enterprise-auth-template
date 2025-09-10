import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_response.dart';
import '../domain/entities/auth_state.dart';
import '../domain/entities/user.dart';
import '../data/models/auth_request.dart';
import '../data/models/auth_response.dart';
import '../services/auth_service.dart';
import '../services/oauth_service.dart';
import '../core/storage/secure_storage_service.dart';

// Authentication state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final oauthService = ref.watch(oauthServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(authService, oauthService, secureStorage);
});

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final OAuthService _oauthService;
  final SecureStorageService _secureStorage;

  AuthNotifier(this._authService, this._oauthService, this._secureStorage)
      : super(const AuthState.unauthenticated()) {
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
    
    final request = LoginRequest(email: email, password: password);
    final response = await _authService.login(request);
    
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

  /// Register new user
  Future<void> register(String email, String password, String name) async {
    state = const AuthState.authenticating();
    
    final request = RegisterRequest(
      email: email,
      password: password,
      name: name,
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

  /// Logout current user
  Future<void> logout() async {
    state = const AuthState.authenticating();
    
    final response = await _authService.logout();
    state = const AuthState.unauthenticated();
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
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

  /// Override logout to include OAuth sign-out
  @override
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
    authenticated: (user, _) => user,
    error: (_) => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    unauthenticated: () => false,
    authenticating: () => false,
    authenticated: (_, __) => true,
    error: (_) => false,
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    unauthenticated: () => false,
    authenticating: () => true,
    authenticated: (_, __) => false,
    error: (_) => false,
  );
});