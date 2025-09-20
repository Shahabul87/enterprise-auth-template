import 'package:flutter/material.dart';
import 'package:flutter_auth_template/domain/entities/user_profile.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Information', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.person,
              'Name',
              (profile.firstName != null && profile.firstName!.isNotEmpty) 
                  ? '${profile.firstName} ${profile.lastName ?? ''}'.trim()
                  : 'Not set',
              profile.firstName == null || profile.firstName!.isEmpty,
            ),

            _buildInfoRow(
              Icons.email,
              'Email',
              profile.email,
              false,
              trailing: profile.isEmailVerified
                  ? Icon(Icons.verified, size: 16, color: AppColors.success)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Unverified',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
            ),

            _buildInfoRow(
              Icons.phone,
              'Phone',
              profile.phoneNumber ?? 'Not set',
              profile.phoneNumber == null,
            ),

            if (profile.bio != null && profile.bio!.isNotEmpty)
              _buildInfoRow(
                Icons.info_outline,
                'Bio',
                profile.bio!,
                false,
                isMultiline: true,
              ),

            _buildInfoRow(
              Icons.calendar_today,
              'Member Since',
              _formatDate(profile.createdAt),
              false,
            ),

            if (profile.isTwoFactorEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Two-Factor Authentication Enabled',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isEmpty, {
    Widget? trailing,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isEmpty ? AppColors.onSurfaceVariant : null,
                    fontStyle: isEmpty ? FontStyle.italic : null,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return _formatDate(dateTime);
    }
  }
}
