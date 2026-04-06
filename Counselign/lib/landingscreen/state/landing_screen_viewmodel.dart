import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:counselign/api/config.dart';
import '../../routes.dart';
import '../../utils/session.dart';
import '../../utils/secure_logger.dart';
import '../../utils/input_validator.dart';
import '../../utils/secure_storage.dart';
import '../dialogs/resend_verification_dialog.dart';

class LandingScreenViewModel extends ChangeNotifier {
  // Session management
  final Session _session = Session();

  // Dialog visibility states
  bool _showLoginDialog = false;
  bool _showSignUpDialog = false;
  bool _showForgotPasswordDialog = false;
  bool _showCodeEntryDialog = false;
  bool _showNewPasswordDialog = false;
  bool _showTermsDialog = false;
  bool _showContactDialog = false;
  bool _showVerificationDialog = false;
  bool _showVerificationSuccessDialog = false;
  bool _showAdminLoginDialog = false;
  bool _showResendResetCodeDialog = false;
  bool _showCounselorInfoDialog = false;
  bool _showCounselorPendingDialog = false;

  // Loading states
  bool _isLoginLoading = false;
  bool _isSignUpLoading = false;
  bool _isForgotPasswordLoading = false;
  bool _isCodeEntryLoading = false;
  bool _isNewPasswordLoading = false;
  bool _isContactLoading = false;
  bool _isVerificationLoading = false;
  bool _isResendVerificationLoading = false;
  bool _isAdminLoginLoading = false;
  bool _isResendResetCodeLoading = false;
  final bool _isForgotPasswordNavigating = false;
  final bool _isSignUpNavigating = false;

  // Error messages
  String _loginError = '';
  String _signUpError = '';
  String _forgotPasswordError = '';
  String _codeEntryError = '';
  String _newPasswordError = '';
  String _contactError = '';
  String _verificationError = '';
  String _resendVerificationError = '';
  String _adminLoginError = '';
  String _resendResetCodeError = '';
  String _resendResetCodeInputError = '';
  String _cInfoWarning = '';
  String _counselorPendingMessage = '';

  // Individual field errors
  String _loginUserIdError = '';
  String _loginPasswordError = '';
  String _signUpUserIdError = '';
  String _signUpUsernameError = '';
  String _signUpEmailError = '';
  String _signUpPasswordError = '';
  String _signUpConfirmPasswordError = '';
  String _forgotPasswordInputError = '';
  String _resetCodeError = '';
  String _newPasswordErrorField = '';
  String _confirmNewPasswordError = '';

  // Verification state
  String _verificationMessage =
      'A verification email has been sent to your registered email address. Please enter the token below to verify your account.';
  String _verificationRole = '';

  // Controllers for form fields
  final TextEditingController loginUserIdController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController signUpUserIdController = TextEditingController();
  final TextEditingController signUpUsernameController =
      TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPasswordController =
      TextEditingController();
  final TextEditingController signUpConfirmPasswordController =
      TextEditingController();
  final TextEditingController forgotPasswordController =
      TextEditingController();
  final TextEditingController resetCodeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactEmailController = TextEditingController();
  final TextEditingController contactSubjectController =
      TextEditingController();
  final TextEditingController contactMessageController =
      TextEditingController();
  final TextEditingController verificationTokenController =
      TextEditingController();
  final TextEditingController resendVerificationController =
      TextEditingController();
  final TextEditingController resendResetCodeController =
      TextEditingController();

  final TextEditingController adminUserIdController = TextEditingController();
  final TextEditingController adminPasswordController = TextEditingController();

  // Counselor info controllers
  final TextEditingController cCounselorIdController = TextEditingController();
  final TextEditingController cNameController = TextEditingController();
  final TextEditingController cDegreeController = TextEditingController();
  final TextEditingController cEmailController = TextEditingController();
  final TextEditingController cContactController = TextEditingController();
  final TextEditingController cAddressController = TextEditingController();
  final TextEditingController cBirthdateController = TextEditingController();

  // Counselor optional dropdowns
  String? _cCivilStatus = '';
  String? _cSex = '';

  // Counselor info loading
  bool _isCounselorInfoSaving = false;

  // Dropdown values
  String? _loginRole;
  String? _signUpRole;

  // Password visibility
  bool _loginPasswordVisible = false;
  bool _signUpPasswordVisible = false;
  bool _signUpConfirmPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;

  // Terms checkbox
  bool _termsAccepted = false;

  // Verified code for password reset
  String _verifiedResetCode = '';
  String _forgotPasswordIdentifier = '';

  // Getters for state
  bool get showLoginDialog => _showLoginDialog;
  bool get showSignUpDialog => _showSignUpDialog;
  bool get showForgotPasswordDialog => _showForgotPasswordDialog;
  bool get showCodeEntryDialog => _showCodeEntryDialog;
  bool get showNewPasswordDialog => _showNewPasswordDialog;
  bool get showTermsDialog => _showTermsDialog;
  bool get showContactDialog => _showContactDialog;
  bool get showVerificationDialog => _showVerificationDialog;
  bool get showAdminLoginDialog => _showAdminLoginDialog;
  bool get showResendResetCodeDialog => _showResendResetCodeDialog;
  bool get showCounselorInfoDialog => _showCounselorInfoDialog;
  bool get showCounselorPendingDialog => _showCounselorPendingDialog;

  bool get isLoginLoading => _isLoginLoading;
  bool get isSignUpLoading => _isSignUpLoading;
  bool get isForgotPasswordLoading => _isForgotPasswordLoading;
  bool get isCodeEntryLoading => _isCodeEntryLoading;
  bool get isNewPasswordLoading => _isNewPasswordLoading;
  bool get isContactLoading => _isContactLoading;
  bool get isVerificationLoading => _isVerificationLoading;
  bool get isResendVerificationLoading => _isResendVerificationLoading;
  bool get isAdminLoginLoading => _isAdminLoginLoading;
  bool get isResendResetCodeLoading => _isResendResetCodeLoading;
  bool get isForgotPasswordNavigating => _isForgotPasswordNavigating;
  bool get isSignUpNavigating => _isSignUpNavigating;

  String get loginError => _loginError;
  String get signUpError => _signUpError;
  String get forgotPasswordError => _forgotPasswordError;
  String get codeEntryError => _codeEntryError;
  String get newPasswordError => _newPasswordError;
  String get contactError => _contactError;
  String get verificationError => _verificationError;
  String get resendVerificationError => _resendVerificationError;
  String get adminLoginError => _adminLoginError;
  String get resendResetCodeError => _resendResetCodeError;
  String get resendResetCodeInputError => _resendResetCodeInputError;
  String get cInfoWarning => _cInfoWarning;
  String get counselorPendingMessage => _counselorPendingMessage;

  // Individual field error getters
  String get loginUserIdError => _loginUserIdError;
  String get loginPasswordError => _loginPasswordError;
  String get signUpUserIdError => _signUpUserIdError;
  String get signUpUsernameError => _signUpUsernameError;
  String get signUpEmailError => _signUpEmailError;
  String get signUpPasswordError => _signUpPasswordError;
  String get signUpConfirmPasswordError => _signUpConfirmPasswordError;
  String get forgotPasswordInputError => _forgotPasswordInputError;
  String get resetCodeError => _resetCodeError;
  String get newPasswordErrorField => _newPasswordErrorField;
  String get confirmNewPasswordError => _confirmNewPasswordError;

  String get verificationMessage => _verificationMessage;
  bool get showVerificationSuccessDialog => _showVerificationSuccessDialog;
  String get verificationRole => _verificationRole;

  String? get loginRole => _loginRole;
  String? get signUpRole => _signUpRole;
  String? get cCivilStatus => _cCivilStatus;
  String? get cSex => _cSex;

  bool get loginPasswordVisible => _loginPasswordVisible;
  bool get signUpPasswordVisible => _signUpPasswordVisible;
  bool get signUpConfirmPasswordVisible => _signUpConfirmPasswordVisible;
  bool get newPasswordVisible => _newPasswordVisible;
  bool get confirmNewPasswordVisible => _confirmNewPasswordVisible;
  bool get isCounselorInfoSaving => _isCounselorInfoSaving;

  bool get termsAccepted => _termsAccepted;

  // Setters for state
  set loginRole(String? value) {
    // Deprecated: role selection is no longer required for login.
    _loginRole = value;
    notifyListeners();
  }

  set signUpRole(String? value) {
    _signUpRole = value;
    notifyListeners();
  }

  set loginPasswordVisible(bool value) {
    _loginPasswordVisible = value;
    notifyListeners();
  }

  set signUpPasswordVisible(bool value) {
    _signUpPasswordVisible = value;
    notifyListeners();
  }

  set signUpConfirmPasswordVisible(bool value) {
    _signUpConfirmPasswordVisible = value;
    notifyListeners();
  }

  set newPasswordVisible(bool value) {
    _newPasswordVisible = value;
    notifyListeners();
  }

  set confirmNewPasswordVisible(bool value) {
    _confirmNewPasswordVisible = value;
    notifyListeners();
  }

  set termsAccepted(bool value) {
    _termsAccepted = value;
    notifyListeners();
  }

  set cCivilStatus(String? value) {
    _cCivilStatus = value;
    notifyListeners();
  }

  set cSex(String? value) {
    _cSex = value;
    notifyListeners();
  }

  // Initialization
  void initialize() {
    loginUserIdController.addListener(_filterLoginUserId);
    signUpUserIdController.addListener(_filterSignUpUserId);
  }

  @override
  void dispose() {
    loginUserIdController.dispose();
    loginPasswordController.dispose();
    signUpUserIdController.dispose();
    signUpUsernameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    forgotPasswordController.dispose();
    resetCodeController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    contactNameController.dispose();
    contactEmailController.dispose();
    contactSubjectController.dispose();
    contactMessageController.dispose();
    verificationTokenController.dispose();
    resendVerificationController.dispose();
    adminUserIdController.dispose();
    adminPasswordController.dispose();
    cCounselorIdController.dispose();
    cNameController.dispose();
    cDegreeController.dispose();
    cEmailController.dispose();
    cContactController.dispose();
    cAddressController.dispose();
    cBirthdateController.dispose();
    super.dispose();
  }

  void _filterLoginUserId() {
    final current = loginUserIdController.text;
    // Allow email or alphanumeric identifiers without forcing numeric-only input.
    // If the input looks like an email or contains letters, do not filter.
    if (RegExp(r'[A-Za-z@.]').hasMatch(current)) {
      return;
    }

    // If purely numeric flow, keep only digits and limit to 10
    String value = current.replaceAll(RegExp(r'\D'), '');
    if (value.length > 10) {
      value = value.substring(0, 10);
    }
    if (loginUserIdController.text != value) {
      loginUserIdController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  void _filterSignUpUserId() {
    String value = signUpUserIdController.text.replaceAll(RegExp(r'\D'), '');
    if (_signUpRole == 'student') {
      if (value.length > 10) value = value.substring(0, 10);
    }
    if (signUpUserIdController.text != value) {
      signUpUserIdController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  // Dialog management methods
  void setShowLoginDialog(bool value) {
    _showLoginDialog = value;
    notifyListeners();
  }

  void setShowSignUpDialog(bool value) {
    _showSignUpDialog = value;
    notifyListeners();
  }

  void setShowForgotPasswordDialog(bool value) {
    _showForgotPasswordDialog = value;
    notifyListeners();
  }

  void setShowCodeEntryDialog(bool value) {
    _showCodeEntryDialog = value;
    if (value) {
      _codeEntryError = '';
      _resetCodeError = '';
      resetCodeController.clear();
    }
    notifyListeners();
  }

  void setShowNewPasswordDialog(bool value) {
    _showNewPasswordDialog = value;
    notifyListeners();
  }

  void setShowTermsDialog(bool value) {
    _showTermsDialog = value;
    notifyListeners();
  }

  void setShowContactDialog(bool value) {
    _showContactDialog = value;
    notifyListeners();
  }

  void setShowVerificationDialog(
    bool value, {
    String message =
        "A verification email has been sent to your registered email address. Please enter the token below to verify your account.",
    String role = '',
  }) {
    _verificationMessage = message;
    _verificationError = '';
    verificationTokenController.clear();
    _verificationRole = role;
    _log('===== SETTING VERIFICATION DIALOG =====');
    _log('Role received: $role');
    _log('Role stored in _verificationRole: $_verificationRole');
    _showVerificationDialog = value;
    notifyListeners();
  }

  void setShowVerificationSuccessDialog(bool value) {
    _showVerificationSuccessDialog = value;
    notifyListeners();
  }

  void setShowAdminLoginDialog(bool value) {
    _showAdminLoginDialog = value;
    if (value) {
      // Copy user ID from login form to admin form
      adminUserIdController.text = loginUserIdController.text;
      _adminLoginError = '';
    }
    notifyListeners();
  }

  void setShowResendResetCodeDialog(bool value) {
    _showResendResetCodeDialog = value;
    if (value) {
      _resendResetCodeError = '';
      _resendResetCodeInputError = '';
      resendResetCodeController.clear();
    }
    notifyListeners();
  }

  void setShowCounselorInfoDialog(bool value) {
    _showCounselorInfoDialog = value;
    if (!value) {
      _cInfoWarning = '';
    }
    notifyListeners();
  }

  void setShowCounselorPendingDialog(bool value, {String message = ''}) {
    _showCounselorPendingDialog = value;
    _counselorPendingMessage = message;
    notifyListeners();
  }

  void hideAllDialogs() {
    _showLoginDialog = false;
    _showSignUpDialog = false;
    _showForgotPasswordDialog = false;
    _showCodeEntryDialog = false;
    _showNewPasswordDialog = false;
    _showTermsDialog = false;
    _showContactDialog = false;
    _showVerificationDialog = false;
    _showVerificationSuccessDialog = false;
    _showAdminLoginDialog = false;
    _showResendResetCodeDialog = false;
    notifyListeners();
  }

  // Navigation methods
  void navigateToServices(BuildContext context) {
    AppRoutes.navigateToServices(context);
  }

  void navigateToDashboard(BuildContext context) {
    AppRoutes.navigateToDashboard(context);
  }

  // Helper methods to safely handle context operations
  void _safePop(BuildContext context) {
    AppRoutes.safePop(context);
  }

  void _showSnackBar(BuildContext context, String message) {
    AppRoutes.showSnackBar(context, message);
  }

  void _log(String message) {
    // Replace with your preferred logging solution
    // For now, using debugPrint which is safe for production
    debugPrint(message);
  }

  // API methods
  Future<void> handleLogin(BuildContext context) async {
    _loginError = '';
    _loginUserIdError = '';
    _loginPasswordError = '';
    _isLoginLoading = true;
    _log('🔄 Setting login loading to true');
    notifyListeners();

    String userId = loginUserIdController.text.trim();
    String password = loginPasswordController.text.trim();

    // Validate identifier (email or 10-digit user ID)
    final userIdError = InputValidator.validateIdentifier(userId);
    final passwordError = InputValidator.validatePassword(password);

    bool isValid = true;
    if (userIdError != null) {
      _loginUserIdError = userIdError;
      isValid = false;
    }

    if (passwordError != null) {
      _loginPasswordError = passwordError;
      isValid = false;
    }

    if (!isValid) {
      // Add a longer delay to show loading state before showing error
      _log('❌ Validation failed, waiting 1000ms before hiding loading');
      await Future.delayed(const Duration(milliseconds: 1000));
      _isLoginLoading = false;
      _log('🔄 Setting login loading to false after validation failure');
      notifyListeners();
      return;
    }

    try {
      SecureLogger.debug('Starting login');
      SecureLogger.logRequest(
        'POST',
        '${ApiConfig.currentBaseUrl}/auth/login',
        {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Requested-With': 'XMLHttpRequest',
        },
        {'identifier': userId, 'password': password},
      );

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/auth/login',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: {'identifier': userId, 'password': password}.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&'),
      );

      SecureLogger.logResponse(
        response.statusCode,
        response.headers,
        response.body,
      );

      if (response.statusCode != 200) {
        _loginError =
            'Server error (${response.statusCode}). Please try again.';
        return;
      }

      final data = json.decode(response.body);
      final status = data['status'];
      final message = data['message'];
      // Role will be determined by the backend response/redirect
      String resolvedRole = '';

      if (status == 'success') {
        // Try to resolve role from response
        if (data.containsKey('role')) {
          resolvedRole = (data['role'] ?? '').toString().toLowerCase();
        } else if (data.containsKey('redirect')) {
          final redirect = (data['redirect'] ?? '').toString();
          if (redirect.contains('/admin/')) {
            resolvedRole = 'admin';
          } else if (redirect.contains('/counselor/')) {
            resolvedRole = 'counselor';
          } else if (redirect.contains('/student/')) {
            resolvedRole = 'student';
          }
        }

        SecureLogger.success(
          'Login successful. Resolved role: ${resolvedRole.isEmpty ? 'unknown' : resolvedRole}',
        );

        // Store user data securely (userId may be email; backend session holds canonical id)
        await SecureStorage.storeUserId(userId);
        if (resolvedRole.isNotEmpty) {
          await SecureStorage.storeUserRole(resolvedRole);
        }
        await SecureStorage.storeLastLogin(DateTime.now());

        if (context.mounted) {
          _safePop(context);
          _showSnackBar(context, 'Login successful!');
          final role = resolvedRole;
          if (role == 'student') {
            navigateToDashboard(context);
          } else if (role == 'counselor') {
            AppRoutes.navigateToCounselorDashboard(context);
          } else if (role == 'admin') {
            AppRoutes.navigateToAdminDashboard(context);
          } else {
            // default to user dashboard if role ambiguous
            SecureLogger.warning(
              'Unknown role "${role.isEmpty ? 'unset' : role}". Defaulting to user dashboard.',
            );
            navigateToDashboard(context);
          }
        }
      } else if (status == 'unverified') {
        SecureLogger.warning('Account unverified');
        if (context.mounted) {
          _safePop(context);
          final msg = (message ?? '').toString();
          final isCounselorUnverified =
              msg.toLowerCase().contains('counselor') ||
              msg.toLowerCase().contains('admin approval');
          if (isCounselorUnverified) {
            setShowCounselorPendingDialog(true, message: msg);
          } else {
            setShowVerificationDialog(
              true,
              message: msg.isNotEmpty
                  ? msg
                  : 'Your account is not verified. Please enter the token to verify your account or resend the verification email.',
              role: resolvedRole.isNotEmpty ? resolvedRole : 'student',
            );
          }
        }
      } else {
        SecureLogger.error('Login failed: ${message ?? 'Unknown error'}');
        _loginError =
            message ??
            'Invalid credentials. Please check your User ID/Email and password.';
      }
    } catch (e) {
      SecureLogger.error('Login Error', e);
      _loginError =
          'Network error. Please check your connection and try again.';
    } finally {
      _isLoginLoading = false;
      notifyListeners();
    }
  }

  // Admin login method
  Future<void> handleAdminLogin(BuildContext context) async {
    _adminLoginError = '';
    _isAdminLoginLoading = true;
    notifyListeners();

    String adminUserId = adminUserIdController.text.trim();
    String adminPassword = adminPasswordController.text.trim();

    bool isValid = true;
    if (adminUserId.isEmpty) {
      _adminLoginError = 'Please enter your Admin ID.';
      isValid = false;
    }

    if (adminPassword.isEmpty) {
      _adminLoginError = 'Please enter your password.';
      isValid = false;
    }

    if (!isValid) {
      _isAdminLoginLoading = false;
      notifyListeners();
      return;
    }

    try {
      _log('🔐 Starting admin login for adminId=$adminUserId');
      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/auth/verify-admin',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: {
          'user_id': adminUserId,
          'password': adminPassword,
        }.entries.map((e) => '${e.key}=${e.value}').join('&'),
      );

      _log('✅ Admin Login Response Status: ${response.statusCode}');
      _log('📨 Admin Login Response Body: ${response.body}');

      if (response.statusCode != 200) {
        _adminLoginError =
            'Server error (${response.statusCode}). Please try again.';
        return;
      }

      final data = json.decode(response.body);
      final status = data['status'];
      final message = data['message'];

      if (status == 'success') {
        _log('🎉 Admin login success');
        if (context.mounted) {
          _safePop(context);
          _showSnackBar(context, 'Admin login successful!');
          AppRoutes.navigateToAdminDashboard(context);
        }
      } else if (status == 'unverified') {
        _log('⚠️ Admin account unverified for adminId=$adminUserId');
        if (context.mounted) {
          _safePop(context);
          setShowVerificationDialog(
            true,
            message:
                message ??
                'Your admin account is not verified. Please enter the token to verify your account or resend the verification email.',
            role: 'admin',
          );
        }
      } else {
        _log('❌ Admin login failed: ${message ?? 'Unknown error'}');
        _adminLoginError = message ?? 'Invalid Admin ID or password.';
      }
    } catch (e) {
      _log('💥 Admin Login Error: $e');
      _adminLoginError =
          'Network error. Please check your connection and try again.';
    } finally {
      _isAdminLoginLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleSignUp(BuildContext context) async {
    _signUpError = '';
    _signUpUserIdError = '';
    _signUpUsernameError = '';
    _signUpEmailError = '';
    _signUpPasswordError = '';
    _signUpConfirmPasswordError = '';
    _isSignUpLoading = true;
    notifyListeners();

    String userId = signUpUserIdController.text.trim();
    String username = signUpUsernameController.text.trim();
    String email = signUpEmailController.text.trim();
    String password = signUpPasswordController.text.trim();
    String confirmPassword = signUpConfirmPasswordController.text.trim();

    bool isValid = true;
    if (userId.isEmpty) {
      _signUpUserIdError = 'Please enter your User ID.';
      isValid = false;
    } else if (_signUpRole == 'student' &&
        !RegExp(r'^\d{10}$').hasMatch(userId)) {
      _signUpUserIdError = 'User ID must be exactly 10 digits.';
      isValid = false;
    }

    if (username.isEmpty) {
      _signUpUsernameError = 'Please enter your username.';
      isValid = false;
    }

    if (email.isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _signUpEmailError = 'Please enter a valid email.';
      isValid = false;
    }

    if (password.isEmpty || password.length < 8) {
      _signUpPasswordError = 'Password must be at least 8 characters.';
      isValid = false;
    }

    if (password != confirmPassword) {
      _signUpConfirmPasswordError = 'Passwords do not match.';
      isValid = false;
    }

    if (!_termsAccepted) {
      _signUpError = 'Please agree to the Terms and Conditions.';
      isValid = false;
    }

    if (!isValid) {
      // Add a longer delay to show loading state before showing error
      await Future.delayed(const Duration(milliseconds: 1000));
      _isSignUpLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/auth/signup',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: {
          'role': _signUpRole ?? 'student',
          'userId': userId,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'username': username,
        }.entries.map((e) => '${e.key}=${e.value}').join('&'),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        signUpUserIdController.clear();
        signUpUsernameController.clear();
        signUpEmailController.clear();
        signUpPasswordController.clear();
        signUpConfirmPasswordController.clear();
        _termsAccepted = false;

        if (context.mounted) {
          _safePop(context);
          if ((_signUpRole ?? 'student') == 'counselor') {
            cCounselorIdController.text = userId;
            cEmailController.text = email;
            setShowCounselorInfoDialog(true);
          } else {
            setShowVerificationDialog(
              true,
              message:
                  data['message'] ??
                  'A verification email has been sent to your registered email address. Please enter the token below to verify your account.',
              role: 'student',
            );
          }
        }
      } else {
        _signUpError = data['message'] ?? 'Sign up failed.';
      }
    } catch (e) {
      _signUpError = 'An error occurred. Please try again.';
    } finally {
      _isSignUpLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleForgotPassword(BuildContext context) async {
    _forgotPasswordError = '';
    _forgotPasswordInputError = '';
    _isForgotPasswordLoading = true;
    notifyListeners();

    String input = forgotPasswordController.text.trim();

    if (input.isEmpty) {
      _forgotPasswordInputError = 'Please enter your email or user ID.';
      // Add a longer delay to show loading state before showing error
      await Future.delayed(const Duration(milliseconds: 1000));
      _isForgotPasswordLoading = false;
      notifyListeners();
      return;
    }

    try {
      _log('🚀 Starting forgot password for: $input');
      _forgotPasswordIdentifier = input;

      _session.clearCookies();

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/forgot-password/send-code',
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode({'input': input}),
      );

      _log('✅ Forgot Password Response Status: ${response.statusCode}');
      _log('📨 Forgot Password Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _log('🎉 Reset code sent successfully');
          _log('🍪 Session after send-code: ${_session.cookies}');

          forgotPasswordController.clear();
          if (context.mounted) {
            _safePop(context);
            setShowCodeEntryDialog(true);
            _showSnackBar(context, 'Reset code sent! Check your email.');
          }
        } else {
          _log('❌ Backend error: ${data['message']}');
          _forgotPasswordError =
              data['message'] ?? 'Failed to send reset code.';
        }
      } else {
        _log('❌ HTTP Error: ${response.statusCode}');
        _forgotPasswordError =
            'Server error (${response.statusCode}). Please try again.';
      }
    } catch (e) {
      _log('💥 Forgot Password Error: $e');
      _forgotPasswordError = 'An error occurred. Please try again.';
    } finally {
      _log('🏁 Forgot Password process completed');
      _isForgotPasswordLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleResendResetCode(BuildContext context) async {
    _resendResetCodeError = '';
    _resendResetCodeInputError = '';
    _isResendResetCodeLoading = true;
    notifyListeners();

    String input = resendResetCodeController.text.trim();

    if (input.isEmpty) {
      _resendResetCodeInputError = 'Please enter your email or user ID.';
      await Future.delayed(const Duration(milliseconds: 1000));
      _isResendResetCodeLoading = false;
      notifyListeners();
      return;
    }

    try {
      _log('🚀 Starting resend reset code for: $input');

      _session.clearCookies();

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/forgot-password/send-code',
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode({'input': input}),
      );

      _log('✅ Resend Reset Code Response Status: ${response.statusCode}');
      _log('📨 Resend Reset Code Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _log('🎉 Reset code resent successfully');

          resendResetCodeController.clear();
          if (context.mounted) {
            _safePop(context);
            _showSnackBar(
              context,
              'A new reset code has been sent to your email. It will expire in 5 minutes.',
            );
            // Open code entry dialog after successful resend
            setShowCodeEntryDialog(true);
          }
        } else {
          _resendResetCodeError =
              data['message'] ?? 'Failed to resend reset code.';
        }
      } else {
        _resendResetCodeError = 'Server error. Please try again.';
      }
    } catch (e) {
      _log('❌ Resend Reset Code Error: $e');
      _resendResetCodeError = 'An error occurred. Please try again.';
    } finally {
      _log('🏁 Resend Reset Code process completed');
      _isResendResetCodeLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleVerifyCode(BuildContext context) async {
    _codeEntryError = '';
    _resetCodeError = '';
    _isCodeEntryLoading = true;
    notifyListeners();

    String code = resetCodeController.text.trim();

    if (code.isEmpty) {
      _resetCodeError = 'Please enter the reset code.';
      // Add a longer delay to show loading state before showing error
      await Future.delayed(const Duration(milliseconds: 1000));
      _isCodeEntryLoading = false;
      notifyListeners();
      return;
    }

    try {
      _log('🔐 Verifying code: $code');
      _log('🍪 Session before verify-code: ${_session.cookies}');

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/forgot-password/verify-code',
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode({'code': code}),
      );

      _log('✅ Verify Code Response Status: ${response.statusCode}');
      _log('📨 Verify Code Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _log('🎉 Code verified successfully');
          _log('🍪 Session after verify-code: ${_session.cookies}');
          _log('🍪 Has session: ${_session.hasSession}');

          _verifiedResetCode = code;
          resetCodeController.clear();
          if (context.mounted) {
            _safePop(context);
            setShowNewPasswordDialog(true);
            _showSnackBar(context, 'Code verified! Set your new password.');
          }
        } else {
          _log('❌ Code verification failed: ${data['message']}');
          _codeEntryError = data['message'] ?? 'Invalid code.';
        }
      } else {
        _log('❌ HTTP Error: ${response.statusCode}');
        _codeEntryError =
            'Server error (${response.statusCode}). Please try again.';
      }
    } catch (e) {
      _log('💥 Verify Code Error: $e');
      _codeEntryError = 'An error occurred. Please try again.';
    } finally {
      _log('🏁 Code verification process completed');
      _isCodeEntryLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleSetNewPassword(BuildContext context) async {
    _newPasswordError = '';
    _newPasswordErrorField = '';
    _confirmNewPasswordError = '';
    _isNewPasswordLoading = true;
    notifyListeners();

    String password = newPasswordController.text.trim();
    String confirmPassword = confirmNewPasswordController.text.trim();

    bool isValid = true;
    if (password.isEmpty || password.length < 8) {
      _newPasswordErrorField = 'Password must be at least 8 characters.';
      isValid = false;
    }

    if (password != confirmPassword) {
      _confirmNewPasswordError = 'Passwords do not match.';
      isValid = false;
    }

    if (!isValid) {
      // Add a longer delay to show loading state before showing error
      await Future.delayed(const Duration(milliseconds: 1000));
      _isNewPasswordLoading = false;
      notifyListeners();
      return;
    }

    try {
      _log('🔑 Setting new password');
      _log('🍪 Session before set-password: ${_session.cookies}');
      _log('🍪 Has active session: ${_session.hasSession}');

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/forgot-password/set-password',
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode({
          'password': password,
          'code': _verifiedResetCode,
          'input': _forgotPasswordIdentifier,
        }),
      );

      _log('✅ Set Password Response Status: ${response.statusCode}');
      _log('📨 Set Password Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _log('🎉 Password reset successfully');

          newPasswordController.clear();
          confirmNewPasswordController.clear();
          _verifiedResetCode = '';
          _forgotPasswordIdentifier = '';

          _session.clearCookies();

          if (context.mounted) {
            _safePop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Success'),
                content: const Text(
                  'Password reset successful! You can now log in with your new password.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => _safePop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          _log('❌ Password reset failed: ${data['message']}');
          _newPasswordError = data['message'] ?? 'Failed to reset password.';

          if (data['message']?.toLowerCase().contains('session expired') ==
              true) {
            _session.clearCookies();
            _newPasswordError =
                'Session expired. Please start the reset process again.';
          }
        }
      } else {
        _log('❌ HTTP Error: ${response.statusCode}');
        _newPasswordError =
            'Server error (${response.statusCode}). Please try again.';
      }
    } catch (e) {
      _log('💥 Set Password Error: $e');
      _newPasswordError = 'An error occurred. Please try again.';
    } finally {
      _log('🏁 Password reset process completed');
      _isNewPasswordLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleContact(BuildContext context) async {
    _contactError = '';
    _isContactLoading = true;
    notifyListeners();

    String name = contactNameController.text.trim();
    String email = contactEmailController.text.trim();
    String subject = contactSubjectController.text.trim();
    String message = contactMessageController.text.trim();

    bool isValid = true;
    if (name.isEmpty) {
      _contactError = 'Please enter your name.';
      isValid = false;
    }

    if (email.isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _contactError = 'Please enter a valid email.';
      isValid = false;
    }

    if (subject.isEmpty) {
      _contactError = 'Please enter a subject.';
      isValid = false;
    }

    if (message.isEmpty) {
      _contactError = 'Please enter a message.';
      isValid = false;
    }

    if (!isValid) {
      // Add a longer delay to show loading state before showing error
      await Future.delayed(const Duration(milliseconds: 1000));
      _isContactLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}/email/sendContactEmail'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: {
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        },
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        contactNameController.clear();
        contactEmailController.clear();
        contactSubjectController.clear();
        contactMessageController.clear();
        if (context.mounted) {
          _safePop(context);
          _showSnackBar(
            context,
            data['message'] ?? 'Message sent successfully!',
          );
        }
      } else {
        _contactError = data['message'] ?? 'Failed to send message.';
      }
    } catch (e) {
      _contactError = 'An error occurred. Please try again.';
    } finally {
      _isContactLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleVerification(BuildContext context) async {
    _verificationError = '';
    _isVerificationLoading = true;
    notifyListeners();

    String token = verificationTokenController.text.trim().toUpperCase();

    if (token.isEmpty) {
      _verificationError = 'Please enter the verification token.';
      _isVerificationLoading = false;
      notifyListeners();
      return;
    }

    // Validate token: must be 6 characters, uppercase letters and/or numbers
    final tokenRegex = RegExp(r'^[A-Z0-9]{6}$');
    if (!tokenRegex.hasMatch(token)) {
      _verificationError = 'Invalid token. Enter 6 characters (A-Z, 0-9).';
      _isVerificationLoading = false;
      notifyListeners();
      return;
    }

    try {
      _log('Sending verification request for token: $token');

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/verify-account',
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode({'token': token}),
      );

      _log('Verification Response Status: ${response.statusCode}');
      _log('Verification Response Body: ${response.body}');

      final data = json.decode(response.body);

      _log('=== VERIFICATION RESPONSE DEBUG ===');
      _log('Response status code: ${response.statusCode}');
      _log('Response body: ${response.body}');
      _log('Parsed data: $data');

      if (response.statusCode == 200) {
        if (data['status'] == 'success') {
          _log('Before role check - _verificationRole: $_verificationRole');
          _log('SignUpRole: $_signUpRole');

          // Check for role in various possible locations
          if (data.containsKey('role')) {
            _verificationRole = data['role'];
            _log('✓ Role found in data[\'role\']: $_verificationRole');
          } else if (data.containsKey('user_role')) {
            _verificationRole = data['user_role'];
            _log('✓ Role found in data[\'user_role\']: $_verificationRole');
          } else if (data.containsKey('redirect')) {
            // Extract role from redirect URL if role not explicitly provided
            final redirectUrl = data['redirect'] as String;
            _log('Extracting role from redirect URL: $redirectUrl');

            if (redirectUrl.contains('/counselor/')) {
              _verificationRole = 'counselor';
              _log('✓ Role extracted from redirect URL: counselor');
            } else if (redirectUrl.contains('/admin/')) {
              _verificationRole = 'admin';
              _log('✓ Role extracted from redirect URL: admin');
            } else if (redirectUrl.contains('/student/')) {
              _verificationRole = 'student';
              _log('✓ Role extracted from redirect URL: student');
            }
          }

          // Last resort: use signup role if still not set
          if (_verificationRole.isEmpty && _signUpRole != null) {
            _verificationRole = _signUpRole ?? 'student';
            _log('✓ Using signup role as fallback: $_verificationRole');
          }

          if (_verificationRole.isEmpty) {
            _log('⚠️ No role found in response data or signup');
          }

          _log('After role check - _verificationRole: $_verificationRole');

          // Store the role securely for session management
          if (_verificationRole.isNotEmpty) {
            SecureStorage.storeUserRole(_verificationRole);
            _log('✓ Role stored in secure storage: $_verificationRole');
          }

          if (context.mounted) {
            _safePop(context);
            setShowVerificationSuccessDialog(true);
          }
        } else {
          _verificationError = data['message'] ?? 'Verification failed.';
        }
      } else {
        if (response.statusCode == 400) {
          _verificationError = data['message'] ?? 'Invalid token.';
        } else if (response.statusCode == 404) {
          _verificationError =
              'Service temporarily unavailable. Please try again later.';
        } else {
          _verificationError =
              data['message'] ?? 'Verification failed. Please try again.';
        }
      }
    } catch (e) {
      _log('Verification Error: $e');
      _verificationError =
          'Network error. Please check your connection and try again.';
    } finally {
      _isVerificationLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleResendVerification(BuildContext context) async {
    _verificationError = '';
    _resendVerificationError = '';
    // Don't set loading to true here - only when submit button is clicked
    notifyListeners();

    String identifier = signUpEmailController.text.trim();

    if (identifier.isEmpty) {
      // Show the new resend verification dialog
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => buildResendVerificationDialog(
          context: context,
          identifierController: resendVerificationController,
          error: _resendVerificationError,
          isLoading: _isResendVerificationLoading,
          onResendPressed: () async {
            final inputIdentifier = resendVerificationController.text.trim();
            if (inputIdentifier.isEmpty) {
              _resendVerificationError = 'Please enter your email or user ID';
              notifyListeners();
              return;
            }

            // Start the resend process
            _isResendVerificationLoading = true;
            _resendVerificationError = '';
            notifyListeners();

            try {
              _log('Resending verification for identifier: $inputIdentifier');

              final response = await _session.post(
                '${ApiConfig.currentBaseUrl}/resend-verification-email',
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded',
                  'X-Requested-With': 'XMLHttpRequest',
                },
                body: 'identifier=$inputIdentifier',
              );

              _log('Resend Verification Response: ${response.statusCode}');
              _log('Resend Verification Body: ${response.body}');

              final data = json.decode(response.body);

              if (response.statusCode == 200) {
                if (data['status'] == 'success') {
                  _verificationMessage =
                      data['message'] ??
                      'Verification email sent successfully. Please check your inbox.';
                  if (context.mounted) {
                    _showSnackBar(
                      context,
                      data['message'] ??
                          'Verification email sent successfully.',
                    );
                    // Reset loading state before closing modal
                    _isResendVerificationLoading = false;
                    notifyListeners();
                    Navigator.pop(context, inputIdentifier);
                  }
                } else if (data['status'] == 'already_verified') {
                  _verificationMessage =
                      data['message'] ?? 'Account is already verified.';
                  if (context.mounted) {
                    _showSnackBar(
                      context,
                      data['message'] ?? 'Account is already verified.',
                    );
                    // Reset loading state before closing modal
                    _isResendVerificationLoading = false;
                    notifyListeners();
                    Navigator.pop(context, inputIdentifier);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (context.mounted) {
                        _safePop(context);
                        setShowLoginDialog(true);
                      }
                    });
                  }
                } else {
                  _resendVerificationError =
                      data['message'] ?? 'Failed to resend verification email.';
                  // Reset loading state on error
                  _isResendVerificationLoading = false;
                  notifyListeners();
                }
              } else {
                _resendVerificationError =
                    data['message'] ?? 'Failed to resend verification email.';
                // Reset loading state on error
                _isResendVerificationLoading = false;
                notifyListeners();
              }
            } catch (e) {
              _log('Resend Verification Error: $e');
              _resendVerificationError = 'Network error. Please try again.';
              // Reset loading state on error
              _isResendVerificationLoading = false;
              notifyListeners();
            }
          },
          onCancelPressed: () {
            // Reset loading state when canceling
            _isResendVerificationLoading = false;
            notifyListeners();
            Navigator.pop(context);
          },
        ),
      );

      if (result == null || result.isEmpty) {
        _isResendVerificationLoading = false;
        notifyListeners();
        return;
      }
      identifier = result;
    }

    // If we have an identifier from signup form, process it directly
    if (identifier.isNotEmpty) {
      try {
        _log('Resending verification for identifier: $identifier');

        final response = await _session.post(
          '${ApiConfig.currentBaseUrl}/resend-verification-email',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest',
          },
          body: 'identifier=$identifier',
        );

        _log('Resend Verification Response: ${response.statusCode}');
        _log('Resend Verification Body: ${response.body}');

        final data = json.decode(response.body);

        if (response.statusCode == 200) {
          if (data['status'] == 'success') {
            _verificationMessage =
                data['message'] ??
                'Verification email sent successfully. Please check your inbox.';
            if (context.mounted) {
              _showSnackBar(
                context,
                data['message'] ?? 'Verification email sent successfully.',
              );
            }
          } else if (data['status'] == 'already_verified') {
            _verificationMessage =
                data['message'] ?? 'Account is already verified.';
            if (context.mounted) {
              _showSnackBar(
                context,
                data['message'] ?? 'Account is already verified.',
              );
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  _safePop(context);
                  setShowLoginDialog(true);
                }
              });
            }
          } else {
            _verificationError =
                data['message'] ?? 'Failed to resend verification email.';
          }
        } else {
          _verificationError =
              data['message'] ?? 'Failed to resend verification email.';
        }
      } catch (e) {
        _log('Resend Verification Error: $e');
        _verificationError = 'Network error. Please try again.';
      }
    }

    _isResendVerificationLoading = false;
    notifyListeners();
  }

  void goToDashboard(BuildContext context) {
    if (context.mounted) {
      _safePop(context);
      _showSnackBar(
        context,
        'Verification successful! Welcome to your dashboard.',
      );

      // Get the role from verification
      final role = _verificationRole.isEmpty
          ? 'student'
          : _verificationRole.toLowerCase();

      _log('=== VERIFICATION REDIRECT DEBUG ===');
      _log('Verification role before cleanup: $_verificationRole');
      _log('Role after cleanup: $role');

      // Navigate based on role, exactly like login does
      if (role == 'student') {
        _log('Redirecting to STUDENT dashboard');
        navigateToDashboard(context);
      } else if (role == 'counselor') {
        _log('Redirecting to COUNSELOR dashboard');
        AppRoutes.navigateToCounselorDashboard(context);
      } else if (role == 'admin') {
        _log('Redirecting to ADMIN dashboard');
        AppRoutes.navigateToAdminDashboard(context);
      } else {
        // Default to student dashboard if role is ambiguous
        _log(
          '⚠️ Unknown verification role "$role". Defaulting to student dashboard.',
        );
        SecureLogger.warning(
          'Unknown verification role "$role". Defaulting to student dashboard.',
        );
        navigateToDashboard(context);
      }
    }
  }

  void stayOnLandingPage(BuildContext context) {
    if (context.mounted) {
      _safePop(context);
    }
  }

  Future<void> handleSaveCounselorInfo(BuildContext context) async {
    _cInfoWarning = '';
    _isCounselorInfoSaving = true;
    notifyListeners();

    final counselorId = cCounselorIdController.text.trim();
    final name = cNameController.text.trim();
    final degree = cDegreeController.text.trim();
    final email = cEmailController.text.trim();
    final contact = cContactController.text.trim();
    final address = cAddressController.text.trim();
    final civil = (_cCivilStatus ?? '').trim();
    final s = (_cSex ?? '').trim();
    final birthdate = cBirthdateController.text.trim();

    if (counselorId.isEmpty ||
        name.isEmpty ||
        degree.isEmpty ||
        email.isEmpty ||
        contact.isEmpty ||
        address.isEmpty) {
      _cInfoWarning = 'Please fill in all required fields.';
      _isCounselorInfoSaving = false;
      notifyListeners();
      return;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _cInfoWarning = 'Please enter a valid email address.';
      _isCounselorInfoSaving = false;
      notifyListeners();
      return;
    }

    if (!RegExp(r'^09[0-9]{9}$').hasMatch(contact)) {
      _cInfoWarning = 'Contact number must be in the format 09XXXXXXXXX.';
      _isCounselorInfoSaving = false;
      notifyListeners();
      return;
    }

    try {
      final payload = {
        'counselor_id': counselorId,
        'name': name,
        'degree': degree,
        'email': email,
        'contact_number': contact,
        'address': address,
        if (civil.isNotEmpty) 'civil_status': civil,
        if (s.isNotEmpty) 'sex': s,
        if (birthdate.isNotEmpty) 'birthdate': birthdate,
      };

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/counselor/save-basic-info',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: payload.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&'),
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        cNameController.clear();
        cDegreeController.clear();
        cContactController.clear();
        cAddressController.clear();
        cBirthdateController.clear();
        _cCivilStatus = '';
        _cSex = '';
        if (context.mounted) {
          _safePop(context);
          _showSnackBar(
            context,
            'Your information has been saved. Please wait for admin approval.',
          );
        }
      } else {
        _cInfoWarning = (data['message'] ?? 'Failed to save information.')
            .toString();
      }
    } catch (e) {
      _cInfoWarning = 'An error occurred. Please try again.';
    } finally {
      _isCounselorInfoSaving = false;
      notifyListeners();
    }
  }
}
