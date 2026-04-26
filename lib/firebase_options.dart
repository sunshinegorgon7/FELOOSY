import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        // TODO: add iOS GoogleService-Info.plist and replace this
        throw UnsupportedError('iOS not configured yet — add GoogleService-Info.plist.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAqxUDxqX_-nBgZ168DkgsyAd7nL3GLSU',
    appId: '1:623272973124:android:ba7ec69e4cb336976cfd11',
    messagingSenderId: '623272973124',
    projectId: 'feloosy-e13c3',
    storageBucket: 'feloosy-e13c3.firebasestorage.app',
  );
}
