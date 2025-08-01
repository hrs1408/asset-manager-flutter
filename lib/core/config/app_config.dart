/// Application configuration
class AppConfig {
  // Data mode configuration
  static const bool _useDemoData = false; // Set to false for production
  
  // Firebase configuration
  static const bool _useFirebaseEmulator = false;
  static const String _firebaseEmulatorHost = 'localhost';
  static const int _firestoreEmulatorPort = 8080;
  static const int _authEmulatorPort = 9099;
  
  // Cache configuration
  static const Duration _cacheMaxAge = Duration(hours: 1);
  static const bool _enableOfflineMode = true;
  
  // UI configuration
  static const bool _showDebugInfo = false;
  static const bool _enableAnimations = true;
  
  // Getters
  static bool get useDemoData => _useDemoData;
  static bool get useFirebaseEmulator => _useFirebaseEmulator;
  static String get firebaseEmulatorHost => _firebaseEmulatorHost;
  static int get firestoreEmulatorPort => _firestoreEmulatorPort;
  static int get authEmulatorPort => _authEmulatorPort;
  static Duration get cacheMaxAge => _cacheMaxAge;
  static bool get enableOfflineMode => _enableOfflineMode;
  static bool get showDebugInfo => _showDebugInfo;
  static bool get enableAnimations => _enableAnimations;
  
  // Environment detection
  static bool get isDevelopment => _useDemoData || _useFirebaseEmulator;
  static bool get isProduction => !isDevelopment;
  
  // Data source configuration
  static String get dataSourceInfo {
    if (_useDemoData) {
      return 'Demo Data';
    } else if (_useFirebaseEmulator) {
      return 'Firebase Emulator';
    } else {
      return 'Firebase Production';
    }
  }
  
  // Debug information
  static Map<String, dynamic> get debugInfo => {
    'useDemoData': _useDemoData,
    'useFirebaseEmulator': _useFirebaseEmulator,
    'enableOfflineMode': _enableOfflineMode,
    'cacheMaxAge': _cacheMaxAge.inMinutes,
    'environment': isDevelopment ? 'Development' : 'Production',
    'dataSource': dataSourceInfo,
  };
  
  // Validation
  static void validate() {
    if (!_useDemoData && !_useFirebaseEmulator) {
      // Production mode - ensure Firebase is properly configured
      print('⚠️  Running in PRODUCTION mode with real Firebase data');
    } else if (_useDemoData) {
      print('🎭 Running in DEMO mode with sample data');
    } else if (_useFirebaseEmulator) {
      print('🧪 Running in DEVELOPMENT mode with Firebase Emulator');
    }
  }
}