## Nov 26, 2025
- Authored a comprehensive update to `guide.md` covering sample group members, end-to-end system description (Flutter app + CodeIgniter 4 API), test/build procedures for both stacks (URL configuration, clean builds, Android Studio and terminal commands), and the primary toolchains used on each side. Ready for stakeholders to customize names as needed.
- Converted the System Description in `guide.md` into a detailed paragraph that explains the Flutter client and CodeIgniter backend flow in language approachable for high school students, and highlighted the key features available to students, counselors, and admins.

## Nov 24, 2025
- Authored `docs/software_implementation_testing.md`, capturing a concise explanation of how the Flutter mobile build and CodeIgniter web portal operate together, the shared hardware/software requirements (with asset reference), and the fixes that stabilized multipart form posts, dropdown reactivity, and enum validation. Document also summarizes current testing status across mobile and web journeys for stakeholders.
- Enabled swipe gestures on student dashboard event and quote carousels so students can drag left/right to switch cards in addition to auto-rotation and arrow buttons. Each widget now normalizes drag distance/velocity, restarts its timer after manual navigation, and preserves the existing fade/slide animations for continuity. Analyzer remains clean.
- Split student profile “Update Profile” modal into two entry points: tapping the avatar edit icon now opens a picture-only dialog, while the main “Update Profile” button exposes username/email fields without photo inputs. Both variants share the existing update logic and keep controller data synchronized with the view model.
- Counselor profile card now mirrors the student layout: the Account Settings header displays `Account ID: {user_id}` beneath the title, and the Change Password/Update Profile buttons render side-by-side with matching colors, padding, and rounded corners for consistent UX.
- Counselor profile avatar gained its own edit affordance that launches a photo-only dialog, while the Update Profile button now opens a username/email-only dialog. Both flows reuse the existing updateProfile/uploadProfilePicture calls so counselors can independently change their picture or credentials without extra inputs.
- Student profile picture-only modal now mirrors the counselor design with a circular preview (current or newly selected photo) and a single upload button inside a framed container so students get visual confirmation before saving.
- Added a Preview button next to “Save” in the Student PDS header that launches `student/pds/preview` in the browser using `url_launcher`, matching the CodeIgniter flow for viewing/downloading the generated PDS.

## Nov 7, 2025
- Added env-driven API base URL (`API_BASE_URL`) and HTTPS production placeholder in `lib/api/config.dart`.
- Updated Android Gradle to Java 17 (`compileOptions`, `kotlinOptions`, Kotlin `jvmToolchain`).
- Analyzer clean after changes.
- Synced counselor announcements UI copy with student screen and restricted both calendars to event-only markers/details; counselor announcement cards now reuse student layout for parity.
- Counselor appointments & schedules now expose `method_type` data, and scheduled follow-up entries show "Pending Follow-up" badges when outstanding. Reports search matches method type, exports unchanged. Analyzer currently reports two pre-existing admin dashboard async context info warnings.
- Counselor dashboard messages card now bolds unread conversation previews and appends 12-hour AM/PM timestamps; counselor chat timestamps share the same 12-hour formatting.
- Counselor conversation sidebar now formats last-message timestamps as "Nov 7 9:20 PM" while dashboard cards use the same month-abbrev 12-hour style, improving consistency with backend displays.
# Progress

## What works
- App boots with Material theme and named routes.
- Landing, user dashboard, appointments, profile, announcements screens registered.
- Admin and counselor dashboard routes scaffolded.
- API config utility with environment-aware base URL and headers.

## In progress / planned
- End-to-end API integrations per screen (list endpoints and payloads).
- Session persistence and auth guards on routes.
- Admin and counselor management flows.

## Known issues/risks
- Hardcoded IPs in `ApiConfig` require environment management.
- Backend dependency (CodeIgniter MVC) must be reachable for runtime features.

## Done (Nov 5, 2025) - Counselor Messages Timestamp Toggle Reactivity Fix
- **CRITICAL FIX**: Fixed timestamp toggle not showing immediately when clicking message bubbles:
  - **Root Cause**: ListView.builder was not rebuilding properly when _selectedMessageId state changed, causing timestamps to only appear after page refresh or navigation
  - **Solution**: Added ValueKey to ListView.builder based on _selectedMessageId to force proper widget tree rebuilds
  - **Implementation**: Added `key: ValueKey(_selectedMessageId)` parameter to ListView.builder widget
  - **Behavior Fixed**: Timestamps now show/hide immediately when user clicks message bubbles without any delay or need for refresh
  - **Flutter Optimization**: ValueKey ensures Flutter recognizes the list has changed and triggers immediate rebuild of visible items
  - **User Experience**: Matches expected Messenger-like behavior with instant visual feedback on tap
  - **State Management**: setState() now properly propagates through ListView.builder thanks to the key parameter
  - **No Breaking Changes**: Maintained all existing messaging functionality including sending, receiving, scrolling
  - **Type Safety**: Follows Flutter best practices with proper key usage for performance and reactivity
  - **No Linter Errors**: Successfully tested with flutter analyze showing only 2 pre-existing warnings in admin dashboard (unrelated)
  - **Files Modified**: 
    - `lib/counselorscreen/counselor_messages_screen.dart` - Added ValueKey to ListView.builder for immediate timestamp visibility toggle

## Done (Nov 5, 2025) - Counselor Messages Timestamp Toggle Feature
- **UI ENHANCEMENT**: Implemented Messenger-like timestamp toggle functionality in counselor messages screen:
  - **Click-to-Show Timestamps**: Message timestamps are now hidden by default and only appear when user clicks on a message bubble
  - **State Management**: Added _selectedMessageId state variable to track which message's timestamp is currently visible
  - **Toggle Behavior**: Clicking a message shows its timestamp, clicking again (or clicking another message) hides it
  - **Layout Restructure**: Changed message bubble layout from Row to Column structure to support conditional timestamp display below bubble
  - **Proper Alignment**: Timestamps appear below message bubbles with proper alignment (left-aligned for received messages, right-aligned for sent messages with appropriate padding)
  - **Clean UI**: Message bubbles now display only the message text by default, creating a cleaner, more focused interface
  - **GestureDetector Integration**: Wrapped message bubble containers with GestureDetector for tap handling using setState to toggle visibility
  - **Type Safety**: Used messageId field from CounselorMessage model for unique message identification
  - **Messenger UX Pattern**: Matches the familiar user experience from popular messaging apps where timestamps appear on demand
  - **Functionality Preserved**: Maintained all existing messaging functionality including sending, receiving, and scrolling behavior
  - **No Linter Errors**: Successfully tested with flutter analyze showing only 2 pre-existing warnings in admin dashboard (unrelated)
  - **Files Modified**: 
    - `lib/counselorscreen/counselor_messages_screen.dart` - Enhanced message bubble with timestamp toggle functionality

## Done (Dec 19, 2024) - Counselor Scheduled Appointments Loading States Implementation
- **LOADING STATES**: Added comprehensive loading states to Mark Complete button and Confirm Cancellation button with proper state management and automatic modal closure functionality:
  - **ViewModel Enhancement**: Added loading state properties (isUpdatingStatus, updatingAppointmentId) to CounselorScheduledAppointmentsViewModel to track ongoing operations
  - **Mark Complete Button**: Implemented loading state with circular progress indicator and "Processing..." text when appointment status is being updated
  - **Confirm Cancellation Button**: Enhanced cancellation dialog with loading state and automatic modal closure when process completes successfully
  - **Error Handling**: Implemented proper error handling in cancellation dialog that shows error messages without closing modal on failure
  - **State Management**: Used Consumer pattern for accessing ViewModel state and proper Provider pattern for reactive UI updates
  - **Type Safety**: Maintained proper type safety with Future<void> callback signatures and comprehensive error handling
  - **Files Modified**: 
    - `lib/counselorscreen/state/counselor_scheduled_appointments_viewmodel.dart` - Added loading state properties and management
    - `lib/counselorscreen/widgets/appointments_cards.dart` - Implemented Mark Complete button loading state
    - `lib/counselorscreen/widgets/cancellation_reason_dialog.dart` - Enhanced with loading state and auto-close functionality
    - `lib/counselorscreen/counselor_scheduled_appointments_screen.dart` - Updated async callback handling
  - **Impact**: Users now see clear loading indicators during appointment status updates and cancellation processes, with automatic modal closure upon successful completion

## Done (Oct 19, 2025)
- **Student Profile Screen Navigation Routes Fix** - Fixed critical navigation route errors in student_profile_screen.dart where routes like '/student-dashboard', '/my-appointments' were not found, updated all navigation routes to use proper '/student/' prefix format matching the existing routing system (e.g., '/student/dashboard', '/student/schedule-appointment', '/student/my-appointments', '/student/follow-up-sessions', '/student/announcements'), corrected bottom navigation bar currentIndex from 3 to 0 to highlight Home button instead of Follow-up Sessions button since profile screen is accessed from home, updated all drawer navigation methods to use correct route format, fixed logout navigation to use pushNamedAndRemoveUntil for proper route clearing, maintained all existing functionality while ensuring proper navigation flow, follows Flutter best practices with proper route management and navigation patterns.
- **Student Profile Screen UI Consistency Update** - Updated student_profile_screen.dart to use the same header and navigation footer as student_dashboard.dart for consistent UI/UX across the application, replaced custom _buildHeader() method with shared AppHeader widget from ../widgets/app_header.dart, added ModernBottomNavigationBar from ../widgets/bottom_navigation_bar.dart with proper navigation handling for all student screens, implemented StudentNavigationDrawer from widgets/navigation_drawer.dart with complete navigation methods for announcements, schedule appointment, my appointments, profile, and logout, added drawer state management with _isDrawerOpen boolean and toggle/close methods, implemented proper navigation routing using Navigator.pushNamed and Navigator.pushReplacementNamed for seamless screen transitions, maintained all existing PDS functionality and profile management features while improving overall app consistency, follows Flutter best practices with proper state management and navigation patterns.
- **Student PDS PWD Proof Preview State Management Fix** - Fixed critical issue where PWD proof preview modal was showing existing saved file instead of newly selected file due to improper state management, removed local selectedFile variable from _buildFileUploadField method and replaced with ViewModel's selectedPwdProofFile state for proper persistence across widget rebuilds, removed StatefulBuilder wrapper since ViewModel state changes trigger parent widget rebuilds automatically, fixed all indentation issues and syntax errors in _buildFileUploadField method, removed unnecessary null assertion operators (!) since selectedFile is already null-checked in if conditions, implemented proper state management where newly selected files take priority over existing saved files in preview modal, follows Flutter best practices with proper type safety and state management patterns.
- **Student PDS PWD Proof Preview Priority Fix** - Fixed PWD proof preview modal to prioritize newly selected files over existing saved files when previewing, modified _buildFileUploadField method to only show existing PWD proof file when no new file is selected (added selectedFile == null condition), enhanced PDF preview support for both newly selected files and existing files with proper PDF icon, file information display, and placeholder "Open PDF" button, implemented proper file type detection and preview handling for all supported file types including images, videos, PDFs, and other documents, maintained existing functionality for all other file types while ensuring newly selected files take priority in preview, follows Flutter best practices with proper type safety and comprehensive file handling.
- **Student PDS PWD Proof File Upload Endpoint Fix** - Fixed critical 404 error when uploading PWD proof files by changing approach from separate file upload endpoint to integrated multipart request with existing PDS save endpoint, removed non-existent 'student/pds/upload-pwd-proof' endpoint usage and instead send PWD proof files as multipart data with PDS save request, enhanced Session class post method to support multipart requests with files parameter, modified PDS ViewModel savePDSData method to include file upload as part of PDS save request matching backend handlePWDProofUpload method expectations, removed separate uploadPwdProofFile method and uploadFile method from Session class, implemented proper file handling with error checking and debug logging, follows Flutter best practices with proper type safety and comprehensive error handling.
- **Student PDS Email Input and PWD Proof File Saving Fixes** - Fixed email input field to be properly read-only (disabled) in PDS form by changing enabled parameter from true to false, implemented comprehensive PWD proof file upload functionality by adding file upload support to PDS ViewModel with setPwdProofFile method and uploadPwdProofFile method, added uploadFile method to Session class for multipart file uploads with proper cookie handling, modified savePDSData method to upload PWD proof files before saving PDS data and include file path in payload, updated file selection handlers to pass selected files to PDS ViewModel for proper saving, fixed all linter warnings for BuildContext usage across async gaps by storing ScaffoldMessenger before async operations, follows Flutter best practices with proper type safety and comprehensive error handling.
- **Student PDS PWD Proof FilePicker Initialization Fix** - Fixed critical LateInitializationError in PWD proof file picker functionality where FilePicker._instance field was not initialized, implemented robust error handling with try-catch blocks around FilePicker.platform.pickFiles() calls, added fallback mechanism to image_picker for images when file_picker fails, created PlatformFile conversion from XFile for consistency in file handling, enhanced file extension detection to handle both extension property and filename-based extraction, implemented comprehensive error logging and user feedback for file selection failures, ran flutter clean and flutter pub get to ensure proper plugin registration, follows Flutter best practices with proper type safety and graceful error handling.
- **Student PDS PWD Proof URL Slash Fix** - Fixed critical missing forward slash issue in PWD proof URL construction where URLs were incorrectly constructed as 'http://10.0.2.2/counselign/publicPhotos/pwd_proofs/...' instead of 'http://10.0.2.2/counselign/public/Photos/pwd_proofs/...', enhanced _buildFileUrl method to properly handle URL concatenation by ensuring base URL ends with slash and file path doesn't start with slash, added comprehensive debugging logs to track URL construction steps including clean base URL and clean file path, implemented robust URL construction logic that handles both cases where base URL may or may not end with slash and file path may or may not start with slash, follows Flutter best practices with proper type safety and comprehensive error handling.
- **Student PDS PWD Proof Enhanced File Support** - Fixed critical URL construction issue in PWD proof preview functionality where image URLs were incorrectly constructed with 'index.phpPhotos' causing "Error loading image File may not exist or be corrupted" errors, corrected URL construction by removing '/index.php' from base URL and constructing proper file URLs using new _buildFileUrl method, expanded PWD proof file input to support comprehensive file types including images (jpg, jpeg, png, gif), PDF documents, Word documents (doc, docx), Excel spreadsheets (xls, xlsx), video files (mp4, avi, mov), and text documents (txt, rtf), replaced image_picker with file_picker package for broader file type support, updated file preview functionality to handle all supported file types with appropriate icons and colors, added VideoPlayerWidget for video file previews with placeholder implementation, enhanced file type detection and description methods, implemented proper error handling and debugging logs for file URL construction, follows Flutter best practices with proper type safety and comprehensive file handling.
- **Student PDS PWD Proof Preview URL Fix** - Fixed critical URL construction issue in PWD proof preview functionality where image URLs were incorrectly constructed with double slashes, causing "Error loading image File may not exist or be corrupted" errors, corrected URL construction from '${ApiConfig.currentBaseUrl}/$fileData' to '${ApiConfig.currentBaseUrl}$fileData' to match backend MVC implementation exactly, added comprehensive debugging logs to track file paths and constructed URLs for troubleshooting, enhanced error handling with detailed error information including constructed URLs, implemented proper file path handling matching JavaScript implementation pattern, follows Flutter best practices with proper type safety and error handling.
- **Student PDS PWD Proof Preview Implementation** - Implemented comprehensive PWD proof file preview functionality in Flutter student profile screen matching the backend MVC implementation exactly, added PWD proof display box with file type detection, thumbnail preview, file information display, and view/download buttons for existing files, created responsive file preview modal with support for images (jpg, jpeg, png, gif), PDFs, Word documents, Excel files, and other file types with appropriate icons and colors, integrated existing PWD proof file display with new file upload functionality while maintaining all original features, implemented proper error handling for file loading failures and network issues, added file type descriptions and appropriate Material Design icons for different file extensions, follows Flutter best practices with proper type safety, responsive design, and clean code architecture.
- Replaced deprecated `withOpacity` usages with `withValues` across multiple screens.
- Migrated qr_flutter color properties to `eyeStyle`/`dataModuleStyle` and verified scannability.
- Guarded BuildContext after awaits using `context.mounted` in viewmodels.
- Fixed casing: `newPasswordErrorField`.
- Token dialogs readability: visible characters, tighter padding, taller cells.
- Replaced `print` with `debugPrint` in models.

## Done (Dec 19, 2024) - Student PDS Date Format Parsing Fix
- **CRITICAL FIX**: Fixed FormatException error in PDS save functionality:
  - **Root Cause**: Date format mismatch between UI display (dd/MM/yyyy) and backend storage (yyyy-MM-dd)
  - **Error**: "Trying to read / from 2005-03-13 at 5" prevented PDS data from being saved
  - **Solution**: Implemented robust date format handling with automatic detection and conversion
  - **Technical Implementation**:
    - Added `_formatDateForUI()` method to convert backend format to UI format for display
    - Added `_formatDateForBackend()` method to convert UI format to backend format for saving
    - Used regex pattern matching to automatically detect date formats
    - Added comprehensive error handling and debug logging
  - **Format Support**: Handles both dd/MM/yyyy (UI) and yyyy-MM-dd (backend) formats seamlessly
  - **Error Handling**: Returns empty string for unrecognized formats with debug logging
  - **Type Safety**: Maintained proper null safety and error handling throughout
  - **Files Modified**: `lib/studentscreen/state/pds_viewmodel.dart`
  - **Impact**: PDS save functionality now works correctly without date parsing errors

## Done (Dec 19, 2024) - Counselor Follow-up Sessions Column Overflow Fix
- **LAYOUT FIX**: Fixed RenderFlex overflow of 2.7 pixels in Column widget at line 277 of counselor_follow_up_sessions_screen.dart:
  - **Root Cause**: Column widget in appointment cards was slightly too tall for the GridView's childAspectRatio of 1.2
  - **Overflow Error**: "RenderFlex overflowed by 2.7 pixels on the bottom" in appointment card layout
  - **Solution**: Added mainAxisSize: MainAxisSize.min to Column widget and adjusted childAspectRatio from 1.2 to 1.15
  - **Layout Optimization**: Provided more height for appointment cards while maintaining responsive design
  - **Functionality Preserved**: Maintained all existing functionality while ensuring proper layout constraints
  - **Type Safety**: Follows Flutter best practices with proper layout management and responsive design
  - **No Linter Errors**: Successfully tested with flutter analyze showing no issues
  - **Files Modified**: 
    - `lib/counselorscreen/counselor_follow_up_sessions_screen.dart` - Fixed Column overflow in appointment cards

## Done (Dec 19, 2024) - Physical Device API Configuration Fix
- **CRITICAL FIX**: Fixed connection timeout issue when testing on physical Android device:
  - **Root Cause**: API configuration was using emulatorUrl (10.0.2.2) for Android platform instead of deviceUrl (192.168.18.63)
  - **Connection Error**: "Connection timed out" error preventing login functionality on physical devices
  - **Solution**: Updated currentBaseUrl getter to return deviceUrl for Android platform detection
  - **Network Connectivity**: Ensured proper network connectivity between physical device and XAMPP server
  - **Functionality Preserved**: Maintained all existing functionality while fixing network connectivity issues
  - **Type Safety**: Follows Flutter best practices with proper API configuration and environment detection
  - **No Linter Errors**: Successfully tested with flutter analyze showing no issues
  - **Files Modified**: 
    - `lib/api/config.dart` - Updated Android platform detection to use deviceUrl for physical device testing

## Done (Dec 19, 2024) - Export Filters Dialog Button Layout Enhancement and Text Overflow Protection
- **UI ENHANCEMENT**: Modified ExportFiltersDialog in counselor reports screen to arrange buttons in two rows as requested:
  - **First Row Layout**: "Clear All" and "Clear Dates" text buttons arranged horizontally with proper spacing and icons
  - **Second Row Layout**: "Export PDF" and "Export Excel" elevated buttons arranged horizontally with their respective colors and icons
  - **Button Distribution**: Used Row widgets with Expanded children to prevent RenderFlex overflow and ensure proper button distribution
  - **Overflow Fix**: Fixed 10-pixel overflow issue by wrapping buttons in Expanded widgets and using proper layout constraints
  - **Text Overflow Protection**: Added TextOverflow.ellipsis to all button text labels to prevent text overflow and ensure proper content alignment on single lines
  - **Visual Separation**: Added 8px spacing between buttons and 12px spacing between rows for clear visual separation
  - **Functionality Preserved**: Maintained all existing functionality including button states, export logic, and dialog behavior
  - **Type Safety**: Follows Flutter best practices with proper layout constraints and responsive design
  - **No Linter Errors**: Successfully tested with flutter analyze showing no issues
  - **Files Modified**: 
    - `lib/counselorscreen/widgets/export_filters_dialog.dart` - Enhanced button layout with two-row arrangement, overflow fix, and text overflow protection

## Done (Dec 19, 2024) - Contact Dialog Theme Consistency
- **UI ENHANCEMENT**: Updated contact dialog to match the exact theme and design of other landing screen modals:
  - **Consistent Styling**: Applied transparent background, rounded corners (24px), shadow effects matching login dialog
  - **Gradient Icon Header**: Added gradient icon header with contact_support icon and proper styling
  - **Close Button Styling**: Updated close button with background container matching other modals
  - **Form Field Enhancement**: Enhanced form fields with prefix icons and consistent spacing (20px)
  - **Error Message Styling**: Implemented error message styling with container background and icon
  - **Button Styling**: Updated send button to match login dialog with proper colors (#060E57) and dimensions (52px height)
  - **Functionality Preserved**: Maintained all original functionality including animations, form validation, loading states, and API integration
  - **Type Safety**: Follows Flutter best practices with proper type safety and responsive design patterns
  - **Files Modified**: 
    - `lib/landingscreen/dialogs/contact_dialog.dart` - Complete theme consistency update with landing screen modals

## Done (Dec 19, 2024) - Login Dialog Layout Enhancement
- **UI ENHANCEMENT**: Modified login dialog to place "Forgot Password?" and "Create Account" text buttons in a single row with responsive behavior:
  - **Single Row Layout**: Replaced LayoutBuilder-based conditional layout with consistent single-row layout using Row widget
  - **Overflow Protection**: Implemented proper overflow handling using Expanded widgets and TextOverflow.ellipsis for text content
  - **Space Optimization**: Reduced horizontal padding from 16px to 8px for better space utilization
  - **Text Alignment**: Added textAlign.center and overflow protection for text content
  - **Responsive Design**: Ensured no pixel overflow issues across different screen sizes
  - **Functionality Preserved**: Maintained all existing functionality including loading states and navigation callbacks
  - **Code Cleanup**: Removed unused `_buildLinks()` method after refactoring
  - **Type Safety**: Follows Flutter best practices with proper type safety and responsive design patterns
  - **Files Modified**: 
    - `lib/landingscreen/dialogs/login_dialog.dart` - Enhanced button layout with single-row responsive design

## Done (Oct 20, 2025)
- Fixed vertical render overflow on student `AnnouncementsScreen` by wrapping the main content `Column` in `SingleChildScrollView` with bouncing physics. No logic changes.
- Counselor dashboard restructure: Updated Flutter counselor dashboard to match backend MVC structure with messages and appointments cards, removed Scheduled Appointments and Follow-up Sessions from navigation drawer, moved them to bottom navigation as footer navigation, implemented recent appointments functionality in viewmodel.
- Counselor appointments management implemented:
  - Added `CounselorAppointmentsScreen` with full management (search, filters, approve/reject/cancel with reason modal)
  - Created `CounselorAppointment` model and `CounselorAppointmentsViewModel`
  - Wired `AppRoutes.counselorAppointments` and `AppRoutes.counselorAppointmentsViewAll` to the new screen
  - Manage button in recent appointments now opens the management screen

## Done (Dec 19, 2024)
- Fixed counselor dashboard navigation issue where it was redirecting to student pages.
- Created complete counselor screen structure matching backend MVC:
  - Counselor announcements screen with API integration
  - Counselor scheduled appointments screen with status management
  - Counselor follow-up sessions screen with notes functionality
  - Counselor profile screen with availability management
- Updated counselor navigation drawer and bottom navigation to use proper counselor routes.
- Implemented counselor viewmodels with proper API integration for all screens.
- Fixed counselor screen wrapper to use counselor-specific routes instead of student routes.
- Added proper logout functionality using session cookie clearing.
- Counselor dashboard UI improvements:
  - Removed chat popup button from profile section
  - Fixed profile picture display with proper network image handling and fallback
  - Rearranged dashboard cards to stack vertically (messages first row, appointments second row)
  - Fixed bottom navigation to show Schedule and Follow-up Sessions buttons
  - Corrected API endpoints for messages fetching to use proper backend routes
- Counselor dashboard backend integration fixes:
  - Fixed profile data parsing to match backend response format (username, email, profile_picture fields)
  - Corrected messages API endpoint to use action=get_dashboard_messages parameter with limit=2
  - Updated Message model instantiation to include senderName field from conversations data
  - Verified bottom navigation is properly configured with isStudent: false parameter
  - Confirmed scheduled appointments and follow-up sessions screens use correct bottom nav indices
- Counselor dashboard debugging and final fixes:
  - Added comprehensive debug logging for profile and messages API calls to identify connection issues
  - Updated bottom navigation labels from 'Schedule'/'Follow-up' to 'Scheduled Appointments'/'Follow-up Sessions'
  - Fixed null safety issues in debug logging statements
  - Confirmed all API endpoints and navigation routes are properly configured
  - Added debug prints to track API response status and data for troubleshooting
- Counselor dashboard message display improvements:
  - Updated message display to show sender name matching backend MVC format
  - Added 'Student: [name]' prefix as first line in message cards
  - Maintained message text and received date display
  - Matches backend counselor dashboard message display format
- Counselor dashboard notifications dropdown implementation:
  - Added complete notifications dropdown widget to counselor dashboard screen
  - Fixed API endpoint from '/counselor/notifications/get' to '/counselor/notifications'
  - Corrected response parsing from 'success: true' to 'status: success'
  - Added comprehensive debug logging for notifications API calls
  - Implemented positioned notifications dropdown with proper styling and close functionality
  - Notifications dropdown now shows when clicked and displays notification list
- Counselor dashboard notifications data parsing fix:
  - Fixed NotificationModel.fromJson to handle backend response format correctly
  - Added fallback for id field using related_id from backend notifications
  - Improved isRead field parsing to handle string '1' values
  - Notifications dropdown now properly displays appointment notifications from backend
  - Backend notifications structure: type='appointment', title='Pending Appointment', message with student details
- Counselor dashboard profile display fix:
  - Fixed profile name display to use user_id instead of username to match backend JavaScript implementation
  - Added comprehensive debug logging for profile and notifications API calls to identify connection issues
  - Profile display now shows actual counselor user ID instead of generic 'Counselor' text
  - Backend JavaScript uses data.user_id for display name, not data.username
  - Added debug logging to track API calls and identify session/authentication issues
- Counselor dashboard navigation enhancement:
  - Added Home button to counselor bottom navigation bar as first item (index 0)
  - Updated navigation indices: Home (0), Scheduled Appointments (1), Follow-up Sessions (2)
  - Updated all counselor screens to use correct bottom navigation indices
  - Home button navigates to counselor dashboard (/counselor/dashboard)
  - Maintained existing functionality while adding new Home navigation option
- Counselor screen layout fixes:
  - Fixed rendering exceptions in counselor scheduled appointments, follow-up sessions, and announcements screens
  - Removed Expanded widgets from Column children that were inside SingleChildScrollView
  - Replaced with SizedBox with fixed height for loading/empty states
  - Used ListView.builder with shrinkWrap: true and NeverScrollableScrollPhysics for content lists
  - Resolved "RenderFlex children have non-zero flex but incoming height constraints are unbounded" errors
  - Fixed "RenderBox was not laid out" errors in counselor navigation screens
- Counselor dashboard data display fixes:
  - Fixed type conversion errors in CounselorProfile and NotificationModel models
  - Added _parseInt helper methods to handle String to int conversion for id and relatedId fields
  - Updated profile data parsing to use username instead of user_id for display name
  - Added _buildImageUrl helper method to construct full URLs for profile pictures from backend relative paths
  - Resolved "type 'String' is not a subtype of type 'int'" errors in profile and notifications data parsing
  - Profile picture, username, and last login now display correctly in counselor dashboard
  - Notifications dropdown now displays actual notification data from backend
- Counselor profile picture URL fix:
  - Fixed profile picture display issue by correcting URL construction in _buildImageUrl method
  - Removed /index.php from base URL when constructing image URLs to prevent malformed URLs
  - Added debug logging for profile picture URL construction
  - Profile pictures now load correctly from backend relative paths instead of showing generic silhouette

## Done (Dec 19, 2024) - Modern Drawer Navigation
- Landing page drawer navigation modernization:
  - Completely redesigned drawer with modern gradient background and visual hierarchy
  - Enhanced header section with logo, branding, and professional styling
  - Redesigned navigation items with subtitles, modern icons, and improved spacing
  - Added smooth animations and staggered transitions for drawer opening and item appearance
  - Implemented responsive design for mobile, tablet, and desktop screen sizes
  - Added visual feedback with hover effects and proper Material Design interactions
  - Maintained all existing functionality while significantly improving user experience
  - Used modern Flutter APIs (Color.withValues) and proper animation patterns
  - No linting errors or breaking changes to existing functionality
- Landing page drawer layout fix:
  - Fixed "RenderFlex children have non-zero flex but incoming width constraints are unbounded" error
  - Replaced Expanded widgets with Flexible widgets in header Row layout to prevent unbounded width constraints
  - Fixed footer Row layout by replacing Expanded with Flexible for text content
  - Resolved layout rendering exceptions that were preventing drawer from displaying properly
  - Maintained all modern design elements while ensuring proper Flutter layout constraints
  - Drawer now renders correctly without layout errors on all screen sizes
- Landing page drawer modal interaction fix:
  - Fixed black screen issue when opening modals (contact, signup, login) from drawer
  - Removed duplicate Navigator.pop() calls that were causing double pop operations
  - Removed Navigator.pop() from _buildModernDrawerItem onTap callback
  - Let landing screen handle drawer closing through its own callback functions
  - Eliminated black overlay effects that were appearing after modal closure
  - Modals now display properly without background interference from drawer gradient

## Done (Dec 19, 2024) - Counselor Scheduled Appointments Implementation
- Counselor scheduled appointments complete Flutter implementation:
  - Created comprehensive implementation that perfectly mirrors backend MVC counselor/appointments/scheduled functionality
  - Implemented two-column responsive layout with appointments table on left and sidebar with weekly schedule and mini calendar on right
  - Created CounselorScheduledAppointment and CounselorSchedule models with proper JSON parsing matching backend data structure
  - Updated CounselorScheduledAppointmentsViewModel to use correct API endpoints (/counselor/appointments/scheduled/get and /counselor/appointments/schedule) with proper error handling and loading states
  - Implemented AppointmentsTable widget with all required columns (Student ID, Name, Appointed Date, Time, Consultation Type, Purpose, Status, Action)
  - Created WeeklySchedule widget displaying counselor availability days and times with proper time formatting
  - Built MiniCalendar widget with appointment date highlighting, navigation controls, and legend
  - Added CancellationReasonDialog for appointment cancellation with reason input
  - Implemented Mark Complete and Cancel actions for approved appointments with proper API integration
  - Added comprehensive responsive design for mobile, tablet, and desktop screens
  - Ensured all functionality matches backend MVC implementation including data structure, API endpoints, UI layout, and user interactions
  - No linting errors and follows Flutter best practices with proper type safety and error handling

## Done (Dec 19, 2024) - Counselor Follow-up Sessions Implementation
- Counselor follow-up sessions complete Flutter implementation:
  - Created comprehensive implementation that perfectly mirrors backend MVC counselor/follow-up functionality
  - Implemented completed appointments display with search functionality matching backend behavior
  - Created CompletedAppointment, FollowUpSession, and CounselorAvailability models with proper JSON parsing
  - Updated CounselorFollowUpSessionsViewModel with complete API integration for all follow-up operations
  - Implemented follow-up sessions modal with proper button state management (create new vs create next follow-up)
  - Added create follow-up modal with date/time selection and counselor availability integration
  - Implemented cancel follow-up modal with reason input and proper validation
  - Added mark complete and cancel follow-up functionality with proper API calls using Session utility
  - Implemented responsive design for mobile, tablet, and desktop screens with proper grid layouts
  - Ensured all functionality matches backend MVC implementation including button states, API endpoints, and user interactions
  - Fixed all linter errors and follows Flutter best practices with proper type safety and error handling
  - Button state logic: "Create New Follow-up" only active when no follow-up sessions exist, "Create Next Follow-up" only active when previous session is completed or cancelled

## Done (Dec 19, 2024) - Weekly Schedule Overflow Fix
- Counselor scheduled appointments weekly schedule overflow fix: Fixed "RenderFlex overflowed by 65 pixels on the right" error in WeeklySchedule widget by replacing MainAxisAlignment.spaceBetween with flexible layout using Expanded widget for time text, added fixed width (80px) for day column and flexible width for time column with proper text alignment, implemented crossAxisAlignment.start for proper vertical alignment, resolved horizontal overflow issue that was preventing proper display of long time schedules in weekly consultation schedules modal, maintained all existing functionality while ensuring proper Flutter layout constraints for responsive text display.

## Done (Dec 19, 2024) - Time Format Conversion Optimization
- Counselor and student time format conversion optimization: Removed unnecessary 24-hour to 12-hour time conversion functions across all models since database already stores time_scheduled in 12-hour format with proper meridian labels (AM/PM), simplified formattedTime getters in CounselorSchedule, CounselorScheduledAppointment, CounselorAvailability, FollowUpAppointment models and FollowUpSessionsViewModel to directly return time values without conversion, eliminated redundant _formatSingleTime and _convertTo12Hour helper methods that were performing unnecessary conversions, improved performance by removing time parsing and formatting operations, maintained all existing functionality while ensuring proper time display throughout the application, updated 5 model files and 1 viewmodel file to handle pre-formatted 12-hour time values from backend database.

## Done (Dec 19, 2024) - Counselor Dashboard Button Icons Enhancement
- Counselor dashboard appointments card button icons enhancement: Added appropriate icons to "View All" and "Manage" buttons in the Recent Appointments Card using ElevatedButton.icon instead of ElevatedButton, implemented Icons.list_alt for "View All" button to represent list/viewing functionality, implemented Icons.settings for "Manage" button to represent management/configuration functionality, maintained all existing button styling, colors, and functionality while improving visual clarity and user experience, enhanced button accessibility with clear visual indicators for different actions, updated counselor dashboard screen to provide better visual feedback for appointment management actions.

## Done (Dec 19, 2024) - Student Appointments Card UI Implementation
- Student appointments table to cards conversion: Replaced DataTable with responsive appointment cards in student my_appointments_screen.dart, created reusable AppointmentCard widget with proper styling and responsive design for mobile, tablet, and desktop screen sizes, implemented card-based layout with status badges, appointment details, and action buttons, maintained all existing functionality including filtering, editing, and status management, enhanced user experience with modern card-based UI while preserving all original features, removed unused _buildStatusBadge and _buildTableHeader methods, added proper screen size detection and responsive design patterns, ensured type safety and Flutter best practices throughout the implementation.

## Done (Dec 19, 2024) - Follow-up Sessions Page Layout Fix
- **LAYOUT FIX**: Fixed follow-up sessions page layout and enhanced appointment card display:
  - **Pending Section Position**: Moved "Appointment with a Pending Follow-up" section above the search bar instead of below it, matching the backend MVC layout exactly
  - **Purpose Display**: Added purpose field display to all completed appointment cards with flag icon and proper styling
  - **Layout Restructure**: Restructured the main content layout to show pending section first, then search bar, then regular appointments
  - **Consumer Widget**: Used Consumer widget for proper state management of pending section visibility
  - **Visual Consistency**: Maintained all existing styling and functionality while improving layout structure
  - **Files Modified**: 
    - `lib/studentscreen/follow_up_sessions_screen.dart` - Fixed layout structure and added purpose display to appointment cards

## Done (Dec 19, 2024) - Student Follow-up Sessions Page Enhancement
- **MAJOR FEATURE**: Enhanced student follow-up sessions page to match backend MVC functionality exactly:
  - **Follow-up Count Display**: Added follow-up count badges showing total number of follow-up sessions for each completed appointment
  - **Pending Warning Indicators**: Added orange gradient badges with warning icons for appointments with pending follow-up sessions
  - **Sorted Display**: Implemented proper sorting with pending appointments displayed first, then regular appointments by date
  - **Separate Pending Section**: Created dedicated pending section above search bar with orange gradient background and warning styling
  - **Debounced Search**: Implemented 300ms debounced search functionality to avoid excessive API calls
  - **Enhanced Appointment Cards**: Redesigned appointment cards with gradient badges, proper indicators, and improved visual hierarchy
  - **API Integration**: Updated Appointment model to include followUpCount, pendingFollowUpCount, and nextPendingDate fields
  - **Responsive Design**: Maintained responsive design with proper mobile/desktop scaling
  - **Visual Consistency**: Ensured design matches backend MVC implementation exactly as shown in reference files
  - **Files Modified**: 
    - `lib/studentscreen/models/appointment.dart` - Added follow-up count fields to Appointment model
    - `lib/studentscreen/state/follow_up_sessions_viewmodel.dart` - Enhanced with debounced search, sorting, and separation logic
    - `lib/studentscreen/follow_up_sessions_screen.dart` - Complete UI overhaul with pending section, enhanced cards, and proper indicators

## Done (Dec 19, 2024) - Consent Accordion and Acknowledgment Implementation
- **MAJOR FEATURE**: Implemented consent accordion and acknowledgment checkboxes for student schedule appointment screen matching backend MVC functionality exactly:
  - **Consent Accordion**: Created `ConsentAccordion` widget (`lib/studentscreen/widgets/consent_accordion.dart`) with expandable counseling informed consent form containing all legal terms and conditions
  - **Acknowledgment Section**: Created `AcknowledgmentSection` widget (`lib/studentscreen/widgets/acknowledgment_section.dart`) with required checkboxes for consent acceptance
  - **State Management**: Added consent validation logic to `ScheduleAppointmentViewModel` with state management for consent checkboxes and error handling
  - **Form Integration**: Integrated consent accordion and acknowledgment section into `ScheduleAppointmentScreen` with proper form validation
  - **Backend Integration**: Implemented consent data submission in appointment form with backend API integration
  - **Validation Logic**: Added consent validation preventing form submission without both checkboxes checked
  - **Error Handling**: Implemented proper error handling and validation messages for consent requirements
  - **Form Reset**: Added consent reset functionality in form reset method
  - **Responsive Design**: Added responsive design with mobile and desktop layouts matching backend MVC styling
  - **UI Styling**: Styled components to match backend MVC design with gradient headers and proper spacing
  - **Legal Content**: Included complete counseling informed consent form with terms, conditions, and confidentiality dimensions
  - **User Experience**: Implemented smooth accordion expansion with proper content organization and readability

## Done (Dec 19, 2024) - PDS Reminder Modal Implementation
- **MAJOR FEATURE**: Implemented PDS reminder modal for student dashboard matching backend MVC functionality exactly:
  - **Modal Widget**: Created `PdsReminderModal` (`lib/studentscreen/widgets/pds_reminder_modal.dart`) with 20-second auto-close timer, dismiss/update buttons, and responsive design
  - **State Management**: Added PDS reminder state management to `StudentDashboardViewModel` with session-based display logic using SharedPreferences
  - **Session Logic**: Implemented session-based reminder logic that only shows modal on initial login (not on page navigation) using SharedPreferences key 'pdsReminderShown'
  - **UI Design**: Added gradient header styling (#060E57, #0A1875), timer progress bar, and modern UI design matching backend MVC implementation exactly
  - **Animations**: Added proper animation effects with scale and opacity transitions for modal appearance using AnimationController
  - **Integration**: Integrated PDS reminder modal into `StudentDashboard` screen with proper state management and navigation
  - **Functionality**: Modal includes "Update Now" button that navigates to profile page and "Dismiss" button that closes modal and marks as shown
  - **Auto-close**: Auto-closes after 20 seconds with visual countdown timer and progress bar
  - **Responsive Design**: Responsive design that adapts to mobile and desktop screen sizes
  - **Cleanup**: Implemented proper cleanup and disposal of timers and animation controllers
  - **Debug Logging**: Added debug logging for troubleshooting reminder display logic
  - **Type Safety**: Implemented with proper error handling, type-safe coding practices, and comprehensive debug logging throughout
  - **Files Modified**: 
    - `lib/studentscreen/widgets/pds_reminder_modal.dart` - New PDS reminder modal widget
    - `lib/studentscreen/state/student_dashboard_viewmodel.dart` - Added PDS reminder state management and session logic
    - `lib/studentscreen/student_dashboard.dart` - Integrated PDS reminder modal into dashboard screen

## Done (Dec 19, 2024) - Counselor Schedule Display Feature Implementation & Enhancement
- **MAJOR FEATURE**: Implemented and enhanced counselor schedule display feature in Flutter student appointment pages with calendar drawer integration:
  - **API Integration**: Added `fetchCounselorSchedules()` method to both `ScheduleAppointmentViewModel` and `MyAppointmentsViewModel` to call `/student/get-counselor-schedules` endpoint
  - **Model Creation**: Created `CounselorSchedule` model (`lib/studentscreen/models/counselor_schedule.dart`) with proper JSON parsing for counselor schedule data including counselor ID, name, degree, and time slots
  - **UI Enhancement**: Enhanced calendar drawers in both `schedule_appointment_screen.dart` and `my_appointments_screen.dart` to display counselor schedules organized by weekday (Monday-Friday only)
  - **Layout Optimization**: Changed calendar drawer flex proportions from 2:3 to 3:2 (calendar:counselor schedules) to prioritize calendar's full height as requested
  - **Colorful Weekday Cards**: Added gradient backgrounds for each weekday matching backend MVC design:
    - Monday: Red gradient (#FF6B6B to #EE5A52)
    - Tuesday: Teal gradient (#4ECDC4 to #44A08D) 
    - Wednesday: Blue-green gradient (#45B7D1 to #96C93D)
    - Thursday: Pink gradient (#F093FB to #F5576C)
    - Friday: Blue gradient (#4FACFE to #00F2FE)
  - **Compact Design**: Reduced card margins, padding, and font sizes for more compact counselor schedule display
  - **Enhanced Time Badges**: Updated time slot badges with light blue background (#E7F5FF) and blue border (#D0EBFF) matching backend styling
  - **Responsive Design**: Implemented responsive design with proper mobile/desktop scaling, weekday cards with counselor information, time slot badges, and loading/error states
  - **User Experience**: Students can now view all counselors and their availability by weekday within the calendar drawer while maintaining existing page design and functionality
  - **Type Safety**: Implemented with proper error handling, type-safe coding practices, and comprehensive debug logging throughout
  - **Visual Consistency**: Ensured design matches backend MVC implementation exactly as shown in reference files
  - **Files Modified**: 
    - `lib/studentscreen/models/counselor_schedule.dart` - New model for counselor schedule data
    - `lib/studentscreen/state/schedule_appointment_viewmodel.dart` - Added API integration and schedule fetching
    - `lib/studentscreen/state/my_appointments_viewmodel.dart` - Added API integration and schedule fetching
    - `lib/studentscreen/schedule_appointment_screen.dart` - Enhanced calendar drawer with counselor schedules section and colorful weekday cards
    - `lib/studentscreen/my_appointments_screen.dart` - Enhanced calendar drawer with counselor schedules section and colorful weekday cards

## Done (Dec 19, 2024) - Student Pending Appointment Button Layout and Loading States Enhancement
- **LAYOUT FIX**: Fixed RenderFlex overflow error of 21 pixels in pending appointment action buttons row:
  - **Root Cause**: Row widget containing action buttons was overflowing on smaller screens due to insufficient space constraints
  - **Overflow Error**: "RenderFlex overflowed by 21 pixels on the right" in pending appointment form action buttons
  - **Solution**: Implemented responsive LayoutBuilder with conditional layout based on screen size and available width
  - **Edit Mode Priority**: "Save Changes" and "Cancel Edit" buttons always stay in one row regardless of screen size to maintain UX consistency
  - **Non-Edit Mode Priority**: "Enable Edit" and "Cancel" buttons always stay in one row regardless of screen size to maintain UX consistency
  - **Button Constraints**: Wrapped all buttons in Flexible widgets with flex: 1 for equal space distribution in both edit and non-edit modes
  - **Button Sizing**: Added consistent padding (horizontal: 12, vertical: 8) for better button proportions
  - **Loading States**: Added comprehensive loading states to Update button and Confirm Cancellation button with proper state management
  - **Update Button Loading**: Shows circular progress indicator and "Updating..." text during appointment update process
  - **Cancel Button Loading**: Shows circular progress indicator and "Cancelling..." text during appointment cancellation process
  - **Automatic Modal Closure**: Cancellation dialog automatically closes after successful cancellation process
  - **Error Handling**: Proper error handling with loading state cleanup in finally blocks
  - **Context Safety**: Added proper context.mounted checks for all UI interactions after async operations
  - **Type Safety**: Follows Flutter best practices with proper layout management, loading states, and responsive design patterns
  - **No Linter Errors**: Successfully tested with flutter analyze showing no issues
  - **Files Modified**: 
    - `lib/studentscreen/my_appointments_screen.dart` - Fixed action buttons layout with responsive design, loading states, and automatic modal closure
    - `lib/studentscreen/state/my_appointments_viewmodel.dart` - Added setUpdatingAppointment and setCancellingAppointment methods for loading state management

## Done (Dec 19, 2024) - Critical Fix: Cancellation Dialog Crash
- **CRITICAL BUG FIX**: Fixed app crash when clicking Cancel button in pending appointment card:
  - **Root Cause**: Consumer<MyAppointmentsViewModel> in dialog was causing crash because dialog context doesn't have access to the Provider
  - **Error**: "Lost connection to device" - app crashed when opening cancellation dialog
  - **Solution**: Removed Consumer widget and used direct _viewModel reference from parent widget state
  - **StatefulBuilder**: Wrapped dialog in StatefulBuilder to enable reactive UI updates for loading states
  - **setState Calls**: Added setState(() {}) calls after loading state changes to trigger dialog rebuilds
  - **Loading State Management**: Maintained proper loading state with _viewModel.setCancellingAppointment()
  - **Context Safety**: All context.mounted checks preserved for safe UI operations
  - **Type Safety**: Follows Flutter best practices with proper state management patterns
  - **No Linter Errors**: Successfully tested with flutter analyze showing no issues
  - **Files Modified**: 
    - `lib/studentscreen/my_appointments_screen.dart` - Fixed cancellation dialog crash by removing Consumer and using StatefulBuilder

## Pending Follow-ups
- Periodic scan for new deprecations after package upgrades.
- Consider central utility for toast/snackbar to standardize UI messages.