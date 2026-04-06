import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/counselor_dashboard_viewmodel.dart';
import 'state/quote_viewmodel.dart';
import 'models/quote.dart';
import 'widgets/counselor_screen_wrapper.dart';
import 'widgets/notifications_dropdown.dart';
import 'widgets/counselor_resources_accordion.dart';
import 'widgets/my_quotes_modal.dart';
import 'widgets/quote_submission_modal.dart';
import '../routes.dart';
import '../utils/online_status.dart';

class CounselorDashboardScreen extends StatefulWidget {
  const CounselorDashboardScreen({super.key});

  @override
  State<CounselorDashboardScreen> createState() =>
      _CounselorDashboardScreenState();
}

class _CounselorDashboardScreenState extends State<CounselorDashboardScreen> {
  late CounselorDashboardViewModel _viewModel;
  late QuoteViewModel _quoteViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CounselorDashboardViewModel();
    _viewModel.initialize();
    _quoteViewModel = QuoteViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _viewModel),
        ChangeNotifierProvider.value(value: _quoteViewModel),
      ],
      child: Consumer<CounselorDashboardViewModel>(
        builder: (context, viewModel, child) {
          return CounselorScreenWrapper(
            currentBottomNavIndex: 0, // Dashboard is Home button (index 0)
            onLogout: () => viewModel.logout(context),
            child: _buildMainContent(context),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 16
            : isTablet
            ? 20
            : 24,
        vertical: isMobile ? 20 : 24,
      ),
      child: Column(
        children: [
          _buildProfileSection(context),
          SizedBox(height: isMobile ? 20 : 30),
          _buildContentPanel(context),
          SizedBox(height: isMobile ? 20 : 24),
          const CounselorResourcesAccordion(),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<CounselorDashboardViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 8 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile Avatar
              GestureDetector(
                // onTap: () => Navigator.of(context).pushNamed(AppRoutes.counselorProfile),
                child: Container(
                  width: isMobile ? 60 : 90,
                  height: isMobile ? 60 : 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: viewModel.isLoadingProfile
                      ? const CircularProgressIndicator()
                      : ClipOval(
                          child: Image.network(
                            viewModel.profileImageUrl,
                            width: isMobile ? 60 : 90,
                            height: isMobile ? 60 : 90,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: isMobile ? 60 : 90,
                                height: isMobile ? 60 : 90,
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                '🖼️ Dashboard Screen: Image.network error: $error',
                              );
                              debugPrint(
                                '🖼️ Dashboard Screen: Image URL: ${viewModel.profileImageUrl}',
                              );
                              return Image.asset(
                                'Photos/profile.png',
                                width: isMobile ? 60 : 90,
                                height: isMobile ? 60 : 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                    '🖼️ Dashboard Screen: Image.asset error: $error',
                                  );
                                  return Container(
                                    width: isMobile ? 60 : 90,
                                    height: isMobile ? 60 : 90,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: isMobile ? 30 : 40,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ),

              SizedBox(width: isMobile ? 5 : 10),

              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi! ${viewModel.displayName}',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF003366),
                      ),
                    ),
                    // Hidden user_id display (similar to PHP implementation)
                    if (viewModel.hasName)
                      Text(
                        viewModel.userId,
                        style: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 0,
                          height: 0,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Last login: ${viewModel.formattedLastLogin}',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Quotes Button
              IconButton(
                onPressed: () => _showMyQuotesModal(context),
                icon: const Icon(
                  Icons.format_quote,
                  color: Color(0xFF003366),
                  size: 24,
                ),
                tooltip: 'Quotes',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.black.withAlpha((0.1 * 255).round()),
                  elevation: 2,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),

              // Notifications Icon
              Stack(
                children: [
                  IconButton(
                    onPressed: viewModel.toggleNotifications,
                    icon: Icon(
                      Icons.notifications,
                      color: viewModel.isNotificationsOpen
                          ? Colors.blue
                          : const Color(0xFF003366),
                      size: 24,
                    ),
                    tooltip: 'Notifications',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.black.withAlpha((0.1 * 255).round()),
                      elevation: 2,
                    ),
                  ),
                  if (viewModel.unreadNotificationsCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          viewModel.unreadNotificationsCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentPanel(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F0FF), Color(0xFFD6E9FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF191970).withAlpha((0.1 * 255).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191970).withAlpha((0.08 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Consumer<CounselorDashboardViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Column(
                children: [
                  // Main heading
                  Text(
                    'Welcome to Your Workspace, Counselor!',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF191970),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Dashboard cards row
                  _buildDashboardCards(context, isMobile),
                ],
              ),
              // Notifications Modal (matches student design)
              if (viewModel.isNotificationsOpen)
                NotificationsDropdown(
                  isVisible: viewModel.isNotificationsOpen,
                  notifications: viewModel.notifications,
                  onClose: viewModel.closeNotifications,
                  onMarkAsRead:
                      ({
                        int? notificationId,
                        String? type,
                        int? relatedId,
                      }) async {
                        await viewModel.markNotificationAsRead(
                          notificationId: notificationId,
                          type: type,
                          relatedId: relatedId,
                        );
                      },
                  onMarkAllAsRead: () async {
                    await viewModel.markAllNotificationsAsRead();
                  },
                  onNotificationTap: (notification) async {
                    // Mark as read if not already read
                    // CRITICAL: For events/announcements, ALWAYS use type/related_id
                    // This ensures proper recording in notifications_read table
                    if (!notification.isRead) {
                      final bool isEventOrAnnouncement =
                          notification.type == 'event' ||
                          notification.type == 'announcement';

                      if (isEventOrAnnouncement &&
                          notification.relatedId != null) {
                        // Event/announcement: use type and related_id
                        await viewModel.markNotificationAsRead(
                          notificationId: null,
                          type: notification.type,
                          relatedId: notification.relatedId,
                        );
                      } else if (notification.id != 0) {
                        // Regular notification: use notification_id
                        await viewModel.markNotificationAsRead(
                          notificationId: notification.id,
                          type: null,
                          relatedId: null,
                        );
                      } else if (notification.type.isNotEmpty &&
                          notification.relatedId != null) {
                        // Fallback: use type and related_id
                        await viewModel.markNotificationAsRead(
                          notificationId: null,
                          type: notification.type,
                          relatedId: notification.relatedId,
                        );
                      }
                    }
                    // Close notifications dropdown
                    viewModel.closeNotifications();
                    // Handle navigation based on notification type
                    if (!context.mounted) return;
                    if (notification.type == 'appointment' &&
                        notification.relatedId != null) {
                      _showAppointmentDetailsDialog(
                        context,
                        viewModel,
                        notification.relatedId.toString(),
                      );
                    } else if (notification.type == 'event' ||
                        notification.type == 'announcement') {
                      // Navigate to announcements screen
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.counselorAnnouncements,
                        );
                      }
                    } else if (notification.type == 'message') {
                      // Navigate to messages screen
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.counselorMessages,
                        );
                      }
                    }
                  },
                  unreadCount: viewModel.unreadNotificationsCount,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardCards(BuildContext context, bool isMobile) {
    return Consumer<CounselorDashboardViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Messages Card - First Row
            _buildMessagesCard(context, viewModel, isMobile),
            const SizedBox(height: 20),
            // Appointments Card - Second Row
            _buildAppointmentsCard(context, viewModel, isMobile),
          ],
        );
      },
    );
  }

  Widget _buildMessagesCard(
    BuildContext context,
    CounselorDashboardViewModel viewModel,
    bool isMobile,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to messages page
        Navigator.pushNamed(context, AppRoutes.counselorMessages);
      },
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF191970).withAlpha((0.1 * 255).round()),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF191970).withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: const Color(0xFF191970), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191970),
                  ),
                ),
                const Spacer(),
                if (viewModel.unreadMessagesCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${viewModel.unreadMessagesCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: viewModel.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No recent messages',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: viewModel.messages.take(2).length,
                      itemBuilder: (context, index) {
                        final message = viewModel.messages[index];
                        final String formattedTimestamp =
                            _formatMessageTimestamp(message.createdAt);
                        final FontWeight nameFontWeight = message.isRead
                            ? FontWeight.w600
                            : FontWeight.bold;
                        final FontWeight textFontWeight = message.isRead
                            ? FontWeight.normal
                            : FontWeight.bold;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Student: ${message.senderName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: nameFontWeight,
                                        color: const Color(0xFF191970),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: _buildStatusIndicator(message),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.messageText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF191970),
                                  fontWeight: textFontWeight,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Received on: $formattedTimestamp',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsCard(
    BuildContext context,
    CounselorDashboardViewModel viewModel,
    bool isMobile,
  ) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF191970).withAlpha((0.1 * 255).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191970).withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: const Color(0xFF191970),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191970),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: viewModel.recentAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No pending appointments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: viewModel.recentAppointments.take(2).length,
                    itemBuilder: (context, index) {
                      final appointment = viewModel.recentAppointments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student: ${appointment['username'] ?? appointment['student_id'] ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF191970),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${_formatDate(appointment['preferred_date'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Time: ${appointment['preferred_time'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.counselorReports);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191970),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.list_alt, size: 16),
                  label: const Text('Reports'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.counselorAppointments,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Manage'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatTimeWithMeridian(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final int hour = localDateTime.hour % 12 == 0
        ? 12
        : localDateTime.hour % 12;
    final String minute = localDateTime.minute.toString().padLeft(2, '0');
    final String period = localDateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatMessageTimestamp(DateTime dateTime) {
    final DateTime localDateTime = dateTime.toLocal();
    const List<String> monthAbbreviations = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final String month = monthAbbreviations[localDateTime.month - 1];
    final String time = _formatTimeWithMeridian(localDateTime);
    return '$month ${localDateTime.day} $time';
  }

  /// Build status indicator widget for a message
  Widget _buildStatusIndicator(dynamic message) {
    final statusResult = OnlineStatus.calculateOnlineStatus(
      message.lastActivity,
      message.lastLogin,
      message.logoutTime,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusResult.statusIcon, size: 8, color: statusResult.statusColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            statusResult.text,
            style: TextStyle(
              color: statusResult.statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Show appointment details dialog
  void _showAppointmentDetailsDialog(
    BuildContext context,
    CounselorDashboardViewModel viewModel,
    String appointmentId,
  ) async {
    // Show loading dialog
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    // Fetch appointment details
    final appointmentData = await viewModel.fetchAppointmentDetails(
      appointmentId,
    );

    // Close loading dialog
    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (appointmentData == null) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to load appointment details.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Show appointment details dialog
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final status =
            appointmentData['status']?.toString().toLowerCase() ?? '';
        Color statusColor = Colors.grey;
        if (status == 'rejected') {
          statusColor = Colors.red;
        } else if (status == 'pending') {
          statusColor = Colors.orange;
        } else if (status == 'completed') {
          statusColor = Colors.blue;
        } else if (status == 'approved') {
          statusColor = Colors.green;
        } else if (status == 'cancelled') {
          statusColor = Colors.grey;
        }

        return AlertDialog(
          title: const Text('Appointment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(
                  'Date',
                  appointmentData['preferred_date']?.toString() ?? 'N/A',
                ),
                _buildDetailRow(
                  'Time',
                  appointmentData['preferred_time']?.toString() ?? 'N/A',
                ),
                _buildDetailRow(
                  'Status',
                  status.toUpperCase(),
                  statusColor: statusColor,
                ),
                _buildDetailRow(
                  'Student',
                  appointmentData['student_name']?.toString() ??
                      appointmentData['username']?.toString() ??
                      appointmentData['student_id']?.toString() ??
                      'N/A',
                ),
                _buildDetailRow(
                  'Method',
                  appointmentData['method_type']?.toString() ?? 'N/A',
                ),
                _buildDetailRow(
                  'Purpose',
                  appointmentData['purpose']?.toString() ?? 'N/A',
                ),
                _buildDetailRow(
                  'Description',
                  appointmentData['description']?.toString() ?? 'N/A',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  Navigator.pushNamed(context, AppRoutes.counselorAppointments);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF191970),
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Appointments'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: statusColor != null
                  ? TextStyle(color: statusColor, fontWeight: FontWeight.w500)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showMyQuotesModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      enableDrag: true,
      isDismissible: true,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: _quoteViewModel,
        child: MyQuotesModal(
          onClose: () {
            if (Navigator.of(sheetContext).canPop()) {
              Navigator.of(sheetContext).pop();
            }
          },
          onOpenQuoteForm: (quote) {
            // Use the ORIGINAL context, not sheetContext
            // Don't close MyQuotesModal
            _showFloatingQuoteSubmissionModal(
              context, // Use dashboard context, not sheetContext
              quoteToEdit: quote,
            );
          },
        ),
      ),
    );
  }

  void _showFloatingQuoteSubmissionModal(
    BuildContext context, {
    Quote? quoteToEdit,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ChangeNotifierProvider.value(
            value: _quoteViewModel,
            child: FloatingQuoteSubmissionModal(
              quoteToEdit: quoteToEdit,
              onClose: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              onSuccess: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                // Reload quotes
                _quoteViewModel.loadMyQuotes();
              },
              onOpenMyQuotes: () {
                // Just reload quotes - MyQuotesModal is still open underneath
                _quoteViewModel.loadMyQuotes();
              },
            ),
          );
        },
      ),
    );
  }
}
