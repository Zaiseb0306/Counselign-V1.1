import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/appointment_report.dart';

class AppointmentReportCard extends StatelessWidget {
  final AppointmentReportItem appointment;
  final VoidCallback? onTap;

  const AppointmentReportCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with User ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appointment.userId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0d6efd),
                    ),
                  ),
                  _buildStatusBadge(appointment.status),
                ],
              ),
              const SizedBox(height: 8),

              // Student Name
              Text(
                appointment.studentName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Date and Time
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.calendar,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    FontAwesomeIcons.clock,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.appointedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Consultation Type
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.userDoctor,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.consultationType,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Method Type and Session Type
              Row(
                children: [
                  if (appointment.methodType != null &&
                      appointment.methodType!.isNotEmpty) ...[
                    const Icon(
                      FontAwesomeIcons.video,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.methodType!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                  ],
                  const Icon(
                    FontAwesomeIcons.clipboardList,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.sessionTypeDisplay,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Purpose
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    FontAwesomeIcons.comment,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.purpose,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),

              // Reason (if available and status is not approved/completed)
              if (appointment.reason != null &&
                  appointment.reason!.isNotEmpty &&
                  appointment.status.toLowerCase() != 'approved' &&
                  appointment.status.toLowerCase() != 'completed')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        FontAwesomeIcons.triangleExclamation,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.reason!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = const Color(0xFF0d6efd);
        textColor = Colors.white;
        icon = FontAwesomeIcons.circleCheck;
        break;
      case 'approved':
        backgroundColor = const Color(0xFF198754);
        textColor = Colors.white;
        icon = FontAwesomeIcons.thumbsUp;
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFdc3545);
        textColor = Colors.white;
        icon = FontAwesomeIcons.circleXmark;
        break;
      case 'pending':
        backgroundColor = const Color(0xFFffc107);
        textColor = Colors.black;
        icon = FontAwesomeIcons.clock;
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFF6c757d);
        textColor = Colors.white;
        icon = FontAwesomeIcons.ban;
        break;
      default:
        backgroundColor = const Color(0xFF6c757d);
        textColor = Colors.white;
        icon = FontAwesomeIcons.question;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
