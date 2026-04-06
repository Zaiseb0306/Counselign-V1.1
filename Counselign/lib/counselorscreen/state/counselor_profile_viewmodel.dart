import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/counselor_profile.dart';
import '../models/counselor_availability.dart';

class CounselorProfileViewModel extends ChangeNotifier {
  CounselorProfile? _profile;
  CounselorProfile? get profile => _profile;

  AvailabilityData? _availability;
  AvailabilityData? get availability => _availability;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Profile update states
  bool _isUpdatingProfile = false;
  bool get isUpdatingProfile => _isUpdatingProfile;

  bool _isUpdatingPersonalInfo = false;
  bool get isUpdatingPersonalInfo => _isUpdatingPersonalInfo;

  bool _isUpdatingPassword = false;
  bool get isUpdatingPassword => _isUpdatingPassword;

  bool _isUpdatingAvailability = false;
  bool get isUpdatingAvailability => _isUpdatingAvailability;

  bool _isUploadingPicture = false;
  bool get isUploadingPicture => _isUploadingPicture;

  // Error states for individual fields
  String? _profileUpdateError;
  String? get profileUpdateError => _profileUpdateError;

  String? _personalInfoError;
  String? get personalInfoError => _personalInfoError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  String? _availabilityError;
  String? get availabilityError => _availabilityError;

  String? _pictureUploadError;
  String? get pictureUploadError => _pictureUploadError;

  final Session _session = Session();

  Future<void> initialize() async {
    debugPrint('🚀 Initializing CounselorProfileViewModel...');
    await loadProfile();
    debugPrint('✅ Profile loaded, now loading availability...');
    await loadAvailability();
    debugPrint('✅ Initialization complete');
  }

  Future<void> loadProfile() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/profile/get',
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📊 Profile API Response: $data');
        debugPrint('📊 Counselor data: ${data['counselor']}');

        if (data['success'] == true) {
          debugPrint('🔍 PROFILE RELOAD DEBUG:');
          debugPrint('🔍 Raw API response username: "${data['username']}"');
          debugPrint('🔍 Raw API response email: "${data['email']}"');
          debugPrint('🔍 Raw API response user_id: "${data['user_id']}"');
          debugPrint('🔍 Raw counselor data from API: ${data['counselor']}');
          debugPrint(
            '🔍 Contact number from API: ${data['counselor']?['contact_number']}',
          );
          debugPrint('🔍 Full API response data: $data');

          _profile = CounselorProfile.fromJson(data);
          debugPrint('✅ Profile loaded successfully: ${_profile?.username}');
          debugPrint('✅ Profile email: ${_profile?.email}');
          debugPrint('✅ Profile username: ${_profile?.username}');
          debugPrint('✅ Counselor name: ${_profile?.counselor?.name}');
          debugPrint('✅ Counselor email: ${_profile?.counselor?.email}');
          debugPrint(
            '✅ Counselor contact: ${_profile?.counselor?.contactNumber}',
          );
          debugPrint('✅ Counselor address: ${_profile?.counselor?.address}');
          debugPrint('✅ Counselor degree: ${_profile?.counselor?.degree}');
        } else {
          // Try to extract any available data from the failed response
          debugPrint(
            '⚠️ Profile API failed, attempting to create profile with available data',
          );
          _profile = _createDefaultProfileFromResponse(data);
          debugPrint('✅ Default profile created with available data');
        }
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please log in again.';
        debugPrint('❌ Session expired');
        // Try to get basic user info before creating default profile
        _profile = await _tryGetBasicUserInfo() ?? _createDefaultProfile();
      } else {
        // Create default profile for other errors to allow data entry
        debugPrint(
          '⚠️ Profile load failed with status: ${response.statusCode}, creating default profile',
        );
        _profile = _createDefaultProfile();
      }
    } catch (e) {
      // Try to get basic user info before creating default profile
      debugPrint(
        '⚠️ Profile load error: $e, attempting to get basic user info',
      );
      _profile = await _tryGetBasicUserInfo() ?? _createDefaultProfile();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAvailability() async {
    try {
      debugPrint('🔄 Loading availability...');
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/profile/availability',
        headers: ApiConfig.defaultHeaders,
      );

      debugPrint('📡 Availability API Response Status: ${response.statusCode}');
      debugPrint('📡 Availability API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📊 Availability API Data: $data');

        if (data['success'] == true) {
          final availabilityData = data['availability'];
          debugPrint('📊 Raw availability data: $availabilityData');

          // Handle case where availability is an empty list or null
          if (availabilityData is List && availabilityData.isEmpty) {
            debugPrint(
              '📊 Availability is empty list, creating default availability',
            );
            _availability = _createDefaultAvailability();
          } else if (availabilityData is Map<String, dynamic>) {
            _availability = AvailabilityData.fromJson(availabilityData);
          } else {
            debugPrint(
              '📊 Availability data is not in expected format, creating default',
            );
            _availability = _createDefaultAvailability();
          }
          debugPrint(
            '✅ Availability loaded successfully: ${_availability?.availableDays}',
          );
          debugPrint(
            '✅ Availability by day: ${_availability?.availabilityByDay}',
          );
          notifyListeners(); // Notify UI to update
        } else {
          // Create default availability with empty values
          debugPrint(
            '⚠️ Availability load failed: ${data['message']}, creating default availability',
          );
          _availability = _createDefaultAvailability();
          notifyListeners();
        }
      } else {
        // Create default availability for other errors
        debugPrint(
          '⚠️ Availability load failed with status: ${response.statusCode}, creating default availability',
        );
        _availability = _createDefaultAvailability();
        notifyListeners();
      }
    } catch (e) {
      // Create default availability for any errors
      debugPrint(
        '⚠️ Availability load error: $e, creating default availability',
      );
      _availability = _createDefaultAvailability();
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String username,
    required String email,
  }) async {
    _isUpdatingProfile = true;
    _profileUpdateError = null;
    notifyListeners();

    try {
      // Debug what we're sending
      debugPrint(
        '🔍 updateProfile - Username: "$username" (length: ${username.length})',
      );
      debugPrint(
        '🔍 updateProfile - Email: "$email" (length: ${email.length})',
      );
      debugPrint('🔍 updateProfile - Username isEmpty: ${username.isEmpty}');
      debugPrint('🔍 updateProfile - Email isEmpty: ${email.isEmpty}');

      // Use multipart form data like the JavaScript frontend
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.currentBaseUrl}/counselor/profile/update'),
      );

      // Add form fields
      request.fields['username'] = username;
      request.fields['email'] = email;

      // Add cookies and headers
      if (_session.cookies.isNotEmpty) {
        final cookieString = _session.cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
        request.headers['Cookie'] = cookieString;
      }
      request.headers.addAll(ApiConfig.defaultHeaders);

      debugPrint('🔍 updateProfile - Request fields: ${request.fields}');
      debugPrint('🔍 updateProfile - Request headers: ${request.headers}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('🔍 updateProfile - Response status: ${response.statusCode}');
      debugPrint('🔍 updateProfile - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await loadProfile(); // Reload profile
          debugPrint('✅ Profile updated successfully');
          return true;
        } else {
          _profileUpdateError = data['message'] ?? 'Failed to update profile';
          debugPrint('❌ Profile update failed: $_profileUpdateError');
        }
      } else {
        _profileUpdateError =
            'Failed to update profile: ${response.statusCode}';
        debugPrint(
          '❌ Profile update failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _profileUpdateError = 'Error updating profile: $e';
      debugPrint('❌ Profile update error: $e');
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> updatePersonalInfo({
    required String fullname,
    required String birthdate,
    required String address,
    required String degree,
    required String email,
    required String contact,
    required String sex,
    required String civilStatus,
  }) async {
    debugPrint('🚨 updatePersonalInfo METHOD CALLED!');
    debugPrint('🚨 Contact parameter received: $contact');
    debugPrint('🚨 Email parameter received: $email');
    debugPrint('🚨 Address parameter received: $address');

    _isUpdatingPersonalInfo = true;
    _personalInfoError = null;
    notifyListeners();

    // Basic validation - at least fullname should be provided
    if (fullname.trim().isEmpty) {
      _personalInfoError = 'Full name is required';
      _isUpdatingPersonalInfo = false;
      notifyListeners();
      return false;
    }

    try {
      // Send fields exactly like the working MVC version
      // Required fields get 'N/A' if empty, optional fields stay empty
      final formData = <String, String>{
        'fullname': fullname.isEmpty ? 'N/A' : fullname,
        'birthdate': birthdate, // Optional field - keep empty string
        'address': address.isEmpty ? 'N/A' : address,
        'degree': degree.isEmpty ? 'N/A' : degree,
        'email': email.isEmpty ? 'N/A' : email,
        'contact': contact.isEmpty ? 'N/A' : contact,
        'sex': sex, // Optional field - keep empty string
        'civil_status': civilStatus, // Optional field - keep empty string
      };

      debugPrint('🧪 TESTING: Sending ALL fields like website does');
      debugPrint('🧪 Fullname: $fullname');
      debugPrint('🧪 Contact: $contact');
      debugPrint('🧪 Email: $email');
      debugPrint('🧪 Address: $address');
      debugPrint('🧪 Degree: $degree');
      debugPrint('🧪 Birthdate: $birthdate');
      debugPrint('🧪 Sex: $sex');
      debugPrint('🧪 Civil Status: $civilStatus');

      debugPrint('🔄 Updating personal info...');
      debugPrint('📊 Form data: $formData');
      debugPrint('📊 Contact number being sent: ${formData['contact']}');
      debugPrint(
        '🌐 API URL: ${ApiConfig.currentBaseUrl}/counselor/profile/counselor-info',
      );

      // Use FormData exactly like the working MVC version
      final client = http.Client();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/counselor/profile/counselor-info',
        ),
      );

      // Add form fields exactly like MVC version
      for (final entry in formData.entries) {
        request.fields[entry.key] = entry.value;
      }

      // Add cookies and headers exactly like MVC version
      request.headers['Cookie'] =
          'ci_session=${_session.cookies['ci_session']}';
      // Don't add Content-Type header for multipart requests - let it be set automatically
      request.headers['Accept'] = 'application/json';
      request.headers['X-Requested-With'] = 'XMLHttpRequest';

      debugPrint('🧪 TESTING: Using multipart form data like website');
      debugPrint('🧪 Request fields: ${request.fields}');
      debugPrint('🧪 Request headers: ${request.headers}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      client.close();

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response body: ${response.body}');
      debugPrint('📡 Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📊 Parsed response: $data');

        if (data['success'] == true) {
          debugPrint(
            '✅ Backend returned success: ${data['message'] ?? 'No message'}',
          );
          debugPrint('📊 Backend response data: $data');
          debugPrint('⏳ Waiting 1 second before reload...');
          await Future.delayed(const Duration(seconds: 1));
          debugPrint('🔄 Reloading profile after update...');
          await loadProfile(); // Reload profile
          debugPrint('✅ Personal info updated successfully');
          return true;
        } else {
          _personalInfoError =
              data['message'] ?? 'Failed to update personal information';
          debugPrint('❌ Personal info update failed: $_personalInfoError');
        }
      } else {
        _personalInfoError =
            'Failed to update personal information: ${response.statusCode}';
        debugPrint(
          '❌ Personal info update failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _personalInfoError = 'Error updating personal information: $e';
      debugPrint('❌ Personal info update error: $e');
    } finally {
      _isUpdatingPersonalInfo = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isUpdatingPassword = true;
    _passwordError = null;
    notifyListeners();

    try {
      // Debug what we're sending
      debugPrint(
        '🔍 updatePassword - Current Password: "$currentPassword" (length: ${currentPassword.length})',
      );
      debugPrint(
        '🔍 updatePassword - New Password: "$newPassword" (length: ${newPassword.length})',
      );
      debugPrint(
        '🔍 updatePassword - Confirm Password: "$confirmPassword" (length: ${confirmPassword.length})',
      );
      debugPrint(
        '🔍 updatePassword - Current Password isEmpty: ${currentPassword.isEmpty}',
      );
      debugPrint(
        '🔍 updatePassword - New Password isEmpty: ${newPassword.isEmpty}',
      );
      debugPrint(
        '🔍 updatePassword - Confirm Password isEmpty: ${confirmPassword.isEmpty}',
      );

      // Use multipart form data like the JavaScript frontend
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.currentBaseUrl}/update-password'),
      );

      // Add form fields
      request.fields['current_password'] = currentPassword;
      request.fields['new_password'] = newPassword;
      request.fields['confirm_password'] = confirmPassword;

      // Add cookies and headers
      if (_session.cookies.isNotEmpty) {
        final cookieString = _session.cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
        request.headers['Cookie'] = cookieString;
      }
      request.headers.addAll(ApiConfig.defaultHeaders);

      debugPrint('🔍 updatePassword - Request fields: ${request.fields}');
      debugPrint('🔍 updatePassword - Request headers: ${request.headers}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('🔍 updatePassword - Response status: ${response.statusCode}');
      debugPrint('🔍 updatePassword - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          debugPrint('✅ Password updated successfully');
          return true;
        } else {
          _passwordError = data['message'] ?? 'Failed to update password';
          debugPrint('❌ Password update failed: $_passwordError');
        }
      } else {
        _passwordError = 'Failed to update password: ${response.statusCode}';
        debugPrint(
          '❌ Password update failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _passwordError = 'Error updating password: $e';
      debugPrint('❌ Password update error: $e');
    } finally {
      _isUpdatingPassword = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> uploadProfilePicture(File imageFile) async {
    _isUploadingPicture = true;
    _pictureUploadError = null;
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.currentBaseUrl}/counselor/profile/picture'),
      );

      // Add session cookies
      if (_session.cookies.isNotEmpty) {
        final cookieString = _session.cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
        request.headers['Cookie'] = cookieString;
      }

      // Add headers
      request.headers.addAll(ApiConfig.defaultHeaders);
      request.headers.remove('Content-Type'); // Let multipart set it

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await loadProfile(); // Reload profile
          debugPrint('✅ Profile picture uploaded successfully');
          return true;
        } else {
          _pictureUploadError =
              data['message'] ?? 'Failed to upload profile picture';
          debugPrint('❌ Picture upload failed: $_pictureUploadError');
        }
      } else {
        _pictureUploadError =
            'Failed to upload profile picture: ${response.statusCode}';
        debugPrint(
          '❌ Picture upload failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _pictureUploadError = 'Error uploading profile picture: $e';
      debugPrint('❌ Picture upload error: $e');
    } finally {
      _isUploadingPicture = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> updateAvailability({
    required List<String> selectedDays,
    required Map<String, List<TimeRange>> timeRangesByDay,
  }) async {
    _isUpdatingAvailability = true;
    _availabilityError = null;
    notifyListeners();

    try {
      final Map<String, List<String>> timesByDay = {};

      for (final day in selectedDays) {
        final ranges = timeRangesByDay[day] ?? [];
        timesByDay[day] = ranges.map((range) => range.toString()).toList();
      }

      final payload = {'days': selectedDays, 'timesByDay': timesByDay};

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/counselor/profile/availability',
        headers: ApiConfig.defaultHeaders,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await loadAvailability(); // Reload availability
          debugPrint('✅ Availability updated successfully');
          return true;
        } else {
          _availabilityError =
              data['message'] ?? 'Failed to update availability';
          debugPrint('❌ Availability update failed: $_availabilityError');
        }
      } else {
        _availabilityError =
            'Failed to update availability: ${response.statusCode}';
        debugPrint(
          '❌ Availability update failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _availabilityError = 'Error updating availability: $e';
      debugPrint('❌ Availability update error: $e');
    } finally {
      _isUpdatingAvailability = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> deleteAvailabilitySlot({
    required String day,
    required TimeRange timeRange,
  }) async {
    try {
      final payload = {'day': day, 'from': timeRange.from, 'to': timeRange.to};

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/counselor/profile/availability',
        headers: {
          'Content-Type': 'application/json',
          ...ApiConfig.defaultHeaders,
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await loadAvailability(); // Reload availability
          debugPrint('✅ Availability slot deleted successfully');
          return true;
        } else {
          debugPrint('❌ Availability slot deletion failed: ${data['message']}');
        }
      } else {
        debugPrint(
          '❌ Availability slot deletion failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Availability slot deletion error: $e');
    }

    return false;
  }

  Future<void> refresh() async {
    await loadProfile();
    await loadAvailability();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to build image URL
  String buildImageUrl() {
    if (_profile == null) {
      return '${ApiConfig.currentBaseUrl}/Photos/profile.png';
    }
    return _profile!.buildImageUrl(ApiConfig.currentBaseUrl);
  }

  // Helper method to get counselor name
  String get counselorName {
    if (_profile?.counselor?.name != null &&
        _profile!.counselor!.name!.isNotEmpty) {
      return _profile!.counselor!.name!;
    }
    return 'N/A';
  }

  // Helper method to get counselor degree
  String get counselorDegree {
    final degree = _profile?.counselor?.degree;
    if (degree != null && degree.isNotEmpty) {
      return degree;
    }
    return 'N/A';
  }

  // Helper method to get counselor email
  String get counselorEmail {
    final email = _profile?.counselor?.email ?? _profile?.email;
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return 'N/A';
  }

  // Helper method to get counselor contact
  String get counselorContact {
    final contact = _profile?.counselor?.contactNumber;
    if (contact != null && contact.isNotEmpty) {
      return contact;
    }
    return 'N/A';
  }

  // Helper method to get counselor address
  String get counselorAddress {
    final address = _profile?.counselor?.address;
    if (address != null && address.isNotEmpty) {
      return address;
    }
    return 'N/A';
  }

  // Helper method to get counselor civil status
  String get counselorCivilStatus {
    final civilStatus = _profile?.counselor?.civilStatus;
    if (civilStatus != null && civilStatus.isNotEmpty) {
      return civilStatus;
    }
    return 'none';
  }

  // Helper method to get counselor sex
  String get counselorSex {
    final sex = _profile?.counselor?.sex;
    if (sex != null && sex.isNotEmpty) {
      return sex;
    }
    return 'none';
  }

  // Helper method to get counselor birthdate
  String get counselorBirthdate {
    final birthdate = _profile?.counselor?.birthdate;
    if (birthdate != null && birthdate.isNotEmpty) {
      return birthdate;
    }
    return 'N/A';
  }

  // Helper method to format birthdate
  String get formattedBirthdate {
    final birthdate = counselorBirthdate;
    if (birthdate.isEmpty) return '';

    try {
      final date = DateTime.parse(birthdate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return birthdate;
    }
  }

  // Create a default profile with empty values for data entry
  CounselorProfile _createDefaultProfile() {
    return CounselorProfile(
      id: 0,
      userId: '',
      username: '',
      email: '',
      role: 'counselor',
      lastLogin: null,
      profilePicture: null,
      counselor: CounselorDetails(
        counselorId: '',
        name: '',
        degree: '',
        email: '',
        contactNumber: '',
        address: '',
        profilePicture: null,
        civilStatus: '',
        sex: '',
        birthdate: '',
      ),
    );
  }

  // Create a default profile trying to extract any available data from failed API response
  CounselorProfile _createDefaultProfileFromResponse(
    Map<String, dynamic> responseData,
  ) {
    debugPrint(
      '🔍 Attempting to extract data from failed response: $responseData',
    );

    // Try to extract basic user information from the response
    final userId = responseData['user_id']?.toString() ?? '';
    final username = responseData['username']?.toString() ?? '';
    final email = responseData['email']?.toString() ?? '';
    final role = responseData['role']?.toString() ?? 'counselor';
    final lastLogin = responseData['last_login']?.toString();
    final profilePicture = responseData['profile_picture']?.toString();

    // Try to extract counselor information
    final counselorData = responseData['counselor'] as Map<String, dynamic>?;
    final counselorId = counselorData?['counselor_id']?.toString() ?? userId;
    final counselorName = counselorData?['name']?.toString() ?? '';
    final counselorDegree = counselorData?['degree']?.toString() ?? '';
    final counselorEmail = counselorData?['email']?.toString() ?? email;
    final counselorContact = counselorData?['contact_number']?.toString() ?? '';
    final counselorAddress = counselorData?['address']?.toString() ?? '';
    final counselorProfilePicture =
        counselorData?['profile_picture']?.toString() ?? profilePicture;
    final counselorCivilStatus =
        counselorData?['civil_status']?.toString() ?? '';
    final counselorSex = counselorData?['sex']?.toString() ?? '';
    final counselorBirthdate = counselorData?['birthdate']?.toString() ?? '';

    debugPrint(
      '🔍 Extracted data - UserId: "$userId", Username: "$username", Email: "$email"',
    );
    debugPrint(
      '🔍 Extracted counselor data - Name: "$counselorName", Degree: "$counselorDegree"',
    );

    return CounselorProfile(
      id: 0,
      userId: userId,
      username: username,
      email: email,
      role: role,
      lastLogin: lastLogin,
      profilePicture: profilePicture,
      counselor: CounselorDetails(
        counselorId: counselorId,
        name: counselorName,
        degree: counselorDegree,
        email: counselorEmail,
        contactNumber: counselorContact,
        address: counselorAddress,
        profilePicture: counselorProfilePicture,
        civilStatus: counselorCivilStatus,
        sex: counselorSex,
        birthdate: counselorBirthdate,
      ),
    );
  }

  // Create a default availability with empty values for data entry
  AvailabilityData _createDefaultAvailability() {
    return AvailabilityData(availabilityByDay: {});
  }

  // Try to get basic user information from a simpler API endpoint
  Future<CounselorProfile?> _tryGetBasicUserInfo() async {
    try {
      debugPrint('🔄 Attempting to get basic user info from dashboard API...');
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/dashboard/get',
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📊 Basic user info API response: $data');

        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];
          debugPrint('✅ Basic user info retrieved successfully');

          // Create profile from basic user data
          return CounselorProfile(
            id: 0,
            userId: userData['user_id']?.toString() ?? '',
            username: userData['username']?.toString() ?? '',
            email: userData['email']?.toString() ?? '',
            role: 'counselor',
            lastLogin: userData['last_login']?.toString(),
            profilePicture: userData['profile_picture']?.toString(),
            counselor: CounselorDetails(
              counselorId: userData['user_id']?.toString() ?? '',
              name: '',
              degree: '',
              email: userData['email']?.toString() ?? '',
              contactNumber: '',
              address: '',
              profilePicture: userData['profile_picture']?.toString(),
              civilStatus: '',
              sex: '',
              birthdate: '',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to get basic user info: $e');
    }

    return null;
  }

  // Clear all error states
  void clearErrors() {
    _error = null;
    _profileUpdateError = null;
    _personalInfoError = null;
    _passwordError = null;
    _availabilityError = null;
    _pictureUploadError = null;
    notifyListeners();
  }
}
