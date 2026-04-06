import 'package:flutter/foundation.dart';

class CounselorAvailability {
  final String counselorId;
  final String name;
  final String specialization;
  final String? profilePicture;
  final String? email;
  final bool isAvailable;
  final String? timeSchedule;

  CounselorAvailability({
    required this.counselorId,
    required this.name,
    required this.specialization,
    this.profilePicture,
    this.email,
    this.isAvailable = true,
    this.timeSchedule,
  });

  factory CounselorAvailability.fromJson(Map<String, dynamic> json) {
    // Debug: Print all available keys in the JSON
    debugPrint('CounselorAvailability JSON keys: ${json.keys.toList()}');
    debugPrint('CounselorAvailability JSON data: $json');

    return CounselorAvailability(
      counselorId: json['counselor_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['counselor_name'] ?? '',
      specialization:
          json['specialization'] ?? json['expertise'] ?? 'General Counseling',
      profilePicture: json['profile_picture'] ?? json['profile_image'],
      email: json['email'],
      isAvailable: json['is_available'] ?? true,
      timeSchedule:
          json['time_scheduled'] ??
          json['time_schedule'] ??
          json['schedule'] ??
          json['time'] ??
          json['available_time'],
    );
  }

  String get displayName => name; // Remove specialization from display name

  // Get formatted time schedule - time is already in 12-hour format with meridian labels
  String? get formattedTimeSchedule {
    if (timeSchedule == null || timeSchedule!.isEmpty) return null;

    // Time is already in 12-hour format with AM/PM, return as is
    return timeSchedule;
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
