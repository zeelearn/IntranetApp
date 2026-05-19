import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      print('web detected...');
      return web;
    }
    print('defaultTargetPlatform $defaultTargetPlatform');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        print('Android detected $android');
        return android;
      case TargetPlatform.iOS:
        print('IOS detected $ios');
        return ios;
      case TargetPlatform.macOS:
        print('macos detected $macos');
        return macos;
      case TargetPlatform.windows:
        print('window detected');
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        print('linus detected');
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        print('default detected');
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
    appId: '1:448618578101:web:a8ebc6ab724e6baaac3efc',
    messagingSenderId: '448618578101',
    projectId: 'react-native-firebase-testing',
    authDomain: 'react-native-firebase-testing.firebaseapp.com',
    databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
    storageBucket: 'react-native-firebase-testing.appspot.com',
    measurementId: 'G-RF9GF9MQ1F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGUg3e_G7TzpwXWcX3KOyxCmYyCXiroDE',
    appId: '1:411998223312:android:176ef77cd8fca5e4dd97d5',
    messagingSenderId: '411998223312',
    projectId: 'intranet-9fda2',
    databaseURL: 'https://intranet-9fda2-default-rtdb.firebaseio.com',
    storageBucket: 'intranet-9fda2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
    appId: '1:411998223312:ios:0dabf3a3a966fb4cdd97d5',
    messagingSenderId: '411998223312',
    projectId: 'intranet-9fda2',
    databaseURL: 'https://intranet-9fda2-default-rtdb.firebaseio.com',
    storageBucket: 'intranet-9fda2.appspot.com',
    androidClientId:
    '448618578101-a9p7bj5jlakabp22fo3cbkj7nsmag24e.apps.googleusercontent.com',
    iosClientId:
    '448618578101-evbjdqq9co9v29pi8jcua8bm7kr4smuu.apps.googleusercontent.com',
    iosBundleId: 'com.zeelearn.intranet',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
    appId: '1:448618578101:ios:0b11ed8263232715ac3efc',
    messagingSenderId: '448618578101',
    projectId: 'react-native-firebase-testing',
    databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
    storageBucket: 'react-native-firebase-testing.appspot.com',
    androidClientId:
    '448618578101-a9p7bj5jlakabp22fo3cbkj7nsmag24e.apps.googleusercontent.com',
    iosClientId:
    '448618578101-evbjdqq9co9v29pi8jcua8bm7kr4smuu.apps.googleusercontent.com',
    iosBundleId: 'com.zeelearn.intranet',
  );
}
