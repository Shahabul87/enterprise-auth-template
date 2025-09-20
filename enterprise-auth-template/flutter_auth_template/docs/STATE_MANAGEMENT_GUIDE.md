# State Management Guide

## Overview
This guide provides comprehensive documentation for state management in the Flutter Authentication Template using Riverpod.

## Table of Contents
1. [Provider Architecture](#provider-architecture)
2. [Core Providers](#core-providers)
3. [State Management Patterns](#state-management-patterns)
4. [Provider Types](#provider-types)
5. [Best Practices](#best-practices)
6. [Testing Providers](#testing-providers)

## Provider Architecture

### Provider Hierarchy
```
ProviderScope (root)
├── Infrastructure Providers
│   ├── apiClientProvider
│   ├── secureStorageProvider
│   └── networkProvider
├── Repository Providers
│   ├── authRepositoryProvider
│   ├── userRepositoryProvider
│   └── sessionRepositoryProvider
├── Service Providers
│   ├── authServiceProvider
│   ├── biometricServiceProvider
│   └── webSocketServiceProvider
└── State Providers
    ├── authStateProvider
    ├── profileStateProvider
    └── sessionStateProvider
```

## Core Providers

### Authentication State Provider
```dart
/// Main authentication state management provider.
///
/// This provider manages the entire authentication lifecycle including:
/// - Login/logout operations
/// - Token management
/// - User session state
/// - Authentication error handling
///
/// Usage:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   authenticated: (user, token) => HomeScreen(),
///   unauthenticated: () => LoginScreen(),
///   authenticating: () => LoadingScreen(),
///   error: (message) => ErrorScreen(message),
/// );
/// ```
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final oauthService = ref.watch(oauthServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(authService, oauthService, secureStorage);
});
```

### Current User Provider
```dart
/// Provides the current authenticated user.
///
/// Returns null if not authenticated.
/// Automatically updates when auth state changes.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});
```

### Authentication Status Provider
```dart
/// Provides boolean authentication status.
///
/// Useful for simple auth checks in widgets.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});
```

## State Management Patterns

### 1. Authentication Flow Pattern
```dart
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(/*dependencies*/) : super(const AuthState.unauthenticated());

  /// Login flow with comprehensive error handling
  Future<void> login(String email, String password) async {
    // 1. Set loading state
    state = const AuthState.authenticating();

    try {
      // 2. Perform authentication
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      // 3. Handle response
      response.when(
        success: (user, message) {
          // 4a. Update to authenticated state
          state = AuthState.authenticated(
            user: user,
            accessToken: response.accessToken,
          );
        },
        error: (message, code, _, __) {
          // 4b. Handle error
          state = AuthState.error(message);
        },
        loading: () {
          // Keep loading state
        },
      );
    } catch (e) {
      // 5. Handle unexpected errors
      state = AuthState.error('An unexpected error occurred');
    }
  }
}
```

### 2. Profile Management Pattern
```dart
/// Profile state management with optimistic updates
class ProfileNotifier extends StateNotifier<ProfileState> {
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    // 1. Store original state for rollback
    final originalState = state;

    // 2. Optimistic update
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      state = ProfileLoaded(
        currentProfile.copyWith(updates),
      );
    }

    try {
      // 3. Perform actual update
      final response = await _profileService.updateProfile(updates);

      if (response.isError) {
        // 4a. Rollback on error
        state = originalState;
        throw Exception(response.error.message);
      }
    } catch (e) {
      // 4b. Rollback on exception
      state = originalState;
      state = ProfileError(e.toString());
    }
  }
}
```

### 3. Session Management Pattern
```dart
/// Session state with automatic refresh
class SessionNotifier extends StateNotifier<SessionState> {
  Timer? _refreshTimer;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void startSession(String token, Duration expiresIn) {
    state = SessionState.active(token: token, expiresAt: DateTime.now().add(expiresIn));

    // Schedule automatic refresh
    _refreshTimer = Timer(
      expiresIn - const Duration(minutes: 5), // Refresh 5 minutes before expiry
      () => refreshSession(),
    );
  }

  Future<void> refreshSession() async {
    try {
      final newToken = await _authService.refreshToken();
      startSession(newToken.token, newToken.expiresIn);
    } catch (e) {
      state = const SessionState.expired();
    }
  }
}
```

## Provider Types

### 1. Provider
Basic provider for dependencies and computed values.
```dart
/// Simple dependency provider
final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig(baseUrl: Config.apiUrl);
});

/// Computed provider
final userDisplayNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.name ?? 'Guest';
});
```

### 2. StateProvider
For simple mutable state.
```dart
/// Theme mode toggle
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// Usage in widget
final themeMode = ref.watch(themeModeProvider);
ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
```

### 3. StateNotifierProvider
For complex state with business logic.
```dart
/// Complex state management
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.watch(productServiceProvider));
});

class CartNotifier extends StateNotifier<CartState> {
  void addItem(Product product) {
    state = state.copyWith(
      items: [...state.items, product],
    );
  }
}
```

### 4. FutureProvider
For async operations.
```dart
/// Fetch user profile
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) throw Exception('Not authenticated');

  return ref.watch(profileServiceProvider).getProfile(userId);
});

/// Usage with AsyncValue
ref.watch(userProfileProvider).when(
  data: (profile) => ProfileWidget(profile),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(error),
);
```

### 5. StreamProvider
For real-time data.
```dart
/// WebSocket messages stream
final messagesProvider = StreamProvider<List<Message>>((ref) {
  final websocket = ref.watch(webSocketServiceProvider);
  return websocket.messagesStream;
});
```

## Best Practices

### 1. Provider Organization
```dart
// Group related providers in single file
// lib/presentation/providers/auth_providers.dart

/// Authentication related providers
final authServiceProvider = Provider<AuthService>((ref) => /*...*/);
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => /*...*/);
final currentUserProvider = Provider<User?>((ref) => /*...*/);
final isAuthenticatedProvider = Provider<bool>((ref) => /*...*/);
```

### 2. Provider Scoping
```dart
// Override providers for specific widget trees
ProviderScope(
  overrides: [
    // Use mock service for testing
    authServiceProvider.overrideWithValue(MockAuthService()),
  ],
  child: MyApp(),
);
```

### 3. Auto-Dispose
```dart
/// Auto-dispose provider when not in use
final searchResultsProvider = FutureProvider.autoDispose<List<Result>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(searchServiceProvider).search(query);
});
```

### 4. Family Providers
```dart
/// Parameterized providers
final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  return ref.watch(userServiceProvider).getUser(userId);
});

// Usage
final user = ref.watch(userByIdProvider('user123'));
```

### 5. Select for Performance
```dart
/// Only rebuild when specific field changes
final userName = ref.watch(
  currentUserProvider.select((user) => user?.name),
);
```

## Testing Providers

### Unit Testing
```dart
void main() {
  test('AuthNotifier login updates state correctly', () async {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(MockAuthService()),
      ],
    );

    final notifier = container.read(authStateProvider.notifier);

    // Initial state
    expect(container.read(authStateProvider), const AuthState.unauthenticated());

    // Perform login
    await notifier.login('test@example.com', 'password');

    // Verify authenticated state
    expect(
      container.read(authStateProvider),
      isA<Authenticated>(),
    );
  });
}
```

### Widget Testing
```dart
testWidgets('Login screen shows loading during authentication', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(() => MockAuthNotifier()),
      ],
      child: MaterialApp(home: LoginScreen()),
    ),
  );

  // Trigger login
  await tester.enterText(find.byType(TextField).first, 'test@example.com');
  await tester.enterText(find.byType(TextField).last, 'password');
  await tester.tap(find.text('Login'));
  await tester.pump();

  // Verify loading state
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Mock Providers
```dart
class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier() : super(const AuthState.unauthenticated());

  @override
  Future<void> login(String email, String password) async {
    state = const AuthState.authenticating();
    await Future.delayed(const Duration(seconds: 1));
    state = AuthState.authenticated(
      user: User(id: '1', email: email, name: 'Test User'),
      accessToken: 'mock_token',
    );
  }
}
```

## Common Patterns

### 1. Loading States
```dart
/// Generic loading state management
mixin LoadingStateMixin<T> on StateNotifier<T> {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<R> withLoading<R>(Future<R> Function() operation) async {
    _isLoading = true;
    // Update state to show loading
    try {
      return await operation();
    } finally {
      _isLoading = false;
    }
  }
}
```

### 2. Error Handling
```dart
/// Centralized error handling
extension ErrorHandlingExtension on WidgetRef {
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    void Function(String)? onError,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final errorMessage = e.toString();
      onError?.call(errorMessage);
      // Show snackbar or dialog
      return null;
    }
  }
}
```

### 3. Debounced Search
```dart
/// Debounced search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) return [];

  // Debounce
  await Future.delayed(const Duration(milliseconds: 500));

  return ref.watch(searchServiceProvider).search(query);
});
```

## Migration from Other State Management

### From Provider to Riverpod
```dart
// Before (Provider)
class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}

// After (Riverpod)
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.unauthenticated());

  void setUser(User user) {
    state = AuthState.authenticated(user: user, accessToken: '');
  }
}
```

### From Bloc to Riverpod
```dart
// Before (Bloc)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
}

// After (Riverpod)
class AuthNotifier extends StateNotifier<AuthState> {
  Future<void> login(String email, String password) async {
    // Direct method call instead of events
  }
}
```

## Performance Optimization

### 1. Selective Watching
```dart
// Watch only what you need
final userName = ref.watch(
  authStateProvider.select((state) => state.user?.name),
);
```

### 2. Cached Providers
```dart
/// Cache expensive computations
final expensiveComputationProvider = Provider<ExpensiveResult>((ref) {
  ref.keepAlive(); // Keep in memory
  return performExpensiveComputation();
});
```

### 3. Lazy Initialization
```dart
/// Initialize only when accessed
final lazyServiceProvider = Provider<Service>((ref) {
  // This runs only when first accessed
  return Service.initialize();
});
```

## Debugging

### Provider Inspector
```dart
// Enable provider observer for debugging
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('${provider.name ?? provider.runtimeType} updated');
  }
}

// Use in main.dart
runApp(
  ProviderScope(
    observers: [ProviderLogger()],
    child: MyApp(),
  ),
);
```

## Conclusion

This state management architecture provides:
- Type-safe state management
- Clear separation of concerns
- Testable business logic
- Performance optimization
- Developer-friendly API

Follow these patterns and best practices for maintainable and scalable state management in your Flutter application.