import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Optional build-time override (e.g., --dart-define=API_BASE_URL=https://api.example.com)
  static const String envBaseUrl = String.fromEnvironment('API_BASE_URL');
  // Localhost (desktop browser / web debug)
  static const String localhostUrl = 'http://10.47.115.105/Counselign/public';

  // XAMPP loopback for desktop (if using 127.0.0.1)
  static const String xamppUrl = 'http://10.47.115.105/Counselign/public';

  // Android emulator
  static const String emulatorUrl = 'http://10.0.2.2/Counselign/public';

  // Real device (replace with your PC's local IP)
  static const String deviceUrl = 'http://10.47.115.105/Counselign/public';

  // Production/live server (replace with your public HTTPS endpoint)
  static const String productionUrl =
      'https://your-domain.example.com/Counselign/public';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Default headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // Auto-detect environment
  static String get currentBaseUrl {
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }
    if (kIsWeb) {
      // Running on web (use localhost)
      return localhostUrl;
    } else if (Platform.isAndroid) {
      // Running on Android
      // Use deviceUrl for physical device testing
      // Use emulatorUrl only when running on Android emulator
      return deviceUrl; // Use deviceUrl for physical device
    } else if (Platform.isIOS) {
      // Use device URL for iOS testing on physical device
      return deviceUrl;
    } else {
      // Desktop (Windows/macOS/Linux)
      return localhostUrl;
    }
  }
}
