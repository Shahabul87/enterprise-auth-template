import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/two_factor_models.dart';
import '../data/services/two_factor_api_service.dart';
import '../core/security/two_factor_service.dart';
import '../core/errors/app_exception.dart';

// Two-Factor State
class TwoFactorState {
  final TwoFactorStatus? status;
  final TwoFactorSetupResponse? setupResponse;
  final List<String> backupCodes;
  final bool isLoading;
  final String? error;
  final bool isSetupInProgress;
  final bool isEnabled;

  const TwoFactorState({
    this.status,
    this.setupResponse,
    this.backupCodes = const [],
    this.isLoading = false,
    this.error,
    this.isSetupInProgress = false,
    this.isEnabled = false,
  });

  TwoFactorState copyWith({
    TwoFactorStatus? status,
    TwoFactorSetupResponse? setupResponse,
    List<String>? backupCodes,
    bool? isLoading,
    String? error,
    bool? isSetupInProgress,
    bool? isEnabled,
  }) {
    return TwoFactorState(
      status: status ?? this.status,
      setupResponse: setupResponse ?? this.setupResponse,
      backupCodes: backupCodes ?? this.backupCodes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSetupInProgress: isSetupInProgress ?? this.isSetupInProgress,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

// Two-Factor Provider
class TwoFactorNotifier extends StateNotifier<TwoFactorState> {
  final TwoFactorApiService _apiService;
  final TwoFactorService _localService;

  TwoFactorNotifier(this._apiService, this._localService)
    : super(const TwoFactorState());

  /// Initialize and load current status
  Future<void> initialize() async {
    await loadStatus();
  }

  /// Load current 2FA status
  Future<void> loadStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final status = await _apiService.getStatus();
      state = state.copyWith(
        status: status,
        isEnabled: status.enabled,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  /// Begin 2FA setup process
  Future<bool> beginSetup() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final setupResponse = await _apiService.setupTwoFactor();
      state = state.copyWith(
        setupResponse: setupResponse,
        isSetupInProgress: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Complete 2FA setup
  Future<bool> completeSetup(
    String verificationCode, {
    String? password,
  }) async {
    if (state.setupResponse == null) {
      state = state.copyWith(error: 'Setup not initialized');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = TwoFactorEnableRequest(
        code: verificationCode,
        password: password,
      );

      final backupCodes = await _apiService.enableTwoFactor(request);

      state = state.copyWith(
        backupCodes: backupCodes,
        isEnabled: true,
        isSetupInProgress: false,
        isLoading: false,
      );

      // Reload status to get updated information
      await loadStatus();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Verify 2FA code
  Future<bool> verifyCode(String code, {bool isBackupCode = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = TwoFactorVerifyRequest(
        code: code,
        isBackupCode: isBackupCode,
      );

      await _apiService.verifyTwoFactor(request);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Disable 2FA
  Future<bool> disable() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.disableTwoFactor();
      state = state.copyWith(
        isEnabled: false,
        isLoading: false,
        setupResponse: null,
        backupCodes: [],
      );

      // Reload status
      await loadStatus();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Regenerate backup codes
  Future<bool> regenerateBackupCodes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newBackupCodes = await _apiService.regenerateBackupCodes();
      state = state.copyWith(backupCodes: newBackupCodes, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  /// Cancel setup process
  void cancelSetup() {
    state = state.copyWith(
      isSetupInProgress: false,
      setupResponse: null,
      error: null,
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Validate input code using local service
  bool validateInput(String input) {
    return _localService.isTOTPCode(input) || _localService.isBackupCode(input);
  }

  /// Get input type classification
  TwoFactorInputType classifyInput(String input) {
    return _localService.classifyInput(input);
  }

  /// Format backup code for display
  String formatBackupCode(String code) {
    return _localService.formatBackupCode(code);
  }

  /// Get setup instructions
  String getSetupInstructions() {
    return _localService.getSetupInstructions('Enterprise Auth');
  }

  /// Get supported authenticator apps
  List<AuthenticatorApp> getSupportedApps() {
    return _localService.getSupportedAuthenticatorApps();
  }
}

// Provider instances
final twoFactorProvider =
    StateNotifierProvider<TwoFactorNotifier, TwoFactorState>((ref) {
      final apiService = ref.watch(twoFactorApiServiceProvider);
      final localService = ref.watch(twoFactorServiceProvider);
      return TwoFactorNotifier(apiService, localService);
    });

// Computed providers
final isTwoFactorEnabledProvider = Provider<bool>((ref) {
  return ref.watch(twoFactorProvider.select((state) => state.isEnabled));
});

final twoFactorStatusProvider = Provider<TwoFactorStatus?>((ref) {
  return ref.watch(twoFactorProvider.select((state) => state.status));
});

final twoFactorLoadingProvider = Provider<bool>((ref) {
  return ref.watch(twoFactorProvider.select((state) => state.isLoading));
});

final twoFactorErrorProvider = Provider<String?>((ref) {
  return ref.watch(twoFactorProvider.select((state) => state.error));
});

final twoFactorSetupInProgressProvider = Provider<bool>((ref) {
  return ref.watch(
    twoFactorProvider.select((state) => state.isSetupInProgress),
  );
});

final backupCodesProvider = Provider<List<String>>((ref) {
  return ref.watch(twoFactorProvider.select((state) => state.backupCodes));
});
