import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../models/admin_appointment_detail.dart';

class ScheduledAppointmentsViewModel extends ChangeNotifier {
  // Data
  List<AdminAppointmentDetail> _appointments = [];
  List<AdminAppointmentDetail> get appointments => _appointments;

  // Filtered appointments (after search/filter)
  List<AdminAppointmentDetail> _filteredAppointments = [];
  List<AdminAppointmentDetail> get filteredAppointments =>
      _filteredAppointments;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Search and filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'all';
  String get statusFilter => _statusFilter;

  String _dateFilter = 'all';
  String get dateFilter => _dateFilter;

  // Statistics
  int _totalAppointments = 0;
  int get totalAppointments => _totalAppointments;

  int _todayAppointments = 0;
  int get todayAppointments => _todayAppointments;

  int _upcomingAppointments = 0;
  int get upcomingAppointments => _upcomingAppointments;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterAppointments();
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _filterAppointments();
    notifyListeners();
  }

  void setDateFilter(String filter) {
    _dateFilter = filter;
    _filterAppointments();
    notifyListeners();
  }

  void _filterAppointments() {
    _filteredAppointments = _appointments.where((appointment) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          appointment.userId.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          appointment.fullName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          appointment.purpose.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Status filter
      final matchesStatus =
          _statusFilter == 'all' ||
          appointment.status.toLowerCase() == _statusFilter.toLowerCase();

      // Date filter (simplified - could be enhanced)
      final matchesDate =
          _dateFilter == 'all' || true; 

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  Future<void> fetchAppointments() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/scheduled-appointments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _appointments =
              (data['appointments'] as List?)
                  ?.map((a) => AdminAppointmentDetail.fromJson(a))
                  .toList() ??
              [];

          _totalAppointments = _appointments.length;
          _todayAppointments = _appointments
              .where((a) => _isToday(a.date))
              .length;
          _upcomingAppointments = _appointments
              .where((a) => _isUpcoming(a.date))
              .length;

          _filterAppointments();
        }
      }
    } catch (e) {
      debugPrint('Error fetching scheduled appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isToday(String dateString) {
    try {
      final appointmentDate = DateTime.parse(dateString);
      final today = DateTime.now();
      return appointmentDate.year == today.year &&
          appointmentDate.month == today.month &&
          appointmentDate.day == today.day;
    } catch (e) {
      return false;
    }
  }

  bool _isUpcoming(String dateString) {
    try {
      final appointmentDate = DateTime.parse(dateString);
      final today = DateTime.now();
      return appointmentDate.isAfter(today);
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(
    int appointmentId,
    String status,
    String? reason,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/admin/scheduled-appointments/$appointmentId',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status, 'reason': reason}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await fetchAppointments();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating appointment status: $e');
      return false;
    }
  }

  void initialize() {
    fetchAppointments();
  }
}
