<?php

namespace App\Controllers\Admin;

use App\Controllers\BaseController;
use App\Models\StudentFeedbackAnalyticsModel;
use App\Models\CounselorModel;

/**
 * Feedback Analytics Controller
 * 
 * Handles student feedback analytics and descriptive statistics
 */
class FeedbackAnalytics extends BaseController
{
    private $analyticsModel;
    private $counselorModel;

    public function __construct()
    {
        $this->analyticsModel = new StudentFeedbackAnalyticsModel();
        $this->counselorModel = new CounselorModel();
    }

    /**
     * Display feedback analytics dashboard
     */
    public function index()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return redirect()->to('/');
        }

        // Get filters from request
        $counselorId = $this->request->getGet('counselor_id');
        $startDate = $this->request->getGet('start_date');
        $endDate = $this->request->getGet('end_date');

        // Build filters
        $filters = [];
        if (!empty($counselorId)) {
            $filters['counselor_id'] = $counselorId;
        }
        if (!empty($startDate)) {
            $filters['start_date'] = $startDate;
        }
        if (!empty($endDate)) {
            $filters['end_date'] = $endDate;
        }

        // Get analytics data
        $analytics = $this->analyticsModel->getAnalytics($filters);
        $categoryMeans = $this->analyticsModel->getCategoryMeans($analytics);
        $monthlyTrend = $this->analyticsModel->getMonthlyTrend(12);

        // Get all counselors for filter dropdown
        $counselors = $this->counselorModel->findAll();

        $data = [
            'analytics' => $analytics,
            'category_means' => $categoryMeans,
            'monthly_trend' => $monthlyTrend,
            'counselors' => $counselors,
            'filters' => $filters
        ];

        return view('admin/feedback_analytics', $data);
    }

    /**
     * Get analytics data as JSON (for AJAX requests)
     */
    public function getAnalyticsData()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 401);
        }

        $counselorId = $this->request->getGet('counselor_id');
        $startDate = $this->request->getGet('start_date');
        $endDate = $this->request->getGet('end_date');

        $filters = [];
        if (!empty($counselorId)) {
            $filters['counselor_id'] = $counselorId;
        }
        if (!empty($startDate)) {
            $filters['start_date'] = $startDate;
        }
        if (!empty($endDate)) {
            $filters['end_date'] = $endDate;
        }

        $analytics = $this->analyticsModel->getAnalytics($filters);
        $categoryMeans = $this->analyticsModel->getCategoryMeans($analytics);

        return $this->response->setJSON([
            'success' => true,
            'analytics' => $analytics,
            'category_means' => $categoryMeans
        ]);
    }

    /**
     * Export analytics data as PDF
     */
    public function exportPDF()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return redirect()->to('/');
        }

        // Get filters
        $counselorId = $this->request->getGet('counselor_id');
        $startDate = $this->request->getGet('start_date');
        $endDate = $this->request->getGet('end_date');

        $filters = [];
        if (!empty($counselorId)) {
            $filters['counselor_id'] = $counselorId;
        }
        if (!empty($startDate)) {
            $filters['start_date'] = $startDate;
        }
        if (!empty($endDate)) {
            $filters['end_date'] = $endDate;
        }

        $analytics = $this->analyticsModel->getAnalytics($filters);
        $categoryMeans = $this->analyticsModel->getCategoryMeans($analytics);

        // Generate PDF (implementation depends on PDF library)
        // This is a placeholder for PDF generation logic
        $data = [
            'analytics' => $analytics,
            'category_means' => $categoryMeans,
            'filters' => $filters,
            'generated_at' => date('Y-m-d H:i:s')
        ];

        // Return PDF view or file
        return view('admin/feedback_analytics_pdf', $data);
    }

    /**
     * Export analytics data as Excel
     */
    public function exportExcel()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'admin') {
            return redirect()->to('/');
        }

        // Get filters
        $counselorId = $this->request->getGet('counselor_id');
        $startDate = $this->request->getGet('start_date');
        $endDate = $this->request->getGet('end_date');

        $filters = [];
        if (!empty($counselorId)) {
            $filters['counselor_id'] = $counselorId;
        }
        if (!empty($startDate)) {
            $filters['start_date'] = $startDate;
        }
        if (!empty($endDate)) {
            $filters['end_date'] = $endDate;
        }

        $analytics = $this->analyticsModel->getAnalytics($filters);

        // Generate Excel file (implementation depends on Excel library)
        // This is a placeholder for Excel generation logic
        return $this->response->setJSON([
            'success' => true,
            'message' => 'Excel export feature - implementation pending',
            'analytics' => $analytics
        ]);
    }
}
