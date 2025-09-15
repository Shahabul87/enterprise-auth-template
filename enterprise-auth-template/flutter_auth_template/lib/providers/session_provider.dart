import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/user.dart';
import '../data/models/auth_request.dart';
import '../services/session_service.dart';

// Session State Provider
final sessionStateProvider = StreamProvider<SessionState>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.sessionState;
});

// Current Session Provider
final currentSessionProvider = Provider<SessionState>((ref) {
  final sessionAsyncValue = ref.watch(sessionStateProvider);
  return sessionAsyncValue.when(
    data: (state) => state,
    loading: () => const SessionState.initializing(),
    error: (error, _) => SessionState.error(message: error.toString()),
  );
});

// Session Notifier Provider
final sessionNotifierProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return SessionNotifier(sessionService);
});

/// Session state notifier
class SessionNotifier extends StateNotifier<SessionState> {
  final SessionService _sessionService;
  late StreamSubscription<SessionState> _sessionSubscription;

  SessionNotifier(this._sessionService) : super(const SessionState.initializing()) {
    _initializeSession();
  }

  void _initializeSession() {
    _sessionSubscription = _sessionService.sessionState.listen((sessionState) {
      state = sessionState;
    });

    // Set initial state
    state = _sessionService.currentState;
  }

  /// Login with credentials
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _sessionService.login(
        email: email,
        password: password,
      );

      response.when(
        success: (user, _) {
          state = SessionState.authenticated(user: user);
        },
        error: (message, _, __, ___) {
          state = SessionState.error(message: message);
        },
        loading: () {
          state = const SessionState.initializing();
        },
      );
    } catch (e) {
      state = SessionState.error(message: e.toString());
    }
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _sessionService.register(
        email: email,
        password: password,
        name: name,
      );

      response.when(
        success: (user, _) {
          state = SessionState.authenticated(user: user);
        },
        error: (message, _, __, ___) {
          state = SessionState.error(message: message);
        },
        loading: () {
          state = const SessionState.initializing();
        },
      );
    } catch (e) {
      state = SessionState.error(message: e.toString());
    }
  }

  /// OAuth login
  Future<void> oauthLogin(OAuthLoginRequest request) async {
    try {
      final response = await _sessionService.oauthLogin(request);

      response.when(
        success: (user, _) {
          state = SessionState.authenticated(user: user);
        },
        error: (message, _, __, ___) {
          state = SessionState.error(message: message);
        },
        loading: () {
          state = const SessionState.initializing();
        },
      );
    } catch (e) {
      state = SessionState.error(message: e.toString());
    }
  }

  /// Two-factor authentication verification
  Future<void> verify2FA(String code) async {
    try {
      final response = await _sessionService.verify2FA(code);

      response.when(
        success: (user, _) {
          state = SessionState.authenticated(user: user);
        },
        error: (message, _, __, ___) {
          state = SessionState.error(message: message);
        },
        loading: () {
          state = const SessionState.initializing();
        },
      );
    } catch (e) {
      state = SessionState.error(message: e.toString());
    }
  }

  /// Magic link verification
  Future<void> verifyMagicLink(String token) async {
    try {
      final response = await _sessionService.verifyMagicLink(token);

      response.when(
        success: (user, _) {
          state = SessionState.authenticated(user: user);
        },
        error: (message, _, __, ___) {
          state = SessionState.error(message: message);
        },
        loading: () {
          state = const SessionState.initializing();
        },
      );
    } catch (e) {
      state = SessionState.error(message: e.toString());
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _sessionService.logout();
    } catch (e) {
      // Even if logout fails, we should clear the session
      state = const SessionState.unauthenticated();
    }
  }

  /// Update user information
  void updateUser(User user) {
    _sessionService.updateUser(user);
  }

  /// Refresh token
  Future<bool> refreshToken() async {
    return await _sessionService.refreshToken();
  }

  /// Check session validity
  Future<bool> checkSessionValidity() async {
    return await _sessionService.checkSessionValidity();
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      state = const SessionState.unauthenticated();
    }
  }

  @override
  void dispose() {
    _sessionSubscription.cancel();
    _sessionService.dispose();
    super.dispose();
  }
}

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session.isAuthenticated ? session.user : null;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session.isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session.isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session.hasError ? session.message : null;
});

final sessionStatusProvider = Provider<SessionStatus>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session.status;
});