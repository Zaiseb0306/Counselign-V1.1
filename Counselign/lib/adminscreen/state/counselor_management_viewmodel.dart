import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../models/counselor_schedule.dart';

class CounselorManagementViewModel extends ChangeNotifier {
  // Data
  List<CounselorInfo> _counselors = [];
  List<CounselorInfo> get counselors => _counselors;

  // Filtered counselors (after search/filter)
  List<CounselorInfo> _filteredCounselors = [];
  List<CounselorInfo> get filteredCounselors => _filteredCounselors;

  // Selected counselor for detailed view
  CounselorInfo? _selectedCounselor;
  CounselorInfo? get selectedCounselor => _selectedCounselor;

  CounselorSchedule? _selectedCounselorSchedule;
  CounselorSchedule? get selectedCounselorSchedule =>
      _selectedCounselorSchedule;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingSchedule = false;
  bool get isLoadingSchedule => _isLoadingSchedule;

  // Search and filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'all';
  String get statusFilter => _statusFilter;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterCounselors();
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _filterCounselors();
    notifyListeners();
  }

  void _filterCounselors() {
    _filteredCounselors = _counselors.where((counselor) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          counselor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          counselor.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          counselor.degree.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter (simplified - could be enhanced with actual status)
      final matchesStatus = _statusFilter == 'all' || true;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> fetchCounselors() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/counselor-management'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _counselors =
              (data['counselors'] as List?)
                  ?.map((c) => CounselorInfo.fromJson(c))
                  .toList() ??
              [];

          _filterCounselors();
        }
      }
    } catch (e) {
      debugPrint('Error fetching counselors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCounselorSchedule(int counselorId) async {
    try {
      _isLoadingSchedule = true;
      _selectedCounselorSchedule = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/admin/counselor-schedule?counselor_id=$counselorId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['schedule'] != null) {
          _selectedCounselorSchedule = CounselorSchedule.fromJson(
            data['schedule'],
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching counselor schedule: $e');
    } finally {
      _isLoadingSchedule = false;
      notifyListeners();
    }
  }

  void selectCounselor(CounselorInfo counselor) {
    _selectedCounselor = counselor;
    fetchCounselorSchedule(counselor.id);
    notifyListeners();
  }

  void clearSelection() {
    _selectedCounselor = null;
    _selectedCounselorSchedule = null;
    notifyListeners();
  }

  void initialize() {
    fetchCounselors();
  }
}
