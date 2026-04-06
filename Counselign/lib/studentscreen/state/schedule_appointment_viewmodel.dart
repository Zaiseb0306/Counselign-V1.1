import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/appointment.dart';
import '../models/follow_up_appointment.dart';
import '../models/counselor_availability.dart';
import '../models/counselor_schedule.dart';

class ScheduleAppointmentViewModel extends ChangeNotifier {
  final Session _session = Session();
  bool _disposed = false;

  // Form controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController consultationTypeController =
      TextEditingController();
  // Method Type controller (In-person / Online ...)
  final TextEditingController methodTypeController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController counselorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Loading states
  bool _isLoadingCounselors = false;
  bool get isLoadingCounselors => _isLoadingCounselors;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isCheckingPending = false;
  bool get isCheckingPending => _isCheckingPending;

  // Data
  List<Counselor> _counselors = [];
  List<Counselor> get counselors => _counselors;

  // Time slots
  bool _isLoadingTimeSlots = false;
  bool get isLoadingTimeSlots => _isLoadingTimeSlots;

  List<String> _availableTimeSlots = [];
  List<String> get availableTimeSlots => _availableTimeSlots;

  bool _hasPendingAppointment = false;
  bool get hasPendingAppointment => _hasPendingAppointment;

  bool _hasApprovedAppointment = false;
  bool get hasApprovedAppointment => _hasApprovedAppointment;

  bool _hasPendingFollowUp = false;
  bool get hasPendingFollowUp => _hasPendingFollowUp;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _hasLoginError = false;
  bool get hasLoginError => _hasLoginError;

  String? _pendingAppointmentMessage;
  String? get pendingAppointmentMessage => _pendingAppointmentMessage;

  // Calendar state
  bool _isCalendarVisible = false;
  bool get isCalendarVisible => _isCalendarVisible;

  DateTime _currentCalendarDate = DateTime.now();
  DateTime get currentCalendarDate => _currentCalendarDate;

  // Calendar stats cache keyed by YYYY-MM -> { 'YYYY-MM-DD': {count:int, fullyBooked:bool} }
  final Map<String, Map<String, dynamic>> _calendarStatsCache = {};
  Map<String, dynamic> _currentMonthStats = {};
  Map<String, dynamic> get currentMonthStats => _currentMonthStats;

  // Form validation
  String? _dateError;
  String? get dateError => _dateError;

  String? _timeError;
  String? get timeError => _timeError;

  String? _consultationTypeError;
  String? get consultationTypeError => _consultationTypeError;

  String? _methodTypeError;
  String? get methodTypeError => _methodTypeError;

  String? _purposeError;
  String? get purposeError => _purposeError;

  String? _counselorError;
  String? get counselorError => _counselorError;

  // Consent validation
  bool _consentRead = false;
  bool get consentRead => _consentRead;

  bool _consentAccept = false;
  bool get consentAccept => _consentAccept;

  bool _showConsentError = false;
  bool get showConsentError => _showConsentError;

  // Message display
  String? _message;
  String? get message => _message;

  bool _isMessageError = false;
  bool get isMessageError => _isMessageError;

  void initialize() {
    _setMinimumDate();
    // Run eligibility check immediately and wait for it to complete
    checkAppointmentEligibility();
  }

  @override
  void dispose() {
    _disposed = true;
    dateController.dispose();
    timeController.dispose();
    consultationTypeController.dispose();
    methodTypeController.dispose();
    purposeController.dispose();
    counselorController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setMinimumDate() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final formattedDate =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    dateController.text = formattedDate;
    // Load initial time slots for default date
    refreshAvailableTimeSlotsForDate(formattedDate);
    _safeNotifyListeners();
  }

  // Check appointment eligibility (pending, approved, pending follow-up)
  Future<void> checkAppointmentEligibility() async {
    try {
      _isCheckingPending = true;
      _safeNotifyListeners();

      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/check-appointment-eligibility',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Eligibility check response: $data');
        if (data['status'] == 'success') {
          _isLoggedIn = true;
          _hasLoginError = false; // Clear login error when successful
          _hasPendingAppointment = data['hasPending'] ?? false;
          _hasApprovedAppointment = data['hasApproved'] ?? false;
          _hasPendingFollowUp = data['hasPendingFollowUp'] ?? false;
          debugPrint(
            'Appointment status - Pending: $_hasPendingAppointment, Approved: $_hasApprovedAppointment, Follow-up: $_hasPendingFollowUp',
          );
          debugPrint(
            'Login status: $_isLoggedIn, Login error: $_hasLoginError',
          );
          debugPrint('Current message: $_message');
          debugPrint(
            'Pending appointment message: $_pendingAppointmentMessage',
          );

          // Set appropriate message based on priority - only show appointment-specific messages
          if (_hasPendingFollowUp) {
            _pendingAppointmentMessage =
                'You have a pending follow-up session. Please complete or resolve it before scheduling a new appointment.';
            _message = _pendingAppointmentMessage;
            _isMessageError = true;
          } else if (_hasPendingAppointment) {
            _pendingAppointmentMessage =
                'You already have a pending appointment. Please wait for it to be approved before scheduling another one.';
            _message = _pendingAppointmentMessage;
            _isMessageError = true;
          } else if (_hasApprovedAppointment) {
            _pendingAppointmentMessage =
                'You already have an approved upcoming appointment. You cannot schedule another at this time.';
            _message = _pendingAppointmentMessage;
            _isMessageError = true;
          } else {
            // Clear any previous messages if user is eligible
            _message = null;
            _isMessageError = false;
          }

          // Only fetch counselors if eligible to book
          if (!_hasPendingAppointment &&
              !_hasApprovedAppointment &&
              !_hasPendingFollowUp) {
            await fetchCounselors();
            // Refresh time slots for current date
            if (dateController.text.isNotEmpty) {
              await refreshAvailableTimeSlotsForDate(dateController.text);
            }
          }
        } else {
          // If API returns error, show login message and disable form
          _isLoggedIn = false;
          _hasLoginError = true;
          _message =
              data['message'] ??
              'You must be logged in to schedule an appointment.';
          _isMessageError = true;
          // Don't set appointment flags for login errors
        }
      } else if (response.statusCode == 401) {
        _isLoggedIn = false;
        _hasLoginError = true;
        _message = 'You must be logged in to schedule an appointment.';
        _isMessageError = true;
        // Don't set appointment flags for login errors
      } else {
        _isLoggedIn = false;
        _hasLoginError = true;
        _message = 'Error checking appointment eligibility. Please try again.';
        _isMessageError = true;
        // Don't set appointment flags for errors
      }
    } catch (e) {
      debugPrint('Error checking appointment eligibility: $e');
      _isLoggedIn = false;
      _hasLoginError = true;
      _message = 'Error checking appointment eligibility. Please try again.';
      _isMessageError = true;
      // Don't set appointment flags for errors
    } finally {
      _isCheckingPending = false;
      _safeNotifyListeners();
    }
  }

  // Fetch counselors
  Future<void> fetchCounselors() async {
    try {
      _isLoadingCounselors = true;
      _safeNotifyListeners();

      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/get-counselors',
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
        } else {
          debugPrint('Error fetching counselors: ${data['message']}');
        }
      } else {
        debugPrint('Error fetching counselors: ${response.statusCode}');
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

  // Get day of week from date string
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

    int hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!.toUpperCase();

    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  // Consent validation methods
  void setConsentRead(bool value) {
    _consentRead = value;
    _updateConsentError();
    _safeNotifyListeners();
  }

  void setConsentAccept(bool value) {
    _consentAccept = value;
    _updateConsentError();
    _safeNotifyListeners();
  }

  void _updateConsentError() {
    _showConsentError = !_consentRead || !_consentAccept;
  }

  bool _validateConsent() {
    return _consentRead && _consentAccept;
  }

  // Form validation
  bool validateForm() {
    bool isValid = true;

    // Reset errors
    _dateError = null;
    _timeError = null;
    _consultationTypeError = null;
    _methodTypeError = null;
    _purposeError = null;
    _counselorError = null;

    // Validate date
    if (dateController.text.isEmpty) {
      _dateError = 'Please select a preferred date.';
      isValid = false;
    } else {
      final selectedDate = DateTime.tryParse(dateController.text);
      final today = DateTime.now();
      today.subtract(
        Duration(
          hours: today.hour,
          minutes: today.minute,
          seconds: today.second,
          milliseconds: today.millisecond,
          microseconds: today.microsecond,
        ),
      );

      if (selectedDate != null &&
          selectedDate.isBefore(today.add(const Duration(days: 1)))) {
        _dateError = 'Please select a future date for your appointment.';
        isValid = false;
      }
    }

    // Validate time
    if (timeController.text.isEmpty) {
      _timeError = 'Please select a preferred time.';
      isValid = false;
    }

    // Validate consultation type
    if (consultationTypeController.text.isEmpty) {
      _consultationTypeError = 'Please select a consultation type.';
      isValid = false;
    }

    // Validate method type
    if (methodTypeController.text.isEmpty) {
      _methodTypeError = 'Please select a method type.';
      isValid = false;
    }

    // Validate purpose
    if (purposeController.text.isEmpty) {
      _purposeError = 'Please select the purpose of your consultation.';
      isValid = false;
    }

    // Validate consent
    if (!_validateConsent()) {
      _showConsentError = true;
      isValid = false;
    } else {
      _showConsentError = false;
    }

    _safeNotifyListeners();
    return isValid;
  }

  // Submit appointment
  Future<bool> submitAppointment(BuildContext context) async {
    if (!validateForm()) return false;

    try {
      _isSubmitting = true;
      _message = null;
      _safeNotifyListeners();

      final formData = {
        'preferredDate': dateController.text,
        'preferredTime': timeController.text,
        'consultationType': consultationTypeController.text,
        'methodType': methodTypeController.text,
        'purpose': purposeController.text,
        'counselorPreference': counselorController.text.isEmpty
            ? 'No preference'
            : counselorController.text,
        'description': descriptionController.text,
        'consentRead': _consentRead ? '1' : '0',
        'consentAccept': _consentAccept ? '1' : '0',
      };

      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/appointment/save',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _message = data['message'] ?? 'Appointment scheduled successfully!';
          _isMessageError = false;

          // Show confirmation dialog
          // ignore: use_build_context_synchronously
          if (context.mounted) {
            _showConfirmationDialog(context);
          }

          // Reset form
          _resetForm();

          return true;
        } else {
          _message = data['message'] ?? 'Failed to schedule appointment.';
          _isMessageError = true;
          return false;
        }
      } else {
        final data = json.decode(response.body);
        _message = data['message'] ?? 'Failed to schedule appointment.';
        _isMessageError = true;
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting appointment: $e');
      _message = 'A server error occurred. Please try again later.';
      _isMessageError = true;
      return false;
    } finally {
      _isSubmitting = false;
      _safeNotifyListeners();
    }
  }

  void _resetForm() {
    _setMinimumDate();
    timeController.clear();
    consultationTypeController.clear();
    methodTypeController.clear();
    purposeController.clear();
    counselorController.clear();
    descriptionController.clear();
    _consentRead = false;
    _consentAccept = false;
    _showConsentError = false;
  }

  // Calendar functionality
  void toggleCalendar() {
    _isCalendarVisible = !_isCalendarVisible;
    debugPrint('Calendar visibility toggled to: $_isCalendarVisible');
    debugPrint(
      'Current appointment status - Pending: $_hasPendingAppointment, Approved: $_hasApprovedAppointment, Follow-up: $_hasPendingFollowUp',
    );
    // When opening the calendar, fetch stats for the current month once
    if (_isCalendarVisible) {
      // Do not await here to keep toggle responsive
      fetchCalendarStatsForMonth(_currentCalendarDate);
    }
    _safeNotifyListeners();
  }

  void setCalendarDate(DateTime date) {
    _currentCalendarDate = date;
    _safeNotifyListeners();
  }

  // Handle date and time changes to filter counselors
  void onDateChanged(String date) {
    if (timeController.text.isNotEmpty) {
      fetchCounselorsByAvailability(date, timeController.text);
    }
    refreshAvailableTimeSlotsForDate(date);
  }

  void onTimeChanged(String time) {
    if (dateController.text.isNotEmpty) {
      fetchCounselorsByAvailability(dateController.text, time);
    }
  }

  // ===== Time slots (30-min ranges) =====
  Future<void> refreshAvailableTimeSlotsForDate(String dateStr) async {
    try {
      _isLoadingTimeSlots = true;
      _availableTimeSlots = [];
      _safeNotifyListeners();

      // Derive weekday
      final dayOfWeek = _getDayOfWeek(dateStr);

      // Determine selected counselor (optional)
      final String selectedCounselorId = counselorController.text;

      // Determine selected consultation type (affects booked-time filtering)
      final String selectedConsultationType = consultationTypeController.text;

      final List<String> unionRanges = await _loadCounselorUnionRanges(
        dayOfWeek: dayOfWeek,
        counselorId: selectedCounselorId,
      );

      final List<String> bookedRanges = await _loadBookedRanges(
        dateStr: dateStr,
        counselorId: selectedCounselorId,
        consultationType: selectedConsultationType,
      );

      final Set<String> bookedSet = bookedRanges.toSet();
      final List<String> available = unionRanges
          .where((r) => !bookedSet.contains(r))
          .toList(growable: false);

      _availableTimeSlots = available;
    } catch (e) {
      debugPrint('Error refreshing time slots: $e');
      _availableTimeSlots = [];
    } finally {
      _isLoadingTimeSlots = false;
      _safeNotifyListeners();
    }
  }

  Future<List<String>> _loadCounselorUnionRanges({
    required String dayOfWeek,
    String? counselorId,
  }) async {
    try {
      // If a specific counselor is selected (and not "No preference"), query their availability
      if (counselorId != null &&
          counselorId.isNotEmpty &&
          counselorId.toLowerCase() != 'no preference') {
        final uri = Uri.parse(
          '${ApiConfig.currentBaseUrl}/counselor/profile/availability',
        ).replace(queryParameters: {'counselorId': counselorId});

        final resp = await _session.get(
          uri.toString(),
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        );
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          final List<dynamic> rows =
              ((data?['availability'] ?? const {})[dayOfWeek] as List?) ?? [];
          final List<String> slotStrings = rows
              .map((r) => r?['time_scheduled'])
              .where((t) => t != null && t.toString().isNotEmpty)
              .map<String>((t) => t.toString())
              .toList();
          return _generateHalfHourRangeUnion(slotStrings);
        }
      }

      // Else, union all counselors schedules for that day
      final resp = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/get-counselor-schedules',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final schedules = (data?['schedules'] ?? const {});
        final List<dynamic> counselorsForDay =
            (schedules[dayOfWeek] as List?) ?? [];
        final List<String> slotStrings = <String>[];
        for (final item in counselorsForDay) {
          final String ts = (item?['time_scheduled'] ?? '').toString();
          if (ts.isEmpty) continue;
          for (final s in ts.split(',')) {
            final v = s.trim();
            if (v.isNotEmpty) slotStrings.add(v);
          }
        }
        return _generateHalfHourRangeUnion(slotStrings);
      }
    } catch (e) {
      debugPrint('Error loading counselor union ranges: $e');
    }
    return [];
  }

  Future<List<String>> _loadBookedRanges({
    required String dateStr,
    String? counselorId,
    String? consultationType,
  }) async {
    try {
      final uri =
          Uri.parse(
            '${ApiConfig.currentBaseUrl}/student/appointments/booked-times',
          ).replace(
            queryParameters: {
              'date': dateStr,
              if (counselorId != null &&
                  counselorId.isNotEmpty &&
                  counselorId.toLowerCase() != 'no preference')
                'counselor_id': counselorId,
              if (consultationType != null && consultationType.isNotEmpty)
                'consultation_type': consultationType,
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
        final List<dynamic> booked = (data?['booked'] as List?) ?? [];
        return booked.map<String>((e) => e.toString()).toList(growable: false);
      }
    } catch (e) {
      debugPrint('Error loading booked ranges: $e');
    }
    return [];
  }

  // Utilities for 12h parsing and generating half-hour ranges
  int? _parseTime12ToMinutes(String t) {
    final String str = t.trim();
    final RegExp re = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM) ?$',
      caseSensitive: false,
    );
    final Match? m = re.firstMatch(str);
    if (m == null) return null;
    int h = int.parse(m.group(1)!);
    final int min = int.parse(m.group(2)!);
    final String ampm = (m.group(3)!).toUpperCase();
    if (h == 12) h = 0;
    if (ampm == 'PM') h += 12;
    return h * 60 + min;
  }

  String _formatMinutesTo12h(int total) {
    final int minutes = total % 60;
    final int h24 = (total ~/ 60) % 24;
    final String ampm = h24 >= 12 ? 'PM' : 'AM';
    int h12 = h24 % 12;
    if (h12 == 0) h12 = 12;
    final String mm = minutes.toString().padLeft(2, '0');
    return '$h12:$mm $ampm';
  }

  List<String> _generateHalfHourRangeUnion(List<String> slotStrings) {
    final Set<String> set = <String>{};
    for (final s in slotStrings) {
      final String str = s.trim();
      if (str.isEmpty) continue;
      if (str.contains('-')) {
        final List<String> parts = str.split('-');
        if (parts.length != 2) continue;
        final int? start = _parseTime12ToMinutes(parts[0].trim());
        final int? end = _parseTime12ToMinutes(parts[1].trim());
        if (start == null || end == null || end <= start) continue;
        for (int t = start; t + 30 <= end; t += 30) {
          final String from = _formatMinutesTo12h(t);
          final String to = _formatMinutesTo12h(t + 30);
          set.add('$from - $to');
        }
      }
    }
    final List<String> arr = set.toList(growable: false);
    arr.sort((a, b) {
      final String af = a.split('-').first.trim();
      final String bf = b.split('-').first.trim();
      final int? am = _parseTime12ToMinutes(af);
      final int? bm = _parseTime12ToMinutes(bf);
      return (am ?? 0) - (bm ?? 0);
    });
    return arr;
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

  // Fetch counselor availability with time schedule for calendar modal
  Future<List<CounselorAvailability>> fetchCounselorAvailabilityWithSchedule(
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
                    debugPrint(
                      'Counselor: ${counselorWithSchedule.name}, TimeSchedule: ${counselorWithSchedule.timeSchedule}',
                    );
                  }
                }
              }
            } catch (e) {
              debugPrint('Error fetching availability for counselor: $e');
              // Add counselor without schedule as fallback
              counselorsWithSchedule.add(
                CounselorAvailability(
                  counselorId: counselor['counselor_id']?.toString() ?? '',
                  name: counselor['name'] ?? '',
                  specialization:
                      counselor['specialization'] ?? 'General Counseling',
                  timeSchedule: null,
                ),
              );
            }
          }

          return counselorsWithSchedule;
        } else {
          debugPrint('API returned error: ${data['message']}');
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching counselor availability with schedule: $e');
      return [];
    }
  }

  // Fetch counselor availability for calendar date
  Future<List<Counselor>> fetchCounselorAvailabilityForDate(
    DateTime date,
  ) async {
    try {
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayOfWeek = _getDayOfWeek(formattedDate);

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
          final counselors =
              (data['counselors'] as List?)
                  ?.map((c) => Counselor.fromJson(c))
                  .toList() ??
              [];
          debugPrint(
            'Found ${counselors.length} counselors for date: $formattedDate',
          );
          return counselors;
        } else {
          debugPrint('API returned error: ${data['message']}');
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching counselor availability for date: $e');
      return [];
    }
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

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Booking Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                'Your booking entry has been passed to the Admin. Please wait for confirmation before proceeding. Thank you for your patience!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to dashboard after a short delay
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/user/dashboard');
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22D3EE),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Navigation
  void navigateToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/user/dashboard');
  }

  void navigateToMyAppointments(BuildContext context) {
    Navigator.of(context).pushNamed('/user/my-appointments');
  }
}
