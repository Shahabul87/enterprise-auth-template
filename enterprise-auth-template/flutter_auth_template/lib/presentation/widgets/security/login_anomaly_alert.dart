import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

/// Login anomaly types
enum AnomalyType {
  newDevice,
  newLocation,
  unusualTime,
  suspiciousPattern,
  multipleFailedAttempts,
  impossibleTravel,
}

/// Login anomaly detection data
class LoginAnomaly {
  final String id;
  final AnomalyType type;
  final DateTime detectedAt;
  final String location;
  final String deviceInfo;
  final String ipAddress;
  final double riskScore; // 0.0 to 1.0
  final Map<String, dynamic>? metadata;

  const LoginAnomaly({
    required this.id,
    required this.type,
    required this.detectedAt,
    required this.location,
    required this.deviceInfo,
    required this.ipAddress,
    required this.riskScore,
    this.metadata,
  });

  String get typeDescription {
    switch (type) {
      case AnomalyType.newDevice:
        return 'New Device Detected';
      case AnomalyType.newLocation:
        return 'New Location Detected';
      case AnomalyType.unusualTime:
        return 'Unusual Login Time';
      case AnomalyType.suspiciousPattern:
        return 'Suspicious Activity Pattern';
      case AnomalyType.multipleFailedAttempts:
        return 'Multiple Failed Login Attempts';
      case AnomalyType.impossibleTravel:
        return 'Impossible Travel Detected';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case AnomalyType.newDevice:
        return Icons.devices;
      case AnomalyType.newLocation:
        return Icons.location_on;
      case AnomalyType.unusualTime:
        return Icons.schedule;
      case AnomalyType.suspiciousPattern:
        return Icons.warning;
      case AnomalyType.multipleFailedAttempts:
        return Icons.lock;
      case AnomalyType.impossibleTravel:
        return Icons.flight;
    }
  }

  Color getRiskColor(BuildContext context) {
    final theme = Theme.of(context);
    if (riskScore < 0.3) return Colors.green;
    if (riskScore < 0.6) return Colors.orange;
    return theme.colorScheme.error;
  }

  String get riskLevel {
    if (riskScore < 0.3) return 'Low';
    if (riskScore < 0.6) return 'Medium';
    return 'High';
  }
}

/// Login anomaly alert dialog
class LoginAnomalyAlert extends HookConsumerWidget {
  final LoginAnomaly anomaly;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onRequireVerification;

  const LoginAnomalyAlert({
    super.key,
    required this.anomaly,
    this.onApprove,
    this.onDeny,
    this.onRequireVerification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isProcessing = useState(false);
    final decision = useState<String?>(null);

    void handleDecision(String action) async {
      isProcessing.value = true;
      decision.value = action;

      // Simulate processing
      await Future.delayed(const Duration(seconds: 1));

      switch (action) {
        case 'approve':
          onApprove?.call();
          break;
        case 'deny':
          onDeny?.call();
          break;
        case 'verify':
          onRequireVerification?.call();
          break;
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Risk indicator with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0, end: anomaly.riskScore),
              builder: (context, value, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: anomaly.getRiskColor(context).withAlpha((26).round()),
                    border: Border.all(
                      color: anomaly.getRiskColor(context),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          anomaly.typeIcon,
                          size: 32,
                          color: anomaly.getRiskColor(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(value * 100).toInt()}%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: anomaly.getRiskColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              anomaly.typeDescription,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Risk level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: anomaly.getRiskColor(context).withAlpha((26).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: anomaly.getRiskColor(context).withAlpha((51).round()),
                ),
              ),
              child: Text(
                '${anomaly.riskLevel} Risk',
                style: TextStyle(
                  color: anomaly.getRiskColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha((26).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha((51).round()),
                ),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _formatDateTime(anomaly.detectedAt),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: anomaly.location,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.devices,
                    label: 'Device',
                    value: anomaly.deviceInfo,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.wifi,
                    label: 'IP Address',
                    value: anomaly.ipAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Warning message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha((26).round()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withAlpha((51).round()),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getWarningMessage(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            if (!isProcessing.value) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => handleDecision('deny'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      child: const Text('Block'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => handleDecision('verify'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: const Text('Verify'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => handleDecision('approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Allow'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      _getProcessingMessage(decision.value),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getWarningMessage() {
    switch (anomaly.type) {
      case AnomalyType.newDevice:
        return 'This login attempt is from a device you haven\'t used before.';
      case AnomalyType.newLocation:
        return 'This login is from an unusual location for your account.';
      case AnomalyType.unusualTime:
        return 'This login occurred at an unusual time based on your patterns.';
      case AnomalyType.suspiciousPattern:
        return 'We detected suspicious activity patterns with this login.';
      case AnomalyType.multipleFailedAttempts:
        return 'There were multiple failed login attempts before this one.';
      case AnomalyType.impossibleTravel:
        return 'This login location seems impossible based on your last login.';
    }
  }

  String _getProcessingMessage(String? action) {
    switch (action) {
      case 'approve':
        return 'Allowing login...';
      case 'deny':
        return 'Blocking login attempt...';
      case 'verify':
        return 'Initiating verification...';
      default:
        return 'Processing...';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Suspicious login notification widget
class SuspiciousLoginNotification extends HookWidget {
  final LoginAnomaly anomaly;
  final VoidCallback? onReview;
  final VoidCallback? onDismiss;

  const SuspiciousLoginNotification({
    super.key,
    required this.anomaly,
    this.onReview,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = useState(false);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    useEffect(() {
      if (isExpanded.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [isExpanded.value]);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: anomaly.getRiskColor(context).withAlpha((51).round()),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: anomaly.getRiskColor(context).withAlpha((26).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: anomaly.getRiskColor(context).withAlpha((26).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                anomaly.typeIcon,
                color: anomaly.getRiskColor(context),
                size: 24,
              ),
            ),
            title: Text(
              anomaly.typeDescription,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${anomaly.location} • ${_formatTime(anomaly.detectedAt)}',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: anomaly.getRiskColor(context).withAlpha((26).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    anomaly.riskLevel,
                    style: TextStyle(
                      color: anomaly.getRiskColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: AnimatedRotation(
                    turns: isExpanded.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more),
                  ),
                  onPressed: () => isExpanded.value = !isExpanded.value,
                ),
              ],
            ),
          ),
          SizeTransition(
            sizeFactor: animationController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha((128).round()),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              anomaly.deviceInfo,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IP Address',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha((128).round()),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              anomaly.ipAddress,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDismiss,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('It was me'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onReview,
                          icon: const Icon(Icons.security, size: 16),
                          label: const Text('Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: anomaly.getRiskColor(context),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Detail row widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withAlpha((128).round()),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((128).round()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}