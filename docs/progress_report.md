# System Progress Report

## Completed Modules

| Module Name | Description | Status |
|-------------|-------------|--------|
| Middleware | Flask-CodeIgniter middleware integration for authentication and session management | ✓ Complete |
| Reschedule | Appointment rescheduling functionality for students and counselors | ✓ Complete |

---

## Undone / In Progress Modules

| Module Name | Description | Status |
|-------------|-------------|--------|
| Remove Cancelled Function | Remove cancellation functionality from the system | In Progress |
| Pending Status Rename | Change "Pending" status to "Waiting to Accept" in counselor view | In Progress |
| Student Concern | Student concern/issue submission feature | In Progress |
| Counselor Remarks | Allow counselors to add remarks to appointments | In Progress |
| Student Feedback | Enable students to provide feedback after appointments | In Progress |
| Time-Based PDF Report | Generate reports with timestamps in PDF export | In Progress |
| Sentiment Analysis | Add AI sentiment analysis for student feedback | In Progress |

---

## Overall Progress

- [ ] 0–25%
- [x] 26–50%
- [ ] 51–75%
- [ ] 76–100%

---

## Issues / Concerns

- PDF generation timing needs integration with existing report system
- Sentiment analysis requires external API or local NLP library integration
- Student feedback collection workflow needs UI updates
- Status renaming affects multiple views and database references

---

## Action Plan / Next Steps

1. Complete pending status rename across all views and database
2. Implement student concern submission form
3. Add counselor remarks input field in appointment details
4. Create student feedback form post-appointment
5. Integrate PDF timestamp generation in history reports
6. Implement sentiment analysis for feedback using NLP library

---

## Working Modules (All Functional)

| Module | Description |
|--------|-------------|
| Admin Appointments | Admin appointment management and viewing |
| Admin Get All Appointments | Retrieve and display all system appointments |
| Admin History Reports | Admin-side appointment history and reporting |
| Admin Users API | User management endpoints |
| Admin Counselors API | Counselor management endpoints |
| Admin Announcements | Admin announcement management |
| Admin Dashboard | Admin dashboard with analytics |
| Student Appointment Scheduling | Student can schedule appointments |
| Student Dashboard | Student dashboard |
| Student Profile | Student profile management |
| Student PDS | Personal Data Sheet management |
| Student Notifications | Student notifications |
| Student Events | Student events viewing |
| Student Follow Up Sessions | Follow-up session management |
| Student Message | Student messaging |
| Counselor Appointments | Counselor appointment management |
| Counselor Get All Appointments | View all appointments for counselor |
| Counselor History Reports | Generate and view appointment history reports |
| Counselor Dashboard | Counselor dashboard |
| Counselor Profile | Counselor profile management |
| Counselor Availability | Counselor availability management |
| Counselor Announcements | Counselor announcements |
| Counselor Follow Up | Follow-up session management |
| Counselor Events | Counselor events |
| Middleware Integration | Flask-CodeIgniter authentication middleware |
| Reschedule Functionality | Appointment rescheduling for students/counselors |
| Email Notifications | Email templates and notification service |
| Database Migrations | Schema management including counselor remarks |
| Authentication | Login, logout, password management |
| Filter Data | Data filtering for appointments/sessions |

---

## System Progress Monitoring Rubric (60 Points)

| Criteria | Excellent (10–9 pts) | Good (8–7 pts) | Fair (6–5 pts) |
|----------|---------------------|---------------|---------------|
| Completeness of Report | All sections are complete, clear, and detailed | Minor missing details; mostly complete | Several sections incomplete or unclear |
| System Progress | Significant progress; multiple modules working and demonstrable | Moderate progress; at least 1–2 modules working | Minimal progress; mostly planning or incomplete |
| Quality of Output | Outputs are functional, organized, and well-implemented | Mostly functional with minor errors | Partially working or inconsistent output |
| Task Distribution | Clear roles: all members actively contributed | Most members contributed; minor imbalance | Unequal participation; unclear roles |
| Issues & Problem Handling | Issues clearly identified with logical solutions | Issues identified but solutions unclear | Minimal or unclear problem identification |
| Action Plan / Next Steps | Clear, specific, and realistic next steps | General next steps but lacks detail | Vague or no clear plan |

**Total Score: _____ / 60**

---

