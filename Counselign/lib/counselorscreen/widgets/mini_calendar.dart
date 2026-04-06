import 'package:flutter/material.dart';
import '../state/counselor_scheduled_appointments_viewmodel.dart';

class MiniCalendar extends StatefulWidget {
  final CounselorScheduledAppointmentsViewModel viewModel;
  final Function(DateTime)? onDateSelected;

  const MiniCalendar({super.key, required this.viewModel, this.onDateSelected});

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  late DateTime _currentDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _displayedMonth = DateTime(_currentDate.year, _currentDate.month);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildWeekdays(),
          const SizedBox(height: 4),
          _buildCalendarDays(),
          const SizedBox(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF123B63),
            side: const BorderSide(color: Color(0xFFC9D7E4)),
            minimumSize: const Size(28, 28),
            padding: EdgeInsets.zero,
          ),
        ),
        Text(
          '${monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF123B63),
            fontSize: 14,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF123B63),
            side: const BorderSide(color: Color(0xFFC9D7E4)),
            minimumSize: const Size(28, 28),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdays() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      children: weekdays
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0x000ff678),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarDays() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    );
    final firstWeekday =
        firstDayOfMonth.weekday % 7; // Convert to 0-based (Sunday = 0)
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: firstWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          // Empty cells for days before the first day of the month
          return const SizedBox.shrink();
        }

        final day = index - firstWeekday + 1;
        final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
        final isToday = _isToday(date);
        final hasAppointment = widget.viewModel.hasAppointmentsOnDate(date);
        final appointmentCount = widget.viewModel.getAppointmentCountForDate(
          date,
        );

        return GestureDetector(
          onTap: () => widget.onDateSelected?.call(date),
          child: Container(
            decoration: BoxDecoration(
              color: _getDayColor(isToday, hasAppointment),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getDayBorderColor(isToday, hasAppointment),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getDayTextColor(isToday, hasAppointment),
                    ),
                  ),
                ),
                if (hasAppointment && appointmentCount > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          appointmentCount.toString(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF191970),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEF2F6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: const Color(0xFF191970),
            label: 'Has Appointments',
          ),
          const SizedBox(width: 24),
          _buildLegendItem(color: const Color(0xFF17A2B8), label: 'Today'),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF123B63),
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  Color _getDayColor(bool isToday, bool hasAppointment) {
    if (hasAppointment) return const Color(0xFF191970);
    if (isToday) return const Color(0xFF17A2B8);
    return const Color(0xFFF8F9FA);
  }

  Color _getDayBorderColor(bool isToday, bool hasAppointment) {
    if (hasAppointment) return const Color(0xFF191970);
    if (isToday) return const Color(0xFF17A2B8);
    return const Color(0xFFE0E0E0);
  }

  Color _getDayTextColor(bool isToday, bool hasAppointment) {
    if (hasAppointment || isToday) return Colors.white;
    return const Color(0xFF333333);
  }
}
