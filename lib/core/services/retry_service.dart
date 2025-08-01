import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../error/error_handler.dart';
import 'connectivity_service.dart';

/// Service để retry các operations thất bại
class RetryService {
  static RetryService? _instance;
  static RetryService get instance => _instance ??= RetryService._();
  
  RetryService._();

  final ErrorHandler _errorHandler = ErrorHandler.instance;
  final ConnectivityService _connectivityService = ConnectivityService.instance;

  /// Retry một operation với các tùy chọn cấu hình
  Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    double backoffMultiplier = 2.0,
    double jitter = 0.1,
    bool Function(dynamic error)? shouldRetry,
    String? operationName,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    dynamic lastError;

    while (attempt < maxRetries) {
      try {
        if (kDebugMode && operationName != null) {
          print('RetryService: Attempting $operationName (attempt ${attempt + 1}/$maxRetries)');
        }

        return await operation();
      } catch (error) {
        lastError = error;
        attempt++;
        
        if (kDebugMode) {
          print('RetryService: ${operationName ?? 'Operation'} failed on attempt $attempt: $error');
        }

        // Kiểm tra xem có nên retry không
        final canRetry = shouldRetry?.call(error) ?? _errorHandler.canRetry(error);
        
        if (!canRetry || attempt >= maxRetries) {
          if (kDebugMode) {
            print('RetryService: Not retrying. CanRetry: $canRetry, Attempt: $attempt/$maxRetries');
          }
          rethrow;
        }

        // Đợi kết nối mạng nếu cần
        if (!_connectivityService.isConnected) {
          if (kDebugMode) {
            print('RetryService: Waiting for network connection...');
          }
          
          try {
            await _waitForConnection(timeout: const Duration(seconds: 10));
          } catch (e) {
            if (kDebugMode) {
              print('RetryService: Network wait timeout, continuing with retry');
            }
          }
        }

        // Tính toán delay với jitter
        final jitterAmount = delay.inMilliseconds * jitter;
        final randomJitter = (Random().nextDouble() - 0.5) * 2 * jitterAmount;
        final actualDelay = Duration(
          milliseconds: (delay.inMilliseconds + randomJitter).round(),
        );

        if (kDebugMode) {
          print('RetryService: Waiting ${actualDelay.inMilliseconds}ms before retry...');
        }

        await Future.delayed(actualDelay);

        // Tăng delay cho lần retry tiếp theo
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * backoffMultiplier).round(),
            maxDelay.inMilliseconds,
          ),
        );
      }
    }

    // Không bao giờ đến đây, nhưng để đảm bảo type safety
    throw lastError ?? Exception('Unknown error in retry operation');
  }

  /// Retry với exponential backoff đơn giản
  Future<T> retryWithExponentialBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    String? operationName,
  }) async {
    return retry<T>(
      operation,
      maxRetries: maxRetries,
      initialDelay: const Duration(milliseconds: 500),
      maxDelay: const Duration(seconds: 10),
      backoffMultiplier: 2.0,
      jitter: 0.1,
      operationName: operationName,
    );
  }

  /// Retry cho network operations
  Future<T> retryNetworkOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 5,
    String? operationName,
  }) async {
    return retry<T>(
      operation,
      maxRetries: maxRetries,
      initialDelay: const Duration(seconds: 1),
      maxDelay: const Duration(seconds: 30),
      backoffMultiplier: 1.5,
      jitter: 0.2,
      shouldRetry: (error) => _isNetworkError(error),
      operationName: operationName,
    );
  }

  /// Retry cho database operations
  Future<T> retryDatabaseOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    String? operationName,
  }) async {
    return retry<T>(
      operation,
      maxRetries: maxRetries,
      initialDelay: const Duration(milliseconds: 200),
      maxDelay: const Duration(seconds: 5),
      backoffMultiplier: 2.0,
      jitter: 0.1,
      shouldRetry: (error) => _isDatabaseRetryableError(error),
      operationName: operationName,
    );
  }

  /// Đợi kết nối mạng trở lại
  Future<void> _waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_connectivityService.isConnected) return;

    final completer = Completer<void>();
    late StreamSubscription subscription;

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(TimeoutException('Network connection timeout', timeout));
      }
    });

    subscription = _connectivityService.connectivityStream.listen((isConnected) {
      if (isConnected && !completer.isCompleted) {
        timer.cancel();
        subscription.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }

  /// Kiểm tra xem có phải network error không
  bool _isNetworkError(dynamic error) {
    return error.toString().contains('SocketException') ||
           error.toString().contains('TimeoutException') ||
           error.toString().contains('NetworkException') ||
           error.toString().contains('network-request-failed');
  }

  /// Kiểm tra xem database error có thể retry không
  bool _isDatabaseRetryableError(dynamic error) {
    if (error.toString().contains('unavailable') ||
        error.toString().contains('internal') ||
        error.toString().contains('aborted') ||
        error.toString().contains('resource-exhausted')) {
      return true;
    }
    return false;
  }

  /// Tạo retry policy tùy chỉnh
  RetryPolicy createPolicy({
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    double backoffMultiplier = 2.0,
    double jitter = 0.1,
    bool Function(dynamic error)? shouldRetry,
  }) {
    return RetryPolicy(
      maxRetries: maxRetries,
      initialDelay: initialDelay,
      maxDelay: maxDelay,
      backoffMultiplier: backoffMultiplier,
      jitter: jitter,
      shouldRetry: shouldRetry,
    );
  }
}

/// Retry policy configuration
class RetryPolicy {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final double jitter;
  final bool Function(dynamic error)? shouldRetry;

  const RetryPolicy({
    required this.maxRetries,
    required this.initialDelay,
    required this.maxDelay,
    required this.backoffMultiplier,
    required this.jitter,
    this.shouldRetry,
  });

  /// Predefined policies
  static const RetryPolicy network = RetryPolicy(
    maxRetries: 5,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 30),
    backoffMultiplier: 1.5,
    jitter: 0.2,
  );

  static const RetryPolicy database = RetryPolicy(
    maxRetries: 3,
    initialDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 5),
    backoffMultiplier: 2.0,
    jitter: 0.1,
  );

  static const RetryPolicy auth = RetryPolicy(
    maxRetries: 2,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 10),
    backoffMultiplier: 2.0,
    jitter: 0.1,
  );
}