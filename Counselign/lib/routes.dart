import 'package:flutter/material.dart';
import 'landingscreen/landing_screen.dart';
import 'studentscreen/student_dashboard.dart';
import 'studentscreen/my_appointments_screen.dart';
import 'studentscreen/schedule_appointment_screen.dart';
import 'studentscreen/student_profile_screen.dart';
import 'studentscreen/announcements_screen.dart';
import 'studentscreen/follow_up_sessions_screen.dart';
import 'studentscreen/counselor_selection_screen.dart';
import 'studentscreen/conversation_screen.dart';
import 'adminscreen/admin_dashboard_screen.dart';
import 'adminscreen/view_users_screen.dart';
import 'adminscreen/view_all_appointments_screen.dart';
import 'adminscreen/announcements_screen.dart' as admin;
import 'adminscreen/counselor_management_screen.dart';
import 'adminscreen/follow_up_sessions_screen.dart' as admin;
import 'adminscreen/scheduled_appointments_screen.dart';
import 'adminscreen/history_reports_screen.dart';
import 'adminscreen/account_settings_screen.dart';
import 'adminscreen/admins_management_screen.dart';
import 'counselorscreen/counselor_dashboard_screen.dart';
import 'counselorscreen/counselor_announcements_screen.dart';
import 'counselorscreen/counselor_scheduled_appointments_screen.dart';
import 'counselorscreen/counselor_appointments_screen.dart';
import 'counselorscreen/counselor_follow_up_sessions_screen.dart';
import 'counselorscreen/counselor_profile_screen.dart';
import 'counselorscreen/counselor_messages_screen.dart';
import 'counselorscreen/counselor_reports_screen.dart';
import 'servicesscreen/services_screen.dart';

class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String landing = '/';
  static const String studentDashboard = '/student/dashboard';
  static const String myAppointments = '/student/my-appointments';
  static const String scheduleAppointment = '/student/schedule-appointment';
  static const String studentProfile = '/student/profile';
  static const String announcements = '/student/announcements';
  static const String followUpSessions = '/student/follow-up-sessions';
  static const String counselorSelection = '/student/counselor-selection';
  static const String conversation = '/student/conversation';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminViewUsers = '/admin/view-users';
  static const String adminViewAllAppointments = '/admin/view-all-appointments';
  static const String adminAnnouncements = '/admin/announcements';
  static const String adminAdminsManagement = '/admin/admins-management';
  static const String adminCounselorManagement = '/admin/counselor-management';
  static const String adminFollowUpSessions = '/admin/follow-up-sessions';
  static const String adminScheduledAppointments =
      '/admin/scheduled-appointments';
  static const String adminHistoryReports = '/admin/history-reports';
  static const String adminAccountSettings = '/admin/account-settings';

  // Counselor routes
  static const String counselorDashboard = '/counselor/dashboard';
  static const String counselorAnnouncements = '/counselor/announcements';
  static const String counselorScheduledAppointments =
      '/counselor/appointments/scheduled';
  static const String counselorFollowUpSessions = '/counselor/follow-up';
  static const String counselorProfile = '/counselor/profile';
  static const String counselorMessages = '/counselor/messages';
  static const String counselorAppointmentsViewAll =
      '/counselor/appointments/view-all';
  static const String counselorAppointments = '/counselor/appointments';
  static const String counselorReports = '/counselor/reports';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      landing: (context) => const LandingScreen(),
      studentDashboard: (context) => const StudentDashboard(),
      myAppointments: (context) => const MyAppointmentsScreen(),
      scheduleAppointment: (context) => const ScheduleAppointmentScreen(),
      studentProfile: (context) => const StudentProfileScreen(),
      announcements: (context) => const AnnouncementsScreen(),
      followUpSessions: (context) => const FollowUpSessionsScreen(),
      counselorSelection: (context) => const CounselorSelectionScreen(),
      conversation: (context) => const ConversationScreen(),

      // Admin routes
      adminDashboard: (context) => const AdminDashboardScreen(),
      adminViewUsers: (context) => const ViewUsersScreen(),
      adminViewAllAppointments: (context) => const ViewAllAppointmentsScreen(),
      adminAnnouncements: (context) => const admin.AnnouncementsScreen(),
      adminAdminsManagement: (context) => const AdminsManagementScreen(),
      adminCounselorManagement: (context) => const CounselorManagementScreen(),
      adminFollowUpSessions: (context) => const admin.FollowUpSessionsScreen(),
      adminScheduledAppointments: (context) =>
          const ScheduledAppointmentsScreen(),
      adminHistoryReports: (context) => const HistoryReportsScreen(),
      adminAccountSettings: (context) => const AccountSettingsScreen(),
      // Counselor routes
      counselorDashboard: (context) => const CounselorDashboardScreen(),
      counselorAnnouncements: (context) => const CounselorAnnouncementsScreen(),
      counselorScheduledAppointments: (context) =>
          const CounselorScheduledAppointmentsScreen(),
      counselorFollowUpSessions: (context) =>
          const CounselorFollowUpSessionsScreen(),
      counselorProfile: (context) => const CounselorProfileScreen(),
      counselorMessages: (context) => const CounselorMessagesScreen(),
      counselorAppointmentsViewAll: (context) =>
          const CounselorAppointmentsScreen(),
      counselorAppointments: (context) => const CounselorAppointmentsScreen(),
      counselorReports: (context) => const CounselorReportsScreen(),
    };
  }

  // Navigation methods
  static void navigateToServices(BuildContext context) {
    if (context.mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ServicesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  static void navigateToDashboard(BuildContext context) {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const StudentDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  /// Navigate to landing screen and clear the entire navigation stack.
  /// This is used for logout so users always end up on the public landing page
  /// with no back arrow.
  static void navigateToLandingRoot() {
    debugPrint('🚪 navigateToLandingRoot: called');
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('🚪 navigateToLandingRoot: ERROR - navigatorKey.currentState is null!');
      return;
    }

    debugPrint('🚪 navigateToLandingRoot: navigator state found, pushing landing screen');
    navigator.pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          debugPrint('🚪 navigateToLandingRoot: building LandingScreen');
          return const LandingScreen();
        },
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
    debugPrint('🚪 navigateToLandingRoot: pushAndRemoveUntil completed');
  }

  static void navigateToCounselorDashboard(BuildContext context) {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const CounselorDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  static void navigateToAdminDashboard(BuildContext context) {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AdminDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  static void showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  static void safePop(BuildContext context) {
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
