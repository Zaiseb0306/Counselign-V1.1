import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../api/config.dart';
import '../../utils/session.dart';
import '../../routes.dart';
import 'navigation_drawer.dart';

class CounselorScreenWrapper extends StatefulWidget {
  final Widget child;
  final int currentBottomNavIndex;
  final ValueChanged<int>? onBottomNavTap;
  final VoidCallback? onLogout;

  const CounselorScreenWrapper({
    super.key,
    required this.child,
    this.currentBottomNavIndex = 0,
    this.onBottomNavTap,
    this.onLogout,
  });

  @override
  State<CounselorScreenWrapper> createState() => _CounselorScreenWrapperState();
}

class _CounselorScreenWrapperState extends State<CounselorScreenWrapper> {
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
    debugPrint('🚪 Counselor wrapper: logout started');
    try {
      debugPrint('🚪 Counselor wrapper: calling logout endpoint...');
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/auth/logout',
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('🚪 Counselor wrapper: logout response status: ${response.statusCode}');
    } catch (e) {
      debugPrint('🚪 Counselor wrapper: error calling logout endpoint: $e');
    }

    // Clear session cookies
    debugPrint('🚪 Counselor wrapper: clearing session cookies');
    _session.clearCookies();

    // Wait a brief moment to ensure drawer close animation completes
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate back to landing and clear the stack so no back arrow appears
    debugPrint('🚪 Counselor wrapper: navigating to landing page');
    AppRoutes.navigateToLandingRoot();
    debugPrint('🚪 Counselor wrapper: navigation called');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppHeader(onMenu: _toggleDrawer),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: widget.child,
          ),
          bottomNavigationBar: ModernBottomNavigationBar(
            currentIndex: widget.currentBottomNavIndex,
            onTap:
                widget.onBottomNavTap ??
                (int index) {
                  // Default navigation logic for counselors
                  switch (index) {
                    case 0: // Home - Dashboard
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/counselor/dashboard');
                      break;
                    case 1: // Scheduled Appointments
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(
                        '/counselor/appointments/scheduled',
                      );
                      break;
                    case 2: // Follow-up Sessions
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/counselor/follow-up');
                      break;
                  }
                },
            isStudent: false,
          ),
        ),
        if (_isDrawerOpen)
          GestureDetector(
            onTap: _closeDrawer,
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        CounselorNavigationDrawer(
          isOpen: _isDrawerOpen,
          onClose: _closeDrawer,
          onNavigateToAnnouncements: () {
            _closeDrawer();
            Navigator.of(context).pushReplacementNamed(
              '/counselor/announcements',
            );
          },
          onNavigateToProfile: () {
            _closeDrawer();
            Navigator.of(context).pushReplacementNamed('/counselor/profile');
          },
          onLogout: () async {
            debugPrint('🚪 Counselor drawer: logout clicked');
            _closeDrawer();
            if (widget.onLogout != null) {
              widget.onLogout!();
            } else {
              await _handleLogout();
            }
          },
        ),
      ],
    );
  }
}
