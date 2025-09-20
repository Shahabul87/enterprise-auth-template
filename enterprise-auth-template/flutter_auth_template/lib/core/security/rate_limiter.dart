import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';

// Rate Limiter Provider
final rateLimiterProvider = Provider<RateLimiter>((ref) {
  return RateLimiter();
});

/// Rate limiter for API endpoints to prevent abuse
class RateLimiter {
  // Configuration per endpoint
  static const Map<String, RateLimitConfig> _endpointConfigs = {
    '/api/auth/login': RateLimitConfig(
      maxAttempts: 5,
      windowDurationSeconds: 60,
      blockDurationSeconds: 300,
      identifier: 'login',
    ),
    '/api/auth/register': RateLimitConfig(
      maxAttempts: 3,
      windowDurationSeconds: 300,
      blockDurationSeconds: 600,
      identifier: 'register',
    ),
    '/api/auth/forgot-password': RateLimitConfig(
      maxAttempts: 3,
      windowDurationSeconds: 300,
      blockDurationSeconds: 900,
      identifier: 'forgot_password',
    ),
    '/api/auth/verify-2fa': RateLimitConfig(
      maxAttempts: 3,
      windowDurationSeconds: 60,
      blockDurationSeconds: 600,
      identifier: 'verify_2fa',
    ),
    '/api/auth/refresh-token': RateLimitConfig(
      maxAttempts: 10,
      windowDurationSeconds: 60,
      blockDurationSeconds: 120,
      identifier: 'refresh_token',
    ),
    '/api/auth/magic-link': RateLimitConfig(
      maxAttempts: 2,
      windowDurationSeconds: 300,
      blockDurationSeconds: 1800,
      identifier: 'magic_link',
    ),
  };

  // Storage for rate limit tracking
  final Map<String, RateLimitBucket> _buckets = {};
  final Map<String, DateTime> _blockedUntil = {};

  // Cleanup timer
  Timer? _cleanupTimer;

  RateLimiter() {
    // Start cleanup timer to remove old entries
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanup(),
    );
  }

  /// Check if request is allowed
  Future<RateLimitResult> checkLimit({
    required String endpoint,
    String? clientId,
    Map<String, dynamic>? metadata,
  }) async {
    // Get config for endpoint
    final config = _endpointConfigs[endpoint] ?? _getDefaultConfig();

    // Generate unique key for this client/endpoint combination
    final key = _generateKey(endpoint, clientId, metadata);

    // Check if client is blocked
    if (_isBlocked(key)) {
      final blockedUntil = _blockedUntil[key]!;
      return RateLimitResult(
        allowed: false,
        remainingAttempts: 0,
        resetTime: blockedUntil,
        reason: 'Too many requests. Please try again later.',
        retryAfterSeconds: blockedUntil.difference(DateTime.now()).inSeconds,
      );
    }

    // Get or create bucket for this key
    final bucket = _buckets.putIfAbsent(
      key,
      () => RateLimitBucket(
        maxAttempts: config.maxAttempts,
        windowDuration: Duration(seconds: config.windowDurationSeconds),
      ),
    );

    // Check if request is allowed
    final now = DateTime.now();
    bucket.removeExpiredAttempts(now);

    if (bucket.attempts.length >= config.maxAttempts) {
      // Block the client
      _blockClient(key, config.blockDurationSeconds);

      return RateLimitResult(
        allowed: false,
        remainingAttempts: 0,
        resetTime: _blockedUntil[key]!,
        reason: 'Rate limit exceeded. Account temporarily blocked.',
        retryAfterSeconds: config.blockDurationSeconds,
      );
    }

    // Record this attempt
    bucket.addAttempt(now);

    // Calculate remaining attempts
    final remainingAttempts = config.maxAttempts - bucket.attempts.length;
    final resetTime = bucket.getResetTime();

    return RateLimitResult(
      allowed: true,
      remainingAttempts: remainingAttempts,
      resetTime: resetTime,
      reason: null,
      retryAfterSeconds: 0,
    );
  }

  /// Record successful request (optional - can reset or reduce count)
  void recordSuccess({
    required String endpoint,
    String? clientId,
    Map<String, dynamic>? metadata,
  }) {
    final key = _generateKey(endpoint, clientId, metadata);

    // Clear the bucket on success (optional behavior)
    _buckets.remove(key);
    _blockedUntil.remove(key);
  }

  /// Check if client is currently blocked
  bool _isBlocked(String key) {
    final blockedUntil = _blockedUntil[key];
    if (blockedUntil == null) return false;

    if (DateTime.now().isAfter(blockedUntil)) {
      _blockedUntil.remove(key);
      return false;
    }

    return true;
  }

  /// Block a client for specified duration
  void _blockClient(String key, int blockDurationSeconds) {
    _blockedUntil[key] = DateTime.now().add(
      Duration(seconds: blockDurationSeconds),
    );
  }

  /// Generate unique key for rate limiting
  String _generateKey(
    String endpoint,
    String? clientId,
    Map<String, dynamic>? metadata,
  ) {
    final parts = [endpoint];

    if (clientId != null) {
      parts.add(clientId);
    }

    // Add relevant metadata to key (e.g., IP address, device ID)
    if (metadata != null) {
      if (metadata['ip'] != null) {
        parts.add(metadata['ip']);
      }
      if (metadata['deviceId'] != null) {
        parts.add(metadata['deviceId']);
      }
    }

    return parts.join(':');
  }

  /// Get default config for unknown endpoints
  RateLimitConfig _getDefaultConfig() {
    return const RateLimitConfig(
      maxAttempts: 60,
      windowDurationSeconds: 60,
      blockDurationSeconds: 60,
      identifier: 'default',
    );
  }

  /// Clean up old entries
  void _cleanup() {
    final now = DateTime.now();

    // Remove expired blocks
    _blockedUntil.removeWhere((key, until) => now.isAfter(until));

    // Remove old buckets
    _buckets.removeWhere((key, bucket) {
      bucket.removeExpiredAttempts(now);
      return bucket.attempts.isEmpty &&
          now.difference(bucket.lastActivity).inMinutes > 30;
    });
  }

  /// Get rate limit status for endpoint
  RateLimitStatus getStatus({
    required String endpoint,
    String? clientId,
    Map<String, dynamic>? metadata,
  }) {
    final config = _endpointConfigs[endpoint] ?? _getDefaultConfig();
    final key = _generateKey(endpoint, clientId, metadata);

    if (_isBlocked(key)) {
      final blockedUntil = _blockedUntil[key]!;
      return RateLimitStatus(
        isBlocked: true,
        currentAttempts: config.maxAttempts,
        maxAttempts: config.maxAttempts,
        windowSeconds: config.windowDurationSeconds,
        blockedUntil: blockedUntil,
      );
    }

    final bucket = _buckets[key];
    if (bucket == null) {
      return RateLimitStatus(
        isBlocked: false,
        currentAttempts: 0,
        maxAttempts: config.maxAttempts,
        windowSeconds: config.windowDurationSeconds,
        blockedUntil: null,
      );
    }

    bucket.removeExpiredAttempts(DateTime.now());

    return RateLimitStatus(
      isBlocked: false,
      currentAttempts: bucket.attempts.length,
      maxAttempts: config.maxAttempts,
      windowSeconds: config.windowDurationSeconds,
      blockedUntil: null,
    );
  }

  /// Reset rate limit for specific client/endpoint
  void reset({
    required String endpoint,
    String? clientId,
    Map<String, dynamic>? metadata,
  }) {
    final key = _generateKey(endpoint, clientId, metadata);
    _buckets.remove(key);
    _blockedUntil.remove(key);
  }

  /// Dispose cleanup timer
  void dispose() {
    _cleanupTimer?.cancel();
  }
}

/// Rate limit configuration
class RateLimitConfig {
  final int maxAttempts;
  final int windowDurationSeconds;
  final int blockDurationSeconds;
  final String identifier;

  const RateLimitConfig({
    required this.maxAttempts,
    required this.windowDurationSeconds,
    required this.blockDurationSeconds,
    required this.identifier,
  });
}

/// Rate limit bucket for tracking attempts
class RateLimitBucket {
  final int maxAttempts;
  final Duration windowDuration;
  final Queue<DateTime> attempts = Queue();
  DateTime lastActivity;

  RateLimitBucket({
    required this.maxAttempts,
    required this.windowDuration,
  }) : lastActivity = DateTime.now();

  void addAttempt(DateTime time) {
    attempts.add(time);
    lastActivity = time;
  }

  void removeExpiredAttempts(DateTime now) {
    final cutoff = now.subtract(windowDuration);
    while (attempts.isNotEmpty && attempts.first.isBefore(cutoff)) {
      attempts.removeFirst();
    }
  }

  DateTime getResetTime() {
    if (attempts.isEmpty) {
      return DateTime.now().add(windowDuration);
    }
    return attempts.first.add(windowDuration);
  }
}

/// Rate limit check result
class RateLimitResult {
  final bool allowed;
  final int remainingAttempts;
  final DateTime resetTime;
  final String? reason;
  final int retryAfterSeconds;

  const RateLimitResult({
    required this.allowed,
    required this.remainingAttempts,
    required this.resetTime,
    this.reason,
    required this.retryAfterSeconds,
  });

  Map<String, dynamic> toHeaders() {
    return {
      'X-RateLimit-Limit': remainingAttempts.toString(),
      'X-RateLimit-Remaining': remainingAttempts.toString(),
      'X-RateLimit-Reset': resetTime.millisecondsSinceEpoch.toString(),
      if (retryAfterSeconds > 0) 'Retry-After': retryAfterSeconds.toString(),
    };
  }
}

/// Rate limit status
class RateLimitStatus {
  final bool isBlocked;
  final int currentAttempts;
  final int maxAttempts;
  final int windowSeconds;
  final DateTime? blockedUntil;

  const RateLimitStatus({
    required this.isBlocked,
    required this.currentAttempts,
    required this.maxAttempts,
    required this.windowSeconds,
    this.blockedUntil,
  });

  double get usagePercentage => currentAttempts / maxAttempts;
  bool get isWarning => usagePercentage > 0.7;
  bool get isCritical => usagePercentage > 0.9;

  String get statusMessage {
    if (isBlocked && blockedUntil != null) {
      final remaining = blockedUntil!.difference(DateTime.now());
      return 'Blocked for ${remaining.inSeconds} seconds';
    }
    if (isCritical) {
      return 'Critical: ${maxAttempts - currentAttempts} attempts remaining';
    }
    if (isWarning) {
      return 'Warning: ${maxAttempts - currentAttempts} attempts remaining';
    }
    return 'Normal: $currentAttempts of $maxAttempts attempts used';
  }
}

/// Widget to display rate limit status
class RateLimitStatusWidget extends StatelessWidget {
  final RateLimitStatus status;
  final VoidCallback? onReset;

  const RateLimitStatusWidget({
    Key? key,
    required this.status,
    this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;

    if (status.isBlocked) {
      color = Colors.red;
      icon = Icons.block;
    } else if (status.isCritical) {
      color = Colors.orange;
      icon = Icons.warning;
    } else if (status.isWarning) {
      color = Colors.amber;
      icon = Icons.info_outline;
    } else {
      color = Colors.green;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate Limit Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.statusMessage,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: status.usagePercentage,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
          if (onReset != null && status.isBlocked)
            IconButton(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              color: color,
              iconSize: 20,
            ),
        ],
      ),
    );
  }
}