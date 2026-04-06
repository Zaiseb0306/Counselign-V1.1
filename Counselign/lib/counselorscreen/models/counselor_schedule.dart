class CounselorSchedule {
  final String day;
  final String time;

  CounselorSchedule({required this.day, required this.time});

  factory CounselorSchedule.fromJson(Map<String, dynamic> json) {
    return CounselorSchedule(
      day: json['available_days'] ?? json['day'] ?? '',
      time: json['time_scheduled'] ?? json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'available_days': day, 'time_scheduled': time};
  }

  // Format time for display - time is already in 12-hour format with meridian labels
  String get formattedTime {
    if (time.isEmpty) return 'All day';

    // Time is already in 12-hour format with AM/PM, return as is
    return time;
  }

  // Check if this is an all-day availability
  bool get isAllDay => time.isEmpty || time.toLowerCase() == 'all day';

  // Get day order for sorting
  int get dayOrder {
    const dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return dayOrder.indexOf(day);
  }
}
