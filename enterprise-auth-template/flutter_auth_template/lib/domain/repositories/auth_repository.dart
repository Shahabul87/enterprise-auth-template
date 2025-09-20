import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/data/models/auth_response.dart';

/// Abstract repository interface for authentication operations.
///
/// This interface defines the contract for all authentication-related
/// data operations. It follows the Repository pattern from Domain-Driven
/// Design and Clean Architecture, providing an abstraction layer between
/// the domain and data layers.
///
/// ## Purpose:
/// - Defines authentication operations without implementation details
/// - Allows for multiple implementations (REST API, GraphQL, Mock, etc.)
/// - Enables testing through dependency injection
/// - Isolates business logic from data access concerns
///
/// ## Implementation Notes:
/// Concrete implementations should:
/// - Handle all network/storage operations
/// - Convert data layer models to domain entities
/// - Handle errors and convert to domain exceptions
/// - Manage token storage and refresh logic
/// - Implement proper retry mechanisms
///
/// ## Example Implementation:
/// ```dart
/// class AuthRepositoryImpl implements AuthRepository {
///   final ApiClient _apiClient;
///   final SecureStorage _storage;
///
///   @override
///   Future<AuthResponseData> login(LoginRequest request) async {
///     try {
///       final response = await _apiClient.post('/auth/login', data: request);
///       await _storage.saveTokens(response.tokens);
///       return response;
///     } catch (e) {
///       throw AuthException.fromError(e);
///     }
///   }
/// }
/// ```
abstract class AuthRepository {
  // ============================================================
  // Basic Authentication
  // ============================================================

  /// Authenticates a user with email and password.
  ///
  /// Parameters:
  /// - [request]: Contains email and password credentials
  ///
  /// Returns:
  /// - [AuthResponseData] containing user info and tokens
  ///
  /// Throws:
  /// - [AuthException] for invalid credentials
  /// - [NetworkException] for connectivity issues
  /// - [ServerException] for backend errors
  Future<AuthResponseData> login(LoginRequest request);

  /// Registers a new user account.
  ///
  /// Parameters:
  /// - [request]: Contains registration details (email, password, name, etc.)
  ///
  /// Returns:
  /// - [AuthResponseData] with new user info and initial tokens
  ///
  /// Throws:
  /// - [ValidationException] for invalid input
  /// - [ConflictException] if email already exists
  Future<AuthResponseData> register(RegisterRequest request);

  /// Refreshes the authentication tokens.
  ///
  /// Uses the stored refresh token to obtain new access/refresh tokens.
  /// Should be called when access token expires (401 response).
  ///
  /// Returns:
  /// - [AuthResponseData] with refreshed tokens
  ///
  /// Throws:
  /// - [AuthException] if refresh token is invalid/expired
  Future<AuthResponseData> refreshToken();

  /// Logs out the current user.
  ///
  /// Should:
  /// - Invalidate tokens on the server
  /// - Clear local storage
  /// - Reset any cached user data
  ///
  /// This operation should not throw exceptions;
  /// failures should be logged but not block logout.
  Future<void> logout();

  // ============================================================
  // Password Management
  // ============================================================

  /// Initiates password reset process.
  ///
  /// Sends a password reset email to the provided address.
  ///
  /// Parameters:
  /// - [request]: Contains email address for reset
  ///
  /// Note: Should return success even if email doesn't exist
  /// (security best practice to prevent email enumeration)
  Future<void> forgotPassword(ForgotPasswordRequest request);

  /// Resets password using a reset token.
  ///
  /// Parameters:
  /// - [request]: Contains reset token and new password
  ///
  /// Throws:
  /// - [InvalidTokenException] if token is expired/invalid
  /// - [ValidationException] if password doesn't meet requirements
  Future<void> resetPassword(ResetPasswordRequest request);

  // ============================================================
  // Email Verification
  // ============================================================

  /// Verifies user's email address.
  ///
  /// Parameters:
  /// - [token]: Email verification token from email link
  ///
  /// Throws:
  /// - [InvalidTokenException] if token is invalid/expired
  /// - [AlreadyVerifiedException] if email already verified
  Future<void> verifyEmail(String token);

  /// Resends email verification link.
  ///
  /// Sends a new verification email to the current user's address.
  /// Should implement rate limiting to prevent abuse.
  ///
  /// Throws:
  /// - [RateLimitException] if too many requests
  /// - [AlreadyVerifiedException] if already verified
  Future<void> resendEmailVerification();

  // ============================================================
  // User Management
  // ============================================================

  /// Fetches the current authenticated user's profile.
  ///
  /// Returns:
  /// - [User] entity with current profile data
  ///
  /// Throws:
  /// - [UnauthorizedException] if not authenticated
  /// - [NetworkException] for connectivity issues
  Future<User> getCurrentUser();

  /// Updates the current user's profile.
  ///
  /// Parameters:
  /// - [userData]: Map of fields to update (e.g., name, bio, phone)
  ///
  /// Returns:
  /// - Updated [User] entity
  ///
  /// Note: Email changes may require re-verification
  Future<User> updateCurrentUser(Map<String, dynamic> userData);

  /// Gets the current user's permissions.
  ///
  /// Returns:
  /// - List of permission strings (e.g., ['posts:read', 'posts:write'])
  ///
  /// Used for fine-grained access control in the UI.
  Future<List<String>> getUserPermissions();

  // OAuth2
  Future<List<String>> getOAuthProviders();
  Future<String> getOAuthAuthorizationUrl(String provider);
  Future<AuthResponseData> completeOAuthLogin(OAuthLoginRequest request);

  // Magic Links
  Future<void> requestMagicLink(MagicLinkRequest request);
  Future<AuthResponseData> verifyMagicLink(String token);

  // WebAuthn
  Future<WebAuthnRegistrationResponse> beginWebAuthnRegistration({
    String? email,
  });
  Future<void> completeWebAuthnRegistration(Map<String, dynamic> credential);
  Future<WebAuthnAuthenticationResponse> beginWebAuthnAuthentication({
    String? email,
  });
  Future<AuthResponseData> completeWebAuthnAuthentication(
    Map<String, dynamic> credential,
  );

  // Two-Factor Authentication
  Future<Map<String, dynamic>> getTwoFactorStatus();
  Future<TwoFactorSetupResponse> setupTwoFactor();
  Future<List<String>> enableTwoFactor(VerifyTwoFactorRequest request);
  Future<AuthResponseData> verifyTwoFactor(VerifyTwoFactorRequest request);
  Future<void> disableTwoFactor();
  Future<List<String>> regenerateBackupCodes();

  // ============================================================
  // Local State Management
  // ============================================================

  /// Checks if user is authenticated locally.
  ///
  /// Returns:
  /// - `true` if valid tokens exist in storage
  /// - `false` otherwise
  ///
  /// Note: This doesn't validate tokens with the server.
  /// For server validation, use [getCurrentUser].
  Future<bool> isAuthenticated();

  /// Retrieves stored access token.
  ///
  /// Returns:
  /// - Access token string if available
  /// - `null` if not authenticated
  ///
  /// Used for adding Authorization headers to API requests.
  Future<String?> getStoredAccessToken();

  /// Retrieves cached user data.
  ///
  /// Returns:
  /// - Cached [User] if available
  /// - `null` if not cached
  ///
  /// Note: May be stale; use [getCurrentUser] for fresh data.
  Future<User?> getStoredUser();

  /// Clears all authentication data from local storage.
  ///
  /// Should clear:
  /// - Access and refresh tokens
  /// - Cached user data
  /// - Any auth-related preferences
  ///
  /// Called during logout or when tokens are invalid.
  Future<void> clearAuthData();
}
