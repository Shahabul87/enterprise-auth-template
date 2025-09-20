import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_auth_template/infrastructure/services/auth/biometric_service.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:local_auth/local_auth.dart';

import 'biometric_service_test.mocks.dart';

@GenerateMocks([SecureStorageService, LocalAuthentication])
void main() {
  late BiometricService biometricService;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    biometricService = BiometricService(mockSecureStorage);
  });

  group('BiometricService', () {
    group('checkBiometricAvailability', () {
      test('should return availability when biometrics are supported', () async {
        // Act
        final result = await biometricService.checkBiometricAvailability();

        // Assert
        expect(result, isA<ApiResponse<BiometricAvailability>>());
      });
    });

    group('enableBiometricAuth', () {
      test('should enable biometric authentication when available', () async {
        // Arrange
        when(mockSecureStorage.storeBiometricEnabled(true))
            .thenAnswer((_) async => {});

        // Act
        final result = await biometricService.enableBiometricAuth();

        // Assert
        expect(result, isA<ApiResponse<String>>());
      });
    });

    group('disableBiometricAuth', () {
      test('should disable biometric authentication', () async {
        // Arrange
        when(mockSecureStorage.storeBiometricEnabled(false))
            .thenAnswer((_) async => {});

        // Act
        final result = await biometricService.disableBiometricAuth();

        // Assert
        expect(result, isA<ApiResponse<String>>());
        expect(result.isSuccess, true);
        verify(mockSecureStorage.storeBiometricEnabled(false)).called(1);
      });
    });

    group('isBiometricAuthEnabled', () {
      test('should return true when biometric is enabled', () async {
        // Arrange
        when(mockSecureStorage.isBiometricEnabled())
            .thenAnswer((_) async => true);

        // Act
        final result = await biometricService.isBiometricAuthEnabled();

        // Assert
        expect(result, true);
        verify(mockSecureStorage.isBiometricEnabled()).called(1);
      });

      test('should return false when biometric is disabled', () async {
        // Arrange
        when(mockSecureStorage.isBiometricEnabled())
            .thenAnswer((_) async => false);

        // Act
        final result = await biometricService.isBiometricAuthEnabled();

        // Assert
        expect(result, false);
        verify(mockSecureStorage.isBiometricEnabled()).called(1);
      });

      test('should handle errors gracefully', () async {
        // Arrange
        when(mockSecureStorage.isBiometricEnabled())
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await biometricService.isBiometricAuthEnabled();

        // Assert
        expect(result, false);
        verify(mockSecureStorage.isBiometricEnabled()).called(1);
      });
    });

    group('getBiometricStatus', () {
      test('should return complete biometric status', () async {
        // Arrange
        when(mockSecureStorage.isBiometricEnabled())
            .thenAnswer((_) async => true);

        // Act
        final result = await biometricService.getBiometricStatus();

        // Assert
        expect(result, isA<ApiResponse<BiometricStatus>>());
      });
    });
  });
}