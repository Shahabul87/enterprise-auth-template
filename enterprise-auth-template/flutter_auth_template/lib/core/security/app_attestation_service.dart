import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_auth_template/core/network/api_response.dart';

// Provider for app attestation service
final appAttestationServiceProvider = Provider<AppAttestationService>((ref) {
  return AppAttestationService();
});

/// App Attestation Service
///
/// Provides device attestation using:
/// - Google SafetyNet API for Android
/// - DeviceCheck API for iOS
///
/// This ensures the app is running on a genuine device
/// and hasn't been tampered with.
class AppAttestationService {
  static const MethodChannel _channel = MethodChannel('app_attestation');

  // SafetyNet API key (should be stored securely in production)
  static const String _safetyNetApiKey = 'YOUR_SAFETY_NET_API_KEY';

  // Nonce length for attestation
  static const int _nonceLength = 32;

  /// Initialize attestation service
  Future<void> initialize() async {
    try {
      if (Platform.isAndroid) {
        await _initializeSafetyNet();
      } else if (Platform.isIOS) {
        await _initializeDeviceCheck();
      }
    } catch (e) {
      print('Failed to initialize attestation service: $e');
    }
  }

  /// Verify device attestation
  /// Returns true if device is genuine and app is untampered
  Future<AttestationResult> verifyAttestation({
    required String userId,
    String? challenge,
  }) async {
    try {
      // Generate nonce for attestation
      final nonce = _generateNonce(userId, challenge);

      if (Platform.isAndroid) {
        return await _verifySafetyNet(nonce);
      } else if (Platform.isIOS) {
        return await _verifyDeviceCheck(nonce);
      }

      // Unsupported platform, return neutral result
      return AttestationResult(
        isValid: true,
        platform: 'unsupported',
        message: 'Platform not supported for attestation',
      );
    } catch (e) {
      return AttestationResult(
        isValid: false,
        platform: Platform.operatingSystem,
        error: e.toString(),
        message: 'Attestation verification failed',
      );
    }
  }

  /// Initialize SafetyNet for Android
  Future<void> _initializeSafetyNet() async {
    try {
      await _channel.invokeMethod('initSafetyNet', {
        'apiKey': _safetyNetApiKey,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize SafetyNet: ${e.message}');
    }
  }

  /// Initialize DeviceCheck for iOS
  Future<void> _initializeDeviceCheck() async {
    try {
      final isSupported = await _channel.invokeMethod<bool>('isDeviceCheckSupported');
      if (!isSupported!) {
        throw Exception('DeviceCheck not supported on this device');
      }
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize DeviceCheck: ${e.message}');
    }
  }

  /// Verify using SafetyNet (Android)
  Future<AttestationResult> _verifySafetyNet(String nonce) async {
    try {
      final result = await _channel.invokeMethod<Map>('verifySafetyNet', {
        'nonce': nonce,
      });

      if (result == null) {
        throw Exception('SafetyNet returned null result');
      }

      // Parse SafetyNet response
      final basicIntegrity = result['basicIntegrity'] as bool? ?? false;
      final ctsProfileMatch = result['ctsProfileMatch'] as bool? ?? false;
      final evaluationType = result['evaluationType'] as String?;

      // Check if device passes SafetyNet checks
      final isValid = basicIntegrity && ctsProfileMatch;

      // Determine risk level
      String riskLevel = 'high';
      if (isValid) {
        riskLevel = 'low';
      } else if (basicIntegrity) {
        riskLevel = 'medium';
      }

      return AttestationResult(
        isValid: isValid,
        platform: 'android',
        basicIntegrity: basicIntegrity,
        ctsProfileMatch: ctsProfileMatch,
        evaluationType: evaluationType,
        riskLevel: riskLevel,
        message: isValid
          ? 'Device passed SafetyNet attestation'
          : 'Device failed SafetyNet attestation',
      );
    } on PlatformException catch (e) {
      return AttestationResult(
        isValid: false,
        platform: 'android',
        error: e.message,
        message: 'SafetyNet verification failed',
        riskLevel: 'high',
      );
    }
  }

  /// Verify using DeviceCheck (iOS)
  Future<AttestationResult> _verifyDeviceCheck(String nonce) async {
    try {
      // Generate device token
      final token = await _channel.invokeMethod<String>('generateDeviceToken');

      if (token == null || token.isEmpty) {
        throw Exception('Failed to generate device token');
      }

      // In production, this token should be sent to your server
      // for verification with Apple's DeviceCheck API
      // For now, we'll do a basic local verification

      final result = await _channel.invokeMethod<Map>('verifyDeviceToken', {
        'token': token,
        'nonce': nonce,
      });

      if (result == null) {
        throw Exception('DeviceCheck returned null result');
      }

      final isValid = result['isValid'] as bool? ?? false;
      final riskScore = result['riskScore'] as double? ?? 1.0;

      // Determine risk level based on score
      String riskLevel = 'high';
      if (riskScore < 0.3) {
        riskLevel = 'low';
      } else if (riskScore < 0.7) {
        riskLevel = 'medium';
      }

      return AttestationResult(
        isValid: isValid,
        platform: 'ios',
        deviceToken: token,
        riskScore: riskScore,
        riskLevel: riskLevel,
        message: isValid
          ? 'Device passed DeviceCheck attestation'
          : 'Device failed DeviceCheck attestation',
      );
    } on PlatformException catch (e) {
      return AttestationResult(
        isValid: false,
        platform: 'ios',
        error: e.message,
        message: 'DeviceCheck verification failed',
        riskLevel: 'high',
      );
    }
  }

  /// Generate nonce for attestation
  String _generateNonce(String userId, String? challenge) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$userId:$timestamp:${challenge ?? ''}';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return base64.encode(hash.bytes);
  }

  /// Check if attestation is supported on current device
  Future<bool> isAttestationSupported() async {
    try {
      if (Platform.isAndroid) {
        // SafetyNet is supported on most Android devices with Google Play Services
        return await _channel.invokeMethod<bool>('isSafetyNetAvailable') ?? false;
      } else if (Platform.isIOS) {
        // DeviceCheck is available on iOS 11+
        return await _channel.invokeMethod<bool>('isDeviceCheckSupported') ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get attestation requirements for current platform
  AttestationRequirements getRequirements() {
    if (Platform.isAndroid) {
      return AttestationRequirements(
        platform: 'android',
        method: 'SafetyNet',
        minimumOSVersion: '4.4',
        requiresGooglePlayServices: true,
        requiresInternet: true,
      );
    } else if (Platform.isIOS) {
      return AttestationRequirements(
        platform: 'ios',
        method: 'DeviceCheck',
        minimumOSVersion: '11.0',
        requiresGooglePlayServices: false,
        requiresInternet: true,
      );
    }

    return AttestationRequirements(
      platform: 'unsupported',
      method: 'none',
      minimumOSVersion: 'N/A',
      requiresGooglePlayServices: false,
      requiresInternet: false,
    );
  }

  /// Validate attestation result on server
  /// This should be called after local verification
  Future<ApiResponse<bool>> validateOnServer({
    required AttestationResult result,
    required String userId,
  }) async {
    // In production, send attestation result to your backend
    // for server-side validation
    try {
      // Simulated server validation
      // Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      if (result.isValid) {
        return const ApiResponse.success(data: true);
      } else {
        return const ApiResponse.error(
          message: 'Server validation failed: Device attestation invalid',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Server validation error: ${e.toString()}',
      );
    }
  }
}

/// Attestation result model
class AttestationResult {
  final bool isValid;
  final String platform;
  final String? error;
  final String message;
  final String? riskLevel;

  // Android SafetyNet specific
  final bool? basicIntegrity;
  final bool? ctsProfileMatch;
  final String? evaluationType;

  // iOS DeviceCheck specific
  final String? deviceToken;
  final double? riskScore;

  const AttestationResult({
    required this.isValid,
    required this.platform,
    this.error,
    required this.message,
    this.riskLevel,
    this.basicIntegrity,
    this.ctsProfileMatch,
    this.evaluationType,
    this.deviceToken,
    this.riskScore,
  });

  Map<String, dynamic> toJson() => {
    'isValid': isValid,
    'platform': platform,
    'error': error,
    'message': message,
    'riskLevel': riskLevel,
    'basicIntegrity': basicIntegrity,
    'ctsProfileMatch': ctsProfileMatch,
    'evaluationType': evaluationType,
    'deviceToken': deviceToken,
    'riskScore': riskScore,
  };
}

/// Attestation requirements for platform
class AttestationRequirements {
  final String platform;
  final String method;
  final String minimumOSVersion;
  final bool requiresGooglePlayServices;
  final bool requiresInternet;

  const AttestationRequirements({
    required this.platform,
    required this.method,
    required this.minimumOSVersion,
    required this.requiresGooglePlayServices,
    required this.requiresInternet,
  });
}