import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/admin_dashboard_viewmodel.dart';

class AppointmentsCard extends StatelessWidget {
  const AppointmentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<AdminDashboardViewModel>(
      builder: (context, viewModel, child) {
        final appointments = viewModel.getRecentAppointments();

        return Container(
          height: isMobile ? 300 : 350,
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: const Color(0xFF060E57),
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: Text(
                      'Appointments',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF060E57),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Appointments list
              Expanded(
                child: viewModel.isLoadingAppointments
                    ? const Center(child: CircularProgressIndicator())
                    : appointments.isEmpty
                    ? const Center(
                        child: Text(
                          'No appointments',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE9ECEF),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'User ID: ${appointment.userId}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    _buildStatusBadge(appointment.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: ${appointment.preferredDate}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                if (appointment.preferredTime != null)
                                  Text(
                                    'Time: ${appointment.preferredTime}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Action buttons
              if (!viewModel.isLoadingAppointments)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _navigateToViewAll(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF060E57),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View All'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _navigateToManage(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Manage'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = Colors.green;
        break;
      case 'rejected':
        bgColor = Colors.red;
        break;
      case 'completed':
        bgColor = Colors.blue;
        break;
      case 'cancelled':
        bgColor = Colors.grey;
        break;
      default:
        bgColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _navigateToViewAll(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/view-all-appointments');
  }

  void _navigateToManage(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/scheduled-appointments');
  }
}
