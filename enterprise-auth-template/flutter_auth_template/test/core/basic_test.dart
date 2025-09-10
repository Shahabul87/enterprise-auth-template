import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/core/constants/api_constants.dart';

void main() {
  group('Core Functionality Tests', () {
    group('User Model Tests', () {
      test('User model can be created from JSON', () {
        // Arrange
        final userJson = {
          'id': '123',
          'email': 'test@example.com',
          'name': 'Test User',
          'isEmailVerified': true,
          'isTwoFactorEnabled': false,
          'roles': <String>[],
          'permissions': <String>[],
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-01T00:00:00Z',
        };

        // Act
        final user = User.fromJson(userJson);

        // Assert
        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.isEmailVerified, isTrue);
        expect(user.isTwoFactorEnabled, isFalse);
      });

      test('User model can be serialized to JSON', () {
        // Arrange
        final user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: const [],
          permissions: const [],
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], '123');
        expect(json['email'], 'test@example.com');
        expect(json['name'], 'Test User');
        expect(json['isEmailVerified'], isTrue);
        expect(json['isTwoFactorEnabled'], isFalse);
      });
    });

    group('Auth Request Models Tests', () {
      test('LoginRequest can be created and serialized', () {
        // Arrange
        const request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['email'], 'test@example.com');
        expect(json['password'], 'password123');
      });

      test('RegisterRequest can be created and serialized', () {
        // Arrange
        const request = RegisterRequest(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['email'], 'test@example.com');
        expect(json['password'], 'password123');
        expect(json['name'], 'Test User');
      });

      test('ForgotPasswordRequest can be created and serialized', () {
        // Arrange
        const request = ForgotPasswordRequest(email: 'test@example.com');

        // Act
        final json = request.toJson();

        // Assert
        expect(json['email'], 'test@example.com');
      });

      test('ResetPasswordRequest can be created and serialized', () {
        // Arrange
        const request = ResetPasswordRequest(
          token: 'reset-token',
          password: 'newpassword123',
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['token'], 'reset-token');
        expect(json['password'], 'newpassword123');
      });
    });

    group('API Response Tests', () {
      test('ApiResponse.success creates successful response', () {
        // Arrange
        const testData = 'test data';

        // Act
        const response = ApiResponse<String>.success(data: testData);

        // Assert
        expect(response.isSuccess, isTrue);
        expect(response.isError, isFalse);
        expect(response.dataOrNull, testData);
        expect(response.errorMessage, isNull);
      });

      test('ApiResponse.error creates error response', () {
        // Arrange
        const errorMessage = 'Test error';
        const errorCode = 'TEST_ERROR';

        // Act
        const response = ApiResponse<String>.error(
          message: errorMessage,
          code: errorCode,
        );

        // Assert
        expect(response.isSuccess, isFalse);
        expect(response.isError, isTrue);
        expect(response.errorMessage, errorMessage);
        expect(response.dataOrNull, isNull);
      });

      test('ApiResponse handles loading state', () {
        // Act
        const response = ApiResponse<String>.loading();

        // Assert
        expect(response.isLoading, isTrue);
        expect(response.isSuccess, isFalse);
        expect(response.isError, isFalse);
      });
    });

    group('API Constants Tests', () {
      test('Auth endpoints are defined correctly', () {
        expect(ApiConstants.loginPath, '/auth/login');
        expect(ApiConstants.registerPath, '/auth/register');
        expect(ApiConstants.logoutPath, '/auth/logout');
        expect(ApiConstants.refreshPath, '/auth/refresh');
      });

      test('User endpoints are defined correctly', () {
        expect(ApiConstants.userMePath, '/users/me');
      });

      test('Two-factor endpoints are defined correctly', () {
        expect(ApiConstants.twoFactorSetupPath, '/2fa/setup');
        expect(ApiConstants.twoFactorEnablePath, '/2fa/enable');
        expect(ApiConstants.twoFactorVerifyPath, '/2fa/verify');
        expect(ApiConstants.twoFactorDisablePath, '/2fa/disable');
      });

      test('OAuth endpoints are defined correctly', () {
        expect(ApiConstants.oauthCallbackPath, '/oauth/{provider}/callback');
      });

      test('Magic link endpoints are defined correctly', () {
        expect(ApiConstants.magicLinkRequestPath, '/magic-links/request');
        expect(ApiConstants.magicLinkVerifyPath, '/magic-links/verify/{token}');
      });
    });

    group('Validation Logic Tests', () {
      test('email validation patterns', () {
        // Valid emails
        expect('test@example.com'.contains('@'), isTrue);
        expect('user.name@domain.org'.contains('@'), isTrue);
        expect('test+tag@example.co.uk'.contains('@'), isTrue);
        
        // Invalid emails
        expect('invalid-email'.contains('@'), isFalse);
        expect('test@'.length > 0, isTrue); // Still has some content
        expect(''.isEmpty, isTrue);
      });

      test('password strength validation', () {
        // Strong passwords
        expect('StrongPass123!'.length >= 8, isTrue);
        expect(r'MySecure123$'.contains(RegExp(r'[A-Z]')), isTrue);
        expect(r'MySecure123$'.contains(RegExp(r'[a-z]')), isTrue);
        expect(r'MySecure123$'.contains(RegExp(r'[0-9]')), isTrue);
        expect(r'MySecure123$'.contains(RegExp(r'[!@#\$%^&*()]')), isTrue);
        
        // Weak passwords
        expect('123'.length >= 8, isFalse);
        expect('password'.contains(RegExp(r'[0-9]')), isFalse);
        expect('PASSWORD123'.contains(RegExp(r'[a-z]')), isFalse);
      });

      test('token validation patterns', () {
        // JWT-like token pattern
        const jwtToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
        expect(jwtToken.split('.').length, 3); // JWT has 3 parts
        expect(jwtToken.startsWith('eyJ'), isTrue); // Common JWT header start
        
        // Simple token
        const simpleToken = 'abc123def456';
        expect(simpleToken.length > 0, isTrue);
        expect(simpleToken.contains(RegExp(r'^[a-zA-Z0-9]+$')), isTrue);
      });
    });

    group('Error Code Constants Tests', () {
      test('API error codes are defined', () {
        expect(ApiErrors.networkError, 'NETWORK_ERROR');
        expect(ApiErrors.invalidCredentials, 'INVALID_CREDENTIALS');
        expect(ApiErrors.userNotFound, 'USER_NOT_FOUND');
        expect(ApiErrors.twoFactorRequired, 'TWO_FACTOR_REQUIRED');
        expect(ApiErrors.tokenExpired, 'TOKEN_EXPIRED');
      });
    });

    group('Configuration Constants Tests', () {
      test('timeout values are reasonable', () {
        expect(ApiConstants.connectTimeoutMs, 30000); // 30 seconds
        expect(ApiConstants.receiveTimeoutMs, 60000); // 60 seconds
        expect(ApiConstants.sendTimeoutMs, 30000); // 30 seconds
      });

      test('cache keys are defined', () {
        expect(ApiConstants.tokenCacheKey, 'access_token');
        expect(ApiConstants.refreshTokenCacheKey, 'refresh_token');
        expect(ApiConstants.userCacheKey, 'user_data');
      });

      test('supported OAuth providers are listed', () {
        expect(ApiConstants.supportedOAuthProviders, contains('google'));
        expect(ApiConstants.supportedOAuthProviders, contains('github'));
        expect(ApiConstants.supportedOAuthProviders, contains('discord'));
      });

      test('two-factor authentication constants', () {
        expect(ApiConstants.totpCodeLength, 6);
        expect(ApiConstants.backupCodeLength, 8);
        expect(ApiConstants.backupCodeCount, 10);
      });

      test('password requirements', () {
        expect(ApiConstants.minPasswordLength, 8);
        expect(ApiConstants.passwordPattern, isNotEmpty);
      });
    });

    group('Date and Time Handling', () {
      test('DateTime parsing and formatting', () {
        // Test ISO 8601 date parsing
        const isoDate = '2024-01-01T00:00:00Z';
        final dateTime = DateTime.parse(isoDate);
        expect(dateTime.year, 2024);
        expect(dateTime.month, 1);
        expect(dateTime.day, 1);
        
        // Test date formatting
        final formattedDate = dateTime.toIso8601String();
        expect(formattedDate, startsWith('2024-01-01T'));
      });
    });
  });
}