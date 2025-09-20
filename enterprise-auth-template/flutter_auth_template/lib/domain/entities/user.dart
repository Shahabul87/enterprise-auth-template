import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Core user entity representing an authenticated user in the system.
///
/// This is a domain entity that represents the essential user information
/// required for authentication and authorization throughout the application.
/// It follows the Clean Architecture principle of being framework-independent
/// and contains only business-relevant data.
///
/// ## Usage Example:
/// ```dart
/// final user = User(
///   id: '123e4567-e89b-12d3-a456-426614174000',
///   email: 'john.doe@example.com',
///   name: 'John Doe',
///   isEmailVerified: true,
///   isTwoFactorEnabled: false,
///   roles: ['user', 'admin'],
///   permissions: ['read', 'write', 'delete'],
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
///
/// // Check user permissions
/// if (user.permissions.contains('admin')) {
///   // Show admin features
/// }
/// ```
///
/// ## Security Considerations:
/// - Never store sensitive data like passwords in this entity
/// - Profile pictures should be URLs, not base64 encoded data
/// - Permissions should be validated server-side
///
/// ## Business Rules:
/// - Email must be unique across the system
/// - User must have at least one role
/// - Email verification is required for certain operations
/// - Two-factor authentication enhances security
@freezed
class User with _$User {
  /// Creates a new User instance.
  ///
  /// Required fields:
  /// - [id]: Unique identifier (UUID format recommended)
  /// - [email]: User's email address (must be unique)
  /// - [name]: Display name for the user
  /// - [isEmailVerified]: Whether email has been verified
  /// - [isTwoFactorEnabled]: Whether 2FA is active
  /// - [roles]: List of assigned roles (e.g., 'user', 'admin')
  /// - [permissions]: List of granted permissions
  /// - [createdAt]: Account creation timestamp
  /// - [updatedAt]: Last profile update timestamp
  ///
  /// Optional fields:
  /// - [firstName]: User's first name
  /// - [lastName]: User's last name
  /// - [phoneNumber]: Contact phone number
  /// - [bio]: User biography/description
  /// - [profilePicture]: Local profile picture path (deprecated)
  /// - [profileImageUrl]: Remote profile picture URL
  /// - [lastLoginAt]: Timestamp of last successful login
  ///
  /// Note: This entity uses Freezed for immutability and code generation.
  /// Any changes require rebuilding with `flutter pub run build_runner build`.
  const factory User({
    /// Unique identifier for the user.
    /// Format: UUID v4 (e.g., '123e4567-e89b-12d3-a456-426614174000')
    required String id,

    /// User's email address.
    /// Must be unique across the system and in valid email format.
    required String email,

    /// Display name for the user.
    /// This is what's shown in the UI (e.g., "John Doe").
    required String name,

    /// User's first name.
    /// Optional, used for personalization.
    String? firstName,

    /// User's last name.
    /// Optional, used for personalization.
    String? lastName,

    /// Contact phone number.
    /// Format varies by region, validation should be done at input.
    String? phoneNumber,

    /// User biography or description.
    /// Limited to 500 characters in most implementations.
    String? bio,

    /// @deprecated Use [profileImageUrl] instead.
    /// Local path to profile picture.
    String? profilePicture,

    /// URL to user's profile image.
    /// Should be a secure HTTPS URL pointing to CDN or storage service.
    String? profileImageUrl,

    /// Whether the user's email address has been verified.
    /// Required for certain operations like password reset.
    required bool isEmailVerified,

    /// Whether the user account is active.
    /// Inactive accounts cannot login.
    @Default(true) bool? isActive,

    /// Whether two-factor authentication is enabled.
    /// When true, requires additional verification on login.
    required bool isTwoFactorEnabled,

    /// List of roles assigned to the user.
    /// Examples: ['user', 'admin', 'moderator']
    /// Used for role-based access control (RBAC).
    required List<String> roles,

    /// Single role for backward compatibility.
    /// @deprecated Use roles list instead
    String? role,

    /// List of specific permissions granted to the user.
    /// Examples: ['posts:read', 'posts:write', 'users:delete']
    /// Used for fine-grained access control.
    required List<String> permissions,

    /// Timestamp when the user account was created.
    /// Immutable once set.
    required DateTime createdAt,

    /// Timestamp of the last profile update.
    /// Updated whenever user information changes.
    required DateTime updatedAt,

    /// Timestamp of the last successful login.
    /// Used for security monitoring and user activity tracking.
    DateTime? lastLoginAt,
  }) = _User;

  /// Creates a User instance from a JSON map.
  ///
  /// This factory is used for deserializing user data from API responses
  /// or local storage. The JSON structure should match the field names
  /// defined in the User class.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "id": "123e4567-e89b-12d3-a456-426614174000",
  ///   "email": "john.doe@example.com",
  ///   "name": "John Doe",
  ///   "isEmailVerified": true,
  ///   "isTwoFactorEnabled": false,
  ///   "roles": ["user"],
  ///   "permissions": ["read", "write"],
  ///   "createdAt": "2024-01-01T00:00:00Z",
  ///   "updatedAt": "2024-01-01T00:00:00Z"
  /// }
  /// ```
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
