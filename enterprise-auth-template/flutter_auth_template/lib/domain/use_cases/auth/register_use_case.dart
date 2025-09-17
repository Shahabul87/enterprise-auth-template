import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/domain/repositories/auth_repository.dart';

/// Register use case - encapsulates registration business logic
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  /// Execute user registration
  Future<ApiResponse<User>> execute({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required bool agreeToTerms,
  }) async {
    // Business rules validation
    if (fullName.isEmpty || fullName.length < 2) {
      return const ApiResponse.error(
        message: 'Please enter your full name',
        code: 'INVALID_NAME',
      );
    }

    if (email.isEmpty || !_isValidEmail(email)) {
      return const ApiResponse.error(
        message: 'Please enter a valid email address',
        code: 'INVALID_EMAIL',
      );
    }

    if (!_isStrongPassword(password)) {
      return const ApiResponse.error(
        message: 'Password must be at least 8 characters with uppercase, lowercase, and numbers',
        code: 'WEAK_PASSWORD',
      );
    }

    if (password != confirmPassword) {
      return const ApiResponse.error(
        message: 'Passwords do not match',
        code: 'PASSWORD_MISMATCH',
      );
    }

    if (!agreeToTerms) {
      return const ApiResponse.error(
        message: 'You must agree to the terms and conditions',
        code: 'TERMS_NOT_ACCEPTED',
      );
    }

    // Create registration request
    final request = RegisterRequest(
      email: email.toLowerCase().trim(),
      password: password,
      confirmPassword: confirmPassword,
      fullName: fullName.trim(),
      agreeToTerms: agreeToTerms,
    );

    // Delegate to repository
    return _repository.register(request);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }
}