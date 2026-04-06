<?php

namespace App\Controllers\Counselor;


use App\Helpers\SecureLogHelper;
use App\Controllers\BaseController;
use App\Helpers\UserActivityHelper;
use App\Models\CounselorAvailabilityModel;
use App\Models\NotificationsModel;
use CodeIgniter\API\ResponseTrait;

class Appointments extends BaseController
{
    use ResponseTrait;

    public function index()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return redirect()->to('/');
        }

        return view('counselor/appointments');
    }

    public function getAll()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'status' => 'error',
                'message' => 'Unauthorized access - Please log in as counselor',
                'appointments' => []
            ], 401);
        }

        $counselor_id = session()->get('user_id_display') ?? session()->get('user_id');
        
        // Debug: log the counselor_id
        log_message('debug', 'Appointments getAll - counselor_id: ' . $counselor_id);
        
        $db = \Config\Database::connect();

        // Query to get all appointments with user and counselor information
        // Filtered by counselor_id - include appointments with no preference ('No preference' string or NULL)
        $query = "SELECT
                    a.*, 
                    a.method_type,
                    u.email as user_email,
                    u.username,
                    COALESCE(CONCAT(spi.last_name, ', ', spi.first_name), u.username) AS student_name,
                    CONCAT(sai.course, ' - ', sai.year_level) as course_year,
                    sai.course,
                    sai.year_level,
                    COALESCE(c.name, 'No Preference') as counselor_name
                  FROM appointments a
                  LEFT JOIN users u ON a.student_id = u.user_id
                  LEFT JOIN student_personal_info spi ON spi.student_id = u.user_id
                  LEFT JOIN student_academic_info sai ON sai.student_id = u.user_id
                  LEFT JOIN counselors c ON c.counselor_id = a.counselor_preference
                  WHERE a.counselor_preference = ? OR a.counselor_preference IS NULL OR a.counselor_preference = 'No preference'
                  ORDER BY a.created_at DESC";

        $appointments = $db->query($query, [$counselor_id])->getResultArray();
        
        // Debug: log count
        log_message('debug', 'Appointments getAll - found: ' . count($appointments));

        return $this->respond([
            'status' => 'success',
            'appointments' => $appointments
        ]);
    }

    public function updateStatus()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'status' => 'error',
                'message' => 'Unauthorized access'
            ], 401);
        }

        $id = $this->request->getPost('id');
        $status = $this->request->getPost('status');

        if (!$id || !$status) {
            return $this->respond([
                'status' => 'error',
                'message' => 'Missing required parameters'
            ], 400);
        }

        $db = \Config\Database::connect();
        
        // Get appointment details to find the student
        $appointment = $db->table('appointments')
            ->where('id', $id)
            ->get()
            ->getRowArray();
        
        if ($appointment) {
            // Update appointment status with Manila timezone
            $db->table('appointments')
               ->where('id', $id)
               ->update([
                   'status' => $status,
                   'updated_at' => $this->getManilaDateTime()
               ]);
            
            // Update last_activity for both counselor and student
            $activityHelper = new UserActivityHelper();
            $counselorId = session()->get('user_id_display');
            $activityHelper->updateCounselorActivity($counselorId, 'update_appointment_status');
            $activityHelper->updateStudentActivity($appointment['student_id'], 'appointment_status_updated');
        }

        return $this->respond([
            'status' => 'success',
            'message' => 'Appointment status updated successfully'
        ]);
    }

    public function getAppointments()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'status' => 'error',
                'message' => 'Unauthorized access - Please log in as counselor',
                'appointments' => []
            ], 401);
        }

        $counselor_id = session()->get('user_id_display') ?? session()->get('user_id');
        $db = \Config\Database::connect();

        $query = $db->table('appointments')
            ->select('appointments.*, appointments.method_type as method_type, users.email as user_email, users.username, 
                     CONCAT(sai.course, " - ", sai.year_level) as course_year, sai.course, sai.year_level, CONCAT(spi.first_name, " ", spi.last_name) as student_name, c.name as counselor_name')
            ->join('users', 'users.user_id = appointments.student_id', 'left')
            ->join('student_academic_info sai', 'sai.student_id = appointments.student_id', 'left')
            ->join('student_personal_info spi', 'spi.student_id = appointments.student_id', 'left')
            ->join('counselors c', 'c.counselor_id = appointments.counselor_preference', 'left')
            ->where('(appointments.counselor_preference = ' . $db->escape($counselor_id) . ' OR appointments.counselor_preference = ' . $db->escape('No preference') . ' OR appointments.counselor_preference IS NULL)')
            ->orderBy('appointments.created_at', 'DESC')
            ->get();

        $appointments = $query->getResultArray();

        return $this->respond([
            'status' => 'success',
            'appointments' => $appointments
        ]);
    }

    public function updateAppointmentStatus()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Unauthorized access']);
        }

        $appointment_id = $this->request->getPost('appointment_id');
        $new_status = strtolower($this->request->getPost('status'));
        $rejection_reason = $this->request->getPost('rejection_reason');

        if (!$appointment_id || !$new_status) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Missing required parameters']);
        }

        $valid_statuses = ['approved', 'rejected', 'completed', 'cancelled', 'pending'];
        if (!in_array($new_status, $valid_statuses)) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Invalid status value']);
        }

        $db = \Config\Database::connect();
        $db->transStart();

        $builder = $db->table('appointments');
        $builder->where('id', $appointment_id);
        $updateData = [
            'status' => $new_status,
            'updated_at' => $this->getManilaDateTime()
        ];

        if (($new_status === 'rejected' || $new_status === 'cancelled') && !empty($rejection_reason)) {
            $updateData['reason'] = 'Reason from Counselor: ' . $rejection_reason;
        }

        $builder->update($updateData);

        // Get the updated appointment data for email notification
        $updatedAppointment = $builder->where('id', $appointment_id)->get()->getRowArray();
        
        if ($updatedAppointment) {
            // Send email notification to student
            $this->sendAppointmentNotificationToStudent($updatedAppointment, $new_status);
            
            // Create notification for student when status is approved, rejected, or cancelled
            if (in_array($new_status, ['approved', 'rejected', 'cancelled'])) {
                $this->createAppointmentStatusNotification($updatedAppointment, $new_status, $rejection_reason);
            }
        }

        $db->transComplete();

        if ($db->transStatus() === false) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Failed to update appointment status']);
        }

        return $this->response->setJSON(['status' => 'success', 'message' => 'Appointment status updated successfully']);
    }

    /**
     * Reschedule an appointment - sets it back to pending with new date/time
     */
    public function reschedule()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Unauthorized access']);
        }

        $appointment_id = $this->request->getPost('appointment_id');
        $new_date = $this->request->getPost('new_date');
        $new_time = $this->request->getPost('new_time');
        $reason = $this->request->getPost('reason');

        if (!$appointment_id || !$new_date || !$new_time || !$reason) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Missing required parameters']);
        }

        $counselorId = session()->get('user_id_display') ?? session()->get('user_id');
        if (!$counselorId) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Invalid counselor session']);
        }

        $db = \Config\Database::connect();

        // Get current appointment data
        $appointment = $db->table('appointments')
            ->where('id', $appointment_id)
            ->get()
            ->getRowArray();

        if (!$appointment) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Appointment not found']);
        }

        $validationError = $this->validateRescheduleSlot($counselorId, $appointment, $new_date, $new_time);
        if ($validationError !== null) {
            return $this->response->setJSON(['status' => 'error', 'message' => $validationError]);
        }

        $db->transStart();

        // Update appointment with new date/time and set to rescheduled status
        $updateData = [
            'preferred_date' => $new_date,
            'preferred_time' => $new_time,
            'counselor_preference' => $counselorId,
            'status' => 'rescheduled',
            'reason' => 'Rescheduled by counselor. Reason: ' . $reason . '. Previous date: ' . $appointment['preferred_date'] . ' ' . $appointment['preferred_time'],
            'updated_at' => $this->getManilaDateTime()
        ];

        $updated = $db->table('appointments')
            ->where('id', $appointment_id)
            ->update($updateData);

        if ($updated === false) {
            $db->transRollback();
            log_message('error', 'Reschedule update failed for appointment ID: ' . $appointment_id);
            return $this->response->setJSON(['status' => 'error', 'message' => 'Failed to reschedule appointment']);
        }

        try {
            // Create notification for student
            $notificationModel = new \App\Models\NotificationsModel();
            $notificationInserted = $notificationModel->insert([
                'user_id' => $appointment['student_id'],
                'title' => 'Appointment Rescheduled',
                'message' => 'Your appointment on ' . $appointment['preferred_date'] . ' has been rescheduled to ' . $new_date . ' at ' . $new_time . '. Reason: ' . $reason,
                'type' => 'appointment',
                'is_read' => 0,
                'created_at' => date('Y-m-d H:i:s')
            ]);

            if ($notificationInserted === false) {
                $errors = $notificationModel->errors();
                log_message('error', 'Reschedule notification insert failed: ' . json_encode($errors));
                throw new \RuntimeException('Failed to create reschedule notification');
            }

            // Send email notification to student
            $this->sendRescheduleNotificationToStudent($appointment, $reason, $new_date, $new_time);
        } catch (\Exception $e) {
            log_message('error', 'Reschedule notification error: ' . $e->getMessage());
            $db->transRollback();
            return $this->response->setJSON(['status' => 'error', 'message' => 'Failed to reschedule appointment']);
        }

        $db->transComplete();

        if ($db->transStatus() === false) {
            log_message('error', 'Reschedule transaction failed');
            return $this->response->setJSON(['status' => 'error', 'message' => 'Failed to reschedule appointment']);
        }

        return $this->response->setJSON(['status' => 'success', 'message' => 'Appointment rescheduled successfully']);
    }

    private function validateRescheduleSlot(string $counselorId, array $appointment, string $newDate, string $newTime): ?string
    {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $newDate)) {
            return 'Invalid appointment date.';
        }

        $normalizedTime = $this->normalizeAvailabilityTime($newTime);
        if ($normalizedTime === null) {
            return 'Invalid appointment time.';
        }

        $dayName = date('l', strtotime($newDate));
        $availabilityModel = new CounselorAvailabilityModel();
        $availableSlots = $availabilityModel->getTimeSlots($counselorId, $dayName);

        if (!$this->isTimeWithinAvailability($normalizedTime, $availableSlots)) {
            return 'Selected time is not within your counselor availability.';
        }

        $appointmentModel = new \App\Models\AppointmentModel();
        if ($appointmentModel->hasCounselorConflict($counselorId, $newDate, $normalizedTime, (int) $appointment['id'])) {
            return 'Selected time conflicts with another appointment.';
        }

        $followUpModel = new \App\Models\FollowUpAppointmentModel();
        if ($followUpModel->hasCounselorFollowUpConflict($counselorId, $newDate, $normalizedTime)) {
            return 'Selected time conflicts with a follow-up session.';
        }

        return null;
    }

    private function normalizeAvailabilityTime(string $time): ?string
    {
        $trimmed = trim($time);

        if (preg_match('/^\d{2}:\d{2}$/', $trimmed)) {
            return date('g:i A', strtotime($trimmed));
        }

        if (preg_match('/^(1[0-2]|[1-9]):[0-5][0-9]\s?(AM|PM)$/i', $trimmed)) {
            return strtoupper(date('g:i A', strtotime($trimmed)));
        }

        return null;
    }

    private function isTimeWithinAvailability(string $selectedTime, array $availableSlots): bool
    {
        $selectedMinutes = $this->timeToMinutes($selectedTime);
        if ($selectedMinutes === null) {
            return false;
        }

        foreach ($availableSlots as $slot) {
            $slot = trim((string) $slot);
            if ($slot === '' || strpos($slot, '-') === false) {
                continue;
            }

            [$from, $to] = array_map('trim', explode('-', $slot, 2));
            $fromMinutes = $this->timeToMinutes($from);
            $toMinutes = $this->timeToMinutes($to);

            if ($fromMinutes === null || $toMinutes === null) {
                continue;
            }

            if ($selectedMinutes >= $fromMinutes && $selectedMinutes < $toMinutes) {
                return true;
            }
        }

        return false;
    }

    private function timeToMinutes(string $time): ?int
    {
        $timestamp = strtotime($time);
        if ($timestamp === false) {
            return null;
        }

        return ((int) date('G', $timestamp) * 60) + (int) date('i', $timestamp);
    }

    /**
     * Send appointment notification email to student
     * 
     * @param array $appointmentData The appointment data
     * @param string $actionType The action type ('approved', 'rejected', 'cancelled')
     * @return void
     */
    private function sendAppointmentNotificationToStudent(array $appointmentData, string $actionType): void
    {
        try {
            // Get counselor information for email
            $db = \Config\Database::connect();
            $counselorInfo = $db->table('counselors c')
                ->select('c.counselor_id, c.name, u.email')
                ->join('users u', 'u.user_id = c.counselor_id', 'left')
                ->where('c.counselor_id', session()->get('user_id_display'))
                ->get()
                ->getRowArray();

            if (!$counselorInfo) {
                log_message('error', 'Counselor information not found for ID: ' . session()->get('user_id_display'));
                return;
            }

            $emailService = new \App\Services\AppointmentEmailService();

            if ($actionType === 'approved') {
                $emailSent = $emailService->sendAppointmentApprovalNotification($appointmentData['student_id'], $appointmentData, $counselorInfo);
            } elseif ($actionType === 'rejected') {
                $emailSent = $emailService->sendAppointmentRejectionNotification($appointmentData['student_id'], $appointmentData, $counselorInfo);
            } elseif ($actionType === 'cancelled') {
                $emailSent = $emailService->sendAppointmentCancellationByCounselorNotification($appointmentData['student_id'], $appointmentData, $counselorInfo);
            } else {
                log_message('error', 'Invalid action type for email notification: ' . $actionType);
                return;
            }

            if ($emailSent) {
                log_message('info', 'Appointment ' . $actionType . ' notification sent successfully to student: ' . $appointmentData['student_id']);
            } else {
                log_message('error', 'Failed to send appointment ' . $actionType . ' notification to student: ' . $appointmentData['student_id']);
            }

        } catch (\Exception $e) {
            log_message('error', 'Error sending appointment notification to student: ' . $e->getMessage());
        }
    }

    /**
     * Send reschedule notification email to student
     * 
     * @param array $appointmentData The appointment data
     * @param string $reason The reschedule reason
     * @param string $newDate The new appointment date
     * @param string $newTime The new appointment time
     * @return void
     */
    private function sendRescheduleNotificationToStudent(array $appointmentData, string $reason, string $newDate, string $newTime): void
    {
        try {
            // Get counselor information for email
            $db = \Config\Database::connect();
            $counselorInfo = $db->table('counselors c')
                ->select('c.counselor_id, c.name, u.email')
                ->join('users u', 'u.user_id = c.counselor_id', 'left')
                ->where('c.counselor_id', session()->get('user_id_display'))
                ->get()
                ->getRowArray();

            if (!$counselorInfo) {
                log_message('error', 'Counselor information not found for ID: ' . session()->get('user_id_display'));
                return;
            }

            // Prepare appointment data with old and new dates
            $appointmentData['old_date'] = $appointmentData['preferred_date'];
            $appointmentData['old_time'] = $appointmentData['preferred_time'];
            $appointmentData['reason'] = $reason;
            $appointmentData['preferred_date'] = $newDate;
            $appointmentData['preferred_time'] = $newTime;

            $emailService = new \App\Services\AppointmentEmailService();
            $emailSent = $emailService->sendAppointmentRescheduleNotification($appointmentData['student_id'], $appointmentData, $counselorInfo);

            if ($emailSent) {
                log_message('info', 'Appointment reschedule notification sent successfully to student: ' . $appointmentData['student_id']);
            } else {
                log_message('error', 'Failed to send appointment reschedule notification to student: ' . $appointmentData['student_id']);
            }

        } catch (\Exception $e) {
            log_message('error', 'Error sending reschedule notification to student: ' . $e->getMessage());
        }
    }

    /**
     * Get counselor name from counselors table
     * 
     * @param string $counselorId Counselor ID
     * @return string Counselor name or counselor ID as fallback
     */
    private function getCounselorName(string $counselorId): string
    {
        try {
            $db = \Config\Database::connect();
            $result = $db->table('counselors')
                ->select('name')
                ->where('counselor_id', $counselorId)
                ->get()
                ->getRowArray();
            
            if ($result && !empty($result['name'])) {
                return trim($result['name']);
            }
            
            return $counselorId; // Fallback to counselor ID if name not found
        } catch (\Exception $e) {
            log_message('error', 'Error getting counselor name: ' . $e->getMessage());
            return $counselorId; // Fallback to counselor ID on error
        }
    }

    /**
     * Create notification for appointment status changes
     * 
     * @param array $appointmentData The appointment data
     * @param string $status The new status ('approved', 'rejected', 'cancelled')
     * @param string|null $rejectionReason Optional rejection reason
     */
    private function createAppointmentStatusNotification(array $appointmentData, string $status, ?string $rejectionReason = null): void
    {
        try {
            $notificationsModel = new NotificationsModel();
            
            $date = isset($appointmentData['preferred_date']) ? date('F j, Y', strtotime($appointmentData['preferred_date'])) : '';
            $time = $appointmentData['preferred_time'] ?? '';
            
            // Get counselor name for notification
            $counselorId = session()->get('user_id_display') ?? session()->get('user_id');
            $counselorName = $this->getCounselorName($counselorId);
            
            $title = 'Appointment ' . ucfirst($status);
            $message = '';
            
            if ($status === 'approved') {
                $message = "Congratulations! Your appointment on {$date} at {$time} with Counselor {$counselorName} has been approved. Please check your scheduled appointments for details.";
            } elseif ($status === 'rejected') {
                $message = "We're sorry, but your appointment on {$date} at {$time} with Counselor {$counselorName} was rejected.";
                if ($rejectionReason) {
                    $message .= " Reason: {$rejectionReason}.";
                }
                $message .= " If you have questions, please contact the counseling office.";
            } elseif ($status === 'cancelled') {
                $message = "Your appointment on {$date} at {$time} with Counselor {$counselorName} has been cancelled by the counselor.";
                if ($rejectionReason) {
                    $message .= " Reason: {$rejectionReason}.";
                }
            }
            
            $notificationData = [
                'user_id' => $appointmentData['student_id'],
                'type' => 'appointment',
                'title' => $title,
                'message' => $message,
                'related_id' => $appointmentData['id'],
                'is_read' => 0
            ];
            
            $notificationsModel->createNotification($notificationData);
        } catch (\Exception $e) {
            log_message('error', 'Error creating appointment status notification: ' . $e->getMessage());
        }
    }

    /**
     * Get current datetime in Manila timezone with specified format
     * 
     * @return string Manila timezone datetime in format 'Y-m-d H:i:s'
     */
    private function getManilaDateTime(): string
    {
        try {
            // Set timezone to Asia/Manila
            $manilaTimezone = new \DateTimeZone('Asia/Manila');
            $manilaDateTime = new \DateTime('now', $manilaTimezone);
            
            // Return formatted datetime
            return $manilaDateTime->format('Y-m-d H:i:s');
        } catch (\Exception $e) {
            // Fallback to server time if timezone setting fails
            log_message('error', 'Failed to get Manila timezone: ' . $e->getMessage());
            return date('Y-m-d H:i:s');
        }
    }

    /**
     * Test method to verify Manila timezone format
     * This method can be removed after testing
     */
    public function testManilaTimezone()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Unauthorized access'
            ], 401);
        }

        $manilaTime = $this->getManilaDateTime();
        
        return $this->response->setJSON([
            'status' => 'success',
            'manila_time' => $manilaTime,
            'format' => 'Y-m-d H:i:s',
            'timezone' => 'Asia/Manila',
            'message' => 'Manila timezone test successful'
        ]);
    }

    public function scheduled()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return redirect()->to('/');
        }

        return view('counselor/scheduled_appointments');
    }

    public function getScheduledAppointments()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'status' => 'error',
                'message' => 'Unauthorized access - Please log in as counselor',
                'appointments' => []
            ], 401);
        }

        try {
            $counselor_id = session()->get('user_id_display') ?? session()->get('user_id');
            $db = \Config\Database::connect();

            // 1) Approved regular appointments (treated as "New")
            $appointmentsQuery = "SELECT
                        a.*, a.method_type, a.updated_at,
                        u.email, u.username,
                        CONCAT(sai.course, ' - ', sai.year_level) as course_year,
                        sai.course, sai.year_level,
                        CONCAT(spi.first_name, ' ', spi.last_name) as student_name,
                        COALESCE(c.name, 'No Preference') as counselorPreference,
                        'New' as schedule_type,
                        'appointment' as record_kind
                      FROM appointments a
                      LEFT JOIN users u ON a.student_id = u.user_id
                      LEFT JOIN student_academic_info sai ON sai.student_id = u.user_id
                      LEFT JOIN student_personal_info spi ON spi.student_id = u.user_id
                      LEFT JOIN counselors c ON c.counselor_id = a.counselor_preference
                      WHERE a.status = 'approved'
                      AND (a.counselor_preference = ? OR a.counselor_preference IS NULL)";

            $appointments = $db->query($appointmentsQuery, [$counselor_id])->getResultArray();

            // 2) Pending/approved follow-up sessions (treated as scheduled items and shown as "Follow-up")
            $followUpsQuery = "SELECT
                        f.id,
                        f.student_id,
                        f.preferred_date,
                        f.preferred_time,
                        f.consultation_type,
                        f.consultation_type as purpose,
                        'approved' as status,
                        u.email,
                        u.username,
                        CONCAT(spi.first_name, ' ', spi.last_name) as student_name,
                        'Follow-up' as schedule_type,
                        'follow_up' as record_kind
                      FROM follow_up_appointments f
                      LEFT JOIN users u ON f.student_id = u.user_id
                      LEFT JOIN student_personal_info spi ON spi.student_id = u.user_id
                      WHERE f.counselor_id = ?
                      AND f.status IN ('pending','approved')";

            $followUps = $db->query($followUpsQuery, [$counselor_id])->getResultArray();

            // Merge and sort by date/time ascending
            $merged = array_merge($appointments, $followUps);
            usort($merged, function ($a, $b) {
                $dateA = strtotime($a['preferred_date'] ?? $a['appointed_date'] ?? '1970-01-01');
                $dateB = strtotime($b['preferred_date'] ?? $b['appointed_date'] ?? '1970-01-01');
                if ($dateA === $dateB) {
                    return strcmp((string)($a['preferred_time'] ?? ''), (string)($b['preferred_time'] ?? ''));
                }
                return $dateA <=> $dateB;
            });

            if (empty($merged)) {
                return $this->respond([
                    'status' => 'success',
                    'message' => 'No approved appointments found',
                    'appointments' => []
                ]);
            }

            return $this->respond([
                'status' => 'success',
                'appointments' => $merged
            ]);

        } catch (\Exception $e) {
            log_message('error', '[Counselor\\Appointments::getScheduledAppointments] Error: ' . $e->getMessage());
            return $this->respond([
                'status' => 'error',
                'message' => 'An error occurred: ' . $e->getMessage(),
                'appointments' => []
            ], 500);
        }
    }

    public function viewAll()
    {
        return view('counselor/view_all_appointments');
    }

    public function followUp()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return redirect()->to('/');
        }

        return view('counselor/follow_up');
    }

    /**
     * Get counselor's availability schedule
     * Returns the counselor's available days and time slots
     */
    public function getCounselorSchedule()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'status' => 'error',
                'message' => 'Unauthorized access - Please log in as counselor',
                'schedule' => []
            ], 401);
        }

        try {
            $counselor_id = session()->get('user_id_display') ?? session()->get('user_id');
            $db = \Config\Database::connect();

            // Get counselor's availability from counselor_availability table
            $query = "SELECT available_days, time_scheduled 
                      FROM counselor_availability 
                      WHERE counselor_id = ? 
                      ORDER BY FIELD(available_days, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')";

            $results = $db->query($query, [$counselor_id])->getResultArray();

            if (empty($results)) {
                return $this->respond([
                    'status' => 'error',
                    'message' => 'No schedule found for counselor',
                    'schedule' => []
                ], 404);
            }

            $schedule = [];
            
            // Process each availability entry
            foreach ($results as $result) {
                $day = trim($result['available_days']);
                $time_scheduled = $result['time_scheduled'] ?? null;
                
                if (!empty($day)) {
                    $schedule[] = [
                        'day' => $day,
                        'time' => $time_scheduled
                    ];
                }
            }

            return $this->respond([
                'status' => 'success',
                'schedule' => $schedule
            ]);

        } catch (\Exception $e) {
            log_message('error', '[Counselor\\Appointments::getCounselorSchedule] Error: ' . $e->getMessage());
            return $this->respond([
                'status' => 'error',
                'message' => 'An error occurred while fetching schedule: ' . $e->getMessage(),
                'schedule' => []
            ], 500);
        }
    }

    /**
     * Track export activity for counselor reports
     */
    public function trackExport()
    {
        try {
            if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
                return $this->respond([
                    'status' => 'error',
                    'message' => 'Unauthorized access'
                ], 401);
            }
            
            $counselorId = session()->get('user_id_display') ?? session()->get('user_id');
            $exportType = $this->request->getPost('export_type') ?? 'appointments_report';
            
            // Update last_activity for exporting reports
            $activityHelper = new UserActivityHelper();
            $activityHelper->updateCounselorActivity($counselorId, 'export_reports');
            
            return $this->respond([
                'status' => 'success',
                'message' => 'Export activity tracked'
            ]);
            
        } catch (\Exception $e) {
            log_message('error', 'Error tracking counselor export activity: ' . $e->getMessage());
            return $this->respond([
                'status' => 'error',
                'message' => 'Error tracking export activity'
            ], 500);
        }
    }
}
