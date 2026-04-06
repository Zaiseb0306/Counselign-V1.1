import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info }

class AlertDialogWidget extends StatelessWidget {
  final String message;
  final AlertType type;
  final String? title;

  const AlertDialogWidget({
    super.key,
    required this.message,
    this.type = AlertType.info,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getIconColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              title ?? _getDefaultTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF060E57),
              ),
            ),
            const SizedBox(height: 16),
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 24),
            // Button
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF060E57),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor() {
    switch (type) {
      case AlertType.success:
        return const Color(0xFF198754);
      case AlertType.error:
        return const Color(0xFFDC3545);
      case AlertType.warning:
        return const Color(0xFFFFC107);
      case AlertType.info:
        return const Color(0xFF0D6EFD);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.info:
        return Icons.info;
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case AlertType.success:
        return 'Success';
      case AlertType.error:
        return 'Error';
      case AlertType.warning:
        return 'Warning';
      case AlertType.info:
        return 'Information';
    }
  }
}