import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';

class AdminsManagementViewModel extends ChangeNotifier {
  // Data
  List<Map<String, dynamic>> _admins = [];
  List<Map<String, dynamic>> get admins => _admins;

  // Filtered admins (after search/filter)
  List<Map<String, dynamic>> _filteredAdmins = [];
  List<Map<String, dynamic>> get filteredAdmins => _filteredAdmins;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // Search and filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'all';
  String get statusFilter => _statusFilter;

  // Form data for adding/editing admin
  String _name = '';
  String get name => _name;

  String _email = '';
  String get email => _email;

  String _username = '';
  String get username => _username;

  String _password = '';
  String get password => _password;

  String _role = 'admin';
  String get role => _role;

  // Error messages
  String? _nameError;
  String? get nameError => _nameError;

  String? _emailError;
  String? get emailError => _emailError;

  String? _usernameError;
  String? get usernameError => _usernameError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  // Statistics
  int _totalAdmins = 0;
  int get totalAdmins => _totalAdmins;

  int _activeAdmins = 0;
  int get activeAdmins => _activeAdmins;

  void setName(String name) {
    _name = name;
    _nameError = null;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    _emailError = null;
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    _usernameError = null;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    _passwordError = null;
    notifyListeners();
  }

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterAdmins();
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _filterAdmins();
    notifyListeners();
  }

  void _filterAdmins() {
    _filteredAdmins = _admins.where((admin) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          admin['name']?.toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ==
              true ||
          admin['email']?.toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ==
              true ||
          admin['username']?.toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ==
              true;

      // Status filter
      final matchesStatus =
          _statusFilter == 'all' ||
          admin['status']?.toString().toLowerCase() ==
              _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> fetchAdmins() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/admins-management'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _admins =
              (data['admins'] as List?)
                  ?.map((a) => Map<String, dynamic>.from(a))
                  .toList() ??
              [];

          _totalAdmins = _admins.length;
          _activeAdmins = _admins.where((a) => a['status'] == 'active').length;

          _filterAdmins();
        }
      }
    } catch (e) {
      debugPrint('Error fetching admins: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAdmin() async {
    try {
      _isSaving = true;
      _clearErrors();
      notifyListeners();

      // Validate inputs
      if (!_validateForm()) {
        _isSaving = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/admins-management'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _name,
          'email': _email,
          'username': _username,
          'password': _password,
          'role': _role,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          clearForm();
          await fetchAdmins();
          return true;
        } else {
          _handleErrors(data['errors'] ?? {});
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error creating admin: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAdmin(int adminId) async {
    try {
      _isSaving = true;
      _clearErrors();
      notifyListeners();

      // Validate inputs
      if (!_validateForm()) {
        _isSaving = false;
        notifyListeners();
        return false;
      }

      final response = await http.put(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/admin/admins-management/$adminId',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _name,
          'email': _email,
          'username': _username,
          'role': _role,
          if (_password.isNotEmpty) 'password': _password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          clearForm();
          await fetchAdmins();
          return true;
        } else {
          _handleErrors(data['errors'] ?? {});
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating admin: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAdmin(int adminId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/admin/admins-management/$adminId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await fetchAdmins();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting admin: $e');
      return false;
    }
  }

  bool _validateForm() {
    bool isValid = true;

    if (_name.isEmpty) {
      _nameError = 'Name is required';
      isValid = false;
    }

    if (_email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!_isValidEmail(_email)) {
      _emailError = 'Please enter a valid email';
      isValid = false;
    }

    if (_username.isEmpty) {
      _usernameError = 'Username is required';
      isValid = false;
    } else if (_username.length < 3) {
      _usernameError = 'Username must be at least 3 characters';
      isValid = false;
    }

    if (_password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (_password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleErrors(Map<String, dynamic> errors) {
    _nameError = errors['name']?.first;
    _emailError = errors['email']?.first;
    _usernameError = errors['username']?.first;
    _passwordError = errors['password']?.first;
  }

  void _clearErrors() {
    _nameError = null;
    _emailError = null;
    _usernameError = null;
    _passwordError = null;
  }

  void clearForm() {
    _name = '';
    _email = '';
    _username = '';
    _password = '';
    _role = 'admin';
    _clearErrors();
  }

  void loadAdminForEdit(Map<String, dynamic> admin) {
    _name = admin['name'] ?? '';
    _email = admin['email'] ?? '';
    _username = admin['username'] ?? '';
    _password = '';
    _role = admin['role'] ?? 'admin';
    _clearErrors();
    notifyListeners();
  }

  void initialize() {
    fetchAdmins();
  }
}
