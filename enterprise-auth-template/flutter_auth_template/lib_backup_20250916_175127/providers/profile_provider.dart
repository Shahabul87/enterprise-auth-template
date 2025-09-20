import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/entities/user_profile.dart';
import '../services/api/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../presentation/providers/auth_provider.dart';

part 'profile_provider.freezed.dart';

/// Profile state
@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    UserProfile? profile,
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    String? error,
    String? updateError,
  }) = _ProfileState;

  const ProfileState._();

  bool get hasProfile => profile != null;
  bool get isVerified => profile?.isEmailVerified ?? false;
  bool get has2FA => profile?.isTwoFactorEnabled ?? false;
}

/// Profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ApiClient _apiClient;
  final SecureStorageService _storage;
  final Ref _ref;

  ProfileNotifier({
    required ApiClient apiClient,
    required SecureStorageService storage,
    required Ref ref,
  }) : _apiClient = apiClient,
       _storage = storage,
       _ref = ref,
       super(const ProfileState());

  /// Load user profile
  Future<void> loadProfile() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.get('/users/profile');

      if (response.statusCode == 200) {
        final profile = UserProfile.fromJson(response.data);
        state = state.copyWith(profile: profile, isLoading: false);

        // Cache profile data
        await _storage.saveUserProfile(profile);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load cached profile
  Future<void> loadCachedProfile() async {
    try {
      final cachedProfileJson = await _storage.getUserProfile();
      if (cachedProfileJson != null &&
          cachedProfileJson is Map<String, dynamic>) {
        final cachedProfile = UserProfile.fromJson(cachedProfileJson);
        state = state.copyWith(profile: cachedProfile);
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
    Map<String, dynamic>? metadata,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, updateError: null);

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (bio != null) data['bio'] = bio;
      if (metadata != null) data['metadata'] = metadata;

      final response = await _apiClient.patch('/users/profile', data: data);

      if (response.statusCode == 200) {
        final updatedProfile = UserProfile.fromJson(response.data);
        state = state.copyWith(profile: updatedProfile, isUpdating: false);

        // Update cache
        await _storage.saveUserProfile(updatedProfile);
        return true;
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false, updateError: e.toString());
      return false;
    }
  }

  /// Update avatar
  Future<bool> updateAvatar(String imagePath) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, updateError: null);

    try {
      // Create form data for image upload
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imagePath,
          filename: 'avatar.jpg',
        ),
      });

      final response = await _apiClient.post(
        '/users/profile/avatar',
        data: formData,
      );

      if (response.statusCode == 200) {
        final profileImageUrl = response.data['profileImageUrl'] ?? response.data['avatarUrl'];
        final updatedProfile = state.profile?.copyWith(profileImageUrl: profileImageUrl);

        if (updatedProfile != null) {
          state = state.copyWith(profile: updatedProfile, isUpdating: false);

          // Update cache
          await _storage.saveUserProfile(updatedProfile);
        }
        return true;
      } else {
        throw Exception('Failed to update avatar');
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false, updateError: e.toString());
      return false;
    }
  }

  /// Delete avatar
  Future<bool> deleteAvatar() async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, updateError: null);

    try {
      final response = await _apiClient.delete('/users/profile/avatar');

      if (response.statusCode == 200) {
        final updatedProfile = state.profile?.copyWith(profileImageUrl: null);

        if (updatedProfile != null) {
          state = state.copyWith(profile: updatedProfile, isUpdating: false);

          // Update cache
          await _storage.saveUserProfile(updatedProfile);
        }
        return true;
      } else {
        throw Exception('Failed to delete avatar');
      }
    } catch (e) {
      state = state.copyWith(isUpdating: false, updateError: e.toString());
      return false;
    }
  }

  /// Enable 2FA
  Future<Map<String, dynamic>?> enable2FA() async {
    try {
      final response = await _apiClient.post('/users/profile/2fa/enable');

      if (response.statusCode == 200) {
        // Update profile state
        final updatedProfile = state.profile?.copyWith(isTwoFactorEnabled: true);

        if (updatedProfile != null) {
          state = state.copyWith(profile: updatedProfile);
          await _storage.saveUserProfile(updatedProfile);
        }

        return response.data; // Contains QR code and backup codes
      }
    } catch (e) {
      state = state.copyWith(updateError: e.toString());
    }
    return null;
  }

  /// Disable 2FA
  Future<bool> disable2FA(String code) async {
    try {
      final response = await _apiClient.post(
        '/users/profile/2fa/disable',
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        // Update profile state
        final updatedProfile = state.profile?.copyWith(isTwoFactorEnabled: false);

        if (updatedProfile != null) {
          state = state.copyWith(profile: updatedProfile);
          await _storage.saveUserProfile(updatedProfile);
        }
        return true;
      }
    } catch (e) {
      state = state.copyWith(updateError: e.toString());
    }
    return false;
  }

  /// Request email verification
  Future<bool> requestEmailVerification() async {
    try {
      final response = await _apiClient.post('/users/profile/verify-email');
      return response.statusCode == 200;
    } catch (e) {
      state = state.copyWith(updateError: e.toString());
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, updateError: null);

    try {
      final response = await _apiClient.post(
        '/users/profile/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      state = state.copyWith(isUpdating: false);
      return response.statusCode == 200;
    } catch (e) {
      state = state.copyWith(isUpdating: false, updateError: e.toString());
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      final response = await _apiClient.delete(
        '/users/profile',
        data: {'password': password},
      );

      if (response.statusCode == 200) {
        // Clear all data and logout
        await _storage.clearAll();
        _ref.read(authStateProvider.notifier).logout();
        return true;
      }
    } catch (e) {
      state = state.copyWith(updateError: e.toString());
    }
    return false;
  }

  /// Clear profile
  void clearProfile() {
    state = const ProfileState();
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    await loadProfile();
  }
}

/// Profile provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);

  return ProfileNotifier(apiClient: apiClient, storage: storage, ref: ref);
});

/// Computed providers
final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(profileProvider).profile;
});

final isProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isLoading;
});

final isProfileVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isVerified;
});

final has2FAEnabledProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).has2FA;
});

/// Profile initialization provider
final profileInitializerProvider = FutureProvider<void>((ref) async {
  final authState = ref.watch(authStateProvider);

  if (authState.isAuthenticated) {
    final profileNotifier = ref.read(profileProvider.notifier);

    // Load cached profile first
    await profileNotifier.loadCachedProfile();

    // Then fetch fresh data
    await profileNotifier.loadProfile();
  }
});

/// FormData class for multipart uploads
class FormData {
  final Map<String, dynamic> fields;

  FormData.fromMap(this.fields);
}

/// MultipartFile class for file uploads
class MultipartFile {
  final String path;
  final String filename;

  MultipartFile._(this.path, this.filename);

  static Future<MultipartFile> fromFile(String path, {String? filename}) async {
    return MultipartFile._(path, filename ?? 'file');
  }
}
