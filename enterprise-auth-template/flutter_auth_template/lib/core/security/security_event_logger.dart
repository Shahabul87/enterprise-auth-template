import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';

// Security Event Logger Provider
final securityEventLoggerProvider = Provider<SecurityEventLogger>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return SecurityEventLogger(secureStorage);
});

/// Security Event Types
enum SecurityEventType {
  // Authentication Events
  loginSuccess,
  loginFailed,
  logout,
  sessionTimeout,
  tokenRefresh,
  passwordChanged,
  passwordReset,

  // Authorization Events
  accessGranted,
  accessDenied,
  permissionChanged,
  roleChanged,

  // Security Events
  accountLocked,
  accountUnlocked,
  twoFactorEnabled,
  twoFactorDisabled,
  twoFactorVerified,
  twoFactorFailed,
  biometricEnabled,
  biometricDisabled,
  biometricVerified,
  biometricFailed,

  // Device Events
  deviceRegistered,
  deviceRemoved,
  deviceVerified,
  untrustedDevice,

  // Data Events
  dataAccessed,
  dataModified,
  dataDeleted,
  dataExported,

  // Security Violations
  rateLimitExceeded,
  suspiciousActivity,
  invalidInput,
  injectionAttempt,
  bruteForceAttempt,

  // System Events
  configurationChanged,
  systemError,
  serviceStarted,
  serviceStopped,
}

/// Security Event Severity Levels
enum SecurityEventSeverity {
  info,      // Informational events
  low,       // Low severity events
  medium,    // Medium severity events
  high,      // High severity events
  critical,  // Critical security events
}

/// Security Event Logger Service
class SecurityEventLogger {
  final SecureStorageService _secureStorage;
  final List<SecurityEvent> _events = [];
  final int _maxEventsInMemory = 1000;
  final StreamController<SecurityEvent> _eventStream = StreamController.broadcast();

  // Storage keys
  static const String _eventsStorageKey = 'security_events';
  static const String _eventCountKey = 'security_event_count';

  SecurityEventLogger(this._secureStorage) {
    _loadEvents();
  }

  /// Get event stream for real-time monitoring
  Stream<SecurityEvent> get eventStream => _eventStream.stream;

  /// Log a security event
  Future<void> logEvent({
    required SecurityEventType type,
    required SecurityEventSeverity severity,
    String? userId,
    String? description,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? userAgent,
    String? deviceId,
  }) async {
    final event = SecurityEvent(
      id: _generateEventId(),
      type: type,
      severity: severity,
      timestamp: DateTime.now(),
      userId: userId,
      description: description ?? _getDefaultDescription(type),
      metadata: metadata,
      ipAddress: ipAddress,
      userAgent: userAgent,
      deviceId: deviceId,
    );

    // Add to memory
    _events.add(event);

    // Emit to stream
    _eventStream.add(event);

    // Persist to storage
    await _persistEvent(event);

    // Clean up old events if needed
    if (_events.length > _maxEventsInMemory) {
      _events.removeAt(0);
    }

    // Check for critical events that need immediate action
    if (severity == SecurityEventSeverity.critical) {
      await _handleCriticalEvent(event);
    }

    // Check for patterns that indicate attacks
    await _detectSecurityPatterns(event);
  }

  /// Log login success
  Future<void> logLoginSuccess({
    required String userId,
    String? ipAddress,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent(
      type: SecurityEventType.loginSuccess,
      severity: SecurityEventSeverity.info,
      userId: userId,
      description: 'User logged in successfully',
      ipAddress: ipAddress,
      deviceId: deviceId,
      metadata: metadata,
    );
  }

  /// Log login failure
  Future<void> logLoginFailure({
    String? userId,
    String? email,
    String? reason,
    String? ipAddress,
    String? deviceId,
  }) async {
    await logEvent(
      type: SecurityEventType.loginFailed,
      severity: SecurityEventSeverity.low,
      userId: userId,
      description: 'Login attempt failed: ${reason ?? 'Invalid credentials'}',
      ipAddress: ipAddress,
      deviceId: deviceId,
      metadata: {'email': email, 'reason': reason},
    );
  }

  /// Log account lockout
  Future<void> logAccountLockout({
    required String userId,
    required int failedAttempts,
    String? ipAddress,
  }) async {
    await logEvent(
      type: SecurityEventType.accountLocked,
      severity: SecurityEventSeverity.high,
      userId: userId,
      description: 'Account locked after $failedAttempts failed attempts',
      ipAddress: ipAddress,
      metadata: {'failedAttempts': failedAttempts},
    );
  }

  /// Log rate limit exceeded
  Future<void> logRateLimitExceeded({
    String? userId,
    required String endpoint,
    String? ipAddress,
  }) async {
    await logEvent(
      type: SecurityEventType.rateLimitExceeded,
      severity: SecurityEventSeverity.medium,
      userId: userId,
      description: 'Rate limit exceeded for endpoint: $endpoint',
      ipAddress: ipAddress,
      metadata: {'endpoint': endpoint},
    );
  }

  /// Log suspicious activity
  Future<void> logSuspiciousActivity({
    String? userId,
    required String activity,
    required String reason,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent(
      type: SecurityEventType.suspiciousActivity,
      severity: SecurityEventSeverity.high,
      userId: userId,
      description: 'Suspicious activity detected: $activity - $reason',
      ipAddress: ipAddress,
      metadata: metadata,
    );
  }

  /// Get events by filter
  List<SecurityEvent> getEvents({
    SecurityEventType? type,
    SecurityEventSeverity? severity,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    var filtered = _events.toList();

    if (type != null) {
      filtered = filtered.where((e) => e.type == type).toList();
    }

    if (severity != null) {
      filtered = filtered.where((e) => e.severity == severity).toList();
    }

    if (userId != null) {
      filtered = filtered.where((e) => e.userId == userId).toList();
    }

    if (startDate != null) {
      filtered = filtered.where((e) => e.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((e) => e.timestamp.isBefore(endDate)).toList();
    }

    // Sort by timestamp descending
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }

    return filtered;
  }

  /// Get event statistics
  SecurityEventStatistics getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final filtered = getEvents(startDate: startDate, endDate: endDate);

    final typeCount = <SecurityEventType, int>{};
    final severityCount = <SecurityEventSeverity, int>{};

    for (final event in filtered) {
      typeCount[event.type] = (typeCount[event.type] ?? 0) + 1;
      severityCount[event.severity] = (severityCount[event.severity] ?? 0) + 1;
    }

    return SecurityEventStatistics(
      totalEvents: filtered.length,
      eventsByType: typeCount,
      eventsBySeverity: severityCount,
      criticalEvents: severityCount[SecurityEventSeverity.critical] ?? 0,
      highSeverityEvents: severityCount[SecurityEventSeverity.high] ?? 0,
      startDate: startDate ?? (filtered.isNotEmpty ? filtered.last.timestamp : DateTime.now()),
      endDate: endDate ?? DateTime.now(),
    );
  }

  /// Clear old events
  Future<void> clearOldEvents({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    _events.removeWhere((event) => event.timestamp.isBefore(cutoffDate));
    await _persistAllEvents();
  }

  // Private methods

  String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  String _getDefaultDescription(SecurityEventType type) {
    switch (type) {
      case SecurityEventType.loginSuccess:
        return 'User logged in successfully';
      case SecurityEventType.loginFailed:
        return 'Login attempt failed';
      case SecurityEventType.logout:
        return 'User logged out';
      case SecurityEventType.sessionTimeout:
        return 'Session timed out';
      case SecurityEventType.accountLocked:
        return 'Account was locked';
      case SecurityEventType.rateLimitExceeded:
        return 'Rate limit exceeded';
      case SecurityEventType.suspiciousActivity:
        return 'Suspicious activity detected';
      default:
        return type.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), r' $1').trim();
    }
  }

  Future<void> _persistEvent(SecurityEvent event) async {
    // In production, this would send to a logging service
    // For now, store locally with rotation

    final events = await _loadStoredEvents();
    events.add(event);

    // Keep only last 10000 events in storage
    if (events.length > 10000) {
      events.removeRange(0, events.length - 10000);
    }

    final eventsJson = events.map((e) => e.toJson()).toList();
    await _secureStorage.storeJsonData(_eventsStorageKey, {'events': eventsJson});
  }

  Future<void> _persistAllEvents() async {
    final eventsJson = _events.map((e) => e.toJson()).toList();
    await _secureStorage.storeJsonData(_eventsStorageKey, {'events': eventsJson});
  }

  Future<List<SecurityEvent>> _loadStoredEvents() async {
    final data = await _secureStorage.getJsonData(_eventsStorageKey);
    if (data == null || data['events'] == null) {
      return [];
    }

    final eventsList = data['events'] as List;
    return eventsList.map((e) => SecurityEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _loadEvents() async {
    final events = await _loadStoredEvents();
    _events.addAll(events.take(_maxEventsInMemory));
  }

  Future<void> _handleCriticalEvent(SecurityEvent event) async {
    // In production, this would:
    // 1. Send immediate alert to security team
    // 2. Trigger automated response (e.g., account lockdown)
    // 3. Create incident ticket
    // 4. Send to SIEM system

    print('CRITICAL SECURITY EVENT: ${event.description}');
  }

  Future<void> _detectSecurityPatterns(SecurityEvent event) async {
    // Check for brute force attempts
    if (event.type == SecurityEventType.loginFailed) {
      final recentFailures = getEvents(
        type: SecurityEventType.loginFailed,
        userId: event.userId,
        startDate: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      if (recentFailures.length >= 5) {
        await logEvent(
          type: SecurityEventType.bruteForceAttempt,
          severity: SecurityEventSeverity.critical,
          userId: event.userId,
          description: 'Possible brute force attack detected',
          metadata: {'failureCount': recentFailures.length},
        );
      }
    }

    // Check for suspicious access patterns
    if (event.type == SecurityEventType.accessDenied) {
      final recentDenials = getEvents(
        type: SecurityEventType.accessDenied,
        userId: event.userId,
        startDate: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      if (recentDenials.length >= 3) {
        await logEvent(
          type: SecurityEventType.suspiciousActivity,
          severity: SecurityEventSeverity.high,
          userId: event.userId,
          description: 'Multiple access denials detected',
          metadata: {'denialCount': recentDenials.length},
        );
      }
    }
  }

  void dispose() {
    _eventStream.close();
  }
}

/// Security Event Model
class SecurityEvent {
  final String id;
  final SecurityEventType type;
  final SecurityEventSeverity severity;
  final DateTime timestamp;
  final String? userId;
  final String description;
  final Map<String, dynamic>? metadata;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceId;

  const SecurityEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.userId,
    required this.description,
    this.metadata,
    this.ipAddress,
    this.userAgent,
    this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'severity': severity.toString(),
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'description': description,
    'metadata': metadata,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'deviceId': deviceId,
  };

  factory SecurityEvent.fromJson(Map<String, dynamic> json) => SecurityEvent(
    id: json['id'],
    type: SecurityEventType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => SecurityEventType.systemError,
    ),
    severity: SecurityEventSeverity.values.firstWhere(
      (e) => e.toString() == json['severity'],
      orElse: () => SecurityEventSeverity.info,
    ),
    timestamp: DateTime.parse(json['timestamp']),
    userId: json['userId'],
    description: json['description'],
    metadata: json['metadata'],
    ipAddress: json['ipAddress'],
    userAgent: json['userAgent'],
    deviceId: json['deviceId'],
  );

  Color get severityColor {
    switch (severity) {
      case SecurityEventSeverity.critical:
        return Colors.red[900]!;
      case SecurityEventSeverity.high:
        return Colors.red;
      case SecurityEventSeverity.medium:
        return Colors.orange;
      case SecurityEventSeverity.low:
        return Colors.yellow[700]!;
      case SecurityEventSeverity.info:
        return Colors.blue;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case SecurityEventType.loginSuccess:
      case SecurityEventType.loginFailed:
        return Icons.login;
      case SecurityEventType.logout:
        return Icons.logout;
      case SecurityEventType.accountLocked:
      case SecurityEventType.accountUnlocked:
        return Icons.lock;
      case SecurityEventType.suspiciousActivity:
      case SecurityEventType.bruteForceAttempt:
        return Icons.warning;
      case SecurityEventType.rateLimitExceeded:
        return Icons.speed;
      default:
        return Icons.security;
    }
  }
}

/// Security Event Statistics
class SecurityEventStatistics {
  final int totalEvents;
  final Map<SecurityEventType, int> eventsByType;
  final Map<SecurityEventSeverity, int> eventsBySeverity;
  final int criticalEvents;
  final int highSeverityEvents;
  final DateTime startDate;
  final DateTime endDate;

  const SecurityEventStatistics({
    required this.totalEvents,
    required this.eventsByType,
    required this.eventsBySeverity,
    required this.criticalEvents,
    required this.highSeverityEvents,
    required this.startDate,
    required this.endDate,
  });
}

/// Security Event Monitor Widget
class SecurityEventMonitor extends ConsumerStatefulWidget {
  const SecurityEventMonitor({Key? key}) : super(key: key);

  @override
  ConsumerState<SecurityEventMonitor> createState() => _SecurityEventMonitorState();
}

class _SecurityEventMonitorState extends ConsumerState<SecurityEventMonitor> {
  final List<SecurityEvent> _recentEvents = [];
  StreamSubscription<SecurityEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    final logger = ref.read(securityEventLoggerProvider);
    _subscription = logger.eventStream.listen((event) {
      setState(() {
        _recentEvents.insert(0, event);
        if (_recentEvents.length > 50) {
          _recentEvents.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logger = ref.watch(securityEventLoggerProvider);
    final stats = logger.getStatistics();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Security Event Monitor',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Events',
                  stats.totalEvents.toString(),
                  Icons.list,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Critical',
                  stats.criticalEvents.toString(),
                  Icons.error,
                  Colors.red,
                ),
                _buildStatCard(
                  'High',
                  stats.highSeverityEvents.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent Events
            Text(
              'Recent Events',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _recentEvents.isEmpty
                  ? const Center(
                      child: Text('No recent events'),
                    )
                  : ListView.builder(
                      itemCount: _recentEvents.length,
                      itemBuilder: (context, index) {
                        final event = _recentEvents[index];
                        return ListTile(
                          leading: Icon(
                            event.typeIcon,
                            color: event.severityColor,
                            size: 20,
                          ),
                          title: Text(
                            event.description,
                            style: const TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            '${event.timestamp.hour.toString().padLeft(2, '0')}:'
                            '${event.timestamp.minute.toString().padLeft(2, '0')}:'
                            '${event.timestamp.second.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          dense: true,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}