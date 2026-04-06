import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';

class HistoryReportsViewModel extends ChangeNotifier {
  // Data
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> get reports => _reports;

  // Filtered reports (after search/filter)
  List<Map<String, dynamic>> _filteredReports = [];
  List<Map<String, dynamic>> get filteredReports => _filteredReports;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Search and filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _typeFilter = 'all';
  String get typeFilter => _typeFilter;

  String _dateFilter = 'all';
  String get dateFilter => _dateFilter;

  // Statistics
  int _totalReports = 0;
  int get totalReports => _totalReports;

  int _appointmentReports = 0;
  int get appointmentReports => _appointmentReports;

  int _userReports = 0;
  int get userReports => _userReports;

  int _systemReports = 0;
  int get systemReports => _systemReports;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterReports();
    notifyListeners();
  }

  void setTypeFilter(String filter) {
    _typeFilter = filter;
    _filterReports();
    notifyListeners();
  }

  void setDateFilter(String filter) {
    _dateFilter = filter;
    _filterReports();
    notifyListeners();
  }

  void _filterReports() {
    _filteredReports = _reports.where((report) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          report['title']?.toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ==
              true ||
          report['description']?.toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ==
              true;

      // Type filter
      final matchesType =
          _typeFilter == 'all' ||
          report['type']?.toString().toLowerCase() == _typeFilter.toLowerCase();

      final matchesDate = _dateFilter == 'all' || true;

      return matchesSearch && matchesType && matchesDate;
    }).toList();
  }

  Future<void> fetchReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/history-reports'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _reports =
              (data['reports'] as List?)
                  ?.map((r) => Map<String, dynamic>.from(r))
                  .toList() ??
              [];

          _totalReports = _reports.length;
          _appointmentReports = _reports
              .where((r) => r['type'] == 'appointment')
              .length;
          _userReports = _reports.where((r) => r['type'] == 'user').length;
          _systemReports = _reports.where((r) => r['type'] == 'system').length;

          _filterReports();
        }
      }
    } catch (e) {
      debugPrint('Error fetching history reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generateReport(
    String type,
    Map<String, dynamic> parameters,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/generate-report'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'type': type, 'parameters': parameters}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await fetchReports();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error generating report: $e');
      return false;
    }
  }

  Future<bool> exportReport(int reportId, String format) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/export-report'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'report_id': reportId, 'format': format}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error exporting report: $e');
      return false;
    }
  }

  void initialize() {
    fetchReports();
  }
}
