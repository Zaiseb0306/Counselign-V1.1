<?php

namespace App\Controllers\Admin;


use App\Helpers\SecureLogHelper;
use App\Controllers\BaseController;

class GetAllAppointments extends BaseController
{
    public function index()
    {
        // Set headers
        header('Content-Type: application/json');
        header('Cache-Control: no-cache, no-store, must-revalidate');
        header('Pragma: no-cache');
        header('Expires: 0');

        // Error reporting for debugging
        error_reporting(E_ALL);
        ini_set('display_errors', 1);

        $response = [
            'success' => false,
            'message' => '',
            'appointments' => [],
            'labels' => [],
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
            'monthlyRejected' => array_fill(0, 12, 0),
            'monthlyRescheduled' => array_fill(0, 12, 0),
            'monthlyPending' => array_fill(0, 12, 0),
            'monthlyFeedbackPending' => array_fill(0, 12, 0)
        ];

        try {
            // Authentication check (CodeIgniter session)
            $session = session();
            if (!$session->get('logged_in') || $session->get('role') !== 'admin') {
                log_message('error', 'GetAllAppointments: User not authenticated');
                throw new \Exception('User not logged in');
            }

            // Log the request
            log_message('info', 'GetAllAppointments called with timeRange: ' . ($this->request->getGet('timeRange') ?? 'none'));

            // Get time range from request (default to 'weekly')
            $timeRange = $this->request->getGet('timeRange') ?? 'weekly';
            log_message('info', 'Time range: ' . $timeRange);

            $db = \Config\Database::connect();
            if (!$db) {
                log_message('error', 'GetAllAppointments: Database connection failed');
                throw new \Exception('Database connection failed');
            }

            // Simplified base query for testing
            $baseQuery = "SELECT
                        appointments.id,
                        appointments.student_id,
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
                        COALESCE(c.name, 'No Preference') as counselor_name,
                        appointments.status, appointments.reason,
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
                        MONTH(appointments.preferred_date) as month
                      FROM appointments
                      LEFT JOIN student_feedback sf ON sf.appointment_id = appointments.id
                      LEFT JOIN student_personal_info spi ON spi.student_id = appointments.student_id
                      LEFT JOIN users u ON appointments.student_id = u.user_id
                      LEFT JOIN counselors c ON c.counselor_id = appointments.counselor_preference";

            // All appointments for the list view
            $allAppointmentsQuery = $baseQuery . " ORDER BY preferred_date ASC, preferred_time ASC";
            log_message('info', 'Executing all appointments query: ' . $allAppointmentsQuery);
            try {
                $allAppointments = $db->query($allAppointmentsQuery)->getResultArray();
                log_message('info', 'Found ' . count($allAppointments) . ' appointments');
            } catch (\Exception $e) {
                log_message('error', 'GetAllAppointments: Query failed: ' . $e->getMessage());
                throw new \Exception('Database query failed: ' . $e->getMessage());
            }

            // Add appointments to response for dashboard table display
            $response['appointments'] = $allAppointments;

            // Normalize and tag base appointments
            foreach ($allAppointments as &$row) {
                $row['appointment_type'] = 'First Session';
                $row['record_kind'] = 'appointment';
            }
            unset($row);

            // Include completed/feedback_pending follow-up sessions, mapped to list schema
            // These are kept separate and only shown in the Follow-up tab
            $followUpsQuery = "SELECT
                    f.id,
                    f.student_id as student_id,
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
                WHERE f.status IN ('pending','completed')
                ORDER BY f.preferred_date ASC, f.preferred_time ASC";

            $followUps = $db->query($followUpsQuery)->getResultArray();

            // Only merge main appointments into response - follow-ups are handled separately in the Follow-up tab
            $response['appointments'] = $allAppointments;
            $response['followUps'] = $followUps;

            // Now get filtered appointments for charts
            $dateFilter = "";
            $startDateStr = null;
            $endDateStr = null;

            switch ($timeRange) {
                case 'daily':
                    $currentDate = new \DateTime();
                    $startDateStr = $currentDate->format('Y-m-d');
                    $endDateStr = $currentDate->format('Y-m-d');
                    $dateFilter = " WHERE preferred_date = '$startDateStr'";
                    // Set weekInfo for daily display
                    $response['weekInfo'] = [
                        'startDate' => $startDateStr,
                        'endDate' => $endDateStr,
                        'weekDays' => []
                    ];
                    $response['weekInfo']['weekDays'][] = [
                        'date' => $startDateStr,
                        'dayName' => $currentDate->format('l'),
                        'shortDayName' => $currentDate->format('D'),
                        'dayMonth' => $currentDate->format('M j')
                    ];
                    break;
                case 'weekly':
                    $currentDate = new \DateTime();
                    $startDate = clone $currentDate;
                    while ($startDate->format('N') != 1) { $startDate->modify('-1 day'); }
                    $startDate->modify('-28 days');
                    $endDate = clone $currentDate;
                    while ($endDate->format('N') != 7) { $endDate->modify('+1 day'); }
                    $startDateStr = $startDate->format('Y-m-d');
                    $endDateStr = $endDate->format('Y-m-d');
                    $dateFilter = " WHERE preferred_date >= '$startDateStr' AND preferred_date <= '$endDateStr'";
                    // Set weekInfo for daily/weekly display
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
                    break;
                case 'monthly':
                    $currentYear = date('Y');
                    $dateFilter = " WHERE YEAR(preferred_date) = '$currentYear'";
                    break;
            }

            $query = $baseQuery . $dateFilter . " ORDER BY preferred_date ASC, preferred_time ASC";
            try {
                $chartAppointments = $db->query($query)->getResultArray();
            } catch (\Exception $e) {
                log_message('error', 'GetAllAppointments: Chart query failed: ' . $e->getMessage());
                $chartAppointments = [];
            }

            // Include all follow-up sessions in chart statistics
            $fuChartQuery = "SELECT
                    f.preferred_date as appointed_date,
                    LOWER(f.status) as status
                FROM follow_up_appointments f
                WHERE f.status IN ('pending','completed')";
            if ($timeRange === 'monthly') {
                $fuChartQuery .= " AND YEAR(f.preferred_date) = YEAR(CURDATE())";
            } elseif (!empty($startDateStr) && !empty($endDateStr)) {
                $fuChartQuery .= " AND f.preferred_date >= " . $db->escape($startDateStr) . " AND f.preferred_date <= " . $db->escape($endDateStr);
            }
            $followUpForCharts = $db->query($fuChartQuery)->getResultArray();
            foreach ($followUpForCharts as $fu) {
                $chartAppointments[] = [
                    'appointed_date' => $fu['appointed_date'],
                    'status' => $fu['status']
                ];
            }

            // Process appointments for statistics
            if ($timeRange === 'daily') {
                $dateFormat = 'Y-m-d';
            } elseif ($timeRange === 'weekly') {
                $dateFormat = 'Y-m-d'; // Will be adjusted to week start in the loop
            } else {
                $dateFormat = 'F';
            }
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
            } elseif ($timeRange === 'monthly') {
                for ($i = 1; $i <= 12; $i++) {
                    $monthName = date('F', mktime(0, 0, 0, $i, 1));
                    $stats[$monthName] = ['completed' => 0, 'approved' => 0, 'rejected' => 0, 'rescheduled' => 0, 'pending' => 0, 'feedback_pending' => 0];
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

            foreach ($chartAppointments as $appointment) {
                $appointmentDate = new \DateTime($appointment['appointed_date']);
                $month = date('n', strtotime($appointment['appointed_date']));
                
                if ($timeRange === 'weekly') {
                    // Find the week start (Monday) for this appointment
                    while ($appointmentDate->format('N') != 1) { $appointmentDate->modify('-1 day'); }
                    $date = $appointmentDate->format('Y-m-d');
                } elseif ($timeRange === 'daily') {
                    $date = $appointmentDate->format('Y-m-d');
                } else {
                    // Monthly
                    $date = $appointmentDate->format('F');
                }
                
                if (!isset($stats[$date])) {
                    $stats[$date] = ['completed' => 0, 'approved' => 0, 'rejected' => 0, 'rescheduled' => 0, 'pending' => 0, 'feedback_pending' => 0];
                }
                $status = strtolower($appointment['status']);

                // Count the status
                if (in_array($status, ['completed', 'approved', 'rejected', 'rescheduled', 'pending', 'feedback_pending'])) {
                    $stats[$date][$status]++;
                    $totalStats[$status]++;
                    $monthlyStats[$month][$status]++;
                }
            }

            ksort($stats);
            $response['labels'] = array_keys($stats);
            foreach ($stats as $stat) {
                $response['completed'][] = $stat['completed'];
                $response['approved'][] = $stat['approved'];
                $response['rejected'][] = $stat['rejected'];
                $response['rescheduled'][] = $stat['rescheduled'];
                $response['pending'][] = $stat['pending'];
                $response['feedback_pending'][] = $stat['feedback_pending'];
            }
            if ($timeRange === 'daily' || $timeRange === 'weekly') {
                $response['startDate'] = $startDateStr;
                $response['endDate'] = $endDateStr;
            }
            $response['totalCompleted'] = $totalStats['completed'];
            $response['totalApproved'] = $totalStats['approved'];
            $response['totalRescheduled'] = $totalStats['rescheduled'];
            $response['totalPending'] = $totalStats['pending'];
            $response['totalFeedbackPending'] = $totalStats['feedback_pending'];
            for ($i = 1; $i <= 12; $i++) {
                $response['monthlyCompleted'][$i-1] = $monthlyStats[$i]['completed'];
                $response['monthlyApproved'][$i-1] = $monthlyStats[$i]['approved'];
                $response['monthlyRescheduled'][$i-1] = $monthlyStats[$i]['rescheduled'];
                $response['monthlyRejected'][$i-1] = $monthlyStats[$i]['rejected'];
                $response['monthlyPending'][$i-1] = $monthlyStats[$i]['pending'];
                $response['monthlyFeedbackPending'][$i-1] = $monthlyStats[$i]['feedback_pending'];
            }
            $response['success'] = true;
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return $this->response->setJSON($response);
    }
}
