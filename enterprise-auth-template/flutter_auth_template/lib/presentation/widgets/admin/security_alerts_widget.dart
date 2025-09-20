import 'package:flutter/material.dart';
import 'package:flutter_auth_template/data/models/admin_models.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class SecurityAlertsWidget extends StatelessWidget {
  final SecurityReport securityReport;
  final Function(String alertType)? onViewDetails;

  const SecurityAlertsWidget({
    super.key,
    required this.securityReport,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security Overview', style: AppTextStyles.titleLarge),

            const SizedBox(height: 20),

            // Security metrics summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getOverallSecurityColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getOverallSecurityColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getOverallSecurityIcon(),
                    color: _getOverallSecurityColor(),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Status',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          _getOverallSecurityStatus(),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: _getOverallSecurityColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Security metrics
            Row(
              children: [
                Expanded(
                  child: _buildSecurityMetric(
                    'Failed Logins',
                    securityReport.failedLoginAttempts.toString(),
                    'Last ${securityReport.periodDays} days',
                    Icons.warning,
                    securityReport.failedLoginAttempts > 50
                        ? AppColors.error
                        : securityReport.failedLoginAttempts > 20
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSecurityMetric(
                    'Locked Accounts',
                    securityReport.lockedAccounts.toString(),
                    'Currently locked',
                    Icons.lock,
                    securityReport.lockedAccounts > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Suspicious IPs
            if (securityReport.suspiciousIps.isNotEmpty) ...[
              _buildSuspiciousIpsSection(),
              const SizedBox(height: 20),
            ],

            // Recent security events
            if (securityReport.recentSecurityEvents.isNotEmpty) ...[
              _buildRecentSecurityEventsSection(),
              const SizedBox(height: 20),
            ],

            // Two-factor authentication adoption
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Two-Factor Authentication',
                        style: AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Adoption Rate: ', style: AppTextStyles.bodyMedium),
                      Text(
                        '${(securityReport.twoFaAdoptionRate * 100).toStringAsFixed(1)}%',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: securityReport.twoFaAdoptionRate > 0.8
                              ? AppColors.success
                              : securityReport.twoFaAdoptionRate > 0.5
                              ? AppColors.warning
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: securityReport.twoFaAdoptionRate,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      securityReport.twoFaAdoptionRate > 0.8
                          ? AppColors.success
                          : securityReport.twoFaAdoptionRate > 0.5
                          ? AppColors.warning
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityMetric(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuspiciousIpsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text('Suspicious IP Addresses', style: AppTextStyles.titleMedium),
            const Spacer(),
            if (onViewDetails != null)
              TextButton(
                onPressed: () => onViewDetails!('suspicious_ips'),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        ...securityReport.suspiciousIps.take(3).map((ipData) {
          final ipAddress = ipData['ip_address'] as String? ?? 'Unknown';
          final attempts = ipData['attempts'] as int? ?? 0;
          final lastSeen = ipData['last_seen'] as String? ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ipAddress,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$attempts failed attempts',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTimestamp(lastSeen),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecentSecurityEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.security, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            Text('Recent Security Events', style: AppTextStyles.titleMedium),
            const Spacer(),
            if (onViewDetails != null)
              TextButton(
                onPressed: () => onViewDetails!('security_events'),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        ...securityReport.recentSecurityEvents.take(3).map((event) {
          final eventType = event['event_type'] as String? ?? 'Unknown Event';
          final description = event['description'] as String? ?? '';
          final timestamp = event['timestamp'] as String? ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getEventIcon(eventType),
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatEventType(eventType),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(timestamp),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getOverallSecurityColor() {
    final failedLogins = securityReport.failedLoginAttempts;
    final lockedAccounts = securityReport.lockedAccounts;
    final twoFaRate = securityReport.twoFaAdoptionRate;

    if (failedLogins > 50 || lockedAccounts > 5 || twoFaRate < 0.3) {
      return AppColors.error;
    } else if (failedLogins > 20 || lockedAccounts > 2 || twoFaRate < 0.6) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  IconData _getOverallSecurityIcon() {
    final failedLogins = securityReport.failedLoginAttempts;
    final lockedAccounts = securityReport.lockedAccounts;
    final twoFaRate = securityReport.twoFaAdoptionRate;

    if (failedLogins > 50 || lockedAccounts > 5 || twoFaRate < 0.3) {
      return Icons.security;
    } else if (failedLogins > 20 || lockedAccounts > 2 || twoFaRate < 0.6) {
      return Icons.warning;
    } else {
      return Icons.verified_user;
    }
  }

  String _getOverallSecurityStatus() {
    final failedLogins = securityReport.failedLoginAttempts;
    final lockedAccounts = securityReport.lockedAccounts;
    final twoFaRate = securityReport.twoFaAdoptionRate;

    if (failedLogins > 50 || lockedAccounts > 5 || twoFaRate < 0.3) {
      return 'High Risk';
    } else if (failedLogins > 20 || lockedAccounts > 2 || twoFaRate < 0.6) {
      return 'Medium Risk';
    } else {
      return 'Secure';
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'brute_force':
      case 'failed_login':
        return Icons.warning;
      case 'suspicious_activity':
        return Icons.security;
      case 'account_locked':
        return Icons.lock;
      case 'password_breach':
        return Icons.key;
      default:
        return Icons.info;
    }
  }

  String _formatEventType(String eventType) {
    return eventType
        .toLowerCase()
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
