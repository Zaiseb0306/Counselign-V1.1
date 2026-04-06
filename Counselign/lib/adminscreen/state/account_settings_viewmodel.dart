import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';

class AccountSettingsViewModel extends ChangeNotifier {
  // Profile data
  String _name = '';
  String get name => _name;

  String _email = '';
  String get email => _email;

  String _username = '';
  String get username => _username;

  String? _profileImage;
  String? get profileImage => _profileImage;

  // Password change
  String _currentPassword = '';
  String get currentPassword => _currentPassword;

  String _newPassword = '';
  String get newPassword => _newPassword;

  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _isChangingPassword = false;
  bool get isChangingPassword => _isChangingPassword;

  // Error messages
  String? _nameError;
  String? get nameError => _nameError;

  String? _emailError;
  String? get emailError => _emailError;

  String? _usernameError;
  String? get usernameError => _usernameError;

  String? _passwordError;
  String? get passwordError => _passwordError;

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

  void setCurrentPassword(String password) {
    _currentPassword = password;
    _passwordError = null;
    notifyListeners();
  }

  void setNewPassword(String password) {
    _newPassword = password;
    _passwordError = null;
    notifyListeners();
  }

  void setConfirmPassword(String password) {
    _confirmPassword = password;
    _passwordError = null;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/account-settings'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _name = data['profile']['name'] ?? '';
          _email = data['profile']['email'] ?? '';
          _username = data['profile']['username'] ?? '';
          _profileImage = data['profile']['profile_image'];
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile() async {
    try {
      _isSaving = true;
      _clearErrors();
      notifyListeners();

      // Validate inputs
      if (!_validateProfile()) {
        _isSaving = false;
        notifyListeners();
        return false;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/account-settings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _name,
          'email': _email,
          'username': _username,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return true;
        } else {
          _handleProfileErrors(data['errors'] ?? {});
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword() async {
    try {
      _isChangingPassword = true;
      _passwordError = null;
      notifyListeners();

      // Validate password inputs
      if (!_validatePassword()) {
        _isChangingPassword = false;
        notifyListeners();
        return false;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'current_password': _currentPassword,
          'new_password': _newPassword,
          'confirm_password': _confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentPassword = '';
          _newPassword = '';
          _confirmPassword = '';
          return true;
        } else {
          _passwordError = data['message'] ?? 'Password change failed';
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error changing password: $e');
      _passwordError = 'An error occurred while changing password';
      return false;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  bool _validateProfile() {
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

    return isValid;
  }

  bool _validatePassword() {
    if (_currentPassword.isEmpty) {
      _passwordError = 'Current password is required';
      return false;
    }

    if (_newPassword.isEmpty) {
      _passwordError = 'New password is required';
      return false;
    }

    if (_newPassword.length < 6) {
      _passwordError = 'New password must be at least 6 characters';
      return false;
    }

    if (_newPassword != _confirmPassword) {
      _passwordError = 'Passwords do not match';
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleProfileErrors(Map<String, dynamic> errors) {
    _nameError = errors['name']?.first;
    _emailError = errors['email']?.first;
    _usernameError = errors['username']?.first;
  }

  void _clearErrors() {
    _nameError = null;
    _emailError = null;
    _usernameError = null;
    _passwordError = null;
  }

  void initialize() {
    fetchProfile();
  }
}
