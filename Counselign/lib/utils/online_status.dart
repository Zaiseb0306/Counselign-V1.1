import 'package:flutter/material.dart';

/// Utility class for calculating online status based on last activity, login, and logout times
/// Matches the JavaScript implementation from counselor_messages.js and counselor_dashboard.js
class OnlineStatus {
  /// Status types
  static const String online = 'online';
  static const String active = 'active';
  static const String offline = 'offline';

  /// Status classes for styling
  static const String statusOnline = 'status-online';
  static const String statusActiveRecent = 'status-active-recent';
  static const String statusOffline = 'status-offline';

  /// Calculate online status based on last_activity, last_login, and logout_time
  ///
  /// Rules:
  /// 1. If logout_time equals last_activity (exact match), status is offline
  /// 2. Find the most recent time between last_activity and last_login
  /// 3. Less than 5 minutes = online (green)
  /// 4. 5-60 minutes = Last active Xm ago (yellow)
  /// 5. More than 1 hour = offline (gray)
  static OnlineStatusResult calculateOnlineStatus(
    String? lastActivity,
    String? lastLogin,
    String? logoutTime,
  ) {
    // Parse dates
    final activityTime = _parseDateTime(lastActivity);
    final loginTime = _parseDateTime(lastLogin);
    final logoutTimeDate = _parseDateTime(logoutTime);

    // Check if logout_time equals last_activity (exact match)
    if (logoutTimeDate != null &&
        activityTime != null &&
        logoutTimeDate.millisecondsSinceEpoch ==
            activityTime.millisecondsSinceEpoch) {
      return OnlineStatusResult(
        status: offline,
        text: 'Offline',
        statusClass: statusOffline,
      );
    }

    // Find the most recent time between last_activity and last_login
    DateTime? mostRecentTime;

    if (activityTime != null && loginTime != null) {
      // Use the more recent of the two
      mostRecentTime = activityTime.isAfter(loginTime)
          ? activityTime
          : loginTime;
    } else if (activityTime != null) {
      mostRecentTime = activityTime;
    } else if (loginTime != null) {
      mostRecentTime = loginTime;
    }

    if (mostRecentTime == null) {
      return OnlineStatusResult(
        status: offline,
        text: 'Offline',
        statusClass: statusOffline,
      );
    }

    final now = DateTime.now();
    final diffInMinutes = now.difference(mostRecentTime).inMinutes;

    if (diffInMinutes <= 5) {
      return OnlineStatusResult(
        status: online,
        text: 'Online',
        statusClass: statusOnline,
      );
    } else if (diffInMinutes <= 60) {
      return OnlineStatusResult(
        status: active,
        text: 'Last active ${diffInMinutes}m ago',
        statusClass: statusActiveRecent,
      );
    } else {
      return OnlineStatusResult(
        status: offline,
        text: 'Offline',
        statusClass: statusOffline,
      );
    }
  }

  /// Parse a date string to DateTime, handling various formats
  static DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      // Handle ISO format with T separator
      if (dateString.contains('T')) {
        return DateTime.parse(dateString);
      }

      // Handle space-separated format by replacing space with T
      final normalized = dateString.replaceFirst(' ', 'T');
      return DateTime.parse(normalized);
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
  }
}

/// Result class for online status calculation
class OnlineStatusResult {
  final String status;
  final String text;
  final String statusClass;

  const OnlineStatusResult({
    required this.status,
    required this.text,
    required this.statusClass,
  });

  /// Get the appropriate color for the status
  Color get statusColor {
    switch (statusClass) {
      case OnlineStatus.statusOnline:
        return Colors.green;
      case OnlineStatus.statusActiveRecent:
        return Colors.orange;
      case OnlineStatus.statusOffline:
      default:
        return Colors.grey;
    }
  }

  /// Get the appropriate icon for the status
  IconData get statusIcon {
    switch (statusClass) {
      case OnlineStatus.statusOnline:
        return Icons.circle;
      case OnlineStatus.statusActiveRecent:
        return Icons.access_time;
      case OnlineStatus.statusOffline:
      default:
        return Icons.circle_outlined;
    }
  }
}
