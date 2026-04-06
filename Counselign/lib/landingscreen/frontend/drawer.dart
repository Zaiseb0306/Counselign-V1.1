import 'package:flutter/material.dart';

Widget buildDrawer({
  required BuildContext context,
  required VoidCallback onServicesPressed,
  required VoidCallback onContactPressed,
  required VoidCallback onLoginPressed,
  required VoidCallback onSignupPressed,
}) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  final isDesktop = screenWidth > 991;

  return Drawer(
    backgroundColor: const Color(0xFF060E57),
    width: isDesktop ? screenWidth * 0.35 : screenWidth * 0.75,
    child: TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF060E57),
                    Color(0xFF1A237E),
                    Color(0xFF3F51B5),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
              child: Column(
                children: [
                  _buildModernHeader(
                    context,
                    screenHeight,
                    screenWidth,
                    isTablet,
                  ),
                  Expanded(
                    child: _buildNavigationContent(
                      context,
                      onServicesPressed,
                      onContactPressed,
                      onLoginPressed,
                      onSignupPressed,
                      screenHeight,
                      isTablet,
                    ),
                  ),
                  _buildFooter(context, screenHeight, isTablet),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildModernHeader(
  BuildContext context,
  double screenHeight,
  double screenWidth,
  bool isTablet,
) {
  return Container(
    padding: EdgeInsets.fromLTRB(
      isTablet ? 24 : 20,
      MediaQuery.of(context).padding.top + (isTablet ? 20 : 16),
      isTablet ? 24 : 20,
      isTablet ? 24 : 20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Image.asset(
                      'Photos/counselign_logo.png',
                      height: isTablet ? 32 : 28,
                      width: isTablet ? 32 : 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Counselign',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Counseling Services',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildNavigationContent(
  BuildContext context,
  VoidCallback onServicesPressed,
  VoidCallback onContactPressed,
  VoidCallback onLoginPressed,
  VoidCallback onSignupPressed,
  double screenHeight,
  bool isTablet,
) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
    child: Column(
      children: [
        const SizedBox(height: 8),
        _buildAnimatedDrawerItem(
          context: context,
          icon: Icons.handshake_rounded,
          title: 'Services',
          subtitle: 'Explore our counseling services',
          onTap: onServicesPressed,
          isTablet: isTablet,
          delay: 0,
        ),
        const SizedBox(height: 8),
        _buildAnimatedDrawerItem(
          context: context,
          icon: Icons.email_rounded,
          title: 'Contact',
          subtitle: 'Get in touch with us',
          onTap: onContactPressed,
          isTablet: isTablet,
          delay: 100,
        ),
        const SizedBox(height: 8),
        _buildAnimatedDrawerItem(
          context: context,
          icon: Icons.login_rounded,
          title: 'Login',
          subtitle: 'Access your account',
          onTap: onLoginPressed,
          isTablet: isTablet,
          delay: 200,
        ),
        const SizedBox(height: 8),
        _buildAnimatedDrawerItem(
          context: context,
          icon: Icons.person_add_rounded,
          title: 'Sign Up',
          subtitle: 'Create a new account',
          onTap: onSignupPressed,
          isTablet: isTablet,
          delay: 300,
        ),
      ],
    ),
  );
}

Widget _buildAnimatedDrawerItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  required bool isTablet,
  required int delay,
}) {
  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 400 + delay),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(30 * (1 - value), 0),
        child: Opacity(
          opacity: value,
          child: _buildModernDrawerItem(
            context: context,
            icon: icon,
            title: title,
            subtitle: subtitle,
            onTap: onTap,
            isTablet: isTablet,
          ),
        ),
      );
    },
  );
}

Widget _buildModernDrawerItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  required bool isTablet,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 16 : 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isTablet ? 22 : 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: isTablet ? 16 : 14,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildFooter(BuildContext context, double screenHeight, bool isTablet) {
  return Container(
    padding: EdgeInsets.all(isTablet ? 24 : 20),
    child: Column(
      children: [
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: isTablet ? 18 : 16,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Your mental health matters',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
