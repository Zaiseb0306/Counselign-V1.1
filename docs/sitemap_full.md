# CounselIgn - Full Sitemap

---

## Public Pages (Unauthenticated)

```
┌─────────────────────────────────────────┐
│              PUBLIC PAGES                │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────┐    ┌─────────────┐     │
│  │   Landing   │    │   Services  │     │
│  │    Page     │    │    Page     │     │
│  │     (/)     │    │ (/services) │     │
│  └─────────────┘    └─────────────┘     │
│         │                  │             │
│         │                  │             │
│         ▼                  ▼             │
│  ┌─────────────┐    ┌─────────────┐     │
│  │   Login     │    │  Register   │     │
│  │  (/login)   │    │ (/register) │     │
│  └─────────────┘    └─────────────┘     │
│         │                  │             │
│         ▼                  ▼             │
│  ┌─────────────────────────────┐        │
│  │     Forgot Password         │        │
│  │    (/forgot-password)       │        │
│  └─────────────────────────────┘        │
│                                         │
└─────────────────────────────────────────┘
```

**Public Routes:**
- `/` - Landing Page
- `/services` - Services Information
- `/login` - Login Page
- `/register` - Registration Page
- `/forgot-password` - Forgot Password
- `/auth/verify` - Email Verification
- `/logout` - Logout

---

## Student Portal

```
┌──────────────────────────────────────────────────────────────┐
│                     STUDENT PORTAL                            │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌─────────────────────────────────────────────────────┐    │
│   │              /student/dashboard                      │    │
│   │                   (Dashboard)                        │    │
│   └──────────────────────┬──────────────────────────────┘    │
│                          │                                    │
│          ┌──────────────┼──────────────┐                     │
│          ▼              ▼              ▼                     │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│   │ Schedule   │  │   My      │  │   Follow   │              │
│   │Appointment │  │Appointments│  │  Sessions  │              │
│   │ /appointment│  │/my-appoint│  │/follow-up  │              │
│   └────────────┘  └────────────┘  └────────────┘              │
│          │              │              │                      │
│          ▼              ▼              ▼                      │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│   │  PDS Form  │  │  Profile  │  │   Events   │              │
│   │    /pds   │  │ /profile  │  │  /events   │              │
│   └────────────┘  └────────────┘  └────────────┘              │
│          │              │              │                      │
│          ▼              ▼              ▼                      │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│   │Announce-   │  │ Messages  │  │   View     │              │
│   │  ments     │  │/messages  │  │ Notifs     │              │
│   │/announce   │  │           │  │/notifs     │              │
│   └────────────┘  └────────────┘  └────────────┘              │
│                          │                                    │
└──────────────────────────┼────────────────────────────────────┘
                           │
                    ┌──────┴──────┐
                    ▼             ▼
              ┌────────┐   ┌────────┐
              │  API   │   │ Session│
              │ Endpts │   │ Check  │
              └────────┘   └────────┘
```

**Student Routes:**

| Route | Controller | Description |
|-------|------------|-------------|
| `/student/dashboard` | `Student\Dashboard` | Main dashboard |
| `/student/appointment` | `Student\Appointment` | Schedule new appointment |
| `/student/my-appointments` | `Student\Appointment` | View my appointments |
| `/student/follow-up-sessions` | `Student\FollowUpSessions` | Follow-up sessions |
| `/student/pds` | `Student\PDS` | Personal Data Sheet |
| `/student/profile` | `Student\Profile` | User profile |
| `/student/messages` | `Student\Message` | Messages |
| `/student/notifications` | `Student\Notifications` | Notifications |
| `/student/announcements` | `Student\Announcements` | Announcements |
| `/student/events` | `Student\Events` | Events |
| `/student/session-check` | `Student\SessionCheck` | Session verification |

**Student API Endpoints:**

| Endpoint | Controller | Method |
|----------|------------|--------|
| `/student/appointment/schedule` | `Student\Appointment` | POST |
| `/student/appointment/atomic` | `Student\AppointmentAtomic` | POST |
| `/student/pds/atomic` | `Student\PDSAtomic` | POST |

---

## Counselor Portal

```
┌──────────────────────────────────────────────────────────────┐
│                    COUNSELOR PORTAL                           │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌─────────────────────────────────────────────────────┐    │
│   │              /counselor/dashboard                    │    │
│   │                   (Dashboard)                        │    │
│   └──────────────────────┬──────────────────────────────┘    │
│                          │                                    │
│          ┌──────────────┼──────────────┐                     │
│          ▼              ▼              ▼                     │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│   │Appointments│  │  View All  │  │Availability│              │
│   │/appointmnts│  │/view-all   │  │/availabilty│              │
│   └────────────┘  └────────────┘  └────────────┘              │
│          │              │              │                      │
│          ▼              ▼              ▼                      │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│   │  History   │  │  Follow Up │  │  Profile   │              │
│   │  Reports   │  │  /follow-up│  │ /profile   │              │
│   │/history-rep│  │            │  │            │              │
│   └────────────┘  └────────────┘  └────────────┘              │
│          │              │              │                      │
│          ▼              ▼              ▼                      │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│   │Announce-   │  │ Messages   │  │   Events   │              │
│   │  ments     │  │/messages  │  │  /events   │              │
│   │/announce   │  │            │  │            │              │
│   └────────────┘  └────────────┘  └────────────┘              │
│                          │                                    │
│          ┌───────────────┼───────────────┐                    │
│          ▼               ▼               ▼                    │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐              │
│   │ Notifs     │  │ Filter     │  │ Session    │              │
│   │/notifs     │  │   Data     │  │  Check     │              │
│   └────────────┘  └────────────┘  └────────────┘              │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

**Counselor Routes:**

| Route | Controller | Description |
|-------|------------|-------------|
| `/counselor/dashboard` | `Counselor\Dashboard` | Main dashboard |
| `/counselor/appointments` | `Counselor\Appointments` | My appointments |
| `/counselor/view-all` | `Counselor\GetAllAppointments` | All appointments |
| `/counselor/availability` | `Counselor\Availability` | Set availability |
| `/counselor/history-reports` | `Counselor\HistoryReports` | History reports |
| `/counselor/follow-up` | `Counselor\FollowUp` | Follow-up management |
| `/counselor/profile` | `Counselor\Profile` | User profile |
| `/counselor/messages` | `Counselor\Message` | Messages |
| `/counselor/notifications` | `Counselor\Notifications` | Notifications |
| `/counselor/announcements` | `Counselor\Announcements` | Announcements |
| `/counselor/events` | `Counselor\Events` | Events |
| `/counselor/session-check` | `Counselor\SessionCheck` | Session verification |

**Counselor API Endpoints:**

| Endpoint | Controller | Method |
|----------|------------|--------|
| `/counselor/appointments/approve` | `Counselor\Appointments` | POST |
| `/counselor/appointments/reject` | `Counselor\Appointments` | POST |
| `/counselor/appointments/reschedule` | `Counselor\Appointments` | POST |
| `/counselor/appointments/complete` | `Counselor\Appointments` | POST |
| `/counselor/availability/set` | `Counselor\Availability` | POST |
| `/counselor/follow-up/create` | `Counselor\FollowUp` | POST |
| `/counselor/filter-data` | `Counselor\FilterData` | POST |
| `/counselor/view-all/filter` | `Counselor\GetAllAppointments` | POST |

---

## Admin Portal

```
┌──────────────────────────────────────────────────────────────┐
│                      ADMIN PORTAL                             │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌─────────────────────────────────────────────────────┐    │
│   │               /admin/dashboard                       │    │
│   │                   (Dashboard)                        │    │
│   └──────────────────────┬──────────────────────────────┘    │
│                          │                                    │
│          ┌──────────────┼──────────────┐                     │
│          ▼              ▼              ▼                     │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐          │
│   │Appointments│  │  View All  │  │  Manage     │          │
│   │/appointmnts│  │/view-all   │  │  Users      │          │
│   └────────────┘  └────────────┘  │/view-users  │          │
│          │              │          └────────────┘          │
│          ▼              ▼                │                   │
│   ┌────────────┐  ┌────────────┐        ▼                   │
│   │ Scheduled  │  │   History  │  ┌────────────┐           │
│   │Appointments│  │  Reports   │  │   Counsel   │           │
│   │/scheduled  │  │/history-rep│  │   Info      │           │
│   └────────────┘  └────────────┘  │/counselors  │           │
│                                    └────────────┘           │
│          ┌────────────────────────┼─────────────┐           │
│          ▼                        ▼              ▼          │
│   ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│   │ Resources  │  │Announce-   │  │   Events   │           │
│   │/resources  │  │  ments    │  │  /events   │           │
│   └────────────┘  │/announce   │  └────────────┘           │
│          │        └────────────┘        │                   │
│          │              │              ▼                   │
│          ▼              ▼        ┌────────────┐            │
│   ┌────────────┐  ┌────────────┐ │  Database  │            │
│   │ Follow-Up  │  │  Profile   │ │   Health   │            │
│   │ Sessions   │  │ /account   │ │/db-health  │            │
│   │/follow-up  │  │            │ └────────────┘            │
│   └────────────┘  └────────────┘                          │
│          │              │                                   │
│          ▼              ▼                                   │
│   ┌────────────┐  ┌────────────┐                          │
│   │   Admin    │  │   Users    │                          │
│   │ Management │  │    API     │                          │
│   │/admins-mgt │  │            │                          │
│   └────────────┘  └────────────┘                          │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

**Admin Routes:**

| Route | Controller | Description |
|-------|------------|-------------|
| `/admin/dashboard` | `Admin\Dashboard` | Main dashboard |
| `/admin/appointments` | `Admin\Appointments` | All appointments |
| `/admin/view-all-appointments` | `Admin\GetAllAppointments` | View all appointments |
| `/admin/scheduled-appointments` | `Admin\Appointments` | Scheduled appointments |
| `/admin/view-users` | `Admin\UsersApi` | User management |
| `/admin/counselors` | `Admin\CounselorInfo` | Counselor information |
| `/admin/resources` | `Admin\Resources` | Resource management |
| `/admin/history-reports` | `Admin\HistoryReports` | History reports |
| `/admin/announcements` | `Admin\Announcements` | Announcements |
| `/admin/events` | `Admin\EventsApi` | Events management |
| `/admin/follow-up-sessions` | `Admin\FollowUpSessions` | Follow-up sessions |
| `/admin/account-settings` | `Admin\AdminsManagement` | Account settings |
| `/admin/admins-management` | `Admin\AdminsManagement` | Admins management |
| `/admin/database-health` | `Admin\DatabaseHealth` | Database health |
| `/admin/session-check` | `Admin\SessionCheck` | Session verification |

**Admin API Endpoints:**

| Endpoint | Controller | Method |
|----------|------------|--------|
| `/admin/users` | `Admin\UsersApi` | GET/POST |
| `/admin/users/delete` | `Admin\UsersApi` | DELETE |
| `/admin/users/update` | `Admin\UsersApi` | PUT |
| `/admin/counselors` | `Admin\CounselorsApi` | GET/POST |
| `/admin/counselors/delete` | `Admin\CounselorsApi` | DELETE |
| `/admin/counselors/update` | `Admin\CounselorsApi` | PUT |
| `/admin/events` | `Admin\EventsApi` | CRUD |
| `/admin/announcements` | `Admin\AnnouncementsApi` | CRUD |
| `/admin/admins` | `Admin\AdminsManagement` | CRUD |
| `/admin/filter-data` | `Admin\FilterData` | POST |
| `/admin/resources/upload` | `Admin\Resources` | POST |

---

## System Services & Utilities

```
┌──────────────────────────────────────────────────────────────┐
│                  SYSTEM SERVICES & UTILITIES                 │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌─────────────────┐    ┌─────────────────┐               │
│   │   Email Service │    │  Auth Middleware │               │
│   │  (PHPMailer)    │    │   (Flask JWT)    │               │
│   └─────────────────┘    └─────────────────┘               │
│                                                               │
│   ┌─────────────────┐    ┌─────────────────┐               │
│   │  Email Templates│    │   BaseController│               │
│   │                 │    │                 │               │
│   └─────────────────┘    └─────────────────┘               │
│                                                               │
│   ┌─────────────────┐    ┌─────────────────┐               │
│   │   Photo Upload  │    │   Maintenance   │               │
│   │                 │    │                 │               │
│   └─────────────────┘    └─────────────────┘               │
│                                                               │
│   ┌─────────────────┐    ┌─────────────────┐               │
│   │  Update Password│    │   Test Activity │               │
│   │                 │    │                 │               │
│   └─────────────────┘    └─────────────────┘               │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

**Service Controllers:**

| Controller | Purpose |
|------------|---------|
| `EmailController` | Email sending service |
| `Photo` | Profile photo upload |
| `Maintenance` | System maintenance |
| `UpdatePassword` | Password reset/update |
| `TestActivity` | Testing utilities |

---

## Database Models

```
┌──────────────────────────────────────────────────────────────┐
│                      DATABASE MODELS                         │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │    UserModel    │  │ AppointmentModel│                  │
│  │    (users)      │  │  (appointments) │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ CounselorModel │  │OptimizedAppointment│              │
│  │   (counselors)  │  │                 │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │  FollowUpModel  │  │    BaseModel    │                  │
│  │(follow_up_apps)  │  │                 │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ Notification    │  │ Announcement   │                  │
│  │    Model        │  │    Model       │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │    Resource     │  │     Event       │                  │
│  │    Model        │  │    Model       │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │   QuoteModel    │  │CounselorAvail   │                  │
│  │ (daily_quotes)  │  │    Model       │                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                               │
│  ── Student PDS Models ──                                    │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ StudentPersonal │  │StudentAcademic │                  │
│  └─────────────────┘  └─────────────────┘                  │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ StudentFamily   │  │ StudentAddress │                  │
│  └─────────────────┘  └─────────────────┘                  │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ StudentAwards   │  │ StudentOther    │                  │
│  └─────────────────┘  └─────────────────┘                  │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │  StudentGCS     │  │  StudentResid  │                  │
│  └─────────────────┘  └─────────────────┘                  │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │ StudentServices │  │StudentSpecial  │                  │
│  │   (Availed)     │  │   Circumstances│                  │
│  └─────────────────┘  └─────────────────┘                  │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Middleware Flow

```
┌──────────────────────────────────────────────────────────────┐
│                  AUTHENTICATION FLOW                         │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│    Browser Request                                            │
│         │                                                    │
│         ▼                                                    │
│  ┌─────────────┐     ┌─────────────┐                         │
│  │   Flask     │────►│   Validate  │                         │
│  │ Middleware  │     │     JWT     │                         │
│  │   (Port 5k) │     │   Token     │                         │
│  └─────────────┘     └─────────────┘                         │
│         │                  │                                 │
│         │            ┌─────┴─────┐                          │
│         │            ▼           ▼                          │
│         │       Valid         Invalid                       │
│         │          │              │                          │
│         └──────────┴──────────────┘                          │
│                    │                                         │
│                    ▼                                         │
│            CodeIgniter App                                   │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Key Features by Role

### Student Features
- Book appointments (Individual/Group)
- View/manage appointments
- Request follow-up sessions
- Complete PDS form
- View announcements & events
- Send messages to counselors
- View notifications
- Update profile

### Counselor Features
- View all appointments
- Approve/Reject/Reschedule appointments
- Add counselor remarks
- Create follow-up sessions
- Set availability schedule
- View history reports
- Send/Receive messages
- Manage announcements

### Admin Features
- Manage all users
- Manage counselors
- View all appointments
- Generate PDF reports
- Manage resources (files/links)
- Post announcements
- Manage events
- Database health monitoring
- Admin account management

---

*Full Sitemap Version - 2026-04-06*