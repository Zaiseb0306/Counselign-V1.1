import 'package:flutter/material.dart';

class ServicesFooter extends StatelessWidget {
  final List<Map<String, String>> teamMembers;
  final Function(BuildContext, String) onTeamMemberTap;

  const ServicesFooter({
    super.key,
    required this.teamMembers,
    required this.onTeamMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double verticalPadding = screenHeight * 0.03; // ~30px on 1080p
    final double fontSize = screenHeight * 0.018; // ~18px
    final double spacing = screenWidth * 0.02; // ~20px horizontal spacing
    final double runSpacing = screenHeight * 0.01; // ~10px vertical spacing

    return Container(
      color: const Color(0xFF060E57),
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Column(
        children: [
          Text(
            '© 2025 Counselign Team. All rights reserved.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
          SizedBox(height: verticalPadding * 0.5),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: runSpacing,
            children: teamMembers.map((member) {
              return InkWell(
                onTap: () => onTeamMemberTap(context, member['name']!),
                child: Text(
                  member['name']!,
                  style: TextStyle(
                    color: const Color(0xFFF2F5F8),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
