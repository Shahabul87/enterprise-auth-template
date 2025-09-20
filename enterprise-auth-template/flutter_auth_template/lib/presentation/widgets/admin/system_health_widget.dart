import 'package:flutter/material.dart';
import 'package:flutter_auth_template/data/models/admin_models.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class SystemHealthWidget extends StatelessWidget {
  final SystemHealthCheck healthData;
  final VoidCallback? onRefresh;

  const SystemHealthWidget({
    super.key,
    required this.healthData,
    this.onRefresh,
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
                Text('System Health', style: AppTextStyles.titleLarge),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Health Check',
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Overall status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(healthData.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(healthData.status).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(healthData.status),
                    color: _getStatusColor(healthData.status),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('System Status', style: AppTextStyles.bodyMedium),
                        Text(
                          healthData.status.toUpperCase(),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: _getStatusColor(healthData.status),
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

            // Component health details
            if (healthData.components.isNotEmpty) ...[
              Text('Component Status', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),

              ...healthData.components.entries.map((entry) {
                final componentName = entry.key;
                final componentData = entry.value;
                final status = componentData['status'] as String? ?? 'unknown';
                final message = componentData['message'] as String? ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getComponentIcon(componentName),
                        color: _getStatusColor(status),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _formatComponentName(componentName),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (message.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                message,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 16),

            // System info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Version', healthData.version),
                  const SizedBox(height: 8),
                  _buildInfoRow('Uptime', healthData.uptime),
                  const SizedBox(height: 8),
                  _buildInfoRow('Last Check', healthData.lastCheck),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'ok':
      case 'up':
        return AppColors.success;
      case 'degraded':
      case 'warning':
        return AppColors.warning;
      case 'unhealthy':
      case 'error':
      case 'down':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'ok':
      case 'up':
        return Icons.check_circle;
      case 'degraded':
      case 'warning':
        return Icons.warning;
      case 'unhealthy':
      case 'error':
      case 'down':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  IconData _getComponentIcon(String componentName) {
    switch (componentName.toLowerCase()) {
      case 'database':
      case 'db':
      case 'postgres':
      case 'postgresql':
        return Icons.storage;
      case 'redis':
      case 'cache':
        return Icons.cached;
      case 'api':
      case 'server':
        return Icons.dns;
      case 'email':
      case 'mail':
        return Icons.mail;
      case 'auth':
      case 'authentication':
        return Icons.security;
      default:
        return Icons.settings;
    }
  }

  String _formatComponentName(String componentName) {
    // Convert snake_case or kebab-case to Title Case
    return componentName
        .split(RegExp(r'[_-]'))
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
