/// Utility class for handling user display name logic
/// Matches the PHP UserDisplayHelper implementation
class UserDisplayHelper {
  /// Get user display information based on available name data
  ///
  /// Returns a map containing:
  /// - display_name: The name to display (full name or user_id)
  /// - has_name: Whether the user has a proper name (not just user_id)
  /// - user_id_display: The user_id for internal use
  static Map<String, dynamic> getUserDisplayInfo({
    required String userId,
    String? firstName,
    String? lastName,
    String? fullName,
  }) {
    // Clean the input data
    final cleanFirstName = firstName?.trim();
    final cleanLastName = lastName?.trim();
    final cleanFullName = fullName?.trim();

    // Determine if user has a proper name
    bool hasName = false;
    String displayName = userId; // Default to user_id

    // Check if we have a full name
    if (cleanFullName != null && cleanFullName.isNotEmpty) {
      hasName = true;
      displayName = cleanFullName;
    }
    // Check if we have first and last name
    else if (cleanFirstName != null &&
        cleanFirstName.isNotEmpty &&
        cleanLastName != null &&
        cleanLastName.isNotEmpty) {
      hasName = true;
      displayName = '$cleanFirstName $cleanLastName';
    }
    // Check if we have just first name
    else if (cleanFirstName != null && cleanFirstName.isNotEmpty) {
      hasName = true;
      displayName = cleanFirstName;
    }
    // Check if we have just last name
    else if (cleanLastName != null && cleanLastName.isNotEmpty) {
      hasName = true;
      displayName = cleanLastName;
    }

    return {
      'display_name': displayName,
      'has_name': hasName,
      'user_id_display': userId,
    };
  }

  /// Get display name for a user with fallback to user_id
  static String getDisplayName({
    required String userId,
    String? firstName,
    String? lastName,
    String? fullName,
  }) {
    final userInfo = getUserDisplayInfo(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
    );
    return userInfo['display_name'] as String;
  }

  /// Check if user has a proper name (not just user_id)
  static bool hasName({
    required String userId,
    String? firstName,
    String? lastName,
    String? fullName,
  }) {
    final userInfo = getUserDisplayInfo(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
    );
    return userInfo['has_name'] as bool;
  }
}
