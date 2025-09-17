import 'package:flutter_auth_template/core/network/api_response.dart';
import 'package:flutter_auth_template/data/models/auth_request.dart';
import 'package:flutter_auth_template/domain/entities/user.dart';
import 'package:flutter_auth_template/domain/repositories/auth_repository.dart';

/// Login use case - encapsulates login business logic
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  /// Execute login with email and password
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

    // Create login request
    final request = LoginRequest(
      email: email.toLowerCase().trim(),
      password: password,
    );

    // Delegate to repository
    return _repository.login(request);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}