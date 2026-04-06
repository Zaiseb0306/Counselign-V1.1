# Prompt Memory

Rule of thumb: Before responding to any prompt, always review all markdown files inside `memory-bank/` to ensure full context continuity.

---

## Entries

### 1) Prompt
- Text: "initialize the memory bank for the whole counselign dart project not the counselign MVC folder"
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: `pubspec.yaml`, `lib/main.dart`, `lib/routes.dart`, `lib/api/config.dart`, `README.md`
- Response summary: Created top-level `memory-bank/` with core docs and `.cursorrules` tailored to the Flutter client, excluding the MVC backend.
- Files modified:
  - `memory-bank/projectbrief.md` (created; entire file)
  - `memory-bank/productContext.md` (created; entire file)
  - `memory-bank/systemPatterns.md` (created; entire file)
  - `memory-bank/techContext.md` (created; entire file)
  - `memory-bank/activeContext.md` (created; entire file)
  - `memory-bank/progress.md` (created; entire file)
  - `memory-bank/.cursorrules` (created; entire file)
- Highlights: All listed files were newly created. Content covers scope, users, architecture, tech, current focus, progress, and working rules.

### 2) Prompt
- Text: "based on the memory bank, can you say there are parts in the flow of this code that would say fit the spaghetti coding?"
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: All `memory-bank/*.md`
- Response summary: Identified risks (hardcoded env URLs, lack of service layer, potential state leakage) and suggested mitigations (ApiClient, repositories, DTOs, DI, env flavors).
- Files modified: none
- Highlights: Advisory only; no code changes.

### 3) Prompt
- Text: "next question, where could be the backend process of the signup process?"
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: `Counselign(09-26-25)/app/Config/Routes.php`, `Counselign(09-26-25)/app/Controllers/Auth.php`, `Counselign(09-26-25)/app/Models/UserModel.php`
- Response summary: Located backend signup at `POST /auth/signup` handled by `App\Controllers\Auth::signup`, persisting via `App\Models\UserModel`.
- Files modified: none
- Highlights: Provided file/route references; no edits performed.

### 4) Prompt
- Text: "add a prompt_memory.md ... and the add rule of thumb ..."
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: Current session history and `memory-bank/` contents
- Response summary: Added `prompt_memory.md` with rule-of-thumb and backfilled entries 1–3.
- Files modified:
  - `prompt_memory.md` (created; entire file)
- Highlights: This file; created with structured entries and the standing rule.

### 5) Prompt
- Text: "for all the buttons in the landing page that involves having a backend process when clicked, make sure to add button loading animations ... make this future proof ..."
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: `lib/landingscreen/landing_screen.dart`, dialogs under `lib/landingscreen/dialogs/`, `lib/landingscreen/frontend/body.dart`
- Response summary: Implemented reusable `AsyncButton` and refactored landing dialogs to use it for consistent loading across backend-triggering actions.
- Files modified:
  - `lib/utils/async_button.dart` (created; entire file)
  - `lib/landingscreen/dialogs/login_dialog.dart` (replaced ElevatedButton/TextButtons with `AsyncButton` for Login, Forgot Password, Sign up actions)
  - `lib/landingscreen/dialogs/signup_dialog.dart` (replaced Sign Up and Back to Login buttons with `AsyncButton`)
  - `lib/landingscreen/dialogs/forgot_password_dialog.dart` (replaced Send Reset Code button with `AsyncButton`)
  - `lib/landingscreen/dialogs/code_entry_dialog.dart` (replaced Verify Code button with `AsyncButton`)
  - `lib/landingscreen/dialogs/verification_dialog.dart` (replaced Verify Account and Resend buttons with `AsyncButton`)
- Highlights:
  - Introduced `AsyncButton` for consistent `isLoading` state: shows spinner, disables press, keeps sizing.
  - Standardized color, padding, shape; customizable via constructor.

### 6) Prompt
- Text: "make the footer of the landing page will be consistent across all pages ... focus on implementing this function"
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: `lib/landingscreen/frontend/body.dart`, `lib/userscreen/user_dashboard.dart`
- Response summary: Created shared `AppFooter` and replaced local footers in landing body and user dashboard to ensure consistency.
- Files modified:
  - `lib/utils/app_footer.dart` (created; entire file)
  - `lib/landingscreen/frontend/body.dart` (imported `AppFooter`; replaced `buildFooter()` call)
  - `lib/userscreen/user_dashboard.dart` (imported `AppFooter`; replaced `_buildFooter` usage and removed its implementation)
- Highlights: Unified footer design, color, spacing, and social icon behavior across these pages.

### 7) Prompt
- Text: "please do the same for the counselor first, we'll do the same to the admin later"
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: `lib/counselorscreen/counselor_dashboard_screen.dart`, `lib/utils/app_footer.dart`
- Response summary: Replaced `CounselorFooter` with shared `AppFooter` for consistent footer across counselor dashboard.
- Files modified:
  - `lib/counselorscreen/counselor_dashboard_screen.dart` (imported `AppFooter`; replaced `CounselorFooter`)
- Highlights: Counselor screen now uses the same footer component as landing and user dashboards.

### 8) Prompt
- Text: "in the login process, add a proper error logging and error message ... not redirected to the dashboard ..."
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: `lib/landingscreen/state/landing_screen_viewmodel.dart`, `lib/utils/session.dart`, `lib/routes.dart`
- Response summary: Added structured logging and robust error messages in login; implemented role-based navigation (user/student → user dashboard, counselor → counselor dashboard, admin → admin dashboard).
- Files modified:
  - `lib/routes.dart` (added `navigateToCounselorDashboard`, `navigateToAdminDashboard` helpers)
  - `lib/landingscreen/state/landing_screen_viewmodel.dart` (enhanced `handleLogin` with logs, HTTP status checks, and role-based navigation)
- Highlights:
  - Logs include status code and response body for diagnostics.
  - User-facing errors distinguish server errors from invalid credentials and network errors.
  - Default fallback to user dashboard if role is missing/unknown to avoid being stuck on landing.

### 9) Prompt
- Text: "footer must always stay at the very bottom ... fix this footer across all dart pages (except landing page)"
- Date: 2025-10-05 (time not provided by environment)
- Context consulted: `lib/userscreen/*`, `lib/counselorscreen/counselor_dashboard_screen.dart`, `lib/servicesscreen/services_screen.dart`, `lib/utils/app_footer.dart`
- Response summary: Pinned shared `AppFooter` via `Scaffold.bottomNavigationBar` across user dashboard, user subpages, counselor dashboard, and services screen; removed in-body footer widgets so the footer always sticks to the bottom without extra space below and without covering/expanding content.
- Files modified:
  - `lib/userscreen/user_dashboard.dart` (moved footer to `bottomNavigationBar`, removed in-body footer)
  - `lib/userscreen/announcements_screen.dart` (added `bottomNavigationBar: const AppFooter()`, removed in-body footer)
  - `lib/userscreen/my_appointments_screen.dart` (added `bottomNavigationBar`, removed in-body footer)
  - `lib/userscreen/user_profile_screen.dart` (added `bottomNavigationBar`, removed in-body footer)
  - `lib/userscreen/schedule_appointment_screen.dart` (added `bottomNavigationBar`, removed in-body footer)
  - `lib/counselorscreen/counselor_dashboard_screen.dart` (added `bottomNavigationBar`, removed in-body footer)
  - `lib/servicesscreen/services_screen.dart` (added `bottomNavigationBar`, removed `ServicesFooter`)
- Highlights: Footer now reliably sits at the lowest layer with no extra bottom spacing and does not take over the entire screen; main content remains scrollable and unblurred.
