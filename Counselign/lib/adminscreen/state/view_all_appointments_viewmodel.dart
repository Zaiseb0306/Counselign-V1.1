import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../models/admin_appointment_detail.dart';
import '../models/appointment_statistics.dart';

class ViewAllAppointmentsViewModel extends ChangeNotifier {
  // Data
  List<AdminAppointmentDetail> _appointments = [];
  List<AdminAppointmentDetail> get appointments => _appointments;

  // Filtered appointments (after search/filter)
  List<AdminAppointmentDetail> _filteredAppointments = [];
  List<AdminAppointmentDetail> get filteredAppointments =>
      _filteredAppointments;

  // Statistics
  AppointmentStatistics? _statistics;
  AppointmentStatistics? get statistics => _statistics;

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
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/view-all-appointments'),
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

          _filterAppointments();
        }
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/appointment-statistics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _statistics = AppointmentStatistics.fromJson(data['statistics']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
    }
  }

  void initialize() {
    fetchAppointments();
    fetchStatistics();
  }
}
