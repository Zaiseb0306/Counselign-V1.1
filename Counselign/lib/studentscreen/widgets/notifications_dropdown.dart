import 'package:flutter/material.dart';
import '../state/student_dashboard_viewmodel.dart';
import '../models/notification.dart' as student_notification;

class StudentNotificationsDropdown extends StatelessWidget {
  final StudentDashboardViewModel viewModel;

  const StudentNotificationsDropdown({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width > 480
            ? 380
            : MediaQuery.of(context).size.width - 40,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFEEF2F7), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Color(0xFF003366),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: viewModel.closeNotifications,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Notifications list
            Flexible(
              child: viewModel.isLoadingNotifications
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : viewModel.notifications.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              color: Color(0xFF64748B),
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'You\'re all caught up!',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: viewModel.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = viewModel.notifications[index];
                        return _buildNotificationItem(context, notification);
                      },
                    ),
            ),

            // Footer with clear all button
            if (viewModel.notifications.isNotEmpty &&
                !viewModel.isLoadingNotifications)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  border: Border(
                    top: BorderSide(color: const Color(0xFFEEF2F7), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('Clear All'),
                        onPressed: () async {
                          await viewModel.clearAllNotifications(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    student_notification.UserNotification notification,
  ) {
    return InkWell(
      onTap: () async {
        await viewModel.handleNotificationTap(context, notification);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF0F9FF),
          border: Border(
            bottom: BorderSide(color: const Color(0xFFF0F4F8), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon based on notification type
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: 18,
              ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and time row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF003366),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Message
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),

                  // Unread indicator for unread notifications
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF060E57),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),

            // Mark as read button
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: const Icon(Icons.check, size: 18),
                  color: const Color(0xFF3B82F6),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () {
                    // For events and announcements, use type+related_id
                    // For other notifications, use notification_id
                    final notificationType = notification.type.toLowerCase();
                    if ((notificationType == 'event' ||
                            notificationType == 'announcement') &&
                        notification.relatedId != null) {
                      // Use type + related_id for events/announcements
                      viewModel.markNotificationAsRead(
                        null,
                        type: notification.type,
                        relatedId: notification.relatedId,
                      );
                    } else if (notification.id > 0) {
                      // Use notification_id for other types
                      viewModel.markNotificationAsRead(
                        notification.id,
                        type: notification.type,
                        relatedId: notification.relatedId,
                      );
                    }
                  },
                  tooltip: 'Mark as read',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'appointment':
        return const Color(0xFF10B981);
      case 'message':
        return const Color(0xFF3B82F6);
      case 'announcement':
        return const Color(0xFFF59E0B);
      case 'urgent':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF060E57);
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'appointment':
        return Icons.calendar_today;
      case 'message':
        return Icons.message;
      case 'announcement':
        return Icons.announcement;
      case 'urgent':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays == 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
