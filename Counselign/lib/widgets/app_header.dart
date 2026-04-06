import 'package:flutter/material.dart';

/* 
===========================================
EDIT THIS VALUE TO CHANGE APPBAR HEIGHT GLOBALLY
===========================================
*/
const double kAppBarHeight = 40; // ← EDIT THIS NUMBER

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenu;
  final double? height;

  const AppHeader({
    super.key,
    required this.onMenu,
    this.height,
  });

  @override
  Size get preferredSize => Size.fromHeight(height ?? kAppBarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final appBarHeight = height ?? kAppBarHeight;

    return AppBar(
      backgroundColor: const Color(0xFF060E57),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      automaticallyImplyLeading: false,
      titleSpacing: isMobile ? 8 : 20,
      toolbarHeight: appBarHeight,
      title: Row(
        children: [
          Image.asset(
            'Photos/counselign_logo.png',
            height: isMobile ? 30 : 40,
            width: isMobile ? 30 : 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Text(
            'Counselign',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          iconSize: screenWidth < 400 ? 22 : 28,
          onPressed: onMenu,
          tooltip: 'Menu',
        ),
      ],
    );
  }
}

/* 
===========================================
USAGE EXAMPLE
===========================================
*/

// In your Scaffold - just use it without specifying height:


// The height is controlled by kAppBarHeight at the top of this file!
// All AppHeader instances will use the same height automatically.