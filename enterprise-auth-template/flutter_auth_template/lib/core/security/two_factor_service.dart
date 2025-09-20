import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_auth_template/core/errors/app_exception.dart';

final twoFactorServiceProvider = Provider<TwoFactorService>((ref) {
  return TwoFactorService();
});

class TwoFactorService {
  /// Generate QR code URL for TOTP setup
  String generateQRCodeUrl({
    required String secret,
    required String accountName,
    required String issuer,
  }) {
    final String encodedAccountName = Uri.encodeComponent(accountName);
    final String encodedIssuer = Uri.encodeComponent(issuer);
    final String encodedSecret = Uri.encodeComponent(secret);

    final String url =
        'otpauth://totp/$encodedIssuer:$encodedAccountName'
        '?secret=$encodedSecret'
        '&issuer=$encodedIssuer'
        '&algorithm=SHA1'
        '&digits=6'
        '&period=30';

    developer.log(
      'Generated TOTP QR URL for: $accountName',
      name: 'TwoFactorService',
    );
    return url;
  }

  /// Validate TOTP code
  bool validateTOTPCode(String secret, String code, {int window = 1}) {
    try {
      final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final int timeStep = currentTime ~/ 30; // 30 second time step

      // Check current time step and adjacent windows
      for (int i = -window; i <= window; i++) {
        final int testTimeStep = timeStep + i;
        final String expectedCode = _generateTOTPCode(secret, testTimeStep);

        if (expectedCode == code) {
          developer.log(
            'TOTP code validated successfully',
            name: 'TwoFactorService',
          );
          return true;
        }
      }

      developer.log('TOTP code validation failed', name: 'TwoFactorService');
      return false;
    } catch (e) {
      developer.log(
        'TOTP validation error: $e',
        name: 'TwoFactorService',
        level: 1000,
      );
      return false;
    }
  }

  /// Generate current TOTP code (for testing purposes)
  String getCurrentTOTPCode(String secret) {
    final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int timeStep = currentTime ~/ 30;
    return _generateTOTPCode(secret, timeStep);
  }

  /// Get remaining seconds until next TOTP code
  int getSecondsUntilNextCode() {
    final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return 30 - (currentTime % 30);
  }

  /// Generate backup codes
  List<String> generateBackupCodes({int count = 10, int length = 8}) {
    final List<String> codes = [];

    for (int i = 0; i < count; i++) {
      codes.add(_generateBackupCode(length));
    }

    developer.log('Generated $count backup codes', name: 'TwoFactorService');
    return codes;
  }

  /// Validate backup code format
  bool isValidBackupCodeFormat(String code) {
    // Backup codes should be 8 characters, alphanumeric
    final RegExp pattern = RegExp(r'^[A-Z0-9]{8}$');
    return pattern.hasMatch(code.toUpperCase().replaceAll('-', ''));
  }

  /// Format backup code for display (add dashes for readability)
  String formatBackupCode(String code) {
    if (code.length == 8) {
      return '${code.substring(0, 4)}-${code.substring(4, 8)}';
    }
    return code;
  }

  /// Parse backup code from user input (remove formatting)
  String parseBackupCode(String input) {
    return input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  /// Check if input looks like a backup code vs TOTP code
  bool isBackupCode(String input) {
    final String cleaned = parseBackupCode(input);
    return cleaned.length == 8 && isValidBackupCodeFormat(cleaned);
  }

  /// Check if input looks like a TOTP code
  bool isTOTPCode(String input) {
    final RegExp pattern = RegExp(r'^\d{6}$');
    return pattern.hasMatch(input.trim());
  }

  /// Validate and classify 2FA input
  TwoFactorInputType classifyInput(String input) {
    final String trimmed = input.trim();

    if (isTOTPCode(trimmed)) {
      return TwoFactorInputType.totpCode;
    } else if (isBackupCode(trimmed)) {
      return TwoFactorInputType.backupCode;
    } else {
      return TwoFactorInputType.invalid;
    }
  }

  /// Get user-friendly instructions for 2FA setup
  String getSetupInstructions(String appName) {
    return '''
1. Install an authenticator app like Google Authenticator, Authy, or Microsoft Authenticator
2. Scan the QR code below with your authenticator app
3. Enter the 6-digit code from your authenticator app to complete setup
4. Save your backup codes in a secure location

Your authenticator app will generate a new 6-digit code every 30 seconds.
''';
  }

  /// Get supported authenticator apps
  List<AuthenticatorApp> getSupportedAuthenticatorApps() {
    return [
      const AuthenticatorApp(
        name: 'Google Authenticator',
        description: 'Free app by Google with offline support',
        platforms: ['iOS', 'Android'],
        downloadUrls: {
          'ios': 'https://apps.apple.com/app/google-authenticator/id388497605',
          'android':
              'https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2',
        },
      ),
      const AuthenticatorApp(
        name: 'Microsoft Authenticator',
        description: 'Microsoft\'s authenticator with cloud backup',
        platforms: ['iOS', 'Android'],
        downloadUrls: {
          'ios':
              'https://apps.apple.com/app/microsoft-authenticator/id983156458',
          'android':
              'https://play.google.com/store/apps/details?id=com.azure.authenticator',
        },
      ),
      const AuthenticatorApp(
        name: 'Authy',
        description: 'Multi-device authenticator with cloud sync',
        platforms: ['iOS', 'Android', 'Desktop'],
        downloadUrls: {
          'ios': 'https://apps.apple.com/app/authy/id494168017',
          'android':
              'https://play.google.com/store/apps/details?id=com.authy.authy',
        },
      ),
      const AuthenticatorApp(
        name: '1Password',
        description: 'Password manager with built-in TOTP',
        platforms: ['iOS', 'Android', 'Desktop'],
        downloadUrls: {
          'ios':
              'https://apps.apple.com/app/1password-7-password-manager/id1333542190',
          'android':
              'https://play.google.com/store/apps/details?id=com.onepassword.android',
        },
      ),
    ];
  }

  // Private helper methods

  /// Generate TOTP code for a specific time step
  String _generateTOTPCode(String secret, int timeStep) {
    try {
      // Convert base32 secret to bytes
      final Uint8List secretBytes = _base32Decode(secret);

      // Convert time step to 8-byte big-endian
      final ByteData timeBytes = ByteData(8);
      timeBytes.setInt64(0, timeStep, Endian.big);

      // HMAC-SHA1
      final Hmac hmac = Hmac(sha1, secretBytes);
      final Digest digest = hmac.convert(timeBytes.buffer.asUint8List());
      final Uint8List hash = Uint8List.fromList(digest.bytes);

      // Dynamic truncation
      final int offset = hash[19] & 0x0F;
      final int code =
          ((hash[offset] & 0x7F) << 24) |
          ((hash[offset + 1] & 0xFF) << 16) |
          ((hash[offset + 2] & 0xFF) << 8) |
          (hash[offset + 3] & 0xFF);

      // Generate 6-digit code
      final String totpCode = (code % 1000000).toString().padLeft(6, '0');
      return totpCode;
    } catch (e) {
      developer.log(
        'TOTP code generation error: $e',
        name: 'TwoFactorService',
        level: 1000,
      );
      throw const UnknownException('Failed to generate TOTP code', null);
    }
  }

  /// Generate a random backup code
  String _generateBackupCode(int length) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      final int index = DateTime.now().millisecondsSinceEpoch % chars.length;
      buffer.write(chars[index]);
    }

    return buffer.toString();
  }

  /// Base32 decode (simplified implementation)
  Uint8List _base32Decode(String input) {
    // Remove any whitespace and convert to uppercase
    final String clean = input.replaceAll(RegExp(r'\s'), '').toUpperCase();

    // Base32 alphabet
    const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

    final List<int> decoded = [];
    int bits = 0;
    int value = 0;

    for (int i = 0; i < clean.length; i++) {
      final String char = clean[i];
      if (char == '=') break; // Padding

      final int index = alphabet.indexOf(char);
      if (index == -1) {
        throw const ValidationException(
          'Invalid base32 character',
          null,
          'INVALID_BASE32',
          null,
        );
      }

      value = (value << 5) | index;
      bits += 5;

      if (bits >= 8) {
        decoded.add((value >> (bits - 8)) & 0xFF);
        bits -= 8;
      }
    }

    return Uint8List.fromList(decoded);
  }
}

/// Two-factor input classification
enum TwoFactorInputType { totpCode, backupCode, invalid }

/// Authenticator app information
class AuthenticatorApp {
  final String name;
  final String description;
  final List<String> platforms;
  final Map<String, String> downloadUrls;

  const AuthenticatorApp({
    required this.name,
    required this.description,
    required this.platforms,
    required this.downloadUrls,
  });

  String? getDownloadUrl(String platform) {
    return downloadUrls[platform.toLowerCase()];
  }

  bool supportsPlatform(String platform) {
    return platforms.any((p) => p.toLowerCase() == platform.toLowerCase());
  }
}
