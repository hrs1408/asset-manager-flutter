import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app.dart';
import 'demo_app.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart' as di;
import 'core/services/firestore_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Validate configuration
  AppConfig.validate();
  
  if (AppConfig.useDemoData) {
    // Demo mode - run with sample data
    runApp(const DemoApp());
  } else {
    // Production mode - initialize Firebase and full app
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configure Firebase Emulator if needed
    if (AppConfig.useFirebaseEmulator) {
      await _configureFirebaseEmulator();
    }
    
    // Enable Firestore offline persistence
    if (AppConfig.enableOfflineMode) {
      await FirestoreService.enableOfflinePersistence();
    }
    
    // Initialize dependency injection
    await di.init();
    
    runApp(const MyApp());
  }
}

Future<void> _configureFirebaseEmulator() async {
  // Configure Firestore emulator
  FirebaseFirestore.instance.useFirestoreEmulator(
    AppConfig.firebaseEmulatorHost,
    AppConfig.firestoreEmulatorPort,
  );
  
  // Configure Auth emulator
  await FirebaseAuth.instance.useAuthEmulator(
    AppConfig.firebaseEmulatorHost,
    AppConfig.authEmulatorPort,
  );
  
  print('🧪 Firebase Emulator configured');
}
