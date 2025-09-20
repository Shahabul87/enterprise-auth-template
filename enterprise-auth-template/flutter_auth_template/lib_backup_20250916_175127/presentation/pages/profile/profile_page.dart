import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/entities/user_profile.dart';
import '../../../domain/entities/auth_state.dart';
import '../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final authNotifier = ref.read(authStateProvider.notifier);

    // Form controllers
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final bioController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // State
    final isEditing = useState(false);
    final isLoading = useState(false);
    final selectedImage = useState<XFile?>(null);
    final errorMessage = useState<String?>(null);
    final successMessage = useState<String?>(null);

    // Initialize form with current user data
    useEffect(() {
      authState.whenOrNull(
        authenticated: (user, _, __) {
          firstNameController.text = user.firstName ?? '';
          lastNameController.text = user.lastName ?? '';
          emailController.text = user.email;
          phoneController.text = user.phoneNumber ?? '';
          bioController.text = user.bio ?? '';
        },
      );
      return null;
    }, [authState]);

    // Handle image selection
    Future<void> handleImageSelection() async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );

        if (image != null) {
          selectedImage.value = image;
        }
      } catch (e) {
        errorMessage.value = 'Failed to select image: $e';
      }
    }

    // Handle camera capture
    Future<void> handleCameraCapture() async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );

        if (image != null) {
          selectedImage.value = image;
        }
      } catch (e) {
        errorMessage.value = 'Failed to capture image: $e';
      }
    }

    // Handle profile update
    Future<void> handleProfileUpdate() async {
      if (!formKey.currentState!.validate()) return;

      try {
        isLoading.value = true;
        errorMessage.value = null;
        successMessage.value = null;

        final currentUser = authState.whenOrNull(
          authenticated: (user, _, __) => user,
        );

        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        await profileNotifier.updateProfile(
          name: '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim().isNotEmpty
              ? phoneController.text.trim()
              : null,
          bio: bioController.text.trim().isNotEmpty
              ? bioController.text.trim()
              : null,
        );

        successMessage.value = 'Profile updated successfully!';
        isEditing.value = false;
        selectedImage.value = null;
      } catch (e) {
        errorMessage.value = 'Failed to update profile: $e';
      } finally {
        isLoading.value = false;
      }
    }

    // Handle account deletion
    Future<void> handleDeleteAccount() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          isLoading.value = true;
          // TODO: Implement account deletion API
          await authNotifier.logout();
          if (context.mounted) {
            context.go('/login');
          }
        } catch (e) {
          errorMessage.value = 'Failed to delete account: $e';
        } finally {
          isLoading.value = false;
        }
      }
    }

    // Show image selection options
    void showImageSelectionOptions() {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  handleImageSelection();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  handleCameraCapture();
                },
              ),
              if (selectedImage.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    selectedImage.value = null;
                  },
                ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (isEditing.value)
                TextButton(
                  onPressed: () {
                    isEditing.value = false;
                    selectedImage.value = null;
                    errorMessage.value = null;
                    successMessage.value = null;
                    // Reset form
                    authState.whenOrNull(
                      authenticated: (user, _, __) {
                        firstNameController.text = user.firstName ?? '';
                        lastNameController.text = user.lastName ?? '';
                        emailController.text = user.email;
                        phoneController.text = user.phoneNumber ?? '';
                        bioController.text = user.bio ?? '';
                      },
                    );
                  },
                  child: const Text('Cancel'),
                )
              else
                IconButton(
                  onPressed: () {
                    isEditing.value = true;
                    errorMessage.value = null;
                    successMessage.value = null;
                  },
                  icon: const Icon(Icons.edit),
                ),
            ],
          ),
          body: authState.when(
            authenticated: (user, _, __) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: isEditing.value
                                ? showImageSelectionOptions
                                : null,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              backgroundImage: selectedImage.value != null
                                  ? FileImage(File(selectedImage.value!.path))
                                  : user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                      as ImageProvider
                                  : null,
                              child:
                                  selectedImage.value == null &&
                                      user.profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                          ),
                          if (isEditing.value)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  onPressed: showImageSelectionOptions,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Success Message
                    if (successMessage.value != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                successMessage.value!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Error Message
                    if (errorMessage.value != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.error),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage.value!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Form Fields
                    TextFormField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      enabled: isEditing.value,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'First name is required';
                        }
                        if (value!.trim().length < 2) {
                          return 'First name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      enabled: isEditing.value,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Last name is required';
                        }
                        if (value!.trim().length < 2) {
                          return 'Last name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      enabled: isEditing.value,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      enabled: isEditing.value,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: bioController,
                      decoration: InputDecoration(
                        labelText: 'Bio (Optional)',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      enabled: isEditing.value,
                      maxLines: 3,
                      maxLength: 500,
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    if (isEditing.value) ...[
                      ElevatedButton(
                        onPressed: isLoading.value ? null : handleProfileUpdate,
                        child: isLoading.value
                            ? CircularProgressIndicator()
                            : Text('Save Changes'),
                      ),
                    ] else ...[
                      // Security Settings Button
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/settings/security');
                        },
                        icon: const Icon(Icons.security),
                        label: const Text('Security Settings'),
                      ),

                      const SizedBox(height: 12),

                      // Change Password Button
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/settings/change-password');
                        },
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Change Password'),
                      ),

                      const SizedBox(height: 12),

                      // Notification Settings Button
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/settings/notifications');
                        },
                        icon: const Icon(Icons.notifications_outlined),
                        label: const Text('Notification Settings'),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Account Information Section
                    if (!isEditing.value) ...[
                      const Divider(),
                      const SizedBox(height: 16),

                      Text(
                        'Account Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildInfoRow(
                        'Account Created',
                        user.createdAt.toString().split(' ')[0],
                      ),
                      _buildInfoRow(
                        'Last Updated',
                        user.updatedAt.toString().split(' ')[0],
                      ),
                      _buildInfoRow('User ID', user.id),

                      const SizedBox(height: 32),

                      // Danger Zone
                      const Divider(color: Colors.red),
                      const SizedBox(height: 16),

                      Text(
                        'Danger Zone',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),

                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: handleDeleteAccount,
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            authenticating: () =>
                const Center(child: CircularProgressIndicator()),
            unauthenticated: () =>
                const Center(child: Text('Please log in to view your profile')),
            error: (message) =>
                Center(child: Text('Error loading profile: $message')),
          ),
        ),
        if (isLoading.value) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
