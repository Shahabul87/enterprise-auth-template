import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/auth_service.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/core/security/account_lockout_service.dart';
import 'package:flutter_auth_template/core/security/device_fingerprint_service.dart';
import 'package:flutter_auth_template/core/security/session_timeout_manager.dart';
import 'package:flutter_auth_template/core/security/remember_device_service.dart';
import 'package:flutter_auth_template/core/security/rate_limiter.dart';
import 'package:flutter_auth_template/domain/entities/auth_state.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';

import 'security_integration_test.mocks.dart';

@GenerateMocks([
  AuthService,
  OAuthService,
  SecureStorageService,
  AccountLockoutService,
  DeviceFingerprintService,
  SessionTimeoutManager,
  RememberDeviceService,
  RateLimiter,
])
void main() {
  group('Security Features Integration Tests', () {
    late AuthNotifier authNotifier;
    late MockAuthService mockAuthService;
    late MockOAuthService mockOAuthService;
    late MockSecureStorageService mockSecureStorage;
    late MockAccountLockoutService mockAccountLockout;
    late MockDeviceFingerprintService mockDeviceFingerprint;
    late MockRateLimiter mockRateLimiter;

    setUp(() {
      mockAuthService = MockAuthService();
      mockOAuthService = MockOAuthService();
      mockSecureStorage = MockSecureStorageService();
      mockAccountLockout = MockAccountLockoutService();
      mockDeviceFingerprint = MockDeviceFingerprintService();
      mockRateLimiter = MockRateLimiter();

      authNotifier = AuthNotifier(
        mockAuthService,
        mockOAuthService,
        mockSecureStorage,
        mockAccountLockout,
        mockDeviceFingerprint,
        mockRateLimiter,
      );
    });

    group('Account Lockout', () {
      test('should prevent login when account is locked', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        // Mock rate limit passes
        when(mockRateLimiter.checkLimit(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => RateLimitResult(
          allowed: true,
          remainingAttempts: 5,
          resetTime: DateTime.now().add(const Duration(minutes: 1)),
          retryAfterSeconds: 0,
        ));

        when(mockAccountLockout.isAccountLocked()).thenAnswer((_) async => true);
        when(mockAccountLockout.getRemainingLockoutMinutes()).thenAnswer((_) async => 25);

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<AuthError>());
        final state = authNotifier.state as AuthError;
        expect(state.message, contains('Account is locked'));
        expect(state.message, contains('25 minutes'));

        // Verify login was not attempted
        verifyNever(mockAuthService.login(any));
      });

      test('should record failed attempts and clear on success', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final user = User(
          id: '123',
          email: email,
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: [],
          permissions: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock rate limit passes
        when(mockRateLimiter.checkLimit(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => RateLimitResult(
          allowed: true,
          remainingAttempts: 5,
          resetTime: DateTime.now().add(const Duration(minutes: 1)),
          retryAfterSeconds: 0,
        ));

        when(mockRateLimiter.recordSuccess(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenReturn(null);

        when(mockAccountLockout.isAccountLocked()).thenAnswer((_) async => false);
        when(mockAuthService.login(any)).thenAnswer(
          (_) async => ApiResponse.success(data: user),
        );
        when(mockAccountLockout.clearFailedAttempts(email)).thenAnswer((_) async {});
        when(mockDeviceFingerprint.generateFingerprint()).thenAnswer(
          (_) async => DeviceFingerprint(
            fingerprintId: 'test-fingerprint',
            deviceId: 'test-device',
            deviceName: 'Test Device',
            deviceModel: 'Test Model',
            osVersion: '1.0',
            platform: 'Test',
            additionalInfo: {},
            createdAt: DateTime.now(),
          ),
        );
        when(mockDeviceFingerprint.isDeviceTrusted(any)).thenAnswer((_) async => true);
        when(mockDeviceFingerprint.recordDeviceVerification()).thenAnswer((_) async {});

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<Authenticated>());
        verify(mockAccountLockout.clearFailedAttempts(email)).called(1);
        verify(mockRateLimiter.recordSuccess(
          endpoint: '/api/auth/login',
          clientId: email,
        )).called(1);
      });
    });

    group('Device Fingerprinting', () {
      test('should trust new device on successful login', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final user = User(
          id: '123',
          email: email,
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: [],
          permissions: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock rate limit passes
        when(mockRateLimiter.checkLimit(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => RateLimitResult(
          allowed: true,
          remainingAttempts: 5,
          resetTime: DateTime.now().add(const Duration(minutes: 1)),
          retryAfterSeconds: 0,
        ));

        when(mockRateLimiter.recordSuccess(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenReturn(null);

        when(mockAccountLockout.isAccountLocked()).thenAnswer((_) async => false);
        when(mockAuthService.login(any)).thenAnswer(
          (_) async => ApiResponse.success(data: user),
        );
        when(mockAccountLockout.clearFailedAttempts(email)).thenAnswer((_) async {});

        final fingerprint = DeviceFingerprint(
          fingerprintId: 'new-device-id',
          deviceId: 'device-123',
          deviceName: 'iPhone 14',
          deviceModel: 'iPhone14,2',
          osVersion: '16.0',
          platform: 'iOS',
          additionalInfo: {},
          createdAt: DateTime.now(),
        );

        when(mockDeviceFingerprint.generateFingerprint()).thenAnswer(
          (_) async => fingerprint,
        );
        when(mockDeviceFingerprint.isDeviceTrusted(user.id)).thenAnswer((_) async => false);
        when(mockDeviceFingerprint.trustDevice(
          userId: user.id,
          customName: anyNamed('customName'),
        )).thenAnswer((_) async => const ApiResponse.success(data: true));

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<Authenticated>());
        verify(mockDeviceFingerprint.trustDevice(
          userId: user.id,
          customName: '${fingerprint.deviceModel} - ${fingerprint.platform}',
        )).called(1);
      });

      test('should verify already trusted device', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final user = User(
          id: '123',
          email: email,
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: [],
          permissions: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock rate limit passes
        when(mockRateLimiter.checkLimit(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => RateLimitResult(
          allowed: true,
          remainingAttempts: 5,
          resetTime: DateTime.now().add(const Duration(minutes: 1)),
          retryAfterSeconds: 0,
        ));

        when(mockRateLimiter.recordSuccess(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenReturn(null);

        when(mockAccountLockout.isAccountLocked()).thenAnswer((_) async => false);
        when(mockAuthService.login(any)).thenAnswer(
          (_) async => ApiResponse.success(data: user),
        );
        when(mockAccountLockout.clearFailedAttempts(email)).thenAnswer((_) async {});
        when(mockDeviceFingerprint.generateFingerprint()).thenAnswer(
          (_) async => DeviceFingerprint(
            fingerprintId: 'trusted-device',
            deviceId: 'device-123',
            deviceName: 'My Phone',
            deviceModel: 'Model X',
            osVersion: '1.0',
            platform: 'Android',
            additionalInfo: {},
            createdAt: DateTime.now(),
          ),
        );
        when(mockDeviceFingerprint.isDeviceTrusted(user.id)).thenAnswer((_) async => true);
        when(mockDeviceFingerprint.recordDeviceVerification()).thenAnswer((_) async {});

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<Authenticated>());
        verify(mockDeviceFingerprint.recordDeviceVerification()).called(1);
        verifyNever(mockDeviceFingerprint.trustDevice(
          userId: anyNamed('userId'),
          customName: anyNamed('customName'),
        ));
      });
    });

    group('Authentication Flow with Security Features', () {
      test('should complete login flow with all security checks', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'SecurePass123!';
        final user = User(
          id: 'user-456',
          email: email,
          name: 'John Doe',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: ['user'],
          permissions: ['read:profile'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Setup mocks
        // Mock rate limit passes
        when(mockRateLimiter.checkLimit(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => RateLimitResult(
          allowed: true,
          remainingAttempts: 5,
          resetTime: DateTime.now().add(const Duration(minutes: 1)),
          retryAfterSeconds: 0,
        ));

        when(mockRateLimiter.recordSuccess(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenReturn(null);

        when(mockAccountLockout.isAccountLocked()).thenAnswer((_) async => false);
        when(mockAuthService.login(any)).thenAnswer(
          (_) async => ApiResponse.success(data: user),
        );
        when(mockAccountLockout.clearFailedAttempts(email)).thenAnswer((_) async {});
        when(mockDeviceFingerprint.generateFingerprint()).thenAnswer(
          (_) async => DeviceFingerprint(
            fingerprintId: 'fingerprint-789',
            deviceId: 'device-789',
            deviceName: 'Test Device',
            deviceModel: 'Test Model',
            osVersion: '1.0',
            platform: 'Test Platform',
            additionalInfo: {},
            createdAt: DateTime.now(),
          ),
        );
        when(mockDeviceFingerprint.isDeviceTrusted(user.id)).thenAnswer((_) async => true);
        when(mockDeviceFingerprint.recordDeviceVerification()).thenAnswer((_) async {});

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<Authenticated>());
        final state = authNotifier.state as Authenticated;
        expect(state.user.email, equals(email));
        expect(state.user.id, equals('user-456'));

        // Verify security checks were performed
        verify(mockRateLimiter.checkLimit(
          endpoint: '/api/auth/login',
          clientId: email,
          metadata: anyNamed('metadata'),
        )).called(1);
        verify(mockAccountLockout.isAccountLocked()).called(1);
        verify(mockDeviceFingerprint.generateFingerprint()).called(1);
        verify(mockDeviceFingerprint.isDeviceTrusted(user.id)).called(1);
      });
    });

    group('Rate Limiting', () {
      test('should block login when rate limit exceeded', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        // Mock rate limit exceeded
        when(mockRateLimiter.checkLimit(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => RateLimitResult(
          allowed: false,
          remainingAttempts: 0,
          resetTime: DateTime.now().add(const Duration(minutes: 5)),
          reason: 'Too many requests. Please try again later.',
          retryAfterSeconds: 300,
        ));

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<AuthError>());
        final state = authNotifier.state as AuthError;
        expect(state.message, contains('Too many'));

        // Verify login was not attempted
        verifyNever(mockAuthService.login(any));
        verifyNever(mockAccountLockout.isAccountLocked());
      });

      test('should clear rate limit on successful login', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final user = User(
          id: '123',
          email: email,
          name: 'Test User',
          isEmailVerified: true,
          isTwoFactorEnabled: false,
          roles: [],
          permissions: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock rate limit passes
        when(mockRateLimiter.checkLimit(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => RateLimitResult(
          allowed: true,
          remainingAttempts: 2,
          resetTime: DateTime.now().add(const Duration(minutes: 1)),
          retryAfterSeconds: 0,
        ));

        when(mockRateLimiter.recordSuccess(
          endpoint: anyNamed('endpoint'),
          clientId: anyNamed('clientId'),
          metadata: anyNamed('metadata'),
        )).thenReturn(null);

        when(mockAccountLockout.isAccountLocked()).thenAnswer((_) async => false);
        when(mockAuthService.login(any)).thenAnswer(
          (_) async => ApiResponse.success(data: user),
        );
        when(mockAccountLockout.clearFailedAttempts(email)).thenAnswer((_) async {});
        when(mockDeviceFingerprint.generateFingerprint()).thenAnswer(
          (_) async => DeviceFingerprint(
            fingerprintId: 'test-fingerprint',
            deviceId: 'test-device',
            deviceName: 'Test Device',
            deviceModel: 'Test Model',
            osVersion: '1.0',
            platform: 'Test',
            additionalInfo: {},
            createdAt: DateTime.now(),
          ),
        );
        when(mockDeviceFingerprint.isDeviceTrusted(any)).thenAnswer((_) async => true);
        when(mockDeviceFingerprint.recordDeviceVerification()).thenAnswer((_) async {});

        // Act
        await authNotifier.login(email, password);

        // Assert
        expect(authNotifier.state, isA<Authenticated>());

        // Verify rate limit was cleared on success
        verify(mockRateLimiter.recordSuccess(
          endpoint: '/api/auth/login',
          clientId: email,
        )).called(1);
      });
    });
  });
}