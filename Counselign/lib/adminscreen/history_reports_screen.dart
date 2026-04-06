import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/history_reports_viewmodel.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_footer.dart';

class HistoryReportsScreen extends StatefulWidget {
  const HistoryReportsScreen({super.key});

  @override
  State<HistoryReportsScreen> createState() => _HistoryReportsScreenState();
}

class _HistoryReportsScreenState extends State<HistoryReportsScreen> {
  late HistoryReportsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HistoryReportsViewModel();
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
          // Reports List
          _buildReportsList(context),
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
          'History Reports',
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
              onPressed: () => _viewModel.fetchReports(),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            _buildActionButton(
              icon: Icons.add,
              label: 'Generate Report',
              onPressed: () => _showGenerateReportDialog(),
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
    return Consumer<HistoryReportsViewModel>(
      builder: (context, viewModel, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              icon: Icons.assessment,
              label: 'Total',
              count: viewModel.totalReports,
              color: const Color(0xFF3B82F6),
            ),
            _buildStatCard(
              icon: Icons.calendar_today,
              label: 'Appointments',
              count: viewModel.appointmentReports,
              color: const Color(0xFF10B981),
            ),
            _buildStatCard(
              icon: Icons.people,
              label: 'Users',
              count: viewModel.userReports,
              color: const Color(0xFFF59E0B),
            ),
            _buildStatCard(
              icon: Icons.settings,
              label: 'System',
              count: viewModel.systemReports,
              color: const Color(0xFF8B5CF6),
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

    return Consumer<HistoryReportsViewModel>(
      builder: (context, viewModel, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Search box
            SizedBox(
              width: isMobile ? double.infinity : 400,
              child: TextField(
                onChanged: viewModel.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search reports...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            // Type filter
            SizedBox(
              width: isMobile ? double.infinity : 200,
              child: DropdownButtonFormField<String>(
                initialValue: viewModel.typeFilter,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Types')),
                  DropdownMenuItem(
                    value: 'appointment',
                    child: Text('Appointment'),
                  ),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'system', child: Text('System')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setTypeFilter(value);
                  }
                },
              ),
            ),
            // Date filter
            SizedBox(
              width: isMobile ? double.infinity : 200,
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

  Widget _buildReportsList(BuildContext context) {
    return Consumer<HistoryReportsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.filteredReports.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: viewModel.filteredReports.map((report) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['title'] ?? 'Untitled Report',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                report['description'] ?? 'No description',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(
                              report['type'] ?? 'system',
                            ).withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (report['type'] ?? 'system').toUpperCase(),
                            style: TextStyle(
                              color: _getTypeColor(report['type'] ?? 'system'),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) =>
                              _handleMenuAction(value, report),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 16),
                                  SizedBox(width: 8),
                                  Text('View'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'export_pdf',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Export PDF'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'export_excel',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.table_chart,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Export Excel'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Generated: ${_formatDate(report['created_at'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.file_download,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Size: ${report['file_size'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'appointment':
        return const Color(0xFF10B981);
      case 'user':
        return const Color(0xFFF59E0B);
      case 'system':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No reports found',
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

  void _handleMenuAction(String action, report) {
    switch (action) {
      case 'view':
        _showReportDetails(report);
        break;
      case 'export_pdf':
        _exportReport(report, 'pdf');
        break;
      case 'export_excel':
        _exportReport(report, 'excel');
        break;
      case 'delete':
        _showDeleteConfirmation(report);
        break;
    }
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${report['title'] ?? 'Untitled Report'}'),
            Text('Type: ${report['type'] ?? 'Unknown'}'),
            Text('Description: ${report['description'] ?? 'No description'}'),
            Text('Generated: ${_formatDate(report['created_at'])}'),
            Text('Size: ${report['file_size'] ?? 'Unknown'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportReport(Map<String, dynamic> report, String format) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final success = await _viewModel.exportReport(report['id'], format);
    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Report exported as $format')),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Failed to export report')),
      );
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality will be implemented'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showGenerateReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Report Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'appointment',
                  child: Text('Appointment Report'),
                ),
                DropdownMenuItem(value: 'user', child: Text('User Report')),
                DropdownMenuItem(value: 'system', child: Text('System Report')),
              ],
              onChanged: (value) {
                // Handle selection
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Report Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Generate report functionality will be implemented',
                  ),
                ),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}
