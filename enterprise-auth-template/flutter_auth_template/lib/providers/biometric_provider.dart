import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_response.dart';
import '../services/biometric_service.dart';

// Biometric Status Provider
final biometricStatusProvider = FutureProvider<BiometricStatus>((ref) async {
  final biometricService = ref.watch(biometricServiceProvider);
  final response = await biometricService.getBiometricStatus();

  return response.when(
    success: (data, _) => data,
    error: (message, _, __, ___) => throw Exception(message),
    loading: () => throw Exception('Unexpected loading state'),
  );
});

// Biometric Settings Notifier Provider
final biometricSettingsProvider = StateNotifierProvider<BiometricSettingsNotifier, BiometricSettings>((ref) {
  final biometricService = ref.watch(biometricServiceProvider);
  return BiometricSettingsNotifier(biometricService);
});

/// Biometric settings state
class BiometricSettings {
  final bool isEnabled;
  final bool isDeviceSupported;
  final bool isLoading;
  final String? errorMessage;

  const BiometricSettings({
    required this.isEnabled,
    required this.isDeviceSupported,
    this.isLoading = false,
    this.errorMessage,
  });

  BiometricSettings copyWith({
    bool? isEnabled,
    bool? isDeviceSupported,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BiometricSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      isDeviceSupported: isDeviceSupported ?? this.isDeviceSupported,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'BiometricSettings(isEnabled: $isEnabled, isDeviceSupported: $isDeviceSupported, '
        'isLoading: $isLoading, errorMessage: $errorMessage)';
  }
}

/// Biometric settings notifier
class BiometricSettingsNotifier extends StateNotifier<BiometricSettings> {
  final BiometricService _biometricService;

  BiometricSettingsNotifier(this._biometricService)
      : super(const BiometricSettings(
          isEnabled: false,
          isDeviceSupported: false,
        )) {
    _loadBiometricStatus();
  }

  /// Load current biometric status
  Future<void> _loadBiometricStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _biometricService.getBiometricStatus();

      if (response.isSuccess) {
        final status = response.dataOrNull!;
        state = BiometricSettings(
          isEnabled: status.isAppEnabled,
          isDeviceSupported: status.isDeviceSupported,
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

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    if (!state.isDeviceSupported) {
      state = state.copyWith(
        errorMessage: 'Biometric authentication is not supported on this device',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _biometricService.enableBiometricAuth();

      if (response.isSuccess) {
        state = state.copyWith(
          isEnabled: true,
          isLoading: false,
        );
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

  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _biometricService.disableBiometricAuth();

      if (response.isSuccess) {
        state = state.copyWith(
          isEnabled: false,
          isLoading: false,
        );
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

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    if (!state.isEnabled) {
      state = state.copyWith(
        errorMessage: 'Biometric authentication is not enabled',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _biometricService.authenticateWithBiometrics(
        reason: reason,
      );

      state = state.copyWith(isLoading: false);

      if (response.isSuccess) {
        return response.dataOrNull!;
      } else {
        state = state.copyWith(errorMessage: response.errorMessage ?? "");
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

  /// Check biometric availability
  Future<BiometricAvailability> checkAvailability() async {
    final response = await _biometricService.checkBiometricAvailability();

    if (response.isSuccess) {
      return response.dataOrNull!;
    } else {
      throw Exception(response.errorMessage ?? "");
    }
  }

  /// Prompt biometric setup
  Future<bool> promptSetup() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _biometricService.promptBiometricSetup();

      state = state.copyWith(isLoading: false);

      if (response.isSuccess) {
        if (response.dataOrNull!) {
          state = state.copyWith(isEnabled: true);
        }
        return response.dataOrNull!;
      } else {
        state = state.copyWith(errorMessage: response.errorMessage ?? "");
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

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Refresh biometric status
  Future<void> refresh() async {
    await _loadBiometricStatus();
  }
}

// Convenience providers
final biometricEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(biometricSettingsProvider);
  return settings.isEnabled;
});

final biometricSupportedProvider = Provider<bool>((ref) {
  final settings = ref.watch(biometricSettingsProvider);
  return settings.isDeviceSupported;
});

final biometricCanUseProvider = Provider<bool>((ref) {
  final settings = ref.watch(biometricSettingsProvider);
  return settings.isEnabled && settings.isDeviceSupported;
});

final biometricLoadingProvider = Provider<bool>((ref) {
  final settings = ref.watch(biometricSettingsProvider);
  return settings.isLoading;
});

final biometricErrorProvider = Provider<String?>((ref) {
  final settings = ref.watch(biometricSettingsProvider);
  return settings.errorMessage;
});