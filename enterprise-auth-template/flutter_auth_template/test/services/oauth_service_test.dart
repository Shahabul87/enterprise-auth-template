import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';

void main() {
  late OAuthService oauthService;

  setUp(() {
    oauthService = OAuthService();
  });

  group('OAuthService', () {
    group('signInWithGoogle', () {
      test('should return error when Google Sign-In is not configured', () async {
        // Act
        final result = await oauthService.signInWithGoogle();

        // Assert
        expect(result, isA<ApiResponse<GoogleSignInResult>>());
        expect(result.isError, true);
        expect(result.errorCode, 'NOT_CONFIGURED');
        expect(result.errorMessage,
            'Google Sign-In needs proper configuration for this platform');
      });
    });

    group('signOutFromGoogle', () {
      test('should complete without errors', () async {
        // Act & Assert - Should not throw
        await oauthService.signOutFromGoogle();
      });
    });

    group('isGoogleSignedIn', () {
      test('should return false when not signed in', () async {
        // Act
        final result = await oauthService.isGoogleSignedIn();

        // Assert
        expect(result, false);
      });
    });

    group('getCurrentGoogleUser', () {
      test('should return null when no user is signed in', () {
        // Act
        final result = oauthService.getCurrentGoogleUser();

        // Assert
        expect(result, isNull);
      });
    });
  });

  group('GoogleSignInAccount', () {
    test('should create instance with required fields', () {
      // Arrange
      const email = 'test@example.com';
      const displayName = 'Test User';
      const photoUrl = 'https://example.com/photo.jpg';

      // Act
      const account = GoogleSignInAccount(
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Assert
      expect(account.email, email);
      expect(account.displayName, displayName);
      expect(account.photoUrl, photoUrl);
    });

    test('should create instance without photo URL', () {
      // Arrange
      const email = 'test@example.com';
      const displayName = 'Test User';

      // Act
      const account = GoogleSignInAccount(
        email: email,
        displayName: displayName,
      );

      // Assert
      expect(account.email, email);
      expect(account.displayName, displayName);
      expect(account.photoUrl, isNull);
    });
  });

  group('GoogleSignInResult', () {
    test('should provide access to user properties', () {
      // Arrange
      const user = GoogleSignInAccount(
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
      );
      const accessToken = 'test_access_token';
      const idToken = 'test_id_token';

      // Act
      const result = GoogleSignInResult(
        user: user,
        accessToken: accessToken,
        idToken: idToken,
      );

      // Assert
      expect(result.email, user.email);
      expect(result.displayName, user.displayName);
      expect(result.photoUrl, user.photoUrl);
      expect(result.accessToken, accessToken);
      expect(result.idToken, idToken);
    });
  });
}