import 'package:flutter/material.dart';
import '../models/follow_up_appointment.dart';

class FollowUpSessionDetailsDialog extends StatelessWidget {
  final FollowUpAppointment session;

  const FollowUpSessionDetailsDialog({super.key, required this.session});

  Color _getStatusColor(String? status) {
    if (status == null) return const Color(0xFF64748B);
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFF64748B);
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
                    Icons.event_available,
                    color: Color(0xFF003366),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Follow-up Session Details',
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
                    _buildDetailRow(
                      'Follow-up Sequence',
                      'Follow-up #${session.followUpSequence}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Date', session.preferredDate),
                    const SizedBox(height: 12),
                    _buildDetailRow('Time', session.preferredTime),
                    const SizedBox(height: 12),
                    _buildDetailRowWithBadge(
                      'Status',
                      session.statusDisplay,
                      _getStatusColor(session.status),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Consultation Type',
                      session.consultationType,
                    ),
                    if (session.counselorName != null &&
                        session.counselorName!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Counselor', session.counselorName!),
                    ],
                    if (session.description != null &&
                        session.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Description', session.description!),
                    ],
                    if (session.reason != null &&
                        session.reason!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        session.status.toLowerCase() == 'cancelled'
                            ? 'Reason For Cancellation'
                            : 'Reason For Follow-up',
                        session.reason!,
                      ),
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Close'),
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
