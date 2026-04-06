import 'package:flutter/material.dart';

class CounselorFooter extends StatelessWidget {
  const CounselorFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060E57),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: const Column(
        children: [
          Text(
            '© 2025 Counselign Team. All rights reserved.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}