import 'package:flutter/material.dart';
import 'package:flutter_auth_template/domain/entities/user_profile.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class ProfileCompletionCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onComplete;

  const ProfileCompletionCard({
    super.key,
    required this.profile,
    this.onComplete,
  });

  double _calculateCompletion() {
    int totalFields = 7;
    int completedFields = 0;

    if (profile.firstName != null && profile.firstName!.isNotEmpty) completedFields++;
    if (profile.email.isNotEmpty) completedFields++;
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) completedFields++;
    if (profile.bio != null && profile.bio!.isNotEmpty) completedFields++;
    if (profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty)
      completedFields++;
    if (profile.isEmailVerified) completedFields++;
    if (profile.isTwoFactorEnabled) completedFields++;

    return completedFields / totalFields;
  }

  List<String> _getMissingFields() {
    List<String> missing = [];

    if (profile.firstName == null || profile.firstName!.isEmpty) missing.add('Name');
    if (profile.phoneNumber == null || profile.phoneNumber!.isEmpty)
      missing.add('Phone Number');
    if (profile.bio == null || profile.bio!.isEmpty) missing.add('Bio');
    if (profile.profileImageUrl == null || profile.profileImageUrl!.isEmpty)
      missing.add('Profile Picture');
    if (!profile.isEmailVerified) missing.add('Email Verification');
    if (!profile.isTwoFactorEnabled) missing.add('Two-Factor Authentication');

    return missing;
  }

  Color _getCompletionColor(double completion) {
    if (completion >= 0.8) return AppColors.success;
    if (completion >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final completion = _calculateCompletion();
    final missingFields = _getMissingFields();

    if (completion >= 1.0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Complete!',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'Your profile is 100% complete',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile Completion', style: AppTextStyles.titleMedium),
                Text(
                  '${(completion * 100).toInt()}%',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _getCompletionColor(completion),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completion,
                minHeight: 8,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCompletionColor(completion),
                ),
              ),
            ),

            if (missingFields.isNotEmpty) ...[
              const SizedBox(height: 16),

              Text(
                'Complete your profile to:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              _buildBenefit('Enhance account security'),
              _buildBenefit('Unlock all features'),
              _buildBenefit('Improve personalization'),

              const SizedBox(height: 16),

              Text(
                'Missing: ${missingFields.join(', ')}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCompletionColor(completion),
                  ),
                  child: const Text('Complete Profile'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
