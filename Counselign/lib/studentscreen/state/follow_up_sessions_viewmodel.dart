import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/appointment.dart';
import '../models/follow_up_appointment.dart';

class FollowUpSessionsViewModel extends ChangeNotifier {
  final Session _session = Session();
  final TextEditingController searchController = TextEditingController();

  // Data
  List<Appointment> _completedAppointments = [];
  List<Appointment> get completedAppointments => _completedAppointments;

  List<FollowUpAppointment> _followUpSessions = [];
  List<FollowUpAppointment> get followUpSessions => _followUpSessions;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingFollowUpSessions = false;
  bool get isLoadingFollowUpSessions => _isLoadingFollowUpSessions;

  // Error states
  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Modal states
  bool _showFollowUpSessionsModal = false;
  bool get showFollowUpSessionsModal => _showFollowUpSessionsModal;

  int? _selectedAppointmentId;
  int? get selectedAppointmentId => _selectedAppointmentId;

  // Search
  String _searchTerm = '';
  String get searchTerm => _searchTerm;

  // Debounced search
  Timer? _searchTimer;

  @override
  void dispose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  // Initialize the viewmodel
  void initialize() {
    loadCompletedAppointments();
  }

  // Load completed appointments
  Future<void> loadCompletedAppointments({String searchTerm = ''}) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      String url =
          '${ApiConfig.currentBaseUrl}/student/follow-up-sessions/completed-appointments';
      if (searchTerm.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(searchTerm)}';
      }

      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final appointments =
              (data['appointments'] as List?)
                  ?.map((a) => Appointment.fromJson(a))
                  .toList() ??
              [];

          _completedAppointments = appointments;
          _isLoading = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorMessage = data['message'] ?? 'Failed to load appointments';
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _hasError = true;
        _errorMessage = 'Server error: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error loading appointments: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search appointments with debouncing
  void searchAppointments(String searchTerm) {
    _searchTerm = searchTerm.toLowerCase();

    // Cancel previous timer
    _searchTimer?.cancel();

    // Set new timer for debounced search
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      loadCompletedAppointments(searchTerm: _searchTerm);
    });

    notifyListeners();
  }

  // Get filtered appointments based on search
  List<Appointment> get filteredAppointments {
    if (_searchTerm.isEmpty) {
      return _completedAppointments;
    }

    return _completedAppointments.where((appointment) {
      final searchLower = _searchTerm.toLowerCase();

      // Search in various fields
      final consultationType =
          appointment.consultationType?.toLowerCase() ?? '';
      final counselorName = appointment.counselorName?.toLowerCase() ?? '';
      final description = appointment.description?.toLowerCase() ?? '';
      final reason = appointment.reason?.toLowerCase() ?? '';
      final date = appointment.preferredDate?.toLowerCase() ?? '';
      final time = appointment.preferredTime?.toLowerCase() ?? '';
      final status = appointment.status?.toLowerCase() ?? '';

      return consultationType.contains(searchLower) ||
          counselorName.contains(searchLower) ||
          description.contains(searchLower) ||
          reason.contains(searchLower) ||
          date.contains(searchLower) ||
          time.contains(searchLower) ||
          status.contains(searchLower);
    }).toList();
  }

  // Get pending appointments (with pending follow-up sessions)
  List<Appointment> get pendingAppointments {
    return filteredAppointments.where((appointment) {
      return (appointment.pendingFollowUpCount ?? 0) > 0;
    }).toList();
  }

  // Get regular appointments (without pending follow-up sessions)
  List<Appointment> get regularAppointments {
    return filteredAppointments.where((appointment) {
      return (appointment.pendingFollowUpCount ?? 0) == 0;
    }).toList();
  }

  // Open follow-up sessions modal
  void openFollowUpSessionsModal(int appointmentId) {
    _selectedAppointmentId = appointmentId;
    _showFollowUpSessionsModal = true;
    _followUpSessions = [];
    notifyListeners();
    loadFollowUpSessions(appointmentId);
  }

  // Close follow-up sessions modal
  void closeFollowUpSessionsModal() {
    _showFollowUpSessionsModal = false;
    _selectedAppointmentId = null;
    _followUpSessions = [];
    notifyListeners();
  }

  // Load follow-up sessions for a specific appointment
  Future<void> loadFollowUpSessions(int parentAppointmentId) async {
    _isLoadingFollowUpSessions = true;
    notifyListeners();

    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/follow-up-sessions/sessions?parent_appointment_id=$parentAppointmentId',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final sessions =
              (data['follow_up_sessions'] as List?)
                  ?.map((s) => FollowUpAppointment.fromJson(s))
                  .toList() ??
              [];

          // Sort follow-up sessions: Pending/Latest on top, oldest at bottom
          sessions.sort((a, b) {
            // First, prioritize pending status
            final aIsPending = a.status.toLowerCase() == 'pending';
            final bIsPending = b.status.toLowerCase() == 'pending';

            if (aIsPending && !bIsPending) {
              return -1; // a (pending) comes before b
            }
            if (!aIsPending && bIsPending) {
              return 1; // b (pending) comes before a
            }

            // Both have same pending status, sort by date (descending - latest first)
            try {
              final aDate = DateTime.parse(a.preferredDate);
              final bDate = DateTime.parse(b.preferredDate);
              final dateComparison = bDate.compareTo(aDate);

              if (dateComparison != 0) {
                return dateComparison;
              }

              // If dates are equal, sort by time (descending - latest first)
              return b.preferredTime.compareTo(a.preferredTime);
            } catch (e) {
              // If date parsing fails, fall back to string comparison
              final dateComparison = b.preferredDate.compareTo(a.preferredDate);
              if (dateComparison != 0) {
                return dateComparison;
              }
              return b.preferredTime.compareTo(a.preferredTime);
            }
          });

          _followUpSessions = sessions;
          _isLoadingFollowUpSessions = false;
          notifyListeners();
        } else {
          _isLoadingFollowUpSessions = false;
          notifyListeners();
          // Show error message
          debugPrint('Error loading follow-up sessions: ${data['message']}');
        }
      } else {
        _isLoadingFollowUpSessions = false;
        notifyListeners();
        debugPrint(
          'Server error loading follow-up sessions: ${response.statusCode}',
        );
      }
    } catch (e) {
      _isLoadingFollowUpSessions = false;
      notifyListeners();
      debugPrint('Error loading follow-up sessions: $e');
    }
  }

  // Utility methods
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';

    // Time is already in 12-hour format with AM/PM, return as is
    return timeString;
  }

  // Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF64748B);
    }
  }

  // Get status icon
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
