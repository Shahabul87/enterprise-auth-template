import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_auth_template/presentation/providers/profile_provider.dart';
import 'package:flutter_auth_template/presentation/providers/auth_provider.dart';
import 'package:flutter_auth_template/presentation/widgets/avatar_component.dart';
import 'package:flutter_auth_template/presentation/widgets/buttons/custom_buttons.dart';
import 'package:flutter_auth_template/presentation/widgets/dialog_components.dart';
import 'package:flutter_auth_template/presentation/widgets/shimmer_loading.dart';
import 'package:flutter_auth_template/domain/entities/user_profile.dart';
import 'package:flutter_auth_template/core/responsive/responsive.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isEditing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = ref.read(currentUserProvider);
    if (profile != null) {
      _nameController.text = '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
      _emailController.text = profile.email;
      _phoneController.text = profile.phoneNumber ?? '';
      _bioController.text = profile.bio ?? '';
    } else {
      // Load profile if not already loaded
      ref.read(profileProvider.notifier).loadProfile();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    if (profileState.isLoading && profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: _buildLoadingState(),
      );
    }

    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: deviceType == DeviceType.mobile,
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => setState(() => _isEditing = true),
                )
              else
                Row(
                  children: [
                    TextButton(
                      onPressed: _cancelEditing,
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: _saveProfile,
                      child: const Text('Save'),
                    ),
                  ],
                ),
            ],
          ),
          body: deviceType == DeviceType.desktop
              ? _buildDesktopLayout(context, profile)
              : _buildMobileLayout(context, profile),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, UserProfile? profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar with avatar and stats
        SizedBox(width: 320, child: _buildProfileSidebar(context, profile)),
        const VerticalDivider(width: 1),
        // Main content area
        Expanded(child: _buildProfileContent(context, profile)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, UserProfile? profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(context, profile),
          _buildProfileContent(context, profile),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ShimmerBox(width: 120, height: 120, shape: BoxShape.circle),
          const SizedBox(height: 16),
          const ShimmerBox(height: 24, width: 150),
          const SizedBox(height: 8),
          const ShimmerBox(height: 16, width: 200),
          const SizedBox(height: 32),
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ShimmerBox(
                height: 56,
                width: double.infinity,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSidebar(BuildContext context, UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAvatarSection(context, profile),
          const SizedBox(height: 24),
          _buildProfileStats(context, profile),
          const SizedBox(height: 24),
          _buildQuickActions(context, profile),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAvatarSection(context, profile),
          const SizedBox(height: 24),
          _buildProfileStats(context, profile),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, UserProfile? profile) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          children: [
            EditableAvatar(
              imageUrl: profile?.profileImageUrl,
              name: profile?.firstName != null ? '${profile?.firstName} ${profile?.lastName ?? ''}'.trim() : profile?.email,
              size: 120,
              onEdit: _isEditing ? _changeAvatar : null,
            ),
            if (profile?.isEmailVerified == true)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile?.firstName != null ? '${profile?.firstName} ${profile?.lastName ?? ''}'.trim() : 'User',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile?.email ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        if (profile?.roles?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: profile!.roles!
                .map<Widget>(
                  (role) => Chip(
                    label: Text(role.toUpperCase()),
                    labelStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileStats(BuildContext context, UserProfile? profile) {
    final theme = Theme.of(context);
    final completionPercentage = 75; // Default profile completion percentage

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Completion',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.75, // Default profile completion value
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                completionPercentage >= 80
                    ? Colors.green
                    : completionPercentage >= 50
                    ? Colors.orange
                    : Colors.red,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${completionPercentage.toInt()}% Complete',
              style: theme.textTheme.bodySmall,
            ),
            if (completionPercentage < 100) ...[
              const SizedBox(height: 12),
              Text(
                'Complete your profile to unlock all features',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserProfile? profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: 'Change Password',
          icon: const Icon(Icons.lock_outline, size: 20),
          onPressed: () => context.push('/settings/change-password'),
          type: ButtonType.secondary,
          isFullWidth: true,
        ),
        const SizedBox(height: 8),
        CustomButton(
          text: 'Security Settings',
          icon: const Icon(Icons.security, size: 20),
          onPressed: () => context.push('/settings/security'),
          type: ButtonType.secondary,
          isFullWidth: true,
        ),
        const SizedBox(height: 8),
        CustomButton(
          text: 'Privacy Settings',
          icon: const Icon(Icons.privacy_tip_outlined, size: 20),
          onPressed: () => context.push('/settings/privacy'),
          type: ButtonType.secondary,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile? profile) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              enabled: false, // Email usually can't be changed directly
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: profile?.isEmailVerified == true
                    ? const Icon(Icons.verified, color: Colors.green)
                    : TextButton(
                        onPressed: _requestEmailVerification,
                        child: const Text('Verify'),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: (profile?.phoneNumber != null)
                    ? const Icon(Icons.verified, color: Colors.green)
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            // Bio Field
            TextFormField(
              controller: _bioController,
              enabled: _isEditing,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bio',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            // Account Information Section
            Text(
              'Account Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow('User ID', profile?.id ?? ''),
            _buildInfoRow('Member Since', _formatDate(profile?.createdAt)),
            _buildInfoRow('Last Updated', _formatDate(profile?.updatedAt)),
            _buildInfoRow('Last Login', _formatDate(profile?.updatedAt)),

            const SizedBox(height: 32),

            // Security Status Section
            Text(
              'Security Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildSecurityStatus(context, profile),

            const SizedBox(height: 32),

            // Danger Zone
            if (!_isEditing) ...[
              Text(
                'Danger Zone',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Account',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Once you delete your account, there is no going back. Please be certain.',
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Delete Account',
                        onPressed: _deleteAccount,
                        type: ButtonType.primary,
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not set' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: value.isEmpty
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus(BuildContext context, UserProfile? profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSecurityItem(
              context,
              'Email Verified',
              profile?.isEmailVerified ?? false,
              onAction: profile?.isEmailVerified == false
                  ? _requestEmailVerification
                  : null,
            ),
            const Divider(),
            _buildSecurityItem(
              context,
              'Two-Factor Authentication',
              profile?.isTwoFactorEnabled ?? false,
              onAction: () => context.push('/settings/security'),
            ),
            const Divider(),
            _buildSecurityItem(
              context,
              'Phone Verified',
              (profile?.phoneNumber != null),
              onAction:
                  (profile?.phoneNumber == null)
                  ? _requestPhoneVerification
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem(
    BuildContext context,
    String label,
    bool enabled, {
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(enabled ? 'Configure' : 'Enable'),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _changeAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context);
                _removeAvatar();
              },
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        await ref.read(profileProvider.notifier).updateAvatar(image.path);
      }
    }
  }

  void _removeAvatar() async {
    await ref.read(profileProvider.notifier).deleteAvatar();
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _loadProfile(); // Reset form fields
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(profileProvider.notifier)
          .updateProfile(
            name: _nameController.text,
            phone: _phoneController.text,
            bio: _bioController.text,
          );

      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  void _requestEmailVerification() async {
    final success = await ref
        .read(profileProvider.notifier)
        .requestEmailVerification();
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification email sent')));
    }
  }

  void _requestPhoneVerification() {
    // Implement phone verification
    context.push('/verify-phone');
  }

  void _deleteAccount() async {
    final confirmed = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Delete Account',
      message:
          'Are you sure you want to delete your account? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Theme.of(context).colorScheme.error,
    );

    if (confirmed == true) {
      // Show password confirmation dialog
      final password = await InputDialog.show(
        context: context,
        title: 'Confirm Password',
        labelText: 'Enter your password to confirm',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          return null;
        },
      );

      if (password != null) {
        final success = await ref
            .read(profileProvider.notifier)
            .deleteAccount(password);
        if (success) {
          context.go('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account')),
          );
        }
      }
    }
  }
}

/// Image picker wrapper class
class ImagePicker {
  Future<XFile?> pickImage({required ImageSource source}) async {
    // Mock implementation - replace with actual image_picker
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }
}

class XFile {
  final String path;
  XFile(this.path);
}

enum ImageSource { camera, gallery }
