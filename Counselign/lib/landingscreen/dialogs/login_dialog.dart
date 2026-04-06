import 'package:flutter/material.dart';
import '../../utils/async_button.dart';

class LoginDialog extends StatefulWidget {
  final TextEditingController userIdController;
  final TextEditingController passwordController;
  final String error;
  final String userIdError;
  final String passwordError;
  final bool isLoading;
  final bool isForgotPasswordNavigating;
  final bool isSignUpNavigating;
  final VoidCallback onForgotPasswordPressed;
  final VoidCallback onSignUpPressed;
  final VoidCallback onLoginPressed;
  final VoidCallback onAdminLoginPressed;

  const LoginDialog({
    super.key,
    required this.userIdController,
    required this.passwordController,
    required this.error,
    required this.userIdError,
    required this.passwordError,
    required this.isLoading,
    required this.isForgotPasswordNavigating,
    required this.isSignUpNavigating,
    required this.onForgotPasswordPressed,
    required this.onSignUpPressed,
    required this.onLoginPressed,
    required this.onAdminLoginPressed,
  });

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog>
    with SingleTickerProviderStateMixin {
  bool passwordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
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
                            Icons.login,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: const Color(0xFF060E57),
                                fontWeight: FontWeight.w700,
                              ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Sign in to your account',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),

                        const SizedBox(height: 32),

                        // Identifier label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sign in with your User ID or Email',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Identifier input
                        TextField(
                          controller: widget.userIdController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'User ID or Email',
                            hintText: 'Enter your 10-digit ID or your email',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFF060E57),
                            ),
                            errorText: widget.userIdError.isNotEmpty
                                ? widget.userIdError
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password
                        TextField(
                          controller: widget.passwordController,
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
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

                        // Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: widget.isForgotPasswordNavigating
                                    ? null
                                    : widget.onForgotPasswordPressed,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF060E57),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                ),
                                child: widget.isForgotPasswordNavigating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF060E57),
                                        ),
                                      )
                                    : const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: widget.isSignUpNavigating
                                    ? null
                                    : widget.onSignUpPressed,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF060E57),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                ),
                                child: widget.isSignUpNavigating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF060E57),
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: widget.isLoading
                                ? null
                                : widget.onLoginPressed,
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
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Show admin login button only on tablet/desktop (>=600px)
                        Builder(
                          builder: (context) {
                            final screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            final isTabletOrDesktop = screenWidth >= 600;

                            if (!isTabletOrDesktop) {
                              return const SizedBox.shrink();
                            }

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: widget.onAdminLoginPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: const Color(0xFF495057),
                                  side: const BorderSide(
                                    color: Color(0xFFDEE2E6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Admin Login',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            );
                          },
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
