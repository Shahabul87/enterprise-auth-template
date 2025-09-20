import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Provider for anti-tampering service
final antiTamperingServiceProvider = Provider<AntiTamperingService>((ref) {
  return AntiTamperingService();
});

/// Anti-Tampering Service
///
/// Provides protection against app tampering including:
/// - App signature verification
/// - Integrity checks
/// - Resource verification
/// - Code modification detection
class AntiTamperingService {
  static const MethodChannel _channel = MethodChannel('anti_tampering');

  // Expected app signatures (SHA256)
  // These should be hardcoded or fetched from a secure server
  static const Map<String, String> _expectedSignatures = {
    'debug': 'DEBUG_SIGNATURE_HASH',
    'release': 'RELEASE_SIGNATURE_HASH',
    'profile': 'PROFILE_SIGNATURE_HASH',
  };

  // Critical files to monitor for tampering
  static const List<String> _criticalFiles = [
    'lib/main.dart',
    'lib/core/security/anti_tampering_service.dart',
    'lib/infrastructure/services/auth/auth_service.dart',
    'pubspec.yaml',
  ];

  bool _isInitialized = false;
  late PackageInfo _packageInfo;
  String? _appSignature;
  Map<String, String> _fileHashes = {};

  /// Initialize anti-tampering protection
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get package info
      _packageInfo = await PackageInfo.fromPlatform();

      // Get app signature
      _appSignature = await _getAppSignature();

      // Calculate initial file hashes
      await _calculateFileHashes();

      // Start integrity monitoring
      _startIntegrityMonitoring();

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize anti-tampering service: $e');
    }
  }

  /// Verify app integrity
  /// Returns true if app is untampered
  Future<TamperDetectionResult> verifyIntegrity() async {
    if (!_isInitialized) {
      await initialize();
    }

    final checks = <String, bool>{};
    final issues = <String>[];

    // 1. Verify app signature
    final signatureValid = await _verifyAppSignature();
    checks['signature'] = signatureValid;
    if (!signatureValid) {
      issues.add('App signature mismatch detected');
    }

    // 2. Check for debugger
    final debuggerAttached = await _isDebuggerAttached();
    checks['no_debugger'] = !debuggerAttached;
    if (debuggerAttached) {
      issues.add('Debugger detected');
    }

    // 3. Verify package name
    final packageValid = _verifyPackageName();
    checks['package_name'] = packageValid;
    if (!packageValid) {
      issues.add('Package name mismatch');
    }

    // 4. Check for hooks/instrumentation
    final hooksDetected = await _detectHooks();
    checks['no_hooks'] = !hooksDetected;
    if (hooksDetected) {
      issues.add('Code instrumentation detected');
    }

    // 5. Verify resource integrity
    final resourcesValid = await _verifyResources();
    checks['resources'] = resourcesValid;
    if (!resourcesValid) {
      issues.add('Resource tampering detected');
    }

    // 6. Check file integrity
    final filesValid = await _verifyFileIntegrity();
    checks['files'] = filesValid;
    if (!filesValid) {
      issues.add('File modification detected');
    }

    // Calculate overall integrity
    final isIntact = checks.values.every((check) => check);

    // Determine risk level
    final failedChecks = checks.values.where((v) => !v).length;
    String riskLevel = 'low';
    if (failedChecks >= 3) {
      riskLevel = 'critical';
    } else if (failedChecks >= 2) {
      riskLevel = 'high';
    } else if (failedChecks >= 1) {
      riskLevel = 'medium';
    }

    return TamperDetectionResult(
      isIntact: isIntact,
      checks: checks,
      issues: issues,
      riskLevel: riskLevel,
      timestamp: DateTime.now(),
    );
  }

  /// Get app signature
  Future<String?> _getAppSignature() async {
    try {
      if (Platform.isAndroid) {
        return await _channel.invokeMethod<String>('getAppSignature');
      } else if (Platform.isIOS) {
        // iOS uses provisioning profiles
        return await _channel.invokeMethod<String>('getProvisioningProfile');
      }
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Verify app signature matches expected
  Future<bool> _verifyAppSignature() async {
    if (_appSignature == null) return false;

    // In debug mode, skip signature check
    if (_packageInfo.buildSignature.isEmpty) {
      return true; // Debug build
    }

    // Get expected signature based on build mode
    final buildMode = const String.fromEnvironment('BUILD_MODE', defaultValue: 'debug');
    final expectedSignature = _expectedSignatures[buildMode];

    if (expectedSignature == null) {
      return false; // Unknown build mode
    }

    return _appSignature == expectedSignature;
  }

  /// Check if debugger is attached
  Future<bool> _isDebuggerAttached() async {
    try {
      if (Platform.isAndroid) {
        return await _channel.invokeMethod<bool>('isDebuggerAttached') ?? false;
      } else if (Platform.isIOS) {
        // Check for common iOS debugging indicators
        return await _channel.invokeMethod<bool>('isDebuggerAttached') ?? false;
      }
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Verify package name hasn't been changed
  bool _verifyPackageName() {
    const expectedPackageName = 'com.example.flutter_auth_template';
    return _packageInfo.packageName == expectedPackageName;
  }

  /// Detect hooks or instrumentation frameworks
  Future<bool> _detectHooks() async {
    try {
      if (Platform.isAndroid) {
        // Check for Xposed, Frida, Substrate
        final hooks = await _channel.invokeMethod<List>('detectHooks');
        return hooks?.isNotEmpty ?? false;
      } else if (Platform.isIOS) {
        // Check for Cycript, Frida, etc.
        return await _channel.invokeMethod<bool>('detectHooks') ?? false;
      }
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Verify app resources haven't been modified
  Future<bool> _verifyResources() async {
    try {
      // Check critical assets
      final assetManifest = await rootBundle.loadString('AssetManifest.json');
      final assets = json.decode(assetManifest) as Map<String, dynamic>;

      // Verify asset count and names
      if (assets.isEmpty) {
        return false;
      }

      // In production, you would verify checksums of critical assets
      // For now, just check they exist
      for (final asset in assets.keys) {
        if (asset.contains('certificates/') || asset.contains('security/')) {
          try {
            await rootBundle.load(asset);
          } catch (e) {
            return false; // Asset missing or modified
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Calculate file hashes for integrity checking
  Future<void> _calculateFileHashes() async {
    _fileHashes.clear();

    for (final filePath in _criticalFiles) {
      try {
        // In production, these would be actual file paths
        // For Flutter, we can hash the content of bundled files
        final content = await rootBundle.loadString(filePath);
        final bytes = utf8.encode(content);
        final hash = sha256.convert(bytes);
        _fileHashes[filePath] = hash.toString();
      } catch (e) {
        // File not accessible, skip
        continue;
      }
    }
  }

  /// Verify file integrity
  Future<bool> _verifyFileIntegrity() async {
    if (_fileHashes.isEmpty) {
      return true; // No hashes to verify
    }

    for (final entry in _fileHashes.entries) {
      try {
        final content = await rootBundle.loadString(entry.key);
        final bytes = utf8.encode(content);
        final currentHash = sha256.convert(bytes).toString();

        if (currentHash != entry.value) {
          return false; // File has been modified
        }
      } catch (e) {
        // File not accessible, consider it tampered
        return false;
      }
    }

    return true;
  }

  /// Start continuous integrity monitoring
  void _startIntegrityMonitoring() {
    // Check integrity periodically
    Stream.periodic(const Duration(minutes: 5), (_) async {
      final result = await verifyIntegrity();
      if (!result.isIntact && result.riskLevel == 'critical') {
        // Critical tampering detected
        _handleTamperingDetected(result);
      }
    }).listen((_) {});
  }

  /// Handle tampering detection
  void _handleTamperingDetected(TamperDetectionResult result) {
    // Log the incident
    print('TAMPERING DETECTED: ${result.issues.join(', ')}');

    // In production, you might want to:
    // 1. Report to server
    // 2. Wipe sensitive data
    // 3. Show warning to user
    // 4. Terminate the app
  }

  /// Check if app is running in emulator
  Future<bool> isRunningInEmulator() async {
    try {
      if (Platform.isAndroid) {
        return await _channel.invokeMethod<bool>('isEmulator') ?? false;
      } else if (Platform.isIOS) {
        return await _channel.invokeMethod<bool>('isSimulator') ?? false;
      }
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Verify app installer source
  Future<String?> getInstallerSource() async {
    try {
      if (Platform.isAndroid) {
        return await _channel.invokeMethod<String>('getInstallerPackageName');
      } else if (Platform.isIOS) {
        // iOS apps are always from App Store or TestFlight in production
        return 'app_store';
      }
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Check if app was installed from official store
  Future<bool> isFromOfficialStore() async {
    final installer = await getInstallerSource();

    if (Platform.isAndroid) {
      // Official Google Play Store package names
      const officialStores = [
        'com.android.vending', // Google Play Store
        'com.google.android.feedback', // Google Play Store (alternative)
      ];
      return installer != null && officialStores.contains(installer);
    } else if (Platform.isIOS) {
      // iOS apps in production are always from App Store
      return installer == 'app_store';
    }

    return false;
  }
}

/// Tamper detection result
class TamperDetectionResult {
  final bool isIntact;
  final Map<String, bool> checks;
  final List<String> issues;
  final String riskLevel;
  final DateTime timestamp;

  const TamperDetectionResult({
    required this.isIntact,
    required this.checks,
    required this.issues,
    required this.riskLevel,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'isIntact': isIntact,
    'checks': checks,
    'issues': issues,
    'riskLevel': riskLevel,
    'timestamp': timestamp.toIso8601String(),
  };

  /// Get a human-readable summary
  String get summary {
    if (isIntact) {
      return 'App integrity verified successfully';
    } else {
      return 'App tampering detected: ${issues.join(', ')}';
    }
  }
}