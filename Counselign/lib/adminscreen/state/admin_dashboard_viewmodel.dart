import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import '../../api/config.dart';
import '../models/admin_profile.dart';
import '../models/message.dart';
import '../models/appointment.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  // Admin profile data
  AdminProfile? _adminProfile;
  AdminProfile? get adminProfile => _adminProfile;

  String? _lastLogin;
  String? get lastLogin => _lastLogin;

  // Loading states
  bool _isLoadingProfile = true;
  bool get isLoadingProfile => _isLoadingProfile;

  bool _isLoadingMessages = true;
  bool get isLoadingMessages => _isLoadingMessages;

  bool _isLoadingAppointments = true;
  bool get isLoadingAppointments => _isLoadingAppointments;

  // Data
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  int _unreadMessagesCount = 0;
  int get unreadMessagesCount => _unreadMessagesCount;

  // Chart data
  final Map<String, dynamic> _chartData = {};
  Map<String, dynamic> get chartData => _chartData;

  // Filters
  String _selectedTimeRange = 'weekly';
  String get selectedTimeRange => _selectedTimeRange;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedMonth = '';
  String get selectedMonth => _selectedMonth;

  // Timers for real-time updates
  Timer? _messagesTimer;
  Timer? _appointmentsTimer;
  Timer? _profileTimer;

  void initialize() {
    fetchAdminProfile();
    fetchMessages();
    fetchAppointments();

    // Set up real-time updates like JavaScript
    _messagesTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchMessages();
    });

    _appointmentsTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      fetchAppointments();
    });

    _profileTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      fetchAdminProfile();
    });
  }

  // Fetch admin profile - matches loadAdminData() from JavaScript
  Future<void> fetchAdminProfile() async {
    try {
      _isLoadingProfile = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/dashboard/data'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final adminData = data['data'];
          _adminProfile = AdminProfile.fromJson(adminData);
          _lastLogin = _formatDateTime(adminData['last_login']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching admin profile: $e');
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // Fetch messages
  Future<void> fetchMessages() async {
    try {
      _isLoadingMessages = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/messages/get'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _messages =
              (data['messages'] as List?)
                  ?.map((m) => Message.fromJson(m))
                  .toList() ??
              [];
          _unreadMessagesCount = _messages.where((m) => !m.isRead).length;
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // Fetch appointments - matches loadAppointments() from JavaScript
  Future<void> fetchAppointments() async {
    try {
      _isLoadingAppointments = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/admin/appointments/get_all_appointments',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _appointments =
              (data['appointments'] as List?)
                  ?.map((a) => Appointment.fromJson(a))
                  .toList() ??
              [];
        }
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      _isLoadingAppointments = false;
      notifyListeners();
    }
  }

  // Update time range filter
  void updateTimeRange(String timeRange) {
    _selectedTimeRange = timeRange;
    notifyListeners();
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Update month filter
  void updateMonthFilter(String month) {
    _selectedMonth = month;
    notifyListeners();
  }

  // Format date time - matches formatDateTime() from JavaScript
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'Never';
    try {
      final date = DateTime.parse(dateTimeStr);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Mark message as read
  Future<bool> markMessageAsRead(int messageId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/messages/mark-read'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'message_id': messageId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final messageIndex = _messages.indexWhere((m) => m.id == messageId);
          if (messageIndex != -1) {
            _messages[messageIndex] = _messages[messageIndex].copyWith(
              isRead: true,
            );
            _unreadMessagesCount = _messages.where((m) => !m.isRead).length;
            notifyListeners();
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error marking message as read: $e');
      return false;
    }
  }

  // Get recent messages (limit to 2 for dashboard)
  List<Message> getRecentMessages() {
    return _messages.take(2).toList();
  }

  // Get recent appointments (limit to 2 for dashboard)
  List<Appointment> getRecentAppointments() {
    return _appointments.take(2).toList();
  }

  // Get statistics for dashboard
  Map<String, int> getStatistics() {
    final completed = _appointments
        .where((a) => a.status.toLowerCase() == 'completed')
        .length;
    final approved = _appointments
        .where((a) => a.status.toLowerCase() == 'approved')
        .length;
    final rejected = _appointments
        .where((a) => a.status.toLowerCase() == 'rejected')
        .length;
    final pending = _appointments
        .where((a) => a.status.toLowerCase() == 'pending')
        .length;
    final cancelled = _appointments
        .where((a) => a.status.toLowerCase() == 'cancelled')
        .length;

    return {
      'completed': completed,
      'approved': approved,
      'rejected': rejected,
      'pending': pending,
      'cancelled': cancelled,
    };
  }

  // Get appointments by status
  List<Appointment> getAppointmentsByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _appointments;
    }
    return _appointments
        .where((a) => a.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // Update appointment status - matches updateAppointmentStatus() from JavaScript
  Future<bool> updateAppointmentStatus(
    int appointmentId,
    String newStatus,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/update_appointment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'appointment_id': appointmentId,
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Refresh appointments to reflect changes
          await fetchAppointments();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating appointment status: $e');
      return false;
    }
  }

  // Get filtered appointments based on search and month
  List<Appointment> getFilteredAppointments(String status) {
    List<Appointment> filtered = getAppointmentsByStatus(status);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((appointment) {
        return appointment.userName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            appointment.preferredDate.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (appointment.consultationType?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ==
                true) ||
            (appointment.description?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ==
                true);
      }).toList();
    }

    // Apply month filter
    if (_selectedMonth.isNotEmpty) {
      filtered = filtered.where((appointment) {
        return appointment.preferredDate.startsWith(_selectedMonth);
      }).toList();
    }

    return filtered;
  }

  // Get chart data for line chart - returns simple data structure
  List<Map<String, double>> getLineChartData(String status) {
    final stats = getStatistics();
    return [
      {'x': 0, 'y': stats['completed']?.toDouble() ?? 0},
      {'x': 1, 'y': stats['approved']?.toDouble() ?? 0},
      {'x': 2, 'y': stats['pending']?.toDouble() ?? 0},
      {'x': 3, 'y': stats['rejected']?.toDouble() ?? 0},
      {'x': 4, 'y': stats['cancelled']?.toDouble() ?? 0},
    ];
  }

  // Get pie chart data - returns simple data structure
  List<Map<String, dynamic>> getPieChartData() {
    final stats = getStatistics();
    final total = stats.values.fold(0, (sum, count) => sum + count);

    if (total == 0) return [];

    return [
      {
        'value': stats['completed']?.toDouble() ?? 0,
        'title': 'Completed',
        'color': const Color(0xFF28A745),
      },
      {
        'value': stats['approved']?.toDouble() ?? 0,
        'title': 'Approved',
        'color': const Color(0xFF007BFF),
      },
      {
        'value': stats['pending']?.toDouble() ?? 0,
        'title': 'Pending',
        'color': const Color(0xFFFFC107),
      },
      {
        'value': stats['rejected']?.toDouble() ?? 0,
        'title': 'Rejected',
        'color': const Color(0xFFDC3545),
      },
      {
        'value': stats['cancelled']?.toDouble() ?? 0,
        'title': 'Cancelled',
        'color': const Color(0xFF6C757D),
      },
    ];
  }

  @override
  void dispose() {
    // Clean up timers
    _messagesTimer?.cancel();
    _appointmentsTimer?.cancel();
    _profileTimer?.cancel();
    super.dispose();
  }
}
