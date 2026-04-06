class Appointment {
  final int id;
  final String? preferredDate;
  final String? preferredTime;
  final String? consultationType;
  final String? methodType;
  final String? counselorPreference;
  final String? counselorName;
  final String? description;
  final String? status;
  final String? reason;
  final String? purpose;
  final int? studentId;
  final int? followUpCount;
  final int? pendingFollowUpCount;
  final String? nextPendingDate;

  Appointment({
    required this.id,
    this.preferredDate,
    this.preferredTime,
    this.consultationType,
    this.methodType,
    this.counselorPreference,
    this.counselorName,
    this.description,
    this.status,
    this.reason,
    this.purpose,
    this.studentId,
    this.followUpCount,
    this.pendingFollowUpCount,
    this.nextPendingDate,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: _parseInt(json['id']) ?? 0,
      preferredDate: json['preferred_date'],
      preferredTime: json['preferred_time'],
      consultationType: json['consultation_type'],
      methodType: json['method_type'],
      counselorPreference: json['counselor_preference'],
      counselorName: json['counselor_name'],
      description: json['description'],
      status: json['status'],
      reason: json['reason'],
      purpose: json['purpose'],
      studentId: _parseInt(json['student_id']),
      followUpCount: _parseInt(json['follow_up_count']),
      pendingFollowUpCount: _parseInt(json['pending_follow_up_count']),
      nextPendingDate: json['next_pending_date'],
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
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'consultation_type': consultationType,
      'method_type': methodType,
      'counselor_preference': counselorPreference,
      'counselor_name': counselorName,
      'description': description,
      'status': status,
      'reason': reason,
      'purpose': purpose,
      'student_id': studentId,
      'follow_up_count': followUpCount,
      'pending_follow_up_count': pendingFollowUpCount,
      'next_pending_date': nextPendingDate,
    };
  }

  String get formattedDate {
    if (preferredDate == null) return '';
    try {
      final date = DateTime.parse(preferredDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return preferredDate!;
    }
  }

  String get statusClass {
    if (status == null) return 'pending';
    switch (status!.toUpperCase()) {
      case 'APPROVED':
        return 'approved';
      case 'REJECTED':
        return 'rejected';
      case 'COMPLETED':
        return 'completed';
      case 'CANCELLED':
        return 'cancelled';
      case 'PENDING':
      default:
        return 'pending';
    }
  }
}

class Counselor {
  final int counselorId;
  final String name;
  final String specialization;

  Counselor({
    required this.counselorId,
    required this.name,
    required this.specialization,
  });

  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      counselorId: _parseInt(json['counselor_id']) ?? 0,
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get displayName => name; // Remove specialization from display name
}
