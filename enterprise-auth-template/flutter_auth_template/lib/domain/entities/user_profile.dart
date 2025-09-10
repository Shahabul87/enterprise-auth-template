import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phoneNumber,
    String? bio,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? address,
    String? timezone,
    String? locale,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool isActive,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isTwoFactorEnabled,
    List<String>? roles,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class UserProfileUpdate with _$UserProfileUpdate {
  const factory UserProfileUpdate({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? address,
    String? timezone,
    String? locale,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) = _UserProfileUpdate;

  factory UserProfileUpdate.fromJson(Map<String, dynamic> json) =>
      _$UserProfileUpdateFromJson(json);
}
