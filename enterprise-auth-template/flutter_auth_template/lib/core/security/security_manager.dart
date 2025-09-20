import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/security/app_attestation_service.dart';
import 'package:flutter_auth_template/core/security/anti_tampering_service.dart';
import 'package:flutter_auth_template/core/security/rasp_service.dart';
import 'package:flutter_auth_template/core/security/device_security.dart';
import 'package:flutter_auth_template/core/security/security_event_logger.dart';

// Provider for security manager
final securityManagerProvider = Provider<SecurityManager>((ref) {
  final attestation = ref.watch(appAttestationServiceProvider);
  final antiTampering = ref.watch(antiTamperingServiceProvider);
  final rasp = ref.watch(raspServiceProvider);
  final eventLogger = ref.watch(securityEventLoggerProvider);

  return SecurityManager(
    attestation: attestation,
    antiTampering: antiTampering,
    rasp: rasp,
    eventLogger: eventLogger,
  );
});

/// Security Manager
///
/// Central management for all security features.
/// Coordinates between different security services and provides
/// a unified interface for security operations.
class SecurityManager {
  final AppAttestationService attestation;
  final AntiTamperingService antiTampering;
  final RASPService rasp;
  final SecurityEventLogger eventLogger;

  // Security configuration
  late SecurityConfiguration _config;
  bool _isInitialized = false;

  // Security status
  SecurityStatus _status = SecurityStatus.unknown;

  SecurityManager({
    required this.attestation,
    required this.antiTampering,
    required this.rasp,
    required this.eventLogger,
  });

  /// Initialize security manager with configuration
  Future<void> initialize({
    SecurityConfiguration? config,
  }) async {
    if (_isInitialized) return;

    _config = config ?? SecurityConfiguration.production();

    try {
      // Initialize all security services based on configuration
      if (_config.enableAttestation) {
        await attestation.initialize();
      }

      if (_config.enableAntiTampering) {
        await antiTampering.initialize();
      }

      if (_config.enableRASP) {
        await rasp.initialize(
          enableDebuggerDetection: _config.enableDebuggerDetection,
          enableHookDetection: _config.enableHookDetection,
          enableMemoryProtection: _config.enableMemoryProtection,
          onViolation: (violation) {
            _handleSecurityViolation(violation);
          },
        );
      }

      // Event logger doesn't need initialization

      // Perform initial security check
      await performSecurityCheck();

      _isInitialized = true;

      // Log initialization
      await eventLogger.logEvent(
        type: SecurityEventType.suspiciousActivity,
        severity: SecurityEventSeverity.info,
        description: 'Security manager initialized',
        metadata: {
          'config': _config.toJson(),
        },
      );
    } catch (e) {
      await eventLogger.logEvent(
        type: SecurityEventType.suspiciousActivity,
        severity: SecurityEventSeverity.high,
        description: 'Failed to initialize security manager',
        metadata: {
          'error': e.toString(),
        },
      );
      rethrow;
    }
  }

  /// Perform comprehensive security check
  Future<SecurityCheckResult> performSecurityCheck() async {
    final checks = <String, bool>{};
    final issues = <String>[];
    int score = 100;

    // 1. Check device security
    if (_config.checkDeviceSecurity) {
      final isCompromised = await DeviceSecurity.isDeviceCompromised();
      checks['device_secure'] = !isCompromised;
      if (isCompromised) {
        issues.add('Device is rooted or jailbroken');
        score -= 30;
      }
    }

    // 2. Verify app attestation
    if (_config.enableAttestation) {
      final attestationResult = await attestation.verifyAttestation(
        userId: 'system',
        challenge: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      checks['attestation'] = attestationResult.isValid;
      if (!attestationResult.isValid) {
        issues.add(attestationResult.message);
        score -= 25;
      }
    }

    // 3. Check app integrity
    if (_config.enableAntiTampering) {
      final integrityResult = await antiTampering.verifyIntegrity();
      checks['integrity'] = integrityResult.isIntact;
      if (!integrityResult.isIntact) {
        issues.addAll(integrityResult.issues);
        score -= 25;
      }
    }

    // 4. Check for emulator
    if (_config.blockEmulator) {
      final isEmulator = await antiTampering.isRunningInEmulator();
      checks['no_emulator'] = !isEmulator;
      if (isEmulator) {
        issues.add('App is running in emulator');
        score -= 10;
      }
    }

    // 5. Check app source
    if (_config.requireOfficialStore) {
      final isOfficial = await antiTampering.isFromOfficialStore();
      checks['official_store'] = isOfficial;
      if (!isOfficial) {
        issues.add('App not installed from official store');
        score -= 10;
      }
    }

    // Determine security status
    if (score >= 90) {
      _status = SecurityStatus.secure;
    } else if (score >= 70) {
      _status = SecurityStatus.warning;
    } else if (score >= 50) {
      _status = SecurityStatus.risk;
    } else {
      _status = SecurityStatus.critical;
    }

    // Log security check
    await eventLogger.logEvent(
      type: SecurityEventType.suspiciousActivity,
      severity: _getSeverityForStatus(_status),
      description: 'Security check completed',
      metadata: {
        'score': score,
        'status': _status.toString(),
        'checks': checks,
        'issues': issues,
      },
    );

    return SecurityCheckResult(
      status: _status,
      score: score,
      checks: checks,
      issues: issues,
      timestamp: DateTime.now(),
    );
  }

  /// Handle security violation from RASP
  void _handleSecurityViolation(SecurityViolation violation) {
    // Log violation
    eventLogger.logEvent(
      type: SecurityEventType.suspiciousActivity,
      severity: _mapViolationSeverity(violation.severity),
      description: violation.message,
      metadata: {
        'type': violation.type.toString(),
        'details': violation.details,
      },
    );

    // Take action based on configuration
    if (_config.strictMode && violation.severity == ViolationSeverity.critical) {
      // In strict mode, critical violations may terminate the app
      _handleCriticalViolation();
    }
  }

  /// Handle critical security violation
  void _handleCriticalViolation() {
    // Log critical event
    eventLogger.logEvent(
      type: SecurityEventType.suspiciousActivity,
      severity: SecurityEventSeverity.critical,
      description: 'Critical security violation - app termination required',
    );

    // In production, you might:
    // 1. Clear sensitive data
    // 2. Logout user
    // 3. Show security warning
    // 4. Terminate app

    // For now, just update status
    _status = SecurityStatus.critical;
  }

  /// Get current security status
  SecurityStatus get status => _status;

  /// Check if app is secure enough to proceed
  bool get isSecure => _status == SecurityStatus.secure || _status == SecurityStatus.warning;

  /// Get security score (0-100)
  Future<int> getSecurityScore() async {
    final result = await performSecurityCheck();
    return result.score;
  }

  /// Map violation severity to event severity
  SecurityEventSeverity _mapViolationSeverity(ViolationSeverity severity) {
    switch (severity) {
      case ViolationSeverity.low:
        return SecurityEventSeverity.low;
      case ViolationSeverity.medium:
        return SecurityEventSeverity.medium;
      case ViolationSeverity.high:
        return SecurityEventSeverity.high;
      case ViolationSeverity.critical:
        return SecurityEventSeverity.critical;
    }
  }

  /// Get severity for security status
  SecurityEventSeverity _getSeverityForStatus(SecurityStatus status) {
    switch (status) {
      case SecurityStatus.secure:
        return SecurityEventSeverity.info;
      case SecurityStatus.warning:
        return SecurityEventSeverity.low;
      case SecurityStatus.risk:
        return SecurityEventSeverity.medium;
      case SecurityStatus.critical:
        return SecurityEventSeverity.critical;
      case SecurityStatus.unknown:
        return SecurityEventSeverity.info;
    }
  }
}

/// Security configuration
class SecurityConfiguration {
  final bool enableAttestation;
  final bool enableAntiTampering;
  final bool enableRASP;
  final bool enableDebuggerDetection;
  final bool enableHookDetection;
  final bool enableMemoryProtection;
  final bool checkDeviceSecurity;
  final bool blockEmulator;
  final bool requireOfficialStore;
  final bool strictMode;

  const SecurityConfiguration({
    required this.enableAttestation,
    required this.enableAntiTampering,
    required this.enableRASP,
    required this.enableDebuggerDetection,
    required this.enableHookDetection,
    required this.enableMemoryProtection,
    required this.checkDeviceSecurity,
    required this.blockEmulator,
    required this.requireOfficialStore,
    required this.strictMode,
  });

  /// Production configuration (most secure)
  factory SecurityConfiguration.production() => const SecurityConfiguration(
    enableAttestation: true,
    enableAntiTampering: true,
    enableRASP: true,
    enableDebuggerDetection: true,
    enableHookDetection: true,
    enableMemoryProtection: true,
    checkDeviceSecurity: true,
    blockEmulator: true,
    requireOfficialStore: true,
    strictMode: true,
  );

  /// Development configuration (less restrictive)
  factory SecurityConfiguration.development() => const SecurityConfiguration(
    enableAttestation: false,
    enableAntiTampering: true,
    enableRASP: true,
    enableDebuggerDetection: false,  // Allow debugging
    enableHookDetection: false,
    enableMemoryProtection: true,
    checkDeviceSecurity: false,  // Allow rooted devices
    blockEmulator: false,  // Allow emulators
    requireOfficialStore: false,
    strictMode: false,
  );

  /// Testing configuration (minimal security)
  factory SecurityConfiguration.testing() => const SecurityConfiguration(
    enableAttestation: false,
    enableAntiTampering: false,
    enableRASP: false,
    enableDebuggerDetection: false,
    enableHookDetection: false,
    enableMemoryProtection: false,
    checkDeviceSecurity: false,
    blockEmulator: false,
    requireOfficialStore: false,
    strictMode: false,
  );

  Map<String, dynamic> toJson() => {
    'enableAttestation': enableAttestation,
    'enableAntiTampering': enableAntiTampering,
    'enableRASP': enableRASP,
    'enableDebuggerDetection': enableDebuggerDetection,
    'enableHookDetection': enableHookDetection,
    'enableMemoryProtection': enableMemoryProtection,
    'checkDeviceSecurity': checkDeviceSecurity,
    'blockEmulator': blockEmulator,
    'requireOfficialStore': requireOfficialStore,
    'strictMode': strictMode,
  };
}

/// Security status
enum SecurityStatus {
  secure,    // All checks passed
  warning,   // Minor issues detected
  risk,      // Significant issues detected
  critical,  // Critical security issues
  unknown,   // Not yet checked
}

/// Security check result
class SecurityCheckResult {
  final SecurityStatus status;
  final int score;
  final Map<String, bool> checks;
  final List<String> issues;
  final DateTime timestamp;

  const SecurityCheckResult({
    required this.status,
    required this.score,
    required this.checks,
    required this.issues,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'status': status.toString(),
    'score': score,
    'checks': checks,
    'issues': issues,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Security status widget to show in UI
class SecurityStatusIndicator extends ConsumerWidget {
  const SecurityStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityManager = ref.watch(securityManagerProvider);
    final status = securityManager.status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorForStatus(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColorForStatus(status)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForStatus(status),
            size: 16,
            color: _getColorForStatus(status),
          ),
          const SizedBox(width: 4),
          Text(
            _getLabelForStatus(status),
            style: TextStyle(
              fontSize: 12,
              color: _getColorForStatus(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForStatus(SecurityStatus status) {
    switch (status) {
      case SecurityStatus.secure:
        return Colors.green;
      case SecurityStatus.warning:
        return Colors.orange;
      case SecurityStatus.risk:
        return Colors.deepOrange;
      case SecurityStatus.critical:
        return Colors.red;
      case SecurityStatus.unknown:
        return Colors.grey;
    }
  }

  IconData _getIconForStatus(SecurityStatus status) {
    switch (status) {
      case SecurityStatus.secure:
        return Icons.security;
      case SecurityStatus.warning:
        return Icons.warning_amber;
      case SecurityStatus.risk:
        return Icons.warning;
      case SecurityStatus.critical:
        return Icons.dangerous;
      case SecurityStatus.unknown:
        return Icons.help_outline;
    }
  }

  String _getLabelForStatus(SecurityStatus status) {
    switch (status) {
      case SecurityStatus.secure:
        return 'Secure';
      case SecurityStatus.warning:
        return 'Warning';
      case SecurityStatus.risk:
        return 'At Risk';
      case SecurityStatus.critical:
        return 'Critical';
      case SecurityStatus.unknown:
        return 'Unknown';
    }
  }
}