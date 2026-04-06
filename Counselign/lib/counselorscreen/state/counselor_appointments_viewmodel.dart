import 'dart:convert';
import 'package:flutter/material.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/appointment.dart';

class CounselorAppointmentsViewModel extends ChangeNotifier {
  final List<CounselorAppointment> _allAppointments = <CounselorAppointment>[];
  List<CounselorAppointment> _visibleAppointments = <CounselorAppointment>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'pending'; // default to pending
  DateTimeRange? _dateRange;
  final Session _session = Session();

  // Loading states for individual operations
  String? _approvingAppointmentId;
  String? _rejectingAppointmentId;
  String? _cancellingAppointmentId;

  List<CounselorAppointment> get appointments => _visibleAppointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  DateTimeRange? get dateRange => _dateRange;

  // Loading state getters
  String? get approvingAppointmentId => _approvingAppointmentId;
  String? get rejectingAppointmentId => _rejectingAppointmentId;
  String? get cancellingAppointmentId => _cancellingAppointmentId;

  Map<String, int> get statusCounts {
    final Map<String, int> counts = {
      'pending': 0,
      'approved': 0,
      'rejected': 0,
      'completed': 0,
      'cancelled': 0,
    };
    for (final a in _allAppointments) {
      final s = a.status.toLowerCase();
      if (counts.containsKey(s)) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<void> initialize() async {
    await loadAppointments();
  }

  Future<void> loadAppointments() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Use explicit JSON endpoint to avoid HTML views
      final url = '${ApiConfig.currentBaseUrl}/counselor/appointments/getAll';
      final response = await _session
          .get(url, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('<')) {
          _errorMessage =
              'Not authenticated. Please log in as counselor and try again.';
          _allAppointments.clear();
          _applyFilters();
          return;
        }
        final Map<String, dynamic> data = json.decode(body);
        if ((data['status']?.toString() ?? '').toLowerCase() == 'success') {
          final List list = (data['appointments'] as List?) ?? <dynamic>[];
          _allAppointments
            ..clear()
            ..addAll(
              list.map((e) => CounselorAppointment.fromJson(e)).toList(),
            );
          _applyFilters();
        } else {
          _errorMessage =
              data['message']?.toString() ?? 'Failed to load appointments';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized access - Please log in as counselor';
      } else {
        _errorMessage = 'Failed to load appointments: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error loading appointments: $e';
    } finally {
      _setLoading(false);
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void updateStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
  }

  void updateDateRange(DateTimeRange? range) {
    _dateRange = range;
    _applyFilters();
  }

  void _applyFilters() {
    _visibleAppointments = _allAppointments.where((a) {
      final matchesStatus = _statusFilter.isEmpty
          ? true
          : a.status.toLowerCase() == _statusFilter.toLowerCase();
      final matchesQuery = a.matchesQuery(_searchQuery);
      final date = a.appointmentDate ?? a.preferredDate;
      final matchesDate = _dateRange == null
          ? true
          : (date != null &&
                !date.isBefore(_dateRange!.start) &&
                !date.isAfter(_dateRange!.end));
      return matchesStatus && matchesQuery && matchesDate;
    }).toList();
    notifyListeners();
  }

  Future<bool> approveAppointment(String appointmentId) async {
    _approvingAppointmentId = appointmentId;
    notifyListeners();

    try {
      final result = await _updateStatus(appointmentId, 'approved');
      return result;
    } finally {
      _approvingAppointmentId = null;
      notifyListeners();
    }
  }

  Future<bool> rejectAppointment(String appointmentId, String reason) async {
    _rejectingAppointmentId = appointmentId;
    notifyListeners();

    try {
      final result = await _updateStatus(
        appointmentId,
        'rejected',
        rejectionReason: reason,
      );
      return result;
    } finally {
      _rejectingAppointmentId = null;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String appointmentId, String reason) async {
    _cancellingAppointmentId = appointmentId;
    notifyListeners();

    try {
      final result = await _updateStatus(
        appointmentId,
        'cancelled',
        rejectionReason: reason,
      );
      return result;
    } finally {
      _cancellingAppointmentId = null;
      notifyListeners();
    }
  }

  Future<bool> _updateStatus(
    String appointmentId,
    String status, {
    String? rejectionReason,
  }) async {
    try {
      // Try primary endpoint
      final primaryUrl =
          '${ApiConfig.currentBaseUrl}/counselor/appointments/updateAppointmentStatus';
      final primaryBody = <String, String>{
        'appointment_id': appointmentId,
        'status': status,
        if (rejectionReason != null && rejectionReason.trim().isNotEmpty)
          'rejection_reason': rejectionReason.trim(),
      };
      final primaryResp = await _session
          .post(
            primaryUrl,
            headers: {
              ...ApiConfig.defaultHeaders,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: primaryBody,
          )
          .timeout(ApiConfig.connectTimeout);

      bool ok = false;
      if (primaryResp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(primaryResp.body);
        ok =
            (data['status']?.toString() ?? '').toLowerCase() == 'success' ||
            (data['success'] == true);
      }

      // Fallback to legacy endpoint signature
      if (!ok) {
        final fallbackUrl =
            '${ApiConfig.currentBaseUrl}/counselor/appointments/updateStatus';
        final fallbackBody = <String, String>{
          'id': appointmentId,
          'status': status,
        };
        final fallbackResp = await _session
            .post(
              fallbackUrl,
              headers: {
                ...ApiConfig.defaultHeaders,
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: fallbackBody,
            )
            .timeout(ApiConfig.connectTimeout);
        if (fallbackResp.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(fallbackResp.body);
          ok =
              (data['status']?.toString() ?? '').toLowerCase() == 'success' ||
              (data['success'] == true);
        }
      }

      if (ok) {
        await loadAppointments();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
