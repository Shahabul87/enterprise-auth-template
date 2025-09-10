import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.unauthenticated() = Unauthenticated;

  const factory AuthState.authenticating() = Authenticating;

  const factory AuthState.authenticated({
    required User user,
    required String accessToken,
    String? refreshToken,
  }) = Authenticated;

  const factory AuthState.error(String message) = AuthError;

  bool get isAuthenticated => this is Authenticated;
  bool get isLoading => this is Authenticating;
  bool get hasError => this is AuthError;

  User? get user => when(
    authenticated: (user, _, __) => user,
    unauthenticated: () => null,
    authenticating: () => null,
    error: (_) => null,
  );

  String? get accessToken => when(
    authenticated: (_, token, __) => token,
    unauthenticated: () => null,
    authenticating: () => null,
    error: (_) => null,
  );
}
