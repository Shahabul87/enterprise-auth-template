# Flutter App API Documentation

## Overview
This document provides comprehensive API documentation for the Flutter authentication template, including all services, repositories, and use cases.

## Table of Contents
1. [Authentication APIs](#authentication-apis)
2. [User Management APIs](#user-management-apis)
3. [Security Services](#security-services)
4. [Error Handling](#error-handling)
5. [Performance Monitoring](#performance-monitoring)

---

## Authentication APIs

### AuthService

Primary service for authentication operations.

#### Methods

##### `login(LoginRequest request) → Future<ApiResponse<User>>`
Authenticates a user with email and password.

**Parameters:**
- `request`: LoginRequest containing email and password

**Returns:**
- Success: User object with authentication tokens
- Error: Error message with appropriate code

**Example:**
```dart
final response = await authService.login(
  LoginRequest(
    email: 'user@example.com',
    password: 'SecurePassword123!',
  ),
);
```

##### `register(RegisterRequest request) → Future<ApiResponse<User>>`
Registers a new user account.

**Parameters:**
- `request`: RegisterRequest with user details

**Returns:**
- Success: Created User object
- Error: Validation or conflict errors

##### `logout() → Future<ApiResponse<String>>`
Logs out the current user and clears tokens.

**Returns:**
- Success: Confirmation message
- Error: Rarely fails

##### `getCurrentUser() → Future<ApiResponse<User>>`
Retrieves the currently authenticated user.

**Returns:**
- Success: Current User object
- Error: Authentication required error

##### `forgotPassword(ForgotPasswordRequest request) → Future<ApiResponse<String>>`
Initiates password reset process.

**Parameters:**
- `request`: Email address for reset

**Returns:**
- Success: Confirmation message
- Error: User not found or rate limited

##### `verify2FA(VerifyTwoFactorRequest request) → Future<ApiResponse<User>>`
Verifies two-factor authentication code.

**Parameters:**
- `request`: 2FA code and optional backup flag

**Returns:**
- Success: Authenticated User
- Error: Invalid code or expired

---

## User Management APIs

### UserRepository

Repository for user-related operations.

#### Methods

##### `updateProfile(Map<String, dynamic> data) → Future<ApiResponse<User>>`
Updates user profile information.

**Parameters:**
- `data`: Map of fields to update

**Allowed Fields:**
- `name`: String (2-100 characters)
- `phoneNumber`: String (optional)
- `avatarUrl`: String (valid URL)

**Example:**
```dart
final response = await userRepository.updateProfile({
  'name': 'John Doe',
  'phoneNumber': '+1234567890',
});
```

##### `changePassword(ChangePasswordRequest request) → Future<ApiResponse<String>>`
Changes user password.

**Parameters:**
- `currentPassword`: Current password for verification
- `newPassword`: New password (8+ chars, complexity required)
- `confirmPassword`: Must match newPassword

---

## Security Services

### DeviceSecurity

Service for device security checks.

#### Methods

##### `isDeviceCompromised() → Future<bool>`
Checks if device is rooted or jailbroken.

**Returns:**
- `true`: Device is compromised
- `false`: Device is secure

##### `performSecurityCheck() → Future<DeviceSecurityStatus>`
Comprehensive security assessment.

**Returns:**
```dart
class DeviceSecurityStatus {
  bool isRootedOrJailbroken;
  bool isEmulator;
  bool isDeveloperModeEnabled;
  bool isSecure;
}
```

### InputSanitizer

Sanitization utilities for user input.

#### Static Methods

##### `sanitizeText(String input) → String`
Removes HTML tags and escapes special characters.

##### `sanitizeEmail(String input) → String?`
Validates and sanitizes email addresses.

##### `sanitizeUrl(String input) → String?`
Validates and sanitizes URLs.

##### `sanitizePassword(String input) → String?`
Validates password strength without modification.

### CertificatePinning

SSL certificate validation.

#### Methods

##### `configureCertificatePinning(Dio dio, {required bool isProduction})`
Configures HTTP client with certificate pinning.

**Parameters:**
- `dio`: Dio HTTP client instance
- `isProduction`: Use production or staging certificates

---

## Error Handling

### ErrorBoundary

Widget for catching and handling errors in widget tree.

#### Properties

- `child`: Widget - Child widget to protect
- `errorBuilder`: Function - Custom error UI builder
- `onError`: Function - Error callback handler

**Usage:**
```dart
ErrorBoundary(
  child: MyApp(),
  errorBuilder: (error, stack) => ErrorScreen(error: error),
  onError: (error, stack) => logError(error),
)
```

### GlobalErrorHandler

Global error handling configuration.

#### Static Methods

##### `initialize()`
Sets up global error handlers for Flutter and async errors.

##### `handleApiError(dynamic error, {Map<String, dynamic>? context})`
Handles API-specific errors with context.

##### `handleAuthError(dynamic error, {Map<String, dynamic>? context})`
Handles authentication errors.

### CrashReporting

Crash reporting service for production error tracking.

#### Methods

##### `initialize({required String dsn, required String environment})`
Initializes crash reporting service.

##### `captureException(dynamic exception, {StackTrace? stackTrace, ErrorLevel level})`
Captures and reports exceptions.

##### `setUser({required String id, String? email, String? username})`
Associates errors with user context.

##### `addBreadcrumb({required String message, BreadcrumbLevel level})`
Adds context breadcrumb for error reports.

---

## Performance Monitoring

### PerformanceMonitor

Performance tracking utility.

#### Static Methods

##### `startOperation(String operationName)`
Begins tracking a performance operation.

##### `endOperation(String operationName) → int?`
Ends tracking and returns duration in milliseconds.

##### `trackAsync<T>(String operationName, Future<T> Function() operation)`
Tracks asynchronous operations.

**Example:**
```dart
final result = await PerformanceMonitor.trackAsync(
  'api_call',
  () => apiClient.fetchData(),
);
```

##### `trackApiCall<T>(String endpoint, Future<T> Function() apiCall)`
Specialized tracking for API calls.

##### `getReport() → Map<String, dynamic>`
Returns performance metrics report.

**Report Structure:**
```dart
{
  'operation_name': {
    'count': 10,
    'average': '125.50',
    'max': 500,
    'min': 50,
    'total': 1255,
  }
}
```

---

## Use Cases

### LoginUseCase

Business logic for user login.

#### Methods

##### `execute({required String email, required String password}) → Future<ApiResponse<User>>`

**Business Rules:**
- Email must be valid format
- Password minimum 8 characters
- Email is normalized to lowercase
- Input is sanitized

**Example:**
```dart
final useCase = LoginUseCase(authRepository);
final result = await useCase.execute(
  email: 'USER@Example.COM',
  password: 'SecurePass123!',
);
```

### RegisterUseCase

Business logic for user registration.

#### Methods

##### `execute({...}) → Future<ApiResponse<User>>`

**Parameters:**
- `email`: Valid email address
- `password`: Strong password (8+ chars, upper, lower, number)
- `confirmPassword`: Must match password
- `fullName`: 2+ characters
- `agreeToTerms`: Must be true

**Validation Rules:**
- Email uniqueness check
- Password strength requirements
- Terms acceptance required

---

## Response Format

All API responses follow this structure:

### ApiResponse<T>

```dart
class ApiResponse<T> {
  final T? data;
  final String? message;
  final String? code;
  final Map<String, dynamic>? metadata;

  // Factory constructors
  ApiResponse.success({T? data, String? message});
  ApiResponse.error({String message, String? code});
  ApiResponse.loading();
}
```

### Error Codes

| Code | Description |
|------|-------------|
| `INVALID_CREDENTIALS` | Wrong email or password |
| `USER_NOT_FOUND` | User does not exist |
| `EMAIL_ALREADY_EXISTS` | Email already registered |
| `WEAK_PASSWORD` | Password doesn't meet requirements |
| `TOKEN_EXPIRED` | Authentication token expired |
| `RATE_LIMITED` | Too many requests |
| `NETWORK_ERROR` | Connection failed |
| `SERVER_ERROR` | Internal server error |
| `VALIDATION_ERROR` | Input validation failed |
| `PERMISSION_DENIED` | Insufficient permissions |

---

## Rate Limiting

API endpoints implement rate limiting:

- Authentication: 5 requests per minute
- Password reset: 3 requests per hour
- General API: 100 requests per minute

Exceeded limits return `429 Too Many Requests`.

---

## Best Practices

1. **Always handle errors**
   ```dart
   response.when(
     success: (data, message) => handleSuccess(data),
     error: (message, code, _, __) => handleError(message),
     loading: () => showLoader(),
   );
   ```

2. **Use input sanitization**
   ```dart
   final sanitizedEmail = InputSanitizer.sanitizeEmail(userInput);
   if (sanitizedEmail == null) {
     // Handle invalid input
   }
   ```

3. **Track performance**
   ```dart
   await PerformanceMonitor.trackApiCall(
     '/api/users',
     () => apiClient.getUsers(),
   );
   ```

4. **Add error boundaries**
   ```dart
   ErrorBoundary(
     child: FeatureWidget(),
     onError: (error, stack) => reportError(error),
   );
   ```

5. **Check device security**
   ```dart
   if (await DeviceSecurity.isDeviceCompromised()) {
     // Show security warning
   }
   ```

---

## Migration Guide

### From v1.0 to v2.0

1. **AuthService changes:**
   - `signIn()` → `login()`
   - `signUp()` → `register()`

2. **New required fields:**
   - Registration now requires `agreeToTerms`
   - Profile updates require validation

3. **Security enhancements:**
   - Certificate pinning now mandatory
   - Input sanitization required

---

## Support

For issues or questions:
- GitHub Issues: [project-repo]/issues
- Documentation: [project-docs]
- Email: support@example.com

---

Generated: 2025-01-16
Version: 2.0.0