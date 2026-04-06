class CounselorAvailabilitySlot {
  final String day;
  final String? timeScheduled;

  CounselorAvailabilitySlot({required this.day, this.timeScheduled});

  factory CounselorAvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return CounselorAvailabilitySlot(
      day: json['available_days']?.toString() ?? '',
      timeScheduled: json['time_scheduled']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'available_days': day, 'time_scheduled': timeScheduled};
  }

  // Helper to parse time range (e.g., "1:30 PM-3:00 PM")
  TimeRange? get timeRange {
    if (timeScheduled == null || timeScheduled!.isEmpty) return null;

    final parts = timeScheduled!.split('-');
    if (parts.length == 2) {
      return TimeRange(from: parts[0].trim(), to: parts[1].trim());
    }
    return null;
  }
}

class TimeRange {
  final String from;
  final String to;

  TimeRange({required this.from, required this.to});

  @override
  String toString() => '$from-$to';

  // Convert to minutes for comparison
  int get fromMinutes => _timeToMinutes(from);
  int get toMinutes => _timeToMinutes(to);

  static int _timeToMinutes(String timeStr) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(timeStr.trim());

    if (match == null) return 0;

    int hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    final ampm = match.group(3)!.toUpperCase();

    if (ampm == 'PM' && hours != 12) {
      hours += 12;
    } else if (ampm == 'AM' && hours == 12) {
      hours = 0;
    }

    return hours * 60 + minutes;
  }

  // Check if this range overlaps with another
  bool overlapsWith(TimeRange other) {
    return fromMinutes < other.toMinutes && toMinutes > other.fromMinutes;
  }

  // Merge overlapping ranges
  static List<TimeRange> mergeRanges(List<TimeRange> ranges) {
    if (ranges.isEmpty) return [];

    // Sort by start time
    ranges.sort((a, b) => a.fromMinutes.compareTo(b.fromMinutes));

    final merged = <TimeRange>[ranges.first];

    for (int i = 1; i < ranges.length; i++) {
      final current = ranges[i];
      final last = merged.last;

      if (current.fromMinutes <= last.toMinutes) {
        // Overlapping ranges - merge them
        if (current.toMinutes > last.toMinutes) {
          merged[merged.length - 1] = TimeRange(
            from: last.from,
            to: current.to,
          );
        }
      } else {
        // Non-overlapping - add as new range
        merged.add(current);
      }
    }

    return merged;
  }
}

class AvailabilityData {
  final Map<String, List<CounselorAvailabilitySlot>> availabilityByDay;

  AvailabilityData({required this.availabilityByDay});

  factory AvailabilityData.fromJson(Map<String, dynamic> json) {
    final Map<String, List<CounselorAvailabilitySlot>> availabilityByDay = {};

    json.forEach((day, slots) {
      if (slots is List) {
        availabilityByDay[day] = slots
            .map((slot) => CounselorAvailabilitySlot.fromJson(slot))
            .toList();
      }
    });

    return AvailabilityData(availabilityByDay: availabilityByDay);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};

    availabilityByDay.forEach((day, slots) {
      result[day] = slots.map((slot) => slot.toJson()).toList();
    });

    return result;
  }

  // Get time ranges for a specific day
  List<TimeRange> getTimeRangesForDay(String day) {
    final slots = availabilityByDay[day] ?? [];
    final ranges = <TimeRange>[];

    for (final slot in slots) {
      final range = slot.timeRange;
      if (range != null) {
        ranges.add(range);
      }
    }

    return TimeRange.mergeRanges(ranges);
  }

  // Get all available days
  List<String> get availableDays => availabilityByDay.keys.toList();

  // Check if counselor is available on a specific day
  bool isAvailableOnDay(String day) {
    return availabilityByDay.containsKey(day) &&
        availabilityByDay[day]!.isNotEmpty;
  }
}

// Backward compatibility class for follow-up sessions
class CounselorAvailability {
  final String date;
  final List<String> timeSlots;

  CounselorAvailability({required this.date, required this.timeSlots});

  factory CounselorAvailability.fromJson(Map<String, dynamic> json) {
    return CounselorAvailability(
      date: json['date']?.toString() ?? '',
      timeSlots:
          (json['time_slots'] as List<dynamic>?)
              ?.map((slot) => slot.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'time_slots': timeSlots};
  }
}
