import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Firebase Config
  static String get firebaseApiKeyAndroid =>
      dotenv.env['FIREBASE_API_KEY_ANDROID'] ?? '';
  static String get firebaseAppIdAndroid =>
      dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? '';
  static String get firebaseApiKeyIOS =>
      dotenv.env['FIREBASE_API_KEY_IOS'] ?? '';
  static String get firebaseAppIdIOS => dotenv.env['FIREBASE_APP_ID_IOS'] ?? '';
  static String get messagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get projectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get storageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  // FCM Server Key
  static String get fcmServerKey => dotenv.env['FCM_SERVER_KEY'] ?? '';

  // App Constants
  static const String appName = 'Connect';
  static const String appVersion = '2.0.0';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration messageTimeout = Duration(seconds: 10);
}
