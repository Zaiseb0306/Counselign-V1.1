import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'secure_logger.dart';

/// Secure storage wrapper for sensitive data
///
/// Provides encrypted storage for session tokens, user credentials,
/// and other sensitive information using platform-specific secure storage.
class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _sessionTokenKey = 'session_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastLoginKey = 'last_login';

  /// Store session token securely
  static Future<void> storeSessionToken(String token) async {
    try {
      await _storage.write(key: _sessionTokenKey, value: token);
      SecureLogger.debug('Session token stored securely');
    } catch (e) {
      SecureLogger.error('Failed to store session token', e);
      rethrow;
    }
  }

  /// Retrieve session token
  static Future<String?> getSessionToken() async {
    try {
      final token = await _storage.read(key: _sessionTokenKey);
      if (token != null) {
        SecureLogger.debug('Session token retrieved');
      }
      return token;
    } catch (e) {
      SecureLogger.error('Failed to retrieve session token', e);
      return null;
    }
  }

  /// Store user ID securely
  static Future<void> storeUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      SecureLogger.debug('User ID stored securely');
    } catch (e) {
      SecureLogger.error('Failed to store user ID', e);
      rethrow;
    }
  }

  /// Retrieve user ID
  static Future<String?> getUserId() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      if (userId != null) {
        SecureLogger.debug('User ID retrieved');
      }
      return userId;
    } catch (e) {
      SecureLogger.error('Failed to retrieve user ID', e);
      return null;
    }
  }

  /// Store user role securely
  static Future<void> storeUserRole(String role) async {
    try {
      await _storage.write(key: _userRoleKey, value: role);
      SecureLogger.debug('User role stored securely');
    } catch (e) {
      SecureLogger.error('Failed to store user role', e);
      rethrow;
    }
  }

  /// Retrieve user role
  static Future<String?> getUserRole() async {
    try {
      final role = await _storage.read(key: _userRoleKey);
      if (role != null) {
        SecureLogger.debug('User role retrieved');
      }
      return role;
    } catch (e) {
      SecureLogger.error('Failed to retrieve user role', e);
      return null;
    }
  }

  /// Store remember me preference
  static Future<void> storeRememberMe(bool remember) async {
    try {
      await _storage.write(key: _rememberMeKey, value: remember.toString());
      SecureLogger.debug('Remember me preference stored');
    } catch (e) {
      SecureLogger.error('Failed to store remember me preference', e);
      rethrow;
    }
  }

  /// Retrieve remember me preference
  static Future<bool> getRememberMe() async {
    try {
      final remember = await _storage.read(key: _rememberMeKey);
      final result = remember == 'true';
      SecureLogger.debug('Remember me preference retrieved: $result');
      return result;
    } catch (e) {
      SecureLogger.error('Failed to retrieve remember me preference', e);
      return false;
    }
  }

  /// Store last login timestamp
  static Future<void> storeLastLogin(DateTime timestamp) async {
    try {
      await _storage.write(
        key: _lastLoginKey,
        value: timestamp.toIso8601String(),
      );
      SecureLogger.debug('Last login timestamp stored');
    } catch (e) {
      SecureLogger.error('Failed to store last login timestamp', e);
      rethrow;
    }
  }

  /// Retrieve last login timestamp
  static Future<DateTime?> getLastLogin() async {
    try {
      final timestamp = await _storage.read(key: _lastLoginKey);
      if (timestamp != null) {
        final result = DateTime.parse(timestamp);
        SecureLogger.debug('Last login timestamp retrieved');
        return result;
      }
      return null;
    } catch (e) {
      SecureLogger.error('Failed to retrieve last login timestamp', e);
      return null;
    }
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      SecureLogger.debug('All secure storage cleared');
    } catch (e) {
      SecureLogger.error('Failed to clear secure storage', e);
      rethrow;
    }
  }

  /// Clear session data only
  static Future<void> clearSession() async {
    try {
      await _storage.delete(key: _sessionTokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userRoleKey);
      SecureLogger.debug('Session data cleared');
    } catch (e) {
      SecureLogger.error('Failed to clear session data', e);
      rethrow;
    }
  }

  /// Check if user has valid session
  static Future<bool> hasValidSession() async {
    try {
      final token = await getSessionToken();
      final userId = await getUserId();
      final role = await getUserRole();

      final hasSession = token != null && userId != null && role != null;
      SecureLogger.debug('Session validity check: $hasSession');
      return hasSession;
    } catch (e) {
      SecureLogger.error('Failed to check session validity', e);
      return false;
    }
  }

  /// Store generic key-value pair securely
  static Future<void> storeSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      SecureLogger.debug('Secure data stored for key: $key');
    } catch (e) {
      SecureLogger.error('Failed to store secure data for key: $key', e);
      rethrow;
    }
  }

  /// Retrieve generic key-value pair
  static Future<String?> getSecure(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) {
        SecureLogger.debug('Secure data retrieved for key: $key');
      }
      return value;
    } catch (e) {
      SecureLogger.error('Failed to retrieve secure data for key: $key', e);
      return null;
    }
  }

  /// Delete specific key
  static Future<void> deleteSecure(String key) async {
    try {
      await _storage.delete(key: key);
      SecureLogger.debug('Secure data deleted for key: $key');
    } catch (e) {
      SecureLogger.error('Failed to delete secure data for key: $key', e);
      rethrow;
    }
  }
}
