import 'package:flutter/material.dart';
import '../state/counselor_dashboard_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';

class CounselorHeader extends StatelessWidget implements PreferredSizeWidget {
  const CounselorHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<CounselorDashboardViewModel>(
      builder: (context, viewModel, child) {
        return AppHeader(onMenu: viewModel.toggleDrawer);
      },
    );
  }
}
