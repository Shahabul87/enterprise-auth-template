import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/auth_service.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/core/security/account_lockout_service.dart';
import 'package:flutter_auth_template/core/security/device_fingerprint_service.dart';
import 'package:flutter_auth_template/core/security/rate_limiter.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';
import 'package:flutter_auth_template/core/security/encryption_key_manager.dart';

import 'auth_flow_integration_test.mocks.dart';

@GenerateMocks([
  AuthService,
  OAuthService,
  SecureStorageService,
  AccountLockoutService,
  DeviceFingerprintService,
  RateLimiter,
  EncryptionKeyManager,
])
void main() {
  late ProviderContainer container;
  late MockAuthService mockAuthService;
  late MockOAuthService mockOAuthService;
  late MockSecureStorageService mockSecureStorage;
  late MockAccountLockoutService mockAccountLockout;
  late MockDeviceFingerprintService mockDeviceFingerprint;
  late MockRateLimiter mockRateLimiter;
  late MockEncryptionKeyManager mockKeyManager;

  setUp(() {
    mockAuthService = MockAuthService();
    mockOAuthService = MockOAuthService();
    mockSecureStorage = MockSecureStorageService();
    mockAccountLockout = MockAccountLockoutService();
    mockDeviceFingerprint = MockDeviceFingerprintService();
    mockRateLimiter = MockRateLimiter();
    mockKeyManager = MockEncryptionKeyManager();

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        oauthServiceProvider.overrideWithValue(mockOAuthService),
        secureStorageServiceProvider.overrideWithValue(mockSecureStorage),
        accountLockoutServiceProvider.overrideWithValue(mockAccountLockout),
        deviceFingerprintServiceProvider.overrideWithValue(mockDeviceFingerprint),
        rateLimiterProvider.overrideWithValue(mockRateLimiter),
        encryptionKeyManagerProvider.overrideWithValue(mockKeyManager),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Complete Authentication Flow Tests', () {
    test('should successfully complete full login flow with all security checks', () async {
      // Arrange
      const email = 'user@example.com';
      const password = 'SecurePass123!';
      final user = User(
        id: '123',
        email: email,
        name: 'Test User',
        isEmailVerified: true,
      );

      // Mock successful responses for all security checks
      when(mockRateLimiter.checkLimit(
        endpoint: anyNamed('endpoint'),
        clientId: anyNamed('clientId'),
      )).thenAnswer((_) async => RateLimitResult(
        isAllowed: true,
        remainingAttempts: 5,
      ));

      when(mockAccountLockout.isAccountLocked(email))
          .thenAnswer((_) async => false);

      when(mockAuthService.login(any)).thenAnswer(
        (_) async => ApiResponse.success(data: user),
      );

      when(mockAccountLockout.clearFailedAttempts(email))
          .thenAnswer((_) async => {});

      when(mockDeviceFingerprint.generateFingerprint())
          .thenAnswer((_) async => DeviceFingerprint(
                id: 'device123',
                platform: 'iOS',
                model: 'iPhone 12',
                os: '14.0',
              ));

      when(mockDeviceFingerprint.isDeviceTrusted(any))
          .thenAnswer((_) async => false);

      when(mockDeviceFingerprint.trustDevice(
        userId: anyNamed('userId'),
        customName: anyNamed('customName'),
      )).thenAnswer((_) async => const ApiResponse.success(data: true));

      when(mockRateLimiter.clearLimit(
        endpoint: anyNamed('endpoint'),
        clientId: anyNamed('clientId'),
      )).thenAnswer((_) async => {});

      when(mockKeyManager.initialize()).thenAnswer((_) async => {});

      // Act
      final authNotifier = container.read(authNotifierProvider.notifier);
      final result = await authNotifier.login(email, password);

      // Assert
      expect(result, isTrue);
      expect(container.read(authNotifierProvider).user, equals(user));
      expect(container.read(authNotifierProvider).isAuthenticated, isTrue);

      // Verify all security services were called
      verify(mockRateLimiter.checkLimit(
        endpoint: '/api/auth/login',
        clientId: email,
      )).called(1);

      verify(mockAccountLockout.isAccountLocked(email)).called(1);
      verify(mockAuthService.login(any)).called(1);
      verify(mockAccountLockout.clearFailedAttempts(email)).called(1);
      verify(mockDeviceFingerprint.generateFingerprint()).called(1);
      verify(mockDeviceFingerprint.isDeviceTrusted(any)).called(1);
      verify(mockDeviceFingerprint.trustDevice(
        userId: user.id,
        customName: anyNamed('customName'),
      )).called(1);
      verify(mockRateLimiter.clearLimit(
        endpoint: '/api/auth/login',
        clientId: email,
      )).called(1);
    });

    test('should handle rate limiting and prevent login', () async {
      // Arrange
      const email = 'user@example.com';
      const password = 'SecurePass123!';

      when(mockRateLimiter.checkLimit(
        endpoint: anyNamed('endpoint'),
        clientId: anyNamed('clientId'),
      )).thenAnswer((_) async => RateLimitResult(
        isAllowed: false,
        remainingAttempts: 0,
        resetTime: DateTime.now().add(const Duration(minutes: 15)),
      ));

      // Act
      final authNotifier = container.read(authNotifierProvider.notifier);
      final result = await authNotifier.login(email, password);

      // Assert
      expect(result, isFalse);
      expect(container.read(authNotifierProvider).error, contains('Too many attempts'));
      verifyNever(mockAuthService.login(any));
    });

    test('should handle account lockout and prevent login', () async {
      // Arrange
      const email = 'user@example.com';
      const password = 'SecurePass123!';

      when(mockRateLimiter.checkLimit(
        endpoint: anyNamed('endpoint'),
        clientId: anyNamed('clientId'),
      )).thenAnswer((_) async => RateLimitResult(
        isAllowed: true,
        remainingAttempts: 5,
      ));

      when(mockAccountLockout.isAccountLocked(email))
          .thenAnswer((_) async => true);

      when(mockAccountLockout.recordFailedAttempt(email))
          .thenAnswer((_) async => AccountLockoutStatus(
                isLocked: true,
                failedAttempts: 5,
                lockoutUntil: DateTime.now().add(const Duration(minutes: 30)),
              ));

      // Act
      final authNotifier = container.read(authNotifierProvider.notifier);
      final result = await authNotifier.login(email, password);

      // Assert
      expect(result, isFalse);
      expect(container.read(authNotifierProvider).error, contains('locked'));
      verifyNever(mockAuthService.login(any));
    });

    test('should handle failed login and record attempt', () async {
      // Arrange
      const email = 'user@example.com';
      const password = 'WrongPassword';

      when(mockRateLimiter.checkLimit(
        endpoint: anyNamed('endpoint'),
        clientId: anyNamed('clientId'),
      )).thenAnswer((_) async => RateLimitResult(
        isAllowed: true,
        remainingAttempts: 5,
      ));

      when(mockAccountLockout.isAccountLocked(email))
          .thenAnswer((_) async => false);

      when(mockAuthService.login(any)).thenAnswer(
        (_) async => const ApiResponse.error(
          message: 'Invalid credentials',
        ),
      );

      when(mockAccountLockout.recordFailedAttempt(email))
          .thenAnswer((_) async => AccountLockoutStatus(
                isLocked: false,
                failedAttempts: 1,
                remainingAttempts: 4,
              ));

      // Act
      final authNotifier = container.read(authNotifierProvider.notifier);
      final result = await authNotifier.login(email, password);

      // Assert
      expect(result, isFalse);
      expect(container.read(authNotifierProvider).error, contains('Invalid credentials'));
      verify(mockAccountLockout.recordFailedAttempt(email)).called(1);
      verifyNever(mockAccountLockout.clearFailedAttempts(email));
    });

    test('should handle biometric authentication flow', () async {
      // Arrange
      final user = User(
        id: '123',
        email: 'user@example.com',
        name: 'Test User',
        isEmailVerified: true,
      );

      when(mockSecureStorage.isBiometricEnabled())
          .thenAnswer((_) async => true);

      when(mockAuthService.getCurrentUser())
          .thenAnswer((_) async => ApiResponse.success(data: user));

      when(mockDeviceFingerprint.generateFingerprint())
          .thenAnswer((_) async => DeviceFingerprint(
                id: 'device123',
                platform: 'iOS',
                model: 'iPhone 12',
                os: '14.0',
              ));

      when(mockDeviceFingerprint.isDeviceTrusted(any))
          .thenAnswer((_) async => true);

      // Act
      final authNotifier = container.read(authNotifierProvider.notifier);
      final result = await authNotifier.authenticateWithBiometric();

      // Assert
      expect(result, isTrue);
      expect(container.read(authNotifierProvider).user, equals(user));
      expect(container.read(authNotifierProvider).isAuthenticated, isTrue);
    });

    test('should handle token refresh with encryption', () async {
      // Arrange
      const refreshToken = 'refresh_token_123';
      final user = User(
        id: '123',
        email: 'user@example.com',
        name: 'Test User',
        isEmailVerified: true,
      );

      when(mockSecureStorage.getRefreshToken())
          .thenAnswer((_) async => refreshToken);

      when(mockAuthService.refreshToken(refreshToken))
          .thenAnswer((_) async => ApiResponse.success(data: user));

      // Act
      final authNotifier = container.read(authNotifierProvider.notifier);
      final result = await authNotifier.refreshToken();

      // Assert
      expect(result, isTrue);
      expect(container.read(authNotifierProvider).user, equals(user));
      verify(mockSecureStorage.getRefreshToken()).called(1);
      verify(mockAuthService.refreshToken(refreshToken)).called(1);
    });

    test('should handle logout and clear all security data', () async {
      // Arrange
      when(mockAuthService.logout())
          .thenAnswer((_) async => const ApiResponse.success(data: 'Logged out'));

      when(mockSecureStorage.clearAll()).thenAnswer((_) async => {});

      when(mockRateLimiter.clearAll()).thenAnswer((_) async => {});

      // Act
      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.logout();

      // Assert
      expect(container.read(authNotifierProvider).user, isNull);
      expect(container.read(authNotifierProvider).isAuthenticated, isFalse);
      verify(mockAuthService.logout()).called(1);
      verify(mockSecureStorage.clearAll()).called(1);
    });
  });
}