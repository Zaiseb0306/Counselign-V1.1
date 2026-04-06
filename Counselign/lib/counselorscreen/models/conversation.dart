import '../../api/config.dart';
import '../../utils/online_status.dart';

class Conversation {
  final String userId;
  final String userName;
  final String? profilePicture;
  final String lastMessage;
  final String lastMessageTime;
  final String lastMessageType; // 'sent' or 'received'
  final int unreadCount;
  final String? statusText;
  final String? lastActivity;
  final String? lastLogin;
  final String? logoutTime;

  Conversation({
    required this.userId,
    required this.userName,
    this.profilePicture,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageType,
    required this.unreadCount,
    this.statusText,
    this.lastActivity,
    this.lastLogin,
    this.logoutTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId:
          json['other_user_id']?.toString() ??
          json['user_id']?.toString() ??
          '',
      userName:
          json['other_username']?.toString() ??
          json['name']?.toString() ??
          'Unknown',
      profilePicture: _buildImageUrl(json['other_profile_picture']),
      lastMessage: json['last_message']?.toString() ?? 'No messages yet',
      lastMessageTime: json['last_message_time']?.toString() ?? '',
      lastMessageType: json['last_message_type']?.toString() ?? 'received',
      unreadCount: _parseInt(json['unread_count']) ?? 0,
      statusText: json['status_text']?.toString(),
      lastActivity: json['last_activity']?.toString(),
      lastLogin: json['last_login']?.toString(),
      logoutTime: json['logout_time']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _buildImageUrl(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return 'Photos/profile.png';
    }
    if (profilePicture.startsWith('http')) {
      return profilePicture;
    }
    String baseUrl = ApiConfig.currentBaseUrl;
    if (baseUrl.endsWith('/index.php')) {
      baseUrl = baseUrl.replaceAll('/index.php', '');
    }
    return '$baseUrl/$profilePicture';
  }

  bool get hasUnreadMessages => unreadCount > 0;

  String get formattedLastMessage {
    if (lastMessageType == 'sent') {
      return 'You: $lastMessage';
    } else if (lastMessageType == 'received') {
      return 'Sent a Message: $lastMessage';
    }
    return lastMessage;
  }

  String get truncatedLastMessage {
    const maxLength = 20;
    if (formattedLastMessage.length > maxLength) {
      return '${formattedLastMessage.substring(0, maxLength - 3)}...';
    }
    return formattedLastMessage;
  }

  /// Get the calculated online status for this conversation
  OnlineStatusResult get onlineStatus {
    return OnlineStatus.calculateOnlineStatus(
      lastActivity,
      lastLogin,
      logoutTime,
    );
  }

  String get formattedLastMessageTime {
    if (lastMessageTime.isEmpty) {
      return '';
    }
    final String normalized = lastMessageTime.contains('T')
        ? lastMessageTime
        : lastMessageTime.replaceFirst(' ', 'T');
    final DateTime? parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      return lastMessageTime;
    }
    final DateTime localDateTime = parsed.toLocal();
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(localDateTime);
    final String time12Hour = _formatTime12Hour(localDateTime);

    // If today
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return time12Hour;
    }

    // If yesterday
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == yesterday.month &&
        localDateTime.year == yesterday.year) {
      return 'Yesterday at $time12Hour';
    }

    // If 1 day ago (more than yesterday but less than 2 days ago)
    if (diff.inDays >= 1 && diff.inDays < 2) {
      return '1 day ago at $time12Hour';
    }

    // If within the week (2-7 days ago)
    if (diff.inDays >= 2 && diff.inDays <= 7) {
      return '${diff.inDays} days ago at $time12Hour';
    }

    // If more than a week, show full date with time
    return '${_getMonthName(localDateTime.month)} ${localDateTime.day}, ${localDateTime.year} at $time12Hour';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatTime12Hour(DateTime dateTime) {
    final int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
