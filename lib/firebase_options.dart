import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

import 'app/app_flavor.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported.');

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        if (AppFlavor.isDev) return androidDev;
        if (AppFlavor.isUat) {
          throw UnsupportedError(
            'Android UAT is not configured in Firebase yet. Add com.feloosy.app.uat to Firebase and regenerate google-services.json.',
          );
        }
        return android;
      case TargetPlatform.iOS:
        // TODO: add iOS GoogleService-Info.plist and replace this
        throw UnsupportedError(
          'iOS not configured yet - add GoogleService-Info.plist.',
        );
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  // prod (com.feloosy.app)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAqxUDxqX_-nBgZ168DkgsyAd7nL3GLSU',
    appId: '1:623272973124:android:ba7ec69e4cb336976cfd11',
    messagingSenderId: '623272973124',
    projectId: 'feloosy-e13c3',
    storageBucket: 'feloosy-e13c3.firebasestorage.app',
    androidClientId:
        '623272973124-9kh82qst3lsqn2l5a10m7tvpr8flhhs7.apps.googleusercontent.com',
  );

  // dev (com.feloosy.app.dev)
  static const FirebaseOptions androidDev = FirebaseOptions(
    apiKey: 'AIzaSyAAqxUDxqX_-nBgZ168DkgsyAd7nL3GLSU',
    appId: '1:623272973124:android:c1d522c8f8d03e3b6cfd11',
    messagingSenderId: '623272973124',
    projectId: 'feloosy-e13c3',
    storageBucket: 'feloosy-e13c3.firebasestorage.app',
    androidClientId:
        '623272973124-m3mbj3415aq34jhrggn312dee3ortvlp.apps.googleusercontent.com',
  );
}
