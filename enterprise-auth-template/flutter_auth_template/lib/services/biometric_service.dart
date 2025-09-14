import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../core/errors/app_exception.dart';
import '../core/network/api_response.dart';
import '../core/storage/secure_storage_service.dart';

// Biometric Service Provider
final biometricServiceProvider = Provider<BiometricService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return BiometricService(secureStorage);
});

/// Biometric authentication service for handling fingerprint, face ID, etc.
class BiometricService {
  final SecureStorageService _secureStorage;
  final LocalAuthentication _localAuth = LocalAuthentication();

  BiometricService(this._secureStorage);

  /// Check if biometric authentication is available on device
  Future<ApiResponse<BiometricAvailability>> checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();

      if (!isAvailable) {
        return const ApiResponse.success(
          data: BiometricAvailability(
            isAvailable: false,
            reason: 'Device does not support biometric authentication',
          ),
        );
      }

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return const ApiResponse.success(
          data: BiometricAvailability(
            isAvailable: false,
            reason: 'Biometric authentication is not available',
          ),
        );
      }

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return const ApiResponse.success(
          data: BiometricAvailability(
            isAvailable: false,
            reason: 'No biometric authentication methods are enrolled',
          ),
        );
      }

      return ApiResponse.success(
        data: BiometricAvailability(
          isAvailable: true,
          availableBiometrics: availableBiometrics,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to check biometric availability: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Authenticate using biometrics
  Future<ApiResponse<bool>> authenticateWithBiometrics({
    String? reason,
  }) async {
    try {
      final availabilityResponse = await checkBiometricAvailability();
      if (!availabilityResponse.isSuccess) {
        return ApiResponse.error(message: availabilityResponse.message);
      }

      final availability = availabilityResponse.data!;
      if (!availability.isAvailable) {
        return ApiResponse.error(message: availability.reason);
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedFallbackTitle: 'Use PIN/Password',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'No thanks',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Set up biometric authentication',
            biometricHint: 'Verify identity',
            biometricNotRecognized: 'Not recognized, try again',
            biometricSuccess: 'Authentication successful',
            biometricRequiredTitle: 'Biometric Required',
            deviceCredentialsRequiredTitle: 'Device Credentials Required',
            deviceCredentialsSetupDescription: 'Device credentials required',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Set up biometric authentication',
            lockOut: 'Re-enable your Touch ID',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );

      return ApiResponse.success(data: didAuthenticate);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Biometric authentication failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Enable biometric authentication for the app
  Future<ApiResponse<String>> enableBiometricAuth() async {
    try {
      // First check if biometrics are available
      final availabilityResponse = await checkBiometricAvailability();
      if (!availabilityResponse.isSuccess) {
        return ApiResponse.error(message: availabilityResponse.message);
      }

      final availability = availabilityResponse.data!;
      if (!availability.isAvailable) {
        return ApiResponse.error(message: availability.reason);
      }

      // Authenticate to enable biometric auth
      final authResponse = await authenticateWithBiometrics();
      if (!authResponse.isSuccess) {
        return ApiResponse.error(message: authResponse.message);
      }

      if (!authResponse.data!) {
        return const ApiResponse.error(
          message: 'Biometric authentication was not successful',
        );
      }

      // Store biometric preference
      await _secureStorage.storeBiometricEnabled(true);

      return const ApiResponse.success(
        data: 'Biometric authentication has been enabled successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to enable biometric authentication: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Disable biometric authentication for the app
  Future<ApiResponse<String>> disableBiometricAuth() async {
    try {
      await _secureStorage.storeBiometricEnabled(false);

      return const ApiResponse.success(
        data: 'Biometric authentication has been disabled successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to disable biometric authentication: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Check if biometric authentication is enabled for the app
  Future<bool> isBiometricAuthEnabled() async {
    try {
      return await _secureStorage.isBiometricEnabled();
    } catch (e) {
      debugPrint('Error checking biometric auth status: $e');
      return false;
    }
  }

  /// Get biometric status including device capabilities and app settings
  Future<ApiResponse<BiometricStatus>> getBiometricStatus() async {
    try {
      final availabilityResponse = await checkBiometricAvailability();
      final isAppEnabled = await isBiometricAuthEnabled();

      if (!availabilityResponse.isSuccess) {
        return ApiResponse.success(
          data: BiometricStatus(
            isDeviceSupported: false,
            isAppEnabled: false,
            message: availabilityResponse.message,
          ),
        );
      }

      final availability = availabilityResponse.data!;
      return ApiResponse.success(
        data: BiometricStatus(
          isDeviceSupported: availability.isAvailable,
          isAppEnabled: isAppEnabled,
          availableBiometrics: availability.availableBiometrics,
          message: availability.isAvailable
              ? 'Biometric authentication is available'
              : availability.reason,
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to get biometric status: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Prompt user to set up biometric authentication
  Future<ApiResponse<bool>> promptBiometricSetup() async {
    try {
      final availabilityResponse = await checkBiometricAvailability();
      if (!availabilityResponse.isSuccess) {
        return ApiResponse.error(message: availabilityResponse.message);
      }

      final availability = availabilityResponse.data!;
      if (!availability.isAvailable) {
        // If biometrics aren't set up, we can't force setup but can guide user
        return ApiResponse.success(
          data: false,
        );
      }

      // If biometrics are available, enable them
      final enableResponse = await enableBiometricAuth();
      if (enableResponse.isSuccess) {
        return const ApiResponse.success(data: true);
      } else {
        return ApiResponse.error(message: enableResponse.message);
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to set up biometric authentication: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get user-friendly biometric type names
  List<String> getBiometricTypeNames(List<BiometricType> types) {
    return types.map((type) {
      switch (type) {
        case BiometricType.face:
          return 'Face ID';
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.iris:
          return 'Iris';
        case BiometricType.strong:
          return 'Strong Biometric';
        case BiometricType.weak:
          return 'Weak Biometric';
        default:
          return 'Biometric';
      }
    }).toList();
  }

  /// Handle platform-specific exceptions
  ApiResponse<bool> _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return const ApiResponse.error(
          message: 'Biometric authentication is not available on this device',
          code: 'BIOMETRIC_NOT_AVAILABLE',
        );
      case 'NotEnrolled':
        return const ApiResponse.error(
          message: 'No biometric authentication methods are enrolled',
          code: 'BIOMETRIC_NOT_ENROLLED',
        );
      case 'LockedOut':
        return const ApiResponse.error(
          message: 'Biometric authentication is temporarily locked out',
          code: 'BIOMETRIC_LOCKED_OUT',
        );
      case 'PermanentlyLockedOut':
        return const ApiResponse.error(
          message: 'Biometric authentication is permanently locked out',
          code: 'BIOMETRIC_PERMANENTLY_LOCKED_OUT',
        );
      case 'UserCancel':
        return const ApiResponse.error(
          message: 'Authentication was cancelled by user',
          code: 'USER_CANCELLED',
        );
      case 'UserFallback':
        return const ApiResponse.error(
          message: 'User chose to use fallback authentication',
          code: 'USER_FALLBACK',
        );
      case 'BiometricOnlyNotSupported':
        return const ApiResponse.error(
          message: 'Biometric-only authentication is not supported',
          code: 'BIOMETRIC_ONLY_NOT_SUPPORTED',
        );
      case 'DeviceNotSupported':
        return const ApiResponse.error(
          message: 'This device does not support biometric authentication',
          code: 'DEVICE_NOT_SUPPORTED',
        );
      default:
        return ApiResponse.error(
          message: 'Biometric authentication error: ${e.message}',
          code: e.code,
          originalError: e,
        );
    }
  }
}

/// Biometric availability information
class BiometricAvailability {
  final bool isAvailable;
  final String? reason;
  final List<BiometricType>? availableBiometrics;

  const BiometricAvailability({
    required this.isAvailable,
    this.reason,
    this.availableBiometrics,
  });

  @override
  String toString() {
    return 'BiometricAvailability(isAvailable: $isAvailable, reason: $reason, '
        'availableBiometrics: $availableBiometrics)';
  }
}

/// Complete biometric status
class BiometricStatus {
  final bool isDeviceSupported;
  final bool isAppEnabled;
  final List<BiometricType>? availableBiometrics;
  final String? message;

  const BiometricStatus({
    required this.isDeviceSupported,
    required this.isAppEnabled,
    this.availableBiometrics,
    this.message,
  });

  bool get canUse => isDeviceSupported && isAppEnabled;
  bool get needsSetup => isDeviceSupported && !isAppEnabled;

  @override
  String toString() {
    return 'BiometricStatus(isDeviceSupported: $isDeviceSupported, '
        'isAppEnabled: $isAppEnabled, availableBiometrics: $availableBiometrics, '
        'message: $message)';
  }
}

/// Biometric authentication result
class BiometricAuthResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;

  const BiometricAuthResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
  });

  const BiometricAuthResult.success() : this(success: true);

  const BiometricAuthResult.failure({
    required String errorMessage,
    String? errorCode,
  }) : this(
          success: false,
          errorMessage: errorMessage,
          errorCode: errorCode,
        );

  @override
  String toString() {
    return 'BiometricAuthResult(success: $success, errorMessage: $errorMessage, '
        'errorCode: $errorCode)';
  }
}