import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;
  final bool showReason;
  final bool isEditing;
  final bool isMobile;
  final bool isTablet;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    this.onComplete,
    this.showReason = false,
    this.isEditing = false,
    this.isMobile = true,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        bottom: isMobile ? 12 : 16,
        left: isMobile ? 4 : 8,
        right: isMobile ? 4 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildContent(context),
            if (showReason &&
                appointment.reason != null &&
                appointment.reason!.isNotEmpty)
              _buildReasonSection(context),
            if (isEditing) _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.formattedDate,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
                if (appointment.preferredTime != null)
                  Text(
                    appointment.preferredTime!,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.psychology,
            label: 'Type',
            value: appointment.consultationType ?? 'N/A',
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildInfoRow(
            icon: Icons.laptop,
            label: 'Method Type',
            value: appointment.methodType ?? 'N/A',
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildInfoRow(
            icon: Icons.description,
            label: 'Purpose',
            value: appointment.purpose ?? 'N/A',
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildInfoRow(
            icon: Icons.person,
            label: 'Counselor',
            value: appointment.counselorName ?? 'Not assigned',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: isMobile ? 16 : 18, color: Colors.grey[600]),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasonSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isMobile ? 12 : 16,
        right: isMobile ? 12 : 16,
        bottom: isMobile ? 12 : 16,
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: isMobile ? 16 : 18,
                color: Colors.grey[600],
              ),
              SizedBox(width: 8),
              Text(
                'Reason',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            appointment.reason!,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (onEdit != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: Icon(Icons.edit, size: isMobile ? 16 : 18),
                label: Text(
                  'Edit',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                ),
              ),
            ),
          if (onEdit != null && onCancel != null)
            SizedBox(width: isMobile ? 8 : 12),
          if (onCancel != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCancel,
                icon: Icon(Icons.cancel, size: isMobile ? 16 : 18),
                label: Text(
                  'Cancel',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                ),
              ),
            ),
          if (onCancel != null && onDelete != null)
            SizedBox(width: isMobile ? 8 : 12),
          if (onDelete != null)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete, size: isMobile ? 16 : 18),
                label: Text(
                  'Delete',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        appointment.status ?? 'PENDING',
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status?.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELLED':
        // Use a neutral gray theme for cancelled appointments
        return Colors.grey;
      case 'PENDING':
      default:
        return Colors.grey;
    }
  }
}
