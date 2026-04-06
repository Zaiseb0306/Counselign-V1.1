# Project Brief

## Name
Counselign (Flutter app)

## Purpose
Provide a cross-platform counseling appointment and information app for users, admins, and counselors. Users can view announcements, manage profiles, schedule and view appointments. Admins and counselors access their respective dashboards.

## Primary Objectives
- Deliver a clean, responsive Flutter UI for mobile, web, and desktop.
- Implement clear navigation via named routes and helper methods.
- Integrate with a backend (CodeIgniter MVC under `Counselign(09-26-25)/`) via configurable base URL.
- Persist lightweight client state (e.g., session/auth) locally.

## Key Features (initial)
- Landing page and services flow
- User dashboard with appointments, profile, announcements
- Admin dashboard entry point
- Counselor dashboard entry point

## Non-Goals (app layer)
- Implementing backend business logic (handled by MVC project)
- Heavy offline-first data sync

## Success Criteria
- Runs on Android, iOS, Web, and Desktop with consistent UX
- Configurable API endpoints per environment
- Navigable flows without runtime errors and basic persistence


