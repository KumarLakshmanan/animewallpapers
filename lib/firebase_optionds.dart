import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCPefAqr_ua3r0WqOzTpHCCmgxL_ZIc9AI',
    appId: '1:456999046779:web:87ecb41478462e89698cbc',
    messagingSenderId: '456999046779',
    projectId: 'studywars-53a6e',
    authDomain: 'studywars-53a6e.firebaseapp.com',
    storageBucket: 'studywars-53a6e.appspot.com',
    measurementId: 'G-J8TR8PGJDC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPefAqr_ua3r0WqOzTpHCCmgxL_ZIc9AI',
    appId: '1:456999046779:android:4df200fb8733bb3a771cde',
    messagingSenderId: '456999046779',
    projectId: 'studywars-53a6e',
    storageBucket: 'studywars-53a6e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCPefAqr_ua3r0WqOzTpHCCmgxL_ZIc9AI',
    appId: '1:456999046779:ios:ed5c277cb2556a3e698cbc',
    messagingSenderId: '456999046779',
    projectId: 'studywars-53a6e',
    storageBucket: 'studywars-53a6e.appspot.com',
    androidClientId:
        '456999046779-mcc953ohnaoahrdtt76pr5fqrfuf06nm.apps.googleusercontent.com',
    iosClientId:
        '456999046779-nvd2pnliseno31mispk86c0ucd9t17j3.apps.googleusercontent.com',
    iosBundleId: 'com.timelessfusionapps.smartTalk',
  );
}
