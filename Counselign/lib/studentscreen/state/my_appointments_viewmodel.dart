import 'package:flutter/material.dart';
import '../../routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/appointment.dart';
import '../models/counselor_availability.dart';
import '../models/counselor_schedule.dart';

class MyAppointmentsViewModel extends ChangeNotifier {
  final Session _session = Session();
  bool _disposed = false;

  // Appointments data
  List<Appointment> _allAppointments = [];
  List<Appointment> get allAppointments => _allAppointments;

  List<Counselor> _counselors = [];
  List<Counselor> get counselors => _counselors;

  // Loading states
  bool _isLoadingAppointments = true;
  bool get isLoadingAppointments => _isLoadingAppointments;

  bool _isLoadingCounselors = false;
  bool get isLoadingCounselors => _isLoadingCounselors;

  bool _isUpdatingAppointment = false;
  bool get isUpdatingAppointment => _isUpdatingAppointment;

  bool _isCancellingAppointment = false;
  bool get isCancellingAppointment => _isCancellingAppointment;

  bool _isDeletingAppointment = false;
  bool get isDeletingAppointment => _isDeletingAppointment;

  // Filter states
  String _searchTerm = '';
  String get searchTerm => _searchTerm;

  String _dateFilter = '';
  String get dateFilter => _dateFilter;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // Calendar state
  bool _isCalendarVisible = false;
  bool get isCalendarVisible => _isCalendarVisible;

  DateTime _currentCalendarDate = DateTime.now();
  DateTime get currentCalendarDate => _currentCalendarDate;

  // Calendar stats cache keyed by YYYY-MM
  final Map<String, Map<String, dynamic>> _calendarStatsCache = {};
  Map<String, dynamic> _currentMonthStats = {};
  Map<String, dynamic> get currentMonthStats => _currentMonthStats;

  // Memoized schedules future to avoid refetch loop in UI
  Future<Map<String, List<CounselorSchedule>>>? _schedulesFuture;

  // Modal states
  bool _showEditModal = false;
  bool get showEditModal => _showEditModal;

  bool _showCancelModal = false;
  bool get showCancelModal => _showCancelModal;

  bool _showSaveChangesModal = false;
  bool get showSaveChangesModal => _showSaveChangesModal;

  bool _showCancellationReasonModal = false;
  bool get showCancellationReasonModal => _showCancellationReasonModal;

  bool _showDeleteModal = false;
  bool get showDeleteModal => _showDeleteModal;

  // Current appointment being edited
  Appointment? _currentAppointment;
  Appointment? get currentAppointment => _currentAppointment;

  // Form controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController dateFilterController = TextEditingController();
  final TextEditingController editDateController = TextEditingController();
  final TextEditingController editTimeController = TextEditingController();
  final TextEditingController editConsultationTypeController =
      TextEditingController();
  final TextEditingController editDescriptionController =
      TextEditingController();
  final TextEditingController cancelReasonController = TextEditingController();
  final TextEditingController cancellationReasonController =
      TextEditingController();

  // Pending appointment editing
  final Map<int, bool> _editingStates = {};
  final Map<String, TextEditingController> _pendingControllers = {};

  void initialize() {
    fetchAppointments();
    fetchCounselors();
  }

  @override
  void dispose() {
    _disposed = true;
    searchController.dispose();
    dateFilterController.dispose();
    editDateController.dispose();
    editTimeController.dispose();
    editConsultationTypeController.dispose();
    editDescriptionController.dispose();
    cancelReasonController.dispose();
    cancellationReasonController.dispose();
    for (var controller in _pendingControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Fetch appointments
  Future<void> fetchAppointments() async {
    try {
      _isLoadingAppointments = true;
      _safeNotifyListeners();

      final url =
          '${ApiConfig.currentBaseUrl}/student/appointments/get-my-appointments';
      debugPrint('Fetching appointments from: $url');

      final response = await _session.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Parsed data: $data');

        if (data['success'] == true) {
          _allAppointments =
              (data['appointments'] as List?)
                  ?.map((a) => Appointment.fromJson(a))
                  .toList() ??
              [];
          debugPrint('Loaded ${_allAppointments.length} appointments');
        } else {
          debugPrint(
            'API returned success: false, message: ${data['message']}',
          );
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      _isLoadingAppointments = false;
      _safeNotifyListeners();
    }
  }

  // Fetch counselors
  Future<void> fetchCounselors() async {
    if (_counselors.isNotEmpty) return;

    try {
      _isLoadingCounselors = true;
      _safeNotifyListeners();

      final url = '${ApiConfig.currentBaseUrl}/student/get-counselors';
      debugPrint('Fetching counselors from: $url');

      final response = await _session.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      debugPrint('Counselors response status: ${response.statusCode}');
      debugPrint('Counselors response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _counselors =
              (data['counselors'] as List?)
                  ?.map((c) => Counselor.fromJson(c))
                  .toList() ??
              [];
          debugPrint('Loaded ${_counselors.length} counselors');
        } else {
          debugPrint(
            'Counselors API returned status: ${data['status']}, message: ${data['message']}',
          );
        }
      } else {
        debugPrint('Counselors HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching counselors: $e');
    } finally {
      _isLoadingCounselors = false;
      _safeNotifyListeners();
    }
  }

  // Fetch counselors by availability for specific date and time
  Future<void> fetchCounselorsByAvailability(String date, String time) async {
    try {
      _isLoadingCounselors = true;
      _safeNotifyListeners();

      final dayOfWeek = _getDayOfWeek(date);
      final timeBounds = _extractTimeBounds(time);

      final uri =
          Uri.parse(
            '${ApiConfig.currentBaseUrl}/student/get-counselors-by-availability',
          ).replace(
            queryParameters: {
              'date': date,
              'day': dayOfWeek,
              'time': time,
              if (timeBounds != null) ...{
                'from': timeBounds['start'],
                'to': timeBounds['end'],
                'timeMode': 'overlap',
              },
            },
          );

      final response = await _session.get(
        uri.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _counselors =
              (data['counselors'] as List?)
                  ?.map((c) => Counselor.fromJson(c))
                  .toList() ??
              [];
          debugPrint(
            'Found ${_counselors.length} available counselors for $date $time',
          );
        } else {
          debugPrint(
            'Error fetching counselors by availability: ${data['message']}',
          );
        }
      } else {
        debugPrint(
          'Error fetching counselors by availability: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching counselors by availability: $e');
    } finally {
      _isLoadingCounselors = false;
      _safeNotifyListeners();
    }
  }

  // Extract time bounds from time string (e.g., "8:00 AM - 9:00 AM")
  Map<String, String>? _extractTimeBounds(String timeString) {
    if (timeString.isEmpty) return null;

    final parts = timeString.split(' - ');
    if (parts.length != 2) return null;

    final start = _convertTo24Hour(parts[0].trim());
    final end = _convertTo24Hour(parts[1].trim());

    if (start == null || end == null) return null;

    return {'start': start, 'end': end};
  }

  // Convert 12-hour time to 24-hour format
  String? _convertTo24Hour(String time12) {
    final regex = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    );
    final match = regex.firstMatch(time12);

    if (match == null) return null;

    final hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!.toUpperCase();

    int hour24 = hour;
    if (period == 'AM' && hour == 12) {
      hour24 = 0;
    } else if (period == 'PM' && hour != 12) {
      hour24 = hour + 12;
    }

    return '${hour24.toString().padLeft(2, '0')}:$minute';
  }

  // Filter appointments
  void updateSearchTerm(String term) {
    _searchTerm = term;
    _safeNotifyListeners();
  }

  void updateDateFilter(String date) {
    if (date.isEmpty) {
      _dateFilter = '';
    } else {
      // Normalize to YYYY-MM only
      final normalized = date.length >= 7 ? date.substring(0, 7) : date;
      _dateFilter = normalized;
      // Also normalize the controller text if it was set externally
      if (dateFilterController.text != normalized) {
        dateFilterController.text = normalized;
      }
    }
    _safeNotifyListeners();
  }

  void updateSelectedTab(int index) {
    _selectedTabIndex = index;
    _safeNotifyListeners();
  }

  List<Appointment> getFilteredAppointments() {
    // 1) Apply status scope first (tab)
    List<Appointment> filtered;
    switch (_selectedTabIndex) {
      case 1: // Completed
        filtered = _allAppointments
            .where((a) => a.status?.toUpperCase() == 'COMPLETED')
            .toList();
        break;
      case 2: // Cancelled
        filtered = _allAppointments
            .where((a) => a.status?.toUpperCase() == 'CANCELLED')
            .toList();
        break;
      case 3: // Rejected
        filtered = _allAppointments
            .where((a) => a.status?.toUpperCase() == 'REJECTED')
            .toList();
        break;
      default: // All
        filtered = List<Appointment>.from(_allAppointments);
        break;
    }

    // 2) Apply monthly date filter (YYYY-MM)
    if (_dateFilter.isNotEmpty) {
      filtered = filtered.where((appointment) {
        final String ym = _extractYearMonth(appointment.preferredDate);
        return ym == _dateFilter;
      }).toList();
    }

    // 3) Apply search filter within the already-scoped set
    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      filtered = filtered.where((appointment) {
        final type = appointment.consultationType?.toLowerCase() ?? '';
        final counselor = appointment.counselorName?.toLowerCase() ?? '';
        final desc = appointment.description?.toLowerCase() ?? '';
        final method = appointment.methodType?.toLowerCase() ?? '';
        final purpose = appointment.purpose?.toLowerCase() ?? '';
        return type.contains(term) ||
            counselor.contains(term) ||
            desc.contains(term) ||
            method.contains(term) ||
            purpose.contains(term);
      }).toList();
    }

    return filtered;
  }

  // Extract YYYY-MM from a date string robustly
  String _extractYearMonth(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    var s = dateStr.trim();

    // If there is a time component, keep only the date part first
    if (s.contains(' ')) {
      s = s.split(' ').first;
    }

    // Try ISO parse first (e.g., 2025-11-17 or 2025-11-17T00:00:00Z)
    try {
      final dt = DateTime.parse(s);
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      // Fallback to substring if looks like YYYY-MM-...
      if (s.length >= 7 && RegExp(r'^\d{4}-\d{2}').hasMatch(s)) {
        return s.substring(0, 7);
      }

      // Try common MM/DD/YYYY
      final mdY = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
      final m1 = mdY.firstMatch(s);
      if (m1 != null) {
        final int year = int.tryParse(m1.group(3) ?? '') ?? 0;
        final int month = int.tryParse(m1.group(1) ?? '') ?? 0;
        if (year > 0 && month > 0) {
          return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
        }
      }

      // Try common DD/MM/YYYY (e.g., 17/11/2025)
      final dMY = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
      final m2 = dMY.firstMatch(s);
      if (m2 != null) {
        final int year = int.tryParse(m2.group(3) ?? '') ?? 0;
        final int month = int.tryParse(m2.group(2) ?? '') ?? 0;
        if (year > 0 && month > 0) {
          return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
        }
      }

      return '';
    }
  }

  List<Appointment> getPendingAppointments() {
    return _allAppointments
        .where((a) => a.status?.toUpperCase() == 'PENDING')
        .toList();
  }

  List<Appointment> getApprovedAppointments() {
    return _allAppointments
        .where((a) => a.status?.toUpperCase() == 'APPROVED')
        .toList();
  }

  // Calendar functionality
  void toggleCalendar() {
    _isCalendarVisible = !_isCalendarVisible;
    if (_isCalendarVisible) {
      // Prefetch month stats when opening
      fetchCalendarStatsForMonth(_currentCalendarDate);
      _schedulesFuture ??= fetchCounselorSchedules();
    }
    _safeNotifyListeners();
  }

  void setCalendarDate(DateTime date) {
    _currentCalendarDate = date;
    _safeNotifyListeners();
  }

  // ===== Calendar daily stats =====
  Future<void> fetchCalendarStatsForMonth(DateTime date) async {
    try {
      final String key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (_calendarStatsCache.containsKey(key)) {
        _currentMonthStats = _calendarStatsCache[key]!;
        _safeNotifyListeners();
        return;
      }
      final uri =
          Uri.parse(
            '${ApiConfig.currentBaseUrl}/student/calendar/daily-stats',
          ).replace(
            queryParameters: {
              'year': date.year.toString(),
              'month': date.month.toString(),
            },
          );
      final resp = await _session.get(
        uri.toString(),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data?['status'] == 'success' && data?['stats'] is Map) {
          final Map<String, dynamic> stats = Map<String, dynamic>.from(
            data['stats'] as Map,
          );
          _calendarStatsCache[key] = stats;
          _currentMonthStats = stats;
        } else {
          _currentMonthStats = {};
        }
      } else {
        _currentMonthStats = {};
      }
    } catch (e) {
      debugPrint('Error fetching calendar stats: $e');
      _currentMonthStats = {};
    } finally {
      _safeNotifyListeners();
    }
  }

  Map<String, dynamic>? getStatsForDate(DateTime date) {
    final String iso =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _currentMonthStats[iso] as Map<String, dynamic>?;
  }

  void setUpdatingAppointment(bool value) {
    _isUpdatingAppointment = value;
    _safeNotifyListeners();
  }

  void setCancellingAppointment(bool value) {
    _isCancellingAppointment = value;
    _safeNotifyListeners();
  }

  // Fetch counselor availability for calendar date
  Future<List<CounselorAvailability>> fetchCounselorAvailabilityForDate(
    DateTime date,
  ) async {
    try {
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayOfWeek = _getDayOfWeek(formattedDate);

      // First, get available counselors for the date
      final uri =
          Uri.parse(
            '${ApiConfig.currentBaseUrl}/student/get-counselors-by-availability',
          ).replace(
            queryParameters: {
              'date': formattedDate,
              'day': dayOfWeek,
              'time': '00:00-23:59',
              'from': '00:00',
              'to': '23:59',
              'timeMode': 'overlap',
            },
          );

      final response = await _session.get(
        uri.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Counselor availability response: $data');
        if (data['status'] == 'success') {
          final counselors = (data['counselors'] as List?) ?? [];
          debugPrint(
            'Found ${counselors.length} counselors for date: $formattedDate',
          );

          // Now fetch individual counselor availability with schedule
          final counselorsWithSchedule = <CounselorAvailability>[];

          for (var counselor in counselors) {
            try {
              // Fetch individual counselor availability using the counselor availability endpoint
              final counselorId = counselor['counselor_id'] ?? counselor['id'];
              if (counselorId != null) {
                final availabilityUri =
                    Uri.parse(
                      '${ApiConfig.currentBaseUrl}/counselor/profile/availability',
                    ).replace(
                      queryParameters: {'counselorId': counselorId.toString()},
                    );

                final availabilityResponse = await _session.get(
                  availabilityUri.toString(),
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                  },
                );

                if (availabilityResponse.statusCode == 200) {
                  final availabilityData = json.decode(
                    availabilityResponse.body,
                  );
                  debugPrint(
                    'Counselor $counselorId availability: $availabilityData',
                  );

                  if (availabilityData['success'] == true &&
                      availabilityData['availability'] != null) {
                    final availability = availabilityData['availability'];
                    final dayAvailability = availability[dayOfWeek] ?? [];

                    // Extract time_scheduled from the day's availability
                    String? timeSchedule;
                    if (dayAvailability.isNotEmpty) {
                      final timeSlots = dayAvailability
                          .map((slot) => slot['time_scheduled'])
                          .where(
                            (time) =>
                                time != null && time.toString().isNotEmpty,
                          )
                          .toList();

                      if (timeSlots.isNotEmpty) {
                        timeSchedule = timeSlots.join(', ');
                      }
                    }

                    final counselorWithSchedule = CounselorAvailability(
                      counselorId: counselorId.toString(),
                      name: counselor['name'] ?? '',
                      specialization:
                          counselor['specialization'] ?? 'General Counseling',
                      timeSchedule: timeSchedule,
                    );

                    counselorsWithSchedule.add(counselorWithSchedule);
                  }
                }
              }
            } catch (e) {
              debugPrint(
                'Error fetching availability for counselor ${counselor['name']}: $e',
              );
            }
          }

          return counselorsWithSchedule;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching counselor availability for date: $e');
      return [];
    }
  }

  String _getDayOfWeek(String dateString) {
    final date = DateTime.parse(dateString);
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[date.weekday % 7];
  }

  // Fetch counselor schedules organized by weekday
  Future<Map<String, List<CounselorSchedule>>> fetchCounselorSchedules() async {
    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/get-counselor-schedules',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Counselor schedules response: $data');

        if (data['status'] == 'success' && data['schedules'] != null) {
          final schedules = <String, List<CounselorSchedule>>{};
          final schedulesData = data['schedules'] as Map<String, dynamic>;

          // Process each weekday
          for (final entry in schedulesData.entries) {
            final day = entry.key;
            final daySchedules =
                (entry.value as List?)
                    ?.map((schedule) => CounselorSchedule.fromJson(schedule))
                    .toList() ??
                [];
            schedules[day] = daySchedules;
          }

          debugPrint('Loaded counselor schedules for ${schedules.length} days');
          return schedules;
        } else {
          debugPrint('API returned error: ${data['message']}');
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching counselor schedules: $e');
      return {};
    }
  }

  // Expose memoized schedules future for UI
  Future<Map<String, List<CounselorSchedule>>> getCounselorSchedulesFuture() {
    _schedulesFuture ??= fetchCounselorSchedules();
    return _schedulesFuture!;
  }

  // Modal management
  void openEditModal(Appointment appointment) {
    _currentAppointment = appointment;
    editDateController.text = appointment.preferredDate ?? '';
    editTimeController.text = appointment.preferredTime ?? '';
    editConsultationTypeController.text = appointment.consultationType ?? '';
    editDescriptionController.text = appointment.description ?? '';
    _showEditModal = true;
    _safeNotifyListeners();
  }

  void closeEditModal() {
    _showEditModal = false;
    _currentAppointment = null;
    _safeNotifyListeners();
  }

  void openCancelModal(Appointment appointment) {
    _currentAppointment = appointment;
    cancelReasonController.clear();
    _showCancelModal = true;
    _safeNotifyListeners();
  }

  void closeCancelModal() {
    _showCancelModal = false;
    _currentAppointment = null;
    _safeNotifyListeners();
  }

  void openSaveChangesModal() {
    _showSaveChangesModal = true;
    _safeNotifyListeners();
  }

  void closeSaveChangesModal() {
    _showSaveChangesModal = false;
    _safeNotifyListeners();
  }

  void openCancellationReasonModal() {
    _showCancellationReasonModal = true;
    _safeNotifyListeners();
  }

  void closeCancellationReasonModal() {
    _showCancellationReasonModal = false;
    _safeNotifyListeners();
  }

  void openDeleteModal(Appointment appointment) {
    _currentAppointment = appointment;
    _showDeleteModal = true;
    _safeNotifyListeners();
  }

  void closeDeleteModal() {
    _showDeleteModal = false;
    _currentAppointment = null;
    _safeNotifyListeners();
  }

  // Pending appointment editing
  bool isEditing(int appointmentId) {
    return _editingStates[appointmentId] ?? false;
  }

  void toggleEditing(int appointmentId) {
    _editingStates[appointmentId] = !(_editingStates[appointmentId] ?? false);
    _safeNotifyListeners();
  }

  TextEditingController getPendingController(
    int appointmentId,
    String field,
    String initialValue,
  ) {
    final key = '${appointmentId}_$field';
    if (!_pendingControllers.containsKey(key)) {
      _pendingControllers[key] = TextEditingController(text: initialValue);
    }
    return _pendingControllers[key]!;
  }

  // Handle date and time changes for pending appointments
  void onPendingDateChanged(int appointmentId, String date) {
    final timeController = getPendingController(
      appointmentId,
      'preferred_time',
      '',
    );
    if (timeController.text.isNotEmpty) {
      fetchCounselorsByAvailability(date, timeController.text);
    }
  }

  void onPendingTimeChanged(int appointmentId, String time) {
    final dateController = getPendingController(
      appointmentId,
      'preferred_date',
      '',
    );
    if (dateController.text.isNotEmpty) {
      fetchCounselorsByAvailability(dateController.text, time);
    }
  }

  // ===== Available time slots (30-minute intervals) for pending/editing =====
  Future<List<String>> fetchAvailableHalfHourSlots({
    required String date,
    required String counselorId,
    required String consultationType,
    String? selectedTime,
  }) async {
    try {
      if (counselorId.isEmpty || counselorId == 'No preference') {
        return selectedTime != null && selectedTime.isNotEmpty
            ? [selectedTime]
            : <String>[];
      }

      final dayOfWeek = _getDayOfWeek(date);

      // Fetch counselor availability for day
      final availabilityResp = await _session.get(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/counselor/profile/availability?counselorId=$counselorId',
        ).toString(),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      List<String> ranges = [];
      if (availabilityResp.statusCode == 200) {
        final data = json.decode(availabilityResp.body);
        final daySchedule = (data?['availability']?[dayOfWeek] as List?) ?? [];
        final slotStrings = daySchedule
            .map((s) => s?['time_scheduled'])
            .where((v) => v != null && (v as String).isNotEmpty)
            .cast<String>()
            .toList();
        ranges = _generateHalfHourRangeUnion(slotStrings);
      }

      // Fetch booked times for date (and counselor)
      final bookedUri =
          Uri.parse(
            '${ApiConfig.currentBaseUrl}/student/appointments/booked-times',
          ).replace(
            queryParameters: {
              'date': date,
              'counselor_id': counselorId,
              if (consultationType.isNotEmpty)
                'consultation_type': consultationType,
            },
          );
      final bookedResp = await _session.get(
        bookedUri.toString(),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      final booked = <String>{};
      if (bookedResp.statusCode == 200) {
        final bookedData = json.decode(bookedResp.body);
        final bookedList = (bookedData?['booked'] as List?) ?? [];
        for (final b in bookedList) {
          if (b is String && b.isNotEmpty) booked.add(b);
        }
      }

      // Filter out booked
      final available = ranges.where((slot) => !booked.contains(slot)).toList();
      if (selectedTime != null && selectedTime.isNotEmpty) {
        if (!available.contains(selectedTime)) {
          available.insert(0, selectedTime);
        }
      }
      return available;
    } catch (e) {
      debugPrint('Error fetching half-hour slots: $e');
      return selectedTime != null && selectedTime.isNotEmpty
          ? [selectedTime]
          : <String>[];
    }
  }

  List<String> _generateHalfHourRangeUnion(List<String> slotStrings) {
    final Set<String> set = {};
    for (final s in slotStrings) {
      final str = s.trim();
      if (str.isEmpty) continue;
      if (str.contains('-')) {
        final parts = str.split('-');
        if (parts.length != 2) continue;
        final int? start = _parseTime12ToMinutes(parts[0].trim());
        final int? end = _parseTime12ToMinutes(parts[1].trim());
        if (start == null || end == null || end <= start) continue;
        for (int t = start; t + 30 <= end; t += 30) {
          final from = _formatMinutesTo12h(t);
          final to = _formatMinutesTo12h(t + 30);
          set.add('$from - $to');
        }
      }
    }
    final arr = set.toList();
    arr.sort((a, b) {
      final af = a.split('-').first.trim();
      final bf = b.split('-').first.trim();
      return (_parseTime12ToMinutes(af) ?? 0) -
          (_parseTime12ToMinutes(bf) ?? 0);
    });
    return arr;
  }

  int? _parseTime12ToMinutes(String t) {
    final m = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)\$',
    ).firstMatch(t.trim().toUpperCase());
    if (m == null) return null;
    int h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ampm = m.group(3)!;
    if (h == 12) h = 0;
    if (ampm == 'PM') h += 12;
    return h * 60 + min;
  }

  String _formatMinutesTo12h(int total) {
    final minutes = total % 60;
    final h24 = (total ~/ 60) % 24;
    final ampm = h24 >= 12 ? 'PM' : 'AM';
    int h12 = h24 % 12;
    if (h12 == 0) h12 = 12;
    final mm = minutes.toString().padLeft(2, '0');
    return '$h12:$mm $ampm';
  }

  // API operations
  Future<bool> updateAppointment(BuildContext context) async {
    if (_currentAppointment == null) return false;

    try {
      _isUpdatingAppointment = true;
      _safeNotifyListeners();

      final formData = {
        'appointment_id': _currentAppointment!.id.toString(),
        'preferred_date': editDateController.text,
        'preferred_time': editTimeController.text,
        'consultation_type': editConsultationTypeController.text,
        'description': editDescriptionController.text,
      };

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/appointments/update',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          closeEditModal();
          await fetchAppointments();
          if (context.mounted) {
            _showSnackBar(context, 'Appointment updated successfully');
          }
          return true;
        } else {
          if (context.mounted) {
            _showSnackBar(
              context,
              data['message'] ?? 'Failed to update appointment',
            );
          }
          return false;
        }
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');
      if (context.mounted) {
        _showSnackBar(
          context,
          'Failed to update appointment. Please try again later.',
        );
      }
      return false;
    } finally {
      _isUpdatingAppointment = false;
      _safeNotifyListeners();
    }
    return false;
  }

  Future<bool> updatePendingAppointment(
    BuildContext context,
    int appointmentId,
    Map<String, dynamic> formData,
  ) async {
    try {
      _isUpdatingAppointment = true;
      _safeNotifyListeners();

      final data = {
        'appointment_id': appointmentId.toString(),
        ...formData,
        'status': 'pending',
      };

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/appointments/update',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          await fetchAppointments();
          return true;
        } else {
          debugPrint('Update failed: ${responseData['message']}');
          return false;
        }
      } else {
        debugPrint('Update failed with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating pending appointment: $e');
      return false;
    } finally {
      _isUpdatingAppointment = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> cancelAppointment(
    BuildContext context,
    int appointmentId,
    String reason,
  ) async {
    try {
      debugPrint(
        'Starting cancellation for appointment $appointmentId with reason: $reason',
      );
      _isCancellingAppointment = true;
      _safeNotifyListeners();

      final formData = {
        'appointment_id': appointmentId.toString(),
        'reason': reason,
      };

      debugPrint('Sending cancellation request with data: $formData');

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/appointments/cancel',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode(formData),
      );

      debugPrint('Cancellation response status: ${response.statusCode}');
      debugPrint('Cancellation response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await fetchAppointments();
          return true;
        } else {
          debugPrint('Cancellation failed: ${data['message']}');
          return false;
        }
      } else {
        debugPrint(
          'Cancellation failed with status code: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      return false;
    } finally {
      _isCancellingAppointment = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> deleteAppointment(
    BuildContext context,
    int appointmentId,
  ) async {
    try {
      _isDeletingAppointment = true;
      _safeNotifyListeners();

      // Use regular http.delete with session cookies
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

      // Add session cookies if available
      if (_session.cookies.isNotEmpty) {
        final cookieString = _session.cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
        headers['Cookie'] = cookieString;
      }

      final response = await http.delete(
        Uri.parse(
          '${ApiConfig.currentBaseUrl}/student/appointments/delete/$appointmentId',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          closeDeleteModal();
          await fetchAppointments();
          if (context.mounted) {
            _showSnackBar(context, 'Appointment deleted successfully');
          }
          return true;
        } else {
          if (context.mounted) {
            _showSnackBar(
              context,
              data['message'] ?? 'Failed to delete appointment',
            );
          }
          return false;
        }
      }
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
      if (context.mounted) {
        _showSnackBar(
          context,
          'Failed to delete appointment. Please try again later.',
        );
      }
      return false;
    } finally {
      _isDeletingAppointment = false;
      _safeNotifyListeners();
    }
    return false;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Navigation
  void navigateToScheduleAppointment(BuildContext context) {
    Navigator.of(context).pushNamed('/user/schedule-appointment');
  }

  void navigateToDashboard(BuildContext context) {
    AppRoutes.navigateToDashboard(context);
  }
}
