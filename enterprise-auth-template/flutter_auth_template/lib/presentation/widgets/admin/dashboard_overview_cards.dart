import 'package:flutter/material.dart';
import 'package:flutter_auth_template/data/models/admin_models.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class DashboardOverviewCards extends StatelessWidget {
  final AdminDashboardData dashboardData;

  const DashboardOverviewCards({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Overview', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 16),

        // First row of cards
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                title: 'Total Users',
                value: dashboardData.totalUsers.toString(),
                icon: Icons.people,
                color: AppColors.primary,
                subtitle: '${dashboardData.recentRegistrations} new this week',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                title: 'Active Users',
                value: dashboardData.activeUsers.toString(),
                icon: Icons.verified_user,
                color: AppColors.success,
                subtitle: 'Currently online',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Second row of cards
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                title: 'Active Sessions',
                value: dashboardData.activeSessions.toString(),
                icon: Icons.devices,
                color: AppColors.info,
                subtitle: 'Connected devices',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                title: 'Failed Logins',
                value: dashboardData.failedLoginAttempts.toString(),
                icon: Icons.warning,
                color: AppColors.error,
                subtitle: 'Security alerts',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Third row - suspended users card (if any)
        if (dashboardData.suspendedUsers > 0)
          _buildOverviewCard(
            title: 'Suspended Users',
            value: dashboardData.suspendedUsers.toString(),
            icon: Icons.person_remove,
            color: AppColors.warning,
            subtitle: 'Accounts temporarily disabled',
            fullWidth: true,
          ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
