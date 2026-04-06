import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Model for appointment report data structure matching backend MVC
class AppointmentReport {
  final List<AppointmentReportItem> appointments;
  final List<String> labels;
  final List<int> completed;
  final List<int> approved;
  final List<int> rejected;
  final List<int> pending;
  final List<int> cancelled;
  final int totalCompleted;
  final int totalApproved;
  final int totalRejected;
  final int totalPending;
  final int totalCancelled;
  final List<int> monthlyCompleted;
  final List<int> monthlyApproved;
  final List<int> monthlyRejected;
  final List<int> monthlyPending;
  final List<int> monthlyCancelled;
  final String counselorName;
  final WeekInfo? weekInfo;
  final String? startDate;
  final String? endDate;
  final List<WeekRange>? weekRanges;

  const AppointmentReport({
    required this.appointments,
    required this.labels,
    required this.completed,
    required this.approved,
    required this.rejected,
    required this.pending,
    required this.cancelled,
    required this.totalCompleted,
    required this.totalApproved,
    required this.totalRejected,
    required this.totalPending,
    required this.totalCancelled,
    required this.monthlyCompleted,
    required this.monthlyApproved,
    required this.monthlyRejected,
    required this.monthlyPending,
    required this.monthlyCancelled,
    required this.counselorName,
    this.weekInfo,
    this.startDate,
    this.endDate,
    this.weekRanges,
  });

  factory AppointmentReport.fromJson(Map<String, dynamic> json) {
    return AppointmentReport(
      appointments:
          (json['appointments'] as List<dynamic>?)
              ?.map((item) => AppointmentReportItem.fromJson(item))
              .toList() ??
          [],
      labels: (json['labels'] as List<dynamic>?)?.cast<String>() ?? [],
      completed: (json['completed'] as List<dynamic>?)?.cast<int>() ?? [],
      approved: (json['approved'] as List<dynamic>?)?.cast<int>() ?? [],
      rejected: (json['rejected'] as List<dynamic>?)?.cast<int>() ?? [],
      pending: (json['pending'] as List<dynamic>?)?.cast<int>() ?? [],
      cancelled: (json['cancelled'] as List<dynamic>?)?.cast<int>() ?? [],
      totalCompleted: json['totalCompleted'] ?? 0,
      totalApproved: json['totalApproved'] ?? 0,
      totalRejected: json['totalRejected'] ?? 0,
      totalPending: json['totalPending'] ?? 0,
      totalCancelled: json['totalCancelled'] ?? 0,
      monthlyCompleted:
          (json['monthlyCompleted'] as List<dynamic>?)?.cast<int>() ??
          List.filled(12, 0),
      monthlyApproved:
          (json['monthlyApproved'] as List<dynamic>?)?.cast<int>() ??
          List.filled(12, 0),
      monthlyRejected:
          (json['monthlyRejected'] as List<dynamic>?)?.cast<int>() ??
          List.filled(12, 0),
      monthlyPending:
          (json['monthlyPending'] as List<dynamic>?)?.cast<int>() ??
          List.filled(12, 0),
      monthlyCancelled:
          (json['monthlyCancelled'] as List<dynamic>?)?.cast<int>() ??
          List.filled(12, 0),
      counselorName: json['counselorName'] ?? 'Unknown Counselor',
      weekInfo: json['weekInfo'] != null
          ? WeekInfo.fromJson(json['weekInfo'] as Map<String, dynamic>)
          : null,
      startDate: json['startDate'],
      endDate: json['endDate'],
      weekRanges: (json['weekRanges'] as List<dynamic>?)
          ?.map((item) => WeekRange.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointments': appointments.map((item) => item.toJson()).toList(),
      'labels': labels,
      'completed': completed,
      'approved': approved,
      'rejected': rejected,
      'pending': pending,
      'cancelled': cancelled,
      'totalCompleted': totalCompleted,
      'totalApproved': totalApproved,
      'totalRejected': totalRejected,
      'totalPending': totalPending,
      'totalCancelled': totalCancelled,
      'monthlyCompleted': monthlyCompleted,
      'monthlyApproved': monthlyApproved,
      'monthlyRejected': monthlyRejected,
      'monthlyPending': monthlyPending,
      'monthlyCancelled': monthlyCancelled,
      'counselorName': counselorName,
      'weekInfo': weekInfo,
      'startDate': startDate,
      'endDate': endDate,
      'weekRanges': weekRanges?.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model for individual appointment report item
class AppointmentReportItem {
  final String userId;
  final String studentName;
  final String appointedDate;
  final String appointedTime;
  final String consultationType;
  final String purpose;
  final String counselorName;
  final String status;
  final String? reason;
  final String? methodType;
  final String? appointmentType;
  final String? recordKind;

  const AppointmentReportItem({
    required this.userId,
    required this.studentName,
    required this.appointedDate,
    required this.appointedTime,
    required this.consultationType,
    required this.purpose,
    required this.counselorName,
    required this.status,
    this.reason,
    this.methodType,
    this.appointmentType,
    this.recordKind,
  });

  factory AppointmentReportItem.fromJson(Map<String, dynamic> json) {
    return AppointmentReportItem(
      userId:
          json['user_id']?.toString() ?? json['student_id']?.toString() ?? '',
      studentName: json['student_name'] ?? '',
      appointedDate: json['appointed_date'] ?? json['preferred_date'] ?? '',
      appointedTime: json['appointed_time'] ?? json['preferred_time'] ?? '',
      consultationType: json['consultation_type'] ?? 'Individual Consultation',
      purpose: json['purpose'] ?? 'N/A',
      counselorName: json['counselor_name'] ?? '',
      status: json['status'] ?? 'PENDING',
      reason: json['reason'],
      methodType: json['method_type'],
      appointmentType: json['appointment_type'],
      recordKind: json['record_kind'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'student_name': studentName,
      'appointed_date': appointedDate,
      'appointed_time': appointedTime,
      'consultation_type': consultationType,
      'purpose': purpose,
      'counselor_name': counselorName,
      'status': status,
      'reason': reason,
      'method_type': methodType,
      'appointment_type': appointmentType,
      'record_kind': recordKind,
    };
  }

  /// Get formatted date for display
  String get formattedDate {
    try {
      final date = DateTime.parse(appointedDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return appointedDate;
    }
  }

  /// Get status badge color
  String get statusColor {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'completed';
      case 'APPROVED':
        return 'approved';
      case 'REJECTED':
        return 'rejected';
      case 'PENDING':
        return 'pending';
      case 'CANCELLED':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  /// Get session type display text
  String get sessionTypeDisplay {
    if (appointmentType != null && appointmentType!.isNotEmpty) {
      return appointmentType!;
    }
    if (recordKind == 'follow_up') {
      return 'Follow-up Session';
    }
    return 'First Session';
  }
}

/// Model for week range data
class WeekRange {
  final String start;
  final String end;

  const WeekRange({required this.start, required this.end});

  factory WeekRange.fromJson(Map<String, dynamic> json) {
    return WeekRange(start: json['start'] ?? '', end: json['end'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end};
  }
}

/// Model for week info data
class WeekInfo {
  final String startDate;
  final String endDate;
  final List<DayInfo> weekDays;

  const WeekInfo({
    required this.startDate,
    required this.endDate,
    required this.weekDays,
  });

  factory WeekInfo.fromJson(Map<String, dynamic> json) {
    return WeekInfo(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      weekDays:
          (json['weekDays'] as List<dynamic>?)
              ?.map((e) => DayInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'weekDays': weekDays.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model for day info data
class DayInfo {
  final String fullDate;
  final String shortDayName;
  final String dayMonth;

  const DayInfo({
    required this.fullDate,
    required this.shortDayName,
    required this.dayMonth,
  });

  factory DayInfo.fromJson(Map<String, dynamic> json) {
    return DayInfo(
      fullDate: json['fullDate'] ?? '',
      shortDayName: json['shortDayName'] ?? '',
      dayMonth: json['dayMonth'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullDate': fullDate,
      'shortDayName': shortDayName,
      'dayMonth': dayMonth,
    };
  }
}

/// Model for export filters
class ExportFilters {
  final String? startDate;
  final String? endDate;
  final String? studentId;
  final String? course;
  final String? yearLevel;

  const ExportFilters({
    this.startDate,
    this.endDate,
    this.studentId,
    this.course,
    this.yearLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'studentId': studentId,
      'course': course,
      'yearLevel': yearLevel,
    };
  }

  /// Check if any filters are applied
  bool get hasFilters {
    return startDate != null ||
        endDate != null ||
        studentId != null ||
        course != null ||
        yearLevel != null;
  }

  /// Get filter summary for display
  String get filterSummary {
    final parts = <String>[];
    if (startDate != null) parts.add('Start: ${_formatDate(startDate!)}');
    if (endDate != null) parts.add('End: ${_formatDate(endDate!)}');
    if (studentId != null) parts.add('Student: $studentId');
    if (course != null) parts.add('Course: $course');
    if (yearLevel != null) parts.add('Year: $yearLevel');
    return parts.join(' | ');
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

/// Model for chart data
class ChartData {
  final List<String> labels;
  final List<int> completed;
  final List<int> approved;
  final List<int> rejected;
  final List<int> pending;
  final List<int> cancelled;

  const ChartData({
    required this.labels,
    required this.completed,
    required this.approved,
    required this.rejected,
    required this.pending,
    required this.cancelled,
  });

  /// Get pie chart data
  List<AppointmentPieChartData> get pieChartData {
    return [
      AppointmentPieChartData(
        'Completed',
        completed.isNotEmpty ? completed.first : 0,
        const Color(0xFF0d6efd),
      ),
      AppointmentPieChartData(
        'Approved',
        approved.isNotEmpty ? approved.first : 0,
        const Color(0xFF198754),
      ),
      AppointmentPieChartData(
        'Rejected',
        rejected.isNotEmpty ? rejected.first : 0,
        const Color(0xFFdc3545),
      ),
      AppointmentPieChartData(
        'Pending',
        pending.isNotEmpty ? pending.first : 0,
        const Color(0xFFffc107),
      ),
      AppointmentPieChartData(
        'Cancelled',
        cancelled.isNotEmpty ? cancelled.first : 0,
        const Color(0xFF6c757d),
      ),
    ];
  }
}

/// Model for pie chart data
class AppointmentPieChartData {
  final String label;
  final int value;
  final Color color;

  const AppointmentPieChartData(this.label, this.value, this.color);
}

/// Time range enum for reports
enum TimeRange {
  daily('daily', 'Daily Report'),
  weekly('weekly', 'Weekly Report'),
  monthly('monthly', 'Monthly Report');

  const TimeRange(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Appointment status enum
enum AppointmentStatus {
  all('all', 'All Appointments'),
  followup('followup', 'Follow-up'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const AppointmentStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}
