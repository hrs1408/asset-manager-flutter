import 'dart:async';
import 'dart:io';

/// Service để kiểm tra kết nối mạng
class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._();
  
  ConnectivityService._();

  final StreamController<bool> _connectivityController = 
      StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Timer? _connectivityTimer;

  /// Khởi tạo service và bắt đầu kiểm tra kết nối
  void initialize() {
    _startConnectivityCheck();
  }

  /// Bắt đầu kiểm tra kết nối định kỳ
  void _startConnectivityCheck() {
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkConnectivity(),
    );
    
    // Kiểm tra ngay lập tức
    _checkConnectivity();
  }

  /// Kiểm tra kết nối mạng
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final newConnectionStatus = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (newConnectionStatus != _isConnected) {
        _isConnected = newConnectionStatus;
        _connectivityController.add(_isConnected);
        
        if (_isConnected) {
          print('Network connection restored');
        } else {
          print('Network connection lost');
        }
      }
    } catch (e) {
      if (_isConnected) {
        _isConnected = false;
        _connectivityController.add(_isConnected);
        print('Network connection lost: $e');
      }
    }
  }

  /// Kiểm tra kết nối một lần
  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Dừng service
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }
}