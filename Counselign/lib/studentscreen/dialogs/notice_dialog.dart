import 'package:flutter/material.dart';

enum NoticeType { success, error, warning, info }

class NoticeDialog extends StatelessWidget {
  final String message;
  final NoticeType type;
  final String? title;

  const NoticeDialog({
    super.key,
    required this.message,
    this.type = NoticeType.info,
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
      case NoticeType.success:
        return const Color(0xFF198754);
      case NoticeType.error:
        return const Color(0xFFDC3545);
      case NoticeType.warning:
        return const Color(0xFFFFC107);
      case NoticeType.info:
        return const Color(0xFFFFC107); // Bell icon with warning color
    }
  }

  IconData _getIcon() {
    switch (type) {
      case NoticeType.success:
        return Icons.check_circle;
      case NoticeType.error:
        return Icons.error;
      case NoticeType.warning:
        return Icons.warning;
      case NoticeType.info:
        return Icons.notifications; // Bell icon
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case NoticeType.success:
        return 'Success';
      case NoticeType.error:
        return 'Error';
      case NoticeType.warning:
        return 'Warning';
      case NoticeType.info:
        return 'Notice';
    }
  }
}