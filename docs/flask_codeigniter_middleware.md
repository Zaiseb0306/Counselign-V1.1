# CodeIgniter 4 + Flask middleware flow

## Flow

`View (HTML + JS)` -> `Flask middleware` -> `CodeIgniter controller` -> `Model` -> `Database`

1. The admin page at `http://localhost/Counselign/public/admin/dashboard` loads the JavaScript file.
2. The JavaScript sends `fetch()` requests to Flask instead of directly to CodeIgniter.
3. Flask receives the request first and forwards it to the CodeIgniter API endpoint.
4. The CodeIgniter controller handles the request and uses the model for database access.
5. CodeIgniter returns JSON to Flask.
6. Flask returns JSON back to the browser JavaScript.

## Folder structure example

```text
Counselign/
├─ app/
│  ├─ Controllers/
│  │  └─ Admin/
│  │     └─ GetAllAppointments.php
│  ├─ Models/
│  │  └─ AppointmentModel.php
│  └─ Views/
│     └─ admin/
│        └─ dashboard.php
├─ public/
│  └─ js/
│     └─ admin/
│        └─ view_all_appointments.js
├─ flask_middleware/
│  ├─ app.py
│  └─ requirements.txt
└─ docs/
   └─ flask_codeigniter_middleware.md
```

## CodeIgniter controller API example

Use the existing admin route:

`GET /admin/appointments/get_all_appointments?timeRange=weekly`

Controller file: `app/Controllers/Admin/GetAllAppointments.php`

This controller already returns JSON, so it can act as the CodeIgniter API that Flask calls.

## Model example

Model file: `app/Models/AppointmentModel.php`

The model remains responsible for database queries. Flask must not query the database directly.

## Flask ON/OFF sign

- Green badge = Flask middleware ON
- Red badge = Flask middleware OFF

The badge is rendered in the admin dashboard and updated by calling the Flask `/health` endpoint.

## Run Flask

Install dependencies:

```bash
pip install -r requirements.txt
```

Start server:

```bash
python app.py
```

## CORS note

Because the admin dashboard runs from `http://localhost/Counselign/public/...` and Flask runs on `http://127.0.0.1:5000`, the browser treats this as a cross-origin request.

[`flask_middleware/app.py`](flask_middleware/app.py) now enables CORS for `http://localhost` and supports credentials, so the JavaScript requests to `/health` and `/api/admin/appointments` can pass the browser preflight check.
