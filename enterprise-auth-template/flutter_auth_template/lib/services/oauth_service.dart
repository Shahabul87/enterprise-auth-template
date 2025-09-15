import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_response.dart';
import '../core/errors/app_exception.dart';

// OAuth Service Provider
final oauthServiceProvider = Provider<OAuthService>((ref) {
  return OAuthService();
});

/// OAuth service for handling various OAuth providers
class OAuthService {
  OAuthService();

  /// Sign in with Google (simplified version)
  Future<ApiResponse<GoogleSignInResult>> signInWithGoogle() async {
    try {
      // For now, return a mock error indicating Google Sign-In needs configuration
      return const ApiResponse.error(
        message: 'Google Sign-In needs proper configuration for this platform',
        code: 'NOT_CONFIGURED',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Google Sign-In failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      debugPrint('Google Sign-In sign out (mock)');
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
    }
  }

  /// Check if user is signed in to Google
  Future<bool> isGoogleSignedIn() async {
    try {
      return false; // Mock return
    } catch (e) {
      debugPrint('Error checking Google sign-in status: $e');
      return false;
    }
  }

  /// Get current Google user
  GoogleSignInAccount? getCurrentGoogleUser() {
    try {
      return null; // Mock return
    } catch (e) {
      debugPrint('Error getting current Google user: $e');
      return null;
    }
  }

  /// Check if Google Sign-In is available on this platform
  bool _isGoogleSignInAvailable() {
    // Google Sign-In is available on iOS, Android, and Web
    if (kIsWeb) return true;
    if (Platform.isIOS || Platform.isAndroid) return true;
    return false;
  }
}

/// Placeholder for GoogleSignInAccount
class GoogleSignInAccount {
  final String email;
  final String displayName;
  final String? photoUrl;

  const GoogleSignInAccount({
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

/// Result class for Google Sign-In
class GoogleSignInResult {
  final GoogleSignInAccount user;
  final String accessToken;
  final String? idToken;

  const GoogleSignInResult({
    required this.user,
    required this.accessToken,
    this.idToken,
  });

  String get email => user.email;
  String get displayName => user.displayName;
  String? get photoUrl => user.photoUrl;
}