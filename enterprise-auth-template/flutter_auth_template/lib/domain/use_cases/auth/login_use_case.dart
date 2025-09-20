import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/domain/repositories/auth_repository.dart';

/// Use case for user authentication via email and password.
///
/// This class encapsulates the business logic for user login, including:
/// - Email validation
/// - Password strength requirements
/// - Request formatting
/// - Delegation to repository layer
///
/// ## Example Usage:
/// ```dart
/// final loginUseCase = LoginUseCase(authRepository);
/// final result = await loginUseCase.execute(
///   email: 'user@example.com',
///   password: 'securePassword123',
/// );
///
/// result.when(
///   success: (user, message) => print('Logged in as ${user.name}'),
///   error: (message, code, _, __) => print('Login failed: $message'),
///   loading: () => print('Logging in...'),
/// );
/// ```
///
/// ## Business Rules:
/// - Email must be valid format (RFC 5322 compliant)
/// - Password must be at least 8 characters
/// - Email is normalized (lowercase, trimmed) before processing
///
/// ## Error Codes:
/// - `INVALID_EMAIL`: Email format is invalid or empty
/// - `INVALID_PASSWORD`: Password doesn't meet requirements
/// - Repository may return additional error codes for network/server issues
class LoginUseCase {
  final AuthRepository _repository;

  /// Creates a new instance of [LoginUseCase].
  ///
  /// Requires an [AuthRepository] implementation for data layer interaction.
  const LoginUseCase(this._repository);

  /// Executes the login operation with provided credentials.
  ///
  /// Parameters:
  /// - [email]: User's email address (will be normalized)
  /// - [password]: User's password (must be at least 8 characters)
  ///
  /// Returns:
  /// - [ApiResponse<User>] containing either:
  ///   - Success: Authenticated user object
  ///   - Error: Validation or authentication error details
  ///
  /// Throws:
  /// - May throw exceptions for unexpected errors (network timeouts, etc.)
  ///   These should be caught by the presentation layer.
  Future<ApiResponse<User>> execute({
    required String email,
    required String password,
  }) async {
    // Business rules validation
    if (email.isEmpty || !_isValidEmail(email)) {
      return const ApiResponse.error(
        message: 'Please enter a valid email address',
        code: 'INVALID_EMAIL',
      );
    }

    if (password.isEmpty || password.length < 8) {
      return const ApiResponse.error(
        message: 'Password must be at least 8 characters',
        code: 'INVALID_PASSWORD',
      );
    }

    // Create login request with normalized email
    final request = LoginRequest(
      email: email.toLowerCase().trim(),
      password: password,
    );

    // Delegate to repository for actual authentication
    try {
      final authData = await _repository.login(request);
      return ApiResponse<User>.success(
        data: authData.user,
        message: 'Login successful',
      );
    } catch (e) {
      return ApiResponse<User>.error(
        message: 'Login failed: ${e.toString()}',
        code: 'LOGIN_ERROR',
      );
    }
  }

  /// Validates email format according to RFC 5322 standard.
  ///
  /// This is a simplified regex that covers most common email formats.
  /// For production systems, consider using a more comprehensive validation
  /// library or server-side validation.
  ///
  /// Returns `true` if email format is valid, `false` otherwise.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}