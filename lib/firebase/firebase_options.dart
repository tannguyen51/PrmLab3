import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDa5rOtsu8KnN-zlOJzipodIhWJyLcJSRE',
    appId: '1:910378654664:android:c6e77b81f4dc0eefe2fefd',
    messagingSenderId: '910378654664',
    projectId: 'prm393-7a248',
    storageBucket: 'prm393-7a248.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDa5rOtsu8KnN-zlOJzipodIhWJyLcJSRE',
    appId: '1:910378654664:ios:c6e77b81f4dc0eefe2fefd',
    messagingSenderId: '910378654664',
    projectId: 'prm393-7a248',
    storageBucket: 'prm393-7a248.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDa5rOtsu8KnN-zlOJzipodIhWJyLcJSRE',
    appId: '1:910378654664:ios:c6e77b81f4dc0eefe2fefd',
    messagingSenderId: '910378654664',
    projectId: 'prm393-7a248',
    storageBucket: 'prm393-7a248.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDa5rOtsu8KnN-zlOJzipodIhWJyLcJSRE',
    appId: '1:910378654664:android:c6e77b81f4dc0eefe2fefd',
    messagingSenderId: '910378654664',
    projectId: 'prm393-7a248',
    storageBucket: 'prm393-7a248.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDa5rOtsu8KnN-zlOJzipodIhWJyLcJSRE',
    appId: '1:910378654664:android:c6e77b81f4dc0eefe2fefd',
    messagingSenderId: '910378654664',
    projectId: 'prm393-7a248',
    storageBucket: 'prm393-7a248.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDa5rOtsu8KnN-zlOJzipodIhWJyLcJSRE',
    appId: '1:910378654664:web:c6e77b81f4dc0eefe2fefd',
    messagingSenderId: '910378654664',
    projectId: 'prm393-7a248',
    storageBucket: 'prm393-7a248.firebasestorage.app',
  );
}
