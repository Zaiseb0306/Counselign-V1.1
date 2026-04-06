import 'package:flutter/material.dart';
import '../../utils/session.dart';
import 'dart:convert';
import 'dart:async';
import '../../api/config.dart';
import '../../routes.dart';
import '../../utils/secure_logger.dart';
import '../models/counselor_profile.dart';
import '../models/message.dart';
import '../models/notification.dart';

class CounselorDashboardViewModel extends ChangeNotifier {
  // Counselor profile data
  CounselorProfile? _counselorProfile;
  CounselorProfile? get counselorProfile => _counselorProfile;

  String? _lastLogin;
  String? get lastLogin => _lastLogin;

  // Derived display fields for UI
  String get displayName {
    final profile = _counselorProfile;
    if (profile == null) return 'Counselor';
    return profile.displayName;
  }

  bool get hasName {
    final profile = _counselorProfile;
    if (profile == null) return false;
    return profile.hasName;
  }

  String get userId {
    final profile = _counselorProfile;
    if (profile == null) return '';
    return profile.userId;
  }

  String get profileImageUrl {
    if (_counselorProfile == null) {
      debugPrint('🖼️ Dashboard: No profile loaded, using default');
      String cleanBaseUrl = ApiConfig.currentBaseUrl;
      if (cleanBaseUrl.endsWith('/index.php')) {
        cleanBaseUrl = cleanBaseUrl.replaceAll('/index.php', '');
      }
      return '$cleanBaseUrl/Photos/profile.png';
    }

    final imageUrl = _counselorProfile!.buildImageUrl(ApiConfig.currentBaseUrl);
    debugPrint('🖼️ Dashboard: Profile picture URL: $imageUrl');
    debugPrint(
      '🖼️ Dashboard: Profile picture field: ${_counselorProfile!.profilePicture}',
    );
    return imageUrl;
  }

  String get formattedLastLogin {
    if (_lastLogin == null || _lastLogin!.isEmpty) return 'N/A';
    final raw = _lastLogin!;
    final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    return '${_monthName(local.month)} ${local.day}, ${local.year} ${_formatTime(local)}';
  }

  // Loading states
  bool _isLoadingProfile = true;
  bool get isLoadingProfile => _isLoadingProfile;

  // Drawer state
  bool _isDrawerOpen = false;
  bool get isDrawerOpen => _isDrawerOpen;

  // Chat state
  bool _isChatOpen = false;
  bool get isChatOpen => _isChatOpen;

  // Notifications state
  bool _isNotificationsOpen = false;
  bool get isNotificationsOpen => _isNotificationsOpen;

  // Recent appointments state
  List<dynamic> _recentAppointments = [];
  List<dynamic> get recentAppointments => _recentAppointments;

  // Messages
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  int _unreadMessagesCount = 0;
  int get unreadMessagesCount => _unreadMessagesCount;

  // Notifications
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int _unreadNotificationsCount = 0;
  int get unreadNotificationsCount => _unreadNotificationsCount;

  // Timer for polling notifications
  Timer? _notificationTimer;

  final Session _session = Session();

  void initialize() {
    debugPrint('Initializing counselor dashboard...');
    fetchCounselorProfile();
    fetchMessages();
    fetchNotifications();
    fetchRecentAppointments();
    startPolling();
  }

  // Fetch counselor profile
  Future<void> fetchCounselorProfile() async {
    try {
      _isLoadingProfile = true;
      notifyListeners();

      debugPrint(
        '🔍 Fetching counselor profile from: ${ApiConfig.currentBaseUrl}/counselor/profile/get',
      );
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/profile/get',
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Profile API Response Status: ${response.statusCode}');
      debugPrint('Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Profile API Data: $data');
        if (data['success'] == true) {
          debugPrint('🖼️ Dashboard: Raw API response data: $data');
          debugPrint(
            '🖼️ Dashboard: profile_picture field: ${data['profile_picture']}',
          );
          debugPrint('🖼️ Dashboard: counselor data: ${data['counselor']}');
          debugPrint(
            '🔍 Counselor name fields - first_name: ${data['counselor']?['first_name']}, last_name: ${data['counselor']?['last_name']}, full_name: ${data['counselor']?['full_name']}',
          );

          if (data['counselor'] != null) {
            debugPrint(
              '🖼️ Dashboard: counselor profile_picture: ${data['counselor']['profile_picture']}',
            );
          }

          final profileData = {
            'id': data['user_id'] ?? 0,
            'user_id': data['user_id'] ?? '',
            'username': data['username'] ?? data['user_id'] ?? '',
            'email': data['email'] ?? '',
            'role': data['role'] ?? 'counselor',
            'last_login': data['last_login'],
            'profile_picture':
                data['profile_picture'] ??
                data['counselor']?['profile_picture'],
            'counselor': data['counselor'],
          };

          debugPrint('🖼️ Dashboard: Created profile data: $profileData');
          _counselorProfile = CounselorProfile.fromJson(profileData);
          _lastLogin = data['last_login']?.toString();
          _isLoadingProfile = false;
          debugPrint(
            'Profile loaded: ${_counselorProfile?.counselor?.name ?? _counselorProfile?.username ?? 'Unknown'}, Last login: $_lastLogin',
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching counselor profile: $e');
    } finally {
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

  // Fetch messages
  Future<void> fetchMessages() async {
    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/message/operations?action=get_dashboard_messages&limit=2',
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Messages API Response Status: ${response.statusCode}');
      debugPrint('Messages API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Messages API Data: $data');
        if (data['success'] == true) {
          final conversations = data['conversations'] as List? ?? [];
          _messages = conversations
              .map(
                (conv) => Message(
                  id: 0,
                  senderId: conv['other_user_id'] ?? '',
                  senderName: conv['other_username'] ?? 'Unknown',
                  receiverId: '',
                  messageText: conv['last_message'] ?? '',
                  createdAt:
                      DateTime.tryParse(conv['last_message_time'] ?? '') ??
                      DateTime.now(),
                  isRead: conv['unread_count'] == 0,
                  lastActivity: conv['last_activity']?.toString(),
                  lastLogin: conv['last_login']?.toString(),
                  logoutTime: conv['logout_time']?.toString(),
                ),
              )
              .toList();
          _unreadMessagesCount = _messages.where((m) => !m.isRead).length;
          debugPrint(
            'Messages loaded: ${_messages.length} messages, $_unreadMessagesCount unread',
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  // Fetch notifications
  Future<void> fetchNotifications() async {
    try {
      debugPrint(
        '🔔 Fetching notifications from: ${ApiConfig.currentBaseUrl}/counselor/notifications',
      );
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/notifications',
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Notifications API Response Status: ${response.statusCode}');
      debugPrint('Notifications API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Notifications API Data: $data');
        if (data['status'] == 'success') {
          _notifications =
              (data['notifications'] as List?)
                  ?.map((n) => NotificationModel.fromJson(n))
                  .toList() ??
              [];
          _unreadNotificationsCount = data['unread_count'] ?? 0;
          debugPrint(
            'Notifications loaded: ${_notifications.length} notifications, $_unreadNotificationsCount unread',
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  // Send message
  Future<bool> sendMessage(String message) async {
    try {
      final formData = {'message': message, 'receiver_id': 'admin123'};

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/counselor/message/send',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await fetchMessages();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  // FIXED: Mark notification as read - supports both notification_id and type/related_id
  // Changed Map<String, String> to Map<String, dynamic> to match JavaScript
  Future<bool> markNotificationAsRead({
    int? notificationId,
    String? type,
    int? relatedId,
  }) async {
    try {
      // IMPORTANT: Build payload exactly like JavaScript does
      final Map<String, dynamic> payload = {};

      // Only add notification_id if it's provided AND not 0
      if (notificationId != null && notificationId != 0) {
        payload['notification_id'] = notificationId;
        debugPrint('📤 Marking with notification_id: $notificationId');
      }
      // Otherwise, use type and related_id (for events/announcements)
      else if (type != null && type.isNotEmpty && relatedId != null) {
        payload['type'] = type;
        payload['related_id'] = relatedId;
        debugPrint('📤 Marking with type: $type, related_id: $relatedId');
      } else {
        debugPrint('❌ Error: Invalid parameters for markNotificationAsRead');
        debugPrint(
          '   notificationId: $notificationId, type: $type, relatedId: $relatedId',
        );
        return false;
      }

      debugPrint('📤 Final payload: $payload');

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/counselor/notifications/mark-read',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' || data['success'] == true) {
          debugPrint('✅ Successfully marked as read');

          // Update local state
          if (notificationId != null && notificationId != 0) {
            final notificationIndex = _notifications.indexWhere(
              (n) => n.id == notificationId,
            );
            if (notificationIndex != -1) {
              _notifications[notificationIndex] =
                  _notifications[notificationIndex].copyWith(isRead: true);
              debugPrint(
                '✅ Updated local notification at index $notificationIndex',
              );
            }
          } else if (type != null && relatedId != null) {
            // Update by type and related_id (for events/announcements)
            for (int i = 0; i < _notifications.length; i++) {
              if (_notifications[i].type == type &&
                  _notifications[i].relatedId == relatedId) {
                _notifications[i] = _notifications[i].copyWith(isRead: true);
                debugPrint(
                  '✅ Updated local notification at index $i (type: $type, relatedId: $relatedId)',
                );
              }
            }
          }

          // Recalculate unread count
          _unreadNotificationsCount = _notifications
              .where((n) => !n.isRead)
              .length;
          debugPrint('📊 New unread count: $_unreadNotificationsCount');

          notifyListeners();
          return true;
        } else {
          debugPrint(
            '⚠️ Server returned non-success: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        debugPrint('⚠️ HTTP error: ${response.statusCode}');
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      return false;
    }
  }

  // FIXED: Mark all notifications as read - now matches JavaScript exactly
  Future<bool> markAllNotificationsAsRead() async {
    try {
      debugPrint('🔔 ========== STARTING MARK ALL PROCESS ==========');

      // Step 1: Call bulk endpoint with mark_all: true
      debugPrint('📤 Step 1: Calling bulk mark-all endpoint...');
      final bulkResponse = await _session.post(
        '${ApiConfig.currentBaseUrl}/counselor/notifications/mark-read',
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mark_all': true}),
      );

      debugPrint('📥 Bulk response status: ${bulkResponse.statusCode}');
      debugPrint('📥 Bulk response body: ${bulkResponse.body}');

      if (bulkResponse.statusCode != 200) {
        debugPrint('❌ Error: Bulk mark-all request failed');
        return false;
      }

      final bulkData = json.decode(bulkResponse.body);
      if (bulkData['status'] != 'success' && bulkData['success'] != true) {
        debugPrint('❌ Error: Bulk mark-all response indicates failure');
        return false;
      }

      debugPrint('✅ Step 1 complete: Bulk mark-all succeeded');

      // Step 2: Collect all notifications that need individual marking
      // CRITICAL: This matches JavaScript behavior - collect ALL notifications that need marking,
      // including events and announcements (which should always be marked individually)
      debugPrint(
        '📋 Step 2: Collecting notifications for individual marking...',
      );
      final notificationsToMark = <Map<String, dynamic>>[];

      for (final notification in _notifications) {
        // CRITICAL: Collect all notifications that need individual marking
        // This matches JavaScript behavior - collect unread notifications AND
        // events/announcements (which should always be marked individually)
        final bool isEventOrAnnouncement =
            notification.type == 'event' || notification.type == 'announcement';
        final bool shouldMark = !notification.isRead || isEventOrAnnouncement;

        if (shouldMark) {
          final Map<String, dynamic> payload = {};

          // CRITICAL: For events and announcements, ALWAYS use type and related_id
          // (even if they have an id, they should be marked by type/related_id)
          if (isEventOrAnnouncement && notification.relatedId != null) {
            payload['type'] = notification.type;
            payload['related_id'] = notification.relatedId;
            debugPrint(
              '  → ${notification.type} (related_id: ${notification.relatedId}): ${notification.title}',
            );
          }
          // Regular notifications use notification_id (if id is valid)
          else if (notification.id != 0) {
            payload['notification_id'] = notification.id;
            debugPrint(
              '  → Notification ID ${notification.id}: ${notification.title}',
            );
          }
          // Fallback: if no valid id but has type and related_id, use those
          else if (notification.type.isNotEmpty &&
              notification.relatedId != null) {
            payload['type'] = notification.type;
            payload['related_id'] = notification.relatedId;
            debugPrint(
              '  → ${notification.type} (related_id: ${notification.relatedId}): ${notification.title}',
            );
          } else {
            debugPrint(
              '  ⚠️ Skipping notification without valid identifiers: ${notification.title}',
            );
            debugPrint(
              '     ID: ${notification.id}, Type: ${notification.type}, RelatedId: ${notification.relatedId}',
            );
          }

          // Only add if we have valid parameters
          if (payload.isNotEmpty) {
            notificationsToMark.add(payload);
          }
        }
      }

      debugPrint(
        '📊 Found ${notificationsToMark.length} notifications to mark individually',
      );

      // Step 3: Mark each individual notification
      if (notificationsToMark.isNotEmpty) {
        debugPrint('📤 Step 3: Marking individual notifications...');
        final markPromises = <Future<void>>[];

        for (final payload in notificationsToMark) {
          markPromises.add(_markIndividualNotification(payload));
        }

        // Wait for all individual marks to complete
        await Future.wait(markPromises);
        debugPrint('✅ Step 3 complete: All individual marks processed');
      } else {
        debugPrint('ℹ️ Step 3: No individual notifications to mark');
      }

      // Step 4: Update local state - mark all as read
      debugPrint('🔄 Step 4: Updating local state...');
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadNotificationsCount = 0;

      // Step 5: Reload notifications to get fresh data from server
      debugPrint('🔄 Step 5: Reloading notifications from server...');
      await fetchNotifications();

      debugPrint('✅ ========== MARK ALL COMPLETE ==========');
      debugPrint('📊 Final unread count: $_unreadNotificationsCount');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  // Helper method to mark individual notification (used by markAllNotificationsAsRead)
  Future<void> _markIndividualNotification(Map<String, dynamic> payload) async {
    try {
      debugPrint('  📤 Marking individual: $payload');

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/counselor/notifications/mark-read',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      debugPrint('  📥 Response status: ${response.statusCode}');
      debugPrint('  📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != 'success' && data['success'] != true) {
          debugPrint(
            '  ⚠️ Warning: Individual mark failed for payload: $payload',
          );
          debugPrint('  ⚠️ Error message: ${data['message'] ?? 'Unknown'}');
        } else {
          debugPrint('  ✅ Individual mark succeeded for: $payload');
        }
      } else {
        debugPrint(
          '  ⚠️ Warning: Individual mark request failed (${response.statusCode}) for: $payload',
        );
      }
    } catch (error) {
      debugPrint(
        '  ❌ Error marking individual notification: $error for payload: $payload',
      );
    }
  }

  // Fetch appointment details by ID
  Future<Map<String, dynamic>?> fetchAppointmentDetails(
    String appointmentId,
  ) async {
    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/appointments/getAppointments',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['appointments'] != null) {
          final appointments = data['appointments'] as List<dynamic>;
          try {
            final appointment = appointments.firstWhere(
              (app) => app['id'].toString() == appointmentId.toString(),
            );
            if (appointment != null) {
              return appointment as Map<String, dynamic>;
            }
          } catch (e) {
            debugPrint('Appointment not found: $appointmentId');
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching appointment details: $e');
      return null;
    }
  }

  // Drawer methods
  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  void closeDrawer() {
    _isDrawerOpen = false;
    notifyListeners();
  }

  // Chat methods
  void toggleChat() {
    _isChatOpen = !_isChatOpen;
    if (_isChatOpen) {
      _isNotificationsOpen = false;
    }
    notifyListeners();
  }

  void closeChat() {
    _isChatOpen = false;
    notifyListeners();
  }

  // Notifications methods
  void toggleNotifications() {
    _isNotificationsOpen = !_isNotificationsOpen;
    if (_isNotificationsOpen) {
      _isChatOpen = false;
    }
    notifyListeners();
  }

  void closeNotifications() {
    _isNotificationsOpen = false;
    notifyListeners();
  }

  // Navigation methods
  void navigateToAnnouncements(BuildContext context) {
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/counselor/announcements');
    }
  }

  void navigateToScheduledAppointments(BuildContext context) {
    if (context.mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/counselor/appointments/scheduled',
      );
    }
  }

  void navigateToFollowUpSessions(BuildContext context) {
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/counselor/follow-up');
    }
  }

  void navigateToProfile(BuildContext context) {
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/counselor/profile');
    }
  }

  void logout(BuildContext context) async {
    debugPrint('🚪 Counselor ViewModel: logout started');
    try {
      debugPrint('🚪 Counselor ViewModel: calling logout endpoint...');
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/auth/logout',
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('🚪 Counselor ViewModel: logout response status: ${response.statusCode}');
    } catch (e) {
      debugPrint('🚪 Counselor ViewModel: error calling logout endpoint: $e');
    }

    // Clear session cookies
    debugPrint('🚪 Counselor ViewModel: clearing session cookies');
    _session.clearCookies();

    // Wait a brief moment to ensure any UI updates complete
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate back to landing page using centralized navigation helper
    debugPrint('🚪 Counselor ViewModel: navigating to landing page');
    AppRoutes.navigateToLandingRoot();
    debugPrint('🚪 Counselor ViewModel: navigation called');
  }

  // Fetch recent pending appointments
  Future<void> fetchRecentAppointments() async {
    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/counselor/dashboard/recent-pending-appointments',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _recentAppointments = data['appointments'] ?? [];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching recent appointments: $e');
    }
  }

  // Polling Methods
  void startPolling() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchNotifications();
    });
  }

  void stopPolling() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }
}
