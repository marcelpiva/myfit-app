// File generated manually for Firebase configuration
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCM2yyfid5TMS7XqiTIwv1LY9nA6l68Uas',
    appId: '1:392447887985:android:31b26b0bac547edd6aa9d0',
    messagingSenderId: '392447887985',
    projectId: 'myfitplatform-7fa7b',
    storageBucket: 'myfitplatform-7fa7b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQtIy1bZr33MjvVhEb3A4u58feu5rE6fo',
    appId: '1:392447887985:ios:ca4257884cffe0e86aa9d0',
    messagingSenderId: '392447887985',
    projectId: 'myfitplatform-7fa7b',
    storageBucket: 'myfitplatform-7fa7b.firebasestorage.app',
    iosBundleId: 'com.marcelpiva.myfitplatform',
  );
}
