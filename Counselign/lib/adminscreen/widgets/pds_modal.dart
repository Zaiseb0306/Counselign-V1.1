import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/view_users_viewmodel.dart';
import '../models/student_pds.dart';

class PdsModal extends StatelessWidget {
  const PdsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewUsersViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.selectedStudentPds == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final pds = viewModel.selectedStudentPds!;

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: pds.profilePicture != null
                          ? NetworkImage(pds.profilePicture!)
                          : null,
                      child: pds.profilePicture == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Student Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pds.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.badge, size: 16),
                              const SizedBox(width: 4),
                              Text(pds.studentId),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 16),
                              const SizedBox(width: 4),
                              Text(pds.email),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.school), text: 'Academic'),
                  Tab(icon: Icon(Icons.person), text: 'Personal'),
                  Tab(icon: Icon(Icons.info), text: 'Other'),
                ],
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAcademicTab(pds),
                    _buildPersonalTab(pds),
                    _buildOtherTab(pds),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAcademicTab(StudentPds pds) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem('Course', pds.course ?? 'Not specified'),
          ),
          Expanded(
            child: _buildInfoItem(
              'Year Level',
              pds.yearLevel ?? 'Not specified',
            ),
          ),
          Expanded(
            child: _buildInfoItem(
              'Academic Status',
              pds.academicStatus ?? 'Not specified',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(StudentPds pds) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Last Name',
                  pds.lastName ?? 'Not specified',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'First Name',
                  pds.firstName ?? 'Not specified',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Middle Name',
                  pds.middleName ?? 'Not specified',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Date of Birth',
                  pds.dateOfBirth ?? 'Not specified',
                ),
              ),
              Expanded(
                child: _buildInfoItem('Age', pds.age ?? 'Not specified'),
              ),
              Expanded(
                child: _buildInfoItem('Sex', pds.sex ?? 'Not specified'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Civil Status',
                  pds.civilStatus ?? 'Not specified',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Contact',
                  pds.contactNumber ?? 'Not specified',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Email',
                  pds.personalEmail ?? 'Not specified',
                ),
              ),
            ],
          ),
          // PWD Section (if applicable)
          if (pds.hasPwd) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'PWD Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoItem('PWD Type', pds.pwdType ?? 'Not specified'),
          ],
        ],
      ),
    );
  }

  Widget _buildOtherTab(StudentPds pds) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Special Circumstances
          Text(
            'Special Circumstances',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Solo Parent',
                  pds.soloParent ?? 'Not specified',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Indigenous',
                  pds.indigenous ?? 'Not specified',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Breastfeeding Mother',
                  pds.breastfeeding ?? 'Not specified',
                ),
              ),
              Expanded(
                child: _buildInfoItem('PWD', pds.pwd ?? 'Not specified'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
