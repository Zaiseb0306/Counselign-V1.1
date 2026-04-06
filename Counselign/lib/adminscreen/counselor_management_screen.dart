import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/counselor_management_viewmodel.dart';
import 'models/counselor_schedule.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_footer.dart';

class CounselorManagementScreen extends StatefulWidget {
  const CounselorManagementScreen({super.key});

  @override
  State<CounselorManagementScreen> createState() =>
      _CounselorManagementScreenState();
}

class _CounselorManagementScreenState extends State<CounselorManagementScreen> {
  late CounselorManagementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CounselorManagementViewModel();
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
          // Search and Filter
          _buildSearchAndFilter(context),
          SizedBox(height: isMobile ? 20 : 30),
          // Counselors List and Details
          _buildCounselorsContent(context),
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
          'Counselor Management',
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
              onPressed: () => _viewModel.fetchCounselors(),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            _buildActionButton(
              icon: Icons.add,
              label: 'Add Counselor',
              onPressed: () => _showAddCounselorDialog(),
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

  Widget _buildSearchAndFilter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<CounselorManagementViewModel>(
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
                  hintText: 'Search counselors...',
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
              width: isMobile ? double.infinity : 200,
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
                  DropdownMenuItem(value: 'all', child: Text('All Status')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setStatusFilter(value);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCounselorsContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Consumer<CounselorManagementViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.filteredCounselors.isEmpty) {
          return _buildEmptyState();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Counselors List
            Expanded(
              flex: isMobile ? 1 : 2,
              child: _buildCounselorsList(context),
            ),
            if (!isMobile) const SizedBox(width: 20),
            // Counselor Details
            if (!isMobile)
              Expanded(flex: 3, child: _buildCounselorDetails(context)),
          ],
        );
      },
    );
  }

  Widget _buildCounselorsList(BuildContext context) {
    return Consumer<CounselorManagementViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Counselors',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.filteredCounselors.length,
                  itemBuilder: (context, index) {
                    final counselor = viewModel.filteredCounselors[index];
                    final isSelected =
                        viewModel.selectedCounselor?.id == counselor.id;

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFF1F5F9),
                      leading: CircleAvatar(
                        backgroundImage: counselor.profilePicture != null
                            ? NetworkImage(counselor.profilePicture!)
                            : null,
                        child: counselor.profilePicture == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        counselor.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(counselor.degree),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) =>
                            _handleMenuAction(value, counselor),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 16),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'schedule',
                            child: Row(
                              children: [
                                Icon(Icons.schedule, size: 16),
                                SizedBox(width: 8),
                                Text('View Schedule'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () => viewModel.selectCounselor(counselor),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounselorDetails(BuildContext context) {
    return Consumer<CounselorManagementViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.selectedCounselor == null) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Select a counselor to view details',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final counselor = viewModel.selectedCounselor!;
        final schedule = viewModel.selectedCounselorSchedule;

        return Card(
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
                // Counselor Info Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: counselor.profilePicture != null
                          ? NetworkImage(counselor.profilePicture!)
                          : null,
                      child: counselor.profilePicture == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            counselor.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            counselor.degree,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            counselor.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Schedule Section
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                if (viewModel.isLoadingSchedule)
                  const Center(child: CircularProgressIndicator())
                else if (schedule != null)
                  _buildScheduleDisplay(schedule)
                else
                  const Text('No schedule available'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleDisplay(CounselorSchedule schedule) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: schedule.schedule.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children: entry.value.map((time) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10B981,
                          ).withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No counselors found',
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

  void _handleMenuAction(String action, counselor) {
    switch (action) {
      case 'view':
        _viewModel.selectCounselor(counselor);
        break;
      case 'edit':
        _showEditCounselorDialog(counselor);
        break;
      case 'schedule':
        _viewModel.selectCounselor(counselor);
        break;
    }
  }

  void _showAddCounselorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Counselor'),
        content: const Text(
          'Add counselor functionality will be implemented here.',
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

  void _showEditCounselorDialog(CounselorInfo counselor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Counselor'),
        content: const Text(
          'Edit counselor functionality will be implemented here.',
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
}
