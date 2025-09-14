import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_response.dart';
import '../core/storage/secure_storage_service.dart';
import '../domain/entities/user.dart';
import 'api/api_client.dart';
import 'auth_service.dart';

// Magic Link Service Provider
final magicLinkServiceProvider = Provider<MagicLinkService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authService = ref.watch(authServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return MagicLinkService(apiClient, authService, secureStorage);
});

/// Magic Link service for passwordless authentication
class MagicLinkService {
  final ApiClient _apiClient;
  final AuthService _authService;
  final SecureStorageService _secureStorage;

  // Deep link stream
  StreamSubscription<String>? _linkSubscription;
  final StreamController<MagicLinkEvent> _eventController =
      StreamController<MagicLinkEvent>.broadcast();

  // Magic link verification state
  bool _isProcessingMagicLink = false;

  MagicLinkService(this._apiClient, this._authService, this._secureStorage) {
    _initializeLinkListener();
  }

  /// Magic link events stream
  Stream<MagicLinkEvent> get events => _eventController.stream;

  /// Check if currently processing a magic link
  bool get isProcessingMagicLink => _isProcessingMagicLink;

  /// Request magic link for email
  Future<ApiResponse<String>> requestMagicLink({
    required String email,
    String? redirectUrl,
  }) async {
    try {
      final requestData = {
        'email': email,
        if (redirectUrl != null) 'redirect_url': redirectUrl,
      };

      final response = await _apiClient.post(
        ApiConstants.magicLinkRequestPath,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final message = data['data']?['message'] as String? ??
              'Magic link has been sent to your email';

          _eventController.add(MagicLinkEvent.requested(email: email));

          return ApiResponse.success(data: message);
        }
      }

      return ApiResponse.error(
        message: 'Failed to send magic link',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Magic link request failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Verify magic link token manually
  Future<ApiResponse<User>> verifyMagicLink(String token) async {
    try {
      _isProcessingMagicLink = true;
      _eventController.add(MagicLinkEvent.verifying(token: token));

      final response = await _authService.verifyMagicLink(token);

      _isProcessingMagicLink = false;

      if (response.isSuccess) {
        final user = response.data!;
        _eventController.add(MagicLinkEvent.verified(user: user));
        return response;
      } else {
        _eventController.add(MagicLinkEvent.error(
          message: response.message,
          token: token,
        ));
        return response;
      }
    } catch (e) {
      _isProcessingMagicLink = false;
      final errorMessage = 'Magic link verification failed: ${e.toString()}';
      _eventController.add(MagicLinkEvent.error(
        message: errorMessage,
        token: token,
      ));
      return ApiResponse.error(
        message: errorMessage,
        originalError: e,
      );
    }
  }

  /// Get magic link status
  Future<ApiResponse<MagicLinkStatus>> getMagicLinkStatus(String email) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.magicLinkStatusPath,
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final statusData = data['data'];
          if (statusData != null) {
            final status = MagicLinkStatus.fromJson(statusData);
            return ApiResponse.success(data: status);
          }
        }
      }

      return ApiResponse.error(
        message: 'Failed to get magic link status',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Magic link status check failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Cancel pending magic link
  Future<ApiResponse<String>> cancelMagicLink(String email) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.magicLinkCancelPath,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final message = data['data']?['message'] as String? ??
              'Magic link has been cancelled';

          _eventController.add(MagicLinkEvent.cancelled(email: email));

          return ApiResponse.success(data: message);
        }
      }

      return ApiResponse.error(
        message: 'Failed to cancel magic link',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: 'Magic link cancellation failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Open email app for user to check magic link
  Future<bool> openEmailApp() async {
    try {
      // Try platform-specific email apps
      if (Platform.isIOS) {
        // Try iOS Mail app
        const mailUrl = 'message://';
        if (await canLaunchUrl(Uri.parse(mailUrl))) {
          await launchUrl(Uri.parse(mailUrl));
          return true;
        }
      } else if (Platform.isAndroid) {
        // Try Android email apps
        const gmailUrl = 'googlegmail://';
        if (await canLaunchUrl(Uri.parse(gmailUrl))) {
          await launchUrl(Uri.parse(gmailUrl));
          return true;
        }

        // Fallback to generic email intent
        const emailUrl = 'mailto:';
        if (await canLaunchUrl(Uri.parse(emailUrl))) {
          await launchUrl(Uri.parse(emailUrl));
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Failed to open email app: $e');
      return false;
    }
  }

  /// Initialize deep link listener for magic links
  void _initializeLinkListener() {
    if (kIsWeb) {
      // Web doesn't support uni_links, handle URLs differently
      return;
    }

    try {
      _linkSubscription = linkStream.listen(
        (String link) {
          _handleIncomingLink(link);
        },
        onError: (err) {
          debugPrint('Deep link error: $err');
          _eventController.add(MagicLinkEvent.error(
            message: 'Deep link error: ${err.toString()}',
          ));
        },
      );

      // Check for initial link when app is launched
      _checkInitialLink();
    } catch (e) {
      debugPrint('Failed to initialize link listener: $e');
    }
  }

  /// Check for initial deep link when app is launched
  Future<void> _checkInitialLink() async {
    try {
      final String? initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get initial link: ${e.message}');
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }
  }

  /// Handle incoming deep link
  Future<void> _handleIncomingLink(String link) async {
    try {
      debugPrint('Received deep link: $link');

      final Uri uri = Uri.parse(link);

      // Check if this is a magic link
      if (_isMagicLinkUrl(uri)) {
        final String? token = _extractMagicLinkToken(uri);
        if (token != null) {
          await verifyMagicLink(token);
        } else {
          _eventController.add(const MagicLinkEvent.error(
            message: 'Invalid magic link format',
          ));
        }
      }
    } catch (e) {
      debugPrint('Failed to handle incoming link: $e');
      _eventController.add(MagicLinkEvent.error(
        message: 'Failed to process magic link: ${e.toString()}',
      ));
    }
  }

  /// Check if URL is a magic link
  bool _isMagicLinkUrl(Uri uri) {
    // Check if the URL matches the magic link pattern
    // This should match your app's URL scheme and magic link path
    return uri.scheme == 'com.yourapp.auth' &&
        uri.host == 'magic-link' &&
        uri.path == '/verify';
  }

  /// Extract token from magic link URL
  String? _extractMagicLinkToken(Uri uri) {
    return uri.queryParameters['token'];
  }

  /// Handle Dio errors
  ApiResponse<T> _handleDioError<T>(DioException e) {
    if (e.error is AppException) {
      final appError = e.error as AppException;
      return ApiResponse.error(
        message: appError.message,
        code: appError.toString(),
        originalError: e,
      );
    }
    return ApiResponse.error(
      message: e.message ?? 'Request failed',
      originalError: e,
    );
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _eventController.close();
  }
}

/// Magic link status
class MagicLinkStatus {
  final String email;
  final bool isPending;
  final String? requestedAt;
  final String? expiresAt;
  final int? remainingAttempts;

  MagicLinkStatus({
    required this.email,
    required this.isPending,
    this.requestedAt,
    this.expiresAt,
    this.remainingAttempts,
  });

  factory MagicLinkStatus.fromJson(Map<String, dynamic> json) {
    return MagicLinkStatus(
      email: json['email'] as String,
      isPending: json['is_pending'] as bool,
      requestedAt: json['requested_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      remainingAttempts: json['remaining_attempts'] as int?,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    try {
      final expiry = DateTime.parse(expiresAt!);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return false;
    }
  }

  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    try {
      final expiry = DateTime.parse(expiresAt!);
      final now = DateTime.now();
      if (now.isAfter(expiry)) return null;
      return expiry.difference(now);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'MagicLinkStatus(email: $email, isPending: $isPending, '
        'requestedAt: $requestedAt, expiresAt: $expiresAt, '
        'remainingAttempts: $remainingAttempts)';
  }
}

/// Magic link events
abstract class MagicLinkEvent {
  const MagicLinkEvent();

  const factory MagicLinkEvent.requested({required String email}) =
      MagicLinkRequested;

  const factory MagicLinkEvent.verifying({required String token}) =
      MagicLinkVerifying;

  const factory MagicLinkEvent.verified({required User user}) =
      MagicLinkVerified;

  const factory MagicLinkEvent.cancelled({required String email}) =
      MagicLinkCancelled;

  const factory MagicLinkEvent.error({
    required String message,
    String? token,
    String? email,
  }) = MagicLinkError;
}

/// Magic link requested event
class MagicLinkRequested extends MagicLinkEvent {
  final String email;

  const MagicLinkRequested({required this.email});

  @override
  String toString() => 'MagicLinkRequested(email: $email)';
}

/// Magic link verifying event
class MagicLinkVerifying extends MagicLinkEvent {
  final String token;

  const MagicLinkVerifying({required this.token});

  @override
  String toString() => 'MagicLinkVerifying(token: $token)';
}

/// Magic link verified event
class MagicLinkVerified extends MagicLinkEvent {
  final User user;

  const MagicLinkVerified({required this.user});

  @override
  String toString() => 'MagicLinkVerified(user: ${user.email})';
}

/// Magic link cancelled event
class MagicLinkCancelled extends MagicLinkEvent {
  final String email;

  const MagicLinkCancelled({required this.email});

  @override
  String toString() => 'MagicLinkCancelled(email: $email)';
}

/// Magic link error event
class MagicLinkError extends MagicLinkEvent {
  final String message;
  final String? token;
  final String? email;

  const MagicLinkError({
    required this.message,
    this.token,
    this.email,
  });

  @override
  String toString() =>
      'MagicLinkError(message: $message, token: $token, email: $email)';
}

/// Magic link request data
class MagicLinkRequest {
  final String email;
  final String? redirectUrl;

  MagicLinkRequest({
    required this.email,
    this.redirectUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
    };
    if (redirectUrl != null) {
      data['redirect_url'] = redirectUrl;
    }
    return data;
  }

  @override
  String toString() {
    return 'MagicLinkRequest(email: $email, redirectUrl: $redirectUrl)';
  }
}