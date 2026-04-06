/// Utility functions for time operations, specifically for generating
/// 30-minute increments from counselor availability time slots.
class TimeUtils {
  /// Parses a 12-hour time string (e.g., "10:30 AM") to total minutes.
  /// Returns null if the format is invalid.
  static int? parseTime12ToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;

    final regex = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    );
    final match = regex.firstMatch(timeStr.trim());

    if (match == null) return null;

    int hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final meridian = (match.group(3) ?? '').toUpperCase();

    if (hours == 12) hours = 0;
    if (meridian == 'PM') hours += 12;

    return hours * 60 + minutes;
  }

  /// Formats total minutes to 12-hour format (e.g., "10:30 AM").
  static String formatMinutesTo12h(int totalMinutes) {
    final minutes = totalMinutes % 60;
    final hours24 = (totalMinutes ~/ 60) % 24;
    final meridian = hours24 >= 12 ? 'PM' : 'AM';
    int hours12 = hours24 % 12;
    if (hours12 == 0) hours12 = 12;

    final mm = minutes.toString().padLeft(2, '0');
    return '$hours12:$mm $meridian';
  }

  /// Generates 30-minute range labels (e.g., "10:00 AM - 10:30 AM")
  /// from availability time slots.
  ///
  /// Time slots can be:
  /// - A range: "10:00 AM - 12:00 PM"
  /// - A single time: "10:00 AM"
  ///
  /// Returns a sorted list of 30-minute range labels.
  static List<String> generateHalfHourRangeLabelsFromSlots(
    List<String> timeSlots,
  ) {
    final rangeSet = <String>{};

    for (final slot in timeSlots) {
      if (slot.trim().isEmpty) continue;

      final trimmedSlot = slot.trim();

      if (trimmedSlot.contains('-')) {
        // Handle range format: "10:00 AM - 12:00 PM"
        final parts = trimmedSlot.split('-');
        if (parts.length == 2) {
          final startStr = parts[0].trim();
          final endStr = parts[1].trim();

          final startMinutes = parseTime12ToMinutes(startStr);
          final endMinutes = parseTime12ToMinutes(endStr);

          if (startMinutes != null &&
              endMinutes != null &&
              endMinutes > startMinutes) {
            // Generate every 30 minutes from start up to but not including end
            for (int t = startMinutes; t + 30 <= endMinutes; t += 30) {
              final from = formatMinutesTo12h(t);
              final to = formatMinutesTo12h(t + 30);
              rangeSet.add('$from - $to');
            }
          }
        }
      } else {
        // Handle single time format: "10:00 AM"
        final fromMinutes = parseTime12ToMinutes(trimmedSlot);
        if (fromMinutes != null) {
          final from = formatMinutesTo12h(fromMinutes);
          final to = formatMinutesTo12h(fromMinutes + 30);
          rangeSet.add('$from - $to');
        }
      }
    }

    // Sort by start time
    final sortedList = rangeSet.toList();
    sortedList.sort((a, b) {
      final aFrom = a.split('-').first.trim();
      final bFrom = b.split('-').first.trim();
      final aMinutes = parseTime12ToMinutes(aFrom) ?? 0;
      final bMinutes = parseTime12ToMinutes(bFrom) ?? 0;
      return aMinutes.compareTo(bMinutes);
    });

    return sortedList;
  }

  /// Finds a matching 30-minute range label for a given time string.
  /// If the time is already a range format, returns it if it exists in the options.
  /// If the time is a single time (e.g., "10:00 AM"), finds a range that starts with it.
  /// Returns null if no match is found.
  static String? findMatchingTimeRange(
    String? timeValue,
    List<String> timeOptions,
  ) {
    if (timeValue == null || timeValue.trim().isEmpty) return null;

    final trimmedTime = timeValue.trim();

    // If it's already a range format, check if it exists in options
    if (trimmedTime.contains(' - ')) {
      if (timeOptions.contains(trimmedTime)) {
        return trimmedTime;
      }
      return null;
    }

    // If it's a single time, find a range that starts with it
    for (final option in timeOptions) {
      if (option.startsWith(trimmedTime)) {
        return option;
      }
    }

    return null;
  }
}
