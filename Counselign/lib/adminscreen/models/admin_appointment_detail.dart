/// Model for detailed admin appointment view (for appointments screen)
class AdminAppointmentDetail {
  final int id;
  final String userId;
  final String fullName;
  final String date;
  final String time;
  final String consultationType;
  final String purpose;
  final String? counselor;
  final String status;
  final String? reasonForStatus;

  AdminAppointmentDetail({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.date,
    required this.time,
    required this.consultationType,
    required this.purpose,
    this.counselor,
    required this.status,
    this.reasonForStatus,
  });

  factory AdminAppointmentDetail.fromJson(Map<String, dynamic> json) {
    return AdminAppointmentDetail(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      consultationType: json['consultation_type'] ?? '',
      purpose: json['purpose'] ?? '',
      counselor: json['counselor'],
      status: json['status'] ?? '',
      reasonForStatus: json['reason_for_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'date': date,
      'time': time,
      'consultation_type': consultationType,
      'purpose': purpose,
      'counselor': counselor,
      'status': status,
      'reason_for_status': reasonForStatus,
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
