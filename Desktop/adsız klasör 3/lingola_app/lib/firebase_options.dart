// Bu dosya `flutterfire configure` çalıştırıldığında otomatik güncellenir.
// Firebase Console'dan projeyi ekleyip terminalde: flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCrzFct8NyoI39dVhoB-WtqvfyRxSHBNzU',
    appId: '1:524778134584:android:236deccfc32a380f351acd',
    messagingSenderId: '524778134584',
    projectId: 'lingola-job',
    storageBucket: 'lingola-job.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA6QnS3UFxJkPQqF9XAVaU6wTsq8f7lMsA',
    appId: '1:524778134584:ios:24484295b1473fbb351acd',
    messagingSenderId: '524778134584',
    projectId: 'lingola-job',
    storageBucket: 'lingola-job.firebasestorage.app',
    iosBundleId: 'com.flywork.lingolajobapp',
  );
}
