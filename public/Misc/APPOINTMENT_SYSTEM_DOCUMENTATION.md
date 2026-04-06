# Counselign Appointment & Follow-up System Documentation

## Table of Contents
1. [Overview](#overview)
2. [Student Appointment System](#student-appointment-system)
3. [Appointment Management](#appointment-management)
4. [Counselor Follow-up System](#counselor-follow-up-system)
5. [Calendar System](#calendar-system)
6. [Backend API Endpoints](#backend-api-endpoints)
7. [Database Schema](#database-schema)
8. [Business Logic & Rules](#business-logic--rules)
9. [Mobile Implementation Guide](#mobile-implementation-guide)

---

## Overview

The Counselign appointment system manages counseling appointments between students and counselors, including:
- **Student Appointment Scheduling**: Students can book individual or group consultation appointments
- **Appointment Management**: Students can view, edit (pending only), and cancel their appointments
- **Follow-up Sessions**: Counselors can create follow-up appointments for completed sessions
- **Double Booking Prevention**: System prevents scheduling conflicts
- **Group Consultation**: Supports up to 5 students per group session
- **Real-time Availability**: Dynamic calendar showing counselor availability

---

## Student Appointment System

### File: `app/Views/student/student_schedule_appointment.php`

#### Features

1. **Appointment Form**
   - **Consultation Type**: Individual or Group Consultation
   - **Preferred Date**: Must be at least 1 day in advance
   - **Counselor Preference**: Select specific counselor or "No preference"
   - **Preferred Time**: 30-minute time slots from 8:00 AM - 5:00 PM (with lunch break 11:30 AM - 1:00 PM)
   - **Method Type**: In-person, Online (Video), Online (Audio only)
   - **Purpose**: Counseling, Psycho-Social Support, Initial Interview
   - **Description**: Optional brief description
   - **Informed Consent**: Required acknowledgment checkboxes

2. **Counselor Schedule Sidebar**
   - **Interactive Calendar**: Month view with appointment counts and fully booked indicators
   - **Daily Schedule**: Shows available counselors and their time slots per day
   - **Real-time Updates**: Displays current booking status

#### Frontend Logic (`public/js/student/student_schedule_appointment.js`)

##### Key Functions

**1. Eligibility Check**
```javascript
checkAppointmentEligibility()
```
- Checks if student has:
  - Pending appointment
  - Approved upcoming appointment
  - Pending follow-up session
- Disables form if any exist
- **Endpoint**: `GET /student/check-appointment-eligibility`

**2. Dynamic Time Slot Filtering**
```javascript
refreshTimeSlotsForDate(dateStr)
```
- Fetches counselor availability for selected date
- Filters out already booked time slots
- Considers consultation type (individual vs group)
- Shows only available 30-minute slots
- **Logic**:
  - For **Individual Consultation**: Shows slots not booked by ANY appointment
  - For **Group Consultation**: Shows slots where group count < 5 and no individual appointments

**3. Counselor Availability Filtering**
```javascript
loadCounselorsByAvailability(preferredDate, preferredTime)
```
- Loads counselors available for specific date/time
- Uses overlap detection for time ranges
- **Endpoint**: `GET /student/get-counselors-by-availability`

**4. Group Slot Availability Check**
```javascript
checkGroupSlotAvailability(date, time, counselorId)
```
- Checks if group consultation slot is available (< 5 bookings)
- Returns available slots count and booked count
- **Endpoint**: `GET /student/appointments/check-group-slots`

**5. Double Booking Prevention**
```javascript
checkCounselorConflicts()
```
- Validates counselor availability before submission
- Checks for conflicting appointments
- Shows conflict modal if unavailable
- **Endpoint**: `GET /student/check-counselor-conflicts`

**6. Form Submission**
```javascript
setupFormSubmission()
```
- Validates all required fields
- Checks acknowledgment checkboxes
- Prevents submission if conflicts exist
- **Endpoint**: `POST /student/appointment/save`

**7. Custom Calendar Integration**
```javascript
initializeCustomCalendarPicker()
```
- Initializes date picker with counselor availability
- Disables unavailable dates
- Shows appointment counts per day
- Shows "fully booked" indicator

**8. Calendar Stats Display**
```javascript
initializeCounselorsCalendarDrawer()
```
- Month view calendar with:
  - Appointment count badges
  - Fully booked indicators
  - Today highlight
  - Click to view counselor list for date
- **Endpoint**: `GET /student/calendar/daily-stats`

#### Consultation Types

**Individual Consultation**
- One-on-one session
- Blocks entire time slot
- Cannot share slot with group consultations

**Group Consultation**
- Up to 5 participants
- Multiple students can book same slot
- Blocked if any individual consultation exists in that slot

---

## Appointment Management

### File: `app/Views/student/my_appointments.php`

#### Features

1. **Approved Appointments Section**
   - Displays the most recent approved appointment as a **digital ticket**
   - Includes QR code for verification
   - Download ticket as PDF functionality
   - Shows all appointment details

2. **Pending Appointments Section**
   - Editable appointment forms (inline editing)
   - Real-time counselor and time slot filtering
   - Edit and Cancel buttons
   - Delete option for pending appointments

3. **Appointments Tabs**
   - **All Appointments**: Complete history
   - **Rejected**: Appointments rejected by counselor/admin with reasons
   - **Completed**: Finished appointments
   - **Cancelled**: Cancelled appointments with reasons

4. **Counselor Schedule Drawer**
   - Side drawer with calendar
   - Same functionality as schedule page
   - Toggle button for easy access

5. **Search and Filter**
   - Search by: name, date, counselor, purpose
   - Month filter for date range

#### Frontend Logic (`public/js/student/my_appointments.js`)

##### Key Functions

**1. Fetch Appointments**
```javascript
fetchAppointments()
```
- Retrieves all student appointments
- **Endpoint**: `GET /student/appointments/get-my-appointments`
- Response includes:
  - appointment_id
  - student_id
  - preferred_date
  - preferred_time
  - consultation_type
  - method_type
  - purpose
  - counselor_preference
  - counselor_name
  - status
  - description
  - cancellation_reason
  - rejection_reason

**2. Display Approved Appointments**
```javascript
displayApprovedAppointments(appointments)
```
- Creates ticket-style display
- Generates QR code with appointment data
- Adds download button event listener

**3. Display Pending Appointments**
```javascript
displayPendingAppointments(appointments)
```
- Creates editable forms for each pending appointment
- Loads counselor list
- Adds Edit/Cancel/Delete button handlers

**4. Edit Appointment**
```javascript
openEditModal(appointmentId)
```
- Opens modal with current appointment data
- Initializes custom calendar picker for edit
- Filters time slots based on counselor availability
- Validates changes before saving

**Edit Modal Features:**
- Date picker with availability checking
- Time slot dropdown (filtered by availability)
- Consultation type selector
- Method type selector
- Purpose selector
- Counselor preference selector
- Description text area

**5. Save Edited Appointment**
```javascript
saveEdit()
```
- Validates form data
- Checks for conflicts
- Updates appointment
- **Endpoint**: `POST /student/appointments/update`
- Refreshes appointment list on success

**6. Cancel Appointment**
```javascript
openCancelModal(appointmentId)
```
- Opens cancellation reason modal
- Requires cancellation reason
- Updates appointment status to "cancelled"

**7. Confirm Cancellation**
```javascript
confirmCancel()
```
- Submits cancellation with reason
- **Endpoint**: `POST /student/appointments/cancel`
- Updates appointment list

**8. Delete Appointment**
```javascript
openDeleteModal(appointmentId)
```
- Confirms deletion (pending appointments only)
- Permanently removes appointment
- **Endpoint**: `DELETE /student/appointments/delete/:id`

**9. Download Ticket**
```javascript
downloadAppointmentTicket(appointment)
```
- Generates PDF ticket using jsPDF
- Includes QR code
- Downloads automatically
- Tracks download
- **Endpoint**: `POST /student/appointments/track-download`

**10. Edit Calendar Picker**
```javascript
initializeEditModalCalendarPicker()
```
- Initializes custom calendar for edit modal
- Shows counselor availability for selected counselor
- Disables unavailable dates
- Updates time slots when date changes

**11. Edit Conflict Checking**
```javascript
checkEditConflicts(appointmentId, date, time, counselorId, consultationType)
```
- Checks if edited appointment causes conflicts
- Excludes current appointment from conflict check
- **Endpoint**: `GET /student/check-edit-conflicts`

**12. Filter Appointments**
```javascript
filterAppointments()
```
- Search functionality across all fields
- Month filter for date range
- Real-time filtering as user types

**13. Counselor Schedule Drawer**
```javascript
setupCounselorSchedulesInDrawer()
```
- Toggle drawer functionality
- Lazy load schedules when opened
- Same calendar as schedule page

---

## Counselor Follow-up System

### File: `app/Views/counselor/follow_up.php`

#### Features

1. **Completed Appointments List**
   - Shows all completed appointments for counselor
   - Search functionality
   - Follow-up count indicator
   - Pending follow-up badge
   - Next pending follow-up date

2. **Follow-up Session Management**
   - Create new follow-up from completed appointment
   - View all follow-up sessions for an appointment
   - Edit pending follow-up sessions
   - Cancel follow-up sessions
   - Complete follow-up sessions

3. **Follow-up Modal**
   - View all follow-ups in chain
   - Status indicators (Pending, Completed, Cancelled)
   - Timeline view of follow-up history

#### Frontend Logic (`public/js/counselor/follow_up.js`)

##### Key Functions

**1. Load Completed Appointments**
```javascript
loadCompletedAppointments(searchTerm)
```
- Fetches completed appointments for counselor
- **Endpoint**: `GET /counselor/follow-up/completed-appointments?search=term`
- Response includes:
  - Appointment details
  - Student name and email
  - Follow-up count
  - Pending follow-up count
  - Next pending follow-up date

**2. Open Follow-up Sessions Modal**
```javascript
openFollowUpSessionsModal(appointmentId)
```
- Displays all follow-up sessions for appointment
- **Endpoint**: `GET /counselor/follow-up/sessions?parent_appointment_id=id`
- Shows:
  - Follow-up session details
  - Status (Pending, Completed, Cancelled)
  - Date and time
  - Consultation type
  - Description and reason

**3. Create Follow-up Modal**
```javascript
openCreateFollowUpModal(parentAppointmentId, studentId)
```
- Opens form to create new follow-up
- Initializes date picker
- Loads counselor availability
- Filters available time slots

**Create Follow-up Form Fields:**
- **Parent Appointment ID**: Hidden (auto-filled)
- **Student ID**: Hidden (auto-filled)
- **Preferred Date**: Date picker with availability
- **Preferred Time**: Dropdown with available slots
- **Consultation Type**: Individual Counseling, Career Guidance, Academic Counseling, Personal Development, Crisis Intervention
- **Description**: Optional description
- **Reason**: Optional reason for follow-up

**4. Save Follow-up**
```javascript
saveFollowUp()
```
- Validates form data
- Checks for double booking
- Creates follow-up appointment
- **Endpoint**: `POST /counselor/follow-up/create`
- Request body:
```json
{
  "parent_appointment_id": "123",
  "student_id": "STU001",
  "preferred_date": "2025-11-20",
  "preferred_time": "10:00 AM - 10:30 AM",
  "consultation_type": "Individual Counseling",
  "description": "Follow-up discussion on stress management",
  "reason": "Continue previous session topics"
}
```

**5. Edit Follow-up Modal**
```javascript
openEditFollowUpModal(followUpId)
```
- Fetches current follow-up data
- **Endpoint**: `GET /counselor/follow-up/session?id=followUpId`
- Pre-fills form with existing data
- Only allows editing pending follow-ups

**6. Update Follow-up**
```javascript
updateFollowUp()
```
- Validates changes
- Checks for conflicts (excluding current follow-up)
- Updates follow-up appointment
- **Endpoint**: `POST /counselor/follow-up/edit`
- Request body:
```json
{
  "id": "456",
  "preferred_date": "2025-11-21",
  "preferred_time": "2:00 PM - 2:30 PM",
  "consultation_type": "Career Guidance",
  "description": "Updated description",
  "reason": "Updated reason"
}
```

**7. Cancel Follow-up**
```javascript
openCancelFollowUpModal(followUpId)
```
- Opens modal requiring cancellation reason
- Updates follow-up status to "cancelled"
- **Endpoint**: `POST /counselor/follow-up/cancel`

**8. Complete Follow-up**
```javascript
completeFollowUp(followUpId)
```
- Marks follow-up as completed
- Allows creating another follow-up from this completed session
- **Endpoint**: `POST /counselor/follow-up/complete`

**9. Load Available Time Slots**
```javascript
loadAvailableTimeSlots(date, excludeFollowUpId)
```
- Fetches counselor's availability for date
- Gets booked times (appointments + follow-ups)
- Excludes current follow-up if editing
- Shows only unbooked 30-minute slots
- **Endpoints**:
  - `GET /counselor/follow-up/availability-by-weekday`
  - `GET /counselor/follow-up/booked-times?date=YYYY-MM-DD&exclude_follow_up_id=id`

**10. Search Completed Appointments**
```javascript
setupSearch()
```
- Real-time search across:
  - Student ID
  - Student name
  - Student email
  - Appointment date
  - Time
  - Method type
  - Purpose
  - Reason

---

## Calendar System

### File: `public/js/utils/customCalendarPicker.js`

#### CustomCalendarPicker Class

**Purpose**: Dynamic date picker that integrates with counselor availability and booking status

#### Features

1. **Availability-Based Date Enabling**
   - Disables dates where no counselors are available
   - Highlights dates with appointments
   - Shows "fully booked" indicator

2. **Role-Based Functionality**
   - **Student Mode**: Shows counselor availability, prevents booking unavailable dates
   - **Counselor Mode**: Shows own availability, prevents booking on days without time slots

3. **Dynamic Updates**
   - Updates when counselor selection changes
   - Updates when consultation type changes
   - Real-time booking status

#### Constructor Options
```javascript
new CustomCalendarPicker({
  inputId: 'preferredDate',        // ID of date input element
  userRole: 'student',              // 'student' or 'counselor'
  counselorId: null,                // Specific counselor ID (optional)
  consultationType: null,           // Filter by consultation type
  excludeAppointmentId: null,       // Exclude appointment when editing
  onDateSelect: (dateString) => {}  // Callback when date selected
})
```

#### Key Methods

**1. Initialize**
```javascript
init()
```
- Sets up calendar HTML structure
- Attaches event listeners
- Loads initial month
- Fetches availability data

**2. Render Calendar**
```javascript
renderCalendar(year, month)
```
- Generates calendar grid
- Applies availability styling
- Shows appointment counts
- Highlights today
- **Data Source**: Fetches from `student/calendar/daily-stats` or `counselor/follow-up/availability-by-weekday`

**3. Update Counselor**
```javascript
updateCounselorId(counselorId)
```
- Changes counselor filter
- Re-fetches availability
- Re-renders calendar

**4. Update Consultation Type**
```javascript
updateConsultationType(consultationType)
```
- Changes consultation type filter
- Re-fetches availability (group vs individual)
- Re-renders calendar

**5. Fetch Daily Stats**
```javascript
fetchDailyStats(year, month)
```
- Gets appointment counts per day
- Gets fully booked status
- **Endpoint**: `GET /student/calendar/daily-stats?year=2025&month=11`
- Response:
```json
{
  "status": "success",
  "stats": {
    "2025-11-17": {
      "count": 3,
      "fullyBooked": false
    },
    "2025-11-18": {
      "count": 5,
      "fullyBooked": true
    }
  }
}
```

**6. Check Date Availability**
```javascript
isDateAvailable(dateString)
```
- Checks if any counselor is available
- Checks if not fully booked
- Returns boolean

**7. Handle Date Selection**
```javascript
selectDate(dateString)
```
- Updates input field
- Triggers callback
- Closes calendar popup
- Validates selection

#### Calendar Indicators

**Visual States:**
- **Today**: Blue border
- **Has Appointments**: Blue badge with count
- **Fully Booked**: Red background, "Fully booked" label
- **Selected**: Bold border
- **Unavailable**: Grayed out, not clickable
- **Other Month**: Faded appearance

---

## Backend API Endpoints

### Student Appointment Endpoints

#### 1. Check Appointment Eligibility
```
GET /student/check-appointment-eligibility
```
**Purpose**: Check if student can schedule new appointment

**Response:**
```json
{
  "status": "success",
  "hasPending": false,
  "hasApproved": false,
  "hasPendingFollowUp": false,
  "allowed": true
}
```

**Logic** (`app/Controllers/Student/Appointment.php:checkAppointmentEligibility`):
- Query `appointments` table for pending/approved appointments
- Query `follow_up_appointments` table for pending follow-ups
- Student can only book if all three are false

---

#### 2. Get Counselors
```
GET /student/get-counselors
```
**Purpose**: Get list of all available counselors

**Response:**
```json
{
  "status": "success",
  "counselors": [
    {
      "counselor_id": "COUN001",
      "name": "Dr. Jane Smith",
      "specialization": "Career Counseling",
      "profile_picture": "path/to/image.jpg",
      "last_activity": "2025-11-17 10:30:00",
      "last_login": "2025-11-17 08:00:00",
      "logout_time": null
    }
  ]
}
```

**Logic**:
- Joins `counselors` and `users` tables
- Returns counselor details with activity status

---

#### 3. Get Counselors by Availability
```
GET /student/get-counselors-by-availability?date=2025-11-20&time=10:00 AM - 10:30 AM&day=Monday&from=10:00&to=10:30&timeMode=overlap
```
**Purpose**: Get counselors available for specific date/time

**Parameters:**
- `date`: YYYY-MM-DD format
- `time`: Human-readable time range (optional)
- `day`: Day of week (Monday-Sunday)
- `from`: 24-hour format start time (HH:MM)
- `to`: 24-hour format end time (HH:MM)
- `timeMode`: "overlap" for range matching

**Response:**
```json
{
  "status": "success",
  "counselors": [
    {
      "counselor_id": "COUN001",
      "name": "Dr. Jane Smith",
      "specialization": "Career Counseling"
    }
  ],
  "dayOfWeek": "Monday",
  "preferredTime": "10:00 AM - 10:30 AM"
}
```

**Logic** (`app/Controllers/Student/Appointment.php:getCounselorsByAvailability`):
1. Gets all counselors
2. For each counselor:
   - Queries `counselor_availability` table
   - Checks if `available_days` = requested day
   - Parses `time_scheduled` field (can be "HH:MM-HH:MM" or "H:MM AM-H:MM PM")
   - Checks for time range overlap
3. Returns only available counselors

**Overlap Detection Logic:**
```php
private function rangesOverlap($aStart, $aEnd, $bStart, $bEnd): bool
{
    return ($aStart < $bEnd) && ($bStart < $aEnd);
}
```

---

#### 4. Get Counselor Schedules
```
GET /student/get-counselor-schedules
```
**Purpose**: Get all counselor schedules grouped by day

**Response:**
```json
{
  "status": "success",
  "schedules": {
    "Monday": [
      {
        "counselor_id": "COUN001",
        "counselor_name": "Dr. Jane Smith",
        "time_scheduled": "8:00 AM-12:00 PM, 1:00 PM-5:00 PM"
      }
    ],
    "Tuesday": [...],
    ...
  }
}
```

**Logic**:
- Queries `counselor_availability` table
- Groups by `available_days`
- Returns time slots per counselor per day

---

#### 5. Get Booked Times for Date
```
GET /student/appointments/booked-times?date=2025-11-20&counselor_id=COUN001&consultation_type=Individual Consultation
```
**Purpose**: Get already booked time slots for a specific date

**Parameters:**
- `date`: YYYY-MM-DD format (required)
- `counselor_id`: Filter by counselor (optional)
- `consultation_type`: Individual or Group Consultation (required for logic)

**Response:**
```json
{
  "status": "success",
  "booked": [
    "8:00 AM - 8:30 AM",
    "9:00 AM - 9:30 AM",
    "10:00 AM - 10:30 AM"
  ]
}
```

**Logic** (`app/Controllers/Student/Appointment.php:getBookedTimesForDate`):

**For Individual Consultation:**
- Returns ALL booked time slots (both individual and group)
- Individual consultations cannot be booked in any slot with existing bookings

**For Group Consultation:**
- Returns ONLY time slots where:
  - Any individual consultation exists (blocks entire slot)
  - 5+ group consultations exist (full capacity)
- Group consultations can be booked in slots with < 5 group bookings and no individual

---

#### 6. Check Group Slot Availability
```
GET /student/appointments/check-group-slots?date=2025-11-20&time=10:00 AM - 10:30 AM&counselor_id=COUN001
```
**Purpose**: Check how many group consultation slots are available

**Response:**
```json
{
  "status": "success",
  "isAvailable": true,
  "bookedSlots": 2,
  "availableSlots": 3
}
```

**Logic**:
1. Count appointments with:
   - Same date, time
   - consultation_type = "Group Consultation"
   - status IN ('pending', 'approved')
   - Optional: same counselor
2. Calculate: `availableSlots = 5 - bookedSlots`
3. `isAvailable = availableSlots > 0`

---

#### 7. Check Counselor Conflicts
```
GET /student/check-counselor-conflicts?counselor_id=COUN001&date=2025-11-20&time=10:00 AM - 10:30 AM
```
**Purpose**: Check if counselor has conflicting appointment

**Response:**
```json
{
  "status": "success",
  "hasConflict": false,
  "message": "",
  "conflictType": ""
}
```

**Conflict Types:**
- "counselor_booked": Counselor has appointment at this time
- "double_booking": Database trigger prevented booking

**Logic**:
1. Queries `appointments` table
2. Checks for matching:
   - `counselor_preference`
   - `preferred_date`
   - `preferred_time`
   - status IN ('pending', 'approved')
3. Returns conflict if exists

---

#### 8. Get Calendar Daily Stats
```
GET /student/calendar/daily-stats?year=2025&month=11
```
**Purpose**: Get appointment counts and fully booked status for each day in month

**Response:**
```json
{
  "status": "success",
  "stats": {
    "2025-11-17": {
      "count": 3,
      "fullyBooked": false
    },
    "2025-11-18": {
      "count": 8,
      "fullyBooked": true
    }
  }
}
```

**Logic** (`app/Controllers/Student/Appointment.php:getCalendarDailyStats`):
1. Get all approved appointments for the month
2. Group by `preferred_date`
3. Count appointments per date
4. Check if fully booked:
   - Get counselor count and their availability
   - Calculate total possible slots per day
   - Compare booked vs total
5. Return stats object

---

#### 9. Save Appointment
```
POST /student/appointment/save
```
**Purpose**: Create new appointment

**Request Body (form-urlencoded):**
```
consultationType=Individual Consultation
preferredDate=2025-11-20
counselorPreference=COUN001
preferredTime=10:00 AM - 10:30 AM
methodType=In-person
purpose=Counseling
description=Need help with stress management
```

**Response:**
```json
{
  "status": "success",
  "message": "Your appointment has been scheduled successfully. Please wait for admin approval.",
  "appointment_id": 123
}
```

**Logic** (`app/Controllers/Student/Appointment.php:save`):
1. **Validation**:
   - Check all required fields
   - Validate date is in future
   - Check date is at least 1 day ahead
2. **Double Booking Check**:
   - **Individual Consultation**:
     - Query for ANY booking (individual or group) at same date/time/counselor
     - Reject if any exists
   - **Group Consultation**:
     - Check for individual consultation (blocks slot)
     - Count group consultations (max 5)
     - Reject if individual exists or group >= 5
3. **Insert**:
   - Insert into `appointments` table
   - Set `status = 'pending'`
   - Send notification email to counselor
   - Create notification record
   - Track user activity
4. **Error Handling**:
   - Catch database trigger errors
   - Return user-friendly messages

**Database Trigger**: `prevent_double_booking`
- Additional safeguard at database level
- Prevents counselor from having multiple appointments at same time
- Fires before INSERT on `appointments` table

---

#### 10. Get My Appointments
```
GET /student/appointments/get-my-appointments
```
**Purpose**: Get all appointments for logged-in student

**Response:**
```json
{
  "success": true,
  "appointments": [
    {
      "id": 123,
      "student_id": "STU001",
      "preferred_date": "2025-11-20",
      "preferred_time": "10:00 AM - 10:30 AM",
      "consultation_type": "Individual Consultation",
      "method_type": "In-person",
      "purpose": "Counseling",
      "counselor_preference": "COUN001",
      "counselor_name": "Dr. Jane Smith",
      "description": "Stress management help",
      "status": "pending",
      "created_at": "2025-11-17 10:00:00",
      "cancellation_reason": null,
      "rejection_reason": null
    }
  ]
}
```

**Logic**:
- Joins `appointments`, `counselors`, and `users` tables
- Filters by `student_id` = current user
- Orders by `created_at DESC`
- Includes counselor name from join

---

#### 11. Update Appointment
```
POST /student/appointments/update
```
**Purpose**: Update pending appointment

**Request Body (JSON):**
```json
{
  "id": 123,
  "preferred_date": "2025-11-21",
  "preferred_time": "2:00 PM - 2:30 PM",
  "consultation_type": "Individual Consultation",
  "method_type": "Online (Video)",
  "purpose": "Counseling",
  "counselor_preference": "COUN002",
  "description": "Updated description"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Appointment updated successfully"
}
```

**Logic**:
1. **Authorization**:
   - Verify appointment belongs to current student
   - Check status is "pending" (only pending can be edited)
2. **Conflict Check**:
   - Run same validation as save
   - Exclude current appointment from conflict check
3. **Update**:
   - Update all editable fields
   - Keep status as "pending"
   - Send notification to counselor about change
4. **Error Handling**:
   - Return error if appointment not found
   - Return error if not pending
   - Return error if conflicts exist

---

#### 12. Cancel Appointment
```
POST /student/appointments/cancel
```
**Purpose**: Cancel appointment with reason

**Request Body (JSON):**
```json
{
  "id": 123,
  "reason": "Unable to attend due to schedule conflict"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Appointment cancelled successfully"
}
```

**Logic**:
1. Verify appointment belongs to student
2. Check status is not already "cancelled" or "completed"
3. Update:
   - `status = 'cancelled'`
   - `cancellation_reason = reason`
4. Send notification to counselor
5. Track activity

---

#### 13. Delete Appointment
```
DELETE /student/appointments/delete/:id
```
**Purpose**: Permanently delete pending appointment

**Response:**
```json
{
  "status": "success",
  "message": "Appointment deleted successfully"
}
```

**Logic**:
1. Verify appointment belongs to student
2. Check status is "pending" (only pending can be deleted)
3. Delete from database
4. Send notification to counselor

---

### Counselor Follow-up Endpoints

#### 14. Get Completed Appointments
```
GET /counselor/follow-up/completed-appointments?search=term
```
**Purpose**: Get completed appointments for counselor with follow-up info

**Response:**
```json
{
  "status": "success",
  "appointments": [
    {
      "id": 123,
      "student_id": "STU001",
      "student_name": "Smith, John",
      "student_email": "john@example.com",
      "preferred_date": "2025-11-15",
      "preferred_time": "10:00 AM - 10:30 AM",
      "consultation_type": "Individual Consultation",
      "method_type": "In-person",
      "purpose": "Counseling",
      "status": "completed",
      "follow_up_count": 2,
      "pending_follow_up_count": 1,
      "next_pending_date": "2025-11-22"
    }
  ],
  "search_term": "term"
}
```

**Logic** (`app/Controllers/Counselor/FollowUp.php:getCompletedAppointments`):
1. Join `appointments`, `users`, `student_personal_info` tables
2. Subquery for follow-up counts:
   ```sql
   (SELECT COUNT(*) FROM follow_up_appointments 
    WHERE parent_appointment_id = appointments.id) as follow_up_count
   ```
3. Subquery for pending follow-up count
4. Subquery for next pending date (MIN date of pending follow-ups)
5. Filter by:
   - `counselor_preference` = current counselor
   - `status = 'completed'`
6. Search filter (if provided):
   - student_id, username, email, name, date, time, method, purpose, reason
7. Order by:
   - `pending_follow_up_count` DESC (prioritize pending follow-ups)
   - `next_pending_date` ASC
   - `preferred_date` DESC

---

#### 15. Get Follow-up Sessions
```
GET /counselor/follow-up/sessions?parent_appointment_id=123
```
**Purpose**: Get all follow-up sessions for an appointment

**Response:**
```json
{
  "status": "success",
  "follow_up_sessions": [
    {
      "id": 456,
      "parent_appointment_id": 123,
      "student_id": "STU001",
      "counselor_id": "COUN001",
      "preferred_date": "2025-11-22",
      "preferred_time": "2:00 PM - 2:30 PM",
      "consultation_type": "Individual Counseling",
      "description": "Follow-up on stress management",
      "reason": "Continue discussion from previous session",
      "status": "pending",
      "created_at": "2025-11-17 10:00:00"
    }
  ]
}
```

**Logic**:
- Query `follow_up_appointments` table
- Filter by `parent_appointment_id`
- Order by `preferred_date` DESC
- Returns all follow-ups (pending, completed, cancelled)

---

#### 16. Get Follow-up Session
```
GET /counselor/follow-up/session?id=456
```
**Purpose**: Get specific follow-up session details

**Response:**
```json
{
  "status": "success",
  "session": {
    "id": 456,
    "parent_appointment_id": 123,
    "student_id": "STU001",
    "counselor_id": "COUN001",
    "preferred_date": "2025-11-22",
    "preferred_time": "2:00 PM - 2:30 PM",
    "consultation_type": "Individual Counseling",
    "description": "Follow-up session",
    "reason": "Continue therapy",
    "status": "pending"
  }
}
```

**Logic**:
1. Find follow-up by ID
2. Verify counselor owns this follow-up (authorization)
3. Return session details

---

#### 17. Get Counselor Availability
```
GET /counselor/follow-up/availability?date=2025-11-20
```
**Purpose**: Get counselor's available time slots for date

**Response:**
```json
{
  "status": "success",
  "day_of_week": "Wednesday",
  "time_slots": [
    "8:00 AM-12:00 PM",
    "1:00 PM-5:00 PM"
  ]
}
```

**Logic**:
1. Convert date to day of week
2. Query `counselor_availability` table
3. Filter by `counselor_id` and `available_days`
4. Return `time_scheduled` values

---

#### 18. Get Availability by Weekday
```
GET /counselor/follow-up/availability-by-weekday
```
**Purpose**: Get weekdays where counselor has time slots scheduled

**Response:**
```json
{
  "status": "success",
  "weekdays_with_slots": [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday"
  ]
}
```

**Logic**:
1. Query `counselor_availability` for counselor
2. Get distinct `available_days` where `time_scheduled IS NOT NULL`
3. Return array of weekday names

---

#### 19. Get Booked Times for Date (Counselor)
```
GET /counselor/follow-up/booked-times?date=2025-11-20&exclude_follow_up_id=456
```
**Purpose**: Get booked time slots for counselor on date

**Parameters:**
- `date`: YYYY-MM-DD (required)
- `exclude_follow_up_id`: Exclude this follow-up when editing (optional)

**Response:**
```json
{
  "status": "success",
  "date": "2025-11-20",
  "booked": [
    "8:00 AM - 8:30 AM",
    "10:00 AM - 10:30 AM"
  ]
}
```

**Logic** (`app/Controllers/Counselor/FollowUp.php:getBookedTimesForDate`):
1. Query `appointments` table:
   - `preferred_date` = date
   - `counselor_preference` = current counselor
   - `status` IN ('pending', 'approved')
2. Query `follow_up_appointments` table:
   - `preferred_date` = date
   - `counselor_id` = current counselor
   - `status = 'pending'`
   - `id != exclude_follow_up_id` (if provided)
3. Merge time slots from both queries
4. Remove duplicates
5. Return array of booked times

---

#### 20. Create Follow-up
```
POST /counselor/follow-up/create
```
**Purpose**: Create new follow-up appointment

**Request Body (form-data):**
```
parent_appointment_id=123
student_id=STU001
preferred_date=2025-11-22
preferred_time=2:00 PM - 2:30 PM
consultation_type=Individual Counseling
description=Follow-up session for stress management
reason=Continue discussing coping strategies
```

**Response:**
```json
{
  "status": "success",
  "message": "Follow-up appointment created successfully",
  "follow_up_id": 456
}
```

**Logic** (`app/Controllers/Counselor/FollowUp.php:createFollowUp`):
1. **Authorization**:
   - Verify counselor is logged in
   - Get counselor ID from session
2. **Validation**:
   - Verify parent appointment exists and is completed
   - Verify parent appointment belongs to this counselor
   - Check all required fields
   - Validate date is in future
3. **Conflict Check**:
   - Check counselor has availability on selected weekday
   - Check time slot is within counselor's schedule
   - Check for existing appointments/follow-ups at same time
4. **Insert**:
   - Insert into `follow_up_appointments` table
   - Fields: parent_appointment_id, student_id, counselor_id, preferred_date, preferred_time, consultation_type, description, reason
   - Set `status = 'pending'`
5. **Notifications**:
   - Send email to student
   - Create notification record
6. **Activity Tracking**:
   - Update counselor activity

---

#### 21. Edit Follow-up
```
POST /counselor/follow-up/edit
```
**Purpose**: Update pending follow-up appointment

**Request Body (form-data):**
```
id=456
preferred_date=2025-11-23
preferred_time=3:00 PM - 3:30 PM
consultation_type=Career Guidance
description=Updated description
reason=Updated reason
```

**Response:**
```json
{
  "status": "success",
  "message": "Follow-up appointment updated successfully"
}
```

**Logic** (`app/Controllers/Counselor/FollowUp.php:editFollowUp`):
1. **Authorization**:
   - Verify follow-up exists
   - Verify counselor owns this follow-up
   - Check status is "pending" (only pending can be edited)
2. **Validation**:
   - Check all required fields
   - Validate date is in future
3. **Conflict Check**:
   - Check counselor availability
   - Check for conflicts (excluding current follow-up)
4. **Update**:
   - Update fields in `follow_up_appointments`
   - Keep `status = 'pending'`
5. **Notifications**:
   - Send email to student about change
   - Create notification record

---

#### 22. Cancel Follow-up
```
POST /counselor/follow-up/cancel
```
**Purpose**: Cancel follow-up appointment

**Request Body (form-data):**
```
id=456
reason=Student requested cancellation
```

**Response:**
```json
{
  "status": "success",
  "message": "Follow-up appointment cancelled successfully"
}
```

**Logic**:
1. Verify follow-up exists and belongs to counselor
2. Check status is not already "cancelled" or "completed"
3. Update:
   - `status = 'cancelled'`
   - `cancellation_reason = reason`
4. Send notification to student

---

#### 23. Complete Follow-up
```
POST /counselor/follow-up/complete
```
**Purpose**: Mark follow-up as completed

**Request Body (form-data):**
```
id=456
```

**Response:**
```json
{
  "status": "success",
  "message": "Follow-up appointment marked as completed"
}
```

**Logic**:
1. Verify follow-up exists and belongs to counselor
2. Check status is "pending"
3. Update `status = 'completed'`
4. Send notification to student

---

## Database Schema

### Tables

#### 1. `appointments`

**Purpose**: Stores all student appointment bookings

| Column | Type | Description |
|--------|------|-------------|
| id | INT(11) AUTO_INCREMENT | Primary key |
| student_id | VARCHAR(10) | Foreign key to users.user_id |
| preferred_date | DATE | Appointment date |
| preferred_time | VARCHAR(50) | Time slot (e.g., "10:00 AM - 10:30 AM") |
| consultation_type | VARCHAR(50) | "Individual Consultation" or "Group Consultation" |
| method_type | VARCHAR(50) | "In-person", "Online (Video)", "Online (Audio only)" |
| purpose | VARCHAR(100) | "Counseling", "Psycho-Social Support", "Initial Interview" |
| counselor_preference | VARCHAR(10) | Foreign key to counselors.counselor_id or "No preference" |
| description | TEXT | Optional description |
| status | ENUM | 'pending', 'approved', 'rejected', 'completed', 'cancelled' |
| cancellation_reason | TEXT | Reason if cancelled by student |
| rejection_reason | TEXT | Reason if rejected by counselor/admin |
| created_at | TIMESTAMP | Record creation time |
| updated_at | TIMESTAMP | Last update time |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (student_id)
- INDEX (counselor_preference)
- INDEX (preferred_date)
- INDEX (status)
- UNIQUE KEY (counselor_preference, preferred_date, preferred_time, status) - for double booking prevention

**Foreign Keys:**
- student_id → users.user_id
- counselor_preference → counselors.counselor_id

---

#### 2. `follow_up_appointments`

**Purpose**: Stores follow-up sessions created by counselors

| Column | Type | Description |
|--------|------|-------------|
| id | INT(11) AUTO_INCREMENT | Primary key |
| parent_appointment_id | INT(11) | Foreign key to appointments.id |
| student_id | VARCHAR(10) | Foreign key to users.user_id |
| counselor_id | VARCHAR(10) | Foreign key to counselors.counselor_id |
| preferred_date | DATE | Follow-up date |
| preferred_time | VARCHAR(50) | Time slot |
| consultation_type | VARCHAR(100) | Type of follow-up consultation |
| description | TEXT | Follow-up description |
| reason | TEXT | Reason for follow-up |
| status | ENUM | 'pending', 'completed', 'cancelled' |
| cancellation_reason | TEXT | Reason if cancelled |
| created_at | TIMESTAMP | Record creation time |
| updated_at | TIMESTAMP | Last update time |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (parent_appointment_id)
- INDEX (student_id)
- INDEX (counselor_id)
- INDEX (preferred_date)
- INDEX (status)

**Foreign Keys:**
- parent_appointment_id → appointments.id (CASCADE on delete)
- student_id → users.user_id
- counselor_id → counselors.counselor_id

---

#### 3. `counselor_availability`

**Purpose**: Stores counselor weekly schedules

| Column | Type | Description |
|--------|------|-------------|
| id | INT(11) AUTO_INCREMENT | Primary key |
| counselor_id | VARCHAR(10) | Foreign key to counselors.counselor_id |
| available_days | VARCHAR(20) | Day of week (Monday-Friday) |
| time_scheduled | VARCHAR(255) | Time range (e.g., "8:00 AM-12:00 PM") |
| created_at | TIMESTAMP | Record creation time |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (counselor_id)
- INDEX (available_days)

**Foreign Keys:**
- counselor_id → counselors.counselor_id

---

#### 4. `counselors`

**Purpose**: Stores counselor profiles

| Column | Type | Description |
|--------|------|-------------|
| counselor_id | VARCHAR(10) | Primary key |
| name | VARCHAR(100) | Counselor full name |
| specialization | VARCHAR(100) | Area of expertise |
| created_at | TIMESTAMP | Record creation time |

**Indexes:**
- PRIMARY KEY (counselor_id)

---

#### 5. `users`

**Purpose**: Stores user accounts (students, counselors, admin)

| Column | Type | Description |
|--------|------|-------------|
| user_id | VARCHAR(10) | Primary key |
| username | VARCHAR(50) | Username |
| email | VARCHAR(100) | Email address |
| password | VARCHAR(255) | Hashed password |
| role | ENUM | 'student', 'counselor', 'admin' |
| profile_picture | VARCHAR(255) | Path to profile image |
| last_activity | TIMESTAMP | Last activity timestamp |
| last_login | TIMESTAMP | Last login timestamp |
| logout_time | TIMESTAMP | Last logout timestamp |
| created_at | TIMESTAMP | Record creation time |

**Indexes:**
- PRIMARY KEY (user_id)
- UNIQUE KEY (username)
- UNIQUE KEY (email)
- INDEX (role)

---

#### 6. `notifications`

**Purpose**: Stores user notifications

| Column | Type | Description |
|--------|------|-------------|
| id | INT(11) AUTO_INCREMENT | Primary key |
| user_id | VARCHAR(10) | Foreign key to users.user_id |
| type | VARCHAR(50) | Notification type |
| title | VARCHAR(255) | Notification title |
| message | TEXT | Notification message |
| related_id | INT(11) | Related record ID (appointment/follow-up) |
| is_read | BOOLEAN | Read status |
| created_at | TIMESTAMP | Record creation time |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (user_id)
- INDEX (is_read)
- INDEX (created_at)

---

### Database Triggers

#### 1. `prevent_double_booking`

**Purpose**: Prevent counselor from having multiple appointments at same time

**Trigger Type**: BEFORE INSERT ON `appointments`

**Logic**:
```sql
IF NEW.counselor_preference != 'No preference' THEN
  IF EXISTS (
    SELECT 1 FROM appointments
    WHERE counselor_preference = NEW.counselor_preference
      AND preferred_date = NEW.preferred_date
      AND preferred_time = NEW.preferred_time
      AND status IN ('pending', 'approved')
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Counselor already has an appointment at this time';
  END IF;
END IF;
```

**Note**: This trigger does NOT consider consultation type. The PHP logic handles group consultation capacity.

---

## Business Logic & Rules

### Appointment Booking Rules

#### 1. **Student Eligibility**
- Student can only have ONE of the following at a time:
  - 1 pending appointment, OR
  - 1 approved appointment, OR
  - 1 pending follow-up session
- If any exists, student cannot book new appointment
- Form is disabled with message displayed

#### 2. **Date Rules**
- Appointments must be at least **1 day in advance**
- Cannot book for today or past dates
- Must be within counselor's available days

#### 3. **Time Slot Rules**
- **30-minute time slots** from 8:00 AM - 11:30 AM and 1:00 PM - 5:00 PM
- Lunch break: 11:30 AM - 1:00 PM (no bookings)
- Time slots shown:
  ```
  8:00 AM - 8:30 AM
  8:30 AM - 9:00 AM
  9:00 AM - 9:30 AM
  9:30 AM - 10:00 AM
  10:00 AM - 10:30 AM
  10:30 AM - 11:00 AM
  11:00 AM - 11:30 AM
  1:00 PM - 1:30 PM
  1:30 PM - 2:00 PM
  2:00 PM - 2:30 PM
  2:30 PM - 3:00 PM
  3:00 PM - 3:30 PM
  3:30 PM - 4:00 PM
  4:00 PM - 4:30 PM
  4:30 PM - 5:00 PM
  ```

#### 4. **Consultation Type Rules**

**Individual Consultation:**
- **Exclusive**: Entire time slot is blocked
- **No sharing**: Cannot coexist with ANY other booking (individual or group)
- **Booking prevention**:
  - Cannot book if ANY individual consultation exists
  - Cannot book if ANY group consultation exists

**Group Consultation:**
- **Shared**: Up to **5 students** per time slot
- **Capacity check**: System shows "X slots available (Y/5 booked)"
- **Booking prevention**:
  - Cannot book if ANY individual consultation exists (individual blocks slot)
  - Cannot book if 5+ group consultations exist (full capacity)
- **Display**: Shows remaining slots in real-time

#### 5. **Counselor Selection**
- Student can select specific counselor OR "No preference"
- If "No preference" selected:
  - System shows all available counselors for date/time
  - Admin/counselor assigns specific counselor after approval
- If specific counselor selected:
  - Filters time slots to only show counselor's availability
  - Checks counselor's schedule before booking

#### 6. **Double Booking Prevention**

**Multiple Layers:**

1. **Frontend Validation**:
   - Checks availability before showing time slots
   - Disables booked time slots
   - Shows conflict modal if counselor unavailable
   - Real-time slot availability updates

2. **PHP Validation (in Controller)**:
   - Queries database before insert
   - Checks for existing appointments
   - Considers consultation type
   - Returns error if conflict

3. **Database Trigger**:
   - `prevent_double_booking` trigger
   - Last line of defense
   - Prevents any double booking at DB level
   - Throws error if constraint violated

**Conflict Scenarios:**
```
Scenario 1: Individual + Individual = CONFLICT ❌
Scenario 2: Individual + Group = CONFLICT ❌
Scenario 3: Group + Individual = CONFLICT ❌
Scenario 4: Group + Group (< 5) = ALLOWED ✓
Scenario 5: Group + Group (= 5) = CONFLICT ❌
```

#### 7. **Informed Consent**
- **Required**: Student must check both consent acknowledgment boxes
- Consent includes:
  - Right of informed consent
  - Counseling definition
  - Terms and conditions
  - Dimensions of confidentiality
- Cannot submit without acknowledgment
- Error shown if not checked

---

### Appointment Management Rules

#### 1. **View Appointments**
- Students can view ALL their appointments (all statuses)
- Approved appointments shown as **digital ticket** at top
- Pending appointments shown as **editable forms**
- Historical appointments in tabs (Rejected, Completed, Cancelled)

#### 2. **Edit Appointments**
- **Only PENDING appointments can be edited**
- Approved/Rejected/Completed/Cancelled cannot be edited
- Edit triggers same validation as new booking
- Conflict check excludes current appointment
- Counselor notified of changes

**Editable Fields:**
- Preferred Date
- Preferred Time
- Consultation Type
- Method Type
- Purpose
- Counselor Preference
- Description

**Non-editable:**
- Student ID
- Creation date
- Status
- Appointment ID

#### 3. **Cancel Appointments**
- Student can cancel appointments with status:
  - Pending
  - Approved
- Cannot cancel:
  - Rejected (already rejected)
  - Completed (already finished)
  - Cancelled (already cancelled)
- **Cancellation reason required**
- Status changes to "cancelled"
- Counselor notified

#### 4. **Delete Appointments**
- **Only PENDING appointments can be deleted**
- Permanently removes from database
- Cannot be undone
- Confirmation required
- Counselor notified

#### 5. **Appointment Tickets**
- Generated for **APPROVED appointments only**
- Includes:
  - QR code with appointment data
  - Ticket number (TICKET-{id}-{timestamp})
  - Student details
  - Appointment details (date, time, counselor)
  - Consultation type, method, purpose
- **Download as PDF** functionality
- QR code can be scanned for verification

**Ticket Data Structure (in QR code):**
```json
{
  "appointmentId": 123,
  "studentId": "STU001",
  "date": "2025-11-20",
  "time": "10:00 AM - 10:30 AM",
  "counselor": "Dr. Jane Smith",
  "type": "Individual Consultation",
  "purpose": "Counseling",
  "ticketId": "TICKET-123-1700001234567"
}
```

---

### Follow-up Session Rules

#### 1. **Eligibility**
- Follow-ups can ONLY be created from **COMPLETED appointments**
- Counselor must own the parent appointment
- No limit on number of follow-ups per appointment

#### 2. **Follow-up Chain**
- Each follow-up links to parent appointment via `parent_appointment_id`
- System tracks:
  - Total follow-up count
  - Pending follow-up count
  - Next pending date
- Follow-ups cannot have follow-ups (flat structure, not nested)

#### 3. **Status Lifecycle**
```
pending → completed
        → cancelled
```
- **Pending**: Newly created, scheduled for future
- **Completed**: Session finished, can create another follow-up
- **Cancelled**: Session cancelled, cannot be recovered

#### 4. **Edit Follow-ups**
- **Only PENDING follow-ups can be edited**
- Same validation as creation
- Conflict check excludes current follow-up
- Student notified of changes

**Editable Fields:**
- Preferred Date
- Preferred Time
- Consultation Type
- Description
- Reason

**Non-editable:**
- Parent Appointment ID
- Student ID
- Counselor ID
- Follow-up ID

#### 5. **Cancel Follow-ups**
- Counselor can cancel pending follow-ups
- **Cancellation reason required**
- Student notified
- Cannot be undone

#### 6. **Complete Follow-ups**
- Counselor marks as completed after session
- Enables creating another follow-up
- Cannot be undone

#### 7. **Follow-up Scheduling**
- Must be on counselor's available days
- Must be within counselor's time slots
- Cannot conflict with:
  - Counselor's appointments
  - Counselor's other follow-ups
- Same double booking prevention as appointments

---

### Calendar Rules

#### 1. **Date Availability**
- **Students**: Date available if ANY counselor has availability
- **Counselors**: Date available if counselor has time slots scheduled
- Past dates always disabled
- Today disabled (must be 1+ days ahead)

#### 2. **Fully Booked Indicator**
- **Calculation**:
  ```
  total_slots = sum of all counselors' available slots for date
  booked_slots = count of approved appointments for date
  fully_booked = (booked_slots >= total_slots)
  ```
- Shown as red background with "Fully booked" label
- Students cannot book these dates

#### 3. **Appointment Count Badge**
- Shows number of **approved appointments** on date
- Blue badge with count
- Only shows if count > 0
- Does not include pending/rejected/cancelled

#### 4. **Calendar Interactions**
- **Click date**: Updates input field, closes calendar
- **Navigation**: Previous/Next month buttons
- **Today highlight**: Blue border on today's date
- **Hover effects**: Highlights date on hover

---

## Mobile Implementation Guide

### Overview

This guide helps you implement the appointment and follow-up system in Flutter. The mobile app should maintain feature parity with the web version.

---

### API Integration

#### Base Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'http://your-domain.com/';
  
  // Student Endpoints
  static const String checkEligibility = 'student/check-appointment-eligibility';
  static const String getCounselors = 'student/get-counselors';
  static const String getCounselorsByAvailability = 'student/get-counselors-by-availability';
  static const String getCounselorSchedules = 'student/get-counselor-schedules';
  static const String getBookedTimes = 'student/appointments/booked-times';
  static const String checkGroupSlots = 'student/appointments/check-group-slots';
  static const String checkConflicts = 'student/check-counselor-conflicts';
  static const String getCalendarStats = 'student/calendar/daily-stats';
  static const String saveAppointment = 'student/appointment/save';
  static const String getMyAppointments = 'student/appointments/get-my-appointments';
  static const String updateAppointment = 'student/appointments/update';
  static const String cancelAppointment = 'student/appointments/cancel';
  static const String deleteAppointment = 'student/appointments/delete/';
  
  // Counselor Endpoints
  static const String getCompletedAppointments = 'counselor/follow-up/completed-appointments';
  static const String getFollowUpSessions = 'counselor/follow-up/sessions';
  static const String getFollowUpSession = 'counselor/follow-up/session';
  static const String getCounselorAvailability = 'counselor/follow-up/availability';
  static const String getAvailabilityByWeekday = 'counselor/follow-up/availability-by-weekday';
  static const String getCounselorBookedTimes = 'counselor/follow-up/booked-times';
  static const String createFollowUp = 'counselor/follow-up/create';
  static const String editFollowUp = 'counselor/follow-up/edit';
  static const String cancelFollowUp = 'counselor/follow-up/cancel';
  static const String completeFollowUp = 'counselor/follow-up/complete';
}
```

#### HTTP Client Setup

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final http.Client client = http.Client();
  
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      String url = ApiConfig.baseUrl + endpoint;
      
      // Add query parameters
      if (queryParams != null && queryParams.isNotEmpty) {
        url += '?' + Uri(queryParameters: queryParams).query;
      }
      
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          // Add authentication headers (session cookies or token)
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConfig.baseUrl + endpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          // Add authentication headers
        },
        body: data,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to save data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await client.delete(
        Uri.parse(ApiConfig.baseUrl + endpoint),
        headers: {
          'Accept': 'application/json',
          // Add authentication headers
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
```

---

### Data Models

#### Appointment Model

```dart
class Appointment {
  final int? id;
  final String studentId;
  final String preferredDate;
  final String preferredTime;
  final String consultationType;
  final String methodType;
  final String purpose;
  final String? counselorPreference;
  final String? counselorName;
  final String? description;
  final String status;
  final String? cancellationReason;
  final String? rejectionReason;
  final DateTime? createdAt;
  
  Appointment({
    this.id,
    required this.studentId,
    required this.preferredDate,
    required this.preferredTime,
    required this.consultationType,
    required this.methodType,
    required this.purpose,
    this.counselorPreference,
    this.counselorName,
    this.description,
    required this.status,
    this.cancellationReason,
    this.rejectionReason,
    this.createdAt,
  });
  
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      studentId: json['student_id'],
      preferredDate: json['preferred_date'],
      preferredTime: json['preferred_time'],
      consultationType: json['consultation_type'],
      methodType: json['method_type'],
      purpose: json['purpose'],
      counselorPreference: json['counselor_preference'],
      counselorName: json['counselor_name'],
      description: json['description'],
      status: json['status'],
      cancellationReason: json['cancellation_reason'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'student_id': studentId,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'consultation_type': consultationType,
      'method_type': methodType,
      'purpose': purpose,
      if (counselorPreference != null) 'counselor_preference': counselorPreference,
      if (description != null) 'description': description,
      'status': status,
    };
  }
}
```

#### Counselor Model

```dart
class Counselor {
  final String counselorId;
  final String name;
  final String? specialization;
  final String? profilePicture;
  final DateTime? lastActivity;
  final DateTime? lastLogin;
  
  Counselor({
    required this.counselorId,
    required this.name,
    this.specialization,
    this.profilePicture,
    this.lastActivity,
    this.lastLogin,
  });
  
  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      counselorId: json['counselor_id'],
      name: json['name'],
      specialization: json['specialization'],
      profilePicture: json['profile_picture'],
      lastActivity: json['last_activity'] != null 
        ? DateTime.parse(json['last_activity']) 
        : null,
      lastLogin: json['last_login'] != null 
        ? DateTime.parse(json['last_login']) 
        : null,
    );
  }
}
```

#### Follow-up Appointment Model

```dart
class FollowUpAppointment {
  final int? id;
  final int parentAppointmentId;
  final String studentId;
  final String counselorId;
  final String preferredDate;
  final String preferredTime;
  final String consultationType;
  final String? description;
  final String? reason;
  final String status;
  final String? cancellationReason;
  final DateTime? createdAt;
  
  FollowUpAppointment({
    this.id,
    required this.parentAppointmentId,
    required this.studentId,
    required this.counselorId,
    required this.preferredDate,
    required this.preferredTime,
    required this.consultationType,
    this.description,
    this.reason,
    required this.status,
    this.cancellationReason,
    this.createdAt,
  });
  
  factory FollowUpAppointment.fromJson(Map<String, dynamic> json) {
    return FollowUpAppointment(
      id: json['id'],
      parentAppointmentId: json['parent_appointment_id'],
      studentId: json['student_id'],
      counselorId: json['counselor_id'],
      preferredDate: json['preferred_date'],
      preferredTime: json['preferred_time'],
      consultationType: json['consultation_type'],
      description: json['description'],
      reason: json['reason'],
      status: json['status'],
      cancellationReason: json['cancellation_reason'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'parent_appointment_id': parentAppointmentId,
      'student_id': studentId,
      'counselor_id': counselorId,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'consultation_type': consultationType,
      if (description != null) 'description': description,
      if (reason != null) 'reason': reason,
      'status': status,
    };
  }
}
```

#### Calendar Day Stats Model

```dart
class CalendarDayStats {
  final int count;
  final bool fullyBooked;
  
  CalendarDayStats({
    required this.count,
    required this.fullyBooked,
  });
  
  factory CalendarDayStats.fromJson(Map<String, dynamic> json) {
    return CalendarDayStats(
      count: json['count'],
      fullyBooked: json['fullyBooked'],
    );
  }
}
```

---

### Student Features Implementation

#### 1. Check Eligibility

```dart
class AppointmentService {
  final ApiService _apiService = ApiService();
  
  Future<Map<String, bool>> checkEligibility() async {
    try {
      final response = await _apiService.get(ApiConfig.checkEligibility);
      
      if (response['status'] == 'success') {
        return {
          'hasPending': response['hasPending'] ?? false,
          'hasApproved': response['hasApproved'] ?? false,
          'hasPendingFollowUp': response['hasPendingFollowUp'] ?? false,
          'allowed': response['allowed'] ?? false,
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to check eligibility');
      }
    } catch (e) {
      throw Exception('Error checking eligibility: $e');
    }
  }
}
```

**Usage in UI:**
```dart
class ScheduleAppointmentScreen extends StatefulWidget {
  @override
  _ScheduleAppointmentScreenState createState() => _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  bool _isEligible = true;
  String _ineligibilityMessage = '';
  
  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }
  
  Future<void> _checkEligibility() async {
    try {
      final eligibility = await _appointmentService.checkEligibility();
      
      setState(() {
        _isEligible = eligibility['allowed'] ?? false;
        
        if (!_isEligible) {
          if (eligibility['hasPendingFollowUp'] ?? false) {
            _ineligibilityMessage = 'You have a pending follow-up session. Please complete or resolve it before scheduling a new appointment.';
          } else if (eligibility['hasPending'] ?? false) {
            _ineligibilityMessage = 'You already have a pending appointment. Please wait for it to be approved before scheduling another one.';
          } else if (eligibility['hasApproved'] ?? false) {
            _ineligibilityMessage = 'You already have an approved upcoming appointment. You cannot schedule another at this time.';
          }
        }
      });
    } catch (e) {
      // Handle error
      print('Error checking eligibility: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule Appointment')),
      body: _isEligible 
        ? _buildAppointmentForm()
        : _buildIneligibilityMessage(),
    );
  }
  
  Widget _buildIneligibilityMessage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Card(
          color: Colors.orange[50],
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  _ineligibilityMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppointmentForm() {
    // Implement your appointment form here
    return Container(); // Placeholder
  }
}
```

---

#### 2. Get Counselors

```dart
Future<List<Counselor>> getCounselors() async {
  try {
    final response = await _apiService.get(ApiConfig.getCounselors);
    
    if (response['status'] == 'success') {
      List<dynamic> counselorsList = response['counselors'] ?? [];
      return counselorsList.map((json) => Counselor.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load counselors');
    }
  } catch (e) {
    throw Exception('Error loading counselors: $e');
  }
}
```

**Usage in Dropdown:**
```dart
class CounselorDropdown extends StatefulWidget {
  final String? selectedCounselorId;
  final Function(String?) onChanged;
  
  CounselorDropdown({this.selectedCounselorId, required this.onChanged});
  
  @override
  _CounselorDropdownState createState() => _CounselorDropdownState();
}

class _CounselorDropdownState extends State<CounselorDropdown> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Counselor> _counselors = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }
  
  Future<void> _loadCounselors() async {
    try {
      final counselors = await _appointmentService.getCounselors();
      setState(() {
        _counselors = counselors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    }
    
    return DropdownButtonFormField<String>(
      value: widget.selectedCounselorId,
      decoration: InputDecoration(
        labelText: 'Counselor Preference *',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<String>(
          value: 'No preference',
          child: Text('No preference'),
        ),
        ..._counselors.map((counselor) => DropdownMenuItem<String>(
          value: counselor.counselorId,
          child: Text(counselor.name),
        )),
      ],
      onChanged: widget.onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a counselor';
        }
        return null;
      },
    );
  }
}
```

---

#### 3. Get Available Time Slots

```dart
Future<List<String>> getAvailableTimeSlots(String date, String? counselorId, String consultationType) async {
  try {
    // 1. Get counselor's scheduled time slots
    final schedules = await _getCounselorSchedulesForDate(date, counselorId);
    final availableSlots = _generate30MinuteSlots(schedules);
    
    // 2. Get booked times
    final bookedTimes = await getBookedTimes(date, counselorId, consultationType);
    
    // 3. Filter out booked times
    return availableSlots.where((slot) => !bookedTimes.contains(slot)).toList();
  } catch (e) {
    throw Exception('Error loading time slots: $e');
  }
}

Future<List<String>> getBookedTimes(String date, String? counselorId, String consultationType) async {
  try {
    final queryParams = {
      'date': date,
      'consultation_type': consultationType,
    };
    
    if (counselorId != null && counselorId != 'No preference') {
      queryParams['counselor_id'] = counselorId;
    }
    
    final response = await _apiService.get(
      ApiConfig.getBookedTimes,
      queryParams: queryParams,
    );
    
    if (response['status'] == 'success') {
      List<dynamic> booked = response['booked'] ?? [];
      return booked.cast<String>();
    } else {
      throw Exception(response['message'] ?? 'Failed to load booked times');
    }
  } catch (e) {
    throw Exception('Error loading booked times: $e');
  }
}

// Helper: Generate 30-minute slots from schedule ranges
List<String> _generate30MinuteSlots(List<String> scheduleRanges) {
  List<String> slots = [];
  
  for (String range in scheduleRanges) {
    // Parse range like "8:00 AM-12:00 PM"
    final parts = range.split('-');
    if (parts.length != 2) continue;
    
    DateTime start = _parseTime(parts[0].trim());
    DateTime end = _parseTime(parts[1].trim());
    
    // Generate 30-minute slots
    while (start.isBefore(end)) {
      DateTime slotEnd = start.add(Duration(minutes: 30));
      if (slotEnd.isAfter(end)) break;
      
      String slotString = '${_formatTime(start)} - ${_formatTime(slotEnd)}';
      slots.add(slotString);
      
      start = slotEnd;
    }
  }
  
  return slots;
}

// Helper: Parse time string to DateTime
DateTime _parseTime(String timeString) {
  // Parse "8:00 AM" format
  final regex = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);
  final match = regex.firstMatch(timeString);
  
  if (match == null) throw Exception('Invalid time format: $timeString');
  
  int hour = int.parse(match.group(1)!);
  int minute = int.parse(match.group(2)!);
  String ampm = match.group(3)!.toUpperCase();
  
  if (ampm == 'PM' && hour != 12) hour += 12;
  if (ampm == 'AM' && hour == 12) hour = 0;
  
  return DateTime(2000, 1, 1, hour, minute);
}

// Helper: Format DateTime to "H:MM AM/PM"
String _formatTime(DateTime time) {
  int hour = time.hour;
  String ampm = hour >= 12 ? 'PM' : 'AM';
  if (hour > 12) hour -= 12;
  if (hour == 0) hour = 12;
  
  String minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute $ampm';
}
```

**Usage in Time Slot Dropdown:**
```dart
class TimeSlotDropdown extends StatefulWidget {
  final String? selectedDate;
  final String? selectedCounselorId;
  final String? selectedConsultationType;
  final String? selectedTimeSlot;
  final Function(String?) onChanged;
  
  TimeSlotDropdown({
    this.selectedDate,
    this.selectedCounselorId,
    this.selectedConsultationType,
    this.selectedTimeSlot,
    required this.onChanged,
  });
  
  @override
  _TimeSlotDropdownState createState() => _TimeSlotDropdownState();
}

class _TimeSlotDropdownState extends State<TimeSlotDropdown> {
  final AppointmentService _appointmentService = AppointmentService();
  List<String> _timeSlots = [];
  bool _isLoading = false;
  
  @override
  void didUpdateWidget(TimeSlotDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reload time slots if date, counselor, or consultation type changes
    if (widget.selectedDate != oldWidget.selectedDate ||
        widget.selectedCounselorId != oldWidget.selectedCounselorId ||
        widget.selectedConsultationType != oldWidget.selectedConsultationType) {
      _loadTimeSlots();
    }
  }
  
  Future<void> _loadTimeSlots() async {
    if (widget.selectedDate == null || widget.selectedConsultationType == null) {
      setState(() {
        _timeSlots = [];
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final slots = await _appointmentService.getAvailableTimeSlots(
        widget.selectedDate!,
        widget.selectedCounselorId,
        widget.selectedConsultationType!,
      );
      
      setState(() {
        _timeSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.selectedTimeSlot,
      decoration: InputDecoration(
        labelText: 'Preferred Time *',
        border: OutlineInputBorder(),
        suffixIcon: _isLoading ? CircularProgressIndicator() : null,
      ),
      items: _timeSlots.isEmpty
        ? [DropdownMenuItem(value: null, child: Text('No available time slots'))]
        : _timeSlots.map((slot) => DropdownMenuItem<String>(
            value: slot,
            child: Text(slot),
          )).toList(),
      onChanged: _timeSlots.isEmpty ? null : widget.onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a time slot';
        }
        return null;
      },
    );
  }
}
```

---

#### 4. Save Appointment

```dart
Future<Map<String, dynamic>> saveAppointment(Appointment appointment) async {
  try {
    final data = appointment.toJson();
    final response = await _apiService.post(ApiConfig.saveAppointment, data);
    
    if (response['status'] == 'success') {
      return {
        'success': true,
        'message': response['message'],
        'appointment_id': response['appointment_id'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to save appointment',
      };
    }
  } catch (e) {
    throw Exception('Error saving appointment: $e');
  }
}
```

**Usage in Form:**
```dart
class AppointmentFormScreen extends StatefulWidget {
  @override
  _AppointmentFormScreenState createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentService _appointmentService = AppointmentService();
  
  // Form fields
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedConsultationType;
  String? _selectedMethodType;
  String? _selectedPurpose;
  String? _selectedCounselorId;
  String? _description;
  bool _consentRead = false;
  bool _consentAccept = false;
  bool _isSubmitting = false;
  
  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_consentRead || !_consentAccept) {
      _showError('Please acknowledge both consent statements to proceed.');
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final appointment = Appointment(
        studentId: 'STU001', // Get from user session
        preferredDate: _selectedDate!,
        preferredTime: _selectedTime!,
        consultationType: _selectedConsultationType!,
        methodType: _selectedMethodType!,
        purpose: _selectedPurpose!,
        counselorPreference: _selectedCounselorId,
        description: _description,
        status: 'pending',
      );
      
      final result = await _appointmentService.saveAppointment(appointment);
      
      setState(() {
        _isSubmitting = false;
      });
      
      if (result['success']) {
        _showSuccessDialog(result['message']);
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showError('An error occurred: $e');
    }
  }
  
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 10),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule Appointment')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Consultation Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedConsultationType,
                decoration: InputDecoration(
                  labelText: 'Consultation Type *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Individual Consultation', child: Text('Individual Consultation')),
                  DropdownMenuItem(value: 'Group Consultation', child: Text('Group Consultation')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedConsultationType = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              SizedBox(height: 16),
              
              // Date Picker
              // Implement custom calendar or use package like table_calendar
              
              // Counselor Dropdown
              CounselorDropdown(
                selectedCounselorId: _selectedCounselorId,
                onChanged: (value) {
                  setState(() {
                    _selectedCounselorId = value;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Time Slot Dropdown
              TimeSlotDropdown(
                selectedDate: _selectedDate,
                selectedCounselorId: _selectedCounselorId,
                selectedConsultationType: _selectedConsultationType,
                selectedTimeSlot: _selectedTime,
                onChanged: (value) {
                  setState(() {
                    _selectedTime = value;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Method Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedMethodType,
                decoration: InputDecoration(
                  labelText: 'Method Type *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'In-person', child: Text('In-person')),
                  DropdownMenuItem(value: 'Online (Video)', child: Text('Online (Video)')),
                  DropdownMenuItem(value: 'Online (Audio only)', child: Text('Online (Audio only)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMethodType = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              SizedBox(height: 16),
              
              // Purpose Dropdown
              DropdownButtonFormField<String>(
                value: _selectedPurpose,
                decoration: InputDecoration(
                  labelText: 'Purpose *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Counseling', child: Text('Counseling')),
                  DropdownMenuItem(value: 'Psycho-Social Support', child: Text('Psycho-Social Support')),
                  DropdownMenuItem(value: 'Initial Interview', child: Text('Initial Interview')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPurpose = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              SizedBox(height: 16),
              
              // Description TextField
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  _description = value;
                },
              ),
              SizedBox(height: 16),
              
              // Consent Checkboxes
              CheckboxListTile(
                value: _consentRead,
                onChanged: (value) {
                  setState(() {
                    _consentRead = value ?? false;
                  });
                },
                title: Text('I have read and reviewed the content of this Counseling Informed Consent.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: _consentAccept,
                onChanged: (value) {
                  setState(() {
                    _consentAccept = value ?? false;
                  });
                },
                title: Text('I accept this agreement and consent to counseling.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAppointment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Schedule Appointment', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

#### 5. Calendar with Stats

For the calendar implementation, I recommend using the `table_calendar` package:

```yaml
# pubspec.yaml
dependencies:
  table_calendar: ^3.0.9
```

```dart
import 'package:table_calendar/table_calendar.dart';

class AppointmentCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final String? selectedCounselorId;
  
  AppointmentCalendar({required this.onDateSelected, this.selectedCounselorId});
  
  @override
  _AppointmentCalendarState createState() => _AppointmentCalendarState();
}

class _AppointmentCalendarState extends State<AppointmentCalendar> {
  final AppointmentService _appointmentService = AppointmentService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, CalendarDayStats> _stats = {};
  
  @override
  void initState() {
    super.initState();
    _loadCalendarStats();
  }
  
  Future<void> _loadCalendarStats() async {
    try {
      final stats = await _appointmentService.getCalendarStats(
        _focusedDay.year,
        _focusedDay.month,
      );
      
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      // Handle error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        // Check if date is available
        final stats = _stats[selectedDay];
        if (stats != null && stats.fullyBooked) {
          _showFullyBookedMessage();
          return;
        }
        
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        
        widget.onDateSelected(selectedDay);
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _loadCalendarStats();
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(day);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(day, isSelected: true);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(day, isToday: true);
        },
      ),
      enabledDayPredicate: (day) {
        // Disable past dates and fully booked dates
        if (day.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
          return false;
        }
        
        final stats = _stats[day];
        return stats == null || !stats.fullyBooked;
      },
    );
  }
  
  Widget _buildCalendarDay(DateTime day, {bool isSelected = false, bool isToday = false}) {
    final stats = _stats[day];
    
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: stats != null && stats.fullyBooked
          ? Colors.red[50]
          : (isSelected ? Colors.blue : (isToday ? Colors.blue[50] : null)),
        border: Border.all(
          color: isSelected 
            ? Colors.blue 
            : (isToday ? Colors.blue : Colors.grey[300]!),
          width: isSelected || isToday ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: stats != null && stats.fullyBooked ? Colors.red : Colors.black,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (stats != null && stats.count > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${stats.count}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (stats != null && stats.fullyBooked)
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Text(
                'Full',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  void _showFullyBookedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This date is fully booked. Please select another date.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Service method to get calendar stats
Future<Map<DateTime, CalendarDayStats>> getCalendarStats(int year, int month) async {
  try {
    final response = await _apiService.get(
      ApiConfig.getCalendarStats,
      queryParams: {
        'year': year.toString(),
        'month': month.toString(),
      },
    );
    
    if (response['status'] == 'success') {
      Map<String, dynamic> statsJson = response['stats'] ?? {};
      Map<DateTime, CalendarDayStats> stats = {};
      
      statsJson.forEach((dateString, value) {
        final date = DateTime.parse(dateString);
        stats[date] = CalendarDayStats.fromJson(value);
      });
      
      return stats;
    } else {
      throw Exception(response['message'] ?? 'Failed to load calendar stats');
    }
  } catch (e) {
    throw Exception('Error loading calendar stats: $e');
  }
}
```

---

### Counselor Features Implementation

#### 1. Get Completed Appointments with Follow-up Info

```dart
class CounselorFollowUpService {
  final ApiService _apiService = ApiService();
  
  Future<List<CompletedAppointmentWithFollowUp>> getCompletedAppointments({String? searchTerm}) async {
    try {
      final queryParams = searchTerm != null && searchTerm.isNotEmpty
        ? {'search': searchTerm}
        : null;
      
      final response = await _apiService.get(
        ApiConfig.getCompletedAppointments,
        queryParams: queryParams,
      );
      
      if (response['status'] == 'success') {
        List<dynamic> appointmentsList = response['appointments'] ?? [];
        return appointmentsList.map((json) => CompletedAppointmentWithFollowUp.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load completed appointments');
      }
    } catch (e) {
      throw Exception('Error loading completed appointments: $e');
    }
  }
}

class CompletedAppointmentWithFollowUp {
  final Appointment appointment;
  final int followUpCount;
  final int pendingFollowUpCount;
  final String? nextPendingDate;
  
  CompletedAppointmentWithFollowUp({
    required this.appointment,
    required this.followUpCount,
    required this.pendingFollowUpCount,
    this.nextPendingDate,
  });
  
  factory CompletedAppointmentWithFollowUp.fromJson(Map<String, dynamic> json) {
    return CompletedAppointmentWithFollowUp(
      appointment: Appointment.fromJson(json),
      followUpCount: json['follow_up_count'] ?? 0,
      pendingFollowUpCount: json['pending_follow_up_count'] ?? 0,
      nextPendingDate: json['next_pending_date'],
    );
  }
}
```

**Usage in UI:**
```dart
class CompletedAppointmentsScreen extends StatefulWidget {
  @override
  _CompletedAppointmentsScreenState createState() => _CompletedAppointmentsScreenState();
}

class _CompletedAppointmentsScreenState extends State<CompletedAppointmentsScreen> {
  final CounselorFollowUpService _followUpService = CounselorFollowUpService();
  List<CompletedAppointmentWithFollowUp> _appointments = [];
  bool _isLoading = true;
  String _searchTerm = '';
  
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }
  
  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appointments = await _followUpService.getCompletedAppointments(
        searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
      );
      
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Follow-up Sessions'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search appointments...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
                _loadAppointments();
              },
            ),
          ),
          
          // Appointments list
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _appointments.isEmpty
                ? Center(child: Text('No completed appointments found'))
                : ListView.builder(
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final item = _appointments[index];
                      return _buildAppointmentCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppointmentCard(CompletedAppointmentWithFollowUp item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _openFollowUpSessions(item.appointment.id!),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Student: ${item.appointment.studentId}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (item.pendingFollowUpCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.pendingFollowUpCount} pending',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text('Date: ${item.appointment.preferredDate}'),
              Text('Time: ${item.appointment.preferredTime}'),
              Text('Purpose: ${item.appointment.purpose}'),
              SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('${item.followUpCount} follow-ups'),
                    avatar: Icon(Icons.repeat, size: 16),
                  ),
                  if (item.nextPendingDate != null) ...[
                    SizedBox(width: 8),
                    Chip(
                      label: Text('Next: ${item.nextPendingDate}'),
                      avatar: Icon(Icons.event, size: 16),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openFollowUpSessions(int appointmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowUpSessionsScreen(appointmentId: appointmentId),
      ),
    );
  }
}
```

---

#### 2. Create Follow-up

```dart
Future<Map<String, dynamic>> createFollowUp(FollowUpAppointment followUp) async {
  try {
    final data = followUp.toJson();
    final response = await _apiService.post(ApiConfig.createFollowUp, data);
    
    if (response['status'] == 'success') {
      return {
        'success': true,
        'message': response['message'],
        'follow_up_id': response['follow_up_id'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to create follow-up',
      };
    }
  } catch (e) {
    throw Exception('Error creating follow-up: $e');
  }
}
```

**Usage in Form:**
```dart
class CreateFollowUpScreen extends StatefulWidget {
  final int parentAppointmentId;
  final String studentId;
  
  CreateFollowUpScreen({required this.parentAppointmentId, required this.studentId});
  
  @override
  _CreateFollowUpScreenState createState() => _CreateFollowUpScreenState();
}

class _CreateFollowUpScreenState extends State<CreateFollowUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final CounselorFollowUpService _followUpService = CounselorFollowUpService();
  
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedConsultationType;
  String? _description;
  String? _reason;
  bool _isSubmitting = false;
  
  Future<void> _submitFollowUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final followUp = FollowUpAppointment(
        parentAppointmentId: widget.parentAppointmentId,
        studentId: widget.studentId,
        counselorId: 'COUN001', // Get from user session
        preferredDate: _selectedDate!,
        preferredTime: _selectedTime!,
        consultationType: _selectedConsultationType!,
        description: _description,
        reason: _reason,
        status: 'pending',
      );
      
      final result = await _followUpService.createFollowUp(followUp);
      
      setState(() {
        _isSubmitting = false;
      });
      
      if (result['success']) {
        _showSuccessDialog(result['message']);
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showError('An error occurred: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Follow-up Session')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Picker
              // Implement date picker that filters by counselor availability
              
              // Time Slot Dropdown
              // Implement time slot dropdown that shows available times
              
              // Consultation Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedConsultationType,
                decoration: InputDecoration(
                  labelText: 'Consultation Type *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Individual Counseling', child: Text('Individual Counseling')),
                  DropdownMenuItem(value: 'Career Guidance', child: Text('Career Guidance')),
                  DropdownMenuItem(value: 'Academic Counseling', child: Text('Academic Counseling')),
                  DropdownMenuItem(value: 'Personal Development', child: Text('Personal Development')),
                  DropdownMenuItem(value: 'Crisis Intervention', child: Text('Crisis Intervention')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedConsultationType = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              SizedBox(height: 16),
              
              // Description TextField
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  _description = value;
                },
              ),
              SizedBox(height: 16),
              
              // Reason TextField
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Reason for Follow-up',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) {
                  _reason = value;
                },
              ),
              SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFollowUp,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Create Follow-up', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 10),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

### Key Flutter Packages to Use

```yaml
dependencies:
  # HTTP requests
  http: ^1.1.0
  
  # State management (choose one)
  provider: ^6.1.1
  # OR
  riverpod: ^2.4.9
  # OR
  bloc: ^8.1.3
  
  # Calendar
  table_calendar: ^3.0.9
  
  # QR code generation (for tickets)
  qr_flutter: ^4.1.0
  
  # PDF generation (for ticket download)
  pdf: ^3.10.7
  
  # Date/time formatting
  intl: ^0.18.1
  
  # Local storage (for caching)
  shared_preferences: ^2.2.2
  
  # Secure storage (for tokens/session)
  flutter_secure_storage: ^9.0.0
```

---

### Important Implementation Notes

1. **Authentication**:
   - Store session token or cookie securely
   - Include in all API requests
   - Handle 401 responses (redirect to login)

2. **Error Handling**:
   - Show user-friendly error messages
   - Log errors for debugging
   - Handle network errors gracefully

3. **Loading States**:
   - Show loading indicators during API calls
   - Disable buttons during submission
   - Provide feedback on long operations

4. **Validation**:
   - Validate all form fields before submission
   - Check date constraints (future dates, counselor availability)
   - Validate time slots against counselor schedule

5. **Caching**:
   - Cache counselor list to reduce API calls
   - Cache calendar stats for current month
   - Invalidate cache when data changes

6. **Real-time Updates**:
   - Refresh appointment list after creation/edit/cancel
   - Refresh time slots when date/counselor changes
   - Update calendar stats when navigating months

7. **Accessibility**:
   - Provide text alternatives for icons
   - Ensure sufficient color contrast
   - Support screen readers

8. **Offline Support** (Optional):
   - Cache appointment data locally
   - Queue actions when offline
   - Sync when connection restored

---

## Conclusion

This documentation provides a complete reference for implementing the Counselign appointment and follow-up system in Flutter. Use the API endpoints, data models, and UI examples as a guide to build the mobile version with feature parity to the web application.

Key features to prioritize:
1. Student appointment scheduling with eligibility check
2. Dynamic time slot filtering based on availability
3. Appointment management (view, edit, cancel, delete)
4. Calendar with availability indicators
5. Counselor follow-up session management
6. QR code ticket generation
7. Conflict detection and double booking prevention

For any questions or clarifications, refer to the backend controller code and database schema sections of this document.
