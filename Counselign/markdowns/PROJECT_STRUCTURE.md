# Counselign Project Directory Structure

## ⚠️ Important Notice

This file contains a **high-level overview** of the project structure.

**For the COMPLETE detailed directory tree with ALL files included (nothing excluded):**
- 📄 **See: `COMPLETE_TREE.txt`** (7,539 lines - contains every single file in the project)

The tree command was run with: `tree /F /A > COMPLETE_TREE.txt`

---

## Project Overview
This is a hybrid Flutter mobile application with a CodeIgniter 4 backend for a counseling appointment system.

```
counselign/
├── 📁 android/                          # Android platform configuration
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/                         # Android source files
│   ├── build.gradle.kts
│   ├── gradle/
│   │   └── wrapper/
│   └── settings.gradle.kts
│
├── 📁 build/                            # Flutter build artifacts
│   ├── flutter_assets/                  # Compiled Flutter assets
│   ├── native_assets/                   # Native libraries
│   └── windows/
│
├── 📁 ios/                              # iOS platform configuration
│   ├── Flutter/
│   ├── Runner/                          # iOS app entry point
│   │   ├── AppDelegate.swift
│   │   ├── Assets.xcassets/
│   │   └── Info.plist
│   └── Runner.xcodeproj/
│
├── 📁 lib/                              # Flutter source code (Dart)
│   ├── main.dart                        # App entry point
│   ├── routes.dart                      # Route definitions
│   │
│   ├── 📁 adminscreen/                  # Admin UI screens and logic
│   │   ├── admin_dashboard_screen.dart
│   │   ├── account_settings_screen.dart
│   │   ├── admins_management_screen.dart
│   │   ├── announcements_screen.dart
│   │   ├── counselor_management_screen.dart
│   │   ├── follow_up_sessions_screen.dart
│   │   ├── history_reports_screen.dart
│   │   ├── scheduled_appointments_screen.dart
│   │   ├── view_all_appointments_screen.dart
│   │   ├── view_users_screen.dart
│   │   │
│   │   ├── 📁 models/                   # Admin data models
│   │   │   ├── admin_appointment_detail.dart
│   │   │   ├── admin_profile.dart
│   │   │   ├── admin_user.dart
│   │   │   ├── announcement.dart
│   │   │   ├── appointment_statistics.dart
│   │   │   ├── appointment.dart
│   │   │   ├── counselor_schedule.dart
│   │   │   ├── follow_up_session.dart
│   │   │   ├── message.dart
│   │   │   └── student_pds.dart
│   │   │
│   │   ├── 📁 state/                    # State management (ViewModels)
│   │   │   ├── account_settings_viewmodel.dart
│   │   │   ├── admin_dashboard_viewmodel.dart
│   │   │   ├── admins_management_viewmodel.dart
│   │   │   ├── announcements_viewmodel.dart
│   │   │   ├── counselor_management_viewmodel.dart
│   │   │   ├── follow_up_sessions_viewmodel.dart
│   │   │   ├── history_reports_viewmodel.dart
│   │   │   ├── scheduled_appointments_viewmodel.dart
│   │   │   ├── view_all_appointments_viewmodel.dart
│   │   │   └── view_users_viewmodel.dart
│   │   │
│   │   └── 📁 widgets/                  # Admin reusable widgets
│   │       ├── admin_footer.dart
│   │       ├── admin_header.dart
│   │       ├── appointments_card.dart
│   │       ├── messages_card.dart
│   │       └── pds_modal.dart
│   │
│   ├── 📁 counselorscreen/              # Counselor UI screens
│   │   ├── counselor_dashboard_screen.dart
│   │   ├── counselor_appointments_screen.dart
│   │   ├── counselor_announcements_screen.dart
│   │   ├── counselor_follow_up_sessions_screen.dart
│   │   ├── counselor_messages_screen.dart
│   │   ├── counselor_profile_screen.dart
│   │   ├── counselor_reports_screen.dart
│   │   ├── counselor_scheduled_appointments_screen.dart
│   │   │
│   │   ├── 📁 models/                   # Counselor data models
│   │   │   ├── appointment.dart
│   │   │   ├── appointment_report.dart
│   │   │   ├── completed_appointment.dart
│   │   │   ├── conversation.dart
│   │   │   ├── counselor_availability.dart
│   │   │   ├── counselor_message.dart
│   │   │   ├── counselor_profile.dart
│   │   │   ├── counselor_schedule.dart
│   │   │   ├── follow_up_session.dart
│   │   │   ├── message.dart
│   │   │   ├── notification.dart
│   │   │   └── scheduled_appointment.dart
│   │   │
│   │   ├── 📁 state/                    # Counselor state management
│   │   │   ├── counselor_announcements_viewmodel.dart
│   │   │   ├── counselor_appointments_viewmodel.dart
│   │   │   ├── counselor_dashboard_viewmodel.dart
│   │   │   ├── counselor_follow_up_sessions_viewmodel.dart
│   │   │   ├── counselor_messages_viewmodel.dart
│   │   │   ├── counselor_profile_viewmodel.dart
│   │   │   ├── counselor_reports_viewmodel.dart
│   │   │   └── counselor_scheduled_appointments_viewmodel.dart
│   │   │
│   │   └── 📁 widgets/                  # Counselor reusable widgets
│   │       ├── appointment_report_card.dart
│   │       ├── appointments_cards.dart
│   │       ├── appointments_table.dart
│   │       ├── cancellation_reason_dialog.dart
│   │       ├── chat_popup.dart
│   │       ├── counselor_footer.dart
│   │       ├── counselor_header.dart
│   │       ├── counselor_screen_wrapper.dart
│   │       ├── export_filters_dialog.dart
│   │       ├── mini_calendar.dart
│   │       ├── navigation_drawer.dart
│   │       ├── notifications_dropdown.dart
│   │       └── weekly_schedule.dart
│   │
│   ├── 📁 studentscreen/                # Student UI screens
│   │   ├── student_dashboard.dart
│   │   ├── my_appointments_screen.dart
│   │   ├── schedule_appointment_screen.dart
│   │   ├── announcements_screen.dart
│   │   ├── follow_up_sessions_screen.dart
│   │   ├── student_profile_screen.dart
│   │   │
│   │   ├── 📁 models/                   # Student data models
│   │   │   └── (11 model files)
│   │   │
│   │   ├── 📁 state/                    # Student state management
│   │   │   └── (7 viewmodel files)
│   │   │
│   │   ├── 📁 widgets/                  # Student reusable widgets
│   │   │   ├── acknowledgment_section.dart
│   │   │   ├── appointment_card.dart
│   │   │   ├── chat_popup.dart
│   │   │   ├── consent_accordion.dart
│   │   │   ├── content_panel.dart
│   │   │   ├── counselor_selection_dialog.dart
│   │   │   ├── footer.dart
│   │   │   ├── header.dart
│   │   │   ├── navigation_drawer.dart
│   │   │   ├── notifications_dropdown.dart
│   │   │   ├── pds_reminder_modal.dart
│   │   │   ├── profile_display.dart
│   │   │   ├── student_header.dart
│   │   │   └── student_screen_wrapper.dart
│   │   │
│   │   ├── 📁 dialogs/                  # Student-specific dialogs
│   │   │   └── (3 dialog files)
│   │   │
│   │   └── 📁 utils/                    # Student utilities
│   │       └── (1 utility file)
│   │
│   ├── 📁 landingscreen/                # Landing/authentication screens
│   │   ├── landing_screen.dart
│   │   │
│   │   ├── 📁 dialogs/                  # Authentication dialogs
│   │   │   ├── admin_login_dialog.dart
│   │   │   ├── code_entry_dialog.dart
│   │   │   ├── contact_dialog.dart
│   │   │   ├── forgot_password_dialog.dart
│   │   │   ├── login_dialog.dart
│   │   │   ├── new_password_dialog.dart
│   │   │   ├── signup_dialog.dart
│   │   │   ├── terms_dialog.dart
│   │   │   ├── verification_dialog.dart
│   │   │   └── verification_success_dialog.dart
│   │   │
│   │   ├── 📁 frontend/                 # Frontend components
│   │   │   └── (3 frontend files)
│   │   │
│   │   └── 📁 state/
│   │       └── landing_screen_viewmodel.dart
│   │
│   ├── 📁 servicesscreen/               # Services page
│   │   ├── services_screen.dart
│   │   │
│   │   ├── 📁 state/
│   │   │   └── (1 viewmodel file)
│   │   │
│   │   └── 📁 widgets/                  # Service page widgets
│   │       └── (6 widget files)
│   │
│   ├── 📁 api/                          # API client configuration
│   │   └── config.dart
│   │
│   ├── 📁 utils/                        # Shared utilities
│   │   ├── app_footer.dart
│   │   ├── async_button.dart
│   │   ├── online_status.dart
│   │   ├── session.dart
│   │   └── user_display_helper.dart
│   │
│   └── 📁 widgets/                      # Global reusable widgets
│       ├── app_header.dart
│       └── bottom_navigation_bar.dart
│
├── 📁 Counselign/                       # CodeIgniter 4 Backend
│   ├── app/
│   │   ├── Common.php                   # Common base class
│   │   │
│   │   ├── 📁 Config/                   # Configuration files
│   │   │   ├── App.php
│   │   │   ├── Autoload.php
│   │   │   ├── Boot/
│   │   │   │   ├── development.php
│   │   │   │   ├── production.php
│   │   │   │   └── testing.php
│   │   │   ├── Cache.php
│   │   │   ├── Constants.php
│   │   │   ├── ContentSecurityPolicy.php
│   │   │   ├── Cookie.php
│   │   │   ├── CORS.php
│   │   │   ├── CURLRequest.php
│   │   │   ├── Database.php
│   │   │   ├── DocTypes.php
│   │   │   ├── Email.php
│   │   │   ├── Encryption.php
│   │   │   ├── Events.php
│   │   │   ├── Exceptions.php
│   │   │   ├── Feature.php
│   │   │   ├── Filters.php
│   │   │   ├── ForeignCharacters.php
│   │   │   ├── Format.php
│   │   │   ├── Generators.php
│   │   │   ├── Honeypot.php
│   │   │   ├── Images.php
│   │   │   ├── Kint.php
│   │   │   ├── Logger.php
│   │   │   ├── Migrations.php
│   │   │   ├── Mimes.php
│   │   │   ├── Modules.php
│   │   │   ├── Optimize.php
│   │   │   ├── Pager.php
│   │   │   ├── Paths.php
│   │   │   ├── Publisher.php
│   │   │   ├── Routes.php
│   │   │   ├── Routing.php
│   │   │   ├── Security.php
│   │   │   ├── Services.php
│   │   │   ├── Session.php
│   │   │   ├── Toolbar.php
│   │   │   ├── UserAgents.php
│   │   │   ├── Validation.php
│   │   │   └── View.php
│   │   │
│   │   ├── 📁 Controllers/              # MVC Controllers
│   │   │   ├── Auth.php                 # Authentication controller
│   │   │   ├── BaseController.php       # Base controller class
│   │   │   ├── Home.php                 # Home page
│   │   │   ├── Logout.php               # Logout handler
│   │   │   ├── Services.php             # Services page
│   │   │   ├── EmailController.php      # Email services
│   │   │   ├── ForgotPassword.php       # Password recovery
│   │   │   ├── UpdatePassword.php       # Password update
│   │   │   ├── Photo.php                # Photo uploads
│   │   │   ├── TestActivity.php         # Testing utilities
│   │   │   │
│   │   │   ├── 📁 Admin/                # Admin controllers
│   │   │   │   ├── Dashboard.php
│   │   │   │   ├── AdminsManagement.php
│   │   │   │   ├── AdminProfileApi.php
│   │   │   │   ├── Announcements.php
│   │   │   │   ├── AnnouncementsApi.php
│   │   │   │   ├── Appointments.php
│   │   │   │   ├── CounselorInfo.php
│   │   │   │   ├── CounselorsApi.php
│   │   │   │   ├── DatabaseHealth.php
│   │   │   │   ├── EventsApi.php
│   │   │   │   ├── FilterData.php
│   │   │   │   ├── FollowUpSessions.php
│   │   │   │   ├── GetAllAppointments.php
│   │   │   │   ├── HistoryReports.php
│   │   │   │   ├── Message.php
│   │   │   │   ├── SessionCheck.php
│   │   │   │   └── UsersApi.php
│   │   │   │
│   │   │   ├── 📁 Counselor/           # Counselor controllers
│   │   │   │   ├── Dashboard.php
│   │   │   │   ├── Profile.php
│   │   │   │   ├── Appointments.php
│   │   │   │   ├── Availability.php
│   │   │   │   ├── FollowUp.php
│   │   │   │   ├── Announcements.php
│   │   │   │   ├── Message.php
│   │   │   │   ├── HistoryReports.php
│   │   │   │   ├── Notifications.php
│   │   │   │   ├── Events.php
│   │   │   │   ├── FilterData.php
│   │   │   │   ├── GetAllAppointments.php
│   │   │   │   └── SessionCheck.php
│   │   │   │
│   │   │   └── 📁 Student/             # Student controllers
│   │   │       ├── Dashboard.php
│   │   │       ├── Profile.php
│   │   │       ├── Appointment.php
│   │   │       ├── AppointmentAtomic.php
│   │   │       ├── PDS.php
│   │   │       ├── PDSAtomic.php
│   │   │       ├── Announcements.php
│   │   │       ├── FollowUpSessions.php
│   │   │       ├── Message.php
│   │   │       ├── Notifications.php
│   │   │       ├── Events.php
│   │   │       └── SessionCheck.php
│   │   │
│   │   ├── 📁 Models/                   # Database models
│   │   │   ├── BaseModel.php
│   │   │   ├── UserModel.php
│   │   │   ├── CounselorModel.php
│   │   │   ├── AnnouncementModel.php
│   │   │   ├── AppointmentModel.php
│   │   │   ├── OptimizedAppointmentModel.php
│   │   │   ├── CounselorAvailabilityModel.php
│   │   │   ├── FollowUpAppointmentModel.php
│   │   │   ├── NotificationsModel.php
│   │   │   ├── StudentPDSModel.php
│   │   │   ├── StudentPersonalInfoModel.php
│   │   │   ├── StudentAcademicInfoModel.php
│   │   │   ├── StudentAddressInfoModel.php
│   │   │   ├── StudentResidenceInfoModel.php
│   │   │   ├── StudentFamilyInfoModel.php
│   │   │   ├── StudentServicesAvailedModel.php
│   │   │   ├── StudentServicesNeededModel.php
│   │   │   └── StudentSpecialCircumstancesModel.php
│   │   │
│   │   ├── 📁 Views/                    # PHP views/templates
│   │   │   ├── landing.php
│   │   │   ├── services_page.php
│   │   │   ├── welcome_message.php
│   │   │   │
│   │   │   ├── 📁 admin/                # Admin views
│   │   │   │   ├── dashboard.php
│   │   │   │   ├── account_settings.php
│   │   │   │   ├── admins_management.php
│   │   │   │   ├── announcements.php
│   │   │   │   ├── appointments.php
│   │   │   │   ├── counselor_info.php
│   │   │   │   ├── follow_up_sessions.php
│   │   │   │   ├── history_reports.php
│   │   │   │   ├── scheduled_appointments.php
│   │   │   │   ├── view_all_appointments.php
│   │   │   │   └── view_users.php
│   │   │   │
│   │   │   ├── 📁 counselor/           # Counselor views
│   │   │   │   ├── dashboard.php
│   │   │   │   ├── counselor_profile.php
│   │   │   │   ├── appointments.php
│   │   │   │   ├── scheduled_appointments.php
│   │   │   │   ├── counselor_announcements.php
│   │   │   │   ├── follow_up.php
│   │   │   │   ├── history_reports.php
│   │   │   │   ├── messages.php
│   │   │   │   └── view_all_appointments.php
│   │   │   │
│   │   │   ├── 📁 student/            # Student views
│   │   │   │   ├── dashboard.php
│   │   │   │   ├── student_profile.php
│   │   │   │   ├── my_appointments.php
│   │   │   │   ├── student_schedule_appointment.php
│   │   │   │   ├── student_announcements.php
│   │   │   │   └── follow_up_sessions.php
│   │   │   │
│   │   │   ├── 📁 auth/                # Authentication views
│   │   │   │   └── verification_prompt.php
│   │   │   │
│   │   │   ├── 📁 emails/              # Email templates
│   │   │   │   └── verification_email.php
│   │   │   │
│   │   │   ├── 📁 modals/             # Modal dialogs
│   │   │   │   ├── confirmation_modal.php
│   │   │   │   └── student_dashboard_modals.php
│   │   │   │
│   │   │   └── 📁 errors/              # Error pages
│   │   │       ├── cli/
│   │   │       └── html/
│   │   │
│   │   ├── 📁 Database/                # Database migrations
│   │   │   ├── Migrations/
│   │   │   │   ├── 2024_01_01_000001_FixForeignKeyConstraints.php
│   │   │   │   ├── 2024_01_01_000002_AddBusinessRuleTriggers.php
│   │   │   │   ├── 2024_01_01_000003_ConfigureACIDSettings.php
│   │   │   │   ├── 2025-09-23-160820_AddNotificationsTable.php
│   │   │   │   ├── 2025-09-23-160918_CreateCiSessionsTable.php
│   │   │   │   ├── 2025-09-23-160926_AlterNotificationsTableUserIdField.php
│   │   │   │   ├── 2025-09-23-163630_AddVerificationToUsers.php
│   │   │   │   └── 2025-09-23-174254_AddResetTokenExpirationToUsers.php
│   │   │   └── Seeds/
│   │   │
│   │   ├── 📁 Services/                # Business logic services
│   │   │   ├── AppointmentEmailService.php
│   │   │   └── CounselorEmailTemplates.php
│   │   │
│   │   ├── 📁 Libraries/               # Custom libraries
│   │   │   ├── DatabaseManager.php
│   │   │   ├── DatabaseMonitor.php
│   │   │   ├── QueryCache.php
│   │   │   └── TransactionManager.php
│   │   │
│   │   ├── 📁 Helpers/                 # Helper functions
│   │   │   ├── admin_helper.php
│   │   │   ├── url_helper.php
│   │   │   ├── UserActivityHelper.php
│   │   │   └── UserDisplayHelper.php
│   │   │
│   │   ├── 📁 Filters/                 # Request filters
│   │   │
│   │   ├── 📁 Language/                # Translations
│   │   │   └── en/
│   │   │       └── Validation.php
│   │   │
│   │   └── 📁 ThirdParty/              # Third-party libraries
│   │
│   ├── public/                          # Web accessible directory
│   │   ├── index.php                    # Entry point
│   │   ├── favicon.ico
│   │   ├── robots.txt
│   │   │
│   │   ├── 📁 css/                     # Stylesheets
│   │   │   ├── landing.css
│   │   │   ├── services.css
│   │   │   ├── admin/                   # Admin CSS files (14 files)
│   │   │   ├── counselor/              # Counselor CSS files (10 files)
│   │   │   ├── student/                # Student CSS files (7 files)
│   │   │   └── auth/                   # Auth CSS files
│   │   │
│   │   ├── 📁 js/                      # JavaScript files
│   │   │   ├── landing.js
│   │   │   ├── services.js
│   │   │   ├── admin_dashboard.js
│   │   │   ├── admin/                   # Admin JS files (15 files)
│   │   │   ├── counselor/              # Counselor JS files (10 files)
│   │   │   ├── student/                # Student JS files (9 files)
│   │   │   ├── auth/                   # Auth JS files
│   │   │   └── utils/                  # Utility JS files
│   │   │
│   │   └── 📁 Photos/                   # Image assets
│   │       ├── counselign_logo.png
│   │       ├── profile_pictures/
│   │       ├── counselor_profiles/
│   │       └── MISC/
│   │
│   ├── vendor/                          # Composer dependencies
│   │   ├── autoload.php
│   │   ├── codeigniter4/framework/
│   │   ├── phpmailer/phpmailer/
│   │   └── (other dependencies)
│   │
│   ├── writable/                        # Writable directories
│   │   ├── cache/
│   │   ├── debugbar/
│   │   ├── logs/
│   │   ├── session/
│   │   ├── uploads/
│   │   ├── appointments_debug.log
│   │   └── debug.log
│   │
│   ├── memory-bank/                     # Project documentation
│   │   ├── activeContext.md
│   │   ├── productContext.md
│   │   ├── progress.md
│   │   ├── projectbrief.md
│   │   ├── systemPatterns.md
│   │   └── techContext.md
│   │
│   ├── tests/                           # PHPUnit tests
│   │   ├── _support/
│   │   ├── database/
│   │   ├── session/
│   │   └── unit/
│   │
│   ├── spark                            # CLI tool
│   ├── composer.json                    # PHP dependencies
│   ├── composer.lock
│   ├── counselign.sql                   # Database schema
│   ├── phpunit.xml.dist                 # Test configuration
│   ├── preload.php                      # Preloading configuration
│   └── ACID_IMPLEMENTATION_SUMMARY.md
│
├── 📁 memory-bank/                      # Top-level documentation
│   ├── activeContext.md
│   ├── productContext.md
│   ├── progress.md
│   ├── projectbrief.md
│   ├── systemPatterns.md
│   └── techContext.md
│
├── 📁 Photos/                           # Application images
│   ├── counselign_logo.png
│   ├── counselign.ico
│   ├── close_eye.png
│   ├── eye.png
│   ├── profile.png
│   ├── privacy1.png
│   ├── personalized.jpg
│   ├── counselor_profiles/
│   ├── profile_pictures/
│   └── MISC/
│
├── 📁 test/                            # Flutter tests
│   └── widget_test.dart
│
├── 📁 web/                             # Web-specific configuration
│   ├── index.html
│   ├── manifest.json
│   ├── favicon.png
│   └── icons/
│
├── 📁 windows/                         # Windows platform configuration
│   ├── CMakeLists.txt
│   ├── flutter/
│   └── runner/
│
├── 📁 linux/                           # Linux platform configuration
│   ├── CMakeLists.txt
│   ├── flutter/
│   └── runner/
│
├── 📁 macos/                           # macOS platform configuration
│   ├── Flutter/
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   └── Runner.xcworkspace/
│
├── analysis_options.yaml               # Dart analyzer configuration
├── devtools_options.yaml               # DevTools configuration
├── pubspec.yaml                        # Flutter dependencies
├── pubspec.lock                       # Dependency lock file
├── README.md                          # Project readme
└── prompt_memory.md                   # AI context file
```

## Key Directories Explained

### Flutter Frontend (`lib/`)
- **adminscreen/**: Admin user interface and state management
- **counselorscreen/**: Counselor user interface and state management
- **studentscreen/**: Student user interface and state management
- **landingscreen/**: Authentication and landing pages
- **servicesscreen/**: Services information page
- **api/**: API client configuration
- **utils/**: Shared utility functions
- **widgets/**: Global reusable widgets

### Backend (`Counselign/`)
- **app/Controllers/**: MVC controllers for Admin, Counselor, Student modules
- **app/Models/**: Database models and data access
- **app/Views/**: PHP templates for web views
- **app/Database/Migrations/**: Database schema changes
- **public/**: Web-accessible static assets (CSS, JS, images)
- **vendor/**: Composer package dependencies

### Platform Directories
- **android/**: Android build configuration
- **ios/**: iOS build configuration
- **windows/**: Windows build configuration
- **linux/**: Linux build configuration
- **macos/**: macOS build configuration
- **web/**: Web build configuration

### Documentation
- **memory-bank/**: Project documentation and context (present at both root and `Counselign/`)
- Contains: `activeContext.md`, `productContext.md`, `progress.md`, `projectbrief.md`, `systemPatterns.md`, `techContext.md`

## Architecture Overview
This project follows a **hybrid architecture** with:
- **Flutter** for mobile client (iOS, Android, Web, Windows, Linux, macOS)
- **CodeIgniter 4** for backend API and web administration
- **RESTful API** communication between client and server
- **State management** using Riverpod in Flutter
- **MVC pattern** in CodeIgniter 4 backend

