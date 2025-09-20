import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_auth_template/core/errors/app_exception.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on this device
  Future<bool> isAvailable() async {
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) return false;

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return canCheckBiometrics;
    } catch (e) {
      developer.log(
        'Biometric availability check failed: $e',
        name: 'BiometricService',
        level: 1000,
      );
      return false;
    }
  }

  /// Get available biometric types on this device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      developer.log(
        'Get available biometrics failed: $e',
        name: 'BiometricService',
        level: 1000,
      );
      return [];
    }
  }

  /// Check if biometrics are enrolled on this device
  Future<bool> isBiometricEnrolled() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      developer.log(
        'Biometric enrollment check failed: $e',
        name: 'BiometricService',
        level: 1000,
      );
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access your account',
    bool biometricOnly = false,
    bool stickyAuth = true,
  }) async {
    try {
      // First check if device supports biometrics
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        throw const BiometricNotAvailableException();
      }

      // Then check if biometrics are enrolled
      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        throw const BiometricNotEnrolledException();
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          sensitiveTransaction: true,
        ),
      );

      if (didAuthenticate) {
        developer.log(
          'Biometric authentication successful',
          name: 'BiometricService',
        );
      } else {
        developer.log(
          'Biometric authentication failed',
          name: 'BiometricService',
        );
      }

      return didAuthenticate;
    } catch (e) {
      developer.log(
        'Biometric authentication error: $e',
        name: 'BiometricService',
        level: 1000,
      );

      // Handle specific local auth errors
      if (e is BiometricException) {
        rethrow;
      } else {
        throw _handleBiometricError(e);
      }
    }
  }

  /// Authenticate for login (with specific messaging)
  Future<bool> authenticateForLogin() async {
    return await authenticate(
      localizedReason: 'Use your fingerprint or face to sign in',
      biometricOnly: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for sensitive operations
  Future<bool> authenticateForSensitiveOperation(String operation) async {
    return await authenticate(
      localizedReason: 'Authenticate to $operation',
      biometricOnly: false,
      stickyAuth: true,
    );
  }

  /// Stop ongoing authentication
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      developer.log(
        'Stop authentication failed: $e',
        name: 'BiometricService',
        level: 1000,
      );
    }
  }

  /// Get user-friendly biometric type names
  String getBiometricTypeName(BiometricType type) {
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
  }

  /// Get available biometric names as a list
  Future<List<String>> getAvailableBiometricNames() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.map((type) => getBiometricTypeName(type)).toList();
  }

  /// Get primary biometric type (for UI display)
  Future<BiometricType?> getPrimaryBiometricType() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) return null;

    // Prioritize stronger biometric types
    if (biometrics.contains(BiometricType.face)) {
      return BiometricType.face;
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    } else if (biometrics.contains(BiometricType.strong)) {
      return BiometricType.strong;
    } else {
      return biometrics.first;
    }
  }

  /// Get appropriate icon for biometric type
  String getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return '👤'; // Face icon
      case BiometricType.fingerprint:
        return '👆'; // Fingerprint icon
      case BiometricType.iris:
        return '👁️'; // Eye icon
      default:
        return '🔐'; // Generic security icon
    }
  }

  /// Check if device supports specific biometric type
  Future<bool> supportsBiometricType(BiometricType type) async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(type);
  }

  /// Get biometric capability summary for UI
  Future<BiometricCapability> getBiometricCapability() async {
    try {
      // Check if device supports biometrics
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        return BiometricCapability.notAvailable;
      }

      // Check if biometrics are enrolled
      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return BiometricCapability.availableButNotEnrolled;
      }

      return BiometricCapability.availableAndEnrolled;
    } catch (e) {
      developer.log(
        'Error checking biometric capability: $e',
        name: 'BiometricService',
        level: 1000,
      );
      return BiometricCapability.notAvailable;
    }
  }

  /// Private helper method to handle biometric errors
  BiometricException _handleBiometricError(dynamic error) {
    if (error.toString().contains(auth_error.notAvailable) ||
        error.toString().contains('NotAvailable')) {
      return const BiometricNotAvailableException();
    } else if (error.toString().contains(auth_error.notEnrolled) ||
        error.toString().contains('NotEnrolled')) {
      return const BiometricNotEnrolledException();
    } else if (error.toString().contains('UserCancel') ||
        error.toString().contains('Canceled')) {
      return const BiometricException('Biometric authentication was canceled');
    } else if (error.toString().contains('Timeout')) {
      return const BiometricException('Biometric authentication timed out');
    } else if (error.toString().contains('TooManyAttempts')) {
      return const BiometricException(
        'Too many failed attempts. Please try again later',
      );
    } else if (error.toString().contains('LockedOut')) {
      return const BiometricException(
        'Biometric authentication is temporarily locked',
      );
    } else {
      return const BiometricAuthFailedException();
    }
  }
}

/// Enum representing biometric capability states
enum BiometricCapability {
  notAvailable,
  availableButNotEnrolled,
  availableAndEnrolled,
}

extension BiometricCapabilityExtension on BiometricCapability {
  String get description {
    switch (this) {
      case BiometricCapability.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricCapability.availableButNotEnrolled:
        return 'Biometric authentication is available but not set up';
      case BiometricCapability.availableAndEnrolled:
        return 'Biometric authentication is ready to use';
    }
  }

  bool get canAuthenticate => this == BiometricCapability.availableAndEnrolled;
}
