import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> features;
  final Animation<double> animation;
  final int animationIndex;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    required this.animation,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizes
    final double padding = screenWidth * 0.035; // ~30px on 1080 width
    final double iconSize = screenHeight * 0.022; // ~40px
    final double titleSize = screenHeight * 0.03; // ~24px
    final double descSize = screenHeight * 0.018; // ~16px
    final double featureSize = screenHeight * 0.016; // ~14px
    final double spacing = screenHeight * 0.02; // ~20px

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
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8FAFF)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF003366).withAlpha((0.08 * 255).round()),
                    width: 1,
                  ),
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
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF003366),
                      ),
                    ),
                    SizedBox(height: spacing * 0.75),
                    Text(
                      description,
                      style: TextStyle(
                        color: const Color(0xFF4A5568),
                        fontSize: descSize,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: spacing),
                    ...features.map(
                      (feature) => Padding(
                        padding: EdgeInsets.only(bottom: spacing * 0.5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: const Color(0xFF22C55E),
                              size: featureSize + 4,
                            ),
                            SizedBox(width: spacing * 0.5),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  color: const Color(0xFF4A5568),
                                  fontSize: featureSize,
                                ),
                              ),
                            ),
                          ],
                        ),
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
