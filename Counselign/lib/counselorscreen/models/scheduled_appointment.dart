import 'dart:convert';

class CounselorScheduledAppointment {
  final int id;
  final int studentId;
  final String studentName;
  final String studentEmail;
  final String courseYear;
  final String course;
  final String yearLevel;
  final String? appointedDate;
  final String? preferredDate;
  final String? time;
  final String? preferredTime;
  final String consultationType;
  final String? methodType;
  final String purpose;
  final String status;
  final String? counselorPreference;
  final String? reason;
  final String? recordKind;
  final String? followUpStatus;
  final String? appointmentType;
  final int pendingFollowUpCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CounselorScheduledAppointment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.courseYear,
    required this.course,
    required this.yearLevel,
    this.appointedDate,
    this.preferredDate,
    this.time,
    this.preferredTime,
    required this.consultationType,
    this.methodType,
    required this.purpose,
    required this.status,
    this.counselorPreference,
    this.reason,
    this.recordKind,
    this.followUpStatus,
    this.appointmentType,
    required this.pendingFollowUpCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CounselorScheduledAppointment.fromJson(Map<String, dynamic> json) {
    return CounselorScheduledAppointment(
      id: _parseInt(json['id']),
      studentId: _parseInt(json['student_id']),
      studentName: json['student_name'] ?? 'Unknown',
      studentEmail: json['user_email'] ?? json['email'] ?? '',
      courseYear: json['course_year'] ?? '',
      course: json['course'] ?? '',
      yearLevel: json['year_level'] ?? '',
      appointedDate: json['appointed_date'],
      preferredDate: json['preferred_date'],
      time: json['time'],
      preferredTime: json['preferred_time'],
      consultationType: json['consultation_type'] ?? 'In-person',
      methodType: json['method_type']?.toString(),
      purpose: json['purpose'] ?? 'Not specified',
      status: json['status'] ?? 'pending',
      counselorPreference:
          json['counselorPreference'] ?? json['counselor_name'],
      reason: json['reason'],
      recordKind: json['record_kind']?.toString(),
      followUpStatus: json['follow_up_status']?.toString(),
      appointmentType: json['appointment_type']?.toString(),
      pendingFollowUpCount: _parseInt(
        json.containsKey('pending_follow_up_count')
            ? json['pending_follow_up_count']
            : json['pendingFollowUpCount'],
      ),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'user_email': studentEmail,
      'course_year': courseYear,
      'course': course,
      'year_level': yearLevel,
      'appointed_date': appointedDate,
      'preferred_date': preferredDate,
      'time': time,
      'preferred_time': preferredTime,
      'consultation_type': consultationType,
      'method_type': methodType,
      'purpose': purpose,
      'status': status,
      'counselorPreference': counselorPreference,
      'reason': reason,
      'record_kind': recordKind,
      'follow_up_status': followUpStatus,
      'appointment_type': appointmentType,
      'pending_follow_up_count': pendingFollowUpCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to parse integer values safely
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final trimmed = value.trim();
      final parsedInt = int.tryParse(trimmed);
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(trimmed);
      if (parsedDouble != null) return parsedDouble.round();
    }
    return 0;
  }

  // Helper method to parse datetime values safely
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Get the effective date (appointed_date or preferred_date)
  String? get effectiveDate => appointedDate ?? preferredDate;

  // Get the effective time (time or preferred_time)
  String? get effectiveTime => time ?? preferredTime;

  // Check if appointment is today
  bool get isToday {
    if (effectiveDate == null) return false;
    try {
      final appointmentDate = DateTime.parse(effectiveDate!);
      final today = DateTime.now();
      return appointmentDate.year == today.year &&
          appointmentDate.month == today.month &&
          appointmentDate.day == today.day;
    } catch (e) {
      return false;
    }
  }

  // Check if appointment is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  // Check if appointment is cancelled
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  // Check if appointment is approved
  bool get isApproved => status.toLowerCase() == 'approved';

  String _normalize(dynamic value) =>
      value?.toString().toLowerCase().trim() ?? '';

  // FIXED: Enhanced follow-up detection logic
  bool get _isFollowUp {
    final kind = _normalize(recordKind);
    final type = _normalize(appointmentType);

    // Check record_kind field
    if (kind.isNotEmpty && (kind.contains('follow') || kind == 'followup')) {
      return true;
    }

    // Check appointment_type field
    if (type.isNotEmpty && (type.contains('follow') || type == 'followup')) {
      return true;
    }

    // Check if purpose mentions follow-up
    final purposeLower = _normalize(purpose);
    if (purposeLower.contains('follow')) {
      return true;
    }

    return false;
  }

  // Public getter for follow-up detection
  bool get isFollowUp => _isFollowUp;

  // FIXED: Enhanced pending follow-up detection
  bool get isPendingFollowUp {
    // First check if this is a follow-up appointment
    if (!_isFollowUp) return false;

    // Check follow_up_status field explicitly
    final followUpStatusNorm = _normalize(followUpStatus);
    if (followUpStatusNorm.isNotEmpty) {
      // If follow_up_status exists and is pending, it's a pending follow-up
      if (followUpStatusNorm == 'pending' ||
          followUpStatusNorm.contains('pending')) {
        return true;
      }
      // If follow_up_status is completed/done, it's not pending anymore
      if (followUpStatusNorm == 'completed' ||
          followUpStatusNorm == 'done' ||
          followUpStatusNorm.contains('complete')) {
        return false;
      }
    }

    // Check pending follow-up count
    if (pendingFollowUpCount > 0) {
      return true;
    }

    // If status is approved but it's a follow-up, check if it needs action
    final statusNorm = _normalize(status);
    if (statusNorm == 'approved' && _isFollowUp) {
      // Approved follow-up that hasn't been marked completed is pending
      if (statusNorm != 'completed') {
        return true;
      }
    }

    return false;
  }

  String get _normalizedStatus => status.toLowerCase();

  // Get formatted date string
  String get formattedDate {
    if (effectiveDate == null) return 'Not scheduled';
    try {
      final date = DateTime.parse(effectiveDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Get formatted time string - time is already in 12-hour format with meridian labels
  String get formattedTime {
    if (effectiveTime == null) return 'Not specified';

    // Time is already in 12-hour format with AM/PM, return as is
    return effectiveTime!;
  }

  // FIXED: Enhanced status color logic - prioritize pending follow-up
  String get statusColor {
    // Priority 1: Check if it's a pending follow-up first
    if (isPendingFollowUp) {
      return 'warning';
    }

    // Priority 2: Check actual status
    switch (_normalizedStatus) {
      case 'completed':
        return 'success';
      case 'cancelled':
        return 'danger';
      case 'approved':
        return 'primary';
      case 'rejected':
        return 'danger';
      case 'pending':
      default:
        return 'warning';
    }
  }

  // FIXED: Enhanced status text logic - prioritize pending follow-up
  String get statusText {
    // Priority 1: Check if it's a pending follow-up first
    if (isPendingFollowUp) {
      return 'Pending Follow-up';
    }

    // Priority 2: Return actual status
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
      default:
        return 'Pending';
    }
  }
}
