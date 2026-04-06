import '../../utils/online_status.dart';

class Counselor {
  final String counselorId;
  final String name;
  final String specialization;
  final String? profilePicture;
  final String? email;
  final bool isAvailable;
  final String? lastActivity;
  final String? lastLogin;
  final String? logoutTime;

  Counselor({
    required this.counselorId,
    required this.name,
    required this.specialization,
    this.profilePicture,
    this.email,
    this.isAvailable = true,
    this.lastActivity,
    this.lastLogin,
    this.logoutTime,
  });

  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      counselorId: json['counselor_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['counselor_name'] ?? '',
      specialization:
          json['specialization'] ?? json['expertise'] ?? 'General Counseling',
      profilePicture: json['profile_picture'] ?? json['profile_image'],
      email: json['email'],
      isAvailable: json['is_available'] ?? true,
      lastActivity: json['last_activity']?.toString(),
      lastLogin: json['last_login']?.toString(),
      logoutTime: json['logout_time']?.toString(),
    );
  }

  String get displayName => name; // Remove specialization from display name

  /// Get the calculated online status for this counselor
  OnlineStatusResult get onlineStatus {
    return OnlineStatus.calculateOnlineStatus(
      lastActivity,
      lastLogin,
      logoutTime,
    );
  }

  String get profileImageUrl {
    if (profilePicture == null || profilePicture!.isEmpty) {
      return 'Photos/profile.png';
    }

    // If it's already a full URL, return as is
    if (profilePicture!.startsWith('http')) {
      return profilePicture!;
    }

    // If it starts with Photos/, return as is
    if (profilePicture!.startsWith('Photos/')) {
      return profilePicture!;
    }

    // Otherwise, prepend Photos/ if not already there
    return profilePicture!.startsWith('/')
        ? profilePicture!.substring(1)
        : profilePicture!;
  }
}
