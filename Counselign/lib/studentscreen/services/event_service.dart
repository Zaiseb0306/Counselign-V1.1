import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../models/event.dart';

class EventService {
  static final Session _session = Session();
  
  static Future<List<Event>> fetchEvents() async {
    try {
      final url = '${ApiConfig.currentBaseUrl}/student/events/all';
      debugPrint('EventService: Fetching from $url');
      
      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('EventService: Response status: ${response.statusCode}');
      debugPrint('EventService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        debugPrint('EventService: Data status: ${data['status']}');
        debugPrint('EventService: Events count: ${(data['events'] as List?)?.length ?? 0}');
        
        if (data['status'] == 'success' && data['events'] is List) {
          final List<dynamic> eventsJson = data['events'];
          final allEvents = eventsJson
              .map((json) => Event.fromJson(json as Map<String, dynamic>))
              .toList();
          
          debugPrint('EventService: Parsed ${allEvents.length} events');
          
          final upcomingEvents = allEvents.where((event) => event.isUpcoming).toList();
          debugPrint('EventService: ${upcomingEvents.length} upcoming events');
          
          upcomingEvents.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return a.date!.compareTo(b.date!);
          });
          
          return upcomingEvents;
        }
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('Error fetching events: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
}
