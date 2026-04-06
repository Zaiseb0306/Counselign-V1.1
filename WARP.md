# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## 1. Tech stack & layout

- **Framework**: CodeIgniter 4 (PHP 8.1+), standard MVC.
- **Entrypoint**: `public/index.php` (web server should point the document root at `public/`, not the repo root).
- **Core directories**:
  - `app/Config`: Framework and app configuration (routes, filters, validation, database, email, CORS, CSP, etc.).
  - `app/Controllers`: HTTP controllers grouped by role/area (e.g., `Admin`, `Student`, `Counselor`, `Auth`).
  - `app/Models`: Database access and domain logic.
  - `app/Views`: PHP views (HTML templates only; no JS logic or CSS here).
  - `public/css`, `public/js`: Frontend assets; each feature/screen has dedicated CSS and JS files.
  - `writable/*`: Logs, sessions, uploads, Debugbar artifacts.
  - `tests/`: PHPUnit test suite; `phpunit.xml.dist` config at repo root.
- **Database**: MySQL/MariaDB configured via `app/Config/Database.php` or `.env`.

## 2. Documentation & rules to respect

### 2.1 Memory Bank is authoritative

This project uses a "Memory Bank" under `memory-bank/` as the primary source of project knowledge:

- `memory-bank/projectbrief.md`: High-level goals, scope, stakeholders.
- `memory-bank/productContext.md`: User types (students, counselors, admins) and core flows.
- `memory-bank/systemPatterns.md`: End-to-end architecture, API routes, UI/UX patterns, and domain-specific flows (appointments, follow-ups, notifications, messaging, dashboards, calendars, etc.).
- `memory-bank/techContext.md`: Tech stack, environment assumptions, email/CORS configuration, build/test commands, and feature-level technical notes.
- `memory-bank/activeContext.md`: Current focus, very recent implementation details, and next steps.
- `memory-bank/progress.md`: Status and known issues.

When making any non-trivial change (new endpoints, flows, or infrastructure behavior), consult these files first to understand existing patterns and update them afterward to keep them aligned with the code.

### 2.2 Cursor rules and project intelligence

There are project-specific rules under `.cursor/` and `public/Misc/.cursorrules` which capture important conventions:

- **CI4 architecture boundaries** (from `.cursor/rules/02-ci4-architecture.mdc`):
  - Keep controllers thin: orchestrate requests, delegate to models/services, and return views/JSON.
  - Put all DB access in models (and services); avoid raw queries in controllers/views.
  - Use CodeIgniter Validation and Filters for input validation and auth/CSRF.
  - Use sessions/flash for user feedback and CI4 Logger for server-side errors.
- **Security & validation guardrails** (from `.cursor/rules/03-security-validation.mdc` and `.cursorrules`):
  - Do not expose admin-only or counselor-only routes to unauthenticated/unauthorized users; enforce role checks in filters/controllers.
  - Validate all user inputs via `app/Config/Validation.php`; escape output in views; never echo raw user data.
  - Use CSRF protection via Filters for mutating requests; review CORS/CSP in `app/Config/Cors.php` and `app/Config/ContentSecurityPolicy.php` before changing cross-origin behavior.
  - Use CI4 Logger; avoid exposing stack traces or raw error messages in views.
- **Documentation workflows** (from `.cursor/rules/01-project-intelligence.mdc` and `04-doc-workflows.mdc`):
  - After meaningful changes, update `activeContext.md`, `systemPatterns.md`, `techContext.md`, and `progress.md` so that future agents can rely on them without re-deriving system behavior from the code.

When working in this repo, Warp should treat the Memory Bank and these rules as high-signal context for understanding intent, existing patterns, and acceptable changes.

## 3. Common commands & workflows

### 3.1 Setup

- Install PHP dependencies:
  - `composer install`
- Environment configuration:
  - Copy `env` → `.env` and adjust:
    - `app.baseURL` (must point to the URL where `public/` is served).
    - Database credentials for the default group and the `tests` group.
    - Email/SMTP settings used by the appointment email service.
- Web server setup:
  - Under XAMPP/Apache, point the virtual host or document root at the `public/` directory.

### 3.2 Running the app locally

Depending on environment, either:

- Serve via Apache (XAMPP) with document root at `public/` (the current dev setup described in `techContext.md`), **or**
- Use CodeIgniter CLI (when available):
  - `php spark serve`

Use the Memory Bank and `app/Config/Routes.php` to discover routes for specific features or test endpoints.

### 3.3 Tests

Dependencies:

- Ensure `composer install` has been run (this pulls in `phpunit/phpunit` and `codeigniter4/framework`).

Running the full suite (from project root):

- Generic (all platforms via Composer script):
  - `composer test`
- Direct PHPUnit usage:
  - Linux/macOS: `vendor/bin/phpunit`
  - Windows: `vendor\bin\phpunit`

Running a subset of tests (see `tests/README.md` and standard PHPUnit docs):

- Restrict to tests under a directory:
  - Linux/macOS: `vendor/bin/phpunit tests/Controllers`
  - Windows: `vendor\bin\phpunit tests\Controllers`
- To run a single test class or method, use standard PHPUnit options such as `--filter` against the desired test name (consult PHPUnit docs for exact filter patterns).

Code coverage (example adapted from `tests/README.md`):

- `vendor/bin/phpunit --colors --coverage-text=tests/coverage.txt --coverage-html=tests/coverage/ -d memory_limit=1024m`

The test configuration is defined in `phpunit.xml.dist` and targets the `app/` directory (excluding views and routes file) plus `tests/` testsuite.

### 3.4 Maintenance / background commands

There is a custom CLI command to keep notification tables small:

- **Cleanup read notifications** (see `memory-bank/techContext.md` and `systemPatterns.md`):
  - Command: `php spark cleanup:read-notifications`
  - Class: `App\Commands\CleanupReadNotifications` (auto-discovered by CI4).
  - Typical usage: run manually during development, or schedule via cron/Task Scheduler in production/staging.

## 4. High-level backend architecture

The app is an "UGC Counseling System" that supports students, counselors, and admins through separate areas and role-based access.

### 4.1 Core layers

- **Routing**: `app/Config/Routes.php` defines web and API-style routes, grouped by role (`admin`, `student`, `counselor`) and feature (appointments, follow-ups, notifications, messaging, reports, etc.).
- **Controllers** (selected patterns, see `memory-bank/systemPatterns.md` for exhaustive routing):
  - **Auth & session**: `App\Controllers\Auth`, `Logout`, `ForgotPassword`, `UpdatePassword`, `EmailController` handle login/signup, password reset, verification, contact forms, and email testing.
  - **Student area** (`App\Controllers\Student\...`): dashboards, appointment scheduling, personal data sheet (PDS), profile management, follow-up sessions, messaging, notifications.
  - **Counselor area** (`App\Controllers\Counselor\...`): dashboards, availability management, appointments and follow-up management (including status changes), history reports, messaging, profile.
  - **Admin area** (`App\Controllers\Admin\...`): user and counselor management, announcements & events CRUD (with JSON APIs), appointments and scheduled calendars, follow-up session overviews, resources, reports, and admin profile APIs.
- **Models**: Encapsulate all database access, including appointments, users, follow-ups, student information (academic, personal, address, family, special circumstances), notifications, and services requested/availed.
- **Services & helpers**:
  - `App\Services\AppointmentEmailService` and related email template classes centralize appointment/follow-up email notifications using PHPMailer and `Config\Email` for SMTP configuration.
  - `UserActivityHelper` centralizes `last_activity` and `last_active_at` tracking for students, counselors, and admins across many controllers.
  - Custom URL helper (`app/Helpers/url_helper.php`) and updated `App` and `Cors` config support dynamic base URLs and robust CORS on localhost/intranet setups.

### 4.2 Key domain flows (condensed from Memory Bank)

- **Appointments**:
  - Students request appointments with an optional counselor preference; counselors/admins manage approvals/rejections/cancellations and track completion.
  - Follow-up sessions are a first-class feature: counselors can create, edit (while pending), complete, and cancel follow-up sessions, all with validation, conflict checks, and email notifications.
  - Manila timezone handling is standardized for timestamps and logging across appointment-related operations.
- **Notifications**:
  - `NotificationsModel` aggregates events, announcements, appointments, and messages into per-user notifications.
  - Student and counselor notifications controllers expose views and JSON endpoints for fetching and marking notifications read.
  - The `cleanup:read-notifications` CLI command periodically removes rows where `is_read = 1` to keep response times reasonable.
- **Messaging**:
  - Student↔counselor messaging flows are implemented via `Student\Message` and `Counselor\Message` controllers and associated routes, with activity tracking and dashboard previews.
- **Reporting & history**:
  - History reports (for counselors and admins) provide time-based aggregations of appointments; recent fixes ensure counselors see only their own data.
  - Admin- and counselor-specific appointments APIs supply data for dashboards, charts, and calendars.

## 5. Frontend architecture & UX patterns

- **Strict separation of concerns** (reinforced in `techContext.md` and `systemPatterns.md`):
  - HTML structure lives in `app/Views/**.php`.
  - CSS lives in `public/css/**` (organized by role/feature, e.g., `public/css/student/student_dashboard.css`).
  - JavaScript lives in `public/js/**` (likewise organized, e.g., `public/js/student/student_dashboard.js`).
  - Do not mix inline JS or CSS into views beyond minimal bootstrap; new behavior should go into the appropriate JS/CSS files.
- **Enhancement patterns**:
  - Student and counselor dashboards use vanilla JS for dynamic widgets (events & quotes carousels, mini-calendars, appointment tickets with QR codes, etc.).
  - Bootstrap 5 modals are used extensively for login/signup, contact, password reset, verification, appointments, and confirmations; generic modal helpers in `public/js/modals/*.js` standardize confirmation/alert/notice flows.
  - Responsive navigation and services page layouts use a drawer pattern on small screens (`landing.js`, `services.js` plus associated CSS), documented in `systemPatterns.md`.

When editing or adding UI features, follow the existing pattern of:

1. Adding/changing markup in the appropriate view under `app/Views/...`.
2. Implementing interaction logic in a dedicated JS file under `public/js/...` for that screen.
3. Adding or updating styling in the corresponding CSS file under `public/css/...`.
4. Reflecting new routes, flows, or UX patterns in `memory-bank/systemPatterns.md` and `memory-bank/activeContext.md` so future agents can build on the documented behavior rather than rediscovering it.