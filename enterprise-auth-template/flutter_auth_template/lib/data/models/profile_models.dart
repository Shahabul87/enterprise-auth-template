import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

/// Profile response model
@freezed
class ProfileResponse with _$ProfileResponse {
  const factory ProfileResponse({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? bio,
    String? avatarUrl,
    String? timezone,
    String? language,
    required bool isActive,
    required bool isVerified,
    required List<String> roles,
    required String createdAt,
    required String updatedAt,
    String? lastLogin,
  }) = _ProfileResponse;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
}

/// Profile update request model
@freezed
class ProfileUpdateRequest with _$ProfileUpdateRequest {
  const factory ProfileUpdateRequest({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    String? timezone,
    String? language,
  }) = _ProfileUpdateRequest;

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestFromJson(json);
}

/// Password change request model
@freezed
class PasswordChangeRequest with _$PasswordChangeRequest {
  const factory PasswordChangeRequest({
    required String currentPassword,
    required String newPassword,
  }) = _PasswordChangeRequest;

  factory PasswordChangeRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordChangeRequestFromJson(json);
}

/// Email change request model
@freezed
class EmailChangeRequest with _$EmailChangeRequest {
  const factory EmailChangeRequest({
    required String newEmail,
    required String password,
  }) = _EmailChangeRequest;

  factory EmailChangeRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailChangeRequestFromJson(json);
}

/// Notification preferences request model
@freezed
class NotificationPreferencesRequest with _$NotificationPreferencesRequest {
  const factory NotificationPreferencesRequest({
    @Default(true) bool emailNotifications,
    @Default(true) bool pushNotifications,
    @Default(false) bool smsNotifications,
    @Default(false) bool marketingEmails,
    @Default(true) bool securityAlerts,
  }) = _NotificationPreferencesRequest;

  factory NotificationPreferencesRequest.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesRequestFromJson(json);
}

/// Security settings response model
@freezed
class SecuritySettingsResponse with _$SecuritySettingsResponse {
  const factory SecuritySettingsResponse({
    required bool twoFactorEnabled,
    required bool loginAlerts,
    required int sessionTimeout,
    String? passwordLastChanged,
    required int activeSessions,
  }) = _SecuritySettingsResponse;

  factory SecuritySettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$SecuritySettingsResponseFromJson(json);
}

/// Avatar upload response model
@freezed
class AvatarUploadResponse with _$AvatarUploadResponse {
  const factory AvatarUploadResponse({
    required String avatarUrl,
    required String message,
  }) = _AvatarUploadResponse;

  factory AvatarUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$AvatarUploadResponseFromJson(json);
}

/// Profile completion status model
@freezed
class ProfileCompletionStatus with _$ProfileCompletionStatus {
  const factory ProfileCompletionStatus({
    required double completionPercentage,
    required List<String> completedFields,
    required List<String> missingFields,
    required List<String> suggestions,
  }) = _ProfileCompletionStatus;

  factory ProfileCompletionStatus.fromJson(Map<String, dynamic> json) =>
      _$ProfileCompletionStatusFromJson(json);
}

/// Privacy settings model
@freezed
class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    @Default(false) bool profilePublic,
    @Default(false) bool showEmail,
    @Default(false) bool showPhone,
    @Default(true) bool showName,
    @Default(false) bool showLocation,
    @Default(true) bool allowMessaging,
    @Default(true) bool allowFriendRequests,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
}

/// Account settings model
@freezed
class AccountSettings with _$AccountSettings {
  const factory AccountSettings({
    required String language,
    required String timezone,
    required String dateFormat,
    required String timeFormat,
    @Default(true) bool use24HourTime,
    @Default('USD') String currency,
    @Default('en_US') String locale,
  }) = _AccountSettings;

  factory AccountSettings.fromJson(Map<String, dynamic> json) =>
      _$AccountSettingsFromJson(json);
}

/// Profile statistics model
@freezed
class ProfileStatistics with _$ProfileStatistics {
  const factory ProfileStatistics({
    required int loginCount,
    required int sessionCount,
    required String accountAge,
    required String lastPasswordChange,
    required int securityScore,
    required Map<String, int> activityBreakdown,
  }) = _ProfileStatistics;

  factory ProfileStatistics.fromJson(Map<String, dynamic> json) =>
      _$ProfileStatisticsFromJson(json);
}

/// Supported timezones
class SupportedTimezones {
  static const List<String> timezones = [
    'UTC',
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'America/Toronto',
    'America/Vancouver',
    'America/Mexico_City',
    'America/Sao_Paulo',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Europe/Madrid',
    'Europe/Rome',
    'Europe/Moscow',
    'Asia/Dubai',
    'Asia/Kolkata',
    'Asia/Shanghai',
    'Asia/Hong_Kong',
    'Asia/Tokyo',
    'Asia/Seoul',
    'Asia/Singapore',
    'Australia/Sydney',
    'Australia/Melbourne',
    'Pacific/Auckland',
  ];

  static String getDisplayName(String timezone) {
    return timezone.replaceAll('_', ' ').split('/').last;
  }

  static String getOffset(String timezone) {
    // This would need actual timezone offset calculation
    // For now, returning placeholder
    return 'UTC+0';
  }
}

/// Supported languages
class SupportedLanguages {
  static const Map<String, String> languages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ar': 'Arabic',
    'hi': 'Hindi',
  };

  static String getDisplayName(String code) {
    return languages[code] ?? code;
  }
}

/// Profile validation helper
class ProfileValidator {
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return true;
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  static bool isValidTimezone(String? timezone) {
    if (timezone == null || timezone.isEmpty) return true;
    return SupportedTimezones.timezones.contains(timezone);
  }

  static bool isValidLanguage(String? language) {
    if (language == null || language.isEmpty) return true;
    return SupportedLanguages.languages.containsKey(language);
  }

  static bool isValidBio(String? bio) {
    if (bio == null) return true;
    return bio.length <= 500;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'First name must be less than 50 characters';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Last name must be less than 50 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!isValidPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > 500) {
      return 'Bio must be less than 500 characters';
    }
    return null;
  }

  static double calculateProfileCompletion(ProfileResponse profile) {
    int totalFields = 8;
    int completedFields = 0;

    if (profile.firstName.isNotEmpty) completedFields++;
    if (profile.lastName.isNotEmpty) completedFields++;
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
      completedFields++;
    if (profile.bio != null && profile.bio!.isNotEmpty) completedFields++;
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
      completedFields++;
    if (profile.timezone != null && profile.timezone!.isNotEmpty)
      completedFields++;
    if (profile.language != null && profile.language!.isNotEmpty)
      completedFields++;
    if (profile.isVerified) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  static List<String> getMissingFields(ProfileResponse profile) {
    List<String> missing = [];

    if (profile.firstName.isEmpty) missing.add('First Name');
    if (profile.lastName.isEmpty) missing.add('Last Name');
    if (profile.phoneNumber == null || profile.phoneNumber!.isEmpty)
      missing.add('Phone Number');
    if (profile.bio == null || profile.bio!.isEmpty) missing.add('Bio');
    if (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
      missing.add('Profile Picture');
    if (profile.timezone == null || profile.timezone!.isEmpty)
      missing.add('Timezone');
    if (profile.language == null || profile.language!.isEmpty)
      missing.add('Language');
    if (!profile.isVerified) missing.add('Email Verification');

    return missing;
  }
}
