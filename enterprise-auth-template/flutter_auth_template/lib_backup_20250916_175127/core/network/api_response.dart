import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Generic API response wrapper
@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse.success({
    required T data,
    String? message,
  }) = _Success<T>;

  const factory ApiResponse.error({
    required String message,
    String? code,
    Object? originalError,
    Map<String, dynamic>? details,
  }) = _Error<T>;

  const factory ApiResponse.loading() = _Loading<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

/// Extension methods for ApiResponse
extension ApiResponseExtension<T> on ApiResponse<T> {
  /// Check if response is successful
  bool get isSuccess => when(
        success: (_, __) => true,
        error: (_, __, ___, ____) => false,
        loading: () => false,
      );

  /// Check if response is error
  bool get isError => when(
        success: (_, __) => false,
        error: (_, __, ___, ____) => true,
        loading: () => false,
      );

  /// Check if response is loading
  bool get isLoading => when(
        success: (_, __) => false,
        error: (_, __, ___, ____) => false,
        loading: () => true,
      );

  /// Get data if successful, otherwise null
  T? get dataOrNull => when(
        success: (data, _) => data,
        error: (_, __, ___, ____) => null,
        loading: () => null,
      );

  /// Get error message if error, otherwise null
  String? get errorMessage => when(
        success: (_, __) => null,
        error: (message, _, __, ___) => message,
        loading: () => null,
      );

  /// Get error code if error, otherwise null
  String? get errorCode => when(
        success: (_, __) => null,
        error: (_, code, __, ___) => code,
        loading: () => null,
      );

  /// Transform the data type
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    return when(
      success: (data, message) => ApiResponse.success(
        data: mapper(data),
        message: message,
      ),
      error: (message, code, originalError, details) => ApiResponse.error(
        message: message,
        code: code,
        originalError: originalError,
        details: details,
      ),
      loading: () => const ApiResponse.loading(),
    );
  }

  /// Handle the response with callbacks
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, String? code) onError,
    required R Function() onLoading,
  }) {
    return when(
      success: (data, _) => onSuccess(data),
      error: (message, code, _, __) => onError(message, code),
      loading: () => onLoading(),
    );
  }
}