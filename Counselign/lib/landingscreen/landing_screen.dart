import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Dialog imports
import 'dialogs/login_dialog.dart';
import 'dialogs/admin_login_dialog.dart';
import 'dialogs/signup_dialog.dart';
import 'dialogs/forgot_password_dialog.dart';
import 'dialogs/code_entry_dialog.dart';
import 'dialogs/new_password_dialog.dart';
import 'dialogs/terms_dialog.dart';
import 'dialogs/contact_dialog.dart';
import 'dialogs/verification_dialog.dart';
import 'dialogs/verification_success_dialog.dart';
import 'dialogs/resend_reset_code_dialog.dart';
import 'dialogs/counselor_info_dialog.dart';
import 'dialogs/counselor_pending_dialog.dart';

// Frontend imports
import 'frontend/app_bar.dart';
import 'frontend/drawer.dart';
import 'frontend/body.dart';

// State management
import 'state/landing_screen_viewmodel.dart';

// Session validation
import '../utils/session_validator.dart';
import '../routes.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late LandingScreenViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LandingScreenViewModel();
    _viewModel.initialize();
    _viewModel.addListener(_onViewModelChanged);
    // Check session on mobile platforms, otherwise show login dialog
    _checkSessionAndNavigate();
  }

  /// Check session validity on mobile platforms and navigate to dashboard if valid
  Future<void> _checkSessionAndNavigate() async {
    // Only check session on mobile platforms
    if (!SessionValidator.isMobile) {
      // On web/desktop, show login dialog as normal
      _viewModel.setShowLoginDialog(true);
      return;
    }

    try {
      // Validate session with backend
      final sessionResult = await SessionValidator.validateSession();

      // Check if widget is still mounted before using context
      if (!mounted) {
        return;
      }

      if (sessionResult['valid'] == true) {
        final role = sessionResult['role'] as String?;
        if (role != null) {
          // Navigate to appropriate dashboard based on role
          if (role.toLowerCase() == 'student') {
            AppRoutes.navigateToDashboard(context);
          } else if (role.toLowerCase() == 'counselor') {
            AppRoutes.navigateToCounselorDashboard(context);
          } else if (role.toLowerCase() == 'admin') {
            AppRoutes.navigateToAdminDashboard(context);
          } else {
            // Unknown role, show login dialog
            _viewModel.setShowLoginDialog(true);
          }
          return;
        }
      }

      // Session invalid or expired, show login dialog
      _viewModel.setShowLoginDialog(true);
    } catch (e) {
      // Error during session check, show login dialog
      if (mounted) {
        _viewModel.setShowLoginDialog(true);
      }
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _showDialogIfNeeded() {
    if (_viewModel.showLoginDialog) {
      _showLoginDialog();
      _viewModel.setShowLoginDialog(false);
    }
    if (_viewModel.showSignUpDialog) {
      _showSignUpDialog();
      _viewModel.setShowSignUpDialog(false);
    }
    if (_viewModel.showForgotPasswordDialog) {
      _showForgotPasswordDialog();
      _viewModel.setShowForgotPasswordDialog(false);
    }
    if (_viewModel.showCodeEntryDialog) {
      _showCodeEntryDialog();
      _viewModel.setShowCodeEntryDialog(false);
    }
    if (_viewModel.showNewPasswordDialog) {
      _showNewPasswordDialog();
      _viewModel.setShowNewPasswordDialog(false);
    }
    if (_viewModel.showTermsDialog) {
      _showTermsDialog();
      _viewModel.setShowTermsDialog(false);
    }
    if (_viewModel.showContactDialog) {
      _showContactDialog();
      _viewModel.setShowContactDialog(false);
    }
    if (_viewModel.showVerificationDialog) {
      _showVerificationDialog();
      _viewModel.setShowVerificationDialog(false);
    }
    if (_viewModel.showVerificationSuccessDialog) {
      _showVerificationSuccessDialog();
      _viewModel.setShowVerificationSuccessDialog(false);
    }
    if (_viewModel.showAdminLoginDialog) {
      _showAdminLoginDialog();
      _viewModel.setShowAdminLoginDialog(false);
    }
    if (_viewModel.showResendResetCodeDialog) {
      _showResendResetCodeDialog();
      _viewModel.setShowResendResetCodeDialog(false);
    }
    if (_viewModel.showCounselorInfoDialog) {
      _showCounselorInfoDialog();
      _viewModel.setShowCounselorInfoDialog(false);
    }
    if (_viewModel.showCounselorPendingDialog) {
      _showCounselorPendingDialog();
      _viewModel.setShowCounselorPendingDialog(false);
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => LoginDialog(
            userIdController: viewModel.loginUserIdController,
            passwordController: viewModel.loginPasswordController,
            error: viewModel.loginError,
            userIdError: viewModel.loginUserIdError,
            passwordError: viewModel.loginPasswordError,
            isLoading: viewModel.isLoginLoading,
            isForgotPasswordNavigating: viewModel.isForgotPasswordNavigating,
            isSignUpNavigating: viewModel.isSignUpNavigating,
            onForgotPasswordPressed: () {
              viewModel.setShowForgotPasswordDialog(true);
              final navigator = Navigator.of(context);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!mounted) return;
                navigator.pop();
                viewModel.setShowForgotPasswordDialog(true);
              });
            },
            onSignUpPressed: () {
              viewModel.setShowSignUpDialog(true);
              final navigator = Navigator.of(context);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!mounted) return;
                navigator.pop();
                viewModel.setShowSignUpDialog(true);
              });
            },
            onLoginPressed: () => viewModel.handleLogin(context),
            onAdminLoginPressed: () {
              Navigator.pop(context);
              viewModel.setShowAdminLoginDialog(true);
            },
          ),
        ),
      ),
    );
  }

  void _showAdminLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => AdminLoginDialog(
            adminUserIdController: viewModel.adminUserIdController,
            adminPasswordController: viewModel.adminPasswordController,
            error: viewModel.adminLoginError,
            isLoading: viewModel.isAdminLoginLoading,
            onAdminLoginPressed: () => viewModel.handleAdminLogin(context),
            onBackToLoginPressed: () {
              Navigator.pop(context);
              viewModel.setShowLoginDialog(true);
            },
          ),
        ),
      ),
    );
  }

  void _showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => SignUpDialog(
            userIdController: viewModel.signUpUserIdController,
            usernameController: viewModel.signUpUsernameController,
            emailController: viewModel.signUpEmailController,
            passwordController: viewModel.signUpPasswordController,
            confirmPasswordController:
                viewModel.signUpConfirmPasswordController,
            role: viewModel.signUpRole,
            onRoleChanged: (value) => viewModel.signUpRole = value,
            error: viewModel.signUpError,
            userIdError: viewModel.signUpUserIdError,
            usernameError: viewModel.signUpUsernameError,
            emailError: viewModel.signUpEmailError,
            passwordError: viewModel.signUpPasswordError,
            confirmPasswordError: viewModel.signUpConfirmPasswordError,
            isLoading: viewModel.isSignUpLoading,
            termsAccepted: viewModel.termsAccepted,
            onTermsChanged: (value) => viewModel.termsAccepted = value,
            onTermsPressed: () {
              Navigator.pop(context);
              viewModel.setShowTermsDialog(true);
            },
            onSignUpPressed: () => viewModel.handleSignUp(context),
            onBackToLoginPressed: () {
              Navigator.pop(context);
              viewModel.setShowLoginDialog(true);
            },
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => buildForgotPasswordDialog(
            context: context,
            controller: viewModel.forgotPasswordController,
            error: viewModel.forgotPasswordError,
            inputError: viewModel.forgotPasswordInputError,
            isLoading: viewModel.isForgotPasswordLoading,
            onSendCodePressed: () => viewModel.handleForgotPassword(context),
          ),
        ),
      ),
    );
  }

  void _showCodeEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => buildCodeEntryDialog(
            context: context,
            controller: viewModel.resetCodeController,
            error: viewModel.codeEntryError,
            codeError: viewModel.resetCodeError,
            isLoading: viewModel.isCodeEntryLoading,
            onVerifyCodePressed: () => viewModel.handleVerifyCode(context),
            onResendCodePressed: () {
              Navigator.pop(context);
              viewModel.setShowResendResetCodeDialog(true);
            },
          ),
        ),
      ),
    );
  }

  void _showNewPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => NewPasswordDialog(
            passwordController: viewModel.newPasswordController,
            confirmPasswordController: viewModel.confirmNewPasswordController,
            error: viewModel.newPasswordError,
            passwordError: viewModel.newPasswordErrorField,
            confirmPasswordError: viewModel.confirmNewPasswordError,
            isLoading: viewModel.isNewPasswordLoading,
            passwordVisible: viewModel.newPasswordVisible,
            confirmPasswordVisible: viewModel.confirmNewPasswordVisible,
            onPasswordVisibleChanged: (visible) =>
                viewModel.newPasswordVisible = visible,
            onConfirmPasswordVisibleChanged: (visible) =>
                viewModel.confirmNewPasswordVisible = visible,
            onSetPasswordPressed: () => viewModel.handleSetNewPassword(context),
          ),
        ),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          buildTermsDialog(onClose: () => _viewModel.setShowSignUpDialog(true)),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => ContactDialog(
            nameController: viewModel.contactNameController,
            emailController: viewModel.contactEmailController,
            subjectController: viewModel.contactSubjectController,
            messageController: viewModel.contactMessageController,
            error: viewModel.contactError,
            isLoading: viewModel.isContactLoading,
            onSendMessagePressed: () => viewModel.handleContact(context),
          ),
        ),
      ),
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => buildVerificationDialog(
        context: context,
        tokenController: _viewModel.verificationTokenController,
        message: _viewModel.verificationMessage,
        error: _viewModel.verificationError,
        isLoading: _viewModel.isVerificationLoading,
        onVerifyPressed: () => _viewModel.handleVerification(context),
        onResendPressed: () => _viewModel.handleResendVerification(context),
      ),
    );
  }

  void _showVerificationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => buildVerificationSuccessDialog(
        context: context,
        role: _viewModel.verificationRole,
        onGoToDashboardPressed: () => _viewModel.goToDashboard(context),
        onStayPressed: () => _viewModel.stayOnLandingPage(context),
      ),
    );
  }

  void _showResendResetCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => buildResendResetCodeDialog(
            context: context,
            controller: viewModel.resendResetCodeController,
            error: viewModel.resendResetCodeError,
            inputError: viewModel.resendResetCodeInputError,
            isLoading: viewModel.isResendResetCodeLoading,
            onResendCodePressed: () => viewModel.handleResendResetCode(context),
          ),
        ),
      ),
    );
  }

  void _showCounselorInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => CounselorInfoDialog(
            counselorId: viewModel.cCounselorIdController.text,
            name: viewModel.cNameController.text,
            degree: viewModel.cDegreeController.text,
            email: viewModel.cEmailController.text,
            contact: viewModel.cContactController.text,
            address: viewModel.cAddressController.text,
            birthdate: viewModel.cBirthdateController.text,
            civilStatus: viewModel.cCivilStatus,
            sex: viewModel.cSex,
            onCivilStatusChanged: (v) => viewModel.cCivilStatus = v,
            onSexChanged: (v) => viewModel.cSex = v,
            onAddressChanged: (a) => viewModel.cAddressController.text = a,
            warning: viewModel.cInfoWarning,
            isLoading: viewModel.isCounselorInfoSaving,
            onSavePressed: () => viewModel.handleSaveCounselorInfo(context),
            onCancelPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _showCounselorPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: Consumer<LandingScreenViewModel>(
          builder: (context, viewModel, child) => CounselorPendingDialog(
            message: viewModel.counselorPendingMessage,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Schedule dialog check safely after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDialogIfNeeded();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: buildAppBar(
        context: context,
        onServicesPressed: () => _viewModel.navigateToServices(context),
        onContactPressed: () => _viewModel.setShowContactDialog(true),
        onLoginPressed: () => _viewModel.setShowLoginDialog(true),
        onSignupPressed: () => _viewModel.setShowSignUpDialog(true),
      ),
      endDrawer: buildDrawer(
        context: context,
        onServicesPressed: () {
          Navigator.pop(context);
          _viewModel.navigateToServices(context);
        },
        onContactPressed: () {
          _viewModel.setShowContactDialog(true);
          Navigator.pop(context);
        },
        onLoginPressed: () {
          _viewModel.setShowLoginDialog(true);
          Navigator.pop(context);
        },
        onSignupPressed: () {
          _viewModel.setShowSignUpDialog(true);
          Navigator.pop(context);
        },
      ),
      body: buildBody(context),
    );
  }
}
