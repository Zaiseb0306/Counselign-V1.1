import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../../utils/secure_logger.dart';
import '../../routes.dart';
import '../models/notification.dart' as user_notification;
import '../models/message.dart';
import '../models/user_profile.dart';
import '../models/counselor.dart';
import '../models/appointment.dart' hide Counselor;
import '../dialogs/confirmation_dialog.dart';
import '../dialogs/alert_dialog.dart';
import '../dialogs/notice_dialog.dart';
import '../widgets/appointment_details_dialog.dart';
import '../widgets/follow_up_session_details_dialog.dart';
import '../models/follow_up_appointment.dart';

class StudentDashboardViewModel extends ChangeNotifier {
  final Session _session = Session();

  // User profile data
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  // Derived display fields for UI (avoids formatting in widgets)
  String get displayName => _userProfile?.displayName ?? 'Student';
  bool get hasName => _userProfile?.hasName ?? false;
  String get userId => _userProfile?.userId ?? '';
  String get formattedLastLogin {
    final raw = _userProfile?.lastLogin;
    if (raw == null || raw.isEmpty) return 'N/A';
    final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return raw; // Fallback to server string if unparseable
    final local = parsed.toLocal();
    return '${_monthName(local.month)} ${local.day}, ${local.year} ${_formatTime(local)}';
  }

  // Drawer state
  bool _isDrawerOpen = false;
  bool get isDrawerOpen => _isDrawerOpen;

  // Notifications
  List<user_notification.UserNotification> _notifications = [];
  List<user_notification.UserNotification> get notifications => _notifications;
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;
  bool _showNotifications = false;
  bool get showNotifications => _showNotifications;

  // Chat state
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  // Unread messages tracking
  final Map<String, List<int>> _unreadMessageIds =
      {}; // counselorId -> [messageIds]
  Map<String, List<int>> get unreadMessageIds => _unreadMessageIds;

  // Get messages filtered by selected counselor
  List<Message> get counselorMessages {
    if (_selectedCounselor == null) return [];

    final counselorId = _selectedCounselor!.counselorId;
    final currentUserId = _userProfile?.userId ?? '';

    return _messages.where((message) {
      // Include messages where:
      // 1. Student sent to this counselor (sender is student, receiver is counselor)
      // 2. Counselor sent to this student (sender is counselor, receiver is student)
      return (message.senderId == currentUserId &&
              message.receiverId == counselorId) ||
          (message.senderId == counselorId &&
              message.receiverId == currentUserId);
    }).toList();
  }

  // Get total unread messages count across all counselors
  int get totalUnreadMessagesCount {
    return _unreadMessageIds.values.fold(0, (sum, list) => sum + list.length);
  }

  // Check if a specific counselor has unread messages
  bool hasUnreadMessages(String counselorId) {
    final unreadIds = _unreadMessageIds[counselorId] ?? [];
    return unreadIds.isNotEmpty;
  }

  // Get unread messages count for a specific counselor
  int getUnreadMessagesCount(String counselorId) {
    final unreadIds = _unreadMessageIds[counselorId] ?? [];
    return unreadIds.length;
  }

  bool _showChat = false;
  bool get showChat => _showChat;
  bool _isTyping = false;
  bool get isTyping => _isTyping;
  final TextEditingController messageController = TextEditingController();
  final ScrollController chatScrollController = ScrollController();

  // Counselor selection state
  List<Counselor> _counselors = [];
  List<Counselor> get counselors => _counselors;
  Counselor? _selectedCounselor;
  Counselor? get selectedCounselor => _selectedCounselor;
  bool _isLoadingCounselors = false;
  bool get isLoadingCounselors => _isLoadingCounselors;
  bool _showCounselorSelection = false;
  bool get showCounselorSelection => _showCounselorSelection;

  // Loading states
  bool _isLoadingProfile = true;
  bool get isLoadingProfile => _isLoadingProfile;
  bool _isLoadingNotifications = false;
  bool get isLoadingNotifications => _isLoadingNotifications;
  bool _isSendingMessage = false;
  bool get isSendingMessage => _isSendingMessage;

  // PDS Reminder state
  bool _showPdsReminder = false;
  bool get showPdsReminder => _showPdsReminder;

  // Timers for polling
  Timer? _notificationTimer;
  Timer? _messageTimer;

  // Initialize the viewmodel
  void initialize() {
    loadUserProfile();
    loadPdsData();
    loadNotifications();
    loadCounselors();
    startPolling();
    _checkPdsReminder();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _messageTimer?.cancel();
    messageController.dispose();
    chatScrollController.dispose();
    super.dispose();
  }

  // User Profile Methods
  Future<void> loadPdsData() async {
    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/pds/load',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('🔍 Student PDS API Response: $data');
        if (data['success'] == true && data['data'] != null) {
          final pdsData = data['data'];
          final personalData = pdsData['personal'];
          if (personalData != null) {
            debugPrint('🔍 PDS Personal Data: $personalData');
            // Update the user profile with PDS data
            if (_userProfile != null) {
              _userProfile = UserProfile(
                userId: _userProfile!.userId,
                username: _userProfile!.username,
                email: _userProfile!.email,
                lastLogin: _userProfile!.lastLogin,
                profileImage: _userProfile!.profileImage,
                courseYear: _userProfile!.courseYear,
                firstName: personalData['first_name'],
                lastName: personalData['last_name'],
                fullName: personalData['full_name'],
              );
              debugPrint(
                '🔍 Updated UserProfile with PDS data - displayName: ${_userProfile?.displayName}, hasName: ${_userProfile?.hasName}',
              );
              notifyListeners();
            }
          }
        } else {
          debugPrint('Failed to load PDS data: ${data['message']}');
        }
      } else {
        debugPrint('PDS API returned status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading PDS data: $e');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/profile/get',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('🔍 Student Profile API Response: $data');
        if (data['success'] == true) {
          _userProfile = UserProfile.fromJson(data);
          debugPrint(
            '🔍 Student Profile loaded - displayName: ${_userProfile?.displayName}, hasName: ${_userProfile?.hasName}',
          );
          _isLoadingProfile = false;
          notifyListeners();
        } else {
          debugPrint('Failed to load profile: ${data['message']}');
          _isLoadingProfile = false;
          notifyListeners();
        }
      } else {
        debugPrint('Profile API returned status: ${response.statusCode}');
        _isLoadingProfile = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // ---------------- Formatting helpers ----------------
  String _monthName(int m) {
    const months = [
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
    if (m < 1 || m > 12) return '';
    return months[m - 1];
  }

  String _formatTime(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  // Drawer Methods
  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  void closeDrawer() {
    _isDrawerOpen = false;
    notifyListeners();
  }

  // Navigation Methods
  void navigateToAnnouncements(BuildContext context) {
    closeDrawer();
    // Use rootNavigator to ensure navigation works even from Dialog context
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/student/announcements');
  }

  void navigateToScheduleAppointment(BuildContext context) {
    closeDrawer();
    Navigator.of(context).pushNamed('/student/schedule-appointment');
  }

  void navigateToMyAppointments(BuildContext context) {
    closeDrawer();
    Navigator.of(context).pushNamed('/student/my-appointments');
  }

  void navigateToFollowUpSessions(BuildContext context) {
    closeDrawer();
    Navigator.of(context).pushNamed('/student/follow-up-sessions');
  }

  void navigateToProfile(BuildContext context) {
    closeDrawer();
    Navigator.of(context).pushNamed('/student/profile');
  }

  void logout(BuildContext context) async {
    closeDrawer();
    debugPrint('🚪 Student ViewModel: logout started');
    try {
      // Call logout endpoint to update activity fields in database
      debugPrint('🚪 Student ViewModel: calling logout endpoint...');
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/auth/logout',
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('🚪 Student ViewModel: logout response status: ${response.statusCode}');
    } catch (e) {
      debugPrint('🚪 Student ViewModel: error calling logout endpoint: $e');
      // Continue with logout even if endpoint call fails
    }

    // Clear session cookies
    debugPrint('🚪 Student ViewModel: clearing session cookies');
    _session.clearCookies();

    // Wait a brief moment to ensure any UI updates complete
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate back to landing (logout) using centralized navigation helper
    debugPrint('🚪 Student ViewModel: navigating to landing page');
    AppRoutes.navigateToLandingRoot();
    debugPrint('🚪 Student ViewModel: navigation called');
  }

  // Notification Methods
  Future<void> loadNotifications() async {
    if (_isLoadingNotifications) return;

    _isLoadingNotifications = true;
    notifyListeners();

    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/notifications',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final allNotifications =
              (data['notifications'] as List?)
                  ?.map((n) => user_notification.UserNotification.fromJson(n))
                  .toList() ??
              [];

          // Filter out message-related notifications
          // This ensures the notifications dropdown only shows non-message notifications
          // (appointments, announcements, etc.) and excludes chat/message notifications
          _notifications = allNotifications.where((notification) {
            final type = notification.type.toLowerCase();
            // Exclude message-related notification types
            return !type.contains('message') &&
                !type.contains('chat') &&
                !type.contains('messaging') &&
                !type.contains('conversation') &&
                !type.contains('reply');
          }).toList();

          // Recalculate unread count for filtered notifications
          _unreadNotificationCount = _notifications
              .where((n) => !n.isRead)
              .length;
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(
    int? notificationId, {
    String? type,
    int? relatedId,
  }) async {
    try {
      final Map<String, dynamic> payload = {};
      if (notificationId != null) {
        payload['notification_id'] = notificationId;
      } else if (type != null && relatedId != null) {
        payload['type'] = type;
        payload['related_id'] = relatedId;
      } else {
        debugPrint('Invalid parameters for markNotificationAsRead');
        return;
      }

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/notifications/mark-read',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Update local notification state
          if (notificationId != null) {
            try {
              final notification = _notifications.firstWhere(
                (n) => n.id == notificationId,
              );
              notification.isRead = true;
            } catch (e) {
              // Notification not found in list, continue
            }
          } else {
            // Mark all matching notifications as read
            for (var notification in _notifications) {
              if (notification.type == type &&
                  notification.relatedId == relatedId) {
                notification.isRead = true;
              }
            }
          }

          // Recalculate unread count
          _unreadNotificationCount = _notifications
              .where((n) => !n.isRead)
              .length;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void toggleNotifications() {
    _showNotifications = !_showNotifications;
    if (_showNotifications) {
      _showChat = false; // Close chat if open
    }
    notifyListeners();
  }

  void closeNotifications() {
    _showNotifications = false;
    notifyListeners();
  }

  Future<void> handleNotificationTap(
    BuildContext context,
    user_notification.UserNotification notification,
  ) async {
    closeNotifications();

    // Wait a brief moment for the notifications dropdown to close
    await Future.delayed(const Duration(milliseconds: 100));

    // Do NOT mark as read automatically - only the mark-as-read button should do that
    // Handle navigation/display based on notification type
    if (!context.mounted) return;

    switch (notification.type.toLowerCase()) {
      case 'appointment':
        if (notification.relatedId != null) {
          await showAppointmentDetailsModal(context, notification.relatedId!);
        } else {
          navigateToMyAppointments(context);
        }
        break;
      case 'follow-up':
      case 'followup':
      case 'follow_up':
        if (notification.relatedId != null) {
          await showFollowUpSessionDetailsModal(
            context,
            notification.relatedId!,
          );
        } else {
          navigateToFollowUpSessions(context);
        }
        break;
      case 'event':
      case 'announcement':
        if (context.mounted) {
          navigateToAnnouncements(context);
        }
        break;
      case 'message':
        toggleChat();
        break;
      default:
        // Default: do nothing or navigate to announcements
        break;
    }
  }

  // Appointment details state
  Appointment? _selectedAppointment;
  Appointment? get selectedAppointment => _selectedAppointment;
  bool _isLoadingAppointmentDetails = false;
  bool get isLoadingAppointmentDetails => _isLoadingAppointmentDetails;

  // Follow-up session details state
  FollowUpAppointment? _selectedFollowUpSession;
  FollowUpAppointment? get selectedFollowUpSession => _selectedFollowUpSession;
  bool _isLoadingFollowUpSessionDetails = false;
  bool get isLoadingFollowUpSessionDetails => _isLoadingFollowUpSessionDetails;

  Future<void> showAppointmentDetailsModal(
    BuildContext context,
    int appointmentId,
  ) async {
    _isLoadingAppointmentDetails = true;
    notifyListeners();

    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/appointments/get-my-appointments',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['appointments'] != null) {
          final appointments =
              (data['appointments'] as List?)
                  ?.map((a) => Appointment.fromJson(a))
                  .toList() ??
              [];
          _selectedAppointment = appointments.firstWhere(
            (app) => app.id == appointmentId,
            orElse: () => Appointment(id: 0),
          );

          if (_selectedAppointment!.id != 0) {
            // Show appointment details dialog using root navigator
            if (context.mounted) {
              await showDialog(
                context: context,
                barrierDismissible: true,
                builder: (dialogContext) => AppointmentDetailsDialog(
                  appointment: _selectedAppointment!,
                  onManage: () {
                    Navigator.of(dialogContext).pop();
                    if (context.mounted) {
                      navigateToMyAppointments(context);
                    }
                  },
                ),
              );
            }
          } else {
            if (context.mounted) {
              showAlertModal(context, 'Appointment not found.', 'warning');
            }
          }
        } else {
          if (context.mounted) {
            showAlertModal(
              context,
              'Failed to load appointment details.',
              'error',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading appointment details: $e');
      if (context.mounted) {
        showAlertModal(context, 'Error loading appointment details.', 'error');
      }
    } finally {
      _isLoadingAppointmentDetails = false;
      notifyListeners();
    }
  }

  Future<void> showFollowUpSessionDetailsModal(
    BuildContext context,
    int followUpSessionId,
  ) async {
    _isLoadingFollowUpSessionDetails = true;
    notifyListeners();

    try {
      // First, we need to find which parent appointment this follow-up belongs to
      // We'll load all follow-up sessions and find the one matching the ID
      // Since we don't have a direct endpoint for a single follow-up session,
      // we'll need to search through completed appointments
      final appointmentsResponse = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/follow-up-sessions/completed-appointments',
        headers: {'Content-Type': 'application/json'},
      );

      if (appointmentsResponse.statusCode == 200) {
        final appointmentsData = json.decode(appointmentsResponse.body);
        if (appointmentsData['status'] == 'success' &&
            appointmentsData['appointments'] != null) {
          final appointments =
              (appointmentsData['appointments'] as List?)
                  ?.map((a) => Appointment.fromJson(a))
                  .toList() ??
              [];

          // Search through all appointments to find the one with this follow-up session
          FollowUpAppointment? foundSession;
          for (final appointment in appointments) {
            final sessionsResponse = await _session.get(
              '${ApiConfig.currentBaseUrl}/student/follow-up-sessions/sessions?parent_appointment_id=${appointment.id}',
              headers: {'Content-Type': 'application/json'},
            );

            if (sessionsResponse.statusCode == 200) {
              final sessionsData = json.decode(sessionsResponse.body);
              if (sessionsData['status'] == 'success' &&
                  sessionsData['follow_up_sessions'] != null) {
                final sessions =
                    (sessionsData['follow_up_sessions'] as List?)
                        ?.map((s) => FollowUpAppointment.fromJson(s))
                        .toList() ??
                    [];

                foundSession = sessions.firstWhere(
                  (s) => s.id == followUpSessionId,
                  orElse: () => FollowUpAppointment(
                    id: 0,
                    counselorId: '',
                    studentId: '',
                    parentAppointmentId: 0,
                    preferredDate: '',
                    preferredTime: '',
                    consultationType: '',
                    followUpSequence: 0,
                    status: '',
                  ),
                );

                if (foundSession.id != 0) {
                  break; // Found the session, exit loop
                }
              }
            }
          }

          if (foundSession != null && foundSession.id != 0) {
            _selectedFollowUpSession = foundSession;
            // Show follow-up session details dialog using root navigator
            if (context.mounted) {
              await showDialog(
                context: context,
                barrierDismissible: true,
                builder: (dialogContext) => FollowUpSessionDetailsDialog(
                  session: _selectedFollowUpSession!,
                ),
              );
            }
          } else {
            if (context.mounted) {
              showAlertModal(
                context,
                'Follow-up session not found.',
                'warning',
              );
            }
          }
        } else {
          if (context.mounted) {
            showAlertModal(
              context,
              'Failed to load follow-up session details.',
              'error',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading follow-up session details: $e');
      if (context.mounted) {
        showAlertModal(
          context,
          'Error loading follow-up session details.',
          'error',
        );
      }
    } finally {
      _isLoadingFollowUpSessionDetails = false;
      notifyListeners();
    }
  }

  // Counselor Methods
  Future<void> loadCounselors() async {
    if (_isLoadingCounselors) return;

    _isLoadingCounselors = true;
    notifyListeners();

    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/get-counselors',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' || data['success'] == true) {
          _counselors =
              (data['counselors'] as List?)
                  ?.map((c) => Counselor.fromJson(c))
                  .toList() ??
              [];
        }
      }
    } catch (e) {
      debugPrint('Error loading counselors: $e');
    } finally {
      _isLoadingCounselors = false;
      notifyListeners();
    }
  }

  void showCounselorSelectionDialog() {
    _showCounselorSelection = true;
    notifyListeners();
  }

  void hideCounselorSelection() {
    _showCounselorSelection = false;
    notifyListeners();
  }

  void selectCounselor(Counselor counselor) {
    _selectedCounselor = counselor;
    _showCounselorSelection = false;
    _showChat = true;
    _showNotifications = false;
    loadMessages();
    startMessagePolling();
    notifyListeners();
  }

  // Chat Methods
  void toggleChat() {
    if (_selectedCounselor == null) {
      showCounselorSelectionDialog();
      return;
    }

    _showChat = !_showChat;
    if (_showChat) {
      _showNotifications = false; // Close notifications if open
      loadMessages();
      startMessagePolling();
    } else {
      stopMessagePolling();
    }
    notifyListeners();
  }

  void closeChat() {
    _showChat = false;
    stopMessagePolling();
    notifyListeners();
  }

  Future<void> loadMessages() async {
    try {
      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/message/operations?action=get_messages',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final newMessages =
              (data['messages'] as List?)
                  ?.map((m) => Message.fromJson(m))
                  .toList() ??
              [];

          // Mark messages as sent/received based on current user
          final currentUserId = _userProfile?.userId ?? '';
          for (var message in newMessages) {
            message.setCurrentUser(currentUserId);
          }

          // Track unread messages (incoming messages that haven't been read)
          _updateUnreadMessages(newMessages, currentUserId);

          _messages = newMessages;
          notifyListeners();

          // Scroll to bottom after loading messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (chatScrollController.hasClients) {
              chatScrollController.animateTo(
                chatScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  // Update unread messages tracking
  void _updateUnreadMessages(List<Message> messages, String currentUserId) {
    // Clear existing unread messages
    _unreadMessageIds.clear();

    // Group unread messages by counselor
    for (final message in messages) {
      // Only track incoming messages (received from counselor)
      if (message.receiverId == currentUserId) {
        final counselorId = message.senderId;

        if (!_unreadMessageIds.containsKey(counselorId)) {
          _unreadMessageIds[counselorId] = [];
        }

        _unreadMessageIds[counselorId]!.add(message.id);
      }
    }
  }

  // Mark all messages from a counselor as read
  void markMessagesAsRead(String counselorId) {
    if (_unreadMessageIds.containsKey(counselorId)) {
      _unreadMessageIds[counselorId] = [];
      notifyListeners();
    }
  }

  Future<void> sendMessage(BuildContext context) async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty ||
        _isSendingMessage ||
        _selectedCounselor == null) {
      return;
    }

    _isSendingMessage = true;
    _isTyping = true;
    notifyListeners();

    try {
      final formData = {
        'action': 'send_message',
        'receiver_id': _selectedCounselor!.counselorId,
        'message': messageText,
      };

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/message/operations',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          messageController.clear();
          await loadMessages(); // Refresh messages

          // Fixed: Check if context is still mounted before showing snackbar
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message sent successfully')),
            );
          }
        } else {
          // Fixed: Check if context is still mounted before showing snackbar
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Failed to send message'),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Fixed: Check if context is still mounted before showing snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error sending message')));
      }
    } finally {
      _isSendingMessage = false;
      _isTyping = false;
      notifyListeners();
    }
  }

  // Polling Methods
  void startPolling() {
    // Poll for notifications every 10 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      loadNotifications();
    });

    // Message polling is started when chat is opened
  }

  void startMessagePolling() {
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadMessages();
    });
  }

  void stopMessagePolling() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  // Utility Methods
  String formatMessageTime(DateTime time) {
    final DateTime localTime = time.toLocal();
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(localTime);
    final String time12Hour = _formatTime(localTime);

    // If today
    if (localTime.day == now.day &&
        localTime.month == now.month &&
        localTime.year == now.year) {
      return time12Hour;
    }

    // If yesterday
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (localTime.day == yesterday.day &&
        localTime.month == yesterday.month &&
        localTime.year == yesterday.year) {
      return 'Yesterday at $time12Hour';
    }

    // If 1 day ago (more than yesterday but less than 2 days ago)
    if (diff.inDays >= 1 && diff.inDays < 2) {
      return '1 day ago at $time12Hour';
    }

    // If within the week (2-7 days ago)
    if (diff.inDays >= 2 && diff.inDays <= 7) {
      return '${diff.inDays} days ago at $time12Hour';
    }

    // If more than a week, show full date with time
    return '${_monthName(localTime.month)} ${localTime.day}, ${localTime.year} at $time12Hour';
  }

  // Modal Utility Methods
  Future<void> showConfirmationModal(
    BuildContext context,
    String message, [
    VoidCallback? onConfirm,
  ]) async {
    return showDialog(
      context: context,
      builder: (context) =>
          ConfirmationDialog(message: message, onConfirm: onConfirm),
    );
  }

  Future<void> showAlertModal(
    BuildContext context,
    String message,
    String type,
  ) async {
    AlertType alertType;
    switch (type) {
      case 'success':
        alertType = AlertType.success;
        break;
      case 'error':
        alertType = AlertType.error;
        break;
      case 'warning':
        alertType = AlertType.warning;
        break;
      default:
        alertType = AlertType.info;
    }

    return showDialog(
      context: context,
      builder: (context) =>
          AlertDialogWidget(message: message, type: alertType),
    );
  }

  Future<void> showNoticeModal(
    BuildContext context,
    String message,
    String type,
  ) async {
    NoticeType noticeType;
    switch (type) {
      case 'success':
        noticeType = NoticeType.success;
        break;
      case 'error':
        noticeType = NoticeType.error;
        break;
      case 'warning':
        noticeType = NoticeType.warning;
        break;
      default:
        noticeType = NoticeType.info;
    }

    return showDialog(
      context: context,
      builder: (context) => NoticeDialog(message: message, type: noticeType),
    );
  }

  Future<void> clearAllNotifications(BuildContext context) async {
    try {
      // Collect all unread notifications that need to be marked
      // This matches the JavaScript behavior: collect notifications that can be marked as read
      final notificationsToMark = <Map<String, dynamic>>[];

      for (var notification in _notifications) {
        if (!notification.isRead) {
          // Prioritize notification_id if available (matches JavaScript behavior)
          if (notification.id > 0) {
            notificationsToMark.add({
              'notification_id': notification.id,
              'type': notification.type,
              'related_id': notification.relatedId,
            });
          } else {
            // For events and announcements without notification_id, use type + related_id
            final notificationType = notification.type.toLowerCase();
            if ((notificationType == 'event' ||
                    notificationType == 'announcement') &&
                notification.relatedId != null) {
              notificationsToMark.add({
                'notification_id': null,
                'type': notification.type,
                'related_id': notification.relatedId,
              });
            }
          }
        }
      }

      // If no notifications to mark, return early
      if (notificationsToMark.isEmpty) {
        return;
      }

      // First, call the bulk endpoint with mark_all: true
      final bulkResponse = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/notifications/mark-read',
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mark_all': true}),
      );

      if (bulkResponse.statusCode == 200) {
        final bulkData = json.decode(bulkResponse.body);
        if (bulkData['status'] == 'success') {
          // Now mark each individual notification based on its type
          final markPromises = <Future<void>>[];

          for (var notif in notificationsToMark) {
            final payload = <String, dynamic>{};

            // Handle different notification types
            if (notif['notification_id'] != null) {
              payload['notification_id'] = notif['notification_id'];
            } else if (notif['type'] != null && notif['related_id'] != null) {
              payload['type'] = notif['type'];
              payload['related_id'] = notif['related_id'];
            } else {
              continue; // Skip invalid entries
            }

            // Make individual API call for each notification
            markPromises.add(
              _session
                  .post(
                    '${ApiConfig.currentBaseUrl}/student/notifications/mark-read',
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(payload),
                  )
                  .then((response) {
                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);
                      if (data['status'] != 'success') {
                        debugPrint(
                          'Error marking notification as read: ${data['message']}',
                        );
                      }
                    }
                  })
                  .catchError((error) {
                    debugPrint('Error marking notification as read: $error');
                  }),
            );
          }

          // Wait for all individual marks to complete
          await Future.wait(markPromises);

          // Mark all notifications as read locally
          for (var notification in _notifications) {
            notification.isRead = true;
          }
          _unreadNotificationCount = 0;
          notifyListeners();

          // Reload notifications to update the list
          await loadNotifications();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All notifications marked as read'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (context.mounted) {
            showAlertModal(
              context,
              bulkData['message'] ??
                  'Failed to mark all notifications as read.',
              'error',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
      if (context.mounted) {
        showAlertModal(
          context,
          'Error marking all notifications as read.',
          'error',
        );
      }
    }
  }

  // PDS Reminder Methods
  Future<void> _checkPdsReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const reminderShownKey = 'pdsReminderShown';
      final hasShownReminder = prefs.getBool(reminderShownKey) ?? false;

      debugPrint('PDS Reminder Debug: hasShownReminder = $hasShownReminder');

      // If reminder hasn't been shown in this session, show it
      if (!hasShownReminder) {
        debugPrint('PDS Reminder: Showing (first time in session)');
        // Show modal after a short delay to ensure page is fully loaded
        Timer(const Duration(seconds: 1), () {
          _showPdsReminder = true;
          notifyListeners();
        });
      } else {
        debugPrint('PDS Reminder: Not showing (already shown in session)');
      }
    } catch (e) {
      debugPrint('Error checking PDS reminder: $e');
    }
  }

  void dismissPdsReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const reminderShownKey = 'pdsReminderShown';
      await prefs.setBool(reminderShownKey, true);
      debugPrint('PDS Reminder: Marked as shown in session');
    } catch (e) {
      debugPrint('Error dismissing PDS reminder: $e');
    }

    _showPdsReminder = false;
    notifyListeners();
  }

  void navigateToProfileFromPdsReminder(BuildContext context) {
    dismissPdsReminder();
    navigateToProfile(context);
  }
}
