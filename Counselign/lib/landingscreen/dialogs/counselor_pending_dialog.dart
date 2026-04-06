import 'package:flutter/material.dart';

class CounselorPendingDialog extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const CounselorPendingDialog({
    super.key,
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account Pending Approval'),
      content: Text(
        message.isNotEmpty
            ? message
            : 'Your counselor account is pending admin approval. You will be notified via email once your account has been verified.',
      ),
      actions: [FilledButton(onPressed: onClose, child: const Text('OK'))],
    );
  }
}
