import 'package:flutter/material.dart';
import '../../utils/app_footer.dart';

Widget buildBody(BuildContext context) {
  final size = MediaQuery.of(context).size; // Get screen size
  final isMobile = size.width < 768;
  final isDesktop = size.width >= 1024;

  return SingleChildScrollView(
    child: isDesktop
        ? Column(
            children: [
              buildQuotePanel(context),
              buildServiceCards(context, isMobile),
              const AppFooter(),
            ],
          )
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1080,
              ), // prevent overflow on mobile
              child: Column(
                children: [
                  buildQuotePanel(context),
                  buildServiceCards(context, isMobile),
                  const AppFooter(),
                ],
              ),
            ),
          ),
  );
}

Widget buildQuotePanel(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isDesktop = size.width >= 1024;
  final isMobile = size.width < 600;

  return Container(
    margin: EdgeInsets.all(isDesktop ? 0 : 20),
    padding: EdgeInsets.all(
      isDesktop
          ? 80
          : isMobile
          ? 32
          : 48,
    ),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
      ),
      borderRadius: BorderRadius.circular(isDesktop ? 0 : 24),
      boxShadow: isDesktop
          ? []
          : [
              BoxShadow(
                color: const Color(0xFF060E57).withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF060E57).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
      border: Border.all(
        color: const Color(0xFF060E57).withValues(alpha: 0.06),
        width: 1,
      ),
    ),
    child: Column(
      children: [
        // Decorative accent
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),

        // Main title with enhanced typography
        Text(
          'Your Future Starts Here',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: const Color(0xFF060E57),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isMobile ? 20 : 24),

        // Quote with modern styling
        Container(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF060E57).withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF060E57).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Quote icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF060E57).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: Color(0xFF060E57),
                  size: 24,
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              Text(
                '"Your voice matters. Don\'t be afraid to open up; our counseling services are a safe space where your thoughts and feelings are kept confidential. Remember, seeking help is a sign of strength."',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF1E293B),
                  fontStyle: FontStyle.italic,
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: isMobile ? 24 : 32),

        // Call to action hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF060E57).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Scroll down to explore our services',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF060E57),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildServiceCards(BuildContext context, bool isMobile) {
  final size = MediaQuery.of(context).size;
  final isDesktop = size.width >= 1024;

  return Container(
    padding: EdgeInsets.all(
      isDesktop
          ? 60
          : isMobile
          ? 24
          : 40,
    ),
    child: Column(
      children: [
        // Section header with modern styling
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Text(
                'Why Choose Us?',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: const Color(0xFF060E57),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: isMobile ? 32 : 48),

        // Service cards with modern layout
        isMobile
            ? Column(
                children: [
                  _buildServiceCard(
                    context,
                    'Photos/MISC/high_five.png',
                    'Personalized Guidance',
                    'We provide tailored advice to match your unique strengths and aspirations.',
                  ),
                  const SizedBox(height: 24),
                  _buildServiceCard(
                    context,
                    'Photos/MISC/protection.png',
                    'Your Privacy Matters',
                    'We prioritize your confidentiality. Everything you share with us is kept safe and secure.',
                  ),
                  const SizedBox(height: 24),
                  _buildServiceCard(
                    context,
                    'Photos/MISC/mental_health.png',
                    'Experienced Counselors',
                    'Our team consists of seasoned professionals with a wealth of knowledge.',
                  ),
                ],
              )
            : isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'Photos/MISC/high_five.png',
                      'Personalized Guidance',
                      'We provide tailored advice to match your unique strengths and aspirations.',
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'Photos/MISC/protection.png',
                      'Your Privacy Matters',
                      'We prioritize your confidentiality. Everything you share with us is kept safe and secure.',
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'Photos/MISC/mental_health.png',
                      'Experienced Counselors',
                      'Our team consists of seasoned professionals with a wealth of knowledge.',
                    ),
                  ),
                ],
              )
            : Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: 320,
                    child: _buildServiceCard(
                      context,
                      'Photos/MISC/high_five.png',
                      'Personalized Guidance',
                      'We provide tailored advice to match your unique strengths and aspirations.',
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: _buildServiceCard(
                      context,
                      'Photos/MISC/protection.png',
                      'Your Privacy Matters',
                      'We prioritize your confidentiality. Everything you share with us is kept safe and secure.',
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: _buildServiceCard(
                      context,
                      'Photos/MISC/mental_health.png',
                      'Experienced Counselors',
                      'Our team consists of seasoned professionals with a wealth of knowledge.',
                    ),
                  ),
                ],
              ),
      ],
    ),
  );
}

Widget _buildServiceCard(
  BuildContext context,
  String imagePath,
  String title,
  String description,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFF060E57).withValues(alpha: 0.08),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF060E57).withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFF060E57).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          // Image container with modern styling
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF060E57).withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title with modern typography
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF060E57),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Description with improved readability
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Decorative accent line
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    ),
  );
}

// Footer is now provided by AppFooter for consistency across pages
