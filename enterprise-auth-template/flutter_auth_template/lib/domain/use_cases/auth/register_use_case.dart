import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/domain/repositories/auth_repository.dart';

/// Use case for new user registration.
///
/// This class encapsulates the business logic for user registration, including:
/// - Name validation
/// - Email format validation
/// - Password strength enforcement
/// - Password confirmation matching
/// - Terms of service acceptance
/// - Request normalization
///
/// ## Example Usage:
/// ```dart
/// final registerUseCase = RegisterUseCase(authRepository);
/// final result = await registerUseCase.execute(
///   email: 'newuser@example.com',
///   password: 'SecurePass123',
///   confirmPassword: 'SecurePass123',
///   fullName: 'John Doe',
///   agreeToTerms: true,
/// );
///
/// result.when(
///   success: (user, message) => print('Registered: ${user.name}'),
///   error: (message, code, _, __) => print('Registration failed: $message'),
///   loading: () => print('Registering...'),
/// );
/// ```
///
/// ## Business Rules:
/// - Full name must be at least 2 characters
/// - Email must be valid format (RFC 5322 compliant)
/// - Password must be at least 8 characters
/// - Password must contain uppercase, lowercase, and numbers
/// - Password and confirmation must match
/// - Terms of service must be accepted
/// - Email is normalized (lowercase, trimmed) before processing
/// - Name is trimmed of whitespace
///
/// ## Error Codes:
/// - `INVALID_NAME`: Name is empty or too short
/// - `INVALID_EMAIL`: Email format is invalid
/// - `WEAK_PASSWORD`: Password doesn't meet strength requirements
/// - `PASSWORD_MISMATCH`: Password and confirmation don't match
/// - `TERMS_NOT_ACCEPTED`: User hasn't accepted terms of service
/// - Repository may return additional codes (e.g., `EMAIL_EXISTS`)
class RegisterUseCase {
  final AuthRepository _repository;

  /// Creates a new instance of [RegisterUseCase].
  ///
  /// Requires an [AuthRepository] implementation for data layer interaction.
  const RegisterUseCase(this._repository);

  /// Executes the user registration process.
  ///
  /// Parameters:
  /// - [email]: User's email address (will be normalized)
  /// - [password]: User's chosen password (must meet strength requirements)
  /// - [confirmPassword]: Password confirmation (must match password)
  /// - [fullName]: User's full name (minimum 2 characters)
  /// - [agreeToTerms]: Whether user accepts terms of service
  ///
  /// Returns:
  /// - [ApiResponse<User>] containing either:
  ///   - Success: Newly created user object
  ///   - Error: Validation or registration error details
  ///
  /// The method performs comprehensive validation before attempting registration.
  /// All validation errors are returned immediately without hitting the repository.
  ///
  /// Throws:
  /// - May throw exceptions for unexpected errors (network issues, etc.)
  ///   These should be caught by the presentation layer.
  Future<ApiResponse<User>> execute({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required bool agreeToTerms,
  }) async {
    // Validate full name
    if (fullName.isEmpty || fullName.trim().length < 2) {
      return const ApiResponse.error(
        message: 'Please enter your full name (at least 2 characters)',
        code: 'INVALID_NAME',
      );
    }

    // Validate email format
    if (email.isEmpty || !_isValidEmail(email)) {
      return const ApiResponse.error(
        message: 'Please enter a valid email address',
        code: 'INVALID_EMAIL',
      );
    }

    // Validate password strength
    final passwordValidation = _validatePasswordStrength(password);
    if (passwordValidation != null) {
      return ApiResponse.error(
        message: passwordValidation,
        code: 'WEAK_PASSWORD',
      );
    }

    // Validate password confirmation
    if (password != confirmPassword) {
      return const ApiResponse.error(
        message: 'Passwords do not match',
        code: 'PASSWORD_MISMATCH',
      );
    }

    // Validate terms acceptance
    if (!agreeToTerms) {
      return const ApiResponse.error(
        message: 'You must agree to the terms and conditions',
        code: 'TERMS_NOT_ACCEPTED',
      );
    }

    // Create registration request with normalized data
    final request = RegisterRequest(
      email: email.toLowerCase().trim(),
      password: password,
      confirmPassword: confirmPassword,
      fullName: fullName.trim(),
      agreeToTerms: agreeToTerms,
    );

    // Delegate to repository for actual registration
    try {
      final authData = await _repository.register(request);
      return ApiResponse<User>.success(
        data: authData.user,
        message: 'Registration successful',
      );
    } catch (e) {
      return ApiResponse<User>.error(
        message: 'Registration failed: ${e.toString()}',
        code: 'REGISTRATION_ERROR',
      );
    }
  }

  /// Validates email format according to RFC 5322 standard.
  ///
  /// This is a simplified regex that covers most common email formats.
  /// Server-side validation should be the ultimate authority.
  ///
  /// Returns `true` if email format is valid, `false` otherwise.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates password strength according to security requirements.
  ///
  /// Password must:
  /// - Be at least 8 characters long
  /// - Contain at least one uppercase letter
  /// - Contain at least one lowercase letter
  /// - Contain at least one number
  ///
  /// Returns `null` if password is strong, or an error message describing
  /// what's missing.
  ///
  /// Consider adding additional requirements for production:
  /// - Special characters
  /// - No common passwords
  /// - No personal information
  String? _validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null; // Password is strong
  }

  /// Legacy method for password strength checking.
  ///
  /// @deprecated Use [_validatePasswordStrength] instead for better error messages.
  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }
}