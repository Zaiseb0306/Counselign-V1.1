import 'package:flutter/foundation.dart';

class CounselorAppointment {
  final String id;
  final String studentId;
  final String studentName;
  final String? username;
  final String? email;
  final String? course;
  final String? yearLevel;
  final String? purpose;
  final String? notes;
  final String? consultationType;
  final String? methodType;
  final String? reason;
  final String status; // pending, approved, rejected, completed, cancelled
  final DateTime? preferredDate;
  final String? preferredTime;
  final DateTime? appointmentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CounselorAppointment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.status,
    this.username,
    this.email,
    this.course,
    this.yearLevel,
    this.purpose,
    this.notes,
    this.consultationType,
    this.methodType,
    this.reason,
    this.preferredDate,
    this.preferredTime,
    this.appointmentDate,
    this.createdAt,
    this.updatedAt,
  });

  factory CounselorAppointment.fromJson(Map<String, dynamic> json) {
    String readString(dynamic v) => v == null ? '' : '$v';
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final s = '$v';
      final normalized = s.contains('T') ? s : s.replaceFirst(' ', 'T');
      return DateTime.tryParse(normalized);
    }

    return CounselorAppointment(
      id: readString(json['id']),
      studentId: readString(json['student_id']),
      studentName: readString(json['student_name']).isNotEmpty
          ? readString(json['student_name'])
          : readString(json['username']),
      username: json['username']?.toString(),
      email: json['user_email']?.toString() ?? json['email']?.toString(),
      course: json['course']?.toString(),
      yearLevel: json['year_level']?.toString(),
      purpose: json['purpose']?.toString(),
      notes: (json['notes'] ?? json['description'])?.toString(),
      consultationType: json['consultation_type']?.toString(),
      methodType: json['method_type']?.toString(),
      reason: json['reason']?.toString(),
      status: readString(json['status']).isEmpty
          ? 'pending'
          : readString(json['status']).toLowerCase(),
      preferredDate: parseDate(json['preferred_date']),
      preferredTime: json['preferred_time']?.toString(),
      appointmentDate: parseDate(json['appointment_date']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    String? fmt(DateTime? d) => d?.toIso8601String();
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'username': username,
      'email': email,
      'course': course,
      'year_level': yearLevel,
      'purpose': purpose,
      'notes': notes,
      'consultation_type': consultationType,
      'method_type': methodType,
      'reason': reason,
      'status': status,
      'preferred_date': fmt(preferredDate),
      'preferred_time': preferredTime,
      'appointment_date': fmt(appointmentDate),
      'created_at': fmt(createdAt),
      'updated_at': fmt(updatedAt),
    };
  }

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return studentName.toLowerCase().contains(q) ||
        studentId.toLowerCase().contains(q) ||
        (username?.toLowerCase().contains(q) ?? false) ||
        (purpose?.toLowerCase().contains(q) ?? false) ||
        (notes?.toLowerCase().contains(q) ?? false) ||
        (methodType?.toLowerCase().contains(q) ?? false);
  }
}
