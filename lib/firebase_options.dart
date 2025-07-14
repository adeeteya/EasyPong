import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'placeholder',
        appId: 'placeholder',
        messagingSenderId: 'placeholder',
        projectId: 'easy-pong',
        databaseURL: 'https://example.firebaseio.com',
      );
}
