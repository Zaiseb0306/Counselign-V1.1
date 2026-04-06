# Software Implementation and Testing Overview

## Software Implementation
Counselign runs as a Flutter mobile app for students and counselors while sharing the same CodeIgniter web portal that administrators already use. On phones and tablets, the Flutter build packages all counselor, student, and admin journeys into one install so users can log in, schedule or accept counseling sessions, and receive announcements even when they are away from their desks. On browsers, the CodeIgniter MVC pages handle the same workflows with lightweight forms and dashboards, which means offices can continue using existing PCs while students enjoy the streamlined mobile UI. Both fronts talk to the same API endpoints, so anything an admin approves on the web instantly shows up on mobile dashboards and notifications.

Required software:
- Flutter SDK 3.9.x with Android Studio or VS Code (mobile build and simulator)
- CodeIgniter 4 with PHP 8.x and Composer (web portal)
- MySQL 8.x (shared database)
- Git and Postman for deployments and quick endpoint checks

Required hardware:
- Android 10+/iOS 15+ phones for field testing
- Windows 10+/macOS 13+ workstation with at least 16 GB RAM for Flutter builds


During integration we hit three notable issues: (1) multipart form submissions from Flutter failed when no file was attached, so the `Session.post` helper now sends form fields even without files; (2) dropdown fields on the mobile Personal Data Sheet (PDS) stopped reflecting saved values, fixed by rebuilding the widgets whenever their controllers change; and (3) enum validation in the CodeIgniter models rejected values containing extra spaces or “N/A”, handled by trimming and filtering those strings inside the Flutter view model before POST requests. After these tweaks, both the mobile client and the PHP controllers exchange identical payloads, which keeps student profiles, appointments, and counselor updates in sync across platforms.

## Software Testing
We combined Flutter-side verification (`flutter analyze`, widget smoke tests, and manual device walkthroughs) with browser-based regression passes on the CodeIgniter portal to be sure every workflow feels identical. Mobile testing covered landing navigation, counselor schedule fetching, form validation, and multimedia uploads (like the PWD proof) across Android emulators, physical Android devices on campus Wi-Fi, and iOS simulators. Web testing focused on the same flows through Chrome and Edge, confirming that approvals, announcements, and follow-up badges appear immediately after backend operations.

| Test | Focus | Outcome |
| --- | --- | --- |
| PDS Save (Mobile + Web) | Multipart fields, consent flag, enum trimming | Passed after session helper and validation fixes |
| Appointment Lifecycle | Schedule, approve/reject, follow-up badges | Passed; mobile UI mirrors CodeIgniter tables |
| Messaging + Notifications | Counselor unread badges, timestamp formats | Passed; bolding and AM/PM formatting consistent |

Overall results show the system meeting its functional requirements: every critical student, counselor, and admin action works from both the Flutter build and the CodeIgniter pages without duplicated logic. Performance goals are also met—API calls reply within expected time on Wi-Fi networks, and the UI stays responsive thanks to loading states and lightweight payloads. Remaining tasks are routine (periodic regression and future feature toggles).

