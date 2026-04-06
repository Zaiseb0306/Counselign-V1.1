import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/announcement.dart';
import '../models/event.dart';
import 'package:table_calendar/table_calendar.dart';

class AnnouncementsViewModel extends ChangeNotifier {
  final Session _session = Session();

  // Announcements data
  List<Announcement> _announcements = [];
  List<Announcement> get announcements => _announcements;

  // Events data
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
    // Ensure lists are initialized
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

      final url = '${ApiConfig.currentBaseUrl}/student/announcements/all';
      debugPrint('🔍 Loading announcements from: $url');

      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint(
        '📡 Announcements API Response Status: ${response.statusCode}',
      );
      debugPrint('📡 Announcements API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📊 Parsed announcements data: $data');

        if (data['status'] == 'success') {
          final announcementsList = data['announcements'] as List?;
          debugPrint('📋 Raw announcements list: $announcementsList');
          debugPrint(
            '📋 Announcements list type: ${announcementsList.runtimeType}',
          );
          debugPrint(
            '📋 Announcements list length: ${announcementsList?.length ?? 0}',
          );

          _announcements = [];
          if (announcementsList != null) {
            for (int i = 0; i < announcementsList.length; i++) {
              try {
                final announcement = Announcement.fromJson(
                  announcementsList[i],
                );
                _announcements.add(announcement);
              } catch (e) {
                debugPrint('❌ Error parsing announcement at index $i: $e');
                debugPrint('❌ Raw announcement data: ${announcementsList[i]}');
              }
            }
          }

          debugPrint(
            '✅ Successfully loaded ${_announcements.length} announcements',
          );
        } else {
          _announcementsError =
              data['message'] ?? 'Failed to load announcements';
          debugPrint('❌ API returned error: $_announcementsError');
        }
      } else {
        _announcementsError =
            'Failed to load announcements (HTTP ${response.statusCode})';
        debugPrint('❌ HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('💥 Exception loading announcements: $e');
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

      final url = '${ApiConfig.currentBaseUrl}/student/events/all';
      debugPrint('🔍 Loading events from: $url');

      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📡 Events API Response Status: ${response.statusCode}');
      debugPrint('📡 Events API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📊 Parsed events data: $data');

        if (data['status'] == 'success') {
          final eventsList = data['events'] as List?;
          debugPrint('📋 Raw events list: $eventsList');
          debugPrint('📋 Events list type: ${eventsList.runtimeType}');
          debugPrint('📋 Events list length: ${eventsList?.length ?? 0}');

          _events = [];
          if (eventsList != null) {
            for (int i = 0; i < eventsList.length; i++) {
              try {
                final event = Event.fromJson(eventsList[i]);
                _events.add(event);
              } catch (e) {
                debugPrint('❌ Error parsing event at index $i: $e');
                debugPrint('❌ Raw event data: ${eventsList[i]}');
              }
            }
          }

          debugPrint('✅ Successfully loaded ${_events.length} events');
        } else {
          _eventsError = data['message'] ?? 'Failed to load events';
          debugPrint('❌ API returned error: $_eventsError');
        }
      } else {
        _eventsError = 'Failed to load events (HTTP ${response.statusCode})';
        debugPrint('❌ HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('💥 Exception loading events: $e');
      _eventsError = 'Unable to load events: $e';
    } finally {
      _isLoadingEvents = false;
      notifyListeners();
    }
  }

  // Refresh data
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

  // Get events for a specific day
  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) {
      if (event.date == null) return false;
      return isSameDay(event.date!, day);
    }).toList();
  }

  // Get announcements for a specific day
  List<Announcement> getAnnouncementsForDay(DateTime day) {
    return _announcements.where((announcement) {
      return isSameDay(announcement.createdAt, day);
    }).toList();
  }

  // Navigation
  void navigateToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/user/dashboard');
  }
}
