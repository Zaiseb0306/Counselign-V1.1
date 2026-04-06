
# Counselign Guide

## Group Members
1. Sebastian Anthony Acierto
2. Milwaukee Arrubio
3. Emeliza Borres
4. Rex Dominic Sihay
5. Princess Grace Marie Sitoy

## System Description
Counselign is made of two parts that constantly talk to each other to keep student counseling running smoothly. The front end is a Flutter 3.x app (built with Dart ^3.9.2) that you can install on phones, tablets, computers, or even open in a web browser. It shows every screen students, counselors, and admins need—such as logging in, browsing announcements, booking or managing sessions, chatting, filling out PDS forms, previewing documents, checking counselor schedules, and updating profiles—while reusable view models handle input checks so people see clear error messages instead of confusing crashes. Behind the scenes, a CodeIgniter 4 backend written in PHP 8.x stores everything in a MySQL database and exposes simple REST-style URLs for logging in, reading schedules, saving PDS forms, managing counselors, sending announcements, tracking follow-ups, and exporting reports. Whenever the Flutter app needs something, it sends an authenticated web request through the shared Session helper, which automatically includes the right base URL and headers, uploads photos or forms using multipart data when required (like profile pictures or PDS attachments), and falls back to regular JSON/form posts for lighter tasks (like status updates or chat messages). As long as both parts agree on the same HTTPS base address (set in `lib/api/config.dart` or through `--dart-define` flags), the data flows securely so even a University student can sign in, book a session, message their counselor, and get updates without learning how the servers work.

## Testing Instructions

### Flutter Client

1. **Database Setup**
   - Import the `counselign_db(schema).sql` to your PHPMyAdmin server, if you don't have a Xampp server installed, download it here from this link `https://www.apachefriends.org/download.html` and follow instructions or watch youtube tutorials about this.

2. **Web and Backend Setup**
   - Copy the full Counselign_Web folder in this Extracted Directory and put in your htdocs folder inside xampp folder, usually `C:\xampp\htdocs` and rename the folder to `Counselign`.

3. **URLs and API Configurations**
   - In your `config.dart` file in the counselign folder inside this Extracted Directory `counselign\lib\api` edit the IP addresses of these lines 
   `static const String localhostUrl = 'http://172.16.83.246/Counselign/public';` and 
   `static const String deviceUrl = 'http://172.16.83.246/Counselign/public';` with the IP address of your PC, for local testing with physical devices.
   - To get the IP Address of your PC, go to Command Prompt and type `ipconfig`, look for this part:
   `Wireless LAN adapter Wi-Fi:` and inside that block there is this line:
   `IPv4 Address. . . . . . . . . . . : 192.168.18.x` that is your IP Address.
   - Verify `ApiConfig.currentBaseUrl` prints the expected URL in logs.

4. **Clean Build (Flutter App)**
   - Run `flutter clean`.
   - Run `flutter pub get`.
   - Optional: delete the `build/` directory manually if switching channels or upgrading Flutter.

5. **Static Analysis & Tests**
   - `flutter analyze` to ensure the analyzer is clean.
   - `flutter test` for widget/unit coverage (student dashboard, counselor flows, etc.).
   - `flutter test integration_test` if integration suites exist.

6. **Build & Run (Android Studio)**
   - Open the project in Android Studio.
   - Select the desired device/emulator.
   - Configure `Run > Edit Configurations...` to pass `--dart-define` as needed.
   - Click **Run** (debug) or **Build > Flutter > Build APK/App Bundle** for release artifacts.

7. **Build & Run (Terminal)**
   - Debug: `flutter run --dart-define=API_BASE_URL=...`
   - Release APK: `flutter build apk --release --dart-define=API_BASE_URL=...`
   - App Bundle: `flutter build appbundle --release --dart-define=API_BASE_URL=...`
   - Desktop/Web: use `flutter build windows`, `flutter build web`, etc., with the same `--dart-define`.
   - The apk-release.apk will be save in the  `\counselign\build\app\outputs\flutter-apk`.


### CodeIgniter 4 API

1. **Environment Setup**
   - PHP 8.1+, Composer, MySQL/MariaDB, and Apache/Nginx (or PHP built-in server).
   - Copy `.env.example` to `.env`, set `CI_ENVIRONMENT = development` (or production as needed).

2. **URL Configuration**
   - In `App.php` `C:\xampp\htdocs\Counselign\app\Config\App.php` set the IP Address of this line `public string $baseURL = 'http://172.16.83.246/Counselign/public/';` to your IP Address.
   - Ensure the `/public` directory is the web root; update Apache/Nginx vhost accordingly.
   - For local testing, map `http://localhost/Counselign/public/` or LAN IPs and ensure Flutter’s base URL matches.

3. **Clean Build / Cache Reset**
   - `composer install` (or `composer update`) to sync dependencies.
   - `php spark cache:clear` and `php spark cache:clear-env` after config changes.
   - Run migrations/seeds if schema updates exist: `php spark migrate` and `php spark db:seed SeederName`.

4. **API Testing**
   - `php spark serve --port 8080` for local testing (or rely on Apache/Nginx).
   - Use PHPUnit: `php vendor/bin/phpunit`.
   - Exercise REST endpoints with Postman or `curl` (login, appointments, announcements, PDS, follow-ups).
   - Confirm JSON/form-data payloads align with Flutter requests (e.g., multipart submissions for PDS).

5. **Deployment Smoke Tests**
   - Hit `/auth/login`, `/student/...`, `/counselor/...` endpoints directly to confirm routing.
   - Validate CORS, session handling, and file uploads (Photos/, uploads/) on the target environment.

6. **Default Admin Account**
   - As A default, there is already an existing Admin account in the SQL file included,  `user_id = 0000000001 or email = counselign2025@gmail.com` and `password = Demo_123`, this is due to the fact that the system does not have a signup function for admin accounts/users.

## Tools Used

### Flutter Stack
- Flutter SDK 3.x with Dart ^3.9.2
- Android Studio (profiling, emulators)
- VS Code (quick edits)
- Android SDK & Platform Tools
- Git + GitHub
- Postman for API inspection

### CodeIgniter Stack
- CodeIgniter 4 CLI (`php spark`) on PHP 8.x
- Composer for dependency management
- MySQL/MariaDB via phpMyAdmin
- Apache (XAMPP)
- Postman for endpoint verification
- Git for version control and deployment hooks


