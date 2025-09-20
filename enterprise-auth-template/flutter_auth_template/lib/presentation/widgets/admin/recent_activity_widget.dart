import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<Map<String, dynamic>> auditLogs;
  final VoidCallback? onViewAll;

  const RecentActivityWidget({
    super.key,
    required this.auditLogs,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Recent Activity', style: AppTextStyles.titleLarge),
                const Spacer(),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            if (auditLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent activity',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: auditLogs.take(5).map((log) {
                  return _buildActivityItem(log);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> log) {
    final action = log['action'] as String? ?? 'Unknown Action';
    final userEmail = log['user_email'] as String? ?? 'Unknown User';
    final timestamp = log['timestamp'] as String? ?? '';
    final resourceType = log['resource_type'] as String? ?? '';
    final ipAddress = log['ip_address'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActionColor(action).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActionIcon(action),
              color: _getActionColor(action),
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAction(action),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      userEmail,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (resourceType.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.folder,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        resourceType,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                if (ipAddress.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ipAddress,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTimestamp(timestamp),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'LOGIN':
      case 'LOGIN_SUCCESS':
        return AppColors.success;
      case 'LOGOUT':
        return AppColors.info;
      case 'LOGIN_FAILED':
      case 'SECURITY_VIOLATION':
        return AppColors.error;
      case 'USER_CREATED':
      case 'USER_REGISTERED':
        return AppColors.primary;
      case 'USER_UPDATED':
      case 'PROFILE_UPDATED':
        return AppColors.warning;
      case 'USER_DELETED':
      case 'USER_SUSPENDED':
        return AppColors.error;
      case 'PASSWORD_CHANGED':
      case 'TWO_FACTOR_ENABLED':
        return AppColors.success;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toUpperCase()) {
      case 'LOGIN':
      case 'LOGIN_SUCCESS':
        return Icons.login;
      case 'LOGOUT':
        return Icons.logout;
      case 'LOGIN_FAILED':
        return Icons.error;
      case 'USER_CREATED':
      case 'USER_REGISTERED':
        return Icons.person_add;
      case 'USER_UPDATED':
      case 'PROFILE_UPDATED':
        return Icons.edit;
      case 'USER_DELETED':
        return Icons.person_remove;
      case 'USER_SUSPENDED':
        return Icons.block;
      case 'PASSWORD_CHANGED':
        return Icons.key;
      case 'TWO_FACTOR_ENABLED':
        return Icons.security;
      case 'ADMIN_DASHBOARD_ACCESS':
        return Icons.dashboard;
      case 'SESSION_TERMINATED':
        return Icons.devices_other;
      case 'SECURITY_VIOLATION':
        return Icons.warning;
      default:
        return Icons.history;
    }
  }

  String _formatAction(String action) {
    // Convert snake_case to readable format
    return action
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
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
