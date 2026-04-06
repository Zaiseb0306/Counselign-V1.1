class CompletedAppointment {
  final int id;
  final String studentId;
  final String studentName;
  final String preferredDate;
  final String preferredTime;
  final String consultationType;
  final String? methodType;
  final String? description;
  final String purpose;
  final String reason;
  final String status;
  final String? searchTerm;
  final int followUpCount;
  final int pendingFollowUpCount;
  final String? nextPendingDate;

  CompletedAppointment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.preferredDate,
    required this.preferredTime,
    required this.consultationType,
    this.methodType,
    this.description,
    required this.purpose,
    required this.reason,
    required this.status,
    this.searchTerm,
    required this.followUpCount,
    required this.pendingFollowUpCount,
    this.nextPendingDate,
  });

  factory CompletedAppointment.fromJson(Map<String, dynamic> json) {
    return CompletedAppointment(
      id: _parseInt(json['id']),
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      preferredDate: json['preferred_date']?.toString() ?? '',
      preferredTime: json['preferred_time']?.toString() ?? '',
      consultationType: json['consultation_type']?.toString() ?? '',
      methodType: json['method_type']?.toString(),
      description: json['description']?.toString(),
      purpose: json['purpose']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      searchTerm: json['search_term']?.toString(),
      followUpCount: _parseInt(json['follow_up_count']),
      pendingFollowUpCount: _parseInt(json['pending_follow_up_count']),
      nextPendingDate: json['next_pending_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'consultation_type': consultationType,
      'method_type': methodType,
      'description': description,
      'purpose': purpose,
      'reason': reason,
      'status': status,
      'search_term': searchTerm,
      'follow_up_count': followUpCount,
      'pending_follow_up_count': pendingFollowUpCount,
      'next_pending_date': nextPendingDate,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
