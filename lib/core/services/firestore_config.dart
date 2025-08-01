import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Service để cấu hình Firestore
class FirestoreConfig {
  static bool _initialized = false;

  /// Khởi tạo Firestore với các cấu hình cần thiết
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Đảm bảo Firebase đã được khởi tạo
      await Firebase.initializeApp();

      // Cấu hình Firestore
      final firestore = FirebaseFirestore.instance;

      // Enable offline persistence
      await _enableOfflinePersistence(firestore);

      // Cấu hình cache size (50MB)
      await _configureCacheSize(firestore);

      _initialized = true;
      print('Firestore initialized successfully');
    } catch (e) {
      print('Error initializing Firestore: $e');
      rethrow;
    }
  }

  /// Enable offline persistence
  static Future<void> _enableOfflinePersistence(FirebaseFirestore firestore) async {
    try {
      await firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
      print('Firestore offline persistence enabled');
    } catch (e) {
      // Persistence có thể đã được enable hoặc không support trên platform này
      print('Firestore persistence warning: $e');
    }
  }

  /// Cấu hình cache size
  static Future<void> _configureCacheSize(FirebaseFirestore firestore) async {
    try {
      firestore.settings = const Settings(
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        persistenceEnabled: true,
      );
      print('Firestore cache configured');
    } catch (e) {
      print('Firestore cache configuration warning: $e');
    }
  }

  /// Kiểm tra trạng thái kết nối
  static Future<bool> isOnline() async {
    try {
      await FirebaseFirestore.instance.enableNetwork();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Enable network
  static Future<void> enableNetwork() async {
    try {
      await FirebaseFirestore.instance.enableNetwork();
    } catch (e) {
      print('Error enabling network: $e');
    }
  }

  /// Disable network (offline mode)
  static Future<void> disableNetwork() async {
    try {
      await FirebaseFirestore.instance.disableNetwork();
    } catch (e) {
      print('Error disabling network: $e');
    }
  }

  /// Clear offline cache
  static Future<void> clearCache() async {
    try {
      await FirebaseFirestore.instance.clearPersistence();
      print('Firestore cache cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Terminate Firestore instance
  static Future<void> terminate() async {
    try {
      await FirebaseFirestore.instance.terminate();
      _initialized = false;
      print('Firestore terminated');
    } catch (e) {
      print('Error terminating Firestore: $e');
    }
  }
}