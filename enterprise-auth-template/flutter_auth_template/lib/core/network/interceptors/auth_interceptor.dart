import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../security/token_manager.dart';
import '../../constants/api_constants.dart';
import '../api_client.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip authentication for certain endpoints
    if (_shouldSkipAuth(options.path)) {
      return handler.next(options);
    }

    try {
      final tokenManager = _ref.read(tokenManagerProvider);
      final token = await tokenManager.getValidAccessToken();

      if (token != null) {
        options.headers[ApiConstants.authorizationHeader] =
            '${ApiConstants.bearerPrefix}$token';
      }

      handler.next(options);
    } catch (e) {
      // If token retrieval fails, continue without token
      handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle token refresh for 401 errors
    if (err.response?.statusCode == 401 &&
        !_shouldSkipAuth(err.requestOptions.path)) {
      try {
        final tokenManager = _ref.read(tokenManagerProvider);
        final newToken = await tokenManager.refreshAccessToken();

        if (newToken != null) {
          // Update the original request with new token
          err.requestOptions.headers[ApiConstants.authorizationHeader] =
              '${ApiConstants.bearerPrefix}$newToken';

          // Retry the original request
          final response = await _ref
              .read(apiClientProvider)
              .dio
              .fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (refreshError) {
        // If refresh fails, clear tokens and redirect to login
        final tokenManager = _ref.read(tokenManagerProvider);
        await tokenManager.clearTokens();
        // TODO: Navigate to login screen
      }
    }

    handler.next(err);
  }

  bool _shouldSkipAuth(String path) {
    final publicPaths = [
      ApiConstants.loginPath,
      ApiConstants.registerPath,
      ApiConstants.refreshPath,
      ApiConstants.forgotPasswordPath,
      ApiConstants.resetPasswordPath,
      ApiConstants.healthPath,
      ApiConstants.oauthProvidersPath,
      ApiConstants.magicLinkVerifyPath,
    ];

    return publicPaths.any((publicPath) => path.contains(publicPath)) ||
        path.contains('/oauth/') ||
        path.contains('/verify-email/') ||
        path.contains('/magic-links/verify/');
  }
}
