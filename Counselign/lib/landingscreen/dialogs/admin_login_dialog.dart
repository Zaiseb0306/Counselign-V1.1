import 'package:flutter/material.dart';
import '../../utils/async_button.dart';

class AdminLoginDialog extends StatefulWidget {
  final TextEditingController adminUserIdController;
  final TextEditingController adminPasswordController;
  final String error;
  final bool isLoading;
  final VoidCallback onAdminLoginPressed;
  final VoidCallback onBackToLoginPressed;

  const AdminLoginDialog({
    super.key,
    required this.adminUserIdController,
    required this.adminPasswordController,
    required this.error,
    required this.isLoading,
    required this.onAdminLoginPressed,
    required this.onBackToLoginPressed,
  });

  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog>
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
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
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
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          'Admin Verification',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: const Color(0xFF060E57),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter admin credentials',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 32),

                        // Admin User ID
                        TextField(
                          controller: widget.adminUserIdController,
                          decoration: InputDecoration(
                            labelText: 'Admin ID',
                            hintText: 'Enter your Admin ID',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFF060E57),
                            ),
                          ),
                          maxLength: 10,
                        ),
                        const SizedBox(height: 20),

                        // Admin Password
                        TextField(
                          controller: widget.adminPasswordController,
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Admin Password',
                            hintText: 'Enter your admin password',
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

                        // Admin Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: AsyncButton(
                            onPressed: widget.onAdminLoginPressed,
                            isLoading: widget.isLoading,
                            backgroundColor: const Color(0xFF060E57),
                            child: const Text(
                              'Continue to Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Back to Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onBackToLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFF495057),
                              side: const BorderSide(color: Color(0xFFDEE2E6)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(fontWeight: FontWeight.w500),
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
