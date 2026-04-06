/// Model for appointment statistics
class AppointmentStatistics {
  final int totalAppointments;
  final int approvedAppointments;
  final int pendingAppointments;
  final int cancelledAppointments;
  final int completedAppointments;

  AppointmentStatistics({
    required this.totalAppointments,
    required this.approvedAppointments,
    required this.pendingAppointments,
    required this.cancelledAppointments,
    required this.completedAppointments,
  });

  factory AppointmentStatistics.fromJson(Map<String, dynamic> json) {
    return AppointmentStatistics(
      totalAppointments: json['total_appointments'] ?? 0,
      approvedAppointments: json['approved_appointments'] ?? 0,
      pendingAppointments: json['pending_appointments'] ?? 0,
      cancelledAppointments: json['cancelled_appointments'] ?? 0,
      completedAppointments: json['completed_appointments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_appointments': totalAppointments,
      'approved_appointments': approvedAppointments,
      'pending_appointments': pendingAppointments,
      'cancelled_appointments': cancelledAppointments,
      'completed_appointments': completedAppointments,
    };
  }
}
