class FollowUpAppointment {
  final int id;
  final String counselorId;
  final String studentId;
  final int parentAppointmentId;
  final String preferredDate;
  final String preferredTime;
  final String consultationType;
  final int followUpSequence;
  final String? description;
  final String? reason;
  final String status;
  final String? counselorName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FollowUpAppointment({
    required this.id,
    required this.counselorId,
    required this.studentId,
    required this.parentAppointmentId,
    required this.preferredDate,
    required this.preferredTime,
    required this.consultationType,
    required this.followUpSequence,
    this.description,
    this.reason,
    required this.status,
    this.counselorName,
    this.createdAt,
    this.updatedAt,
  });

  factory FollowUpAppointment.fromJson(Map<String, dynamic> json) {
    return FollowUpAppointment(
      id: _parseInt(json['id']) ?? 0,
      counselorId: json['counselor_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      parentAppointmentId: _parseInt(json['parent_appointment_id']) ?? 0,
      preferredDate: json['preferred_date'] ?? '',
      preferredTime: json['preferred_time'] ?? '',
      consultationType: json['consultation_type'] ?? '',
      followUpSequence: _parseInt(json['follow_up_sequence']) ?? 0,
      description: json['description'],
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      counselorName: json['counselor_name'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'counselor_id': counselorId,
      'student_id': studentId,
      'parent_appointment_id': parentAppointmentId,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'consultation_type': consultationType,
      'follow_up_sequence': followUpSequence,
      'description': description,
      'reason': reason,
      'status': status,
      'counselor_name': counselorName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get formattedDate {
    if (preferredDate.isEmpty) return '';
    try {
      final date = DateTime.parse(preferredDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return preferredDate;
    }
  }

  String get formattedTime {
    if (preferredTime.isEmpty) return '';

    // Time is already in 12-hour format with AM/PM, return as is
    return preferredTime;
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get statusClass {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'pending';
      case 'approved':
        return 'approved';
      case 'rejected':
        return 'rejected';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}
