import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Secure logger that automatically redacts sensitive information
///
/// This logger prevents sensitive data like passwords, tokens, and user IDs
/// from appearing in console output or log files.
class SecureLogger {
  // List of fields that should be redacted
  static const List<String> _sensitiveFields = [
    'password',
    'pass',
    'pwd',
    'user_id',
    'userId',
    'username',
    'email',
    'token',
    'session_id',
    'sessionId',
    'auth_token',
    'authToken',
    'access_token',
    'accessToken',
    'refresh_token',
    'refreshToken',
    'api_key',
    'apiKey',
    'secret',
    'cookie',
    'authorization',
    'Authorization',
  ];

  /// Log a debug message (only in debug mode)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('🔍 [DEBUG] $message');
    }
  }

  /// Log an info message (only in debug mode)
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ [INFO] $message');
    }
  }

  /// Log a warning message (only in debug mode)
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ [WARNING] $message');
    }
  }

  /// Log an error message (always logged in debug, never in production)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack: $stackTrace');
      }
    }
  }

  /// Log a request with sanitized data
  static void logRequest(
    String method,
    String url,
    Map<String, dynamic>? headers,
    dynamic body,
  ) {
    if (kDebugMode) {
      debugPrint('📤 [REQUEST] $method $url');
      if (headers != null) {
        final sanitizedHeaders = _sanitizeMap(headers);
        debugPrint('Headers: $sanitizedHeaders');
      }
      if (body != null) {
        final sanitizedBody = _sanitizeData(body);
        debugPrint('Body: $sanitizedBody');
      }
    }
  }

  /// Log a response with sanitized data
  static void logResponse(
    int statusCode,
    Map<String, String>? headers,
    String? body,
  ) {
    if (kDebugMode) {
      debugPrint('📥 [RESPONSE] Status: $statusCode');
      if (headers != null && headers.isNotEmpty) {
        final sanitizedHeaders = _sanitizeHeaders(headers);
        debugPrint('Headers: $sanitizedHeaders');
      }
      if (body != null && body.isNotEmpty) {
        final sanitizedBody = _sanitizeBody(body);
        if (sanitizedBody.length > 500) {
          debugPrint('Body: ${sanitizedBody.substring(0, 500)}... (truncated)');
        } else {
          debugPrint('Body: $sanitizedBody');
        }
      }
    }
  }

  /// Sanitize a Map by redacting sensitive fields
  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      if (_isSensitiveField(key)) {
        sanitized[entry.key] = '***REDACTED***';
      } else if (entry.value is Map) {
        sanitized[entry.key] = _sanitizeMap(
          entry.value as Map<String, dynamic>,
        );
      } else if (entry.value is List) {
        sanitized[entry.key] = _sanitizeList(entry.value as List);
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  /// Sanitize list items
  static List<dynamic> _sanitizeList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _sanitizeMap(item as Map<String, dynamic>);
      }
      return item;
    }).toList();
  }

  /// Sanitize body string (JSON or form data)
  static String _sanitizeBody(String body) {
    try {
      // Try to parse as JSON
      final dynamic data = json.decode(body);
      if (data is Map) {
        final sanitized = _sanitizeMap(data as Map<String, dynamic>);
        return json.encode(sanitized);
      } else if (data is List) {
        final sanitized = _sanitizeList(data);
        return json.encode(sanitized);
      }
      return body;
    } catch (e) {
      // If not JSON, try to sanitize as form data
      return _sanitizeFormData(body);
    }
  }

  /// Sanitize form data string
  static String _sanitizeFormData(String formData) {
    final parts = formData.split('&');
    final sanitizedParts = parts.map((part) {
      if (part.contains('=')) {
        final keyValue = part.split('=');
        if (keyValue.length == 2) {
          final key = Uri.decodeComponent(keyValue[0]);
          if (_isSensitiveField(key.toLowerCase())) {
            return '${keyValue[0]}=***REDACTED***';
          }
        }
      }
      return part;
    });
    return sanitizedParts.join('&');
  }

  /// Sanitize headers
  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = <String, String>{};
    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();
      if (_isSensitiveField(key)) {
        sanitized[entry.key] = '***REDACTED***';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  /// Check if a field name is sensitive
  static bool _isSensitiveField(String key) {
    final lowerKey = key.toLowerCase();
    for (final sensitiveField in _sensitiveFields) {
      if (lowerKey.contains(sensitiveField.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  /// Sanitize any dynamic data
  static dynamic _sanitizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _sanitizeMap(data);
    } else if (data is List) {
      return _sanitizeList(data);
    } else if (data is String) {
      return _sanitizeFormData(data);
    }
    return data;
  }

  /// Log success message
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ [SUCCESS] $message');
    }
  }
}
