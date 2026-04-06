import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/view_all_appointments_viewmodel.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_footer.dart';

class ViewAllAppointmentsScreen extends StatefulWidget {
  const ViewAllAppointmentsScreen({super.key});

  @override
  State<ViewAllAppointmentsScreen> createState() =>
      _ViewAllAppointmentsScreenState();
}

class _ViewAllAppointmentsScreenState extends State<ViewAllAppointmentsScreen> {
  late ViewAllAppointmentsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewAllAppointmentsViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            const AdminHeader(),
            Expanded(
              child: SingleChildScrollView(child: _buildMainContent(context)),
            ),
            const AdminFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          SizedBox(height: isMobile ? 20 : 30),
          // Statistics Cards
          _buildStatisticsCards(context),
          SizedBox(height: isMobile ? 20 : 30),
          // Search and Filter
          _buildSearchAndFilter(context),
          SizedBox(height: isMobile ? 20 : 30),
          // Appointments Table
          _buildAppointmentsTable(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'All Appointments',
          style: TextStyle(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF060E57),
          ),
        ),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.refresh,
              label: 'Refresh',
              onPressed: () => _viewModel.fetchAppointments(),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            _buildActionButton(
              icon: Icons.download,
              label: 'Export',
              onPressed: () => _showExportDialog(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF060E57),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context) {
    return Consumer<ViewAllAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.statistics == null) {
          return const SizedBox.shrink();
        }

        final stats = viewModel.statistics!;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              icon: Icons.calendar_today,
              label: 'Total',
              count: stats.totalAppointments,
              color: const Color(0xFF3B82F6),
            ),
            _buildStatCard(
              icon: Icons.check_circle,
              label: 'Approved',
              count: stats.approvedAppointments,
              color: const Color(0xFF10B981),
            ),
            _buildStatCard(
              icon: Icons.pending,
              label: 'Pending',
              count: stats.pendingAppointments,
              color: const Color(0xFFF59E0B),
            ),
            _buildStatCard(
              icon: Icons.cancel,
              label: 'Cancelled',
              count: stats.cancelledAppointments,
              color: const Color(0xFFEF4444),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<ViewAllAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Search box
            SizedBox(
              width: isMobile ? double.infinity : 300,
              child: TextField(
                onChanged: viewModel.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search appointments...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            // Status filter
            SizedBox(
              width: isMobile ? double.infinity : 150,
              child: DropdownButtonFormField<String>(
                initialValue: viewModel.statusFilter,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setStatusFilter(value);
                  }
                },
              ),
            ),
            // Date filter
            SizedBox(
              width: isMobile ? double.infinity : 150,
              child: DropdownButtonFormField<String>(
                initialValue: viewModel.dateFilter,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Time')),
                  DropdownMenuItem(value: 'today', child: Text('Today')),
                  DropdownMenuItem(value: 'week', child: Text('This Week')),
                  DropdownMenuItem(value: 'month', child: Text('This Month')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setDateFilter(value);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentsTable(BuildContext context) {
    return Consumer<ViewAllAppointmentsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.filteredAppointments.isEmpty) {
          return _buildEmptyState();
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: const BoxConstraints(minWidth: 1000),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF1F5F9),
                ),
                columns: const [
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('Full Name')),
                  DataColumn(label: Text('Date & Time')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Purpose')),
                  DataColumn(label: Text('Counselor')),
                  DataColumn(label: Text('Status')),
                ],
                rows: viewModel.filteredAppointments.map((appointment) {
                  return DataRow(
                    cells: [
                      DataCell(Text(appointment.userId)),
                      DataCell(Text(appointment.fullName)),
                      DataCell(Text('${appointment.date} ${appointment.time}')),
                      DataCell(Text(appointment.consultationType)),
                      DataCell(Text(appointment.purpose)),
                      DataCell(Text(appointment.counselor ?? 'Not assigned')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              appointment.status,
                            ).withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            appointment.status,
                            style: TextStyle(
                              color: _getStatusColor(appointment.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Appointments'),
        content: const Text('Export functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
