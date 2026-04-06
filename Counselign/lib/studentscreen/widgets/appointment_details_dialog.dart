import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentDetailsDialog extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onManage;

  const AppointmentDetailsDialog({
    super.key,
    required this.appointment,
    required this.onManage,
  });

  String _getStatusBadgeColor(String? status) {
    if (status == null) return 'pending';
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case 'pending':
        return 'warning';
      case 'rejected':
        return 'danger';
      case 'completed':
        return 'primary';
      case 'approved':
        return 'success';
      case 'cancelled':
        return 'secondary';
      default:
        return 'secondary';
    }
  }

  Color _getStatusColor(String? status) {
    final badgeType = _getStatusBadgeColor(status);
    switch (badgeType) {
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'danger':
        return const Color(0xFFEF4444);
      case 'primary':
        return const Color(0xFF3B82F6);
      case 'success':
        return const Color(0xFF10B981);
      case 'secondary':
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFEEF2F7), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF003366),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Appointment Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Date', appointment.preferredDate ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Time', appointment.preferredTime ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildDetailRowWithBadge(
                      'Status',
                      appointment.status ?? 'N/A',
                      _getStatusColor(appointment.status),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Counselor Preference',
                      appointment.counselorPreference ?? 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Consultation Type',
                      appointment.consultationType ?? 'N/A',
                    ),
                    if (appointment.methodType != null &&
                        appointment.methodType!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Method Type', appointment.methodType!),
                    ],
                    if (appointment.purpose != null &&
                        appointment.purpose!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Purpose', appointment.purpose!),
                    ],
                    if (appointment.description != null &&
                        appointment.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Description', appointment.description!),
                    ],
                    if (appointment.reason != null &&
                        appointment.reason!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Reason', appointment.reason!),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                border: Border(
                  top: BorderSide(color: const Color(0xFFEEF2F7), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: onManage,
                    icon: const Icon(Icons.list_alt, size: 16),
                    label: const Text('Manage'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF060E57),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF003366),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithBadge(
    String label,
    String value,
    Color badgeColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF003366),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: badgeColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
