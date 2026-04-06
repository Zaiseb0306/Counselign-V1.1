import 'package:flutter/material.dart';

class NewPasswordDialog extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String error;
  final String passwordError;
  final String confirmPasswordError;
  final bool isLoading;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final ValueChanged<bool> onPasswordVisibleChanged;
  final ValueChanged<bool> onConfirmPasswordVisibleChanged;
  final VoidCallback onSetPasswordPressed;

  const NewPasswordDialog({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.error,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.isLoading,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.onPasswordVisibleChanged,
    required this.onConfirmPasswordVisibleChanged,
    required this.onSetPasswordPressed,
  });

  @override
  State<NewPasswordDialog> createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<NewPasswordDialog> {
  late bool _passwordVisible;
  late bool _confirmPasswordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = widget.passwordVisible;
    _confirmPasswordVisible = widget.confirmPasswordVisible;
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
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Set New Password',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF060E57),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Enter your new password below.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // New Password Field
                    TextField(
                      controller: widget.passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF060E57),
                        ),
                        suffixIcon: IconButton(
                          icon: _passwordVisible
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
                          onPressed: () {
                            setState(
                              () => _passwordVisible = !_passwordVisible,
                            );
                            widget.onPasswordVisibleChanged(_passwordVisible);
                          },
                        ),
                        errorText: widget.passwordError.isNotEmpty
                            ? widget.passwordError
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    TextField(
                      controller: widget.confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF060E57),
                        ),
                        suffixIcon: IconButton(
                          icon: _confirmPasswordVisible
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
                          onPressed: () {
                            setState(
                              () => _confirmPasswordVisible =
                                  !_confirmPasswordVisible,
                            );
                            widget.onConfirmPasswordVisibleChanged(
                              _confirmPasswordVisible,
                            );
                          },
                        ),
                        errorText: widget.confirmPasswordError.isNotEmpty
                            ? widget.confirmPasswordError
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

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: widget.isLoading
                            ? null
                            : widget.onSetPasswordPressed,
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
                                'Set Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
