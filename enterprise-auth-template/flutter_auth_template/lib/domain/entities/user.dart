import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    String? profilePicture,
    String? profileImageUrl,
    required bool isEmailVerified,
    required bool isTwoFactorEnabled,
    required List<String> roles,
    required List<String> permissions,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastLoginAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
