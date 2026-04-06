import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'state/student_profile_viewmodel.dart';
import 'state/pds_viewmodel.dart';
import 'models/student_profile.dart';
import '../api/config.dart';
import '../utils/session.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'widgets/navigation_drawer.dart';
import 'pds_preview_screen.dart';

enum UpdateProfileDialogMode { pictureOnly, infoOnly }

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late StudentProfileViewModel _viewModel;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _viewModel = StudentProfileViewModel();
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    await _viewModel.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  Future<void> _openPdsPreview() async {
    try {
      final session = Session();
      await session.initialize();

      if (!session.hasSession) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String cleanBaseUrl = ApiConfig.currentBaseUrl;
      if (cleanBaseUrl.endsWith('/index.php')) {
        cleanBaseUrl = cleanBaseUrl.replaceAll('/index.php', '');
      }
      cleanBaseUrl = cleanBaseUrl.replaceAll(RegExp(r'/$'), '');

      final previewUrl = '$cleanBaseUrl/student/pds/preview';

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              PdsPreviewScreen(previewUrl: previewUrl, baseUrl: cleanBaseUrl),
        ),
      );
    } catch (e) {
      debugPrint('Error opening PDS preview: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening PDS preview: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _closeDrawer() {
    setState(() {
      _isDrawerOpen = false;
    });
  }

  void _navigateToAnnouncements(BuildContext context) {
    _closeDrawer();
    Navigator.pushNamed(context, '/student/announcements');
  }

  void _navigateToScheduleAppointment(BuildContext context) {
    _closeDrawer();
    Navigator.pushNamed(context, '/student/schedule-appointment');
  }

  void _navigateToMyAppointments(BuildContext context) {
    _closeDrawer();
    Navigator.pushNamed(context, '/student/my-appointments');
  }

  void _navigateToProfile(BuildContext context) {
    _closeDrawer();
    // Already on profile screen, just close drawer
  }

  void _logout(BuildContext context) {
    _closeDrawer();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppHeader(onMenu: _toggleDrawer),
          body: AnimatedBuilder(
            animation: _viewModel,
            builder: (context, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    _buildProfileSection(_viewModel),
                    _buildPDSSection(_viewModel),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: ModernBottomNavigationBar(
            currentIndex:
                0, // Home is highlighted since profile is accessed from home
            onTap: (index) {
              // Handle navigation based on index
              switch (index) {
                case 0: // Home
                  Navigator.pushReplacementNamed(context, '/student/dashboard');
                  break;
                case 1: // Schedule Appointment
                  Navigator.pushNamed(context, '/student/schedule-appointment');
                  break;
                case 2: // My Appointments
                  Navigator.pushNamed(context, '/student/my-appointments');
                  break;
                case 3: // Follow-up Sessions
                  Navigator.pushNamed(context, '/student/follow-up-sessions');
                  break;
              }
            },
            isStudent: true,
          ),
        ),
        if (_isDrawerOpen)
          GestureDetector(
            onTap: _closeDrawer,
            child: Container(
              color: Colors.black.withAlpha(128),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        StudentNavigationDrawer(
          isOpen: _isDrawerOpen,
          onClose: _closeDrawer,
          onNavigateToAnnouncements: () => _navigateToAnnouncements(context),
          onNavigateToScheduleAppointment: () =>
              _navigateToScheduleAppointment(context),
          onNavigateToMyAppointments: () => _navigateToMyAppointments(context),
          onNavigateToProfile: () => _navigateToProfile(context),
          onLogout: () => _logout(context),
        ),
      ],
    );
  }

  Widget _buildProfileSection(StudentProfileViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(viewModel),
          _buildAccountInfo(viewModel),
          _buildActionButtons(viewModel),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(StudentProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFCFC), Color(0xFFFCF6F5)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: viewModel.profile?.profilePicture != null
                      ? Image.network(
                          viewModel.profile!.buildImageUrl(
                            ApiConfig.currentBaseUrl,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('Photos/profile.png');
                          },
                        )
                      : Image.asset('Photos/profile.png'),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => _showUpdateProfileDialog(
                    viewModel,
                    UpdateProfileDialogMode.pictureOnly,
                  ),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Color(0xFF060E57),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Account ID: ${viewModel.userId}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF060E57),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(StudentProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAccountField('Username', viewModel.username),
          const SizedBox(height: 20),
          _buildAccountField('Email', viewModel.email),
        ],
      ),
    );
  }

  Widget _buildAccountField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: Color(0xFF495057)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(StudentProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showChangePasswordDialog(viewModel),
              icon: const Icon(Icons.key_sharp, size: 18),
              label: const Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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
            child: ElevatedButton.icon(
              onPressed: () => _showUpdateProfileDialog(
                viewModel,
                UpdateProfileDialogMode.infoOnly,
              ),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Update Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF060E57),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDSSection(StudentProfileViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [_buildPDSHeader(viewModel), _buildPDSTabs(viewModel)],
      ),
    );
  }

  Widget _buildPDSHeader(StudentProfileViewModel viewModel) {
    if (!viewModel.isInitialized) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Data Sheet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF060E57),
            ),
          ),
          const SizedBox(height: 12),
          // Mobile-friendly button layout
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => viewModel.pdsViewModel.togglePdsEditing(),
                icon: Icon(
                  viewModel.pdsViewModel.isPdsEditingEnabled
                      ? Icons.lock
                      : Icons.lock_open,
                  size: 20,
                ),
                label: Text(
                  viewModel.pdsViewModel.isPdsEditingEnabled
                      ? 'Disable'
                      : 'Enable',
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C757D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed:
                    viewModel.pdsViewModel.isPdsEditingEnabled &&
                        !viewModel.pdsViewModel.isSavingPDS
                    ? () => _savePDSData(viewModel)
                    : null,
                icon: viewModel.pdsViewModel.isSavingPDS
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save, size: 20),
                label: const Text('Save', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openPdsPreview,
                icon: const Icon(Icons.visibility, size: 20),
                label: const Text('Preview', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPDSTabs(StudentProfileViewModel viewModel) {
    if (!viewModel.isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF060E57),
            unselectedLabelColor: const Color(0xFF374151),
            indicatorColor: const Color(0xFF060E57),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            isScrollable: true, // Allow horizontal scrolling on mobile
            tabAlignment: TabAlignment.center,
            tabs: const [
              Tab(icon: Icon(Icons.school, size: 18), text: 'Personal BG'),
              Tab(
                icon: Icon(Icons.family_restroom, size: 18),
                text: 'Family BG',
              ),
              Tab(icon: Icon(Icons.info, size: 18), text: 'Other Info'),
              Tab(icon: Icon(Icons.emoji_events, size: 18), text: 'Awards'),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6, // Responsive height
          child: viewModel.pdsViewModel.isSavingPDS
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Saving your data...'),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      key: const PageStorageKey(
                        'personal_bg_tab',
                      ), // Preserve scroll position
                      padding: const EdgeInsets.all(16),
                      child: _buildPersonalBackgroundTab(viewModel),
                    ),
                    SingleChildScrollView(
                      key: const PageStorageKey(
                        'family_bg_tab',
                      ), // Preserve scroll position
                      padding: const EdgeInsets.all(16),
                      child: _buildFamilyBackgroundTab(viewModel),
                    ),
                    SingleChildScrollView(
                      key: const PageStorageKey(
                        'other_info_tab',
                      ), // Preserve scroll position
                      padding: const EdgeInsets.all(16),
                      child: _buildOtherInfoTab(viewModel),
                    ),
                    SingleChildScrollView(
                      key: const PageStorageKey(
                        'awards_tab',
                      ), // Preserve scroll position
                      padding: const EdgeInsets.all(16),
                      child: _buildAwardsTab(viewModel),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPersonalBackgroundTab(StudentProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Academic Information Section
        const Text(
          'Academic Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          'Course',
          viewModel.pdsViewModel.getController('course'),
          [
            'BSIT',
            'BSABE',
            'BSEnE',
            'BSHM',
            'BFPT',
            'BSA',
            'BTHM',
            'BSSW',
            'BSAF',
            'BTLED',
            'DAT-BAT',
          ],
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Year Level',
          viewModel.pdsViewModel.getController('yearLevel'),
          ['I', 'II', 'III', 'IV'],
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Academic Status',
          viewModel.pdsViewModel.getController('academicStatus'),
          [
            'Continuing/Old',
            'Returnee',
            'Shiftee',
            'New Student',
            'Transferee',
          ],
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'School Last Attended',
          viewModel.pdsViewModel.getController('schoolLastAttended'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Name of school',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Location of School',
          viewModel.pdsViewModel.getController('locationOfSchool'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'City, Province',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Previous Course/Grade',
          viewModel.pdsViewModel.getController('previousCourseGrade'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Previous course or grade level',
        ),
        const SizedBox(height: 24),
        // Personal Information Section
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Last name',
          viewModel.pdsViewModel.getController('lastName'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'First name',
          viewModel.pdsViewModel.getController('firstName'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Middle name',
          viewModel.pdsViewModel.getController('middleName'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Date of Birth',
          viewModel.pdsViewModel.getController('dateOfBirth'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          isDateField: true,
          viewModel: viewModel,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Place of Birth',
          viewModel.pdsViewModel.getController('placeOfBirth'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'City, Province',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Age',
          viewModel.pdsViewModel.getController('age'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Sex',
          viewModel.pdsViewModel.getController('sex'),
          ['Male', 'Female'],
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Civil Status',
          viewModel.pdsViewModel.getController('civilStatus'),
          ['Single', 'Married', 'Widowed', 'Legally Separated', 'Annulled'],
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Religion',
          viewModel.pdsViewModel.getController('religion'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Contact Number',
          viewModel.pdsViewModel.getController('contactNumber'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.phone,
          hintText: '09XXXXXXXXX',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'FB Account Name',
          viewModel.pdsViewModel.getController('fbAccountName'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Email Address',
          viewModel.pdsViewModel.getController('personalEmail'),
          enabled: false, // Read-only
          hintText: 'name@example.com',
        ),
        const SizedBox(height: 24),
        // Address Section
        const Text(
          'Permanent Home Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Zone',
          viewModel.pdsViewModel.getController('permanentZone'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Barangay',
          viewModel.pdsViewModel.getController('permanentBarangay'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'City',
          viewModel.pdsViewModel.getController('permanentCity'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Province',
          viewModel.pdsViewModel.getController('permanentProvince'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 24),
        const Text(
          'Present Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Zone',
          viewModel.pdsViewModel.getController('presentZone'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Barangay',
          viewModel.pdsViewModel.getController('presentBarangay'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'City',
          viewModel.pdsViewModel.getController('presentCity'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Province',
          viewModel.pdsViewModel.getController('presentProvince'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
      ],
    );
  }

  Widget _buildFamilyBackgroundTab(StudentProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Father Information
        const Text(
          'Father Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Father\'s Name',
          viewModel.pdsViewModel.getController('fatherName'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Father\'s Occupation',
          viewModel.pdsViewModel.getController('fatherOccupation'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Father\'s Educational Attainment',
          viewModel.pdsViewModel.getController('fatherEducationalAttainment'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Father\'s Age',
          viewModel.pdsViewModel.getController('fatherAge'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Father\'s Contact Number',
          viewModel.pdsViewModel.getController('fatherContactNumber'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.phone,
          hintText: '09XXXXXXXXX',
        ),
        const SizedBox(height: 24),
        // Mother Information
        const Text(
          'Mother Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Mother\'s Name',
          viewModel.pdsViewModel.getController('motherName'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Mother\'s Occupation',
          viewModel.pdsViewModel.getController('motherOccupation'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Mother\'s Educational Attainment',
          viewModel.pdsViewModel.getController('motherEducationalAttainment'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Mother\'s Age',
          viewModel.pdsViewModel.getController('motherAge'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Mother\'s Contact Number',
          viewModel.pdsViewModel.getController('motherContactNumber'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.phone,
          hintText: '09XXXXXXXXX',
        ),
        const SizedBox(height: 24),
        // Parents Information
        const Text(
          'Parents Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Parents Permanent Address',
          viewModel.pdsViewModel.getController('parentsPermanentAddress'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Parents Contact Number',
          viewModel.pdsViewModel.getController('parentsContactNumber'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.phone,
          hintText: '09XXXXXXXXX',
        ),
        const SizedBox(height: 24),
        // Spouse Information
        const Text(
          'Spouse Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Spouse Name',
          viewModel.pdsViewModel.getController('spouse'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Leave blank if not applicable',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Spouse Occupation',
          viewModel.pdsViewModel.getController('spouseOccupation'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Spouse Educational Attainment',
          viewModel.pdsViewModel.getController('spouseEducationalAttainment'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 24),
        // Guardian Information
        const Text(
          'Guardian Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Guardian Name',
          viewModel.pdsViewModel.getController('guardianName'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Guardian Age',
          viewModel.pdsViewModel.getController('guardianAge'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Guardian Occupation',
          viewModel.pdsViewModel.getController('guardianOccupation'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Guardian Contact Number',
          viewModel.pdsViewModel.getController('guardianContactNumber'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.phone,
          hintText: '09XXXXXXXXX',
        ),
      ],
    );
  }

  Widget _buildAwardsTab(StudentProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Awards and Recognition',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'List any awards or recognition you have received (up to 3)',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        // Award 1
        const Text(
          'Award 1',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Award Name',
          viewModel.pdsViewModel.getController('awardName1'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'e.g., Dean\'s Lister, Academic Excellence Award',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'School/Organization',
          viewModel.pdsViewModel.getController('awardSchoolOrg1'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Name of school or organization',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Year Received',
          viewModel.pdsViewModel.getController('awardYear1'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.number,
          hintText: 'YYYY',
        ),
        const SizedBox(height: 24),
        // Award 2
        const Text(
          'Award 2',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Award Name',
          viewModel.pdsViewModel.getController('awardName2'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'e.g., Dean\'s Lister, Academic Excellence Award',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'School/Organization',
          viewModel.pdsViewModel.getController('awardSchoolOrg2'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Name of school or organization',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Year Received',
          viewModel.pdsViewModel.getController('awardYear2'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.number,
          hintText: 'YYYY',
        ),
        const SizedBox(height: 24),
        // Award 3
        const Text(
          'Award 3',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Award Name',
          viewModel.pdsViewModel.getController('awardName3'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'e.g., Dean\'s Lister, Academic Excellence Award',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'School/Organization',
          viewModel.pdsViewModel.getController('awardSchoolOrg3'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Name of school or organization',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Year Received',
          viewModel.pdsViewModel.getController('awardYear3'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          keyboardType: TextInputType.number,
          hintText: 'YYYY',
        ),
      ],
    );
  }

  Widget _buildOtherInfoTab(StudentProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Special Circumstances
        const Text(
          'Special Circumstances',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 16),

        _buildRadioGroup('Are you a solo parent?', 'soloParent', [
          'Yes',
          'No',
        ], viewModel),
        const SizedBox(height: 16),

        _buildRadioGroup('Member of indigenous people?', 'indigenous', [
          'Yes',
          'No',
        ], viewModel),
        const SizedBox(height: 16),

        _buildRadioGroup('Are you a breast-feeding mother?', 'breastFeeding', [
          'Yes',
          'No',
          'N/A',
        ], viewModel),
        const SizedBox(height: 16),

        _buildRadioGroup('Are you a person with disability?', 'pwd', [
          'Yes',
          'No',
          'Other',
        ], viewModel),
        const SizedBox(height: 16),

        _buildTextField(
          'Specify disability (put N/A if not applicable)',
          viewModel.pdsViewModel.getController('pwdDisabilityType'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'N/A',
        ),
        const SizedBox(height: 16),

        // PWD Proof File Upload
        _buildFileUploadField(
          'Attach PWD ID / Proof of Disability',
          'pwdProof',
          viewModel,
        ),
        const SizedBox(height: 24),

        // Course Choice Reason
        const Text(
          'Course Choice',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Why did you choose this course?',
          viewModel.pdsViewModel.getController('courseChoiceReason'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Explain your reason for choosing this course',
        ),
        const SizedBox(height: 24),

        // Family Description
        const Text(
          'Family Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildCheckboxField(
          'harmonious',
          'familyDescHarmonious',
          'Harmonious',
          viewModel,
        ),
        _buildCheckboxField(
          'conflict',
          'familyDescConflict',
          'With conflict',
          viewModel,
        ),
        _buildCheckboxField(
          'separated_parents',
          'familyDescSeparatedParents',
          'Separated parents',
          viewModel,
        ),
        _buildCheckboxField(
          'parents_working_abroad',
          'familyDescParentsWorkingAbroad',
          'Parents working abroad',
          viewModel,
        ),
        _buildTextField(
          'Other (specify)',
          viewModel.pdsViewModel.getController('familyDescriptionOther'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Other family description',
        ),
        const SizedBox(height: 24),

        // Living Condition
        const Text(
          'Living Condition',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildRadioGroup('', 'livingCondition', [
          'good_environment',
          'supportive_family',
          'financial_challenges',
          'unstable_housing',
        ], viewModel),
        const SizedBox(height: 24),

        // Physical Health Condition
        const Text(
          'Physical Health Condition',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildRadioGroup(
          'Do you have any physical health conditions?',
          'physicalHealthCondition',
          ['Yes', 'No'],
          viewModel,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Specify condition (if Yes)',
          viewModel.pdsViewModel.getController(
            'physicalHealthConditionSpecify',
          ),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Specify your health condition',
        ),
        const SizedBox(height: 24),

        // Psychological Treatment
        _buildRadioGroup(
          'Have you undergone or are currently undergoing psychological treatment?',
          'psychTreatment',
          ['Yes', 'No'],
          viewModel,
        ),
        const SizedBox(height: 24),

        // GCS Activities
        const Text(
          'Guidance Counseling Services Activities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Select activities you are interested in:',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 12),
        _buildCheckboxField(
          'adjustment',
          'gcsAdjustment',
          'Adjustment to college life',
          viewModel,
        ),
        _buildCheckboxField(
          'building_self_confidence',
          'gcsSelfConfidence',
          'Building self-confidence',
          viewModel,
        ),
        _buildCheckboxField(
          'developing_communication_skills',
          'gcsCommunication',
          'Developing communication skills',
          viewModel,
        ),
        _buildCheckboxField(
          'study_habits',
          'gcsStudyHabits',
          'Study habits',
          viewModel,
        ),
        _buildCheckboxField(
          'time_management',
          'gcsTimeManagement',
          'Time management',
          viewModel,
        ),
        _buildCheckboxField(
          'tutorial_with_peers',
          'gcsTutorial',
          'Tutorial with peers',
          viewModel,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Tutorial subjects (if applicable)',
          viewModel.pdsViewModel.getController('tutorialSubjects'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'e.g., Math, Science',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Other activities',
          viewModel.pdsViewModel.getController('gcsOther'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Specify other activities',
        ),
        const SizedBox(height: 24),

        // Services Needed
        const Text(
          'Services Needed (check all that apply)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildCheckboxField(
          'counseling',
          'svcCounseling',
          'Counseling',
          viewModel,
        ),
        _buildCheckboxField(
          'insurance',
          'svcInsurance',
          'Insurance',
          viewModel,
        ),
        _buildCheckboxField(
          'special lanes for PWD/pregnant/elderly in all office',
          'svcSpecialLanes',
          'Special lanes for PWD/pregnant/elderly in all office',
          viewModel,
        ),
        _buildCheckboxField(
          'safe learning environment, free from any form of discrimination',
          'svcSafeLearning',
          'Safe learning environment, free from any form of discrimination',
          viewModel,
        ),
        _buildCheckboxField(
          'equal access to quality education',
          'svcEqualAccess',
          'Equal access to quality education',
          viewModel,
        ),
        _buildTextField(
          'Other (specify)',
          viewModel.pdsViewModel.getController('svcOther'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Other (specify)',
        ),
        const SizedBox(height: 24),

        // Services Availed
        const Text(
          'Services Availed in the University',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildCheckboxField(
          'counseling',
          'availedCounseling',
          'Counseling',
          viewModel,
        ),
        _buildCheckboxField(
          'insurance',
          'availedInsurance',
          'Insurance',
          viewModel,
        ),
        _buildCheckboxField(
          'special lanes for PWD/pregnant/elderly in all office',
          'availedSpecialLanes',
          'Special lanes for PWD/pregnant/elderly in all office',
          viewModel,
        ),
        _buildCheckboxField(
          'safe learning environment, free from any form of discrimination',
          'availedSafeLearning',
          'Safe learning environment, free from any form of discrimination',
          viewModel,
        ),
        _buildCheckboxField(
          'equal access to quality education',
          'availedEqualAccess',
          'Equal access to quality education',
          viewModel,
        ),
        _buildTextField(
          'Other (specify)',
          viewModel.pdsViewModel.getController('availedOther'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Other (specify)',
        ),
        const SizedBox(height: 24),

        // Current Residence
        const Text(
          'Current Residence',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 12),
        _buildRadioGroup('', 'residence', [
          'at home',
          'boarding house',
          'USTP-Claveria Dormitory',
          'relatives',
          'friends',
          'Other',
        ], viewModel),
        _buildTextField(
          'Other (specify)',
          viewModel.pdsViewModel.getController('residenceOtherSpecify'),
          enabled: viewModel.pdsViewModel.isPdsEditingEnabled,
          hintText: 'Other (specify)',
        ),
        const SizedBox(height: 24),

        // Consent
        _buildCheckboxField(
          'consentAgree',
          'consentAgree',
          'I voluntarily give my consent to participate in this survey.',
          viewModel,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController? controller, {
    bool enabled = true,
    TextInputType? keyboardType,
    String? hintText,
    bool isDateField = false,
    StudentProfileViewModel? viewModel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        isDateField && viewModel != null
            ? _buildDateField(controller, enabled, viewModel)
            : TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 16), // Larger text for mobile
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
                ),
              ),
      ],
    );
  }

  Widget _buildDateField(
    TextEditingController? controller,
    bool enabled,
    StudentProfileViewModel viewModel,
  ) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: true, // Make it read-only so users must use the calendar
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'DD/MM/YYYY',
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
        suffixIcon: enabled
            ? IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF2563EB),
                ),
                onPressed: () => _selectDate(context, controller, viewModel),
              )
            : null,
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController? controller,
    StudentProfileViewModel viewModel,
  ) async {
    if (!viewModel.pdsViewModel.isPdsEditingEnabled) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(controller?.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color(0xFF374151), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      controller?.text = formattedDate;
    }
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Widget _buildDropdownField(
    String label,
    TextEditingController? controller,
    List<String> options, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        // Wrap with AnimatedBuilder to rebuild when controller changes
        AnimatedBuilder(
          animation: controller ?? ValueNotifier(''),
          builder: (context, child) {
            // Get current value from controller, validating it's in options
            String? initialValue;
            if (controller?.text.isNotEmpty == true) {
              final controllerText = controller!.text.trim();
              // Only use if it's a valid option
              if (options.contains(controllerText)) {
                initialValue = controllerText;
              }
            }

            return DropdownButtonFormField<String>(
              key: ValueKey(
                '${label}_${initialValue ?? "empty"}',
              ), // Force rebuild on value change
              initialValue: initialValue,
              onChanged: enabled
                  ? (value) {
                      if (value != null && controller != null) {
                        controller.text = value;
                      }
                    }
                  : null,
              style: const TextStyle(fontSize: 16, color: Color(0xFF374151)),
              decoration: InputDecoration(
                hintText: 'Select $label',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFF3F4F6),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
              ),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRadioGroup(
    String label,
    String groupName,
    List<String> options,
    StudentProfileViewModel viewModel,
  ) {
    final String selectedValue = viewModel.pdsViewModel.getRadioValue(
      groupName,
    );
    const activeColor = Color(0xFF2563EB);
    const borderColor = Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),

        // Use Column with for loop (no toList, no deprecated API)
        Column(
          children: [
            for (final option in options)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedValue == option ? activeColor : borderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: selectedValue == option
                      ? const Color(0xFFEBF4FF)
                      : Colors.white,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: viewModel.pdsViewModel.isPdsEditingEnabled
                      ? () {
                          // Only call handler when editing is enabled
                          viewModel.pdsViewModel.setRadioValue(
                            groupName,
                            option,
                          );
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // Custom radio icon
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedValue == option
                                  ? activeColor
                                  : borderColor,
                              width: 2,
                            ),
                            color: selectedValue == option
                                ? activeColor
                                : Colors.white,
                          ),
                          child: selectedValue == option
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),

                        const SizedBox(width: 12),

                        // Label
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: selectedValue == option
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: selectedValue == option
                                  ? activeColor
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),

                        // Optional small chevron or indicator if you want
                        // Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxField(
    String value,
    String fieldName,
    String label,
    StudentProfileViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontSize: 16)),
        value: viewModel.pdsViewModel.getCheckboxValue(fieldName),
        onChanged: viewModel.pdsViewModel.isPdsEditingEnabled
            ? (bool? newValue) {
                if (newValue != null) {
                  viewModel.pdsViewModel.setCheckboxValue(fieldName, newValue);
                }
              }
            : null,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: const Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildFileUploadField(
    String label,
    String fieldName,
    StudentProfileViewModel viewModel,
  ) {
    // Get existing PWD proof file from PDS data
    final existingPwdProofFile = viewModel.pdsViewModel.pwdProofFile;
    // Use the selected file from PDS ViewModel instead of local state
    final selectedFile = viewModel.pdsViewModel.selectedPwdProofFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedFile != null
                          ? selectedFile.name
                          : 'Choose file...',
                      style: TextStyle(
                        color: selectedFile != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: viewModel.pdsViewModel.isPdsEditingEnabled
                        ? () async {
                            // Store context before async operations
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );

                            try {
                              // Try file_picker first for comprehensive file support
                              final result = await FilePicker.platform
                                  .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'jpg', 'jpeg', 'png', 'gif', // Images
                                      'pdf', // PDF documents
                                      'doc', 'docx', // Word documents
                                      'xls', 'xlsx', // Excel documents
                                      'mp4', 'avi', 'mov', // Videos
                                      'txt', 'rtf', // Text documents
                                    ],
                                    allowMultiple: false,
                                  );
                              if (result != null && result.files.isNotEmpty) {
                                final file = result.files.first;
                                // Pass the file to PDS ViewModel
                                viewModel.pdsViewModel.setPwdProofFile(file);
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'File selected: ${file.name}',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('File picker error: $e');
                              // Fallback to image picker for images only
                              try {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null) {
                                  // Convert XFile to PlatformFile for consistency
                                  final platformFile = PlatformFile(
                                    name: image.name,
                                    path: image.path,
                                    size: await File(image.path).length(),
                                  );
                                  // Pass the file to PDS ViewModel
                                  viewModel.pdsViewModel.setPwdProofFile(
                                    platformFile,
                                  );
                                  if (mounted) {
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Image selected: ${image.name}',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              } catch (fallbackError) {
                                debugPrint(
                                  'Image picker fallback error: $fallbackError',
                                );
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error selecting file: ${e.toString()}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        : null,
                    icon: const Icon(Icons.attach_file, size: 16),
                    label: const Text('Choose File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C757D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),

              // Show existing PWD proof file if available AND no new file is selected
              if (selectedFile == null &&
                  existingPwdProofFile.isNotEmpty &&
                  existingPwdProofFile != 'N/A')
                _buildPwdProofDisplayBox(existingPwdProofFile, viewModel),

              // Preview section for newly selected file
              if (selectedFile != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFileIcon(
                          selectedFile.extension ??
                              (selectedFile.name.split('.').length > 1
                                  ? selectedFile.name.split('.').last
                                  : ''),
                        ),
                        size: 16,
                        color: _getFileIconColor(
                          selectedFile.extension ??
                              (selectedFile.name.split('.').length > 1
                                  ? selectedFile.name.split('.').last
                                  : ''),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'File ready to upload: ${selectedFile.name}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _showFilePreviewModal(context, selectedFile, true),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Preview'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Build proper file URL for PWD proof files
  String _buildFileUrl(String filePath) {
    // Remove index.php from base URL and construct proper file URL
    final baseUrl = ApiConfig.currentBaseUrl.replaceAll('/index.php', '');

    // Ensure base URL ends with slash and file path doesn't start with slash
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleanFilePath = filePath.startsWith('/')
        ? filePath.substring(1)
        : filePath;

    final url = '$cleanBaseUrl$cleanFilePath';
    debugPrint('File URL Construction - Base URL: $baseUrl');
    debugPrint('File URL Construction - Clean Base URL: $cleanBaseUrl');
    debugPrint('File URL Construction - File Path: $filePath');
    debugPrint('File URL Construction - Clean File Path: $cleanFilePath');
    debugPrint('File URL Construction - Final URL: $url');
    return url;
  }

  // Build PWD proof display box for existing files
  Widget _buildPwdProofDisplayBox(
    String filePath,
    StudentProfileViewModel viewModel,
  ) {
    debugPrint('PWD Proof Display Box - File Path: $filePath');
    final fileName = filePath.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getFileIcon(fileExtension),
                    size: 20,
                    color: _getFileIconColor(fileExtension),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getFileTypeDescription(fileExtension),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showFilePreviewModal(context, filePath, false),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadFile(filePath, fileName),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C757D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get appropriate icon for file type
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      case 'txt':
      case 'rtf':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get appropriate color for file icon
  Color _getFileIconColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.purple;
      case 'txt':
      case 'rtf':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Get file type description
  String _getFileTypeDescription(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image File';
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'Video File';
      case 'txt':
      case 'rtf':
        return 'Text Document';
      default:
        return 'Document File';
    }
  }

  // Show file preview modal
  void _showFilePreviewModal(
    BuildContext context,
    dynamic fileData,
    bool isNewFile,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.file_present, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isNewFile ? 'File Preview' : 'PWD Proof Preview',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(child: _buildFilePreviewContent(fileData, isNewFile)),
            ],
          ),
        ),
      ),
    );
  }

  // Build file preview content based on file type
  Widget _buildFilePreviewContent(dynamic fileData, bool isNewFile) {
    if (isNewFile && fileData is PlatformFile) {
      // Preview newly selected file
      final fileExtension =
          fileData.extension?.toLowerCase() ??
          (fileData.name.split('.').length > 1
              ? fileData.name.split('.').last.toLowerCase()
              : '');

      if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
        return Column(
          children: [
            Expanded(
              child: Image.file(
                File(fileData.path!),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 48, color: Colors.red),
                        SizedBox(height: 8),
                        Text('Error loading image'),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File: ${fileData.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        );
      } else if (['mp4', 'avi', 'mov'].contains(fileExtension)) {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: VideoPlayerWidget(filePath: fileData.path!),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File: ${fileData.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        );
      } else if (fileExtension == 'pdf') {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'PDF Document',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'File: ${fileData.name}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // In a real implementation, you would use a PDF viewer package
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'PDF viewer would be implemented here',
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFileIcon(fileExtension),
                size: 64,
                color: _getFileIconColor(fileExtension),
              ),
              const SizedBox(height: 16),
              Text(
                'File: ${fileData.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This file type cannot be previewed.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }
    } else if (!isNewFile && fileData is String) {
      // Preview existing file from server
      final fileName = fileData.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final imageUrl = _buildFileUrl(fileData);

      debugPrint('PWD Proof Preview - File Path: $fileData');
      debugPrint('PWD Proof Preview - Image URL: $imageUrl');
      debugPrint('PWD Proof Preview - File Extension: $fileExtension');

      if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
        return Column(
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('PWD Proof Image Error: $error');
                  debugPrint('PWD Proof Image URL: $imageUrl');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        const Text('Error loading image'),
                        Text('URL: $imageUrl'),
                        const Text('File may not exist or be corrupted'),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File: $fileName',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        );
      } else if (fileExtension == 'pdf') {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'PDF Document',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'File: $fileName',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // In a real implementation, you would use a PDF viewer package
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'PDF viewer would be implemented here',
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFileIcon(fileExtension),
                size: 64,
                color: _getFileIconColor(fileExtension),
              ),
              const SizedBox(height: 16),
              Text(
                'File: $fileName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _downloadFile(fileData, fileName),
                icon: const Icon(Icons.download),
                label: const Text('Download File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    }

    return const Center(child: Text('No file to preview'));
  }

  // Download file functionality
  void _downloadFile(String filePath, String fileName) {
    // For now, show a message that download functionality would be implemented
    // In a real implementation, you would use packages like 'url_launcher' or 'open_file'
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Download functionality for $fileName would be implemented here',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // These methods are no longer needed as radio buttons are handled by ViewModel

  Future<void> _savePDSData(StudentProfileViewModel viewModel) async {
    final success = await viewModel.pdsViewModel.savePDSData(viewModel.email);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal Data Sheet saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.pdsViewModel.saveError ?? 'Failed to save PDS data',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUpdateProfileDialog(
    StudentProfileViewModel viewModel,
    UpdateProfileDialogMode mode,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _UpdateProfileDialog(viewModel: viewModel, mode: mode),
    );
  }

  void _showChangePasswordDialog(StudentProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(viewModel: viewModel),
    );
  }
}

class _UpdateProfileDialog extends StatefulWidget {
  final StudentProfileViewModel viewModel;
  final UpdateProfileDialogMode mode;

  const _UpdateProfileDialog({required this.viewModel, required this.mode});

  @override
  State<_UpdateProfileDialog> createState() => _UpdateProfileDialogState();
}

class _UpdateProfileDialogState extends State<_UpdateProfileDialog> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.viewModel.username;
    _emailController.text = widget.viewModel.email;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.mode == UpdateProfileDialogMode.pictureOnly
            ? 'Update Profile Picture'
            : 'Update Profile Information',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.mode == UpdateProfileDialogMode.infoOnly) ...[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
            if (widget.mode == UpdateProfileDialogMode.pictureOnly) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Profile Picture',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              )
                            : _buildCurrentProfileImage(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, size: 16),
                      label: const Text('Choose Image'),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade900,
                                  height: 1.4,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Important: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'Please use PDS-friendly formats like 2x2 or 1x1 passport-style photos with a plain white or light background for official documentation.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.viewModel.isUpdatingProfile ? null : _updateProfile,
          child: widget.viewModel.isUpdatingProfile
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildCurrentProfileImage() {
    final profile = widget.viewModel.profile;
    final picturePath = profile?.profilePicture;
    final hasProfilePicture = picturePath != null && picturePath.isNotEmpty;
    if (hasProfilePicture) {
      return Image.network(
        profile!.buildImageUrl(ApiConfig.currentBaseUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('Photos/profile.png', fit: BoxFit.cover);
        },
      );
    }
    return Image.asset('Photos/profile.png', fit: BoxFit.cover);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _updateProfile() async {
    final success = await widget.viewModel.updateProfile(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      profilePicture: _selectedImage,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.updateError ?? 'Failed to update profile',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final StudentProfileViewModel viewModel;

  const _ChangePasswordDialog({required this.viewModel});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.viewModel.isChangingPassword
              ? null
              : _changePassword,
          child: widget.viewModel.isChangingPassword
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 8 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await widget.viewModel.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.passwordError ?? 'Failed to change password',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Simple video player widget for PWD proof videos
class VideoPlayerWidget extends StatefulWidget {
  final String filePath;

  const VideoPlayerWidget({super.key, required this.filePath});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Video Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File: ${widget.filePath.split('/').last}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // In a real implementation, you would use video_player package
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video player would be implemented here'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
