<?php

namespace App\Controllers\Student;

use App\Controllers\BaseController;

class Feedback extends BaseController
{
    public function index()
    {
        // Check if user is logged in and is a student
        if (!session()->get('logged_in') || session()->get('role') !== 'student') {
            return redirect()->to('/');
        }

        // Get appointment ID from URL parameter
        $appointmentId = $this->request->getGet('appointment_id');

        if (!$appointmentId) {
            return redirect()->to('student/my-appointments')->with('error', 'Invalid appointment ID');
        }

        // Verify the appointment belongs to the logged-in student and is in feedback_pending status
        $db = \Config\Database::connect();
        $studentId = session()->get('user_id_display') ?? session()->get('user_id');

        $appointment = $db->table('appointments')
            ->where('id', $appointmentId)
            ->where('student_id', $studentId)
            ->where('status', 'feedback_pending')
            ->get()
            ->getRowArray();

        if (!$appointment) {
            return redirect()->to('student/my-appointments')->with('error', 'Appointment not found or feedback not required');
        }

        // Check if feedback already submitted
        $existingFeedback = $db->table('student_feedback')
            ->where('appointment_id', $appointmentId)
            ->where('student_id', $studentId)
            ->get()
            ->getRowArray();

        if ($existingFeedback) {
            return redirect()->to('student/my-appointments')->with('info', 'Feedback already submitted for this appointment');
        }

        return view('student/feedback', [
            'appointment' => $appointment,
            'appointmentId' => $appointmentId
        ]);
    }

    public function submit()
    {
        // Check if user is logged in and is a student
        if (!session()->get('logged_in') || session()->get('role') !== 'student') {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Unauthorized']);
        }

        $appointmentId = $this->request->getPost('appointment_id');
        $studentId = session()->get('user_id_display') ?? session()->get('user_id');

        // Verify the appointment
        $db = \Config\Database::connect();
        $appointment = $db->table('appointments')
            ->where('id', $appointmentId)
            ->where('student_id', $studentId)
            ->where('status', 'feedback_pending')
            ->get()
            ->getRowArray();

        if (!$appointment) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Invalid appointment']);
        }

        // Check if feedback already exists
        $existingFeedback = $db->table('student_feedback')
            ->where('appointment_id', $appointmentId)
            ->where('student_id', $studentId)
            ->get()
            ->getRowArray();

        if ($existingFeedback) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Feedback already submitted']);
        }

        // Validate required fields
        $requiredFields = ['q1_ease_of_use', 'q2_satisfaction', 'q3_timeliness', 'q4_information_clarity',
                          'q5_staff_helpfulness', 'q6_technology_reliability', 'q7_privacy_confidence',
                          'q8_recommendation', 'q9_overall_experience', 'q10_future_use'];

        foreach ($requiredFields as $field) {
            $value = $this->request->getPost($field);
            if (!isset($value) || $value === '' || !is_numeric($value) || $value < 1 || $value > 5) {
                return $this->response->setJSON(['status' => 'error', 'message' => 'All questions must be answered with a rating from 1-5']);
            }
        }

        // Insert feedback
        $feedbackData = [
            'appointment_id' => $appointmentId,
            'student_id' => $studentId,
            'counselor_id' => $appointment['counselor_preference'],
            'q1_ease_of_use' => (int)$this->request->getPost('q1_ease_of_use'),
            'q2_satisfaction' => (int)$this->request->getPost('q2_satisfaction'),
            'q3_timeliness' => (int)$this->request->getPost('q3_timeliness'),
            'q4_information_clarity' => (int)$this->request->getPost('q4_information_clarity'),
            'q5_staff_helpfulness' => (int)$this->request->getPost('q5_staff_helpfulness'),
            'q6_technology_reliability' => (int)$this->request->getPost('q6_technology_reliability'),
            'q7_privacy_confidence' => (int)$this->request->getPost('q7_privacy_confidence'),
            'q8_recommendation' => (int)$this->request->getPost('q8_recommendation'),
            'q9_overall_experience' => (int)$this->request->getPost('q9_overall_experience'),
            'q10_future_use' => (int)$this->request->getPost('q10_future_use'),
            'additional_comments' => $this->request->getPost('additional_comments'),
            'status' => 'submitted'
        ];

        $db->transStart();
        try {
            $db->table('student_feedback')->insert($feedbackData);

            // Update appointment status to completed
            $db->table('appointments')
                ->where('id', $appointmentId)
                ->update(['status' => 'completed']);

            $db->transComplete();

            return $this->response->setJSON([
                'status' => 'success',
                'message' => 'Thank you for your feedback! You can now schedule new appointments.'
            ]);
        } catch (\Exception $e) {
            $db->transRollback();
            return $this->response->setJSON(['status' => 'error', 'message' => 'Failed to submit feedback: ' . $e->getMessage()]);
        }
    }
}