import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration Firebase pour baka-ticket-2026
/// ⚠️  Remplacez les valeurs par celles de votre console Firebase
///     https://console.firebase.google.com/project/baka-ticket-2026/settings/general/web
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAKATIKET-WEB-KEY-REPLACE-ME',
    appId: '1:000000000000:web:bakatiket000000000000',
    messagingSenderId: '000000000000',
    projectId: 'baka-ticket-2026',
    authDomain: 'baka-ticket-2026.firebaseapp.com',
    databaseURL: 'https://baka-ticket-2026-default-rtdb.firebaseio.com',
    storageBucket: 'baka-ticket-2026.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAKATIKET-ANDROID-KEY-REPLACE-ME',
    appId: '1:000000000000:android:bakatiket000000000000',
    messagingSenderId: '000000000000',
    projectId: 'baka-ticket-2026',
    databaseURL: 'https://baka-ticket-2026-default-rtdb.firebaseio.com',
    storageBucket: 'baka-ticket-2026.appspot.com',
  );
}
