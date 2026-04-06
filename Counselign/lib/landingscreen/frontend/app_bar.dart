import 'package:flutter/material.dart';
import 'package:counselign/widgets/app_header.dart';

PreferredSizeWidget buildAppBar({
  required BuildContext context,
  required VoidCallback onServicesPressed,
  required VoidCallback onContactPressed,
  required VoidCallback onLoginPressed,
  required VoidCallback onSignupPressed,
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  return AppBar(
    toolbarHeight: kAppBarHeight,
    backgroundColor: const Color(0xFF060E57),
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    titleSpacing: screenWidth < 600 ? 8 : 20, // tighter spacing on phones
    title: Row(
      children: [
        Image.asset(
          'Photos/counselign_logo.png',
          height: screenWidth < 600 ? 30 : 40, // scale logo for small phones
          width: screenWidth < 600 ? 30 : 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text(
          'Counselign',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth < 600 ? 16 : 18, // adjust font size
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
    actions: [
      // Desktop / Tablet navigation
      if (screenWidth > 991) ...[
        _buildNavButton(Icons.handshake, 'Services', onServicesPressed),
        _buildNavButton(Icons.email, 'Contact', onContactPressed),
        _buildNavButton(Icons.login, 'Login', onLoginPressed),
        _buildNavButton(Icons.person_add, 'Signup', onSignupPressed),
      ] else ...[
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            iconSize: screenWidth < 400 ? 22 : 28, // scale menu button
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    ],
  );
}

Widget _buildNavButton(IconData icon, String text, VoidCallback onPressed) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14, // consistent readable size on FHD phones
          ),
        ),
      ],
    ),
  );
}
