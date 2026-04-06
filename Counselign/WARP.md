# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This repo is a hybrid system:
- **Flutter frontend** (root `lib/`, `android/`, `ios/`, `web/`, `windows/`, etc.) for students, counselors, and admins.
- **CodeIgniter 4 backend** (`Counselign/`) providing MVC pages, REST-like endpoints, email, and database access.

The domain is a university counseling platform: students schedule and manage counseling appointments; counselors and admins manage operations, reports, follow-ups, and announcements.

## Important Project Docs & Rules

### Memory bank (authoritative context)

Before significant changes, consult the root `memory-bank/`:
- `projectbrief.md` – high-level product goals and scope.
- `productContext.md` – target users and core journeys.
- `activeContext.md` – most recent work, critical fixes, and current focus (especially around PDS, counselor reports, follow-up sessions, notifications, and Android toolchain/API config).
- `techContext.md` – stack, platform targets, API base URL configuration, and recent technical decisions (e.g., `API_BASE_URL` via `--dart-define`, Java 17 configuration).
- `systemPatterns.md` – backend/frontend flow patterns and endpoint notes.
- `progress.md` – timeline and status.

When you make non-trivial changes to flows, endpoints, or infrastructure, update at least:
- `memory-bank/activeContext.md` (what changed, why, next steps), and
- `memory-bank/techContext.md` and/or `memory-bank/systemPatterns.md` for new/changed APIs or architectural patterns.

There is a second `memory-bank/` under `Counselign/` focused on backend; prefer the **root** one for high-level guidance and keep them consistent when relevant.

### Assistant rule sets (Cursor/Qoder)

This repo already encodes assistant behavior; WARP should respect the spirit of these rules:

- `.cursor/rules/01-project-intelligence.mdc`
  - Memory bank files are **authoritative**; always read them first and keep them up to date after meaningful changes.
  - Prefer clear, explicit naming and small, incremental edits.

- `.cursor/rules/02-ci4-architecture.mdc`
  - CodeIgniter architecture: entry via `public/`, routing in `app/Config/Routes.php`, controllers in `app/Controllers`, models in `app/Models`, views in `app/Views`, config in `app/Config`.
  - Keep CI4 controllers thin: orchestrate requests, delegate to models/services, return views/JSON.
  - Centralize DB access in models; avoid raw queries in controllers/views.

- `.cursor/rules/05-flutter-project-structure.mdc`
  - `lib/main.dart` bootstraps the app; `lib/routes.dart` owns navigation.
  - Feature folders per role: `landingscreen/`, `studentscreen/`, `counselorscreen/`, `adminscreen/`, each with `models/`, `state/`, `widgets/` plus root screens.
  - Shared layers: `lib/api/` (HTTP clients and config), `lib/utils/` (helpers), `lib/widgets/` (global widgets).
  - Keep screens lean; move data-fetching and business logic into view models under `state/`.

- `.cursor/rules/dart-rules.mdc` and `.qoder/rules/06-dart-flutter-standards.md`
  - Strongly-typed Dart: avoid `dynamic`/`any`, define explicit types and models.
  - Naming: PascalCase for classes, camelCase for members/functions, snake_case for files.
  - Short, single-purpose functions; favor composition and clear error handling.

Use these as guardrails when generating or refactoring Dart/PHP.

### Feature/system documentation

Detailed flows are documented under `markdowns/` and are the reference for behavior parity between backend MVC and Flutter:
- `PROJECT_STRUCTURE.md` – high-level directory and module layout for frontend and backend.
- `FOLLOW_UP_SYSTEM_DOCUMENTATION.md` – complete counselor follow-up sessions design (CI4 controllers, JS, views, DB schema, and flow). Flutter counselor follow-up screens mirror this behavior.
- `VIEW_ALL_APPOINTMENTS_SYSTEM_DOCUMENTATION.md` – counselor "View All Appointments" / reports system, including charting, filters, exports, and how follow-ups are merged into the data model. The Flutter counselor reports screen is kept in lockstep with this.
- `BACKEND_DEPLOYMENT_GUIDE.md` – how to deploy the `Counselign` backend (XAMPP, config files, security settings).
- `SECURITY_IMPLEMENTATION_SUMMARY.md` – overview of frontend security work (secure logging, validation, secure storage, session management) and pending backend security tasks.

When changing any of these systems (follow-ups, reports, PDS, security), cross-check the matching docs, CI4 controllers, and JS files under `Counselign/public/js/` to keep **backend MVC and Flutter screens in sync**.

## Common Commands

### Flutter frontend (run from repo root)

Setup and dev loop:
- Install dependencies: `flutter pub get`
- Analyze/lint Dart code: `flutter analyze`
- Run the app (pick a device as appropriate):
  - Desktop (Windows example): `flutter run -d windows`
  - Web: `flutter run -d chrome`
  - Android emulator/device: `flutter run -d emulator-5554` (or another device ID)

Builds (examples used in this project):
- Windows release build: `flutter build windows --release`
- Other platforms: standard Flutter commands (`flutter build apk`, `flutter build ios`, `flutter build web`, etc.) as needed.

Testing:
- Run all Flutter tests: `flutter test`
- Run a single Flutter test file: `flutter test test/widget_test.dart`

API base URL configuration (important when running against different backends):
- `lib/api/config.dart` defines `localhostUrl`, `emulatorUrl`, `deviceUrl`, and `productionUrl`.
- You can override at build time with a `--dart-define`:
  - Example: `flutter run --dart-define=API_BASE_URL=https://your-domain.example.com/Counselign/public`
- Make sure the base URL matches how the backend is actually hosted (XAMPP/Apache vs `php spark serve`).

### CodeIgniter 4 backend (run from `Counselign/`)

Change into the backend directory before running these:
- `cd Counselign`

Dependencies and local server:
- Install PHP dependencies: `composer install`
- Run CI4 development server (alternative to XAMPP): `php spark serve`
  - Optionally: `php spark serve --port 8080`
- For XAMPP/Apache setups, follow `markdowns/BACKEND_DEPLOYMENT_GUIDE.md` to copy config files and serve from `C:\xampp\htdocs\Counselign`.

PHPUnit tests (see `Counselign/tests/README.md`):
- Run all backend tests (cross-platform via Composer script): `composer test`
- On Windows without the symlink:
  - All tests: `vendor\bin\phpunit`
  - Tests in a specific directory: `vendor\bin\phpunit tests/unit`

## High-Level Architecture

### Flutter frontend

Entry and navigation:
- `lib/main.dart` – app bootstrap: providers, theme, top-level navigation setup.
- `lib/routes.dart` – central route table and navigation helpers. All screens should be wired here using named routes (e.g. `/student/dashboard`, `/counselor/reports`).

Feature modules (per user role and flow):
- `lib/adminscreen/` – admin dashboards, management screens, and associated `models/`, `state/`, and `widgets/` for admins.
- `lib/counselorscreen/` – counselor dashboards, appointments, follow-up sessions, messaging, profile management, reports, etc.; structured as:
  - `models/` – typed data objects (appointments, reports, messages, availability).
  - `state/` – view models (generally `ChangeNotifier` + Provider) that orchestrate API calls and manage UI state.
  - `widgets/` – reusable UI components (cards, tables, modals, layout wrappers).
- `lib/studentscreen/` – student dashboard, appointments, PDS, follow-up sessions, messaging, announcements; same `models/` / `state/` / `widgets/` layering.
- `lib/landingscreen/` – landing/auth flows with dialogs (login, signup, forgot password, verification) and a dedicated `state/` view model.
- `lib/servicesscreen/` – informational services page.

Shared layers and cross-cutting concerns:
- `lib/api/config.dart` – central API base URL selection and HTTP configuration; recent changes add `API_BASE_URL` override via `--dart-define` and clarify production HTTPS expectations.
- `lib/utils/` – shared utilities such as:
  - `session.dart` – HTTP session wrapper handling cookies, multipart form posts, and error handling. **Critical**: it now always uses multipart when `fields` are provided, even without files, to match CI4 form expectations.
  - `secure_logger.dart`, `secure_storage.dart`, `input_validator.dart` – logging, secure storage, and input validation systems described in `markdowns/SECURITY_IMPLEMENTATION_SUMMARY.md`.
  - Other helpers like `online_status.dart`, `user_display_helper.dart`, image URL helpers, etc.
- `lib/widgets/` – global widgets (shared headers, navigation bars) used across role-specific screens.

Patterns:
- Each complex flow has a **ViewModel** class under a `state/` folder that:
  - Holds domain-specific state (appointments, notifications, follow-ups, PDS data, etc.).
  - Wraps API calls to backend endpoints and normalizes data into models.
  - Exposes simple methods for the UI (e.g., `clearAllNotifications()`, `updateAppointmentStatus()`, `submitAppointment()`).
- UI widgets and screens delegate logic to these view models and focus on rendering; they are wired via Provider/ChangeNotifier.
- Many Flutter features are explicit ports of existing JS + CI4 MVC behavior (e.g., student PDS, counselor reports, follow-up sessions). When modifying these, inspect both the Flutter implementation and the backend JS/PHP to keep them behaviorally identical.

### CodeIgniter 4 backend (`Counselign/`)

Core application structure (standard CI4):
- `app/Config/` – configuration (App, Database, Security, Session, Routes, Filters, etc.). Security-hardening changes are described in `markdowns/BACKEND_DEPLOYMENT_GUIDE.md`.
- `app/Controllers/` – request handling:
  - Root controllers (e.g., `Auth`, `Home`, `Services`, `ForgotPassword`, `Photo`, etc.).
  - `Admin/`, `Counselor/`, `Student/` subnamespaces for role-specific dashboards, CRUD, reports, follow-up sessions, messaging, notifications, etc.
- `app/Models/` – all DB access and data persistence (users, appointments, PDS-related tables, notifications, follow-up appointments, etc.).
- `app/Views/` – PHP templates mirroring the same features surfaced in Flutter, including role-specific dashboards and flows.
- `app/Database/Migrations/` and `app/Database/Seeds/` – schema evolution and seeders (e.g., notifications tables, ACID-related migrations).
- `app/Services/` – service-layer helpers such as `AppointmentEmailService` for email notifications.
- `app/Libraries/` – custom libraries for DB monitoring, transaction management, and caching.
- `public/` – web root:
  - `index.php` – front controller; web server must point here.
  - `css/`, `js/`, `Photos/` – static assets; JS in particular defines the original behavior for many flows the Flutter app later mirrored.
- `tests/` – PHPUnit test suite (see `Counselign/tests/README.md`).

The backend is the **source of truth** for business rules. Many Flutter fixes explicitly reference CI4 views and JS (see `memory-bank/activeContext.md` and the `markdowns/*SYSTEM_DOCUMENTATION.md` files). When in doubt about expected behavior, inspect the CI4 controller + JS for that feature.

### Cross-cutting flows to be aware of

These flows span multiple layers and are heavily documented; keep them consistent end-to-end when editing:
- **Student PDS (Personal Data Sheet)** – implemented in Flutter under `lib/studentscreen/` (models, `pds_viewmodel`, profile screen) and mirrored from `Counselign/app/Views/student/student_profile.php` plus JS under `Counselign/public/js/student/`. Many subtle validation and serialization rules (e.g., handling of `N/A`, enums, ages, consent, file uploads) are detailed in `memory-bank/activeContext.md`.
- **Counselor Follow-Up Sessions** – documented in `markdowns/FOLLOW_UP_SYSTEM_DOCUMENTATION.md` and implemented in CI4 (`Counselign/app/Controllers/Counselor/FollowUp.php`, related models, JS) and Flutter (`lib/counselorscreen/.../follow_up_sessions_*`). This includes follow-up chains, conflict detection, email notifications, and status transitions.
- **Counselor View All Appointments / Reports** – documented in `markdowns/VIEW_ALL_APPOINTMENTS_SYSTEM_DOCUMENTATION.md` and mirrored by Flutter counselor reports screens. It combines base appointments and follow-up sessions into a unified reporting surface with charts and exports.
- **Security & Sessions** – frontend secure logger/storage/session utilities and backend config changes (`Session.php`, `Security.php`, `Filters.php`, `Database.php`, `Logger.php`) are described in `BACKEND_DEPLOYMENT_GUIDE.md` and `SECURITY_IMPLEMENTATION_SUMMARY.md`. Handle credentials, tokens, and logs in line with those docs.

## Guidance for Future Changes

- **Keep backend and frontend behavior aligned.** For any feature that exists in both CI4 MVC (PHP + JS) and Flutter, treat the backend implementation and the `markdowns/*SYSTEM_DOCUMENTATION.md` files as canonical. When changing logic, update both sides (and the relevant docs) together.
- **Respect module boundaries.** New Flutter features for a given role should live under that role’s folder (`studentscreen/`, `counselorscreen/`, `adminscreen/`) with corresponding `models/`, `state/`, and `widgets/`. Backend changes for those features belong under the matching controller namespace (`App\Controllers\Student`, `...\Counselor`, `...\Admin`).
- **Update memory bank after significant work.** When you add or substantially modify flows, endpoints, or security behavior, record the change in `memory-bank/activeContext.md` and, where applicable, in `techContext.md` and `systemPatterns.md` so future agents understand the rationale and current state.
- **Follow existing Dart/PHP style.** Match the patterns in `dart-rules.mdc`, the existing view models, and CI4 controllers/models: explicit types, thin controllers, model-driven DB access, and small, focused functions.
