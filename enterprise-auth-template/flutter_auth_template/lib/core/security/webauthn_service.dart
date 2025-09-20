import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';

final webAuthnServiceProvider = Provider<WebAuthnService>((ref) {
  return WebAuthnService();
});

class WebAuthnService {
  static const MethodChannel _channel = MethodChannel(
    'enterprise_auth/webauthn',
  );

  /// Check if WebAuthn/Passkeys are supported on this device
  Future<bool> isSupported() async {
    try {
      final bool supported =
          await _channel.invokeMethod('isSupported') ?? false;
      developer.log('WebAuthn supported: $supported', name: 'WebAuthnService');
      return supported;
    } on PlatformException catch (e) {
      developer.log(
        'WebAuthn support check failed: $e',
        name: 'WebAuthnService',
        level: 1000,
      );
      return false;
    }
  }

  /// Check if platform authenticator is available (Face ID, Touch ID, etc.)
  Future<bool> isPlatformAuthenticatorAvailable() async {
    try {
      final bool available =
          await _channel.invokeMethod('isPlatformAuthenticatorAvailable') ??
          false;
      developer.log(
        'Platform authenticator available: $available',
        name: 'WebAuthnService',
      );
      return available;
    } on PlatformException catch (e) {
      developer.log(
        'Platform authenticator check failed: $e',
        name: 'WebAuthnService',
        level: 1000,
      );
      return false;
    }
  }

  /// Create a new passkey (registration)
  Future<PasskeyRegistrationResult> createPasskey({
    required String challenge,
    required Map<String, dynamic> publicKeyCredentialCreationOptions,
  }) async {
    try {
      // Check if WebAuthn is supported
      if (!await isSupported()) {
        throw const PasskeyNotSupportedException();
      }

      developer.log('Starting passkey creation', name: 'WebAuthnService');

      final Map<String, dynamic> options = {
        'challenge': challenge,
        'publicKeyCredentialCreationOptions':
            publicKeyCredentialCreationOptions,
      };

      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'createPasskey',
        options,
      );

      final passkeyResult = PasskeyRegistrationResult.fromMap(
        Map<String, dynamic>.from(result),
      );

      developer.log('Passkey creation successful', name: 'WebAuthnService');
      return passkeyResult;
    } on PlatformException catch (e) {
      developer.log(
        'Passkey creation platform error: $e',
        name: 'WebAuthnService',
        level: 1000,
      );
      throw _handleWebAuthnError(e);
    } catch (e) {
      developer.log(
        'Passkey creation error: $e',
        name: 'WebAuthnService',
        level: 1000,
      );
      if (e is PasskeyException) rethrow;
      throw const PasskeyCreationFailedException();
    }
  }

  /// Authenticate with passkey
  Future<PasskeyAuthenticationResult> authenticateWithPasskey({
    required String challenge,
    required Map<String, dynamic> publicKeyCredentialRequestOptions,
  }) async {
    try {
      // Check if WebAuthn is supported
      if (!await isSupported()) {
        throw const PasskeyNotSupportedException();
      }

      developer.log('Starting passkey authentication', name: 'WebAuthnService');

      final Map<String, dynamic> options = {
        'challenge': challenge,
        'publicKeyCredentialRequestOptions': publicKeyCredentialRequestOptions,
      };

      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'authenticateWithPasskey',
        options,
      );

      final authResult = PasskeyAuthenticationResult.fromMap(
        Map<String, dynamic>.from(result),
      );

      developer.log(
        'Passkey authentication successful',
        name: 'WebAuthnService',
      );
      return authResult;
    } on PlatformException catch (e) {
      developer.log(
        'Passkey authentication platform error: $e',
        name: 'WebAuthnService',
        level: 1000,
      );
      throw _handleWebAuthnError(e);
    } catch (e) {
      developer.log(
        'Passkey authentication error: $e',
        name: 'WebAuthnService',
        level: 1000,
      );
      if (e is PasskeyException) rethrow;
      throw const PasskeyAuthenticationFailedException();
    }
  }

  /// Get platform authenticator info (Face ID, Touch ID, etc.)
  Future<PlatformAuthenticatorInfo> getPlatformAuthenticatorInfo() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'getPlatformAuthenticatorInfo',
      );

      return PlatformAuthenticatorInfo.fromMap(
        Map<String, dynamic>.from(result),
      );
    } on PlatformException catch (e) {
      developer.log(
        'Get platform authenticator info failed: $e',
        name: 'WebAuthnService',
        level: 1000,
      );
      return const PlatformAuthenticatorInfo(
        isAvailable: false,
        authenticatorType: AuthenticatorType.none,
        displayName: 'Not Available',
      );
    }
  }

  /// Cancel ongoing WebAuthn operation
  Future<void> cancelOperation() async {
    try {
      await _channel.invokeMethod('cancelOperation');
      developer.log('WebAuthn operation canceled', name: 'WebAuthnService');
    } on PlatformException catch (e) {
      developer.log(
        'Cancel WebAuthn operation failed: $e',
        name: 'WebAuthnService',
        level: 1000,
      );
    }
  }

  /// Utility Methods

  /// Generate client data JSON for WebAuthn
  Map<String, dynamic> generateClientDataJSON({
    required String type,
    required String challenge,
    required String origin,
  }) {
    return {
      'type': type,
      'challenge': challenge,
      'origin': origin,
      'crossOrigin': false,
    };
  }

  /// Create SHA-256 hash of data
  Uint8List sha256Hash(List<int> data) {
    final digest = sha256.convert(data);
    return Uint8List.fromList(digest.bytes);
  }

  /// Base64URL encode without padding
  String base64UrlEncode(List<int> data) {
    return base64Url.encode(data).replaceAll('=', '');
  }

  /// Base64URL decode
  Uint8List base64UrlDecode(String data) {
    // Add padding if necessary
    String padded = data;
    while (padded.length % 4 != 0) {
      padded += '=';
    }
    return base64Url.decode(padded);
  }

  /// Private helper method to handle WebAuthn errors
  PasskeyException _handleWebAuthnError(PlatformException error) {
    final String code = error.code;
    final String? message = error.message;

    switch (code) {
      case 'NOT_SUPPORTED':
        return const PasskeyNotSupportedException();
      case 'USER_CANCELED':
      case 'CANCELED':
        return const PasskeyException('Passkey operation was canceled');
      case 'TIMEOUT':
        return const PasskeyException('Passkey operation timed out');
      case 'NOT_ALLOWED':
        return const PasskeyException('Passkey operation not allowed');
      case 'INVALID_STATE':
        return const PasskeyException('Invalid state for passkey operation');
      case 'UNKNOWN_ERROR':
      default:
        return PasskeyException(message ?? 'Passkey operation failed');
    }
  }
}

/// Platform authenticator information
class PlatformAuthenticatorInfo {
  final bool isAvailable;
  final AuthenticatorType authenticatorType;
  final String displayName;
  final String? icon;

  const PlatformAuthenticatorInfo({
    required this.isAvailable,
    required this.authenticatorType,
    required this.displayName,
    this.icon,
  });

  factory PlatformAuthenticatorInfo.fromMap(Map<String, dynamic> map) {
    return PlatformAuthenticatorInfo(
      isAvailable: map['isAvailable'] ?? false,
      authenticatorType: AuthenticatorType.fromString(map['authenticatorType']),
      displayName: map['displayName'] ?? 'Unknown',
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAvailable': isAvailable,
      'authenticatorType': authenticatorType.toString(),
      'displayName': displayName,
      'icon': icon,
    };
  }
}

/// Authenticator type enum
enum AuthenticatorType {
  none,
  faceId,
  touchId,
  fingerprint,
  pin,
  securityKey,
  other;

  static AuthenticatorType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'faceid':
      case 'face_id':
        return AuthenticatorType.faceId;
      case 'touchid':
      case 'touch_id':
        return AuthenticatorType.touchId;
      case 'fingerprint':
        return AuthenticatorType.fingerprint;
      case 'pin':
        return AuthenticatorType.pin;
      case 'security_key':
      case 'securitykey':
        return AuthenticatorType.securityKey;
      case 'other':
        return AuthenticatorType.other;
      default:
        return AuthenticatorType.none;
    }
  }

  String get displayName {
    switch (this) {
      case AuthenticatorType.faceId:
        return 'Face ID';
      case AuthenticatorType.touchId:
        return 'Touch ID';
      case AuthenticatorType.fingerprint:
        return 'Fingerprint';
      case AuthenticatorType.pin:
        return 'PIN';
      case AuthenticatorType.securityKey:
        return 'Security Key';
      case AuthenticatorType.other:
        return 'Other';
      case AuthenticatorType.none:
        return 'None';
    }
  }

  String get icon {
    switch (this) {
      case AuthenticatorType.faceId:
        return '👤';
      case AuthenticatorType.touchId:
      case AuthenticatorType.fingerprint:
        return '👆';
      case AuthenticatorType.pin:
        return '🔢';
      case AuthenticatorType.securityKey:
        return '🔑';
      case AuthenticatorType.other:
      case AuthenticatorType.none:
      default:
        return '🔐';
    }
  }
}

/// Passkey registration result
class PasskeyRegistrationResult {
  final String credentialId;
  final String publicKey;
  final String attestationObject;
  final String clientDataJSON;

  const PasskeyRegistrationResult({
    required this.credentialId,
    required this.publicKey,
    required this.attestationObject,
    required this.clientDataJSON,
  });

  factory PasskeyRegistrationResult.fromMap(Map<String, dynamic> map) {
    return PasskeyRegistrationResult(
      credentialId: map['credentialId'] ?? '',
      publicKey: map['publicKey'] ?? '',
      attestationObject: map['attestationObject'] ?? '',
      clientDataJSON: map['clientDataJSON'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'credentialId': credentialId,
      'publicKey': publicKey,
      'attestationObject': attestationObject,
      'clientDataJSON': clientDataJSON,
    };
  }
}

/// Passkey authentication result
class PasskeyAuthenticationResult {
  final String credentialId;
  final String authenticatorData;
  final String signature;
  final String clientDataJSON;
  final String? userHandle;

  const PasskeyAuthenticationResult({
    required this.credentialId,
    required this.authenticatorData,
    required this.signature,
    required this.clientDataJSON,
    this.userHandle,
  });

  factory PasskeyAuthenticationResult.fromMap(Map<String, dynamic> map) {
    return PasskeyAuthenticationResult(
      credentialId: map['credentialId'] ?? '',
      authenticatorData: map['authenticatorData'] ?? '',
      signature: map['signature'] ?? '',
      clientDataJSON: map['clientDataJSON'] ?? '',
      userHandle: map['userHandle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'credentialId': credentialId,
      'authenticatorData': authenticatorData,
      'signature': signature,
      'clientDataJSON': clientDataJSON,
      'userHandle': userHandle,
    };
  }
}
