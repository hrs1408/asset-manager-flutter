import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/error_handler.dart';
import '../error/failures.dart';
import '../services/retry_service.dart';

/// Mixin để xử lý lỗi trong BLoC
mixin ErrorHandlerMixin<Event, State> on BlocBase<State> {
  final ErrorHandler _errorHandler = ErrorHandler.instance;
  final RetryService _retryService = RetryService.instance;

  /// Xử lý lỗi và trả về Failure
  Failure handleError(dynamic error, {String? context}) {
    if (kDebugMode && context != null) {
      print('ErrorHandlerMixin: Error in $context: $error');
    }
    
    _errorHandler.logError(error, context: {'bloc': runtimeType.toString(), 'context': context});
    return _errorHandler.handleError(error);
  }

  /// Thực hiện operation với error handling
  Future<T> safeExecute<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool enableRetry = true,
    int maxRetries = 3,
  }) async {
    try {
      if (enableRetry) {
        return await _retryService.retry<T>(
          operation,
          maxRetries: maxRetries,
          operationName: operationName ?? 'BLoC operation',
        );
      } else {
        return await operation();
      }
    } catch (error) {
      throw handleError(error, context: operationName);
    }
  }

  /// Thực hiện network operation với retry
  Future<T> safeNetworkExecute<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await _retryService.retryNetworkOperation<T>(
        operation,
        operationName: operationName ?? 'Network operation',
      );
    } catch (error) {
      throw handleError(error, context: operationName);
    }
  }

  /// Thực hiện database operation với retry
  Future<T> safeDatabaseExecute<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await _retryService.retryDatabaseOperation<T>(
        operation,
        operationName: operationName ?? 'Database operation',
      );
    } catch (error) {
      throw handleError(error, context: operationName);
    }
  }

  /// Log thông tin debug
  void logInfo(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('${runtimeType.toString()}: $message');
      if (data != null) {
        print('Data: $data');
      }
    }
  }

  /// Log warning
  void logWarning(String message, {dynamic error}) {
    if (kDebugMode) {
      print('WARNING - ${runtimeType.toString()}: $message');
      if (error != null) {
        print('Error: $error');
      }
    }
  }
}

/// Extension để thêm error handling cho Stream
extension StreamErrorHandling<T> on Stream<T> {
  Stream<T> handleErrors(ErrorHandler errorHandler) {
    return handleError((error, stackTrace) {
      final failure = errorHandler.handleError(error);
      throw failure;
    });
  }
}

/// Extension để thêm error handling cho Future
extension FutureErrorHandling<T> on Future<T> {
  Future<T> handleErrors(ErrorHandler errorHandler) {
    return catchError((error, stackTrace) {
      final failure = errorHandler.handleError(error);
      throw failure;
    });
  }
}