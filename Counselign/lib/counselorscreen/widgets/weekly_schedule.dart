import 'package:flutter/material.dart';
import '../models/counselor_schedule.dart';

class WeeklySchedule extends StatelessWidget {
  final List<CounselorSchedule> schedule;

  const WeeklySchedule({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Weekly Consultation Schedules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF123B63),
            ),
          ),
          const SizedBox(height: 12),
          if (schedule.isEmpty) _buildEmptySchedule() else _buildScheduleList(),
        ],
      ),
    );
  }

  Widget _buildEmptySchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Text(
          'No schedule set',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    // Group schedule by day to handle multiple time slots per day
    final Map<String, List<String>> groupedSchedule = {};

    for (final item in schedule) {
      final day = item.day;
      final time = item.time;

      if (!groupedSchedule.containsKey(day)) {
        groupedSchedule[day] = [];
      }

      if (time.isNotEmpty && !groupedSchedule[day]!.contains(time)) {
        groupedSchedule[day]!.add(time);
      }
    }

    // Sort days in chronological order
    const dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final sortedDays = groupedSchedule.keys.toList()
      ..sort((a, b) => dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b)));

    return Column(
      children: sortedDays.map((day) {
        final times = groupedSchedule[day]!;

        if (times.isEmpty) {
          return _buildScheduleRow(day, 'All day');
        }

        // Format time slots for display
        final formattedTimes = times.map((time) {
          final schedule = CounselorSchedule(day: day, time: time);
          return schedule.formattedTime;
        }).toList();

        return _buildScheduleRow(day, formattedTimes.join(', '));
      }).toList(),
    );
  }

  Widget _buildScheduleRow(String day, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day column - fixed width
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ),
          const SizedBox(width: 12),
          // Time column - flexible width that can wrap
          Expanded(
            child: Text(
              time,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
