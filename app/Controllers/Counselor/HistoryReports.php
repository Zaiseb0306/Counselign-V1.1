<?php

namespace App\Controllers\Counselor;


use App\Helpers\SecureLogHelper;
use CodeIgniter\Controller;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Psr\Log\LoggerInterface;

class HistoryReports extends Controller
{
    protected $request;
    protected $helpers = ['url', 'form'];
    protected $db;

    public function initController(RequestInterface $request, ResponseInterface $response, LoggerInterface $logger)
    {
        parent::initController($request, $response, $logger);
        $this->db = \Config\Database::connect();
    }

    public function index()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return redirect()->to('/');
        }
        return view('counselor/history_reports');
    }

    public function getHistoryData()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Unauthorized']);
        }

        $counselor_id = session()->get('user_id_display') ?? session()->get('user_id');

        $query = $this->db->table('appointments')
            ->select('appointments.*, users.firstname, users.lastname, counselors.firstname as counselor_firstname, counselors.lastname as counselor_lastname')
            ->join('users', 'users.user_id = appointments.student_id')
            ->join('counselors', 'counselors.id = appointments.counselor_id')
            ->where('appointments.status', 'completed')
            ->groupStart()
                ->where('appointments.counselor_preference', $counselor_id)
                ->orWhere('appointments.counselor_preference IS NULL', null, false)
            ->groupEnd()
            ->orderBy('appointments.created_at', 'DESC')
            ->get();

        return $this->response->setJSON([
            'status' => 'success',
            'data' => $query->getResult()
        ]);
    }

    public function getHistoricalData()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->response->setStatusCode(401)->setJSON(['error' => 'Unauthorized']);
        }

        $counselor_id = session()->get('user_id_display') ?? session()->get('user_id');
        $month = $this->request->getGet('month') ?? date('Y-m');
        // Prevent access to future months
        $currentMonth = date('Y-m');
        if ($month > $currentMonth) {
            $month = $currentMonth;
        }
        $reportType = $this->request->getGet('type') ?? 'monthly';

        try {
            $firstDay = new \DateTime($month . '-01');
            $lastDay = clone $firstDay; $lastDay->modify('last day of this month');

            $labels = []; $completed = []; $approved = []; $rescheduled = []; $pending = []; $cancelled = []; $feedback_pending = [];

            // Counselor filtering condition - matches the pattern from GetAllAppointments controller
            $counselorFilter = " AND (appointments.counselor_preference = " . $this->db->escape($counselor_id) . " OR appointments.counselor_preference IS NULL)";

            if ($reportType === 'daily') {
                $query = $this->db->query(
                    "SELECT
                        DATE(preferred_date) as date,
                        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
                        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
                        SUM(CASE WHEN status = 'rescheduled' THEN 1 ELSE 0 END) as rescheduled,
                        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                        SUM(CASE WHEN status = 'feedback_pending' THEN 1 ELSE 0 END) as feedback_pending,
                        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
                    FROM appointments
                    WHERE preferred_date BETWEEN ? AND ?" . $counselorFilter . "
                    GROUP BY DATE(preferred_date)
                    ORDER BY DATE(preferred_date)",
                    [$firstDay->format('Y-m-d'), $lastDay->format('Y-m-d')]
                );

                foreach ($query->getResult() as $row) {
                    $labels[] = date('j', strtotime($row->date));
                    $completed[] = (int)$row->completed;
                    $approved[] = (int)$row->approved;
                    $rescheduled[] = (int)$row->rescheduled;
                    $pending[] = (int)$row->pending;
                    $feedback_pending[] = (int)$row->feedback_pending;
                    $cancelled[] = (int)$row->cancelled;
                }

                // Add follow-up sessions for counselor
                $fu = $this->db->query(
                    "SELECT DATE(preferred_date) as date,
                           SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
                           SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                           SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
                    FROM follow_up_appointments
                    WHERE counselor_id = ? AND preferred_date BETWEEN ? AND ?
                    GROUP BY DATE(preferred_date)
                    ORDER BY DATE(preferred_date)",
                    [$counselor_id, $firstDay->format('Y-m-d'), $lastDay->format('Y-m-d')]
                );
                foreach ($fu->getResult() as $row) {
                    $dayNum = (int)date('j', strtotime($row->date));
                    $idx = array_search($dayNum, $labels);
                    if ($idx === false) continue;
                    $completed[$idx] += (int)$row->completed;
                    $pending[$idx] += (int)$row->pending;
                    $cancelled[$idx] += (int)$row->cancelled;
                }
            } elseif ($reportType === 'weekly') {
                $firstMonday = clone $firstDay; $dayOfWeek = $firstMonday->format('N');
                if ($dayOfWeek > 1) { $firstMonday->modify('-' . ($dayOfWeek - 1) . ' days'); }
                $lastSunday = clone $lastDay; if ($lastSunday->format('N') != 7) { $lastSunday->modify('next sunday'); }
                // Limit to today to exclude future dates
                $today = new \DateTime();
                if ($lastSunday > $today) {
                    $lastSunday = $today;
                }

                $query = $this->db->query(
                    "SELECT
                        YEARWEEK(preferred_date, 1) as week,
                        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
                        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
                        SUM(CASE WHEN status = 'rescheduled' THEN 1 ELSE 0 END) as rescheduled,
                        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                        SUM(CASE WHEN status = 'feedback_pending' THEN 1 ELSE 0 END) as feedback_pending,
                        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
                    FROM appointments
                    WHERE preferred_date BETWEEN ? AND ?" . $counselorFilter . "
                    GROUP BY YEARWEEK(preferred_date, 1)
                    ORDER BY YEARWEEK(preferred_date, 1)",
                    [$firstMonday->format('Y-m-d'), $lastSunday->format('Y-m-d')]
                );

                $weekStarts = [];
                foreach ($query->getResult() as $row) {
                    $labels[] = 'Week ' . substr($row->week, -2);
                    $completed[] = (int)$row->completed;
                    $approved[] = (int)$row->approved;
                    $rescheduled[] = (int)$row->rescheduled;
                    $pending[] = (int)$row->pending;
                    $feedback_pending[] = (int)$row->feedback_pending;
                    $cancelled[] = (int)$row->cancelled;
                    // compute actual monday for index mapping
                    $y = substr($row->week, 0, 4);
                    $w = substr($row->week, -2);
                    $monday = new \DateTime();
                    $monday->setISODate((int)$y, (int)$w);
                    $weekStarts[] = $monday->format('Y-m-d');
                }

                // Bucket counselor follow-ups by week
                $fuAll = $this->db->query(
                    "SELECT preferred_date, status FROM follow_up_appointments WHERE counselor_id = ? AND preferred_date BETWEEN ? AND ?",
                    [$counselor_id, $firstMonday->format('Y-m-d'), $lastSunday->format('Y-m-d')]
                )->getResultArray();
                foreach ($fuAll as $fuRow) {
                    $d = new \DateTime($fuRow['preferred_date']);
                    while ($d->format('N') != 1) { $d->modify('-1 day'); }
                    $wkStart = $d->format('Y-m-d');
                    $idx = array_search($wkStart, $weekStarts);
                    if ($idx === false) continue;
                    $st = strtolower($fuRow['status']);
                    if ($st === 'completed') $completed[$idx]++;
                    if ($st === 'pending') $pending[$idx]++;
                    if ($st === 'cancelled') $cancelled[$idx]++;
                }
            } elseif ($reportType === 'yearly') {
                // Aggregate by year for counselor
                $query = $this->db->query(
                    "SELECT
                        YEAR(preferred_date) as year,
                        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
                        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
                        SUM(CASE WHEN status = 'rescheduled' THEN 1 ELSE 0 END) as rescheduled,
                        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                        SUM(CASE WHEN status = 'feedback_pending' THEN 1 ELSE 0 END) as feedback_pending,
                        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
                    FROM appointments
                    WHERE YEAR(preferred_date) BETWEEN 2023 AND YEAR(CURDATE())" . $counselorFilter . "
                    GROUP BY YEAR(preferred_date)
                    ORDER BY YEAR(preferred_date)"
                );

                foreach ($query->getResult() as $row) {
                    $labels[] = $row->year;
                    $completed[] = (int)$row->completed;
                    $approved[] = (int)$row->approved;
                    $rescheduled[] = (int)$row->rescheduled;
                    $pending[] = (int)$row->pending;
                    $feedback_pending[] = (int)$row->feedback_pending;
                    $cancelled[] = (int)$row->cancelled;
                }

                // Add counselor follow-up yearly counts
                $fuYears = $this->db->query(
                    "SELECT YEAR(preferred_date) as year,
                           SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as completed,
                           SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) as pending,
                           SUM(CASE WHEN status='cancelled' THEN 1 ELSE 0 END) as cancelled
                     FROM follow_up_appointments
                     WHERE counselor_id = ? AND YEAR(preferred_date) BETWEEN 2023 AND YEAR(CURDATE())
                     GROUP BY YEAR(preferred_date)",
                    [$counselor_id]
                )->getResult();
                foreach ($fuYears as $row) {
                    $idx = array_search($row->year, $labels);
                    if ($idx === false) continue;
                    $completed[$idx] += (int)$row->completed;
                    $pending[$idx] += (int)$row->pending;
                    $cancelled[$idx] += (int)$row->cancelled;
                }
            } else {
                // Monthly aggregation for selected year
                $query = $this->db->query(
                    "SELECT
                        MONTH(preferred_date) as month,
                        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
                        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
                        SUM(CASE WHEN status = 'rescheduled' THEN 1 ELSE 0 END) as rescheduled,
                        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                        SUM(CASE WHEN status = 'feedback_pending' THEN 1 ELSE 0 END) as feedback_pending,
                        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
                    FROM appointments
                    WHERE YEAR(preferred_date) = ?" . $counselorFilter . "
                    GROUP BY MONTH(preferred_date)
                    ORDER BY MONTH(preferred_date)",
                    [date('Y', strtotime($month . '-01'))]
                );

                $labels = range(1, 12);
                foreach ($query->getResult() as $row) {
                    $completed[$row->month - 1] = (int)$row->completed;
                    $approved[$row->month - 1] = (int)$row->approved;
                    $rescheduled[$row->month - 1] = (int)$row->rescheduled;
                    $pending[$row->month - 1] = (int)$row->pending;
                    $feedback_pending[$row->month - 1] = (int)$row->feedback_pending;
                    $cancelled[$row->month - 1] = (int)$row->cancelled;
                }

                // Add counselor follow-up monthly counts
                $fuMonths = $this->db->query(
                    "SELECT MONTH(preferred_date) as month,
                           SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as completed,
                           SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) as pending,
                           SUM(CASE WHEN status='cancelled' THEN 1 ELSE 0 END) as cancelled
                     FROM follow_up_appointments
                     WHERE counselor_id = ? AND YEAR(preferred_date) = ?
                     GROUP BY MONTH(preferred_date)",
                    [$counselor_id, date('Y', strtotime($month . '-01'))]
                )->getResult();
                foreach ($fuMonths as $row) {
                    $idx = (int)$row->month - 1;
                    if ($idx < 0 || $idx >= 12) continue;
                    $completed[$idx] += (int)$row->completed;
                    $pending[$idx] += (int)$row->pending;
                    $cancelled[$idx] += (int)$row->cancelled;
                }
            }

            $totalQuery = $this->db->query(
                "SELECT
                    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as total_completed,
                    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as total_approved,
                    SUM(CASE WHEN status = 'rescheduled' THEN 1 ELSE 0 END) as total_rescheduled,
                    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as total_pending,
                    SUM(CASE WHEN status = 'feedback_pending' THEN 1 ELSE 0 END) as total_feedback_pending,
                    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as total_cancelled
                FROM appointments
                WHERE preferred_date BETWEEN ? AND ?" . $counselorFilter . "",
                [$firstDay->format('Y-m-d'), $lastDay->format('Y-m-d')]
            );

            $totals = $totalQuery->getRow();

            // Add follow-up totals
            $fuTotals = $this->db->query(
                "SELECT
                    SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as total_completed,
                    SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) as total_pending,
                    SUM(CASE WHEN status='cancelled' THEN 1 ELSE 0 END) as total_cancelled
                 FROM follow_up_appointments
                 WHERE counselor_id = ? AND preferred_date BETWEEN ? AND ?",
                [$counselor_id, $firstDay->format('Y-m-d'), $lastDay->format('Y-m-d')]
            )->getRow();
            $totals->total_completed += (int)($fuTotals->total_completed ?? 0);
            $totals->total_pending += (int)($fuTotals->total_pending ?? 0);
            $totals->total_cancelled += (int)($fuTotals->total_cancelled ?? 0);

            return $this->response->setJSON([
                'labels' => $labels,
                'completed' => $completed,
                'approved' => $approved,
                'rescheduled' => $rescheduled,
                'pending' => $pending,
                'feedback_pending' => $feedback_pending,
                'cancelled' => $cancelled,
                'totalCompleted' => (int)$totals->total_completed,
                'totalApproved' => (int)$totals->total_approved,
                'totalRescheduled' => (int)$totals->total_rescheduled,
                'totalPending' => (int)$totals->total_pending,
                'totalFeedbackPending' => (int)$totals->total_feedback_pending,
                'totalCancelled' => (int)$totals->total_cancelled
            ]);
        } catch (\Exception $e) {
            return $this->response->setStatusCode(500)->setJSON(['error' => 'Server error: ' . $e->getMessage()]);
        }
    }
}



