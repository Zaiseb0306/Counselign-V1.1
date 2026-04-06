import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../models/admin_user.dart';
import '../models/student_pds.dart';

class ViewUsersViewModel extends ChangeNotifier {
  // Data
  List<AdminUser> _users = [];
  List<AdminUser> get users => _users;

  // Filtered users (after search/filter)
  List<AdminUser> _filteredUsers = [];
  List<AdminUser> get filteredUsers => _filteredUsers;

  // Student PDS data
  StudentPds? _selectedStudentPds;
  StudentPds? get selectedStudentPds => _selectedStudentPds;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingPds = false;
  bool get isLoadingPds => _isLoadingPds;

  // Search and filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'all';
  String get statusFilter => _statusFilter;

  // Statistics
  int _totalUsers = 0;
  int get totalUsers => _totalUsers;

  int _activeUsers = 0;
  int get activeUsers => _activeUsers;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterUsers();
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _filterUsers();
    notifyListeners();
  }

  void _filterUsers() {
    _filteredUsers = _users.where((user) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus =
          _statusFilter == 'all' ||
          (_statusFilter == 'active' && user.isActive) ||
          (_statusFilter == 'inactive' && !user.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> fetchUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/view-users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _users =
              (data['users'] as List?)
                  ?.map((u) => AdminUser.fromJson(u))
                  .toList() ??
              [];

          _totalUsers = _users.length;
          _activeUsers = _users.where((u) => u.isActive).length;

          _filterUsers();
        }
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStudentPds(String userId) async {
    try {
      _isLoadingPds = true;
      _selectedStudentPds = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/admin/view-users/pds?user_id=$userId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['pds'] != null) {
          _selectedStudentPds = StudentPds.fromJson(data['pds']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching student PDS: $e');
    } finally {
      _isLoadingPds = false;
      notifyListeners();
    }
  }

  void initialize() {
    fetchUsers();
  }
}
