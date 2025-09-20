# Infrastructure Layer

## Overview
The infrastructure layer contains all framework-specific implementations and external service integrations. This layer implements the interfaces defined in the domain layer and handles all technical concerns.

## Directory Structure

```
infrastructure/
├── services/        # External service implementations
│   ├── auth/       # Authentication services
│   ├── analytics/  # Analytics services
│   └── push/       # Push notification services
├── network/         # Network configuration and clients
│   ├── api/        # API client implementations
│   ├── interceptors/ # Request/response interceptors
│   └── websocket/  # WebSocket implementations
├── storage/         # Data persistence implementations
│   ├── secure/     # Secure storage (tokens, credentials)
│   ├── cache/      # Cache implementations
│   └── local/      # Local database implementations
├── security/        # Security implementations
│   ├── encryption/ # Encryption/decryption services
│   ├── biometric/  # Biometric authentication
│   └── keychain/   # Platform-specific secure storage
├── datasources/     # Data source implementations
│   ├── remote/     # Remote API datasources
│   └── local/      # Local datasources
└── config/          # Configuration files
    ├── env/        # Environment configurations
    └── constants/  # Infrastructure constants
```

## Principles

### 1. Dependency Direction
- Infrastructure depends on Domain (implements interfaces)
- Infrastructure can depend on Data layer
- No other layers should depend on Infrastructure

### 2. Framework Isolation
- All framework-specific code lives here
- Changes to frameworks should only affect this layer
- Business logic remains independent

### 3. Interface Implementation
- All services implement domain interfaces
- Concrete implementations are injected via dependency injection
- Multiple implementations can exist (e.g., mock, production)

## Examples

### Service Implementation
```dart
// Domain interface (in domain/repositories/)
abstract class AuthRepository {
  Future<User> login(LoginRequest request);
}

// Infrastructure implementation
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  @override
  Future<User> login(LoginRequest request) async {
    // Implementation details
  }
}
```

### Dependency Injection
```dart
// In providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});
```

## Migration Guide

When moving services to this layer:

1. Create appropriate subdirectory
2. Move service implementation
3. Create or implement domain interface
4. Update provider to use new location
5. Update all imports
6. Test thoroughly

## Best Practices

1. **Keep implementations focused**: Single responsibility principle
2. **Use dependency injection**: Never instantiate directly
3. **Handle errors gracefully**: Convert to domain exceptions
4. **Mock for testing**: Create mock implementations
5. **Document external dependencies**: API versions, SDK requirements
6. **Version external APIs**: Support multiple API versions if needed
7. **Implement retry logic**: For network operations
8. **Cache appropriately**: Reduce network calls
9. **Log infrastructure events**: For debugging and monitoring
10. **Secure sensitive data**: Use platform security features