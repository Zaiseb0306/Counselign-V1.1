# CounselIgn - Diagrams (Simplified)

---

## 1. Use Case Diagram

### Actors

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Student   │     │  Counselor  │     │    Admin    │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Student Use Cases

```
┌─────────────────────────────────────────────────────┐
│                      STUDENT                         │
├─────────────────────────────────────────────────────┤
│  • Book Appointment                                  │
│  • View My Appointments                              │
│  • Reschedule Appointment                            │
│  • Submit Feedback                                   │
│  • Submit Concern                                    │
│  • Complete PDS Form                                │
│  • View Announcements                               │
│  • Send Messages                                    │
│  • View Dashboard                                    │
└─────────────────────────────────────────────────────┘
```

### Counselor Use Cases

```
┌─────────────────────────────────────────────────────┐
│                     COUNSELOR                        │
├─────────────────────────────────────────────────────┤
│  • View All Appointments                             │
│  • Approve/Reject Appointments                       │
│  • Reschedule Appointments                           │
│  • Add Counselor Remarks                            │
│  • Request Follow-Up                                 │
│  • View History Reports                              │
│  • Set Availability                                  │
│  • Send Messages                                     │
│  • View Dashboard                                    │
└─────────────────────────────────────────────────────┘
```

### Admin Use Cases

```
┌─────────────────────────────────────────────────────┐
│                       ADMIN                         │
├─────────────────────────────────────────────────────┤
│  • Manage Users                                      │
│  • Manage Counselors                                 │
│  • View All Appointments                            │
│  • Generate PDF Reports                             │
│  • Manage Resources                                 │
│  • Post Announcements                               │
│  • Manage Events                                    │
│  • System Health Check                              │
└─────────────────────────────────────────────────────┘
```

### Relationship Diagram

```
         ┌──────────────┐
         │    Login     │
         └──────┬───────┘
                │
       ┌────────┼────────┐
       ▼        ▼        ▼
   ┌───────┐ ┌───────┐ ┌───────┐
   │Student│ │Counsel│ │ Admin │
   └───────┘ └───────┘ └───────┘
     │   │     │   │     │   │
     │   │     │   │     │   │
     ▼   ▼     ▼   ▼     ▼   ▼
   Appointments ←→ Students
       │
       ├──→ Follow-Up Sessions
       ├──→ Messages
       ├──→ Announcements
       ├──→ Notifications
       └──→ Reports
```

---

## 2. Activity Diagram

### Student Booking Appointment

```
START
  │
  ▼
Login
  │
  ▼
Book Appointment Page
  │
  ▼
Fill Form
  │
  ├──Date & Time
  ├──Counselor
  ├──Type (Individual/Group)
  ├──Method (Face-to-Face/Online)
  └──Purpose & Description
  │
  ▼
Submit
  │
  ▼
Receive Email
  │
  ▼
END
```

### Counselor Managing Appointment

```
START
  │
  ▼
Login
  │
  ▼
View Pending Appointments
  │
  ▼
Select Appointment
  │
  ▼
┌─────────────────────────────────┐
│      Choose Action              │
└─────────────┬───────────────────┘
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
  Approve   Reject   Reschedule
    │         │         │
    │         │         │
    └─────────┼─────────┘
              │
              ▼
        Notify Student
              │
              ▼
           END
```

### Admin Generating Report

```
START
  │
  ▼
Login as Admin
  │
  ▼
History Reports Page
  │
  ▼
Select Date Range
  │
  ▼
Select Filters
  │
  ▼
Click Export PDF
  │
  ▼
Download PDF
  │
  ▼
END
```

---

## 3. Sitemap

### Public Pages

```
┌─────────────┐
│   Landing   │
│    Page     │
└──────┬──────┘
       │
       ├────────────┐
       ▼            ▼
  ┌────────┐   ┌────────┐
  │ Login  │   │Register│
  └────────┘   └────────┘
```

---

### Student Pages

```
┌─────────────────────────────────┐
│        STUDENT PORTAL           │
└───────────────┬─────────────────┘
                │
                ▼
┌───────────────────────────────┐
│        /student/dashboard     │
│         (Dashboard)            │
└───────────────┬───────────────┘
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐
│Schedule│ │   My   │ │  PDS   │
│ Appt   │ │ Appts  │ │  Form  │
└────────┘ └────────┘ └────────┘
    │           │           │
    ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐
│Follow  │ │Profile │ │  View  │
│  Up    │ │        │ │ Announce│
└────────┘ └────────┘ └────────┘
                │           │
                ▼           ▼
          ┌────────┐  ┌────────┐
          │Messages│  │ Events │
          └────────┘  └────────┘
                │
                ▼
          ┌────────────┐
          │Notifications│
          └────────────┘
```

**Student Routes:**
- `/student/dashboard` - Dashboard
- `/student/appointment` - Schedule Appointment
- `/student/my-appointments` - My Appointments
- `/student/follow-up-sessions` - Follow-Up Sessions
- `/student/pds` - PDS Form
- `/student/profile` - Profile
- `/student/messages` - Messages
- `/student/notifications` - Notifications
- `/student/announcements` - Announcements
- `/student/events` - Events

---

### Counselor Pages

```
┌─────────────────────────────────┐
│       COUNSELOR PORTAL          │
└───────────────┬─────────────────┘
                │
                ▼
┌───────────────────────────────┐
│       /counselor/dashboard     │
│         (Dashboard)            │
└───────────────┬───────────────┘
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐
│Appoint │ │  View  │ │Availability│
│ ments  │ │  All   │ │         │
└────────┘ └────────┘ └────────┘
    │           │           │
    ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐
│History │ │Follow │ │  Set   │
│ Reports│ │  Up   │ │Availability│
└────────┘ └────────┘ └────────┘
    │           │
    ▼           ▼
┌────────┐ ┌────────┐
│Profile │ │Messages│
└────────┘ └────────┘
    │           │
    ▼           ▼
┌────────┐ ┌────────┐
│Announce│ │ Events │
└────────┘ └────────┘
    │
    ▼
┌────────────┐
│Notifications│
└────────────┘
```

**Counselor Routes:**
- `/counselor/dashboard` - Dashboard
- `/counselor/appointments` - Appointments
- `/counselor/view-all` - View All
- `/counselor/availability` - Availability
- `/counselor/history-reports` - Reports
- `/counselor/follow-up` - Follow-Up
- `/counselor/profile` - Profile
- `/counselor/messages` - Messages
- `/counselor/notifications` - Notifications
- `/counselor/announcements` - Announcements
- `/counselor/events` - Events

---

### Admin Pages

```
┌─────────────────────────────────┐
│         ADMIN PORTAL            │
└───────────────┬─────────────────┘
                │
                ▼
┌───────────────────────────────┐
│        /admin/dashboard       │
│         (Dashboard)            │
└───────────────┬───────────────┘
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐
│  All   │ │  Users │ │Counsel │
│Appoint │ │Manage │ │Manage  │
└────────┘ └────────┘ └────────┘
    │           │           │
    ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐
│History │ │  Add   │ │ Add    │
│ Reports│ │Counsel │ │  User  │
└────────┘ └────────┘ └────────┘
    │           │
    ▼           ▼
┌────────┐ ┌────────┐
│Resource│ │ Announce│
│Manage  │ │ ments  │
└────────┘ └────────┘
    │           │
    ▼           ▼
┌────────┐ ┌────────┐
│ Events │ │Admins  │
└────────┘ └────────┘
    │
    ▼
┌──────────────┐
│Database Health│
└──────────────┘
```

**Admin Routes:**
- `/admin/dashboard` - Dashboard
- `/admin/appointments` - All Appointments
- `/admin/view-users` - Manage Users
- `/admin/counselors` - Manage Counselors
- `/admin/resources` - Resources
- `/admin/history-reports` - Reports
- `/admin/announcements` - Announcements
- `/admin/events` - Events
- `/admin/admins-management` - Admins
- `/admin/database-health` - Database Health

---

*Simplified Version - 2026-04-06*