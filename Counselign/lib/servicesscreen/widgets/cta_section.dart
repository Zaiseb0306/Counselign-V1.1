import 'package:flutter/material.dart';

class CTASection extends StatelessWidget {
  final VoidCallback onGetStartedTap;

  const CTASection({super.key, required this.onGetStartedTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth >= 1024;

    final double padding = screenWidth * 0.04; // 4% of screen width
    final double headingFont = screenHeight * 0.028; // ~30px on 1080p
    final double textFont = screenHeight * 0.018; // ~18px
    final double buttonFont = screenHeight * 0.018; // ~18px
    final double buttonPaddingH = screenWidth * 0.08; // horizontal padding
    final double buttonPaddingV = screenHeight * 0.02; // vertical padding
    final double spacing = screenHeight * 0.02; // ~40px equivalent spacing

    return Container(
      padding: EdgeInsets.all(
        isDesktop ? 0 : padding,
      ), // No padding on desktop, normal padding on mobile
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF060E57), Color(0xFF1A237E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isDesktop ? padding : 0,
        ), // Add padding on desktop, none on mobile
        child: Column(
          children: [
            Text(
              'Ready to Get Started?',
              style: TextStyle(
                fontSize: headingFont,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              'Our services are confidential and available to all university students.',
              style: TextStyle(
                color: Colors.white,
                fontSize: textFont,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing * 1.5),
            GestureDetector(
              onTap: onGetStartedTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: buttonPaddingH,
                  vertical: buttonPaddingV,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha(51), // Fixed: 0.2 opacity
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: buttonFont,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF060E57),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
