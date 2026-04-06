class FollowUpSession {
  final int id;
  final int parentAppointmentId;
  final String studentId;
  final String preferredDate;
  final String preferredTime;
  final String consultationType;
  final String? description;
  final String? reason;
  final String? purpose;
  final String status;
  final int followUpSequence;
  final String? counselorName;

  FollowUpSession({
    required this.id,
    required this.parentAppointmentId,
    required this.studentId,
    required this.preferredDate,
    required this.preferredTime,
    required this.consultationType,
    this.description,
    this.reason,
    this.purpose,
    required this.status,
    required this.followUpSequence,
    this.counselorName,
  });

  factory FollowUpSession.fromJson(Map<String, dynamic> json) {
    return FollowUpSession(
      id: _parseInt(json['id']),
      parentAppointmentId: _parseInt(json['parent_appointment_id']),
      studentId: json['student_id']?.toString() ?? '',
      preferredDate: json['preferred_date']?.toString() ?? '',
      preferredTime: json['preferred_time']?.toString() ?? '',
      consultationType: json['consultation_type']?.toString() ?? '',
      description: json['description']?.toString(),
      reason: json['reason']?.toString(),
      purpose: json['purpose']?.toString(),
      status: json['status']?.toString() ?? '',
      followUpSequence: _parseInt(json['follow_up_sequence']),
      counselorName: json['counselor_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_appointment_id': parentAppointmentId,
      'student_id': studentId,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'consultation_type': consultationType,
      'description': description,
      'reason': reason,
      'purpose': purpose,
      'status': status,
      'follow_up_sequence': followUpSequence,
      'counselor_name': counselorName,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}
