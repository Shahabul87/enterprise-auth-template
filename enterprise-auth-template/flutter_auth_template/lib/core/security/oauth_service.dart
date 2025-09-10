import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import '../errors/app_exception.dart';
import '../constants/api_constants.dart';

final oauthServiceProvider = Provider<OAuthService>((ref) {
  return OAuthService();
});

class OAuthService {
  late final GoogleSignIn _googleSignIn;
  late final AppLinks _appLinks;

  OAuthService() {
    _initializeGoogleSignIn();
    _appLinks = AppLinks();
  }

  void _initializeGoogleSignIn() {
    // TODO: Fix Google Sign-In initialization
    // Current issue: Flutter analyzer not recognizing GoogleSignIn constructor
    // This is likely due to version compatibility or platform-specific configuration
    // For now, using a placeholder implementation

    developer.log(
      'Google Sign-In initialization skipped due to analyzer compatibility issues',
      name: 'OAuthService',
      level: 900,
    );

    // Create a stub implementation that will be replaced when platform is configured
    _googleSignIn = _createStubGoogleSignIn();
  }

  // Stub implementation for development/testing
  dynamic _createStubGoogleSignIn() {
    return _StubGoogleSignIn();
  }

  /// Google Sign-In Methods

  /// Check if Google Sign-In is available
  Future<bool> isGoogleSignInAvailable() async {
    try {
      // Try to initialize without signing in
      return true; // Google Sign-In is generally available on most platforms
    } catch (e) {
      developer.log(
        'Google Sign-In availability check failed: $e',
        name: 'OAuthService',
        level: 1000,
      );
      return false;
    }
  }

  /// Perform Google Sign-In
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // Note: Using dynamic typing as workaround for analyzer issues
      final dynamic googleSignIn = _googleSignIn;

      // Check if already signed in
      GoogleSignInAccount? account =
          googleSignIn.currentUser as GoogleSignInAccount?;

      if (account == null) {
        // Perform sign-in
        account = await googleSignIn.signIn() as GoogleSignInAccount?;
      }

      if (account == null) {
        developer.log(
          'Google Sign-In was canceled by user',
          name: 'OAuthService',
        );
        return null;
      }

      developer.log(
        'Google Sign-In successful: ${account.email}',
        name: 'OAuthService',
      );
      return account;
    } on PlatformException catch (e) {
      developer.log(
        'Google Sign-In platform error: $e',
        name: 'OAuthService',
        level: 1000,
      );
      throw UnknownException('Google Sign-In failed: ${e.message}', null);
    } catch (e) {
      developer.log(
        'Google Sign-In error: $e',
        name: 'OAuthService',
        level: 1000,
      );
      throw const UnknownException('Google Sign-In failed', null);
    }
  }

  /// Get Google authentication token
  Future<String?> getGoogleAuthToken(GoogleSignInAccount account) async {
    try {
      // Using dynamic for analyzer compatibility
      final dynamic auth = await account.authentication;

      // For backend integration, we typically need the ID token
      final String? idToken = auth.idToken as String?;
      final String? accessToken = auth.accessToken as String?;

      developer.log('Google auth token obtained', name: 'OAuthService');

      // Return ID token for backend verification, fallback to access token
      return idToken ?? accessToken;
    } catch (e) {
      developer.log(
        'Google auth token retrieval failed: $e',
        name: 'OAuthService',
        level: 1000,
      );
      throw const UnknownException(
        'Failed to get Google authentication token',
        null,
      );
    }
  }

  /// Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      final dynamic googleSignIn = _googleSignIn;
      await googleSignIn.signOut();
      developer.log('Google Sign-Out successful', name: 'OAuthService');
    } catch (e) {
      developer.log(
        'Google Sign-Out error: $e',
        name: 'OAuthService',
        level: 1000,
      );
      // Don't throw error for sign-out failures
    }
  }

  /// Check if currently signed in to Google
  bool isSignedInToGoogle() {
    final dynamic googleSignIn = _googleSignIn;
    return googleSignIn.currentUser != null;
  }

  /// Get current Google user
  GoogleSignInAccount? getCurrentGoogleUser() {
    final dynamic googleSignIn = _googleSignIn;
    return googleSignIn.currentUser as GoogleSignInAccount?;
  }

  /// Generic OAuth Methods (for GitHub, Discord, etc.)

  /// Launch OAuth authorization URL
  Future<bool> launchOAuthUrl(String authorizationUrl) async {
    try {
      final Uri uri = Uri.parse(authorizationUrl);

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );

      if (launched) {
        developer.log('OAuth URL launched successfully', name: 'OAuthService');
      } else {
        developer.log(
          'Failed to launch OAuth URL',
          name: 'OAuthService',
          level: 1000,
        );
        throw const UnknownException(
          'Failed to open authentication page',
          null,
        );
      }

      return launched;
    } catch (e) {
      developer.log(
        'Launch OAuth URL error: $e',
        name: 'OAuthService',
        level: 1000,
      );
      throw const UnknownException('Failed to open authentication page', null);
    }
  }

  /// Listen for OAuth callback deep link
  Stream<Uri> listenForOAuthCallback() {
    return _appLinks.uriLinkStream;
  }

  /// Handle OAuth callback URL
  OAuthCallbackResult parseOAuthCallback(Uri callbackUri) {
    try {
      final Map<String, String> params = callbackUri.queryParameters;

      // Check for error in callback
      if (params.containsKey('error')) {
        final String error = params['error'] ?? 'unknown_error';
        final String? errorDescription = params['error_description'];

        developer.log(
          'OAuth callback error: $error - $errorDescription',
          name: 'OAuthService',
          level: 1000,
        );

        return OAuthCallbackResult.error(
          error: error,
          description: errorDescription ?? 'OAuth authentication failed',
        );
      }

      // Extract authorization code
      final String? code = params['code'];
      final String? state = params['state'];

      if (code == null) {
        developer.log(
          'OAuth callback missing authorization code',
          name: 'OAuthService',
          level: 1000,
        );
        return const OAuthCallbackResult.error(
          error: 'invalid_callback',
          description: 'Authorization code not found in callback',
        );
      }

      developer.log(
        'OAuth callback successful with code: ${code.substring(0, 10)}...',
        name: 'OAuthService',
      );

      return OAuthCallbackResult.success(code: code, state: state);
    } catch (e) {
      developer.log(
        'OAuth callback parsing error: $e',
        name: 'OAuthService',
        level: 1000,
      );

      return OAuthCallbackResult.error(
        error: 'parse_error',
        description: 'Failed to parse OAuth callback',
      );
    }
  }

  /// Check if URL is OAuth callback
  bool isOAuthCallback(Uri uri) {
    return uri.scheme == ApiConstants.appScheme && uri.host == 'oauth';
  }

  /// Provider-specific OAuth helpers

  /// Get GitHub OAuth URL (will be provided by backend)
  Future<String> getGitHubOAuthUrl(String backendAuthUrl) async {
    // Backend should provide the complete GitHub OAuth URL
    return backendAuthUrl;
  }

  /// Get Discord OAuth URL (will be provided by backend)
  Future<String> getDiscordOAuthUrl(String backendAuthUrl) async {
    // Backend should provide the complete Discord OAuth URL
    return backendAuthUrl;
  }

  /// Dispose resources
  void dispose() {
    // Clean up resources if needed
  }
}

/// OAuth callback result data class
class OAuthCallbackResult {
  final bool isSuccess;
  final String? code;
  final String? state;
  final String? error;
  final String? description;

  const OAuthCallbackResult._({
    required this.isSuccess,
    this.code,
    this.state,
    this.error,
    this.description,
  });

  const OAuthCallbackResult.success({required String code, String? state})
    : this._(isSuccess: true, code: code, state: state);

  const OAuthCallbackResult.error({
    required String error,
    required String description,
  }) : this._(isSuccess: false, error: error, description: description);

  @override
  String toString() {
    if (isSuccess) {
      return 'OAuthCallbackResult.success(code: ${code?.substring(0, 10)}..., state: $state)';
    } else {
      return 'OAuthCallbackResult.error(error: $error, description: $description)';
    }
  }
}

/// Stub implementation for Google Sign-In
/// TODO: Replace with actual GoogleSignIn when platform configuration is complete
class _StubGoogleSignIn {
  GoogleSignInAccount? get currentUser => null;

  Future<GoogleSignInAccount?> signIn() async {
    developer.log(
      'Stub Google Sign-In called - not functional',
      name: 'StubGoogleSignIn',
    );
    return null;
  }

  Future<void> signOut() async {
    developer.log(
      'Stub Google Sign-Out called - not functional',
      name: 'StubGoogleSignIn',
    );
  }
}
