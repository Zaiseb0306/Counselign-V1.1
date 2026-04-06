import 'package:flutter/material.dart';
import 'dart:convert';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/scheduled_appointment.dart';
import '../models/counselor_schedule.dart';

class CounselorScheduledAppointmentsViewModel extends ChangeNotifier {
  final Session _session = Session();

  List<CounselorScheduledAppointment> _appointments = [];
  List<CounselorScheduledAppointment> get appointments => _appointments;

  List<CounselorScheduledAppointment> _filteredAppointments = [];
  List<CounselorScheduledAppointment> get filteredAppointments =>
      _searchQuery.isEmpty ? _appointments : _filteredAppointments;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<CounselorSchedule> _counselorSchedule = [];
  List<CounselorSchedule> get counselorSchedule => _counselorSchedule;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Loading states for specific operations
  bool _isUpdatingStatus = false;
  bool get isUpdatingStatus => _isUpdatingStatus;

  String? _updatingAppointmentId;
  String? get updatingAppointmentId => _updatingAppointmentId;

  Future<void> initialize() async {
    await Future.wait([loadAppointments(), loadCounselorSchedule()]);
  }

  Future<void> loadAppointments() async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint(
        '🔍 Fetching scheduled appointments from: ${ApiConfig.currentBaseUrl}/counselor/appointments/scheduled/get',
      );

      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/appointments/scheduled/get',
        headers: ApiConfig.defaultHeaders,
      );

      debugPrint(
        'Scheduled Appointments API Response Status: ${response.statusCode}',
      );
      debugPrint('Scheduled Appointments API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final appointmentsList = data['appointments'] as List<dynamic>? ?? [];
          _appointments = appointmentsList
              .map((json) => CounselorScheduledAppointment.fromJson(json))
              .toList();
          // Filter appointments after loading
          _filterAppointments();
        } else {
          _error = data['message'] ?? 'Failed to load appointments';
        }
      } else if (response.statusCode == 401) {
        _error = 'Session expired - Please log in again';
      } else {
        _error = 'Failed to load appointments: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading appointments: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCounselorSchedule() async {
    try {
      debugPrint(
        '🔍 Fetching counselor schedule from: ${ApiConfig.currentBaseUrl}/counselor/appointments/schedule',
      );

      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/appointments/schedule',
        headers: ApiConfig.defaultHeaders,
      );

      debugPrint(
        'Counselor Schedule API Response Status: ${response.statusCode}',
      );
      debugPrint('Counselor Schedule API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final scheduleList = data['schedule'] as List<dynamic>? ?? [];
          _counselorSchedule = scheduleList
              .map((json) => CounselorSchedule.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      // Schedule loading failure shouldn't block the main functionality
      debugPrint('Error loading counselor schedule: $e');
    }
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status, {
    String? rejectionReason,
  }) async {
    _setUpdatingStatus(true, appointmentId);

    try {
      debugPrint('🔍 Updating appointment status: $appointmentId to $status');

      // Prepare form data
      final formData = <String, String>{
        'appointment_id': appointmentId,
        'status': status,
        if (rejectionReason != null && rejectionReason.isNotEmpty)
          'rejection_reason': rejectionReason,
      };

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/counselor/appointments/updateAppointmentStatus',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formData.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&'),
      );

      debugPrint(
        'Update Appointment Status API Response Status: ${response.statusCode}',
      );
      debugPrint(
        'Update Appointment Status API Response Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Reload appointments to reflect the change
          await loadAppointments();
        } else {
          throw Exception(
            data['message'] ?? 'Failed to update appointment status',
          );
        }
      } else {
        throw Exception(
          'Failed to update appointment status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _setUpdatingStatus(false, null);
    }
  }

  Future<void> refresh() async {
    await Future.wait([loadAppointments(), loadCounselorSchedule()]);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdatingStatus(bool updating, String? appointmentId) {
    _isUpdatingStatus = updating;
    _updatingAppointmentId = appointmentId;
    notifyListeners();
  }

  // Get appointments for a specific date
  List<CounselorScheduledAppointment> getAppointmentsForDate(DateTime date) {
    return _appointments.where((appointment) {
      if (appointment.effectiveDate == null) return false;
      try {
        final appointmentDate = DateTime.parse(appointment.effectiveDate!);
        return appointmentDate.year == date.year &&
            appointmentDate.month == date.month &&
            appointmentDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get appointment count for a specific date
  int getAppointmentCountForDate(DateTime date) {
    return getAppointmentsForDate(date).length;
  }

  // Check if a date has appointments
  bool hasAppointmentsOnDate(DateTime date) {
    return getAppointmentCountForDate(date) > 0;
  }

  // Search functionality
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _filterAppointments();
    notifyListeners();
  }

  void _filterAppointments() {
    if (_searchQuery.isEmpty) {
      _filteredAppointments = _appointments;
      return;
    }

    final query = _searchQuery.toLowerCase();
    _filteredAppointments = _appointments.where((appointment) {
      // Search in student name
      if (appointment.studentName.toLowerCase().contains(query)) {
        return true;
      }

      // Search in student ID
      if (appointment.studentId.toString().contains(query)) {
        return true;
      }

      // Search in date (appointed_date or preferred_date)
      if (appointment.appointedDate != null &&
          appointment.appointedDate!.toLowerCase().contains(query)) {
        return true;
      }
      if (appointment.preferredDate != null &&
          appointment.preferredDate!.toLowerCase().contains(query)) {
        return true;
      }

      // Search in time
      if (appointment.time != null &&
          appointment.time!.toLowerCase().contains(query)) {
        return true;
      }
      if (appointment.preferredTime != null &&
          appointment.preferredTime!.toLowerCase().contains(query)) {
        return true;
      }

      // Search in consultation type
      if (appointment.consultationType.toLowerCase().contains(query)) {
        return true;
      }

      // Search in method type
      if (appointment.methodType != null &&
          appointment.methodType!.toLowerCase().contains(query)) {
        return true;
      }

      // Search in purpose
      if (appointment.purpose.toLowerCase().contains(query)) {
        return true;
      }

      // Search in status
      if (appointment.status.toLowerCase().contains(query)) {
        return true;
      }

      // Search in course
      if (appointment.course.toLowerCase().contains(query)) {
        return true;
      }

      // Search in year level
      if (appointment.yearLevel.toLowerCase().contains(query)) {
        return true;
      }

      // Search in course year
      if (appointment.courseYear.toLowerCase().contains(query)) {
        return true;
      }

      // Search in formatted date
      if (appointment.formattedDate.toLowerCase().contains(query)) {
        return true;
      }

      // Search in formatted time
      if (appointment.formattedTime.toLowerCase().contains(query)) {
        return true;
      }

      return false;
    }).toList();
  }
}
