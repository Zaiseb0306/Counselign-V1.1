<?php

namespace App\Controllers\Admin;

use App\Controllers\BaseController;

class GetFeedbackAnalysis extends BaseController
{
    public function index()
    {
        // Set headers
        header('Content-Type: application/json');
        header('Cache-Control: no-cache, no-store, must-revalidate');
        header('Pragma: no-cache');
        header('Expires: 0');

        $response = [
            'success' => false,
            'message' => '',
            'interpretationCounts' => [],
            'meanScores' => []
        ];

        try {
            // Authentication check
            $session = session();
            if (!$session->get('logged_in') || $session->get('role') !== 'admin') {
                log_message('error', 'GetFeedbackAnalysis: User not authenticated');
                throw new \Exception('User not logged in');
            }

            log_message('info', 'GetFeedbackAnalysis: User authenticated, returning test data');

            // Return test data without database queries
            $response = [
                'success' => true,
                'interpretationCounts' => [
                    'labels' => ['Strongly Agree', 'Agree', 'Neutral', 'Disagree', 'Strongly Disagree'],
                    'data' => [4, 6, 3, 2, 1]
                ],
                'questionRatings' => [
                    'labels' => [
                        'Ease of Use',
                        'Satisfaction',
                        'Timeliness',
                        'Information Clarity',
                        'Staff Helpfulness',
                        'Technology Reliability',
                        'Privacy Confidence',
                        'Recommendation',
                        'Overall Experience',
                        'Future Use'
                    ],
                    'data' => [4.2, 4.5, 3.8, 4.0, 4.3, 3.9, 4.1, 4.4, 4.6, 4.0]
                ],
                'meanScores' => [
                    'purpose' => [],
                    'sessionType' => [],
                    'counselor' => [],
                    'date' => []
                ]
            ];

            log_message('info', 'GetFeedbackAnalysis::index called - returning test data');

        } catch (\Exception $e) {
            log_message('error', 'GetFeedbackAnalysis error: ' . $e->getMessage());
            $response = [
                'success' => false,
                'message' => $e->getMessage(),
                'interpretationCounts' => [],
                'meanScores' => []
            ];
        }

        return $this->response->setJSON($response);
    }
}
