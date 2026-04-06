import 'package:flutter/foundation.dart';

class CounselorSchedule {
  final String counselorId;
  final String counselorName;
  final String degree;
  final String timeSlots;

  CounselorSchedule({
    required this.counselorId,
    required this.counselorName,
    required this.degree,
    required this.timeSlots,
  });

  factory CounselorSchedule.fromJson(Map<String, dynamic> json) {
    debugPrint('CounselorSchedule JSON: $json');

    return CounselorSchedule(
      counselorId: json['counselor_id']?.toString() ?? '',
      counselorName: json['counselor_name'] ?? json['name'] ?? '',
      degree: json['degree'] ?? '',
      timeSlots: json['time_slots'] ?? json['time_scheduled'] ?? '',
    );
  }

  // Get formatted time slots for display
  String get formattedTimeSlots {
    if (timeSlots.isEmpty) return 'All day';

    // Time slots are already in 12-hour format with AM/PM from backend
    return timeSlots;
  }

  // Get display name with degree
  String get displayNameWithDegree {
    if (degree.isNotEmpty) {
      return '$counselorName ($degree)';
    }
    return counselorName;
  }
}
