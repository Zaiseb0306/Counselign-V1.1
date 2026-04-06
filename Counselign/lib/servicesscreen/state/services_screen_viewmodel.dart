import 'package:flutter/material.dart';

class ServicesScreenViewModel extends ChangeNotifier {
  // Animation controllers
  late AnimationController fadeController;
  late AnimationController slideController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Scroll controller
  final ScrollController scrollController = ScrollController();

  // Card animation controllers and animations
  final List<AnimationController> cardAnimationControllers = [];
  final List<Animation<double>> cardAnimations = [];

  // Team members data
  final List<Map<String, String>> teamMembers = [
    {'name': 'Sebastian', 'url': 'https://www.facebook.com/basteac'},
    {'name': 'Milwaukee', 'url': 'https://www.facebook.com/eekuawmil'},
    {'name': 'Emeliza', 'url': 'https://www.facebook.com/lizaaayyy'},
    {'name': 'Rex', 'url': 'https://www.facebook.com/rexsimon.fajardoberonilla'},
    {'name': 'Princess', 'url': 'https://www.facebook.com/printitqt'},
  ];

  // Service data
  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.school,
      'title': 'Academic Counseling',
      'description': 'Expert guidance for your academic journey and success strategies.',
      'features': [
        'Study skills development',
        'Time management coaching',
        'Test anxiety management',
        'Academic goal setting',
      ],
    },
    {
      'icon': Icons.favorite,
      'title': 'Personal Counseling',
      'description': 'Confidential support for personal challenges and growth.',
      'features': [
        'Stress management',
        'Anxiety & depression support',
        'Relationship counseling',
        'Self-esteem building',
      ],
    },
    {
      'icon': Icons.work,
      'title': 'Career Counseling',
      'description': 'Professional guidance for your career development journey.',
      'features': [
        'Career assessment',
        'Resume writing support',
        'Interview preparation',
        'Professional networking',
      ],
    },
  ];

  // Support programs data
  final List<Map<String, dynamic>> supportPrograms = [
    {
      'icon': Icons.group,
      'title': 'Group Workshops',
      'description': 'Interactive sessions focusing on personal development and skill-building.',
    },
    {
      'icon': Icons.school,
      'title': 'Peer Mentoring',
      'description': 'Connect with experienced student mentors for guidance and support.',
    },
    {
      'icon': Icons.computer,
      'title': 'Online Resources',
      'description': 'Access our digital library of self-help materials and tools.',
    },
    {
      'icon': Icons.medical_services,
      'title': 'Crisis Support',
      'description': '24/7 emergency support for urgent mental health concerns.',
    },
  ];

  void initialize(TickerProvider vsync) {
    // Initialize main animations
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );

    slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.easeInOut),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));

    // Start main animations
    fadeController.forward();
    slideController.forward();

    // Initialize card animations (7 cards total: 3 services + 4 support)
    for (int i = 0; i < 7; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: vsync,
      );
      cardAnimationControllers.add(controller);
      cardAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        ),
      );
    }

    // Set up scroll listener
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Trigger card animations on scroll
    for (int i = 0; i < cardAnimationControllers.length; i++) {
      if (!cardAnimationControllers[i].isCompleted) {
        cardAnimationControllers[i].forward();
      }
    }
  }

  void onTeamMemberTap(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $name\'s profile...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void onGetStartedTap(BuildContext context) {
    Navigator.of(context).pop();
    // Additional logic to open login modal can be added here
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    scrollController.dispose();
    for (var controller in cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}