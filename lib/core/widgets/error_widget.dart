import 'package:flutter/material.dart';

import '../error/failures.dart';

/// Widget để hiển thị lỗi một cách nhất quán
class AppErrorWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final String? customMessage;
  final bool showRetryButton;

  const AppErrorWidget({
    Key? key,
    required this.failure,
    this.onRetry,
    this.customMessage,
    this.showRetryButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: _getErrorColor(),
            ),
            const SizedBox(height: 16),
            Text(
              customMessage ?? failure.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    if (failure is NetworkFailure) {
      return Icons.wifi_off;
    } else if (failure is AuthFailure) {
      return Icons.lock_outline;
    } else if (failure is NotFoundFailure) {
      return Icons.search_off;
    } else if (failure is PermissionFailure) {
      return Icons.block;
    } else if (failure is ValidationFailure) {
      return Icons.error_outline;
    } else {
      return Icons.error_outline;
    }
  }

  Color _getErrorColor() {
    if (failure is NetworkFailure) {
      return Colors.orange;
    } else if (failure is AuthFailure) {
      return Colors.red;
    } else if (failure is NotFoundFailure) {
      return Colors.grey;
    } else if (failure is PermissionFailure) {
      return Colors.red;
    } else if (failure is ValidationFailure) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}

/// Widget nhỏ gọn để hiển thị lỗi inline
class InlineErrorWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const InlineErrorWidget({
    Key? key,
    required this.failure,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              failure.message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Snackbar để hiển thị lỗi
class ErrorSnackBar {
  static void show(BuildContext context, Failure failure, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(failure.message),
            ),
          ],
        ),
        backgroundColor: _getSnackBarColor(failure),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static Color _getSnackBarColor(Failure failure) {
    if (failure is NetworkFailure) {
      return Colors.orange;
    } else if (failure is AuthFailure) {
      return Colors.red;
    } else if (failure is ValidationFailure) {
      return Colors.amber.shade700;
    } else {
      return Colors.red;
    }
  }
}

/// Dialog để hiển thị lỗi chi tiết
class ErrorDialog extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const ErrorDialog({
    Key? key,
    required this.failure,
    this.onRetry,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        failure: failure,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          const Text('Đã xảy ra lỗi'),
        ],
      ),
      content: Text(failure.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: const Text('Thử lại'),
          ),
      ],
    );
  }
}