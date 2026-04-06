import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'state/counselor_profile_viewmodel.dart';
import 'widgets/counselor_screen_wrapper.dart';
import 'models/counselor_availability.dart';

enum CounselorUpdateDialogMode { infoOnly, pictureOnly }

class CounselorProfileScreen extends StatefulWidget {
  const CounselorProfileScreen({super.key});

  @override
  State<CounselorProfileScreen> createState() => _CounselorProfileScreenState();
}

class _CounselorProfileScreenState extends State<CounselorProfileScreen> {
  late CounselorProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CounselorProfileViewModel();
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
      child: CounselorScreenWrapper(
        currentBottomNavIndex: -1, // Not in bottom nav
        child: _buildMainContent(context),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 16
              : isTablet
              ? 20
              : 24,
          vertical: isMobile ? 20 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isMobile ? 20 : 30),
            _buildProfileContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Consumer<CounselorProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF060E57)),
            ),
          );
        }

        // Profile will always be available (either real or default)
        // No need to check for null anymore

        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 1024;

        if (isDesktop) {
          return _buildDesktopLayout(context, viewModel);
        } else {
          return _buildMobileLayout(context, viewModel);
        }
      },
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CounselorProfileViewModel viewModel,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Account Settings
        Expanded(flex: 2, child: _buildAccountSettingsCard(context, viewModel)),
        const SizedBox(width: 24),
        // Right Column - Personal Information & Availability
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildPersonalInfoCard(context, viewModel),
              const SizedBox(height: 24),
              _buildAvailabilityCard(context, viewModel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    CounselorProfileViewModel viewModel,
  ) {
    return Column(
      children: [
        _buildAccountSettingsCard(context, viewModel),
        const SizedBox(height: 24),
        _buildPersonalInfoCard(context, viewModel),
        const SizedBox(height: 24),
        _buildAvailabilityCard(context, viewModel),
      ],
    );
  }

  Widget _buildAccountSettingsCard(
    BuildContext context,
    CounselorProfileViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Header with Gradient - Full Width
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF060E57), Color(0xFF4169E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          viewModel.buildImageUrl(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF060E57),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _showUpdateProfileDialog(
                          context,
                          CounselorUpdateDialogMode.pictureOnly,
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
                const SizedBox(height: 16),
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Account ID: ${viewModel.profile?.userId ?? "N/A"}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Account Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 1),
                _buildAccountField(
                  'Username',
                  viewModel.profile?.username ?? 'N/A',
                ),
                const SizedBox(height: 16),
                _buildAccountField('Email', viewModel.profile?.email ?? 'N/A'),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showChangePasswordDialog(context),
                        icon: const Icon(Icons.key_sharp, size: 18),
                        label: const Text('Change Password'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 1),
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
                          context,
                          CounselorUpdateDialogMode.infoOnly,
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
              ],
            ),
          ),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF060E57),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(
    BuildContext context,
    CounselorProfileViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFD),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: const Color(0xFF060E57),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF060E57),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildPersonalInfoField('Full Name', viewModel.counselorName),
                _buildPersonalInfoField(
                  'Date of Birth',
                  viewModel.formattedBirthdate,
                ),
                _buildPersonalInfoField('Sex', viewModel.counselorSex),
                _buildPersonalInfoField('Degree', viewModel.counselorDegree),
                _buildPersonalInfoField(
                  'Civil Status',
                  viewModel.counselorCivilStatus,
                ),
                _buildPersonalInfoField(
                  'Contact Number',
                  viewModel.counselorContact,
                ),
                _buildPersonalInfoField('Email', viewModel.counselorEmail),
                _buildPersonalInfoField('Address', viewModel.counselorAddress),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditPersonalInfoDialog(context),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Personal Info'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF060E57),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(
    BuildContext context,
    CounselorProfileViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFD),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: const Color(0xFF060E57), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF060E57),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.availability == null ||
                    viewModel.availability!.availableDays.isEmpty) ...[
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No availability schedule set',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set your available days and times',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ...viewModel.availability!.availableDays.map(
                    (day) => _buildAvailabilityDay(
                      day,
                      viewModel.availability!.getTimeRangesForDay(day),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditAvailabilityDialog(context),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Availability'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityDay(String day, List<TimeRange> timeRanges) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF060E57),
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: timeRanges
                  .map(
                    (range) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060E57),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${range.from} - ${range.to}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Methods
  void _showUpdateProfileDialog(
    BuildContext context, [
    CounselorUpdateDialogMode mode = CounselorUpdateDialogMode.infoOnly,
  ]) {
    // Debug current profile data
    debugPrint('🔍 Current profile data:');
    debugPrint('🔍 Username: "${_viewModel.profile?.username}"');
    debugPrint('🔍 Email: "${_viewModel.profile?.email}"');
    debugPrint('🔍 Profile null: ${_viewModel.profile == null}');

    final usernameController = TextEditingController(
      text: _viewModel.profile?.username ?? '',
    );
    final emailController = TextEditingController(
      text: _viewModel.profile?.email ?? '',
    );
    File? selectedImageFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            mode == CounselorUpdateDialogMode.pictureOnly
                ? 'Update Profile Picture'
                : 'Update Profile Information',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (mode == CounselorUpdateDialogMode.infoOnly) ...[
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (mode == CounselorUpdateDialogMode.pictureOnly) ...[
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
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: selectedImageFile != null
                                ? Image.file(
                                    selectedImageFile!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _viewModel.buildImageUrl(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(() {
                                  selectedImageFile = File(image.path);
                                });
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error picking image: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text('Choose Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF060E57),
                            foregroundColor: Colors.white,
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
              onPressed: _viewModel.isUpdatingProfile
                  ? null
                  : () async {
                      // Debug controller values
                      debugPrint('🔍 Dialog Save Button - Controller Values:');
                      debugPrint(
                        '🔍 Username controller: "${usernameController.text}"',
                      );
                      debugPrint(
                        '🔍 Email controller: "${emailController.text}"',
                      );
                      debugPrint(
                        '🔍 Username trimmed: "${usernameController.text.trim()}"',
                      );
                      debugPrint(
                        '🔍 Email trimmed: "${emailController.text.trim()}"',
                      );
                      debugPrint(
                        '🔍 Username isEmpty: ${usernameController.text.trim().isEmpty}',
                      );
                      debugPrint(
                        '🔍 Email isEmpty: ${emailController.text.trim().isEmpty}',
                      );

                      // Validate inputs like backend does
                      if (mode == CounselorUpdateDialogMode.infoOnly) {
                        if (usernameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Username is required'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (emailController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email is required'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(emailController.text.trim())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid email address',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      bool success = true;

                      if (mode == CounselorUpdateDialogMode.infoOnly) {
                        success = await _viewModel.updateProfile(
                          username: usernameController.text.trim(),
                          email: emailController.text.trim(),
                        );
                      }

                      final shouldUploadPicture =
                          selectedImageFile != null &&
                          success &&
                          mode == CounselorUpdateDialogMode.pictureOnly;

                      if (shouldUploadPicture) {
                        final pictureSuccess = await _viewModel
                            .uploadProfilePicture(selectedImageFile!);
                        if (!pictureSuccess) {
                          success = false;
                        }
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _viewModel.profileUpdateError ??
                                    _viewModel.pictureUploadError ??
                                    'Failed to update profile',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: _viewModel.isUpdatingProfile
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
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
              onPressed: _viewModel.isUpdatingPassword
                  ? null
                  : () async {
                      // Validate inputs like backend does - all fields required
                      if (currentPasswordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Current password is required'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New password is required'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (confirmPasswordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Confirm password is required'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'New password must be at least 8 characters long',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final success = await _viewModel.updatePassword(
                        currentPassword: currentPasswordController.text.trim(),
                        newPassword: newPasswordController.text.trim(),
                        confirmPassword: confirmPasswordController.text.trim(),
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _viewModel.passwordError ??
                                    'Failed to update password',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: _viewModel.isUpdatingPassword
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPersonalInfoDialog(BuildContext context) {
    // Get default values, replacing 'N/A' and 'none' with empty strings for editing
    final fullnameController = TextEditingController(
      text: _viewModel.counselorName == 'N/A' ? '' : _viewModel.counselorName,
    );
    final birthdateController = TextEditingController(
      text: _viewModel.counselorBirthdate == 'N/A'
          ? ''
          : _viewModel.counselorBirthdate,
    );
    final addressController = TextEditingController(
      text: _viewModel.counselorAddress == 'N/A'
          ? ''
          : _viewModel.counselorAddress,
    );
    final degreeController = TextEditingController(
      text: _viewModel.counselorDegree == 'N/A'
          ? ''
          : _viewModel.counselorDegree,
    );
    final emailController = TextEditingController(
      text: _viewModel.counselorEmail == 'N/A' ? '' : _viewModel.counselorEmail,
    );
    final contactController = TextEditingController(
      text: _viewModel.counselorContact == 'N/A'
          ? ''
          : _viewModel.counselorContact,
    );
    String selectedSex = _viewModel.counselorSex == 'none'
        ? ''
        : _viewModel.counselorSex;
    String selectedCivilStatus = _viewModel.counselorCivilStatus == 'none'
        ? ''
        : _viewModel.counselorCivilStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Personal Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fullnameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: birthdateController,
                  decoration: const InputDecoration(
                    labelText: 'Birthdate (YYYY-MM-DD)',
                    hintText: 'Enter your birthdate (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: degreeController,
                  decoration: const InputDecoration(
                    labelText: 'Degree',
                    hintText: 'Enter your degree',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Comprehensive responsive layout for dropdowns with multiple breakpoints
                Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;

                    // Step 2: Additional responsive breakpoints for very narrow screens
                    if (screenWidth < 300) {
                      // Very narrow screens: Always vertical layout with minimal spacing
                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: selectedSex.isEmpty
                                ? null
                                : selectedSex,
                            decoration: const InputDecoration(
                              labelText: 'Sex',
                              hintText: 'Sex',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => selectedSex = value ?? ''),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedCivilStatus.isEmpty
                                ? null
                                : selectedCivilStatus,
                            decoration: const InputDecoration(
                              labelText: 'Civil Status',
                              hintText: 'Status',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Single',
                                child: Text('Single'),
                              ),
                              DropdownMenuItem(
                                value: 'Married',
                                child: Text('Married'),
                              ),
                              DropdownMenuItem(
                                value: 'Widowed',
                                child: Text('Widowed'),
                              ),
                              DropdownMenuItem(
                                value: 'Separated',
                                child: Text('Separated'),
                              ),
                            ],
                            onChanged: (value) => setState(
                              () => selectedCivilStatus = value ?? '',
                            ),
                          ),
                        ],
                      );
                    } else if (screenWidth < 400) {
                      // Narrow screens: Vertical layout with normal spacing
                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: selectedSex.isEmpty
                                ? null
                                : selectedSex,
                            decoration: const InputDecoration(
                              labelText: 'Sex',
                              hintText: 'Select your sex',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => selectedSex = value ?? ''),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: selectedCivilStatus.isEmpty
                                ? null
                                : selectedCivilStatus,
                            decoration: const InputDecoration(
                              labelText: 'Civil Status',
                              hintText: 'Select your civil status',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Single',
                                child: Text('Single'),
                              ),
                              DropdownMenuItem(
                                value: 'Married',
                                child: Text('Married'),
                              ),
                              DropdownMenuItem(
                                value: 'Widowed',
                                child: Text('Widowed'),
                              ),
                              DropdownMenuItem(
                                value: 'Separated',
                                child: Text('Separated'),
                              ),
                            ],
                            onChanged: (value) => setState(
                              () => selectedCivilStatus = value ?? '',
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Wide screens: Horizontal layout with optimized spacing
                      return Row(
                        children: [
                          // Step 3: Alternative layout approach using Flexible widgets
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedSex.isEmpty
                                  ? null
                                  : selectedSex,
                              decoration: const InputDecoration(
                                labelText: 'Sex',
                                hintText: 'Sex',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text('Male'),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text('Female'),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text('Other'),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => selectedSex = value ?? ''),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedCivilStatus.isEmpty
                                  ? null
                                  : selectedCivilStatus,
                              decoration: const InputDecoration(
                                labelText: 'Civil Status',
                                hintText: 'Status',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Single',
                                  child: Text('Single'),
                                ),
                                DropdownMenuItem(
                                  value: 'Married',
                                  child: Text('Married'),
                                ),
                                DropdownMenuItem(
                                  value: 'Widowed',
                                  child: Text('Widowed'),
                                ),
                                DropdownMenuItem(
                                  value: 'Separated',
                                  child: Text('Separated'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => selectedCivilStatus = value ?? '',
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    hintText: 'Enter your contact number',
                    border: OutlineInputBorder(),
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
              onPressed: _viewModel.isUpdatingPersonalInfo
                  ? null
                  : () async {
                      debugPrint('🔍 Dialog Save Button - Controller Values:');
                      debugPrint(
                        '🔍 Fullname: "${fullnameController.text.trim()}"',
                      );
                      debugPrint(
                        '🔍 Contact: "${contactController.text.trim()}"',
                      );
                      debugPrint('🔍 Email: "${emailController.text.trim()}"');
                      debugPrint(
                        '🔍 Address: "${addressController.text.trim()}"',
                      );
                      debugPrint(
                        '🔍 Degree: "${degreeController.text.trim()}"',
                      );
                      debugPrint(
                        '🔍 Birthdate: "${birthdateController.text.trim()}"',
                      );
                      debugPrint('🔍 Sex: "$selectedSex"');
                      debugPrint('🔍 Civil Status: "$selectedCivilStatus"');

                      // Validate required fields before sending
                      if (fullnameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Full name is required'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final success = await _viewModel.updatePersonalInfo(
                        fullname: fullnameController.text.trim(),
                        birthdate: birthdateController.text.trim(),
                        address: addressController.text.trim(),
                        degree: degreeController.text.trim(),
                        email: emailController.text.trim(),
                        contact: contactController.text.trim(),
                        sex: selectedSex,
                        civilStatus: selectedCivilStatus,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Personal information updated successfully!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _viewModel.personalInfoError ??
                                    'Failed to update personal information',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: _viewModel.isUpdatingPersonalInfo
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAvailabilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AvailabilityManagementDialog(viewModel: _viewModel),
    );
  }
}

// Availability Management Dialog
class AvailabilityManagementDialog extends StatefulWidget {
  final CounselorProfileViewModel viewModel;

  const AvailabilityManagementDialog({super.key, required this.viewModel});

  @override
  State<AvailabilityManagementDialog> createState() =>
      _AvailabilityManagementDialogState();
}

class _AvailabilityManagementDialogState
    extends State<AvailabilityManagementDialog> {
  final List<String> _selectedDays = [];
  final Map<String, List<TimeRange>> _timeRangesByDay = {};
  String _selectedFromTime = '7:00 AM';
  String _selectedToTime = '5:30 PM';
  static const List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    _initializeTimeOptions();
    _loadCurrentAvailability();
  }

  void _initializeTimeOptions() {
    // Generate time options from 7:00 AM to 5:30 PM in 30-minute intervals
    // Exclude 12:00 PM and 12:30 PM as per backend logic
  }

  void _loadCurrentAvailability() {
    final availability = widget.viewModel.availability;
    if (availability == null) {
      return;
    }
    setState(() {
      _selectedDays.clear();
      _timeRangesByDay.clear();
      for (final day in availability.availableDays) {
        _selectedDays.add(day);
        final ranges = availability.getTimeRangesForDay(day);
        _timeRangesByDay[day] = ranges
            .map((r) => TimeRange(from: r.from, to: r.to))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Availability',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF060E57),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Days',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF060E57),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: _allDays
                          .map(
                            (day) => FilterChip(
                              label: Text(day),
                              selected: _selectedDays.contains(day),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedDays.add(day);
                                  } else {
                                    _selectedDays.remove(day);
                                    // Do not remove existing time ranges when unchecking the day.
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    // --- Add Time Slot area: only show if at least one day checked
                    if (_selectedDays.isNotEmpty) ...[
                      const Text(
                        'Available Times (per selected day)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF060E57),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Responsive layout for adding time slot
                      Builder(
                        builder: (context) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final isMobile = screenWidth < 600;
                          if (isMobile) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _selectedFromTime,
                                        decoration: const InputDecoration(
                                          labelText: 'From',
                                          border: OutlineInputBorder(),
                                        ),
                                        isExpanded: true,
                                        isDense: true,
                                        items: _getTimeOptions()
                                            .map(
                                              (time) => DropdownMenuItem(
                                                value: time,
                                                child: Text(time),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) => setState(
                                          () => _selectedFromTime = value!,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _selectedToTime,
                                        decoration: const InputDecoration(
                                          labelText: 'To',
                                          border: OutlineInputBorder(),
                                        ),
                                        isExpanded: true,
                                        isDense: true,
                                        items: _getTimeOptions()
                                            .map(
                                              (time) => DropdownMenuItem(
                                                value: time,
                                                child: Text(time),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) => setState(
                                          () => _selectedToTime = value!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _addTimeSlot,
                                    child: const Text('Add Time Slot'),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedFromTime,
                                    decoration: const InputDecoration(
                                      labelText: 'From',
                                      border: OutlineInputBorder(),
                                    ),
                                    isExpanded: true,
                                    isDense: true,
                                    items: _getTimeOptions()
                                        .map(
                                          (time) => DropdownMenuItem(
                                            value: time,
                                            child: Text(time),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(
                                      () => _selectedFromTime = value!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedToTime,
                                    decoration: const InputDecoration(
                                      labelText: 'To',
                                      border: OutlineInputBorder(),
                                    ),
                                    isExpanded: true,
                                    isDense: true,
                                    items: _getTimeOptions()
                                        .map(
                                          (time) => DropdownMenuItem(
                                            value: time,
                                            child: Text(time),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(
                                      () => _selectedToTime = value!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _addTimeSlot,
                                  child: const Text('Add'),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    // --- Always show time slots for any day that has ranges, even if nothing is selected!
                    ..._allDays
                        .where(
                          (day) => (_timeRangesByDay[day]?.isNotEmpty ?? false),
                        )
                        .map((day) => _buildDayAvailability(day)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveAvailability,
                  child: const Text('Save Availability'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getTimeOptions() {
    final List<String> options = [];
    for (int h = 7; h <= 17; h++) {
      for (int m = 0; m < 60; m += 30) {
        final ampm = h >= 12 ? 'PM' : 'AM';
        final hour12 = ((h + 11) % 12) + 1;
        final time = '$hour12:${m.toString().padLeft(2, '0')} $ampm';

        // Skip 12:00 PM and 12:30 PM as per backend logic
        if (time != '12:00 PM' && time != '12:30 PM') {
          options.add(time);
        }
      }
    }
    return options;
  }

  void _addTimeSlot() {
    if (_selectedFromTime.isNotEmpty && _selectedToTime.isNotEmpty) {
      final range = TimeRange(from: _selectedFromTime, to: _selectedToTime);

      for (final day in _selectedDays) {
        setState(() {
          _timeRangesByDay[day] ??= [];
          _timeRangesByDay[day]!.add(range);
          _timeRangesByDay[day] = TimeRange.mergeRanges(_timeRangesByDay[day]!);
        });
      }
    }
  }

  Widget _buildDayAvailability(String day) {
    final ranges = _timeRangesByDay[day] ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF060E57),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ranges
                .map(
                  (range) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060E57),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${range.from} - ${range.to}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeTimeSlot(day, range),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _removeTimeSlot(String day, TimeRange range) {
    setState(() {
      _timeRangesByDay[day]?.removeWhere(
        (r) => r.from == range.from && r.to == range.to,
      );
      if (_timeRangesByDay[day]?.isEmpty == true) {
        _timeRangesByDay.remove(day);
      }
    });
  }

  Future<void> _saveAvailability() async {
    // Ensure days that still have ranges are included even if currently unchecked
    final Set<String> daysToSave = {..._selectedDays, ..._timeRangesByDay.keys};

    final success = await widget.viewModel.updateAvailability(
      selectedDays: daysToSave.toList(),
      timeRangesByDay: _timeRangesByDay,
    );

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.viewModel.availabilityError ??
                  'Failed to update availability',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
