import 'package:flutter/material.dart';
import '../models/scheduled_appointment.dart';
import '../state/counselor_scheduled_appointments_viewmodel.dart';

class AppointmentsTable extends StatelessWidget {
  final List<CounselorScheduledAppointment> appointments;
  final Function(CounselorScheduledAppointment, String) onUpdateStatus;
  final Function(CounselorScheduledAppointment) onCancelAppointment;

  const AppointmentsTable({
    super.key,
    required this.appointments,
    required this.onUpdateStatus,
    required this.onCancelAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF6AA2C6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          if (appointments.isEmpty) _buildEmptyState() else _buildTableBody(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE9F3FB),
        border: Border(bottom: BorderSide(color: Color(0xFF6AA2C6))),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(flex: 1, child: _buildHeaderCell('Student ID')),
            Expanded(flex: 2, child: _buildHeaderCell('Name')),
            Expanded(flex: 2, child: _buildHeaderCell('Appointed Date')),
            Expanded(flex: 1, child: _buildHeaderCell('Time')),
            Expanded(flex: 2, child: _buildHeaderCell('Method Type')),
            Expanded(flex: 2, child: _buildHeaderCell('Consultation Type')),
            Expanded(flex: 2, child: _buildHeaderCell('Purpose')),
            Expanded(flex: 1, child: _buildHeaderCell('Status', center: true)),
            Expanded(flex: 2, child: _buildHeaderCell('Action', center: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {bool center = false}) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF123B63),
      ),
      textAlign: center ? TextAlign.center : TextAlign.left,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No scheduled appointments found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableBody() {
    return Column(
      children: appointments.asMap().entries.map((entry) {
        final index = entry.key;
        final appointment = entry.value;
        final isOdd = index % 2 == 1;

        return Container(
          decoration: BoxDecoration(
            color: isOdd ? const Color(0xFFF7FBFF) : Colors.white,
            border: const Border(bottom: BorderSide(color: Color(0xFF6AA2C6))),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildDataCell(appointment.studentId.toString()),
                ),
                Expanded(
                  flex: 2,
                  child: _buildDataCell(appointment.studentName),
                ),
                Expanded(
                  flex: 2,
                  child: _buildDataCell(appointment.formattedDate),
                ),
                Expanded(
                  flex: 1,
                  child: _buildDataCell(appointment.formattedTime),
                ),
                Expanded(
                  flex: 2,
                  child: _buildDataCell(
                    (appointment.methodType ?? '').trim().isNotEmpty
                        ? appointment.methodType!.trim()
                        : 'N/A',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildDataCell(appointment.consultationType),
                ),
                Expanded(flex: 2, child: _buildDataCell(appointment.purpose)),
                Expanded(flex: 1, child: _buildStatusCell(appointment)),
                Expanded(flex: 2, child: _buildActionCell(appointment)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDataCell(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
    );
  }

  Widget _buildStatusCell(CounselorScheduledAppointment appointment) {
    final statusColor = _getStatusColor(appointment);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          appointment.statusText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(CounselorScheduledAppointment appointment) {
    if (appointment.isCompleted || appointment.isCancelled) {
      return const Center(
        child: Text(
          'No actions available',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => onUpdateStatus(appointment, 'completed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(0, 32),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 14),
              SizedBox(width: 4),
              Text('Mark Complete'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => onCancelAppointment(appointment),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(0, 32),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, size: 14),
              SizedBox(width: 4),
              Text('Cancel'),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(CounselorScheduledAppointment appointment) {
    switch (appointment.statusColor) {
      case 'success':
        return const Color(0xFF2E7D32);
      case 'primary':
        return const Color(0xFF0D47A1);
      case 'danger':
        return const Color(0xFFB22727);
      case 'warning':
      default:
        return const Color(0xFFFFA000);
    }
  }
}
