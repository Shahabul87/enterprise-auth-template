import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_response.dart';
import '../services/magic_link_service.dart';

// Magic Link Events Provider
final magicLinkEventsProvider = StreamProvider<MagicLinkEvent>((ref) {
  final magicLinkService = ref.watch(magicLinkServiceProvider);
  return magicLinkService.events;
});

// Magic Link Notifier Provider
final magicLinkProvider = StateNotifierProvider<MagicLinkNotifier, MagicLinkState>((ref) {
  final magicLinkService = ref.watch(magicLinkServiceProvider);
  return MagicLinkNotifier(magicLinkService);
});

/// Magic link state
class MagicLinkState {
  final String? email;
  final MagicLinkStatus? status;
  final bool isRequesting;
  final bool isVerifying;
  final String? errorMessage;
  final String? successMessage;

  const MagicLinkState({
    this.email,
    this.status,
    this.isRequesting = false,
    this.isVerifying = false,
    this.errorMessage,
    this.successMessage,
  });

  MagicLinkState copyWith({
    String? email,
    MagicLinkStatus? status,
    bool? isRequesting,
    bool? isVerifying,
    String? errorMessage,
    String? successMessage,
  }) {
    return MagicLinkState(
      email: email ?? this.email,
      status: status ?? this.status,
      isRequesting: isRequesting ?? this.isRequesting,
      isVerifying: isVerifying ?? this.isVerifying,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get isLoading => isRequesting || isVerifying;
  bool get hasPendingLink => status?.isPending == true && !(status?.isExpired == true);

  @override
  String toString() {
    return 'MagicLinkState(email: $email, status: $status, isRequesting: $isRequesting, '
        'isVerifying: $isVerifying, errorMessage: $errorMessage, successMessage: $successMessage)';
  }
}

/// Magic link state notifier
class MagicLinkNotifier extends StateNotifier<MagicLinkState> {
  final MagicLinkService _magicLinkService;
  late StreamSubscription<MagicLinkEvent> _eventSubscription;

  MagicLinkNotifier(this._magicLinkService) : super(const MagicLinkState()) {
    _initializeEventListener();
  }

  void _initializeEventListener() {
    _eventSubscription = _magicLinkService.events.listen((event) {
      _handleMagicLinkEvent(event);
    });
  }

  void _handleMagicLinkEvent(MagicLinkEvent event) {
    if (event is MagicLinkRequested) {
      state = state.copyWith(
        email: event.email,
        isRequesting: false,
        errorMessage: null,
        successMessage: 'Magic link has been sent to ${event.email}',
      );
    } else if (event is MagicLinkVerifying) {
      state = state.copyWith(
        isVerifying: true,
        errorMessage: null,
        successMessage: null,
      );
    } else if (event is MagicLinkVerified) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: null,
        successMessage: 'Successfully authenticated!',
      );
    } else if (event is MagicLinkCancelled) {
      state = state.copyWith(
        email: null,
        status: null,
        errorMessage: null,
        successMessage: 'Magic link has been cancelled',
      );
    } else if (event is MagicLinkError) {
      state = state.copyWith(
        isRequesting: false,
        isVerifying: false,
        errorMessage: event.message,
        successMessage: null,
      );
    }
  }

  /// Request magic link for email
  Future<bool> requestMagicLink({
    required String email,
    String? redirectUrl,
  }) async {
    state = state.copyWith(
      isRequesting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final response = await _magicLinkService.requestMagicLink(
        email: email,
        redirectUrl: redirectUrl,
      );

      if (response.isSuccess) {
        // Update status
        await _loadMagicLinkStatus(email);
        return true;
      } else {
        state = state.copyWith(
          isRequesting: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isRequesting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Verify magic link token
  Future<bool> verifyMagicLink(String token) async {
    state = state.copyWith(
      isVerifying: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final response = await _magicLinkService.verifyMagicLink(token);

      if (response.isSuccess) {
        state = state.copyWith(
          isVerifying: false,
          successMessage: 'Successfully authenticated!',
        );
        return true;
      } else {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Get magic link status
  Future<void> loadMagicLinkStatus(String email) async {
    await _loadMagicLinkStatus(email);
  }

  Future<void> _loadMagicLinkStatus(String email) async {
    try {
      final response = await _magicLinkService.getMagicLinkStatus(email);

      if (response.isSuccess) {
        state = state.copyWith(
          email: email,
          status: response.data,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          errorMessage: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }

  /// Cancel pending magic link
  Future<bool> cancelMagicLink(String email) async {
    try {
      final response = await _magicLinkService.cancelMagicLink(email);

      if (response.isSuccess) {
        return true;
      } else {
        state = state.copyWith(errorMessage: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Open email app
  Future<bool> openEmailApp() async {
    try {
      return await _magicLinkService.openEmailApp();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to open email app: ${e.toString()}',
      );
      return false;
    }
  }

  /// Check if currently processing a magic link
  bool get isProcessingMagicLink => _magicLinkService.isProcessingMagicLink;

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Clear all state
  void clearState() {
    state = const MagicLinkState();
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    _magicLinkService.dispose();
    super.dispose();
  }
}

// Magic Link Status Provider for specific email
final magicLinkStatusProvider = FutureProvider.family<MagicLinkStatus?, String>((ref, email) async {
  if (email.isEmpty) return null;

  final magicLinkService = ref.watch(magicLinkServiceProvider);
  final response = await magicLinkService.getMagicLinkStatus(email);

  if (response.isSuccess) {
    return response.data;
  } else {
    throw Exception(response.message);
  }
});

// Convenience providers
final magicLinkEmailProvider = Provider<String?>((ref) {
  final state = ref.watch(magicLinkProvider);
  return state.email;
});

final magicLinkLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(magicLinkProvider);
  return state.isLoading;
});

final magicLinkErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(magicLinkProvider);
  return state.errorMessage;
});

final magicLinkSuccessProvider = Provider<String?>((ref) {
  final state = ref.watch(magicLinkProvider);
  return state.successMessage;
});

final hasPendingMagicLinkProvider = Provider<bool>((ref) {
  final state = ref.watch(magicLinkProvider);
  return state.hasPendingLink;
});

final magicLinkProcessingProvider = Provider<bool>((ref) {
  final notifier = ref.watch(magicLinkProvider.notifier);
  return notifier.isProcessingMagicLink;
});