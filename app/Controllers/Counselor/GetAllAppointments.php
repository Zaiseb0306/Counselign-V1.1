<?php

namespace App\Controllers\Counselor;


use App\Helpers\SecureLogHelper;
use App\Controllers\BaseController;

class GetAllAppointments extends BaseController
{
    public function index()
    {
        try {
            // Basic authentication check - only allow counselors
            $session = session();
            if (!$session->get('logged_in') || $session->get('role') !== 'counselor') {
                throw new \Exception('Unauthorized access');
            }

            $userId = session()->get('user_id_display') ?? session()->get('user_id');
            $timeRange = $this->request->getGet('timeRange') ?? 'weekly';

            $db = \Config\Database::connect();

            // Get counselor name
            $counselorName = '';
            $counselorQuery = $db->table('counselors')
                ->select('name')
                ->where('counselor_id', $userId)
                ->get()
                ->getRowArray();
            if ($counselorQuery && !empty($counselorQuery['name'])) {
                $counselorName = $counselorQuery['name'];
            }

            // Base query for appointments
            $baseQuery = "SELECT
                        appointments.id,
                        appointments.student_id as user_id,
                        u.username,
                        CASE
                            WHEN COALESCE(spi.first_name, '') != '' OR COALESCE(spi.last_name, '') != ''
                            THEN CONCAT(COALESCE(spi.first_name, ''), ' ', COALESCE(spi.last_name, ''))
                            WHEN COALESCE(u.username, '') != ''
                            THEN u.username
                            ELSE appointments.student_id
                        END as student_name,
                        appointments.preferred_date as appointed_date,
                        appointments.preferred_time as appointed_time,
                        appointments.method_type,
                        'Individual Consultation' as consultation_type,
                        appointments.purpose,
                        appointments.description,
                        appointments.counselor_remarks,
                        COALESCE(sf.status, 'pending') as feedback_status,
                        sf.q1_ease_of_use,
                        sf.q2_satisfaction,
                        sf.q3_timeliness,
                        sf.q4_information_clarity,
                        sf.q5_staff_helpfulness,
                        sf.q6_technology_reliability,
                        sf.q7_privacy_confidence,
                        sf.q8_recommendation,
                        sf.q9_overall_experience,
                        sf.q10_future_use,
                        appointments.status,
                        appointments.reason,
                        c.name as counselor_name,
                        MONTH(appointments.preferred_date) as month
                      FROM appointments
                      LEFT JOIN student_feedback sf ON sf.appointment_id = appointments.id
                      LEFT JOIN student_personal_info spi ON spi.student_id = appointments.student_id
                      LEFT JOIN users u ON appointments.student_id = u.user_id
                      LEFT JOIN counselors c ON c.counselor_id = appointments.counselor_preference
                      WHERE appointments.counselor_preference = " . $db->escape($userId);

            // All appointments for the list view (no limit for proper chart data)
            $allAppointmentsQuery = $baseQuery . " ORDER BY appointments.preferred_date DESC";
            $allAppointments = $db->query($allAppointmentsQuery)->getResultArray();

            // Include completed/cancelled follow-up sessions, mapped to list schema
            // These are kept separate and only shown in the Follow-up tab
            $followUpsQuery = "SELECT
                    f.id,
                    f.student_id as user_id,
                    CASE 
                        WHEN COALESCE(spi.first_name, '') != '' OR COALESCE(spi.last_name, '') != '' 
                        THEN CONCAT(COALESCE(spi.first_name, ''), ' ', COALESCE(spi.last_name, ''))
                        WHEN COALESCE(u.username, '') != ''
                        THEN u.username
                        ELSE f.student_id
                    END as student_name,
                    f.preferred_date as appointed_date,
                    f.preferred_time as appointed_time,
                    'Online' as method_type,
                    'Individual Consultation' as consultation_type,
                    f.consultation_type as purpose,
                    f.description,
                    COALESCE(parent.counselor_remarks, '') as counselor_remarks,
                    COALESCE(c.name, 'No Preference') as counselor_name,
                    LOWER(f.status) as status,
                    f.reason as reason,
                    CASE WHEN sf.q1_ease_of_use IS NOT NULL THEN 'submitted' ELSE 'pending' END as feedback_status,
                    sf.q1_ease_of_use,
                    sf.q2_satisfaction,
                    sf.q3_timeliness,
                    sf.q4_information_clarity,
                    sf.q5_staff_helpfulness,
                    sf.q6_technology_reliability,
                    sf.q7_privacy_confidence,
                    sf.q8_recommendation,
                    sf.q9_overall_experience,
                    sf.q10_future_use,
                    'Follow-up Session' as appointment_type,
                    'follow_up' as record_kind
                FROM follow_up_appointments f
                LEFT JOIN student_feedback sf ON sf.appointment_id = f.parent_appointment_id
                LEFT JOIN student_personal_info spi ON spi.student_id = f.student_id
                LEFT JOIN users u ON f.student_id = u.user_id
                LEFT JOIN appointments parent ON parent.id = f.parent_appointment_id
                LEFT JOIN counselors c ON c.counselor_id = f.counselor_id
                WHERE f.counselor_id = " . $db->escape($userId) . " AND f.status IN ('pending','completed')
                ORDER BY f.preferred_date DESC";

            $followUps = $db->query($followUpsQuery)->getResultArray();

            // Apply date filter for chart data based on timeRange
            $dateFilter = "";
            $startDateStr = null;
            $endDateStr = null;

            switch ($timeRange) {
                case 'daily':
                    $currentDate = new \DateTime();
                    $startDate = clone $currentDate;
                    while ($startDate->format('N') != 1) { $startDate->modify('-1 day'); }
                    $endDate = clone $startDate; $endDate->modify('+6 days');
                    $startDateStr = $startDate->format('Y-m-d');
                    $endDateStr = $endDate->format('Y-m-d');
                    $dateFilter = " AND appointments.preferred_date >= '$startDateStr' AND appointments.preferred_date <= '$endDateStr'";
                    break;
                case 'weekly':
                    $currentDate = new \DateTime();
                    $startDate = clone $currentDate;
                    while ($startDate->format('N') != 1) { $startDate->modify('-1 day'); }
                    $startDate->modify('-28 days');
                    $endDate = clone $currentDate;
                    $startDateStr = $startDate->format('Y-m-d');
                    $endDateStr = $endDate->format('Y-m-d');
                    $dateFilter = " AND appointments.preferred_date >= '$startDateStr' AND appointments.preferred_date <= '$endDateStr'";
                    break;
                case 'monthly':
                    $currentYear = date('Y');
                    $dateFilter = " AND YEAR(appointments.preferred_date) = '$currentYear'";
                    break;
            }

            $chartQuery = $baseQuery . $dateFilter . " ORDER BY appointments.preferred_date ASC";
            $chartAppointments = $db->query($chartQuery)->getResultArray();

            // Process appointments for statistics
            $dateFormat = ($timeRange === 'daily' || $timeRange === 'weekly') ? 'Y-m-d' : 'Y-m';
            $stats = [];

            // Initialize dates based on time range
            if ($timeRange === 'daily' && $startDateStr && $endDateStr) {
                $currentDate = new \DateTime($startDateStr);
                $endDate = new \DateTime($endDateStr);
                while ($currentDate <= $endDate) {
                    $dateStr = $currentDate->format('Y-m-d');
                    $stats[$dateStr] = ['completed' => 0, 'approved' => 0, 'rejected' => 0, 'rescheduled' => 0, 'pending' => 0, 'feedback_pending' => 0];
                    $currentDate->modify('+1 day');
                }
                $response['weekInfo'] = [
                    'startDate' => $startDateStr,
                    'endDate' => $endDateStr,
                    'weekDays' => []
                ];
                $tempDate = new \DateTime($startDateStr);
                $endTempDate = new \DateTime($endDateStr);
                while ($tempDate <= $endTempDate) {
                    $response['weekInfo']['weekDays'][] = [
                        'date' => $tempDate->format('Y-m-d'),
                        'dayName' => $tempDate->format('l'),
                        'shortDayName' => $tempDate->format('D'),
                        'dayMonth' => $tempDate->format('M j')
                    ];
                    $tempDate->modify('+1 day');
                }
            } elseif ($timeRange === 'weekly' && $startDateStr && $endDateStr) {
                $currentDate = new \DateTime($startDateStr);
                $lastDate = new \DateTime($endDateStr);
                while ($currentDate->format('N') != 1) { $currentDate->modify('-1 day'); }
                while ($lastDate->format('N') != 7) { $lastDate->modify('+1 day'); }
                while ($currentDate <= $lastDate) {
                    $weekStart = $currentDate->format('Y-m-d');
                    $stats[$weekStart] = ['completed' => 0, 'approved' => 0, 'rejected' => 0, 'rescheduled' => 0, 'pending' => 0, 'feedback_pending' => 0];
                    $currentDate->modify('+7 days');
                }
                $response['weekRanges'] = [];
                foreach (array_keys($stats) as $weekStart) {
                    $weekEnd = date('Y-m-d', strtotime($weekStart . ' +6 days'));
                    $response['weekRanges'][] = [
                        'start' => $weekStart,
                        'end' => $weekEnd
                    ];
                }
            }

            $totalStats = ['completed' => 0, 'approved' => 0, 'rejected' => 0, 'rescheduled' => 0, 'pending' => 0, 'feedback_pending' => 0];
            $monthlyStats = array_fill(1, 12, ['completed' => 0, 'approved' => 0, 'rejected' => 0, 'rescheduled' => 0, 'pending' => 0, 'feedback_pending' => 0]);

            // Calculate total stats based on timeRange
            $today = date('Y-m-d');
            foreach ($allAppointments as $appointment) {
                $appointedDate = $appointment['appointed_date'];
                $status = strtolower($appointment['status']);

                // For monthly, count all appointments (including future dates)
                // For daily/weekly, only count past/current dates
                if ($timeRange === 'monthly') {
                    if (in_array($status, ['completed', 'approved', 'rejected', 'rescheduled', 'pending', 'feedback_pending'])) {
                        $totalStats[$status]++;
                    }
                } else {
                    // Only count appointments that are today or in the past
                    if ($appointedDate <= $today) {
                        if (in_array($status, ['completed', 'approved', 'rejected', 'rescheduled', 'pending', 'feedback_pending'])) {
                            $totalStats[$status]++;
                        }
                    }
                }
            }

            // Include follow-ups as completed in total stats
            foreach ($followUps as $followUp) {
                $appointedDate = $followUp['appointed_date'];
                if ($timeRange === 'monthly') {
                    $totalStats['completed']++;
                } else {
                    // Only count appointments that are today or in the past
                    if ($appointedDate <= $today) {
                        $totalStats['completed']++;
                    }
                }
            }

            // Process chart data for time-series statistics (with date filter)
            foreach ($chartAppointments as $appointment) {
                $date = date($dateFormat, strtotime($appointment['appointed_date']));
                $month = date('n', strtotime($appointment['appointed_date']));
                if ($timeRange === 'weekly') {
                    $appointmentDate = new \DateTime($appointment['appointed_date']);
                    while ($appointmentDate->format('N') != 1) { $appointmentDate->modify('-1 day'); }
                    $date = $appointmentDate->format('Y-m-d');
                    if (!isset($stats[$date])) continue;
                }
                if (!isset($stats[$date])) {
                    $stats[$date] = ['completed' => 0, 'approved' => 0, 'rejected' => 0, 'rescheduled' => 0, 'pending' => 0, 'feedback_pending' => 0];
                }
                $status = strtolower($appointment['status']);
                if (in_array($status, ['completed', 'approved', 'rejected', 'rescheduled', 'pending', 'feedback_pending'])) {
                    $stats[$date][$status]++;
                    $monthlyStats[$month][$status]++;
                }
            }

            // Add follow-ups to monthly stats for monthly chart
            if ($timeRange === 'monthly') {
                foreach ($followUps as $followUp) {
                    $month = date('n', strtotime($followUp['appointed_date']));
                    $status = strtolower($followUp['status']);
                    if ($status === 'completed') {
                        $monthlyStats[$month]['completed']++;
                    } else if ($status === 'pending') {
                        $monthlyStats[$month]['pending']++;
                    }
                }
            }

            ksort($stats);
            $labels = array_keys($stats);
            $completed = [];
            $approved = [];
            $rejected = [];
            $rescheduled = [];
            $pending = [];
            $feedback_pending = [];

            foreach ($stats as $stat) {
                $completed[] = $stat['completed'];
                $approved[] = $stat['approved'];
                $rejected[] = $stat['rejected'];
                $rescheduled[] = $stat['rescheduled'];
                $pending[] = $stat['pending'];
                $feedback_pending[] = $stat['feedback_pending'];
            }

            $monthlyCompleted = [];
            $monthlyApproved = [];
            $monthlyRescheduled = [];
            $monthlyRejected = [];
            $monthlyPending = [];
            $monthlyFeedbackPending = [];

            for ($i = 1; $i <= 12; $i++) {
                $monthlyCompleted[] = $monthlyStats[$i]['completed'];
                $monthlyApproved[] = $monthlyStats[$i]['approved'];
                $monthlyRescheduled[] = $monthlyStats[$i]['rescheduled'];
                $monthlyRejected[] = $monthlyStats[$i]['rejected'];
                $monthlyPending[] = $monthlyStats[$i]['pending'];
                $monthlyFeedbackPending[] = $monthlyStats[$i]['feedback_pending'];
            }

            $response = [
                'success' => true,
                'counselorName' => $counselorName,
                'appointments' => $allAppointments,
                'followUps' => $followUps,
                'labels' => $labels,
                'datasets' => [
                    'completed' => $completed,
                    'approved' => $approved,
                    'rejected' => $rejected,
                    'rescheduled' => $rescheduled,
                    'pending' => $pending,
                    'feedback_pending' => $feedback_pending
                ],
                'completed' => $completed,
                'approved' => $approved,
                'rejected' => $rejected,
                'rescheduled' => $rescheduled,
                'pending' => $pending,
                'feedback_pending' => $feedback_pending,
                'totalCompleted' => $totalStats['completed'],
                'totalApproved' => $totalStats['approved'],
                'totalRescheduled' => $totalStats['rescheduled'],
                'totalPending' => $totalStats['pending'],
                'totalFeedbackPending' => $totalStats['feedback_pending'],
                'monthlyCompleted' => $monthlyCompleted,
                'monthlyApproved' => $monthlyApproved,
                'monthlyRescheduled' => $monthlyRescheduled,
                'monthlyRejected' => $monthlyRejected,
                'monthlyPending' => $monthlyPending,
                'monthlyFeedbackPending' => $monthlyFeedbackPending
            ];

            if ($timeRange === 'daily' || $timeRange === 'weekly') {
                $response['startDate'] = $startDateStr;
                $response['endDate'] = $endDateStr;
            }

            log_message('info', 'GetAllAppointments::index called - returning ' . count($allAppointments) . ' appointments');
        } catch (\Exception $e) {
            log_message('error', 'GetAllAppointments error: ' . $e->getMessage());
            $response = [
                'success' => false,
                'message' => $e->getMessage(),
                'appointments' => [],
                'labels' => [],
                'datasets' => [],
                'completed' => [],
                'approved' => [],
                'rejected' => [],
                'rescheduled' => [],
                'pending' => [],
                'feedback_pending' => [],
                'totalCompleted' => 0,
                'totalApproved' => 0,
                'totalRescheduled' => 0,
                'totalPending' => 0,
                'totalFeedbackPending' => 0,
                'monthlyCompleted' => array_fill(0, 12, 0),
                'monthlyApproved' => array_fill(0, 12, 0),
                'monthlyRescheduled' => array_fill(0, 12, 0),
                'monthlyRejected' => array_fill(0, 12, 0),
                'monthlyPending' => array_fill(0, 12, 0),
                'monthlyFeedbackPending' => array_fill(0, 12, 0)
            ];
        }

        // Ensure we always return a valid JSON response
        log_message('info', 'GetAllAppointments response: ' . json_encode($response));
        return $this->response->setJSON($response);
    }
}



