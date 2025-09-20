import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';

// OAuth Service Provider
final oauthServiceProvider = Provider<OAuthService>((ref) {
  return OAuthService();
});

/// OAuth service for handling various OAuth providers
class OAuthService {
  // GoogleSignIn instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  OAuthService();

  /// Sign in with Google
  Future<ApiResponse<GoogleSignInResult>> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available on this platform
      if (!_isGoogleSignInAvailable()) {
        return const ApiResponse.error(
          message: 'Google Sign-In is not available on this platform',
        );
      }

      // For web and mobile, try to sign in
      GoogleSignInAccount? googleAccount;
      try {
        googleAccount = await _googleSignIn.signIn();
      } catch (e) {
        // Handle sign-in error
        return ApiResponse.error(
          message: 'Google Sign-In failed: ${e.toString()}',
          originalError: e,
        );
      }

      if (googleAccount == null) {
        // User cancelled the sign-in
        return const ApiResponse.error(
          message: 'Google Sign-In was cancelled by user',
          code: 'CANCELLED',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      // Use the token property instead of accessToken in newer versions
      final String? token = googleAuth.idToken;
      if (token == null) {
        return const ApiResponse.error(
          message: 'Failed to get Google access token',
          code: 'NO_ACCESS_TOKEN',
        );
      }

      final result = GoogleSignInResult(
        user: googleAccount,
        accessToken: token,
        idToken: googleAuth.idToken,
      );

      return ApiResponse.success(data: result);
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
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
    }
  }

  /// Check if user is signed in to Google
  Future<bool> isGoogleSignedIn() async {
    try {
      // Check if signed in
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      debugPrint('Error checking Google sign-in status: $e');
      return false;
    }
  }

  /// Get current Google user
  GoogleSignInAccount? getCurrentGoogleUser() {
    try {
      // Get current user
      return _googleSignIn.currentUser;
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
  String get displayName => user.displayName ?? '';
  String? get photoUrl => user.photoUrl;
}