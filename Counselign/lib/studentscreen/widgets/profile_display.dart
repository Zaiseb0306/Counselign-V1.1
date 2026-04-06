import 'package:flutter/material.dart';
import '../state/student_dashboard_viewmodel.dart';

class StudentProfileDisplay extends StatelessWidget {
  final StudentDashboardViewModel viewModel;
  final VoidCallback onChatToggle;
  final VoidCallback onNotificationsToggle;

  const StudentProfileDisplay({
    super.key,
    required this.viewModel,
    required this.onChatToggle,
    required this.onNotificationsToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF003366).withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 1),
              image: DecorationImage(
                image: AssetImage(viewModel.userProfile?.profileImageUrl ?? 'Photos/profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 15),

          // Profile info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hello! ${viewModel.userProfile?.displayName ?? 'User'}',
                  style: const TextStyle(
                    color: Color(0xFF003366),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last login: ${viewModel.userProfile?.lastLogin ?? 'Never'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              // Chat button
              _buildActionButton(
                icon: Icons.message,
                onPressed: onChatToggle,
                tooltip: 'Message a Counselor',
                badge: null,
              ),

              const SizedBox(width: 20),

              // Notifications button
              Stack(
                children: [
                  _buildActionButton(
                    icon: Icons.notifications,
                    onPressed: onNotificationsToggle,
                    tooltip: 'Notifications',
                    badge: viewModel.unreadNotificationCount > 0
                        ? viewModel.unreadNotificationCount.toString()
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    String? badge,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF003366).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: const Color(0xFF003366)),
            onPressed: onPressed,
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            iconSize: 24,
          ),
          if (badge != null && badge != '0')
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}