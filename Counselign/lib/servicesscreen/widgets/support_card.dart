import 'package:flutter/material.dart';

class SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Animation<double> animation;
  final int animationIndex;

  const SupportCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.animation,
    this.animationIndex = 3,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizes
    final double padding = screenWidth * 0.03; // ~25px on 1080 width
    final double iconSize = screenHeight * 0.017; // ~32px
    final double titleSize = screenHeight * 0.022; // ~18px
    final double descSize = screenHeight * 0.018; // ~14px
    final double spacing = screenHeight * 0.015; // ~15px

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 0.8 + (0.2 * animation.value),
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: const Color(0xFF060E57),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF003366),
                      ),
                    ),
                    SizedBox(height: spacing * 0.7),
                    Text(
                      description,
                      style: TextStyle(
                        color: const Color(0xFF4A5568),
                        fontSize: descSize,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
