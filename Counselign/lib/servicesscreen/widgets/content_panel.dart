import 'package:flutter/material.dart';
import 'service_card.dart';
import 'support_card.dart';
import 'cta_section.dart';

class ContentPanel extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> supportPrograms;
  final List<Animation<double>> cardAnimations;
  final VoidCallback onGetStartedTap;

  const ContentPanel({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.services,
    required this.supportPrograms,
    required this.cardAnimations,
    required this.onGetStartedTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    double basePadding = screenWidth * 0.04; // responsive padding
    double headingFontSize = screenHeight * 0.035; // 28-30px for 1080p
    double subHeadingFontSize = screenHeight * 0.02; // 16-18px

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: isDesktop
            ? Column(
                children: [
                  // Main content container
                  Container(
                    padding: EdgeInsets.all(basePadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).round()),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(
                          0xFF003366,
                        ).withAlpha((0.08 * 255).round()),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Services',
                          style: TextStyle(
                            fontSize: headingFontSize,
                            color: const Color(0xFF003366),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: basePadding),
                        Text(
                          'The University Guidance Counseling Center offers comprehensive support services designed to enhance your academic success, personal growth, and career development. Our professional counselors are here to help you navigate your university journey.',
                          style: TextStyle(
                            color: const Color(0xFF4A5568),
                            fontSize: subHeadingFontSize,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: basePadding * 0.5), // Reduced spacing
                        _buildServiceGrid(screenWidth),
                        SizedBox(height: basePadding * 0.5), // Reduced spacing
                        _buildSupportProgramsSection(screenWidth),
                      ],
                    ),
                  ),
                  SizedBox(height: basePadding * 0.5), // Reduced spacing
                  // CTA section that stretches to full width on desktop
                  SizedBox(
                    width: double.infinity, // Full width on desktop
                    child: CTASection(onGetStartedTap: onGetStartedTap),
                  ),
                ],
              )
            : Container(
                padding: EdgeInsets.all(basePadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.05 * 255).round()),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(
                      0xFF003366,
                    ).withAlpha((0.08 * 255).round()),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Services',
                      style: TextStyle(
                        fontSize: headingFontSize,
                        color: const Color(0xFF003366),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: basePadding),
                    Text(
                      'The University Guidance Counseling Center offers comprehensive support services designed to enhance your academic success, personal growth, and career development. Our professional counselors are here to help you navigate your university journey.',
                      style: TextStyle(
                        color: const Color(0xFF4A5568),
                        fontSize: subHeadingFontSize,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: basePadding * 1.5),
                    _buildServiceGrid(screenWidth),
                    SizedBox(height: basePadding * 2),
                    _buildSupportProgramsSection(screenWidth),
                    SizedBox(height: basePadding * 2),
                    CTASection(onGetStartedTap: onGetStartedTap),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildServiceGrid(double screenWidth) {
    bool isWide = screenWidth > 900;
    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: services.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ServiceCard(
                    icon: service['icon'],
                    title: service['title'],
                    description: service['description'],
                    features: service['features'],
                    animation: cardAnimations[index],
                    animationIndex: index,
                  ),
                ),
              );
            }).toList(),
          )
        : Column(
            children: services.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ServiceCard(
                  icon: service['icon'],
                  title: service['title'],
                  description: service['description'],
                  features: service['features'],
                  animation: cardAnimations[index],
                  animationIndex: index,
                ),
              );
            }).toList(),
          );
  }

  Widget _buildSupportProgramsSection(double screenWidth) {
    bool isLarge = screenWidth > 1000;
    bool isMedium = screenWidth > 500 && screenWidth <= 1000;

    if (isLarge) {
      return Row(
        children: supportPrograms.asMap().entries.map((entry) {
          final index = entry.key + services.length;
          final program = entry.value;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SupportCard(
                icon: program['icon'],
                title: program['title'],
                description: program['description'],
                animation: cardAnimations[index],
                animationIndex: index,
              ),
            ),
          );
        }).toList(),
      );
    } else if (isMedium) {
      final programs = supportPrograms.asMap().entries.map((entry) {
        final index = entry.key + services.length;
        final program = entry.value;
        return SupportCard(
          icon: program['icon'],
          title: program['title'],
          description: program['description'],
          animation: cardAnimations[index],
          animationIndex: index,
        );
      }).toList();

      return Column(
        children: [
          Row(
            children: [
              Expanded(child: programs[0]),
              const SizedBox(width: 20),
              Expanded(child: programs[1]),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: programs[2]),
              const SizedBox(width: 20),
              Expanded(child: programs[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: supportPrograms.asMap().entries.map((entry) {
          final index = entry.key + services.length;
          final program = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SupportCard(
              icon: program['icon'],
              title: program['title'],
              description: program['description'],
              animation: cardAnimations[index],
              animationIndex: index,
            ),
          );
        }).toList(),
      );
    }
  }
}
