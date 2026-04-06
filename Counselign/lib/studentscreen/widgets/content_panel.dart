import 'package:flutter/material.dart';
import '../state/student_dashboard_viewmodel.dart';

class StudentContentPanel extends StatelessWidget {
  final StudentDashboardViewModel viewModel;

  const StudentContentPanel({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(75),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F0FF), Color(0xFFD6E9FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14003366), // Fixed: 0.08 opacity in hex
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: const Color(0x1A191970), // Fixed: 0.1 opacity in hex
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 400,
              height: 600,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0x14191970), // Fixed: 0.08 opacity in hex
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 600,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0x0F191970), // Fixed: 0.06 opacity in hex
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),

          // Royal blue diagonal accent
          Positioned(
            top: 0,
            right: 0,
            child: Transform(
              transform:
                  Matrix4.rotationZ(0.785) // 45 degrees
                    ..setEntry(3, 0, 50.0) // Fixed: X translation
                    ..setEntry(3, 1, -100.0), // Fixed: Y translation
              child: Container(
                width: 150,
                height: 150,
                color: const Color(0x1A060E57), // Fixed: 0.1 opacity in hex
              ),
            ),
          ),

          // Royal blue dots pattern - replaced with solid color
          Positioned(
            top: 50,
            left: 50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0x0D060E57), // Fixed: 0.05 opacity in hex
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Container(
                  margin: const EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to Your Safe Space',
                        style: TextStyle(
                          color: const Color(0xFF191970), // Midnight Blue
                          fontSize: 35,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: const Color(
                                0x26191970,
                              ), // Fixed: 0.15 opacity in hex
                              blurRadius: 2,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Underline accent
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        width: 320,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF060E57), Color(0xFF1e3799)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0x33060E57,
                              ), // Fixed: 0.2 opacity in hex
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quote
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 25,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCCFFFFFF), // Fixed: 0.8 opacity in hex
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0x1A191970,
                        ), // Fixed: 0.1 opacity in hex
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(
                        0x26191970,
                      ), // Fixed: 0.15 opacity in hex
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Quote marks
                      Positioned(
                        left: -10,
                        top: -10,
                        child: Text(
                          '"',
                          style: TextStyle(
                            fontSize: 60,
                            color: const Color(
                              0x26060E57,
                            ), // Fixed: 0.15 opacity in hex
                            fontFamily: 'Georgia, serif',
                            height: 1,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -30,
                        child: Text(
                          '"',
                          style: TextStyle(
                            fontSize: 60,
                            color: const Color(
                              0x26060E57,
                            ), // Fixed: 0.15 opacity in hex
                            fontFamily: 'Georgia, serif',
                            height: 1,
                          ),
                        ),
                      ),

                      // Quote text
                      Text(
                        'At our University Guidance Counseling, we understand that opening up can be challenging. However, we want to assure you that you are not alone. We are here to listen and support you without judgment.',
                        style: TextStyle(
                          color: const Color(0xFF003366),
                          fontSize: 17,
                          height: 1.8,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Wave decoration at bottom - replaced with gradient
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0x1A060E57), // Fixed: 0.1 opacity in hex
                        const Color(0x0D060E57), // Fixed: 0.05 opacity in hex
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ],
            ),
          ),

          // Royal blue top border accent
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF060E57),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
