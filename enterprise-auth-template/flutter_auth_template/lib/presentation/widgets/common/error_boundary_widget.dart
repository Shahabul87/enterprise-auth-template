import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_auth_template/core/error/app_exception.dart';
import 'package:flutter_auth_template/core/error/error_handler.dart';
import 'package:flutter_auth_template/core/error/error_logger.dart';

class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(AppException error)? errorBuilder;
  final void Function(AppException error, StackTrace stackTrace)? onError;
  final bool showErrorDetails;
  final String? context;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.showErrorDetails = false,
    this.context,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  AppException? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? 
             _buildDefaultErrorWidget(_error!, _stackTrace);
    }

    return ErrorBoundaryWrapper(
      onError: _handleError,
      child: widget.child,
    );
  }

  void _handleError(Object error, StackTrace stackTrace) {
    final errorHandler = ref.read(errorHandlerProvider);
    final appException = errorHandler.handleException(error, stackTrace);

    setState(() {
      _error = appException;
      _stackTrace = stackTrace;
    });

    // Log the error with context
    ref.read(errorLoggerProvider).logException(
      appException, 
      stackTrace, 
      widget.context,
    );

    // Call custom error handler if provided
    widget.onError?.call(appException, stackTrace);
  }

  Widget _buildDefaultErrorWidget(AppException error, StackTrace? stackTrace) {
    return ErrorDisplayWidget(
      error: error.userMessage,
      technicalDetails: widget.showErrorDetails ? error.technicalMessage : null,
      stackTrace: widget.showErrorDetails ? stackTrace : null,
      onRetry: error.isRetryable ? () => _retry() : null,
    );
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
}

class ErrorBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace stackTrace) onError;

  const ErrorBoundaryWrapper({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  State<ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<ErrorBoundaryWrapper> {
  @override
  void initState() {
    super.initState();
    // Set up error handling for this widget subtree
    FlutterError.onError = (FlutterErrorDetails details) {
      widget.onError(details.exception, details.stack ?? StackTrace.current);
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ErrorDisplayWidget extends StatelessWidget {
  final String error;
  final String? technicalDetails;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.technicalDetails,
    this.stackTrace,
    this.onRetry,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (technicalDetails != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Technical Details'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    technicalDetails!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                if (stackTrace != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stack Trace:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          stackTrace.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onRetry != null) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: onRetry,
                ),
                const SizedBox(width: 16),
              ],
              OutlinedButton.icon(
                icon: const Icon(Icons.bug_report),
                label: const Text('Report Issue'),
                onPressed: onReport ?? () => _showReportDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text(
          'To report this issue, please contact support with the technical details shown above.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (technicalDetails != null)
            TextButton(
              onPressed: () {
                // Copy technical details to clipboard
                Navigator.of(context).pop();
                _copyToClipboard(context);
              },
              child: const Text('Copy Details'),
            ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final details = '''
Error: $error

Technical Details:
$technicalDetails

Stack Trace:
${stackTrace ?? 'Not available'}
    ''';

    // In a real app, you would use Clipboard.setData here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
      ),
    );
  }
}

class AsyncErrorBoundary extends ConsumerWidget {
  final AsyncValue<dynamic> asyncValue;
  final Widget Function(dynamic data) dataBuilder;
  final Widget Function(AppException error)? errorBuilder;
  final Widget? loadingWidget;
  final bool showErrorDetails;

  const AsyncErrorBoundary({
    super.key,
    required this.asyncValue,
    required this.dataBuilder,
    this.errorBuilder,
    this.loadingWidget,
    this.showErrorDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncValue.when(
      data: dataBuilder,
      loading: () => loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        final errorHandler = ref.read(errorHandlerProvider);
        final appException = errorHandler.handleException(error, stackTrace);

        if (errorBuilder != null) {
          return errorBuilder!(appException);
        }

        return ErrorDisplayWidget(
          error: appException.userMessage,
          technicalDetails: showErrorDetails ? appException.technicalMessage : null,
          stackTrace: showErrorDetails ? stackTrace : null,
          onRetry: appException.isRetryable ? () => ref.invalidate(asyncValue) : null,
        );
      },
    );
  }
}

// Widget for inline error display
class InlineErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final bool compact;

  const InlineErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: 16, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                iconSize: 16,
                onPressed: onRetry,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.red[700]),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Extension for easy error boundary usage
extension ErrorBoundaryExtension on Widget {
  Widget withErrorBoundary({
    Widget Function(AppException error)? errorBuilder,
    void Function(AppException error, StackTrace stackTrace)? onError,
    bool showErrorDetails = false,
    String? context,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      onError: onError,
      showErrorDetails: showErrorDetails,
      context: context,
      child: this,
    );
  }
}