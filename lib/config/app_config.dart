class AppConfig {
  // Rasa Server Configuration
  static const String rasaServerUrl = 'http://192.168.31.28:5005/model/parse';

  // Network timeout settings
  static const Duration networkTimeout = Duration(seconds: 10);

  // Database settings
  static const String databaseName = 'tasks.db';

  // App settings
  static const String appName = 'Voice Reminder';
  static const String timeZone = 'Asia/Dhaka';
  static const String locale = 'en_US';
}
