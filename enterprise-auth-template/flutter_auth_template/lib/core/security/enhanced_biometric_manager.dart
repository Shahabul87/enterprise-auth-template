import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../storage/secure_storage_service.dart';
import 'biometric_service.dart';
import '../errors/app_exception.dart';

final enhancedBiometricManagerProvider = Provider<EnhancedBiometricManager>((ref) {
  return EnhancedBiometricManager(
    biometricService: ref.read(biometricServiceProvider),
    storageService: ref.read(secureStorageServiceProvider),
  );
});

/// Configuration for biometric authentication
class BiometricConfig {
  final bool enabled;
  final bool requireForLogin;
  final bool requireForTransactions;
  final bool requireForViewingSensitiveData;
  final int maxAttempts;
  final Duration lockoutDuration;
  final DateTime? lastAuthTime;
  final int failedAttempts;
  final DateTime? lockedUntil;

  BiometricConfig({
    this.enabled = false,
    this.requireForLogin = false,
    this.requireForTransactions = true,
    this.requireForViewingSensitiveData = true,
    this.maxAttempts = 3,
    this.lockoutDuration = const Duration(minutes: 30),
    this.lastAuthTime,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'requireForLogin': requireForLogin,
    'requireForTransactions': requireForTransactions,
    'requireForViewingSensitiveData': requireForViewingSensitiveData,
    'maxAttempts': maxAttempts,
    'lockoutDurationMinutes': lockoutDuration.inMinutes,
    'lastAuthTime': lastAuthTime?.toIso8601String(),
    'failedAttempts': failedAttempts,
    'lockedUntil': lockedUntil?.toIso8601String(),
  };

  factory BiometricConfig.fromJson(Map<String, dynamic> json) {
    return BiometricConfig(
      enabled: json['enabled'] ?? false,
      requireForLogin: json['requireForLogin'] ?? false,
      requireForTransactions: json['requireForTransactions'] ?? true,
      requireForViewingSensitiveData: json['requireForViewingSensitiveData'] ?? true,
      maxAttempts: json['maxAttempts'] ?? 3,
      lockoutDuration: Duration(minutes: json['lockoutDurationMinutes'] ?? 30),
      lastAuthTime: json['lastAuthTime'] != null 
        ? DateTime.parse(json['lastAuthTime']) 
        : null,
      failedAttempts: json['failedAttempts'] ?? 0,
      lockedUntil: json['lockedUntil'] != null 
        ? DateTime.parse(json['lockedUntil']) 
        : null,
    );
  }

  BiometricConfig copyWith({
    bool? enabled,
    bool? requireForLogin,
    bool? requireForTransactions,
    bool? requireForViewingSensitiveData,
    int? maxAttempts,
    Duration? lockoutDuration,
    DateTime? lastAuthTime,
    int? failedAttempts,
    DateTime? lockedUntil,
  }) {
    return BiometricConfig(
      enabled: enabled ?? this.enabled,
      requireForLogin: requireForLogin ?? this.requireForLogin,
      requireForTransactions: requireForTransactions ?? this.requireForTransactions,
      requireForViewingSensitiveData: requireForViewingSensitiveData ?? this.requireForViewingSensitiveData,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      lockoutDuration: lockoutDuration ?? this.lockoutDuration,
      lastAuthTime: lastAuthTime ?? this.lastAuthTime,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }
}

/// Enhanced biometric manager with advanced features
class EnhancedBiometricManager {
  final BiometricService biometricService;
  final SecureStorageService storageService;
  
  static const String _configKey = 'biometric_config';
  static const String _biometricTokenKey = 'biometric_token';
  static const String _fallbackPinKey = 'fallback_pin';
  
  BiometricConfig? _config;
  Timer? _sessionTimer;
  
  EnhancedBiometricManager({
    required this.biometricService,
    required this.storageService,
  });

  /// Initialize biometric configuration
  Future<void> initialize() async {
    try {
      final configJson = await storageService.read(_configKey);
      if (configJson != null) {
        _config = BiometricConfig.fromJson(jsonDecode(configJson));
      } else {
        _config = BiometricConfig();
      }
    } catch (e) {
      _config = BiometricConfig();
    }
  }

  /// Get current biometric configuration
  BiometricConfig get config => _config ?? BiometricConfig();

  /// Enable biometric authentication
  Future<bool> enableBiometric({
    required String reason,
    String? fallbackPin,
  }) async {
    try {
      // Check if biometrics are available
      final capability = await biometricService.getBiometricCapability();
      if (!capability.canAuthenticate) {
        throw BiometricException(capability.description);
      }

      // Authenticate to enable biometrics
      final authenticated = await biometricService.authenticate(
        localizedReason: reason,
        biometricOnly: false,
      );

      if (!authenticated) {
        return false;
      }

      // Generate biometric token
      final token = _generateBiometricToken();
      await storageService.write(_biometricTokenKey, token);

      // Save fallback PIN if provided
      if (fallbackPin != null && fallbackPin.isNotEmpty) {
        await _saveFallbackPin(fallbackPin);
      }

      // Update configuration
      _config = config.copyWith(
        enabled: true,
        lastAuthTime: DateTime.now(),
      );
      await _saveConfig();

      return true;
    } catch (e) {
      throw BiometricException('Failed to enable biometric: $e');
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometric({required String reason}) async {
    try {
      // Require authentication to disable
      final authenticated = await authenticateWithBiometric(
        reason: reason,
        allowFallback: true,
      );

      if (!authenticated) {
        return false;
      }

      // Clear biometric data
      await storageService.delete(_biometricTokenKey);
      await storageService.delete(_fallbackPinKey);

      // Update configuration
      _config = BiometricConfig(enabled: false);
      await _saveConfig();

      return true;
    } catch (e) {
      throw BiometricException('Failed to disable biometric: $e');
    }
  }

  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric({
    required String reason,
    bool allowFallback = false,
    Duration? sessionDuration,
  }) async {
    // Check if locked out
    if (_isLockedOut()) {
      final remaining = config.lockedUntil!.difference(DateTime.now());
      throw BiometricException(
        'Too many failed attempts. Try again in ${remaining.inMinutes} minutes',
      );
    }

    try {
      // Attempt biometric authentication
      final authenticated = await biometricService.authenticate(
        localizedReason: reason,
        biometricOnly: !allowFallback,
      );

      if (authenticated) {
        // Reset failed attempts
        _config = config.copyWith(
          failedAttempts: 0,
          lastAuthTime: DateTime.now(),
          lockedUntil: null,
        );
        await _saveConfig();

        // Start session if duration specified
        if (sessionDuration != null) {
          _startBiometricSession(sessionDuration);
        }

        return true;
      } else {
        // Increment failed attempts
        await _handleFailedAttempt();
        return false;
      }
    } catch (e) {
      await _handleFailedAttempt();
      rethrow;
    }
  }

  /// Authenticate with fallback PIN
  Future<bool> authenticateWithPin(String pin) async {
    if (_isLockedOut()) {
      throw BiometricException('Too many failed attempts');
    }

    try {
      final savedPin = await storageService.read(_fallbackPinKey);
      if (savedPin == null) {
        throw BiometricException('Fallback PIN not configured');
      }

      // Simple comparison (in production, use proper hashing)
      if (pin == savedPin) {
        _config = config.copyWith(
          failedAttempts: 0,
          lastAuthTime: DateTime.now(),
          lockedUntil: null,
        );
        await _saveConfig();
        return true;
      } else {
        await _handleFailedAttempt();
        return false;
      }
    } catch (e) {
      await _handleFailedAttempt();
      rethrow;
    }
  }

  /// Check if biometric session is active
  bool isSessionActive() {
    if (config.lastAuthTime == null) return false;
    
    // Default session duration is 5 minutes
    const sessionDuration = Duration(minutes: 5);
    final elapsed = DateTime.now().difference(config.lastAuthTime!);
    
    return elapsed < sessionDuration;
  }

  /// Update biometric settings
  Future<void> updateSettings({
    bool? requireForLogin,
    bool? requireForTransactions,
    bool? requireForViewingSensitiveData,
    int? maxAttempts,
    Duration? lockoutDuration,
  }) async {
    _config = config.copyWith(
      requireForLogin: requireForLogin,
      requireForTransactions: requireForTransactions,
      requireForViewingSensitiveData: requireForViewingSensitiveData,
      maxAttempts: maxAttempts,
      lockoutDuration: lockoutDuration,
    );
    await _saveConfig();
  }

  /// Reset biometric configuration
  Future<void> reset() async {
    await storageService.delete(_configKey);
    await storageService.delete(_biometricTokenKey);
    await storageService.delete(_fallbackPinKey);
    _config = BiometricConfig();
    _sessionTimer?.cancel();
  }

  /// Get biometric status summary
  Future<Map<String, dynamic>> getBiometricStatus() async {
    final capability = await biometricService.getBiometricCapability();
    final availableTypes = await biometricService.getAvailableBiometricNames();
    final primaryType = await biometricService.getPrimaryBiometricType();
    
    return {
      'enabled': config.enabled,
      'capability': capability.description,
      'canAuthenticate': capability.canAuthenticate,
      'availableTypes': availableTypes,
      'primaryType': primaryType != null 
        ? biometricService.getBiometricTypeName(primaryType)
        : null,
      'isLockedOut': _isLockedOut(),
      'failedAttempts': config.failedAttempts,
      'requireForLogin': config.requireForLogin,
      'requireForTransactions': config.requireForTransactions,
      'sessionActive': isSessionActive(),
    };
  }

  /// Private helper methods
  
  bool _isLockedOut() {
    if (config.lockedUntil == null) return false;
    return DateTime.now().isBefore(config.lockedUntil!);
  }

  Future<void> _handleFailedAttempt() async {
    final newFailedAttempts = config.failedAttempts + 1;
    
    if (newFailedAttempts >= config.maxAttempts) {
      // Lock out user
      _config = config.copyWith(
        failedAttempts: newFailedAttempts,
        lockedUntil: DateTime.now().add(config.lockoutDuration),
      );
    } else {
      _config = config.copyWith(failedAttempts: newFailedAttempts);
    }
    
    await _saveConfig();
  }

  Future<void> _saveConfig() async {
    if (_config != null) {
      await storageService.write(
        _configKey,
        jsonEncode(_config!.toJson()),
      );
    }
  }

  Future<void> _saveFallbackPin(String pin) async {
    // In production, hash the PIN before storing
    await storageService.write(_fallbackPinKey, pin);
  }

  String _generateBiometricToken() {
    // Generate a secure random token
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return base64Encode(utf8.encode('$timestamp:$random'));
  }

  void _startBiometricSession(Duration duration) {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(duration, () {
      // Session expired, require re-authentication
      _config = config.copyWith(lastAuthTime: null);
      _saveConfig();
    });
  }

  void dispose() {
    _sessionTimer?.cancel();
  }
}

/// Biometric authentication state for UI
class BiometricAuthState {
  final bool isEnabled;
  final bool isAuthenticated;
  final bool isLockedOut;
  final DateTime? lockedUntil;
  final int remainingAttempts;
  final BiometricType? primaryBiometric;

  BiometricAuthState({
    required this.isEnabled,
    required this.isAuthenticated,
    required this.isLockedOut,
    this.lockedUntil,
    required this.remainingAttempts,
    this.primaryBiometric,
  });
}