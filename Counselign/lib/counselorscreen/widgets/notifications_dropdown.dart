import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationsDropdown extends StatelessWidget {
  final bool isVisible;
  final List<NotificationModel> notifications;
  final VoidCallback onClose;
  final Function({int? notificationId, String? type, int? relatedId})
  onMarkAsRead;
  final VoidCallback? onMarkAllAsRead;
  final Function(NotificationModel)? onNotificationTap;
  final int unreadCount;

  const NotificationsDropdown({
    super.key,
    required this.isVisible,
    required this.notifications,
    required this.onClose,
    required this.onMarkAsRead,
    this.onMarkAllAsRead,
    this.onNotificationTap,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

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
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Notifications list
            Flexible(
              child: notifications.isEmpty
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
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final bool showMarkReadBtn = !notification.isRead;
                        return InkWell(
                          onTap: () {
                            if (onNotificationTap != null) {
                              onNotificationTap!(notification);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: notification.isRead
                                  ? Colors.white
                                  : const Color(0xFFF0F9FF),
                              border: const Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF0F4F8),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Unread indicator
                                if (!notification.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(
                                      top: 8,
                                      right: 12,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF060E57),
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 20),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF003366),
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
                                      Text(
                                        notification.message,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // FIXED: Mark as read button - now properly checks which parameters to send
                                // CRITICAL: Events and announcements should ALWAYS use type/related_id,
                                // even if they have an id, to ensure proper recording in notifications_read table
                                if (showMarkReadBtn)
                                  IconButton(
                                    onPressed: () {
                                      // CRITICAL: For events and announcements, ALWAYS use type and related_id
                                      // This matches JavaScript behavior - events/announcements must be marked
                                      // by type/related_id to be recorded in notifications_read table
                                      final bool isEventOrAnnouncement =
                                          notification.type == 'event' ||
                                          notification.type == 'announcement';

                                      if (isEventOrAnnouncement &&
                                          notification.relatedId != null) {
                                        // Event/announcement: ALWAYS use type and related_id
                                        debugPrint(
                                          '🔘 Individual mark: Using type ${notification.type}, related_id ${notification.relatedId}',
                                        );
                                        onMarkAsRead(
                                          notificationId: null,
                                          type: notification.type,
                                          relatedId: notification.relatedId,
                                        );
                                      } else if (notification.id != 0) {
                                        // Regular notification: use notification_id
                                        debugPrint(
                                          '🔘 Individual mark: Using notification_id ${notification.id}',
                                        );
                                        onMarkAsRead(
                                          notificationId: notification.id,
                                          type: null,
                                          relatedId: null,
                                        );
                                      } else if (notification.type.isNotEmpty &&
                                          notification.relatedId != null) {
                                        // Fallback: use type and related_id if no valid id
                                        debugPrint(
                                          '🔘 Individual mark: Using type ${notification.type}, related_id ${notification.relatedId}',
                                        );
                                        onMarkAsRead(
                                          notificationId: null,
                                          type: notification.type,
                                          relatedId: notification.relatedId,
                                        );
                                      } else {
                                        // Invalid notification structure
                                        debugPrint(
                                          '⚠️ Warning: Cannot mark notification - no valid identifiers',
                                        );
                                        debugPrint(
                                          '   ID: ${notification.id}, Type: ${notification.type}, RelatedId: ${notification.relatedId}',
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                      color: Color(0xFF059669),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Mark as read',
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Footer with clear all button
            if (notifications.isNotEmpty && onMarkAllAsRead != null)
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
                        onPressed: onMarkAllAsRead,
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
