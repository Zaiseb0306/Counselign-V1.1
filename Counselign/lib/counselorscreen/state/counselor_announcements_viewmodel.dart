import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../../studentscreen/models/announcement.dart';
import '../../studentscreen/models/event.dart';

class CounselorAnnouncementsViewModel extends ChangeNotifier {
  final Session _session = Session();

  // Data
  List<Announcement> _announcements = [];
  List<Announcement> get announcements => _announcements;

  List<Event> _events = [];
  List<Event> get events => _events;

  // Loading states
  bool _isLoadingAnnouncements = true;
  bool get isLoadingAnnouncements => _isLoadingAnnouncements;

  bool _isLoadingEvents = true;
  bool get isLoadingEvents => _isLoadingEvents;

  // Error states
  String? _announcementsError;
  String? get announcementsError => _announcementsError;

  String? _eventsError;
  String? get eventsError => _eventsError;

  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;

  DateTime? _selectedDay;
  DateTime? get selectedDay => _selectedDay;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  CalendarFormat get calendarFormat => _calendarFormat;

  bool _showCalendar = false;
  bool get showCalendar => _showCalendar;

  void initialize() {
    _announcements = [];
    _events = [];
    loadAnnouncements();
    loadEvents();
  }

  // Load announcements
  Future<void> loadAnnouncements() async {
    try {
      _isLoadingAnnouncements = true;
      _announcementsError = null;
      notifyListeners();

      final url = '${ApiConfig.currentBaseUrl}/counselor/announcements/all';
      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' || data['success'] == true) {
          final list = data['announcements'] as List?;
          _announcements = [];
          if (list != null) {
            for (final raw in list) {
              try {
                _announcements = [
                  ..._announcements,
                  Announcement.fromJson(raw),
                ];
              } catch (_) {}
            }
          }
        } else {
          _announcementsError =
              data['message'] ?? 'Failed to load announcements';
        }
      } else {
        _announcementsError =
            'Failed to load announcements (HTTP ${response.statusCode})';
      }
    } catch (e) {
      _announcementsError = 'Unable to load announcements: $e';
    } finally {
      _isLoadingAnnouncements = false;
      notifyListeners();
    }
  }

  // Load events
  Future<void> loadEvents() async {
    try {
      _isLoadingEvents = true;
      _eventsError = null;
      notifyListeners();

      final url = '${ApiConfig.currentBaseUrl}/counselor/events/all';
      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' || data['success'] == true) {
          final list = data['events'] as List?;
          _events = [];
          if (list != null) {
            for (final raw in list) {
              try {
                _events = [..._events, Event.fromJson(raw)];
              } catch (_) {}
            }
          }
        } else {
          _eventsError = data['message'] ?? 'Failed to load events';
        }
      } else {
        _eventsError = 'Failed to load events (HTTP ${response.statusCode})';
      }
    } catch (e) {
      _eventsError = 'Unable to load events: $e';
    } finally {
      _isLoadingEvents = false;
      notifyListeners();
    }
  }

  // Refresh
  Future<void> refresh() async {
    await Future.wait([loadAnnouncements(), loadEvents()]);
  }

  // Calendar methods
  void toggleCalendar() {
    _showCalendar = !_showCalendar;
    notifyListeners();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void onFormatChanged(CalendarFormat format) {
    _calendarFormat = format;
    notifyListeners();
  }

  // Day filters
  List<Event> getEventsForDay(DateTime day) {
    return _events
        .where((e) => e.date != null && isSameDay(e.date!, day))
        .toList();
  }

  List<Announcement> getAnnouncementsForDay(DateTime day) {
    return _announcements.where((a) => isSameDay(a.createdAt, day)).toList();
  }
}
