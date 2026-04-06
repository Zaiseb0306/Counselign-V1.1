import 'package:flutter/material.dart';

class AdminFooter extends StatelessWidget {
  const AdminFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF060E57),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: const Text(
        '© 2025 Counselign Team. All rights reserved.',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
