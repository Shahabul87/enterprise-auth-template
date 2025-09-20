import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// User profile model
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? name,
    String? avatarUrl,
    String? phone,
    String? bio,
    @Default(false) bool emailVerified,
    @Default(false) bool phoneVerified,
    @Default(false) bool twoFactorEnabled,
    @Default([]) List<String> roles,
    @Default({}) Map<String, dynamic> metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    ProfileSettings? settings,
  }) = _UserProfile;

  const UserProfile._();

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Get display name
  String get displayName => name ?? email.split('@').first;

  /// Get initials for avatar
  String get initials {
    if (name != null && name!.isNotEmpty) {
      final parts = name!.trim().split(' ');
      if (parts.length > 1) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first.substring(0, 1).toUpperCase();
    }
    return email.substring(0, 1).toUpperCase();
  }

  /// Check if user has role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is admin
  bool get isAdmin => hasRole('admin') || hasRole('super_admin');

  /// Check if profile is complete
  bool get isProfileComplete {
    return name != null &&
        name!.isNotEmpty &&
        emailVerified &&
        (phone == null || phoneVerified);
  }

  /// Get profile completion percentage
  double get profileCompletion {
    int completed = 0;
    int total = 5; // Base fields to complete

    if (name != null && name!.isNotEmpty) completed++;
    if (emailVerified) completed++;
    if (phone != null && phone!.isNotEmpty) completed++;
    if (avatarUrl != null) completed++;
    if (bio != null && bio!.isNotEmpty) completed++;

    if (twoFactorEnabled) {
      completed++;
      total++;
    }

    return completed / total;
  }
}

/// Profile settings model
@freezed
class ProfileSettings with _$ProfileSettings {
  const factory ProfileSettings({
    @Default(true) bool emailNotifications,
    @Default(true) bool pushNotifications,
    @Default(false) bool smsNotifications,
    @Default(true) bool marketingEmails,
    @Default(true) bool securityAlerts,
    @Default('en') String language,
    @Default('UTC') String timezone,
    @Default('light') String theme,
    @Default({}) Map<String, dynamic> preferences,
  }) = _ProfileSettings;

  factory ProfileSettings.fromJson(Map<String, dynamic> json) =>
      _$ProfileSettingsFromJson(json);
}

/// Profile update request model
@freezed
class ProfileUpdateRequest with _$ProfileUpdateRequest {
  const factory ProfileUpdateRequest({
    String? name,
    String? phone,
    String? bio,
    Map<String, dynamic>? metadata,
    ProfileSettings? settings,
  }) = _ProfileUpdateRequest;

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestFromJson(json);
}

/// Profile statistics model
@freezed
class ProfileStatistics with _$ProfileStatistics {
  const factory ProfileStatistics({
    @Default(0) int loginCount,
    @Default(0) int sessionsActive,
    @Default(0) int devicesLinked,
    DateTime? lastPasswordChange,
    DateTime? last2FAChange,
    @Default([]) List<LoginHistory> recentLogins,
    @Default({}) Map<String, int> activityStats,
  }) = _ProfileStatistics;

  factory ProfileStatistics.fromJson(Map<String, dynamic> json) =>
      _$ProfileStatisticsFromJson(json);
}

/// Login history model
@freezed
class LoginHistory with _$LoginHistory {
  const factory LoginHistory({
    required String id,
    required DateTime timestamp,
    String? ipAddress,
    String? userAgent,
    String? location,
    String? device,
    @Default(true) bool successful,
    String? failureReason,
  }) = _LoginHistory;

  factory LoginHistory.fromJson(Map<String, dynamic> json) =>
      _$LoginHistoryFromJson(json);
}

/// Privacy settings model
@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    @Default('public') String profileVisibility, // public, friends, private
    @Default(true) bool showEmail,
    @Default(false) bool showPhone,
    @Default(true) bool showLastSeen,
    @Default(true) bool showOnlineStatus,
    @Default([]) List<String> blockedUsers,
    @Default({}) Map<String, bool> dataSharing,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
}
