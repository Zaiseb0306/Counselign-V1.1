import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../api/config.dart';
import 'session.dart';
import 'secure_storage.dart';
import 'secure_logger.dart';

/// Service to validate session with backend API
/// Used for mobile platforms to check if user session is still valid
class SessionValidator {
  static final Session _session = Session();

  /// Check if session is valid by calling backend session check endpoint
  /// Returns Map with 'valid' (bool) and 'role' (String?) keys
  static Future<Map<String, dynamic>> validateSession() async {
    // Only validate on mobile platforms
    if (kIsWeb) {
      return {'valid': false, 'role': null};
    }

    try {
      // Ensure session is initialized and cookies are restored
      await _session.initialize();

      // Get user role from secure storage
      final role = await SecureStorage.getUserRole();
      if (role == null || role.isEmpty) {
        SecureLogger.debug('No user role found in secure storage');
        return {'valid': false, 'role': null};
      }

      // Check if we have cookies
      if (!_session.hasSession) {
        SecureLogger.debug('No session cookies found');
        return {'valid': false, 'role': null};
      }

      // Determine session check endpoint based on role
      String sessionCheckEndpoint;
      switch (role.toLowerCase()) {
        case 'student':
          sessionCheckEndpoint =
              '${ApiConfig.currentBaseUrl}/student/session/check';
          break;
        case 'counselor':
          sessionCheckEndpoint =
              '${ApiConfig.currentBaseUrl}/counselor/session/check';
          break;
        case 'admin':
          sessionCheckEndpoint =
              '${ApiConfig.currentBaseUrl}/admin/session/check';
          break;
        default:
          SecureLogger.debug('Unknown role: $role');
          return {'valid': false, 'role': null};
      }

      // Make request to session check endpoint
      final response = await _session.get(
        sessionCheckEndpoint,
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final loggedIn = data['loggedin'] as bool? ?? false;
        final responseRole = data['role'] as String?;

        if (loggedIn &&
            responseRole != null &&
            responseRole.toLowerCase() == role.toLowerCase()) {
          SecureLogger.debug('Session is valid for role: $role');
          return {'valid': true, 'role': role};
        } else {
          SecureLogger.debug(
            'Session check returned invalid: loggedIn=$loggedIn, role=$responseRole',
          );
          return {'valid': false, 'role': null};
        }
      } else {
        SecureLogger.debug(
          'Session check failed with status: ${response.statusCode}',
        );
        return {'valid': false, 'role': null};
      }
    } catch (e) {
      SecureLogger.error('Failed to validate session', e);
      return {'valid': false, 'role': null};
    }
  }

  /// Check if current platform is mobile (Android or iOS)
  static bool get isMobile {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }
}
