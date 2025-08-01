import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'exceptions.dart';
import 'failures.dart';
import '../services/connectivity_service.dart';

/// Global error handler service với localized error messages
class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();
  
  ErrorHandler._();

  final ConnectivityService _connectivityService = ConnectivityService.instance;

  /// Chuyển đổi Exception thành Failure với thông báo tiếng Việt
  Failure handleError(dynamic error) {
    if (kDebugMode) {
      print('ErrorHandler: Handling error: $error');
    }

    // Firebase Auth Errors
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    }

    // Firestore Errors
    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }

    // Socket Errors (Network)
    if (error is SocketException) {
      return NetworkFailure(_getNetworkErrorMessage(error.message));
    }

    // Timeout Errors
    if (error is TimeoutException) {
      return NetworkFailure('Kết nối quá chậm. Vui lòng thử lại.');
    }

    // Custom Exceptions
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }
    if (error is ServerException) {
      return ServerFailure(error.message);
    }
    if (error is CacheException) {
      return CacheFailure(error.message);
    }
    if (error is AuthException) {
      return AuthFailure(error.message);
    }
    if (error is ValidationException) {
      return ValidationFailure(error.message);
    }
    if (error is NotFoundException) {
      return NotFoundFailure(error.message);
    }
    if (error is PermissionException) {
      return PermissionFailure(error.message);
    }

    // Unknown errors
    return UnknownFailure('Đã xảy ra lỗi không xác định. Vui lòng thử lại.');
  }

  /// Xử lý Firebase Auth errors
  Failure _handleFirebaseAuthError(FirebaseAuthException error) {
    String message;
    
    switch (error.code) {
      case 'user-not-found':
        message = 'Không tìm thấy tài khoản với email này.';
        break;
      case 'wrong-password':
        message = 'Mật khẩu không chính xác.';
        break;
      case 'email-already-in-use':
        message = 'Email này đã được sử dụng cho tài khoản khác.';
        break;
      case 'weak-password':
        message = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        break;
      case 'invalid-email':
        message = 'Địa chỉ email không hợp lệ.';
        break;
      case 'user-disabled':
        message = 'Tài khoản này đã bị vô hiệu hóa.';
        break;
      case 'too-many-requests':
        message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
        break;
      case 'operation-not-allowed':
        message = 'Phương thức đăng nhập này không được phép.';
        break;
      case 'network-request-failed':
        message = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        break;
      default:
        message = 'Lỗi xác thực: ${error.message ?? 'Không xác định'}';
    }
    
    return AuthFailure(message, code: error.code);
  }

  /// Xử lý Firebase/Firestore errors
  Failure _handleFirebaseError(FirebaseException error) {
    String message;
    
    switch (error.code) {
      case 'permission-denied':
        message = 'Bạn không có quyền truy cập dữ liệu này.';
        break;
      case 'not-found':
        message = 'Không tìm thấy dữ liệu yêu cầu.';
        break;
      case 'already-exists':
        message = 'Dữ liệu đã tồn tại.';
        break;
      case 'resource-exhausted':
        message = 'Đã vượt quá giới hạn sử dụng. Vui lòng thử lại sau.';
        break;
      case 'failed-precondition':
        message = 'Điều kiện thực hiện không được đáp ứng.';
        break;
      case 'aborted':
        message = 'Thao tác bị hủy bỏ do xung đột.';
        break;
      case 'out-of-range':
        message = 'Dữ liệu vượt quá phạm vi cho phép.';
        break;
      case 'unimplemented':
        message = 'Tính năng này chưa được hỗ trợ.';
        break;
      case 'internal':
        message = 'Lỗi hệ thống nội bộ. Vui lòng thử lại sau.';
        break;
      case 'unavailable':
        message = 'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.';
        break;
      case 'data-loss':
        message = 'Mất dữ liệu không thể khôi phục.';
        break;
      case 'unauthenticated':
        message = 'Bạn cần đăng nhập để thực hiện thao tác này.';
        break;
      default:
        message = 'Lỗi hệ thống: ${error.message ?? 'Không xác định'}';
    }
    
    return ServerFailure(message, code: error.code);
  }

  /// Lấy thông báo lỗi mạng
  String _getNetworkErrorMessage(String originalMessage) {
    if (originalMessage.contains('Failed host lookup')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.';
    }
    if (originalMessage.contains('Connection refused')) {
      return 'Máy chủ từ chối kết nối. Vui lòng thử lại sau.';
    }
    if (originalMessage.contains('Connection timed out')) {
      return 'Kết nối quá chậm. Vui lòng thử lại.';
    }
    return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
  }

  /// Thực hiện retry với exponential backoff
  Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempt++;
        
        if (kDebugMode) {
          print('ErrorHandler: Retry attempt $attempt/$maxRetries failed: $error');
        }

        // Kiểm tra xem có nên retry không
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        // Nếu đã hết số lần retry
        if (attempt >= maxRetries) {
          rethrow;
        }

        // Kiểm tra kết nối mạng trước khi retry
        if (!_connectivityService.isConnected) {
          // Đợi kết nối trở lại
          await _waitForConnection();
        }

        // Đợi trước khi retry
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }

    throw UnknownFailure('Không thể thực hiện thao tác sau $maxRetries lần thử.');
  }

  /// Đợi kết nối mạng trở lại
  Future<void> _waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_connectivityService.isConnected) return;

    final completer = Completer<void>();
    late StreamSubscription subscription;

    // Timeout timer
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(NetworkException('Timeout waiting for network connection'));
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

  /// Kiểm tra xem error có thể retry không
  bool canRetry(dynamic error) {
    // Network errors có thể retry
    if (error is SocketException || 
        error is TimeoutException || 
        error is NetworkException) {
      return true;
    }

    // Một số Firebase errors có thể retry
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'internal':
        case 'aborted':
        case 'resource-exhausted':
          return true;
        default:
          return false;
      }
    }

    // Auth errors thường không retry được
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'network-request-failed':
        case 'too-many-requests':
          return true;
        default:
          return false;
      }
    }

    return false;
  }

  /// Log error để debug
  void logError(dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    if (kDebugMode) {
      print('=== ERROR LOG ===');
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
      if (context != null) {
        print('Context: $context');
      }
      print('=================');
    }
    
    // Trong production, có thể gửi lên crash reporting service
    // như Firebase Crashlytics
  }
}