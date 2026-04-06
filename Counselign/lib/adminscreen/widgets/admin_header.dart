import 'package:flutter/material.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: const Color(0xFF060E57),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      titleSpacing: screenWidth < 600 ? 8 : 20,
      title: Row(
        children: [
          Image.asset(
            'Photos/counselign_logo.png',
            height: screenWidth < 600 ? 30 : 40,
            width: screenWidth < 600 ? 30 : 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: screenWidth < 600 ? 30 : 40,
                height: screenWidth < 600 ? 30 : 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: const Color(0xFF060E57),
                  size: screenWidth < 600 ? 15 : 20,
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            'Counselign',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth < 600 ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _logout(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              const SizedBox(width: 6),
              Text(
                'Log Out',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _logout(BuildContext context) {
    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed('/');
  }
}
