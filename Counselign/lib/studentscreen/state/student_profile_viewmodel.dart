import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'pds_viewmodel.dart';
import '../models/student_profile.dart';
import '../../api/config.dart';
import '../../utils/session.dart';

class StudentProfileViewModel extends ChangeNotifier {
  final Session _session = Session();

  // Profile data
  StudentProfile? _profile;

  // PDS ViewModel
  PDSViewModel? _pdsViewModel;

  // Initialization state
  bool _isInitialized = false;

  // Loading states
  bool _isLoadingProfile = false;
  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;
  bool _isUploadingPicture = false;

  // Error states
  String? _profileError;
  String? _updateError;
  String? _passwordError;
  String? _uploadError;

  // Getters
  StudentProfile? get profile => _profile;
  PDSViewModel get pdsViewModel => _pdsViewModel!;

  bool get isLoadingProfile => _isLoadingProfile;
  bool get isUpdatingProfile => _isUpdatingProfile;
  bool get isChangingPassword => _isChangingPassword;
  bool get isUploadingPicture => _isUploadingPicture;
  bool get isInitialized => _isInitialized;

  String? get profileError => _profileError;
  String? get updateError => _updateError;
  String? get passwordError => _passwordError;
  String? get uploadError => _uploadError;

  // Profile getters
  String get userId => _profile?.userId ?? 'N/A';
  String get username => _profile?.username ?? 'N/A';
  String get email => _profile?.email ?? 'N/A';
  String get profilePicture => _profile?.profilePicture ?? '';

  // Initialize the viewmodel
  Future<void> initialize() async {
    if (_isInitialized) return;

    _pdsViewModel = PDSViewModel();
    // Listen to PDS ViewModel changes to forward notifications
    _pdsViewModel!.addListener(_onPdsViewModelChanged);
    await loadProfile();
    await _pdsViewModel!.initialize(userId, email);
    _isInitialized = true;
  }

  // Forward PDS ViewModel notifications
  void _onPdsViewModelChanged() {
    notifyListeners();
  }

  // Load profile data
  Future<void> loadProfile() async {
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      final response = await _session.get('${ApiConfig.currentBaseUrl}/student/profile/get');

      debugPrint('Profile Load Response Status: ${response.statusCode}');
      debugPrint('Profile Load Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _profile = StudentProfile.fromJson(data);
          debugPrint('Profile loaded successfully: ${_profile?.username}');
        } else {
          _profileError = data['message'] ?? 'Failed to load profile';
          debugPrint('Profile Load Error: $_profileError');
        }
      } else {
        _profileError = 'Failed to load profile: ${response.statusCode}';
        debugPrint('Profile Load HTTP Error: $_profileError');
      }
    } catch (e) {
      _profileError = 'Error loading profile: $e';
      debugPrint('Profile load error: $e');
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // Update profile information
  Future<bool> updateProfile({
    required String username,
    required String email,
    XFile? profilePicture,
  }) async {
    _isUpdatingProfile = true;
    _updateError = null;
    notifyListeners();

    try {
      // First update username and email
      final formData = <String, String>{
        'username': username,
        'email': email,
      };

      final response = await _session.post('${ApiConfig.currentBaseUrl}/student/profile/update', body: formData);

      debugPrint('Profile Update Response Status: ${response.statusCode}');
      debugPrint('Profile Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Update profile picture if provided
          if (profilePicture != null) {
            await _uploadProfilePicture(profilePicture);
          }

          await loadProfile(); // Reload profile data
          debugPrint('Profile updated successfully');
          return true;
        } else {
          _updateError = data['message'] ?? 'Failed to update profile';
          debugPrint('Profile Update Error: $_updateError');
        }
      } else {
        _updateError = 'Failed to update profile: ${response.statusCode}';
        debugPrint('Profile Update HTTP Error: $_updateError');
      }
    } catch (e) {
      _updateError = 'Error updating profile: $e';
      debugPrint('Profile update error: $e');
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }

    return false;
  }

  // Upload profile picture
  Future<bool> _uploadProfilePicture(XFile imageFile) async {
    _isUploadingPicture = true;
    _uploadError = null;
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.currentBaseUrl}/student/profile/picture'),
      );

      // Add session cookies
      request.headers.addAll({
        'Cookie': 'ci_session=${_session.cookies['ci_session']}',
      });

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Profile Picture Upload Response Status: ${response.statusCode}');
      debugPrint('Profile Picture Upload Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          debugPrint('Profile picture uploaded successfully');
          return true;
        } else {
          _uploadError = data['message'] ?? 'Failed to upload profile picture';
          debugPrint('Profile Picture Upload Error: $_uploadError');
        }
      } else {
        _uploadError = 'Failed to upload profile picture: ${response.statusCode}';
        debugPrint('Profile Picture Upload HTTP Error: $_uploadError');
      }
    } catch (e) {
      _uploadError = 'Error uploading profile picture: $e';
      debugPrint('Profile picture upload error: $e');
    } finally {
      _isUploadingPicture = false;
      notifyListeners();
    }

    return false;
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isChangingPassword = true;
    _passwordError = null;
    notifyListeners();

    try {
      final formData = <String, String>{
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      final response = await _session.post('${ApiConfig.currentBaseUrl}/update-password', body: formData);

      debugPrint('Password Change Response Status: ${response.statusCode}');
      debugPrint('Password Change Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          debugPrint('Password changed successfully');
          return true;
        } else {
          _passwordError = data['message'] ?? 'Failed to change password';
          debugPrint('Password Change Error: $_passwordError');
        }
      } else {
        _passwordError = 'Failed to change password: ${response.statusCode}';
        debugPrint('Password Change HTTP Error: $_passwordError');
      }
    } catch (e) {
      _passwordError = 'Error changing password: $e';
      debugPrint('Password change error: $e');
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }

    return false;
  }

  // Clear errors
  void clearErrors() {
    _profileError = null;
    _updateError = null;
    _passwordError = null;
    _uploadError = null;
    _pdsViewModel?.clearErrors();
    notifyListeners();
  }

  @override
  void dispose() {
    _pdsViewModel?.removeListener(_onPdsViewModelChanged);
    _pdsViewModel?.dispose();
    super.dispose();
  }
}