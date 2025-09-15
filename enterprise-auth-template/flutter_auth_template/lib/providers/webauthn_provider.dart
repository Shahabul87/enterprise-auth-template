import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_response.dart';
import '../services/webauthn_service.dart';

// WebAuthn Credentials Provider
final webAuthnCredentialsProvider = FutureProvider<List<WebAuthnCredential>>((ref) async {
  final webAuthnService = ref.watch(webAuthnServiceProvider);
  final response = await webAuthnService.getUserCredentials();

  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.errorMessage ?? "");
  }
});

// WebAuthn Notifier Provider
final webAuthnProvider = StateNotifierProvider<WebAuthnNotifier, WebAuthnState>((ref) {
  final webAuthnService = ref.watch(webAuthnServiceProvider);
  return WebAuthnNotifier(webAuthnService);
});

/// WebAuthn state
class WebAuthnState {
  final List<WebAuthnCredential> credentials;
  final WebAuthnRegistrationOptions? registrationOptions;
  final WebAuthnAuthenticationOptions? authenticationOptions;
  final bool isRegistering;
  final bool isAuthenticating;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const WebAuthnState({
    this.credentials = const [],
    this.registrationOptions,
    this.authenticationOptions,
    this.isRegistering = false,
    this.isAuthenticating = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  WebAuthnState copyWith({
    List<WebAuthnCredential>? credentials,
    WebAuthnRegistrationOptions? registrationOptions,
    WebAuthnAuthenticationOptions? authenticationOptions,
    bool? isRegistering,
    bool? isAuthenticating,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return WebAuthnState(
      credentials: credentials ?? this.credentials,
      registrationOptions: registrationOptions ?? this.registrationOptions,
      authenticationOptions: authenticationOptions ?? this.authenticationOptions,
      isRegistering: isRegistering ?? this.isRegistering,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get hasCredentials => credentials.isNotEmpty;
  bool get canAuthenticate => hasCredentials && !isLoading;

  @override
  String toString() {
    return 'WebAuthnState(credentials: ${credentials.length}, '
        'isRegistering: $isRegistering, isAuthenticating: $isAuthenticating, '
        'isLoading: $isLoading, errorMessage: $errorMessage, '
        'successMessage: $successMessage)';
  }
}

/// WebAuthn state notifier
class WebAuthnNotifier extends StateNotifier<WebAuthnState> {
  final WebAuthnService _webAuthnService;

  WebAuthnNotifier(this._webAuthnService) : super(const WebAuthnState()) {
    _loadCredentials();
  }

  /// Load user's WebAuthn credentials
  Future<void> _loadCredentials() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _webAuthnService.getUserCredentials();

      if (response.isSuccess) {
        state = state.copyWith(
          credentials: response.data!,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Start WebAuthn registration process
  Future<WebAuthnRegistrationOptions?> startRegistration() async {
    state = state.copyWith(
      isRegistering: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final response = await _webAuthnService.startRegistration();

      if (response.isSuccess) {
        final options = response.data!;
        state = state.copyWith(
          registrationOptions: options,
          isRegistering: false,
        );
        return options;
      } else {
        state = state.copyWith(
          isRegistering: false,
          errorMessage: response.errorMessage ?? "",
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isRegistering: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Complete WebAuthn registration
  Future<bool> completeRegistration({
    required String credentialId,
    required String response,
    required String clientDataJSON,
    required String attestationObject,
    String? deviceName,
  }) async {
    state = state.copyWith(
      isRegistering: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final apiResponse = await _webAuthnService.completeRegistration(
        credentialId: credentialId,
        response: response,
        clientDataJSON: clientDataJSON,
        attestationObject: attestationObject,
        deviceName: deviceName,
      );

      if (apiResponse.isSuccess) {
        state = state.copyWith(
          isRegistering: false,
          successMessage: apiResponse.dataOrNull!,
          registrationOptions: null,
        );

        // Reload credentials
        await _loadCredentials();
        return true;
      } else {
        state = state.copyWith(
          isRegistering: false,
          errorMessage: apiResponse.errorMessage ?? "",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isRegistering: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Start WebAuthn authentication process
  Future<WebAuthnAuthenticationOptions?> startAuthentication({
    String? email,
  }) async {
    state = state.copyWith(
      isAuthenticating: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final response = await _webAuthnService.startAuthentication(email: email);

      if (response.isSuccess) {
        final options = response.data!;
        state = state.copyWith(
          authenticationOptions: options,
          isAuthenticating: false,
        );
        return options;
      } else {
        state = state.copyWith(
          isAuthenticating: false,
          errorMessage: response.errorMessage ?? "",
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Complete WebAuthn authentication
  Future<bool> completeAuthentication({
    required String credentialId,
    required String response,
    required String clientDataJSON,
    required String authenticatorData,
    required String signature,
    required String userHandle,
  }) async {
    state = state.copyWith(
      isAuthenticating: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final apiResponse = await _webAuthnService.completeAuthentication(
        credentialId: credentialId,
        response: response,
        clientDataJSON: clientDataJSON,
        authenticatorData: authenticatorData,
        signature: signature,
        userHandle: userHandle,
      );

      if (apiResponse.isSuccess) {
        state = state.copyWith(
          isAuthenticating: false,
          successMessage: 'Successfully authenticated with passkey!',
          authenticationOptions: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isAuthenticating: false,
          errorMessage: apiResponse.errorMessage ?? "",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Delete a WebAuthn credential
  Future<bool> deleteCredential(String credentialId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _webAuthnService.deleteCredential(credentialId);

      if (response.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          successMessage: response.data!,
        );

        // Reload credentials
        await _loadCredentials();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Update credential name
  Future<bool> updateCredentialName({
    required String credentialId,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _webAuthnService.updateCredentialName(
        credentialId: credentialId,
        name: name,
      );

      if (response.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          successMessage: response.data!,
        );

        // Reload credentials
        await _loadCredentials();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Check if WebAuthn is supported
  bool isWebAuthnSupported() {
    return _webAuthnService.isWebAuthnSupported();
  }

  /// Refresh credentials
  Future<void> refreshCredentials() async {
    await _loadCredentials();
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Clear registration/authentication options
  void clearOptions() {
    state = state.copyWith(
      registrationOptions: null,
      authenticationOptions: null,
    );
  }
}

// Convenience providers
final webAuthnCredentialsCountProvider = Provider<int>((ref) {
  final state = ref.watch(webAuthnProvider);
  return state.credentials.length;
});

final webAuthnHasCredentialsProvider = Provider<bool>((ref) {
  final state = ref.watch(webAuthnProvider);
  return state.hasCredentials;
});

final webAuthnCanAuthenticateProvider = Provider<bool>((ref) {
  final state = ref.watch(webAuthnProvider);
  return state.canAuthenticate;
});

final webAuthnLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(webAuthnProvider);
  return state.isLoading || state.isRegistering || state.isAuthenticating;
});

final webAuthnErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(webAuthnProvider);
  return state.errorMessage;
});

final webAuthnSuccessProvider = Provider<String?>((ref) {
  final state = ref.watch(webAuthnProvider);
  return state.successMessage;
});

final webAuthnSupportedProvider = Provider<bool>((ref) {
  final notifier = ref.watch(webAuthnProvider.notifier);
  return notifier.isWebAuthnSupported();
});