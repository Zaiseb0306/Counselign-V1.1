# System Patterns

## Documentation Assets (Nov 24, 2025)
- `docs/software_implementation_testing.md` explains to non-technical stakeholders how the Flutter mobile client and CodeIgniter web portal share APIs, what hardware/software are required, and the stabilization fixes (multipart posts, dropdown sync, enum validation) that keep both fronts aligned. Use this file as the quick reference when preparing reports or presentations.

## Admin Dashboard Structure (Updated Oct 27, 2025)

The AdminDashboardScreen now exactly mirrors the backend dashboard.php structure:

### Layout Components
1. **Sticky Header**: AdminHeader widget with logo, title, and logout button
2. **Profile Section**: Avatar, greeting, last login, responsive action buttons
3. **Appointment Reports Section**: Time range filter, "View Past Reports" button
4. **Statistics Section**: 5 stat cards with FontAwesome icons and proper colors
5. **Charts Section**: Trend line chart and pie chart using fl_chart
6. **Appointment Tables Section**: Tabbed interface with search/filter and export

### Responsive Design
- **Mobile (<600px)**: Stacked action buttons, compact layouts
- **Tablet (600-1024px)**: Horizontal action buttons, medium spacing
- **Desktop (>=1024px)**: Full horizontal layout, desktop action buttons

### Data Management
- AdminDashboardViewModel with getAppointmentsByStatus() method
- Provider pattern for state management
- Type-safe appointment filtering and statistics calculation

### Navigation
- All action buttons navigate to appropriate admin screens
- Export functionality with PDF/Excel options
- Tab-based appointment filtering (All, Approved, Rejected, Completed, Cancelled)

## Dialog Themes (Updated Oct 27, 2025)

- All landing dialogs (e.g., LoginDialog, AdminLoginDialog, ContactDialog) use a unified modern style with:
  - Transparent dialog backgrounds, outer Container with rounded corners (radius 24)
  - White box with two layers of box shadow (primary large/soft blue, subtle shadow for lift)
  - Icon header in gradient circle matching dialog purpose (login, admin)
  - Modern close button with background container
  - Padding: uniform content padding (32 on all sides)
  - Inputs styled with prefix icons, consistent colors
  - Text fields capped at appropriate length, password field with eye toggle using icon/image
  - Visible, styled error/output feedback sections
  - Button row: Primary button (color #060E57 or relevant), Elevated secondary options for navigation/other roles
- All dialogs preserve original business logic and only share a visual styling system.
- Future dialogs must extend this theme system for consistency and user familiarity.

## Architecture
- Flutter client app with route-based navigation (`lib/routes.dart`), MaterialApp in `lib/main.dart`.
- Integrates with a PHP CodeIgniter backend (separate MVC project) via HTTP.

## Navigation
- Named routes via `AppRoutes` with `initialRoute` set to `landing` (`'/'`).
- Helper methods for transitions (`navigateToServices`, `navigateToDashboard`, `safePop`, `showSnackBar`).
- Counselor appointments management routes:
  - `AppRoutes.counselorAppointments` → `CounselorAppointmentsScreen`
  - `AppRoutes.counselorAppointmentsViewAll` → `CounselorAppointmentsScreen`

### Student messaging flow (Updated Nov 3, 2025)
- Counselor selection and conversation are now dedicated screens (replacing modals):
  - `AppRoutes.counselorSelection` → `CounselorSelectionScreen` (`/student/counselor-selection`)
  - `AppRoutes.conversation` → `ConversationScreen` (`/student/conversation`)
- Entry from `StudentDashboard` action buttons:
  - People icon → navigates to CounselorSelectionScreen
  - Message icon → navigates to ConversationScreen if a counselor is selected, otherwise to CounselorSelectionScreen
- Messaging retains original view model logic (polling, send, formatting) with UI migrated from modals to full screens.

## State Management
- `provider` listed; screens and state files exist per feature directories.
- `shared_preferences` for lightweight persistence.

## Networking
- `http` package used.
- `ApiConfig.currentBaseUrl` selects environment (web/Android/iOS/desktop) with default headers and timeouts.
- Authentication API endpoints:
  - GET `auth/logout` → Logs out user and updates logout_time, last_activity, last_inactive_at, last_active_at database columns via UserActivityHelper
- Student API endpoints:
  - GET `student/get-counselor-schedules` → Returns counselor availability data organized by weekday (Monday-Friday only)

## Theming
- Seeded `ColorScheme` and global font family (`Roboto`).

## Modules (by directory)
- `lib/landingscreen` → entry/marketing+dialogs with modern drawer navigation.
  - Modern drawer: `frontend/drawer.dart` with gradient background, animated navigation items, responsive design.
- `lib/studentscreen` → student dashboards, appointments, profile, announcements.
  - Dashboard: `student_dashboard.dart` with PDS reminder modal (`pds_reminder_modal.dart`) that shows 20-second auto-close timer with dismiss/update buttons on initial login. Event and quote carousels accept horizontal swipe gestures (drag distance or fling velocity) in addition to auto-rotation and controls, keeping animations and timers in sync for a smoother mobile experience.
  - Announcements: `announcements_screen.dart` shares copy with counselor view; calendar markers now derive exclusively from event data while announcements stay in list sections.
  - Schedule Appointment: `schedule_appointment_screen.dart` with consent accordion (`consent_accordion.dart`) and acknowledgment section (`acknowledgment_section.dart`) for legal consent requirements.
  - Appointments: `my_appointments_screen.dart` with card-based UI using `AppointmentCard` widget.
  - PDS Preview: `pds_preview_screen.dart` loads the authenticated HTML returned by `/student/pds/preview` inside a WebView so CSS/JS assets render correctly without triggering `/index.php/auth` redirects.
  - Models: `counselor_schedule.dart` for counselor schedule data with weekday organization.
- `lib/adminscreen` → admin dashboard and widgets.
- `lib/counselorscreen` → counselor dashboard with messages/appointments cards, announcements, appointments, follow-up sessions, profile, messages screen with conversation list and chat interface, reports screen with comprehensive appointment analytics.
  - Announcements: `counselor_announcements_screen.dart` mirrors student copy and uses event-only calendar markers and details for parity.
  - Profile management: `counselor_profile_screen.dart`, `state/counselor_profile_viewmodel.dart`, `models/counselor_profile.dart`, `models/counselor_availability.dart` with comprehensive profile management including account settings, personal information updates, password changes, profile picture uploads, and availability management with time range functionality.
  - Appointments management: `counselor_appointments_screen.dart`, `state/counselor_appointments_viewmodel.dart`, `models/appointment.dart`.
    - Cards and detail dialogs now show `method_type` so counselors can distinguish in-person vs remote consultations at a glance.
  - Scheduled appointments: `counselor_scheduled_appointments_screen.dart`, `state/counselor_scheduled_appointments_viewmodel.dart`, `models/scheduled_appointment.dart`, `models/counselor_schedule.dart`.
    - Method type appears in both the responsive cards and table view; follow-up entries surface a "Pending Follow-up" badge when the linked session is still awaiting completion.
  - Follow-up sessions: `counselor_follow_up_sessions_screen.dart`, `state/counselor_follow_up_sessions_viewmodel.dart`, `models/completed_appointment.dart`, `models/follow_up_session.dart`, `models/counselor_availability.dart` with enhanced features: follow-up count badges, pending warning indicators, separate pending section, proper sorting.
  - Reports system: `counselor_reports_screen.dart`, `state/counselor_reports_viewmodel.dart`, `models/appointment_report.dart` with comprehensive appointment analytics including statistics dashboard, data visualization (line charts for trends, pie charts for status distribution), tab-based filtering, search and date filtering, PDF export with advanced filtering, responsive appointment cards for mobile display.
    - Quick search now matches `method_type`, and exports already include the column to match on-screen data.
  - Widgets: `appointments_table.dart`, `weekly_schedule.dart`, `mini_calendar.dart`, `cancellation_reason_dialog.dart`, `appointment_report_card.dart`, `export_filters_dialog.dart`.
- `lib/servicesscreen` → services display and navigation.
- `lib/utils/session.dart` → session utilities.

## Platform Targets
- Android, iOS, Web, Desktop (Windows/macOS/Linux configured by Flutter scaffolding).

## Coding Patterns/Rules from Recent Fixes
- Keyboard input: prefer `KeyboardListener` with `onKeyEvent` returning `KeyEventResult`; use `KeyDownEvent` checks.
- Token inputs: use `TextField` with centered text, explicit `TextStyle(color: Colors.black)`, `contentPadding` minimized, and fixed cell height for clarity.
- Colors: use `Color.withValues(alpha: ...)` instead of `withOpacity`.
- QR codes (qr_flutter): avoid deprecated `color`/`foregroundColor`/`emptyColor`. Use `eyeStyle` and `dataModuleStyle` for module/eye colors and keep `gapless: false` with padding for quiet zone.
- Async context safety: after awaits or delays, always gate UI interactions with `if (context.mounted)` before calling navigation/snackbar/dialog APIs.
- Logging: use `debugPrint`; avoid `print` in production.
 - Layout overflow prevention: wrap tall page bodies in `SingleChildScrollView` or use `CustomScrollView` where dynamic lists/sections can exceed viewport, e.g., student `AnnouncementsScreen` main content.
 - Layout in scroll views: Do not place `Expanded`/`Flexible` inside `Column` when the column is inside a `SingleChildScrollView`. Instead, make inner lists non-scrollable (`shrinkWrap: true`, `NeverScrollableScrollPhysics`) and let the outer scroll view scroll.