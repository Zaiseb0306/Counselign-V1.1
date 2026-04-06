import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../../routes.dart';
import 'navigation_drawer.dart';

class StudentScreenWrapper extends StatefulWidget {
  final Widget child;
  final int currentBottomNavIndex;
  final ValueChanged<int>? onBottomNavTap;

  const StudentScreenWrapper({
    super.key,
    required this.child,
    this.currentBottomNavIndex = 0,
    this.onBottomNavTap,
  });

  @override
  State<StudentScreenWrapper> createState() => _StudentScreenWrapperState();
}

class _StudentScreenWrapperState extends State<StudentScreenWrapper> {
  bool _isDrawerOpen = false;
  final Session _session = Session();

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _closeDrawer() {
    setState(() {
      _isDrawerOpen = false;
    });
  }

  Future<void> _handleLogout() async {
    debugPrint('🚪 Student wrapper: logout started');
    try {
      // Call logout endpoint to update activity fields in database
      debugPrint('🚪 Student wrapper: calling logout endpoint...');
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/auth/logout',
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('🚪 Student wrapper: logout response status: ${response.statusCode}');
    } catch (e) {
      debugPrint('🚪 Student wrapper: error calling logout endpoint: $e');
      // Continue with logout even if endpoint call fails
    }

    // Clear session cookies
    debugPrint('🚪 Student wrapper: clearing session cookies');
    _session.clearCookies();

    // Wait a brief moment to ensure drawer close animation completes
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate back to landing and clear the stack so no back arrow appears
    debugPrint('🚪 Student wrapper: navigating to landing page');
    AppRoutes.navigateToLandingRoot();
    debugPrint('🚪 Student wrapper: navigation called');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppHeader(onMenu: _toggleDrawer),
          body: widget.child,
          bottomNavigationBar: ModernBottomNavigationBar(
            currentIndex: widget.currentBottomNavIndex,
            onTap: widget.onBottomNavTap ??
                (int index) {
              // Default navigation logic
              switch (index) {
                case 0: // Home
                  Navigator.of(context)
                      .pushReplacementNamed('/student/dashboard');
                  break;
                case 1: // Schedule
                  Navigator.of(context)
                      .pushReplacementNamed('/student/schedule-appointment');
                  break;
                case 2: // Appointments
                  Navigator.of(context)
                      .pushReplacementNamed('/student/my-appointments');
                  break;
                case 3: // Follow-up Sessions
                  Navigator.of(context)
                      .pushReplacementNamed('/student/follow-up-sessions');
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
          onNavigateToAnnouncements: () {
            _closeDrawer();
            Navigator.of(context).pushNamed('/student/announcements');
          },
          onNavigateToScheduleAppointment: () {
            _closeDrawer();
            Navigator.of(context).pushNamed('/student/schedule-appointment');
          },
          onNavigateToMyAppointments: () {
            _closeDrawer();
            Navigator.of(context).pushNamed('/student/my-appointments');
          },
          onNavigateToProfile: () {
            _closeDrawer();
            Navigator.of(context).pushNamed('/student/profile');
          },
          onLogout: () async {
            debugPrint('🚪 Student drawer: logout clicked');
            _closeDrawer();
            await _handleLogout();
          },
        ),
      ],
    );
  }
}
