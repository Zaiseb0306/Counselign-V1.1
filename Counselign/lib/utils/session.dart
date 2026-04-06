import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'secure_logger.dart';
import 'secure_storage.dart';

class Session {
  static final Session _instance = Session._internal();
  factory Session() => _instance;
  Session._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      colors: true,
      dateTimeFormat: DateTimeFormat.none, // ✅ replaces printTime: false
    ),
  );

  Map<String, String> cookies = {};
  bool _initialized = false;

  /// Initialize session by restoring cookies from secure storage
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await _restoreCookies();
    _initialized = true;
  }

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    // Ensure session is initialized
    await initialize();

    final client = http.Client();

    try {
      final requestHeaders = headers ?? {};

      // Add cookies to the request if we have any
      if (cookies.isNotEmpty) {
        final cookieString = cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
        requestHeaders['Cookie'] = cookieString;
        SecureLogger.debug('Sending session cookies');
      }

      SecureLogger.debug('Making GET request to: $url');
      final response = await client.get(
        Uri.parse(url),
        headers: requestHeaders,
      );

      _logResponse(response);

      // Extract and store cookies from the response
      _updateCookies(response);

      return response;
    } finally {
      client.close();
    }
  }

  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? fields,
    Map<String, List<int>>? files,
  }) async {
    // Ensure session is initialized
    await initialize();

    final client = http.Client();

    try {
      final requestHeaders = headers ?? {};

      // Add cookies to the request if we have any
      if (cookies.isNotEmpty) {
        final cookieString = cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
        requestHeaders['Cookie'] = cookieString;
        SecureLogger.debug('Sending session cookies');
      }

      SecureLogger.debug('Making POST request to: $url');

      // If files are provided OR fields are provided, use multipart request
      // This ensures form-data format expected by backend PHP
      if ((files != null && files.isNotEmpty) ||
          (fields != null && fields.isNotEmpty)) {
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll(requestHeaders);

        // Add fields
        if (fields != null) {
          request.fields.addAll(fields);
        }

        // Add files if present
        if (files != null) {
          files.forEach((fieldName, fileBytes) {
            request.files.add(
              http.MultipartFile.fromBytes(
                fieldName,
                fileBytes,
                filename: 'file_$fieldName',
              ),
            );
          });
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        _logResponse(response);
        _updateCookies(response);

        return response;
      } else {
        // Regular POST request
        final response = await client.post(
          Uri.parse(url),
          headers: requestHeaders,
          body: body,
        );

        _logResponse(response);
        _updateCookies(response);

        return response;
      }
    } finally {
      client.close();
    }
  }

  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? fields,
  }) async {
    // Ensure session is initialized
    await initialize();

    final client = http.Client();

    try {
      final requestHeaders = headers ?? {};

      // Add cookies to the request if we have any
      if (cookies.isNotEmpty) {
        final cookieString = cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
        requestHeaders['Cookie'] = cookieString;
        SecureLogger.debug('Sending session cookies');
      }

      SecureLogger.debug('Making PUT request to: $url');

      // For PUT requests with form data, use URLSearchParams format
      if (fields != null && fields.isNotEmpty) {
        final body = fields.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&');
        requestHeaders['Content-Type'] = 'application/x-www-form-urlencoded';

        final response = await client.put(
          Uri.parse(url),
          headers: requestHeaders,
          body: body,
        );

        _logResponse(response);
        _updateCookies(response);

        return response;
      } else {
        final response = await client.put(
          Uri.parse(url),
          headers: requestHeaders,
        );

        _logResponse(response);
        _updateCookies(response);

        return response;
      }
    } finally {
      client.close();
    }
  }

  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    // Ensure session is initialized
    await initialize();

    final client = http.Client();

    try {
      final requestHeaders = headers ?? {};

      // Add cookies to the request if we have any
      if (cookies.isNotEmpty) {
        final cookieString = cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
        requestHeaders['Cookie'] = cookieString;
        SecureLogger.debug('Sending session cookies');
      }

      SecureLogger.debug('Making DELETE request to: $url');

      final response = await client.delete(
        Uri.parse(url),
        headers: requestHeaders,
      );

      _logResponse(response);
      _updateCookies(response);

      return response;
    } finally {
      client.close();
    }
  }

  void _updateCookies(http.Response response) {
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      SecureLogger.debug('Received Set-Cookie header');

      // Parse the Set-Cookie header (handle multiple cookies)
      final cookiesList = setCookieHeader.split(',');

      for (var cookie in cookiesList) {
        // Take the first part before semicolon (the actual cookie)
        final cookiePart = cookie.split(';').first.trim();
        final parts = cookiePart.split('=');

        if (parts.length >= 2) {
          final cookieName = parts[0].trim();
          final cookieValue = parts.sublist(1).join('=').trim();
          cookies[cookieName] = cookieValue;
          SecureLogger.debug('Stored session cookie: $cookieName');

          // Store session token in secure storage if it's a session cookie
          if (cookieName.toLowerCase().contains('session') ||
              cookieName.toLowerCase().contains('token')) {
            SecureStorage.storeSessionToken(cookieValue);
          }
        }
      }

      // Persist all cookies to secure storage for mobile persistence
      _persistCookies();
    }

    SecureLogger.debug('Total cookies stored: ${cookies.length}');
  }

  /// Persist all cookies to secure storage
  Future<void> _persistCookies() async {
    try {
      if (cookies.isNotEmpty) {
        final cookiesJson = jsonEncode(cookies);
        await SecureStorage.storeSecure('session_cookies', cookiesJson);
        SecureLogger.debug(
          'Persisted ${cookies.length} cookies to secure storage',
        );
      }
    } catch (e) {
      SecureLogger.error('Failed to persist cookies', e);
    }
  }

  /// Restore cookies from secure storage
  Future<void> _restoreCookies() async {
    try {
      final cookiesJson = await SecureStorage.getSecure('session_cookies');
      if (cookiesJson != null && cookiesJson.isNotEmpty) {
        final restoredCookies = jsonDecode(cookiesJson) as Map<String, dynamic>;
        cookies = restoredCookies.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        SecureLogger.debug(
          'Restored ${cookies.length} cookies from secure storage',
        );
      }
    } catch (e) {
      SecureLogger.error('Failed to restore cookies', e);
      cookies.clear();
    }
  }

  void clearCookies() {
    cookies.clear();
    SecureStorage.clearSession();
    SecureStorage.deleteSecure('session_cookies');
    SecureLogger.debug('Cleared all session cookies and secure storage');
  }

  // Helper method to check if we have a session
  bool get hasSession => cookies.isNotEmpty;

  void _logResponse(http.Response response) {
    try {
      _logger.i('🌐 Response status: ${response.statusCode}');
      _logger.d('🌐 Response headers: ${response.headers}');
      if (response.statusCode != 200) {
        _logger.w('🌐 Response body (non-200): ${response.body}');
      }
    } catch (e) {
      _logger.e('🌐 Failed to log response details: $e');
    }
  }
}
