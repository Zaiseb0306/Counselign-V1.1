import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'state/student_dashboard_viewmodel.dart';
import 'widgets/navigation_drawer.dart';
import '../widgets/app_header.dart';
import 'widgets/notifications_dropdown.dart';
import 'widgets/chat_popup.dart';
import 'widgets/counselor_selection_dialog.dart';
import 'widgets/event_carousel.dart';
import 'widgets/quotes_carousel.dart';
import 'widgets/resources_accordion.dart';
import '../api/config.dart';
import 'utils/image_url_helper.dart';
import 'models/counselor.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = StudentDashboardViewModel();
        viewModel.initialize();
        return viewModel;
      },
      child: const _StudentDashboardContent(),
    );
  }
}

class _StudentDashboardContent extends StatefulWidget {
  const _StudentDashboardContent();

  @override
  State<_StudentDashboardContent> createState() =>
      _StudentDashboardContentState();
}

class _StudentDashboardContentState extends State<_StudentDashboardContent> {
  bool _showPdsReminder = false;
  int _timer = 20;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Show immediately for testing
    _checkPdsReminder();
  }

  Future<void> _checkPdsReminder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool? hasShownReminder = prefs.getBool('pdsReminderShown');

      debugPrint('PDS Reminder check: hasShownReminder = $hasShownReminder');

      // Only show reminder if not shown before
      if (hasShownReminder != true) {
        debugPrint('PDS Reminder: Showing modal');
        setState(() => _showPdsReminder = true);
        _startCountdown();
      } else {
        debugPrint('PDS Reminder: Already shown, not displaying');
      }
    } catch (e) {
      debugPrint('Error checking PDS reminder: $e');
    }
  }

  void _startCountdown() {
    _timer = 20;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timer--;
        if (_timer <= 0) {
          _closePdsReminder();
        }
      });
    });
  }

  Future<void> _closePdsReminder() async {
    debugPrint('PDS Reminder: Closing modal');
    _countdownTimer?.cancel();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pdsReminderShown', true);
      debugPrint('PDS Reminder: Preference saved');
    } catch (e) {
      debugPrint('Error saving PDS reminder preference: $e');
    }
    setState(() => _showPdsReminder = false);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentDashboardViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF0F4F8),
              appBar: AppHeader(onMenu: viewModel.toggleDrawer),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: _buildMainContent(context, viewModel),
                  ),
                  if (viewModel.showNotifications)
                    StudentNotificationsDropdown(viewModel: viewModel),
                  // Modals replaced by dedicated screens; keep imports for backward compatibility
                  // PDS Reminder Modal
                  if (_showPdsReminder)
                    Positioned(
                      top: 20,
                      left: 20,
                      child: _buildPdsReminderModal(context, viewModel),
                    ),
                ],
              ),
              bottomNavigationBar: ModernBottomNavigationBar(
                currentIndex: 0, // Home is selected by default
                onTap: (index) {
                  // Handle navigation based on index
                  switch (index) {
                    case 0: // Home - already on dashboard
                      break;
                    case 1: // Schedule Appointment
                      viewModel.navigateToScheduleAppointment(context);
                      break;
                    case 2: // My Appointments
                      viewModel.navigateToMyAppointments(context);
                      break;
                    case 3: // Follow-up Sessions
                      viewModel.navigateToFollowUpSessions(context);
                      break;
                  }
                },
                isStudent: true,
              ),
            ),
            if (viewModel.isDrawerOpen)
              GestureDetector(
                onTap: viewModel.closeDrawer,
                child: Container(
                  color: Colors.black.withAlpha(128),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            StudentNavigationDrawer(
              isOpen: viewModel.isDrawerOpen,
              onClose: viewModel.closeDrawer,
              onNavigateToAnnouncements: () =>
                  viewModel.navigateToAnnouncements(context),
              onNavigateToScheduleAppointment: () =>
                  viewModel.navigateToScheduleAppointment(context),
              onNavigateToMyAppointments: () =>
                  viewModel.navigateToMyAppointments(context),
              onNavigateToProfile: () => viewModel.navigateToProfile(context),
              onLogout: () => viewModel.logout(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPdsReminderModal(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    final progress = _timer / 20.0;

    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(6, 14, 87, 0.15), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  colors: [Color(0xFF060E57), Color(0xFF0A1875)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'PDS Reminder',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _closePdsReminder,
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF060E57), Color(0xFF0A1875)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(6, 14, 87, 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Update Your PDS!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF060E57),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Keep your Personal Data Sheet updated for timely counseling services.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748b),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Timer
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFe4e6eb)),
                    ),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFe4e6eb),
                          color: const Color(0xFF0A1875),
                          minHeight: 4,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Auto-close in $_timer s',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748b),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _closePdsReminder();
                      viewModel.navigateToProfile(context);
                    },
                    icon: const Icon(Icons.edit, size: 16),

                    label: const Text(
                      'Update Now',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      backgroundColor: const Color(0xFF060E57),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _closePdsReminder,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text(
                      'Dismiss',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // header now provided via Scaffold.appBar using AppHeader

  // ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 20 : 24,
      ),
      child: Column(
        children: [
          _buildProfileDisplay(context, viewModel, isMobile),
          const EventCarousel(),
          SizedBox(height: isMobile ? 20 : 24),
          _buildContentPanel(context, isMobile),
          const ResourcesAccordion(),
        ],
      ),
    );
  }

  // ---------------- PROFILE DISPLAY ----------------
  Widget _buildProfileDisplay(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 10 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              // Profile Avatar
              GestureDetector(
                //onTap: () => viewModel.navigateToProfile(context),
                child: Container(
                  width: isMobile ? 60 : 70,
                  height: isMobile ? 60 : 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image(
                      image: _getProfileImageProvider(viewModel),
                      width: isMobile ? 60 : 70,
                      height: isMobile ? 60 : 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'Photos/profile.png',
                          width: isMobile ? 60 : 70,
                          height: isMobile ? 60 : 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: isMobile ? 60 : 70,
                              height: isMobile ? 60 : 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: isMobile ? 30 : 35,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              // Profile Info
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi! ${viewModel.displayName}',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF003366),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (viewModel.hasName)
                      Text(
                        viewModel.userId,
                        style: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 0,
                          height: 0,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      'Last login: ${viewModel.formattedLastLogin}',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              // Action buttons inline
              _buildMessageButton(context, viewModel, isMobile),
              SizedBox(width: isMobile ? 8 : 12),
              _buildNotificationButton(viewModel, isMobile),
            ],
          ),
          // Selected counselor indicator
          if (viewModel.selectedCounselor != null) ...[
            SizedBox(height: isMobile ? 16 : 20),
            _buildSelectedCounselorIndicator(viewModel, isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageButton(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    bool isMobile,
  ) {
    final hasUnreadMessages = viewModel.totalUnreadMessagesCount > 0;

    return SizedBox(
      width: isMobile ? 44 : 50,
      height: isMobile ? 44 : 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: viewModel.selectedCounselor != null
              ? () => Navigator.of(context).pushNamed(
                  '/student/conversation',
                  arguments: viewModel.selectedCounselor,
                )
              : () => Navigator.of(
                  context,
                ).pushNamed('/student/counselor-selection'),
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.message_rounded,
                color: const Color(0xFF060E57),
                size: isMobile ? 28 : 32,
              ),
              if (hasUnreadMessages)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      minWidth: isMobile ? 18 : 20,
                      minHeight: isMobile ? 18 : 20,
                    ),
                    child: Center(
                      child: Text(
                        viewModel.totalUnreadMessagesCount > 9
                            ? '9+'
                            : viewModel.totalUnreadMessagesCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 9 : 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(
    StudentDashboardViewModel viewModel,
    bool isMobile,
  ) {
    return SizedBox(
      width: isMobile ? 44 : 50,
      height: isMobile ? 44 : 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: viewModel.toggleNotifications,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_rounded,
                color: viewModel.showNotifications
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF060E57),
                size: isMobile ? 28 : 32,
              ),
              if (viewModel.unreadNotificationCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      minWidth: isMobile ? 18 : 20,
                      minHeight: isMobile ? 18 : 20,
                    ),
                    child: Center(
                      child: Text(
                        viewModel.unreadNotificationCount > 9
                            ? '9+'
                            : viewModel.unreadNotificationCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 9 : 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentPanel(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
            ),
            borderRadius: BorderRadius.circular(isMobile ? 24 : 28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF060E57).withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF060E57).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF060E57).withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(isMobile ? 32 : 40),
          child: Column(
            children: [
              // Decorative accent
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: isMobile ? 24 : 32),

              // Main title
              Text(
                'Welcome to Your Safe Space',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: const Color(0xFF060E57),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isMobile ? 20 : 24),

              // Static message
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF060E57).withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF060E57).withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Quote icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF060E57).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.format_quote,
                        color: Color(0xFF060E57),
                        size: 20,
                      ),
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    Text(
                      'At our University Guidance Counseling, we understand that opening up can be challenging. However, we want to assure you that you are not alone. We are here to listen and support you without judgment.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF1E293B),
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                        letterSpacing: 0.2,
                        fontSize: isMobile ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),
        // Quotes carousel
        const QuotesCarousel(),
      ],
    );
  }

  // Helper method to get the appropriate image provider
  ImageProvider _getProfileImageProvider(StudentDashboardViewModel viewModel) {
    if (viewModel.userProfile?.profileImageUrl == null ||
        viewModel.userProfile!.profileImageUrl.isEmpty) {
      return const AssetImage('Photos/profile.png');
    }

    final imageUrl = ImageUrlHelper.getProfileImageUrl(
      viewModel.userProfile!.profileImageUrl,
    );

    // If it's the default profile image, use asset
    if (imageUrl == 'Photos/profile.png') {
      return const AssetImage('Photos/profile.png');
    }

    // Otherwise, use network image
    return NetworkImage(imageUrl);
  }

  // Selected counselor indicator
  Widget _buildSelectedCounselorIndicator(
    StudentDashboardViewModel viewModel,
    bool isMobile,
  ) {
    final counselor = viewModel.selectedCounselor!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Counselor profile picture
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3B82F6), width: 2),
            ),
            child: ClipOval(child: _buildCounselorImage(counselor)),
          ),

          SizedBox(width: isMobile ? 8 : 12),

          // Counselor info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selected Counselor',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                counselor.displayName,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(width: isMobile ? 8 : 12),

          // Change counselor button
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed('/student/counselor-selection'),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build counselor image
  Widget _buildCounselorImage(Counselor counselor) {
    final imageUrl = ImageUrlHelper.getProfileImageUrl(
      counselor.profileImageUrl,
    );

    // If it's the default profile image, use asset
    if (imageUrl == 'Photos/profile.png') {
      return Image.asset(
        'Photos/profile.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Color(0xFF64748B), size: 20);
        },
      );
    }

    // Otherwise, use network image
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, color: Color(0xFF64748B), size: 20);
      },
    );
  }

  // Footer provided via shared AppFooter as bottomNavigationBar for consistency across pages
}
