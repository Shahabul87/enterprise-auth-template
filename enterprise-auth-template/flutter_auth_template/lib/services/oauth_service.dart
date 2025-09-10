import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/network/api_response.dart';
import '../core/errors/app_exception.dart';

// OAuth Service Provider
final oauthServiceProvider = Provider<OAuthService>((ref) {
  return OAuthService();
});

/// OAuth service for handling various OAuth providers
class OAuthService {
  // Google Sign-In instance
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  /// Sign in with Google
  Future<ApiResponse<GoogleSignInResult>> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available on this platform
      if (!_isGoogleSignInAvailable()) {
        return const ApiResponse.error(
          message: 'Google Sign-In is not available on this platform',
        );
      }

      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
      
      if (googleAccount == null) {
        // User cancelled the sign-in
        return const ApiResponse.error(
          message: 'Google Sign-In was cancelled by user',
          code: 'CANCELLED',
        );
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleAccount.authentication;

      if (googleAuth.accessToken == null) {
        return const ApiResponse.error(
          message: 'Failed to get Google access token',
          code: 'NO_ACCESS_TOKEN',
        );
      }

      final result = GoogleSignInResult(
        user: googleAccount,
        accessToken: googleAuth.accessToken!,
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
      // Ignore sign-out errors as they're not critical
      debugPrint('Google sign-out error: $e');
    }
  }

  /// Check if user is signed in to Google
  Future<bool> isGoogleSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      debugPrint('Google sign-in check error: $e');
      return false;
    }
  }

  /// Get current Google user
  Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      debugPrint('Get current Google user error: $e');
      return null;
    }
  }

  /// Apple Sign-In (placeholder for future implementation)
  Future<ApiResponse<AppleSignInResult>> signInWithApple() async {
    // TODO: Implement Apple Sign-In using sign_in_with_apple package
    return const ApiResponse.error(
      message: 'Apple Sign-In not implemented yet',
      code: 'NOT_IMPLEMENTED',
    );
  }

  /// Facebook Sign-In (placeholder for future implementation)
  Future<ApiResponse<FacebookSignInResult>> signInWithFacebook() async {
    // TODO: Implement Facebook Sign-In using flutter_facebook_auth package
    return const ApiResponse.error(
      message: 'Facebook Sign-In not implemented yet',
      code: 'NOT_IMPLEMENTED',
    );
  }

  /// GitHub Sign-In (placeholder for web-based OAuth)
  Future<ApiResponse<GitHubSignInResult>> signInWithGitHub() async {
    // TODO: Implement GitHub OAuth using web-based flow
    return const ApiResponse.error(
      message: 'GitHub Sign-In not implemented yet',
      code: 'NOT_IMPLEMENTED',
    );
  }

  /// Discord Sign-In (placeholder for web-based OAuth)
  Future<ApiResponse<DiscordSignInResult>> signInWithDiscord() async {
    // TODO: Implement Discord OAuth using web-based flow
    return const ApiResponse.error(
      message: 'Discord Sign-In not implemented yet',
      code: 'NOT_IMPLEMENTED',
    );
  }

  /// Check if Google Sign-In is available on current platform
  bool _isGoogleSignInAvailable() {
    // Google Sign-In is available on Android, iOS, and Web
    if (kIsWeb) return true;
    
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      // If Platform is not available, assume it's web or supported
      return true;
    }
  }
}

/// Google Sign-In result
class GoogleSignInResult {
  final GoogleSignInAccount user;
  final String accessToken;
  final String? idToken;

  GoogleSignInResult({
    required this.user,
    required this.accessToken,
    this.idToken,
  });

  Map<String, dynamic> toJson() => {
    'provider': 'google',
    'id': user.id,
    'email': user.email,
    'name': user.displayName,
    'photoUrl': user.photoUrl,
    'accessToken': accessToken,
    'idToken': idToken,
  };
}

/// Apple Sign-In result (placeholder)
class AppleSignInResult {
  final String userIdentifier;
  final String? email;
  final String? fullName;
  final String identityToken;

  AppleSignInResult({
    required this.userIdentifier,
    this.email,
    this.fullName,
    required this.identityToken,
  });

  Map<String, dynamic> toJson() => {
    'provider': 'apple',
    'userIdentifier': userIdentifier,
    'email': email,
    'fullName': fullName,
    'identityToken': identityToken,
  };
}

/// Facebook Sign-In result (placeholder)
class FacebookSignInResult {
  final String userId;
  final String accessToken;
  final String? email;
  final String? name;

  FacebookSignInResult({
    required this.userId,
    required this.accessToken,
    this.email,
    this.name,
  });

  Map<String, dynamic> toJson() => {
    'provider': 'facebook',
    'userId': userId,
    'accessToken': accessToken,
    'email': email,
    'name': name,
  };
}

/// GitHub Sign-In result (placeholder)
class GitHubSignInResult {
  final String code;
  final String? state;

  GitHubSignInResult({
    required this.code,
    this.state,
  });

  Map<String, dynamic> toJson() => {
    'provider': 'github',
    'code': code,
    'state': state,
  };
}

/// Discord Sign-In result (placeholder)
class DiscordSignInResult {
  final String code;
  final String? state;

  DiscordSignInResult({
    required this.code,
    this.state,
  });

  Map<String, dynamic> toJson() => {
    'provider': 'discord',
    'code': code,
    'state': state,
  };
}