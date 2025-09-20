# API Documentation

## Overview
This document provides comprehensive API documentation for all public interfaces in the Flutter Authentication Template.

## Table of Contents
1. [Authentication APIs](#authentication-apis)
2. [User Management APIs](#user-management-apis)
3. [State Management APIs](#state-management-apis)
4. [Error Handling APIs](#error-handling-apis)
5. [Storage APIs](#storage-apis)
6. [Network APIs](#network-apis)

## Authentication APIs

### AuthRepository
```dart
/// Core authentication repository interface
abstract class AuthRepository
```

#### Methods

##### login
```dart
Future<AuthResponseData> login(LoginRequest request)
```
Authenticates user with email and password.

**Parameters:**
- `request`: LoginRequest containing email and password

**Returns:**
- `AuthResponseData`: User information and authentication tokens

**Throws:**
- `AuthException`: Invalid credentials
- `NetworkException`: Connection issues
- `ServerException`: Server errors

**Example:**
```dart
final response = await authRepository.login(
  LoginRequest(email: 'user@example.com', password: 'password123')
);
```

##### register
```dart
Future<AuthResponseData> register(RegisterRequest request)
```
Creates a new user account.

**Parameters:**
- `request`: Registration details including email, password, and user info

**Returns:**
- `AuthResponseData`: New user information and initial tokens

**Throws:**
- `ValidationException`: Invalid input data
- `ConflictException`: Email already exists

##### logout
```dart
Future<void> logout()
```
Logs out the current user and clears all authentication data.

**Note:** This method should not throw exceptions; errors are logged but don't block logout.

### LoginUseCase
```dart
class LoginUseCase
```

#### Constructor
```dart
const LoginUseCase(AuthRepository repository)
```

#### Methods

##### execute
```dart
Future<ApiResponse<User>> execute({
  required String email,
  required String password,
})
```

Executes login with business rule validation.

**Business Rules:**
- Email must be valid format (RFC 5322)
- Password must be at least 8 characters
- Email is normalized (lowercase, trimmed)

**Error Codes:**
- `INVALID_EMAIL`: Email format invalid
- `INVALID_PASSWORD`: Password requirements not met

## User Management APIs

### User Entity
```dart
class User
```

Core user entity representing an authenticated user.

#### Properties
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | String | Yes | Unique identifier (UUID) |
| email | String | Yes | User's email address |
| name | String | Yes | Display name |
| firstName | String? | No | First name |
| lastName | String? | No | Last name |
| phoneNumber | String? | No | Contact phone |
| bio | String? | No | User biography |
| profileImageUrl | String? | No | Profile picture URL |
| isEmailVerified | bool | Yes | Email verification status |
| isTwoFactorEnabled | bool | Yes | 2FA status |
| roles | List<String> | Yes | User roles |
| permissions | List<String> | Yes | User permissions |
| createdAt | DateTime | Yes | Account creation date |
| updatedAt | DateTime | Yes | Last update date |
| lastLoginAt | DateTime? | No | Last login timestamp |

### UserProfile Entity
```dart
class UserProfile
```

Extended user profile with additional information.

## State Management APIs

### AuthState
```dart
sealed class AuthState
```

Represents all possible authentication states.

#### States

##### Unauthenticated
```dart
const factory AuthState.unauthenticated()
```
No user is logged in.

##### Authenticating
```dart
const factory AuthState.authenticating()
```
Authentication in progress.

##### Authenticated
```dart
const factory AuthState.authenticated({
  required User user,
  required String accessToken,
  String? refreshToken,
})
```
User successfully authenticated.

##### AuthError
```dart
const factory AuthState.error(String message)
```
Authentication error occurred.

#### Helper Properties
- `bool isAuthenticated`: Check if authenticated
- `bool isLoading`: Check if authenticating
- `bool hasError`: Check if error state
- `User? user`: Get current user
- `String? accessToken`: Get access token

### AuthNotifier
```dart
class AuthNotifier extends StateNotifier<AuthState>
```

Manages authentication state and operations.

#### Key Methods

##### login
```dart
Future<void> login(String email, String password)
```

##### register
```dart
Future<void> register(String email, String password, String name)
```

##### logout
```dart
Future<void> logout()
```

##### refreshUser
```dart
Future<void> refreshUser()
```

## Error Handling APIs

### AppException
```dart
sealed class AppException
```

Base class for all application exceptions.

#### Factory Constructors
- `AppException.network()`: Network-related errors
- `AppException.authentication()`: Auth errors
- `AppException.validation()`: Input validation errors
- `AppException.server()`: Server errors
- `AppException.unknown()`: Unexpected errors

#### Properties
- `String technicalMessage`: For logging
- `String userMessage`: User-friendly message
- `bool isRetryable`: Whether operation can be retried
- `Duration? retryDelay`: Suggested retry delay

### ErrorHandler
```dart
class ErrorHandler
```

Central error handling service.

#### Methods

##### handleException
```dart
AppException handleException(dynamic error, [StackTrace? stackTrace])
```

##### showErrorToUser
```dart
void showErrorToUser(BuildContext context, AppException exception)
```

##### withRetry
```dart
Future<T> withRetry<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration? baseDelay,
})
```

## Storage APIs

### SecureStorageService
```dart
class SecureStorageService
```

Secure storage for sensitive data.

#### Methods

##### saveToken
```dart
Future<void> saveToken(String key, String token)
```

##### getToken
```dart
Future<String?> getToken(String key)
```

##### deleteToken
```dart
Future<void> deleteToken(String key)
```

##### clearAll
```dart
Future<void> clearAll()
```

## Network APIs

### ApiClient
```dart
class ApiClient
```

HTTP client for API communication.

#### Methods

##### get
```dart
Future<Response> get(
  String path, {
  Map<String, dynamic>? queryParameters,
  Options? options,
})
```

##### post
```dart
Future<Response> post(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
})
```

##### put
```dart
Future<Response> put(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
})
```

##### delete
```dart
Future<Response> delete(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
})
```

### ApiResponse
```dart
sealed class ApiResponse<T>
```

Standardized API response wrapper.

#### States

##### Success
```dart
const factory ApiResponse.success({
  required T data,
  String? message,
})
```

##### Error
```dart
const factory ApiResponse.error({
  required String message,
  String? code,
  Map<String, dynamic>? details,
})
```

##### Loading
```dart
const factory ApiResponse.loading()
```

#### Pattern Matching
```dart
response.when(
  success: (data, message) => handleSuccess(data),
  error: (message, code, details) => handleError(message),
  loading: () => showLoader(),
);
```

## Provider APIs

### Core Providers

#### authStateProvider
```dart
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>
```
Main authentication state provider.

#### currentUserProvider
```dart
final currentUserProvider = Provider<User?>
```
Provides current authenticated user.

#### isAuthenticatedProvider
```dart
final isAuthenticatedProvider = Provider<bool>
```
Provides authentication status.

### Usage Examples

#### Watching State
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = ref.watch(currentUserProvider);

    return authState.when(
      authenticated: (user, _, __) => HomeScreen(user: user),
      unauthenticated: () => LoginScreen(),
      authenticating: () => LoadingScreen(),
      error: (message) => ErrorScreen(message: message),
    );
  }
}
```

#### Modifying State
```dart
// Login
ref.read(authStateProvider.notifier).login(email, password);

// Logout
ref.read(authStateProvider.notifier).logout();

// Refresh user
ref.read(authStateProvider.notifier).refreshUser();
```

## Testing APIs

### Mock Providers
```dart
// Override providers for testing
final container = ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWithValue(MockAuthRepository()),
    apiClientProvider.overrideWithValue(MockApiClient()),
  ],
);
```

### Test Utilities
```dart
// Test helper for auth state
AuthState createTestAuthState({User? user}) {
  return user != null
    ? AuthState.authenticated(user: user, accessToken: 'test')
    : AuthState.unauthenticated();
}
```

## Best Practices

### 1. Error Handling
Always handle errors gracefully:
```dart
try {
  final result = await repository.operation();
} catch (e) {
  final appException = errorHandler.handleException(e);
  errorHandler.showErrorToUser(context, appException);
}
```

### 2. State Management
Use appropriate provider types:
- `Provider`: For dependencies
- `StateProvider`: For simple state
- `StateNotifierProvider`: For complex state
- `FutureProvider`: For async operations

### 3. Testing
Always test with mocked dependencies:
```dart
test('should authenticate user', () async {
  final mock = MockAuthRepository();
  when(mock.login(any)).thenAnswer((_) async => testUser);

  final useCase = LoginUseCase(mock);
  final result = await useCase.execute('email', 'password');

  expect(result.isSuccess, true);
});
```

## Migration Guide

### From Provider to Riverpod
```dart
// Before (Provider)
Provider<AuthService>(
  create: (context) => AuthService(),
)

// After (Riverpod)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
```

### From Callbacks to Async/Await
```dart
// Before
authService.login(
  email: email,
  password: password,
  onSuccess: (user) => navigateToHome(),
  onError: (error) => showError(error),
);

// After
try {
  final user = await authService.login(email, password);
  navigateToHome();
} catch (error) {
  showError(error);
}
```

## Changelog
- 2024-01-15: Initial API documentation
- 2024-01-20: Added provider examples
- 2024-01-25: Added testing utilities