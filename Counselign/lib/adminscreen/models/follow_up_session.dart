/// Model for follow-up sessions (admin view)
class FollowUpSession {
  final int id;
  final String studentName;
  final String counselorName;
  final String purpose;
  final String status;
  final String? reason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FollowUpSession({
    required this.id,
    required this.studentName,
    required this.counselorName,
    required this.purpose,
    required this.status,
    this.reason,
    required this.createdAt,
    this.updatedAt,
  });

  factory FollowUpSession.fromJson(Map<String, dynamic> json) {
    return FollowUpSession(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      counselorName: json['counselor_name'] ?? '',
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? '',
      reason: json['reason'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'counselor_name': counselorName,
      'purpose': purpose,
      'status': status,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper getters
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

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

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
