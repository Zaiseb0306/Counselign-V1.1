import 'package:flutter/material.dart';

Widget buildResendVerificationDialog({
  required BuildContext context,
  required TextEditingController identifierController,
  required String error,
  required bool isLoading,
  required VoidCallback onResendPressed,
  required VoidCallback onCancelPressed,
}) {
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(20),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
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
      child: _ResendVerificationDialogContent(
        identifierController: identifierController,
        error: error,
        isLoading: isLoading,
        onResendPressed: onResendPressed,
        onCancelPressed: onCancelPressed,
      ),
    ),
  );
}

class _ResendVerificationDialogContent extends StatefulWidget {
  final TextEditingController identifierController;
  final String error;
  final bool isLoading;
  final VoidCallback onResendPressed;
  final VoidCallback onCancelPressed;

  const _ResendVerificationDialogContent({
    required this.identifierController,
    required this.error,
    required this.isLoading,
    required this.onResendPressed,
    required this.onCancelPressed,
  });

  @override
  State<_ResendVerificationDialogContent> createState() =>
      _ResendVerificationDialogContentState();
}

class _ResendVerificationDialogContentState
    extends State<_ResendVerificationDialogContent> {
  bool _localLoading = false;

  @override
  void initState() {
    super.initState();
    _localLoading = widget.isLoading;
  }

  @override
  void didUpdateWidget(_ResendVerificationDialogContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync local state with external loading state
    if (oldWidget.isLoading != widget.isLoading) {
      setState(() {
        _localLoading = widget.isLoading;
      });
    }
  }

  void _handleResendPressed() {
    if (_localLoading) return; // Prevent duplicate calls

    setState(() {
      _localLoading = true;
    });
    widget.onResendPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Close Button (disabled when loading)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
              onPressed: _localLoading ? null : widget.onCancelPressed,
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
                        color: const Color(0xFF060E57).withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Resend Verification Email',
                  style: TextStyle(
                    color: Color(0xFF060E57),
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),

                const SizedBox(height: 16),

                // Message
                const Text(
                  'Enter your registered email address or user ID to resend the verification email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Email/User ID Input Field
                TextFormField(
                  controller: widget.identifierController,
                  enabled: !_localLoading,
                  decoration: InputDecoration(
                    labelText: 'Email or User ID',
                    hintText: 'Enter your email address or user ID',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF64748B),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF060E57),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: _localLoading
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFF8FAFD),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),

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
                          color: Color(0xFFDC2626),
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

                const SizedBox(height: 32),

                // Resend Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _localLoading ? null : _handleResendPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF060E57),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _localLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send Verification Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _localLoading ? null : widget.onCancelPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
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
    );
  }
}
