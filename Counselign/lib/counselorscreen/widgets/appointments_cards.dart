import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scheduled_appointment.dart';
import '../state/counselor_scheduled_appointments_viewmodel.dart';

class AppointmentsCards extends StatelessWidget {
  final List<CounselorScheduledAppointment> appointments;
  final void Function(CounselorScheduledAppointment appointment, String status)
  onUpdateStatus;
  final void Function(CounselorScheduledAppointment appointment)
  onCancelAppointment;
  final VoidCallback? onNavigateToFollowUp;

  const AppointmentsCards({
    super.key,
    required this.appointments,
    required this.onUpdateStatus,
    required this.onCancelAppointment,
    this.onNavigateToFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<CounselorScheduledAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final a = appointments[index];
            return _AppointmentCard(
              appointment: a,
              viewModel: viewModel,
              onUpdateStatus: (status) => onUpdateStatus(a, status),
              onCancelAppointment: () => onCancelAppointment(a),
              onNavigateToFollowUp: onNavigateToFollowUp,
            );
          },
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final CounselorScheduledAppointment appointment;
  final CounselorScheduledAppointmentsViewModel viewModel;
  final void Function(String status) onUpdateStatus;
  final VoidCallback onCancelAppointment;
  final VoidCallback? onNavigateToFollowUp;

  const _AppointmentCard({
    required this.appointment,
    required this.viewModel,
    required this.onUpdateStatus,
    required this.onCancelAppointment,
    this.onNavigateToFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCFE1EF)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123B63).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF060E57).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF060E57),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  appointment.studentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF060E57),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusChip(appointment),
            ],
          ),
          const SizedBox(height: 16),
          // Info grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.badge,
                  'Student ID',
                  appointment.studentId.toString(),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.event,
                  'Date',
                  appointment.effectiveDate ?? 'Not scheduled',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  'Time',
                  appointment.effectiveTime ?? 'Not specified',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.medical_services_outlined,
                  'Consultation',
                  appointment.consultationType,
                ),
                if ((appointment.methodType ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.wifi_tethering,
                    'Method Type',
                    appointment.methodType!.trim(),
                  ),
                ],
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.flag_outlined,
                  'Purpose',
                  appointment.purpose,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons - conditional based on follow-up status
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF123B63)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C757D),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF123B63),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  bool _isMarkCompleteLoading() {
    return viewModel.isUpdatingStatus &&
        viewModel.updatingAppointmentId == appointment.id.toString();
  }

  Widget _buildStatusChip(CounselorScheduledAppointment appointment) {
    final Color fg = _resolveStatusColor(appointment);
    final Color bg = fg.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        appointment.statusText,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  Color _resolveStatusColor(CounselorScheduledAppointment appointment) {
    switch (appointment.statusColor) {
      case 'success':
        return const Color(0xFF2E7D32);
      case 'primary':
        return const Color(0xFF0D47A1);
      case 'danger':
        return const Color(0xFFB22727);
      case 'warning':
      default:
        return const Color(0xFFFB8C00);
    }
  }

  Widget _buildActionButtons() {
    // If it's a follow-up session, show "Manage in Follow-up Sessions" button
    if (appointment.isFollowUp && onNavigateToFollowUp != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onNavigateToFollowUp,
          icon: const Icon(Icons.update_rounded, size: 18),
          label: const Text('Manage in Follow-up Sessions'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF191970),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Otherwise, show the standard Mark Complete and Cancel buttons
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isMarkCompleteLoading()
                ? null
                : () => onUpdateStatus('completed'),
            icon: _isMarkCompleteLoading()
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle_outline, size: 18),
            label: Text(
              _isMarkCompleteLoading() ? 'Processing...' : 'Mark Complete',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancelAppointment,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF060E57),
              side: const BorderSide(color: Color(0xFF060E57)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
