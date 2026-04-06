import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/admins_management_viewmodel.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_footer.dart';

class AdminsManagementScreen extends StatefulWidget {
  const AdminsManagementScreen({super.key});

  @override
  State<AdminsManagementScreen> createState() => _AdminsManagementScreenState();
}

class _AdminsManagementScreenState extends State<AdminsManagementScreen> {
  late AdminsManagementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminsManagementViewModel();
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
          // Admins List
          _buildAdminsList(context),
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
          'Admins Management',
          style: TextStyle(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF060E57),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddAdminDialog(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Admin'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(BuildContext context) {
    return Consumer<AdminsManagementViewModel>(
      builder: (context, viewModel, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              icon: Icons.admin_panel_settings,
              label: 'Total Admins',
              count: viewModel.totalAdmins,
              color: const Color(0xFF3B82F6),
            ),
            _buildStatCard(
              icon: Icons.person,
              label: 'Active',
              count: viewModel.activeAdmins,
              color: const Color(0xFF10B981),
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

    return Consumer<AdminsManagementViewModel>(
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
                  hintText: 'Search admins...',
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

  Widget _buildAdminsList(BuildContext context) {
    return Consumer<AdminsManagementViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.filteredAdmins.isEmpty) {
          return _buildEmptyState();
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
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
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: viewModel.filteredAdmins.map((admin) {
                  return DataRow(
                    cells: [
                      DataCell(Text(admin['name'] ?? '')),
                      DataCell(Text(admin['email'] ?? '')),
                      DataCell(Text(admin['username'] ?? '')),
                      DataCell(Text(admin['role'] ?? '')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              admin['status'] ?? 'inactive',
                            ).withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            admin['status'] ?? 'inactive',
                            style: TextStyle(
                              color: _getStatusColor(
                                admin['status'] ?? 'inactive',
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(_formatDate(admin['created_at']))),
                      DataCell(
                        PopupMenuButton<String>(
                          onSelected: (value) =>
                              _handleMenuAction(value, admin),
                          itemBuilder: (context) => [
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
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
      case 'active':
        return const Color(0xFF10B981);
      case 'inactive':
        return const Color(0xFFEF4444);
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
          Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No admins found',
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

  void _handleMenuAction(String action, admin) {
    switch (action) {
      case 'edit':
        _viewModel.loadAdminForEdit(admin);
        _showAddAdminDialog(isEdit: true, adminId: admin['id']);
        break;
      case 'delete':
        _showDeleteConfirmation(admin);
        break;
    }
  }

  void _showAddAdminDialog({bool isEdit = false, int? adminId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Admin' : 'Add Admin'),
        content: SizedBox(
          width: 500,
          child: Consumer<AdminsManagementViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: viewModel.name),
                    onChanged: viewModel.setName,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.nameError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: viewModel.email),
                    onChanged: viewModel.setEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.emailError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: viewModel.username),
                    onChanged: viewModel.setUsername,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.usernameError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: viewModel.password),
                    onChanged: viewModel.setPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: isEdit
                          ? 'New Password (leave empty to keep current)'
                          : 'Password',
                      border: const OutlineInputBorder(),
                      errorText: viewModel.passwordError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: viewModel.role,
                    onChanged: (value) {
                      if (value != null) viewModel.setRole(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text('Super Admin'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _viewModel.clearForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          Consumer<AdminsManagementViewModel>(
            builder: (context, viewModel, child) {
              return ElevatedButton(
                onPressed: viewModel.isSaving
                    ? null
                    : () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final success = isEdit
                            ? await viewModel.updateAdmin(adminId ?? 0)
                            : await viewModel.createAdmin();

                        if (success) {
                          navigator.pop();
                          _viewModel.clearForm();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? 'Admin updated successfully'
                                    : 'Admin created successfully',
                              ),
                            ),
                          );
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Failed to save admin'),
                            ),
                          );
                        }
                      },
                child: viewModel.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Update' : 'Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete ${admin['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final success = await _viewModel.deleteAdmin(admin['id']);
              if (success) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Admin deleted successfully')),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Failed to delete admin')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
