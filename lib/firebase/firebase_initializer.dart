import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux) {
          await Firebase.initializeApp();
        } else {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
      } else {
        debugPrint('Firebase already initialized.');
      }
      debugPrint('Firebase initialized successfully.');
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'duplicate-app') {
        debugPrint('Firebase initialization skipped: duplicate app.');
      } else {
        debugPrint('Firebase initialization failed: $error');
        debugPrint('$stackTrace');
      }
    } catch (error, stackTrace) {
      debugPrint('Firebase initialization skipped: $error');
      debugPrint('$stackTrace');
    }
  }
}
