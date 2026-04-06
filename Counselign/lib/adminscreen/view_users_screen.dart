import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/view_users_viewmodel.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_footer.dart';
import 'widgets/pds_modal.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  late ViewUsersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ViewUsersViewModel();
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
          // Users Table
          _buildUsersTable(context),
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
          'Student User Accounts',
          style: TextStyle(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF060E57),
          ),
        ),
        Row(
          children: [
            Consumer<ViewUsersViewModel>(
              builder: (context, viewModel, child) {
                return _buildStatCard(
                  icon: Icons.people,
                  label: 'Total',
                  count: viewModel.totalUsers,
                  color: const Color(0xFF3B82F6),
                );
              },
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Consumer<ViewUsersViewModel>(
              builder: (context, viewModel, child) {
                return _buildStatCard(
                  icon: Icons.people_outline,
                  label: 'Active',
                  count: viewModel.activeUsers,
                  color: const Color(0xFF10B981),
                );
              },
            ),
          ],
        ),
      ],
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

    return Consumer<ViewUsersViewModel>(
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
                  hintText: 'Search student users...',
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

  Widget _buildUsersTable(BuildContext context) {
    return Consumer<ViewUsersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.filteredUsers.isEmpty) {
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
              constraints: const BoxConstraints(minWidth: 800),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF1F5F9),
                ),
                columns: const [
                  DataColumn(label: Text('Action')),
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('Full Name')),
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Course & Year')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Status')),
                ],
                rows: viewModel.filteredUsers.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () =>
                              _viewModel.fetchStudentPds(user.userId),
                        ),
                      ),
                      DataCell(Text(user.userId)),
                      DataCell(Text(user.fullName)),
                      DataCell(Text(user.username)),
                      DataCell(Text(user.email)),
                      DataCell(Text(user.courseAndYear)),
                      DataCell(
                        Text(
                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user.isActive
                                ? const Color(
                                    0xFF10B981,
                                  ).withAlpha((0.1 * 255).round())
                                : const Color(
                                    0xFFEF4444,
                                  ).withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: user.isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No student users found',
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
}
