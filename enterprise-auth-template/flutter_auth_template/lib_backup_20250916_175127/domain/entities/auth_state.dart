import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'auth_state.freezed.dart';

/// Represents the current authentication state of the application.
///
/// This sealed class uses the Freezed union pattern to represent all possible
/// authentication states in a type-safe manner. Each state carries relevant
/// data and transitions are managed by the authentication layer.
///
/// ## State Machine
/// ```
/// Unauthenticated ──┬──> Authenticating ──> Authenticated
///                   │         │
///                   │         └──> Error ──> Unauthenticated
///                   │
///                   └──> Error
/// ```
///
/// ## Usage Example:
/// ```dart
/// // Pattern matching on state
/// authState.when(
///   unauthenticated: () => showLoginScreen(),
///   authenticating: () => showLoadingSpinner(),
///   authenticated: (user, token, _) => showHomeScreen(user),
///   error: (message) => showErrorDialog(message),
/// );
///
/// // Checking state type
/// if (authState.isAuthenticated) {
///   navigateToProfile();
/// }
///
/// // Getting current user
/// final currentUser = authState.user;
/// if (currentUser != null) {
///   print('Logged in as ${currentUser.name}');
/// }
/// ```
///
/// ## State Transitions:
/// - App Start → Unauthenticated or Authenticated (from storage)
/// - Login Attempt → Authenticating → Authenticated or Error
/// - Logout → Unauthenticated
/// - Token Refresh → Authenticating → Authenticated or Unauthenticated
/// - Session Expire → Unauthenticated
@freezed
class AuthState with _$AuthState {
  /// Private constructor for adding custom getters.
  const AuthState._();

  /// State when no user is logged in.
  ///
  /// This is the initial state of the application and the state
  /// after logout or session expiration.
  ///
  /// Typical UI: Show login/register screen
  const factory AuthState.unauthenticated() = Unauthenticated;

  /// State during authentication operations.
  ///
  /// This state is active during:
  /// - Login attempts
  /// - Registration
  /// - Token refresh
  /// - Initial app authentication check
  ///
  /// Typical UI: Show loading spinner or progress indicator
  const factory AuthState.authenticating() = Authenticating;

  /// State when user is successfully authenticated.
  ///
  /// Contains:
  /// - [user]: The authenticated user object
  /// - [accessToken]: JWT or OAuth access token for API calls
  /// - [refreshToken]: Optional refresh token for token renewal
  ///
  /// The access token should be included in API request headers:
  /// ```
  /// Authorization: Bearer {accessToken}
  /// ```
  ///
  /// Typical UI: Show main application content
  const factory AuthState.authenticated({
    /// The authenticated user object containing profile information.
    required User user,

    /// Access token for API authentication.
    /// Should be included in Authorization header for protected endpoints.
    required String accessToken,

    /// Optional refresh token for renewing access token.
    /// Stored securely and used when access token expires.
    String? refreshToken,
  }) = Authenticated;

  /// State when an authentication error occurs.
  ///
  /// [message]: Human-readable error message to display to user
  ///
  /// Common error scenarios:
  /// - Invalid credentials
  /// - Network errors
  /// - Server errors
  /// - Account locked/suspended
  /// - Email not verified
  ///
  /// After showing error, typically transition back to Unauthenticated
  ///
  /// Typical UI: Show error message with retry option
  const factory AuthState.error(String message) = AuthError;

  /// Helper getter to check if user is authenticated.
  ///
  /// Returns `true` only when state is [Authenticated].
  ///
  /// Example:
  /// ```dart
  /// if (authState.isAuthenticated) {
  ///   // User is logged in
  /// }
  /// ```
  bool get isAuthenticated => this is Authenticated;

  /// Helper getter to check if authentication is in progress.
  ///
  /// Returns `true` only when state is [Authenticating].
  ///
  /// Example:
  /// ```dart
  /// if (authState.isLoading) {
  ///   return CircularProgressIndicator();
  /// }
  /// ```
  bool get isLoading => this is Authenticating;

  /// Helper getter to check if an error occurred.
  ///
  /// Returns `true` only when state is [AuthError].
  ///
  /// Example:
  /// ```dart
  /// if (authState.hasError) {
  ///   showErrorSnackBar();
  /// }
  /// ```
  bool get hasError => this is AuthError;

  /// Gets the current user if authenticated, null otherwise.
  ///
  /// Convenient getter that extracts the user from [Authenticated] state
  /// without needing pattern matching.
  ///
  /// Example:
  /// ```dart
  /// final user = authState.user;
  /// if (user != null) {
  ///   welcomeText = 'Hello, ${user.name}!';
  /// }
  /// ```
  User? get user => when(
    authenticated: (user, _, __) => user,
    unauthenticated: () => null,
    authenticating: () => null,
    error: (_) => null,
  );

  /// Gets the access token if authenticated, null otherwise.
  ///
  /// Convenient getter for accessing the JWT/OAuth token without
  /// pattern matching. Used for API authentication.
  ///
  /// Example:
  /// ```dart
  /// final token = authState.accessToken;
  /// if (token != null) {
  ///   headers['Authorization'] = 'Bearer $token';
  /// }
  /// ```
  String? get accessToken => when(
    authenticated: (_, token, __) => token,
    unauthenticated: () => null,
    authenticating: () => null,
    error: (_) => null,
  );
}
