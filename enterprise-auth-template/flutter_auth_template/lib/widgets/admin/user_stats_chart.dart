import 'package:flutter/material.dart';
import '../../data/models/admin_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class UserStatsChart extends StatelessWidget {
  final AdminDashboardData dashboardData;

  const UserStatsChart({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Statistics', style: AppTextStyles.titleLarge),

            const SizedBox(height: 20),

            // Role distribution
            if (dashboardData.roleDistribution.isNotEmpty) ...[
              Text('Users by Role', style: AppTextStyles.titleMedium),
              const SizedBox(height: 16),

              ...dashboardData.roleDistribution.entries.map((entry) {
                final roleName = entry.key;
                final userCount = entry.value;
                final percentage = dashboardData.totalUsers > 0
                    ? (userCount / dashboardData.totalUsers) * 100
                    : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getRoleIcon(roleName),
                                size: 16,
                                color: _getRoleColor(roleName),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatRoleName(roleName),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                          Text(
                            '$userCount (${percentage.toStringAsFixed(1)}%)',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRoleColor(roleName),
                        ),
                        minHeight: 6,
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
            ],

            // User status breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Status Breakdown',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusItem(
                          'Active',
                          dashboardData.activeUsers,
                          dashboardData.totalUsers,
                          AppColors.success,
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusItem(
                          'Suspended',
                          dashboardData.suspendedUsers,
                          dashboardData.totalUsers,
                          AppColors.warning,
                          Icons.pause_circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildStatusItem(
                    'Inactive',
                    dashboardData.totalUsers -
                        dashboardData.activeUsers -
                        dashboardData.suspendedUsers,
                    dashboardData.totalUsers,
                    AppColors.onSurfaceVariant,
                    Icons.radio_button_unchecked,
                    fullWidth: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent activity summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Growth This Week',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          '+${dashboardData.recentRegistrations} new users',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildStatusItem(
    String label,
    int count,
    int total,
    Color color,
    IconData icon, {
    bool fullWidth = false,
  }) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}% of total',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
      case 'administrator':
      case 'superuser':
        return AppColors.error;
      case 'moderator':
      case 'manager':
        return AppColors.warning;
      case 'user':
      case 'member':
        return AppColors.primary;
      case 'guest':
      case 'viewer':
        return AppColors.onSurfaceVariant;
      default:
        return AppColors.info;
    }
  }

  IconData _getRoleIcon(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
      case 'administrator':
      case 'superuser':
        return Icons.admin_panel_settings;
      case 'moderator':
      case 'manager':
        return Icons.supervisor_account;
      case 'user':
      case 'member':
        return Icons.person;
      case 'guest':
      case 'viewer':
        return Icons.visibility;
      default:
        return Icons.group;
    }
  }

  String _formatRoleName(String roleName) {
    return roleName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
