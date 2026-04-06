import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/student_dashboard_viewmodel.dart';
import '../../widgets/app_header.dart';

class StudentHeader extends StatelessWidget implements PreferredSizeWidget {
  const StudentHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentDashboardViewModel>(
      builder: (context, viewModel, child) {
        return AppHeader(onMenu: viewModel.toggleDrawer);
      },
    );
  }
}
