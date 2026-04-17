<?php

namespace App\Controllers\Counselor;

use App\Controllers\BaseController;

class PendingFeedback extends BaseController
{
    public function index()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return redirect()->to('/');
        }

        return view('counselor/pending_feedback');
    }

    public function getPendingFeedbackAppointments()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Unauthorized access',
                'appointments' => []
            ]);
        }

        $counselor_id = session()->get('user_id_display') ?? session()->get('user_id');
        $db = \Config\Database::connect();

        log_message('info', 'PendingFeedback - counselor_id: ' . $counselor_id);

        try {
            // Debug: Check if there are any appointments with feedback_pending status
            $debugQuery = "SELECT id, student_id, counselor_preference, status FROM appointments WHERE status = 'feedback_pending'";
            $debugResult = $db->query($debugQuery)->getResultArray();
            log_message('info', 'PendingFeedback - debug result count: ' . count($debugResult));
            if (!empty($debugResult)) {
                log_message('info', 'PendingFeedback - debug results: ' . json_encode($debugResult));
            }

            // Query to get appointments with feedback_pending status for this counselor
            $query = "SELECT
                        a.id,
                        a.student_id,
                        a.preferred_date as appointed_date,
                        a.preferred_time as appointed_time,
                        a.method_type as session,
                        a.purpose,
                        a.description,
                        a.counselor_remarks as remarks,
                        a.status,
                        u.email as user_email,
                        u.username,
                        COALESCE(CONCAT(spi.first_name, ' ', spi.last_name), u.username) AS student_name,
                        c.name as counselor_name
                      FROM appointments a
                      LEFT JOIN users u ON a.student_id = u.user_id
                      LEFT JOIN student_personal_info spi ON spi.student_id = u.user_id
                      LEFT JOIN counselors c ON a.counselor_preference = c.counselor_id
                      WHERE a.status = 'feedback_pending'
                      AND a.counselor_preference = ?
                      ORDER BY a.preferred_date DESC";

            log_message('info', 'PendingFeedback - query: ' . $query);
            log_message('info', 'PendingFeedback - params: ' . json_encode([$counselor_id]));

            $result = $db->query($query, [$counselor_id])->getResultArray();

            log_message('info', 'PendingFeedback - result count: ' . count($result));

            return $this->response->setJSON([
                'status' => 'success',
                'message' => 'Pending feedback appointments retrieved successfully',
                'appointments' => $result
            ]);

        } catch (\Exception $e) {
            log_message('error', 'PendingFeedback::getPendingFeedbackAppointments error: ' . $e->getMessage());
            return $this->response->setJSON([
                'status' => 'error',
                'message' => $e->getMessage(),
                'appointments' => []
            ]);
        }
    }

    public function sendReminderEmail()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Unauthorized access'
            ]);
        }

        $appointmentId = $this->request->getPost('appointment_id');
        
        if (!$appointmentId) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Appointment ID is required'
            ]);
        }

        try {
            $db = \Config\Database::connect();
            
            // Get appointment details
            $appointmentQuery = "SELECT a.*, u.email, u.username, 
                               CONCAT(spi.first_name, ' ', spi.last_name) as student_name,
                               c.name as counselor_name
                               FROM appointments a
                               LEFT JOIN users u ON a.student_id = u.user_id
                               LEFT JOIN student_personal_info spi ON spi.student_id = u.user_id
                               LEFT JOIN counselors c ON a.counselor_preference = c.counselor_id
                               WHERE a.id = ?";
            $appointment = $db->query($appointmentQuery, [$appointmentId])->getRowArray();

            if (!$appointment) {
                return $this->response->setJSON([
                    'status' => 'error',
                    'message' => 'Appointment not found'
                ]);
            }

            // Check if student has already submitted feedback
            $feedbackQuery = "SELECT * FROM student_feedback WHERE appointment_id = ?";
            $feedback = $db->query($feedbackQuery, [$appointmentId])->getRowArray();

            if ($feedback) {
                return $this->response->setJSON([
                    'status' => 'error',
                    'message' => 'Student has already submitted feedback'
                ]);
            }

            // Send reminder email
            $emailService = new \App\Services\AppointmentEmailService();
            $emailSent = $emailService->sendFeedbackReminderNotification(
                $appointment['student_id'],
                [
                    'student_name' => $appointment['student_name'],
                    'counselor_name' => $appointment['counselor_name'],
                    'appointment_date' => date('F j, Y', strtotime($appointment['preferred_date'])),
                    'appointment_time' => $appointment['preferred_time'],
                    'feedback_link' => base_url('student/feedback?appointment_id=' . $appointment['id'])
                ]
            );

            if ($emailSent) {
                log_message('info', 'Feedback reminder email sent to student: ' . $appointment['student_id']);
                return $this->response->setJSON([
                    'status' => 'success',
                    'message' => 'Reminder email sent successfully'
                ]);
            } else {
                return $this->response->setJSON([
                    'status' => 'error',
                    'message' => 'Failed to send reminder email'
                ]);
            }

        } catch (\Exception $e) {
            log_message('error', 'PendingFeedback::sendReminderEmail error: ' . $e->getMessage());
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'An error occurred: ' . $e->getMessage()
            ]);
        }
    }
}
