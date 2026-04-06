import 'package:flutter/material.dart';

// State Management
import 'state/services_screen_viewmodel.dart';

// Widget Components
import 'widgets/header.dart';
import 'widgets/content_panel.dart';
import '../utils/app_footer.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with TickerProviderStateMixin {
  late ServicesScreenViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ServicesScreenViewModel();
    _viewModel.initialize(this);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: const ServicesHeader(),
      body: SingleChildScrollView(
        controller: _viewModel.scrollController,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isDesktop ? 20 : 40),
              child: ContentPanel(
                fadeAnimation: _viewModel.fadeAnimation,
                slideAnimation: _viewModel.slideAnimation,
                services: _viewModel.services,
                supportPrograms: _viewModel.supportPrograms,
                cardAnimations: _viewModel.cardAnimations,
                onGetStartedTap: () => _viewModel.onGetStartedTap(context),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
