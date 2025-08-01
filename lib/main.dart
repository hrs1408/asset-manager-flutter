import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'demo_app.dart';
import 'core/di/service_locator.dart' as di;
import 'core/services/firestore_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // For demo purposes, run the demo app
  // Comment this line and uncomment the full app initialization below for production
  runApp(const DemoApp());
  return;
  
  // Full app initialization (commented for demo)
  /*
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Firestore offline persistence
  await FirestoreService.enableOfflinePersistence();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
  */
}
