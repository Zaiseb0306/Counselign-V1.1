import 'package:flutter/material.dart';

class StudentDashboardFooter extends StatelessWidget {
  const StudentDashboardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: const Color(0xFF060E57),
      child: const Column(
        children: [
          Text(
            '© 2025 Counselign Team. All rights reserved.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
