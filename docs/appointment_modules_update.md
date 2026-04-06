# Appointment Modules Update Specification

## Overview

This document outlines the changes required for the CounselIgn appointment management system. The updates are divided into two categories: Complete Module and In Progress/Und Module.

---

## Complete Module

### 1. Middleware Integration

**Current State:**
- JavaScript makes direct fetch requests to CodeIgniter API endpoints

**Required Changes:**
- All appointment-related requests should route through Flask middleware
- Implement in `flask_middleware/app.py`:

```python
# Endpoint mappings
@app.route('/api/counselor/appointments/complete', methods=['POST'])
def complete_appointment():
    """Forward complete appointment request to CodeIgniter"""
    # Forward request to CodeIgniter: /counselor/appointments/updateStatus
    pass

@app.route('/api/counselor/appointments/reschedule', methods=['POST'])
def reschedule_appointment():
    """Forward reschedule appointment request to CodeIgniter"""
    # Forward request to CodeIgniter: /counselor/appointments/reschedule
    pass
```

- Update JavaScript files to call Flask endpoints instead of direct CodeIgniter URLs:
  - `public/js/counselor/view_all_appointments.js`
  - `public/js/counselor/scheduled_appointments.js`

### 2. Reschedule Function

**Current State:**
- Already implemented in `app/Controllers/Counselor/Appointments.php` (lines 215-308)

**Required Changes:**
- Add middleware routing for reschedule
- Ensure time conflict validation works through middleware
- Update client-side to call Flask `/api/counselor/appointments/reschedule`

---

## In Progress / Undone Module

### 1. Remove Cancelled Function

**Current State:**
- `AppointmentModel::cancel()` method exists (line 305-308)
- Cancellation available for both students and counselors

**Required Changes:**
- Remove cancellation option from UI:
  - Student: `app/Views/student/student_schedule_appointment.php`
  - Counselor: `app/Views/counselor/view_all_appointments.php`
- Update `app/Controllers/Student/Appointment.php` cancel method to restrict access
- Keep cancel capability only for admin role

### 2. Change "Pending" to "Waiting to Accept"

**Current State:**
- Status displayed as "pending" in UI and database

**Required Changes:**

**Database:**
```sql
-- Add new status or update display label
-- Option A: Add new status
ALTER TABLE appointments MODIFY COLUMN status ENUM('pending','waiting_accept','approved','rescheduled','completed','cancelled','rejected');
-- Option B: Update display labels (UI only)
```

**Model Update (`app/Models/AppointmentModel.php`):**
```php
// Update validation rules
protected $validationRules = [
    'status' => 'permit_empty|in_list[pending,waiting_accept,approved,rescheduled,completed,cancelled,rejected]'
];
```

**Controller Update:**
- `app/Controllers/Counselor/Appointments.php`
- `app/Controllers/Admin/Appointments.php`

**UI Update:**
```javascript
// In JavaScript, map status to display labels
const statusLabels = {
    'pending': 'Waiting to Accept',
    'approved': 'Approved',
    'completed': 'Completed',
    'rescheduled': 'Rescheduled',
    'cancelled': 'Cancelled',
    'rejected': 'Rejected'
};
```

### 3. Student Concern (New Field)

**Database:**
```sql
ALTER TABLE appointments ADD COLUMN student_concern TEXT AFTER description;
```

**Model Update:**
```php
protected $allowedFields = [
    // ... existing fields
    'student_concern'
];
```

**Student UI (`app/Views/student/student_schedule_appointment.php`):**
- Add textarea for student to describe their concern/issue
- Update `public/js/student/student_schedule_appointment.js`

### 4. Counselor Remarks (New Field)

**Database:**
```sql
ALTER TABLE appointments ADD COLUMN counselor_remarks TEXT AFTER counselor_preference;
```

**Migration:**
```php
// app/Database/Migrations/2026-03-26-111100_AddCounselorRemarksToAppointments.php
// Already exists - check for implementation
```

**Model Update:**
```php
protected $allowedFields = [
    // ... existing fields
    'counselor_remarks'
];
```

**Counselor UI:**
- Add remark input capability in appointment details view

### 5. Student Feedback (New Field)

**Database:**
```sql
ALTER TABLE appointments ADD COLUMN student_feedback TEXT AFTER status;
ALTER TABLE appointments ADD COLUMN feedback_sentiment VARCHAR(20) NULL;
ALTER TABLE appointments ADD COLUMN feedback_created_at DATETIME NULL;
```

**Model Update:**
```php
protected $allowedFields = [
    // ... existing fields
    'student_feedback',
    'feedback_sentiment',
    'feedback_created_at'
];
```

**Student UI:**
- Add feedback form after appointment completion
- Include rating and comment options

### 6. Time Generated Report in PDF Export

**Current State:**
- `HistoryReports` controller exists but lacks PDF export

**Required Changes:**

**New Controller Method:**
```php
// In app/Controllers/Counselor/HistoryReports.php
public function exportPDF()
{
    // Generate PDF report using TCPDF or DomPDF
    
    // Include:
    // - Report generation timestamp
    // - Date range filter
    // - Appointment statistics
    // - Individual appointment details
}
```

**Add Library (composer.json):**
```json
"require": {
    "tecnickcom/tcpdf": "^6.7"
}
```

**Client-Side:**
- Add PDF export button in `app/Views/counselor/history_reports.php`
- Update `public/js/counselor/history_reports.js`

### 7. Sentiment Analysis for Student Feedback

**Database:**
```sql
-- Already included in student_feedback field setup above
ALTER TABLE appointments ADD COLUMN feedback_sentiment VARCHAR(20) NULL;
```

**Implementation Options:**

**Option A: Python/Flask Service:**
```python
# flask_middleware/app.py
from textblob import TextBlob

@app.route('/api/sentiment/analyze', methods=['POST'])
def analyze_sentiment():
    text = request.json.get('text', '')
    blob = TextBlob(text)
    sentiment = 'positive' if blob.sentiment.polarity > 0.1 else 'negative' if blob.sentiment.polarity < -0.1 else 'neutral'
    confidence = abs(blob.sentiment.polarity)
    return {'sentiment': sentiment, 'confidence': confidence}
```

**Option B: CodeIgniter Service:**
```php
// app/Services/SentimentAnalysisService.php
namespace App\Services;

class SentimentAnalysisService
{
    public function analyze(string $text): array
    {
        // Simple keyword-based sentiment analysis
        // Positive words: thank, great, helpful, better, improved, etc.
        // Negative words: frustrated, confused, worse, not helpful, etc.
        
        $positiveWords = ['thank', 'great', 'helpful', 'better', 'improved', 'good', 'appreciate'];
        $negativeWords = ['frustrated', 'confused', 'worse', 'not helpful', 'bad', 'poor', 'issue'];
        
        $text = strtolower($text);
        $positiveCount = 0;
        $negativeCount = 0;
        
        foreach ($positiveWords as $word) {
            if (strpos($text, $word) !== false) $positiveCount++;
        }
        
        foreach ($negativeWords as $word) {
            if (strpos($text, $word) !== false) $negativeCount++;
        }
        
        if ($positiveCount > $negativeCount) {
            return ['sentiment' => 'positive', 'score' => $positiveCount / ($positiveCount + $negativeCount)];
        } elseif ($negativeCount > $positiveCount) {
            return ['sentiment' => 'negative', 'score' => $negativeCount / ($positiveCount + $negativeCount)];
        }
        
        return ['sentiment' => 'neutral', 'score' => 0.5];
    }
}
```

**Integration:**
- Call sentiment service when student submits feedback
- Store result in `feedback_sentiment` column

---

## Summary of Required Files

### New Files to Create:
1. `app/Services/SentimentAnalysisService.php`
2. `app/Controllers/Counselor/ExportPDF.php` (or add to existing)

### Files to Modify:
1. `app/Models/AppointmentModel.php`
2. `app/Controllers/Counselor/Appointments.php`
3. `app/Controllers/Counselor/HistoryReports.php`
4. `app/Controllers/Student/Appointment.php`
5. `flask_middleware/app.py`
6. `public/js/counselor/view_all_appointments.js`
7. `public/js/counselor/history_reports.js`
8. `public/js/student/student_schedule_appointment.js`

### Database Updates:
1. Add `student_concern` column to appointments
2. Add `counselor_remarks` column to appointments
3. Add `student_feedback`, `feedback_sentiment`, `feedback_created_at` columns

### Composer Dependencies:
```bash
composer require tecnickcom/tcpdf
pip install textblob  # for Flask sentiment
```