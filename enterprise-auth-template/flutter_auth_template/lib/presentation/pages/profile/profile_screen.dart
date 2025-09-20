import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_auth_template/presentation/providers/profile_provider.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/presentation/widgets/loading_indicators.dart';
import 'package:flutter_auth_template/presentation/widgets/profile/profile_avatar.dart';
import 'package:flutter_auth_template/presentation/widgets/profile/profile_completion_card.dart';
import 'package:flutter_auth_template/presentation/widgets/profile/profile_info_card.dart';
import 'package:flutter_auth_template/presentation/widgets/profile/profile_settings_tile.dart';
import 'package:flutter_auth_template/core/theme/app_colors.dart';
import 'package:flutter_auth_template/core/theme/app_text_styles.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  Future<void> _refreshProfile() async {
    await ref.read(profileProvider.notifier).refreshProfile();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      await ref.read(profileProvider.notifier).updateAvatar(image.path);
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    await ref
                        .read(profileProvider.notifier)
                        .updateAvatar(image.path);
                  }
                },
              ),
              if (ref.read(currentUserProvider)?.profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Remove Photo'),
                  textColor: AppColors.error,
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(profileProvider.notifier).deleteAvatar();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEditProfile() {
    Navigator.pushNamed(context, '/profile/edit');
  }

  void _navigateToChangePassword() {
    Navigator.pushNamed(context, '/profile/change-password');
  }

  void _navigateToPrivacySettings() {
    Navigator.pushNamed(context, '/profile/privacy');
  }

  void _navigateToNotificationSettings() {
    Navigator.pushNamed(context, '/profile/notifications');
  }

  void _navigateToSecuritySettings() {
    Navigator.pushNamed(context, '/profile/security');
  }

  void _navigateToAccountSettings() {
    Navigator.pushNamed(context, '/profile/account-settings');
  }

  void _navigateToExportData() {
    Navigator.pushNamed(context, '/profile/export');
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile/delete-account');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = ref.watch(currentUserProvider);

    // Listen to errors and success messages
    ref.listen(profileProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        _showError(next.error!);
      }
      if (next.updateError != null &&
          next.updateError != previous?.updateError) {
        _showError(next.updateError!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: profileState.isLoading,
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: ProfileAvatar(
                          avatarUrl: profile?.profileImageUrl,
                          name: profile?.firstName != null ? '${profile?.firstName} ${profile?.lastName ?? ''}'.trim() : profile?.email ?? '',
                          size: 100,
                          isUploading: profileState.isUpdating,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name and Email
                      Text(
                        profile?.firstName != null ? '${profile?.firstName} ${profile?.lastName ?? ''}'.trim() : 'User',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile?.email ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),

                      // Verification Status
                      if (profile != null && !profile.isEmailVerified) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Email not verified',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Profile Completion Card
                if (profile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ProfileCompletionCard(
                      profile: profile,
                      onComplete: _navigateToEditProfile,
                    ),
                  ),

                const SizedBox(height: 16),

                // Profile Information
                if (profile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ProfileInfoCard(profile: profile),
                  ),

                const SizedBox(height: 24),

                // Settings Sections
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Settings',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Security
                      ProfileSettingsTile(
                        icon: Icons.security,
                        title: 'Security',
                        subtitle: 'Password, 2FA, login history',
                        onTap: _navigateToSecuritySettings,
                        showBadge: profile?.isTwoFactorEnabled == false,
                      ),

                      // Privacy
                      ProfileSettingsTile(
                        icon: Icons.privacy_tip,
                        title: 'Privacy',
                        subtitle: 'Profile visibility, data sharing',
                        onTap: _navigateToPrivacySettings,
                      ),

                      // Notifications
                      ProfileSettingsTile(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Email, push, and SMS preferences',
                        onTap: _navigateToNotificationSettings,
                      ),

                      // Account Settings
                      ProfileSettingsTile(
                        icon: Icons.settings,
                        title: 'Account Settings',
                        subtitle: 'Language, timezone, date format',
                        onTap: _navigateToAccountSettings,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Data & Privacy',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Export Data
                      ProfileSettingsTile(
                        icon: Icons.download,
                        title: 'Export My Data',
                        subtitle: 'Download your personal data',
                        onTap: _navigateToExportData,
                      ),

                      // Delete Account
                      ProfileSettingsTile(
                        icon: Icons.delete_forever,
                        title: 'Delete Account',
                        subtitle: 'Permanently delete your account',
                        onTap: _showDeleteAccountDialog,
                        isDestructive: true,
                      ),

                      const SizedBox(height: 24),

                      // Sign Out Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authStateProvider.notifier).logout();
                            if (mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
