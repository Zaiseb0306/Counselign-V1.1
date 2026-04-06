import 'package:flutter/material.dart';

class CounselorNavigationDrawer extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final VoidCallback onNavigateToAnnouncements;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onLogout;

  const CounselorNavigationDrawer({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onNavigateToAnnouncements,
    required this.onNavigateToProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = MediaQuery.of(context).size.height;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      right: isOpen ? 0 : -320,
      width: 320,
      child: Container(
        height: totalHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF060E57),
              Color(0xFF0A1875),
              Color(0xFF1E3A8A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF060E57).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(-4, 0),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF060E57).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(-2, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with modern styling
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Counselign',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Counselor Menu',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildMenuItem(
                    icon: Icons.campaign_rounded,
                    title: 'Announcements',
                    onTap: () {
                      onClose();
                      onNavigateToAnnouncements();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    onTap: () {
                      onClose();
                      onNavigateToProfile();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Divider with modern styling
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Logout anchored at the bottom near navigation footer
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  onTap: () {
                    onClose();
                    onLogout();
                  },
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final Color effectiveIconColor = color ?? Colors.white;
    final Color effectiveBackgroundColor = color != null
        ? color.withValues(alpha: 0.2)
        : Colors.white.withValues(alpha: 0.1);
    final Color effectiveTrailingColor =
        color ?? Colors.white.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: effectiveBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: effectiveIconColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: effectiveTrailingColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
