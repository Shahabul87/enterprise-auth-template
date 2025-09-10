abstract class AppException implements Exception {
  final String message;
  final String? path;
  final String? errorCode;
  final int? statusCode;
  final dynamic details;

  const AppException(
    this.message, {
    this.path,
    this.errorCode,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(String message, String? path)
    : super(message, path: path);
}

class TimeoutException extends AppException {
  const TimeoutException(String message, String? path)
    : super(message, path: path);
}

class RequestCancelledException extends AppException {
  const RequestCancelledException(String message, String? path)
    : super(message, path: path);
}

class UnknownException extends AppException {
  const UnknownException(String message, String? path)
    : super(message, path: path);
}

class HttpException extends AppException {
  const HttpException(
    String message,
    String? path,
    int statusCode, [
    String? errorCode,
  ]) : super(message, path: path, statusCode: statusCode, errorCode: errorCode);
}

class BadRequestException extends HttpException {
  const BadRequestException(String message, String? path, [String? errorCode])
    : super(message, path, 400, errorCode);
}

class UnauthorizedException extends HttpException {
  const UnauthorizedException(String message, String? path, [String? errorCode])
    : super(message, path, 401, errorCode);
}

class ForbiddenException extends HttpException {
  const ForbiddenException(String message, String? path, [String? errorCode])
    : super(message, path, 403, errorCode);
}

class NotFoundException extends HttpException {
  const NotFoundException(String message, String? path, [String? errorCode])
    : super(message, path, 404, errorCode);
}

class ConflictException extends HttpException {
  const ConflictException(String message, String? path, [String? errorCode])
    : super(message, path, 409, errorCode);
}

class ValidationException extends HttpException {
  const ValidationException(
    String message,
    String? path,
    String? errorCode,
    dynamic validationDetails,
  ) : super(message, path, 422, errorCode);
}

class TooManyRequestsException extends HttpException {
  const TooManyRequestsException(
    String message,
    String? path, [
    String? errorCode,
  ]) : super(message, path, 429, errorCode);
}

class ServerException extends HttpException {
  const ServerException(String message, String? path, int statusCode)
    : super(message, path, statusCode);
}

// Authentication specific exceptions
class InvalidCredentialsException extends UnauthorizedException {
  const InvalidCredentialsException([String? path])
    : super('Invalid email or password.', path, 'INVALID_CREDENTIALS');
}

class EmailNotVerifiedException extends UnauthorizedException {
  const EmailNotVerifiedException([String? path])
    : super(
        'Please verify your email address to continue.',
        path,
        'EMAIL_NOT_VERIFIED',
      );
}

class TwoFactorRequiredException extends UnauthorizedException {
  const TwoFactorRequiredException([String? path])
    : super(
        'Two-factor authentication is required.',
        path,
        'TWO_FACTOR_REQUIRED',
      );
}

class AccountLockedException extends ForbiddenException {
  const AccountLockedException([String? path])
    : super(
        'Your account has been locked due to multiple failed login attempts.',
        path,
        'ACCOUNT_LOCKED',
      );
}

class EmailAlreadyExistsException extends ConflictException {
  const EmailAlreadyExistsException([String? path])
    : super(
        'An account with this email already exists.',
        path,
        'EMAIL_ALREADY_EXISTS',
      );
}

class TokenExpiredException extends UnauthorizedException {
  const TokenExpiredException([String? path])
    : super(
        'Your session has expired. Please login again.',
        path,
        'TOKEN_EXPIRED',
      );
}

class InvalidTokenException extends UnauthorizedException {
  const InvalidTokenException([String? path])
    : super('Invalid authentication token.', path, 'INVALID_TOKEN');
}

class BiometricException extends AppException {
  const BiometricException(String message) : super(message);
}

class BiometricNotAvailableException extends BiometricException {
  const BiometricNotAvailableException()
    : super('Biometric authentication is not available on this device.');
}

class BiometricNotEnrolledException extends BiometricException {
  const BiometricNotEnrolledException()
    : super('No biometric credentials are enrolled on this device.');
}

class BiometricAuthFailedException extends BiometricException {
  const BiometricAuthFailedException()
    : super('Biometric authentication failed. Please try again.');
}

class PasskeyException extends AppException {
  const PasskeyException(String message) : super(message);
}

class PasskeyNotSupportedException extends PasskeyException {
  const PasskeyNotSupportedException()
    : super('Passkeys are not supported on this device or browser.');
}

class PasskeyCreationFailedException extends PasskeyException {
  const PasskeyCreationFailedException()
    : super('Failed to create passkey. Please try again.');
}

class PasskeyAuthenticationFailedException extends PasskeyException {
  const PasskeyAuthenticationFailedException()
    : super('Passkey authentication failed. Please try again.');
}

class StorageException extends AppException {
  const StorageException(String message) : super(message);
}

class SecureStorageException extends StorageException {
  const SecureStorageException()
    : super(
        'Failed to access secure storage. Please check device security settings.',
      );
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

// Deep linking exceptions
class DeepLinkException extends AppException {
  const DeepLinkException(String message) : super(message);
}

class InvalidDeepLinkException extends DeepLinkException {
  const InvalidDeepLinkException() : super('Invalid or malformed deep link.');
}

class ExpiredDeepLinkException extends DeepLinkException {
  const ExpiredDeepLinkException()
    : super('This link has expired. Please request a new one.');
}
