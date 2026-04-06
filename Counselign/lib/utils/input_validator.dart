import 'dart:convert';

/// Input validation and sanitization utilities
///
/// Provides comprehensive validation for user inputs to prevent
/// XSS, SQL injection, and other injection attacks.
class InputValidator {
  /// Validate identifier which can be either a 10-digit user ID or an email
  static String? validateIdentifier(String identifier) {
    if (identifier.isEmpty) {
      return 'User ID or Email is required';
    }

    final trimmed = identifier.trim();
    final sanitized = sanitizeInput(trimmed);
    if (sanitized != trimmed) {
      return 'Invalid characters in User ID or Email';
    }

    // Email match
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (emailRegex.hasMatch(trimmed)) {
      return null;
    }

    // 10-digit numeric user ID
    if (RegExp(r'^\d{10}$').hasMatch(trimmed)) {
      return null;
    }

    return 'Enter a valid 10-digit User ID or a valid email address';
  }

  /// Validate User ID based on role
  static String? validateUserId(String userId, String role) {
    if (userId.isEmpty) {
      return 'User ID is required';
    }

    // Remove any whitespace
    final trimmed = userId.trim();

    // Sanitize to prevent injection attacks
    final sanitized = sanitizeInput(trimmed);
    if (sanitized != trimmed) {
      return 'Invalid characters in User ID';
    }

    // Role-specific validation
    if (role.toLowerCase() == 'student' || role.toLowerCase() == 'counselor') {
      // Must be exactly 10 digits for students/counselors
      if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
        return 'User ID must be exactly 10 digits';
      }
    } else if (role.toLowerCase() == 'admin') {
      // Admin IDs can be alphanumeric, max 10 characters
      if (trimmed.length > 10) {
        return 'User ID cannot exceed 10 characters';
      }
      if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(trimmed)) {
        return 'User ID can only contain letters and numbers';
      }
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_containsUppercase(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!_containsLowercase(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!_containsNumber(password)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate confirm password matches
  static String? validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate email format
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Sanitize email
    final sanitized = sanitizeInput(email);
    if (sanitized != email) {
      return 'Invalid characters in email';
    }

    return null;
  }

  /// Validate username
  static String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username is required';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > 50) {
      return 'Username cannot exceed 50 characters';
    }

    // Only allow alphanumeric and underscore
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  /// Sanitize input to prevent injection attacks
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[<>"]'), '') // Remove < > and "
        .trim();
  }

  /// Validate input is not empty
  static String? validateRequired(String value, String fieldName) {
    if (value.isEmpty || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String value,
    String fieldName,
    int minLength,
  ) {
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String value,
    String fieldName,
    int maxLength,
  ) {
    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  /// Validate numeric input
  static String? validateNumeric(String value) {
    if (value.isEmpty) {
      return 'Please enter a number';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Please enter a valid number';
    }

    return null;
  }

  /// Validate alphanumeric input
  static String? validateAlphanumeric(String value) {
    if (value.isEmpty) {
      return 'Input is required';
    }

    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value)) {
      return 'Input can only contain letters and numbers';
    }

    return null;
  }

  // Helper methods
  static bool _containsUppercase(String input) {
    return RegExp(r'[A-Z]').hasMatch(input);
  }

  static bool _containsLowercase(String input) {
    return RegExp(r'[a-z]').hasMatch(input);
  }

  static bool _containsNumber(String input) {
    return RegExp(r'[0-9]').hasMatch(input);
  }

  /// Escape special characters for database queries (client-side defense)
  /// Note: This is only a client-side defense. Server-side should handle the actual escaping.
  static String escapeSpecialChars(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
  }
}
