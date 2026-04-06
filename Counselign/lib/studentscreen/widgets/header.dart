import 'package:flutter/material.dart';

class StudentDashboardHeader extends StatelessWidget {
  final VoidCallback onDrawerToggle;

  const StudentDashboardHeader({super.key, required this.onDrawerToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060E57),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo and title
          Row(
            children: [
              Image.asset(
                'Photos/counselign_logo.png',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Color(0xFF060E57),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Counselign',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Drawer toggle button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onDrawerToggle,
              tooltip: 'Menu',
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}
