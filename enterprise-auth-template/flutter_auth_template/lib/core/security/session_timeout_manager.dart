import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/storage/secure_storage_service.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';

final sessionTimeoutManagerProvider = Provider<SessionTimeoutManager>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return SessionTimeoutManager(ref, secureStorage);
});

class SessionTimeoutManager {
  final Ref _ref;
  final SecureStorageService _secureStorage;

  // Configuration
  static const int sessionTimeoutMinutes = 30; // 30 minutes of inactivity
  static const int warningBeforeTimeoutSeconds = 60; // Show warning 1 minute before timeout

  Timer? _sessionTimer;
  Timer? _warningTimer;
  DateTime? _lastActivity;
  VoidCallback? _onSessionTimeout;
  VoidCallback? _onSessionWarning;

  // Storage keys
  static const String _lastActivityKey = 'last_activity_time';
  static const String _sessionStartKey = 'session_start_time';

  SessionTimeoutManager(this._ref, this._secureStorage);

  /// Get last activity time
  DateTime? getLastActivityTime() {
    return _lastActivity;
  }

  /// Initialize session timeout management
  void initializeSession({
    VoidCallback? onTimeout,
    VoidCallback? onWarning,
  }) {
    _onSessionTimeout = onTimeout;
    _onSessionWarning = onWarning;

    // Record session start
    _recordSessionStart();

    // Start monitoring
    _startSessionTimer();

    // Update last activity
    updateActivity();
  }

  /// Update activity timestamp
  void updateActivity() {
    _lastActivity = DateTime.now();
    _secureStorage.write(
      key: _lastActivityKey,
      value: _lastActivity!.toIso8601String(),
    );

    // Reset timers
    _resetTimers();
  }

  /// Reset session timers
  void _resetTimers() {
    // Cancel existing timers
    _sessionTimer?.cancel();
    _warningTimer?.cancel();

    // Start new timers
    _startSessionTimer();
  }

  /// Start session timeout timer
  void _startSessionTimer() {
    // Calculate timeout duration
    final timeoutDuration = Duration(minutes: sessionTimeoutMinutes);
    final warningDuration = timeoutDuration -
        Duration(seconds: warningBeforeTimeoutSeconds);

    // Set warning timer
    _warningTimer = Timer(warningDuration, () {
      _onSessionWarning?.call();
    });

    // Set session timeout timer
    _sessionTimer = Timer(timeoutDuration, () {
      _handleSessionTimeout();
    });
  }

  /// Handle session timeout
  Future<void> _handleSessionTimeout() async {
    // Clear session data
    await clearSession();

    // Notify callback
    _onSessionTimeout?.call();

    // Logout user through auth provider
    try {
      await _ref.read(authStateProvider.notifier).logout();
    } catch (e) {
      debugPrint('Error during session timeout logout: $e');
    }
  }

  /// Check if session is still valid
  Future<bool> isSessionValid() async {
    final lastActivityStr = await _secureStorage.read(key: _lastActivityKey);
    if (lastActivityStr == null) return false;

    final lastActivity = DateTime.tryParse(lastActivityStr);
    if (lastActivity == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    return difference.inMinutes < sessionTimeoutMinutes;
  }

  /// Get remaining session time in seconds
  Future<int> getRemainingSessionTime() async {
    final lastActivityStr = await _secureStorage.read(key: _lastActivityKey);
    if (lastActivityStr == null) return 0;

    final lastActivity = DateTime.tryParse(lastActivityStr);
    if (lastActivity == null) return 0;

    final now = DateTime.now();
    final elapsed = now.difference(lastActivity);
    final remaining = Duration(minutes: sessionTimeoutMinutes) - elapsed;

    if (remaining.isNegative) return 0;
    return remaining.inSeconds;
  }

  /// Extend session (when user chooses to stay logged in)
  void extendSession() {
    updateActivity();
  }

  /// Record session start time
  void _recordSessionStart() {
    final now = DateTime.now();
    _secureStorage.write(
      key: _sessionStartKey,
      value: now.toIso8601String(),
    );
  }

  /// Get session duration
  Future<Duration> getSessionDuration() async {
    final sessionStartStr = await _secureStorage.read(key: _sessionStartKey);
    if (sessionStartStr == null) return Duration.zero;

    final sessionStart = DateTime.tryParse(sessionStartStr);
    if (sessionStart == null) return Duration.zero;

    return DateTime.now().difference(sessionStart);
  }

  /// Clear session data
  Future<void> clearSession() async {
    // Cancel timers
    _sessionTimer?.cancel();
    _warningTimer?.cancel();

    // Clear stored data
    await _secureStorage.delete(key: _lastActivityKey);
    await _secureStorage.delete(key: _sessionStartKey);

    // Reset state
    _lastActivity = null;
  }

  /// Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
  }
}

/// Session timeout warning dialog
class SessionTimeoutWarning extends StatefulWidget {
  final VoidCallback onExtend;
  final VoidCallback onLogout;
  final int remainingSeconds;

  const SessionTimeoutWarning({
    Key? key,
    required this.onExtend,
    required this.onLogout,
    this.remainingSeconds = 60,
  }) : super(key: key);

  @override
  State<SessionTimeoutWarning> createState() => _SessionTimeoutWarningState();
}

class _SessionTimeoutWarningState extends State<SessionTimeoutWarning> {
  late int _remainingSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.remainingSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          widget.onLogout();
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: theme.colorScheme.warning),
          const SizedBox(width: 8),
          const Text('Session Expiring'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your session will expire in $_remainingSeconds seconds due to inactivity.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const Text(
            'Would you like to extend your session?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onLogout,
          child: const Text('Logout'),
        ),
        ElevatedButton(
          onPressed: () {
            _countdownTimer?.cancel();
            widget.onExtend();
          },
          child: const Text('Stay Logged In'),
        ),
      ],
    );
  }
}

// Extension for color scheme
extension ColorSchemeExtension on ColorScheme {
  Color get warning => Colors.orange;
}