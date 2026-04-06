import 'package:flutter/material.dart';

class ServicesHeader extends StatelessWidget implements PreferredSizeWidget {
  const ServicesHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: const Color(0xFF060E57),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      titleSpacing: screenWidth < 600 ? 8 : 20,
      automaticallyImplyLeading: false,
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
        // Back button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.arrow_back, size: 18),
              const SizedBox(width: 6),
              Text(
                'Back',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
