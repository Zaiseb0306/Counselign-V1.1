import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../models/follow_up_session.dart';

class FollowUpSessionsViewModel extends ChangeNotifier {
  // Data
  List<FollowUpSession> _sessions = [];
  List<FollowUpSession> get sessions => _sessions;

  // Filtered sessions (after search/filter)
  List<FollowUpSession> _filteredSessions = [];
  List<FollowUpSession> get filteredSessions => _filteredSessions;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Search and filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'all';
  String get statusFilter => _statusFilter;

  // Statistics
  int _totalSessions = 0;
  int get totalSessions => _totalSessions;

  int _pendingSessions = 0;
  int get pendingSessions => _pendingSessions;

  int _approvedSessions = 0;
  int get approvedSessions => _approvedSessions;

  int _completedSessions = 0;
  int get completedSessions => _completedSessions;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterSessions();
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _filterSessions();
    notifyListeners();
  }

  void _filterSessions() {
    _filteredSessions = _sessions.where((session) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          session.studentName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          session.counselorName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          session.purpose.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus =
          _statusFilter == 'all' ||
          session.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> fetchSessions() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/follow-up-sessions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _sessions =
              (data['sessions'] as List?)
                  ?.map((s) => FollowUpSession.fromJson(s))
                  .toList() ??
              [];

          _totalSessions = _sessions.length;
          _pendingSessions = _sessions.where((s) => s.isPending).length;
          _approvedSessions = _sessions.where((s) => s.isApproved).length;
          _completedSessions = _sessions.where((s) => s.isCompleted).length;

          _filterSessions();
        }
      }
    } catch (e) {
      debugPrint('Error fetching follow-up sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSessionStatus(
    int sessionId,
    String status,
    String? reason,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/admin/follow-up-sessions/$sessionId',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status, 'reason': reason}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await fetchSessions();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating session status: $e');
      return false;
    }
  }

  void initialize() {
    fetchSessions();
  }
}
