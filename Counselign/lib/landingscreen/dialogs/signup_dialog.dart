import 'package:flutter/material.dart';
import '../../utils/async_button.dart';
import 'package:flutter/gestures.dart';

class SignUpDialog extends StatefulWidget {
  final TextEditingController userIdController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? role;
  final ValueChanged<String?> onRoleChanged;
  final String error;
  final String userIdError;
  final String usernameError;
  final String emailError;
  final String passwordError;
  final String confirmPasswordError;
  final bool isLoading;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onSignUpPressed;
  final VoidCallback onBackToLoginPressed;

  const SignUpDialog({
    super.key,
    required this.userIdController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.role,
    required this.onRoleChanged,
    required this.error,
    required this.userIdError,
    required this.usernameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.isLoading,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.onTermsPressed,
    required this.onSignUpPressed,
    required this.onBackToLoginPressed,
  });

  @override
  State<SignUpDialog> createState() => _SignUpDialogState();
}

class _SignUpDialogState extends State<SignUpDialog>
    with SingleTickerProviderStateMixin {
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  late bool termsAccepted;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    termsAccepted = widget.termsAccepted;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF060E57).withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF060E57).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Close Button
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF060E57,
                                ).withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: const Color(0xFF060E57),
                                fontWeight: FontWeight.w700,
                              ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Join our counseling community',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),

                        const SizedBox(height: 32),

                        // Role dropdown
                        DropdownButtonFormField<String>(
                          initialValue: widget.role,
                          decoration: InputDecoration(
                            labelText: 'Select your role',
                            labelStyle: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF060E57),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'student',
                              child: Text('Student'),
                            ),
                            DropdownMenuItem(
                              value: 'counselor',
                              child: Text('Counselor'),
                            ),
                          ],
                          onChanged: widget.onRoleChanged,
                        ),
                        const SizedBox(height: 20),

                        // User ID
                        TextField(
                          controller: widget.userIdController,
                          decoration: InputDecoration(
                            labelText: 'Preferred User ID',
                            hintText: 'User ID must be exactly 10 digits',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFF060E57),
                            ),
                            errorText: widget.userIdError.isNotEmpty
                                ? widget.userIdError
                                : null,
                          ),
                          maxLength: 10,
                        ),
                        const SizedBox(height: 20),

                        // Username
                        TextField(
                          controller: widget.usernameController,
                          decoration: InputDecoration(
                            labelText: 'Preferred Username',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF060E57),
                            ),
                            errorText: widget.usernameError.isNotEmpty
                                ? widget.usernameError
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email
                        TextField(
                          controller: widget.emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF060E57),
                            ),
                            errorText: widget.emailError.isNotEmpty
                                ? widget.emailError
                                : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // Password
                        TextField(
                          controller: widget.passwordController,
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF060E57),
                            ),
                            suffixIcon: IconButton(
                              icon: passwordVisible
                                  ? const Icon(
                                      Icons.visibility,
                                      color: Color(0xFF64748B),
                                    )
                                  : Image.asset(
                                      'Photos/close_eye.png',
                                      width: 20,
                                      height: 20,
                                      color: const Color(0xFF64748B),
                                    ),
                              onPressed: () => setState(
                                () => passwordVisible = !passwordVisible,
                              ),
                            ),
                            errorText: widget.passwordError.isNotEmpty
                                ? widget.passwordError
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password
                        TextField(
                          controller: widget.confirmPasswordController,
                          obscureText: !confirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF060E57),
                            ),
                            suffixIcon: IconButton(
                              icon: confirmPasswordVisible
                                  ? const Icon(
                                      Icons.visibility,
                                      color: Color(0xFF64748B),
                                    )
                                  : Image.asset(
                                      'Photos/close_eye.png',
                                      width: 20,
                                      height: 20,
                                      color: const Color(0xFF64748B),
                                    ),
                              onPressed: () => setState(
                                () => confirmPasswordVisible =
                                    !confirmPasswordVisible,
                              ),
                            ),
                            errorText: widget.confirmPasswordError.isNotEmpty
                                ? widget.confirmPasswordError
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Terms and Conditions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFF060E57,
                              ).withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: termsAccepted,
                                onChanged: (value) {
                                  setState(
                                    () => termsAccepted = value ?? false,
                                  );
                                  widget.onTermsChanged(value ?? false);
                                },
                                activeColor: const Color(0xFF060E57),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the ',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: const TextStyle(
                                          color: Color(0xFF060E57),
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = widget.onTermsPressed,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Error message
                        if (widget.error.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.error,
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Sign Up button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: widget.isLoading
                                ? null
                                : widget.onSignUpPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF060E57),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: widget.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Back to Login button
                        TextButton(
                          onPressed: widget.onBackToLoginPressed,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF060E57),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Already have an account? Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
