<?php

namespace App\Models;

use CodeIgniter\Model;

/**
 * Student Feedback Analytics Model
 * 
 * Handles statistical calculations for student feedback analysis
 * including weighted mean, frequency distribution, and interpretation
 */
class StudentFeedbackAnalyticsModel extends Model
{
    protected $table = 'student_feedback';
    protected $primaryKey = 'id';
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $useTimestamps = false;

    /**
     * Question definitions with labels
     */
    private $questions = [
        'q1_ease_of_use' => 'How easy was it to navigate the appointment scheduling system?',
        'q2_satisfaction' => 'How satisfied are you with the overall counseling experience?',
        'q3_timeliness' => 'How satisfied are you with the response time to your appointment request?',
        'q4_information_clarity' => 'How clear was the information provided about counseling services?',
        'q5_staff_helpfulness' => 'How helpful was the counseling staff in addressing your concerns?',
        'q6_technology_reliability' => 'How reliable was the technology used for online consultations?',
        'q7_privacy_confidence' => 'How confident do you feel about the privacy of your personal information?',
        'q8_recommendation' => 'How likely are you to recommend our counseling services to others?',
        'q9_overall_experience' => 'How would you rate your overall experience with the counseling system?',
        'q10_future_use' => 'How likely are you to use our counseling services again in the future?'
    ];

    /**
     * Likert scale labels
     */
    private $likertScale = [
        1 => 'Strongly Disagree',
        2 => 'Disagree',
        3 => 'Neutral',
        4 => 'Agree',
        5 => 'Strongly Agree'
    ];

    /**
     * Interpretation scale
     */
    private $interpretationScale = [
        ['min' => 4.21, 'max' => 5.00, 'label' => 'Very Satisfied', 'color' => 'success'],
        ['min' => 3.41, 'max' => 4.20, 'label' => 'Satisfied', 'color' => 'primary'],
        ['min' => 2.61, 'max' => 3.40, 'label' => 'Neutral', 'color' => 'warning'],
        ['min' => 1.81, 'max' => 2.60, 'label' => 'Dissatisfied', 'color' => 'danger'],
        ['min' => 1.00, 'max' => 1.80, 'label' => 'Very Dissatisfied', 'color' => 'dark']
    ];

    /**
     * Get all feedback analytics data
     * 
     * @param array $filters Optional filters (date range, counselor_id, etc.)
     * @return array Complete analytics data
     */
    public function getAnalytics(array $filters = []): array
    {
        $db = \Config\Database::connect();
        
        // Build base query with filters
        $builder = $db->table($this->table)->where('status', 'submitted');
        
        if (!empty($filters['counselor_id'])) {
            $builder->where('counselor_id', $filters['counselor_id']);
        }
        
        if (!empty($filters['start_date'])) {
            $builder->where('submitted_at >=', $filters['start_date']);
        }
        
        if (!empty($filters['end_date'])) {
            $builder->where('submitted_at <=', $filters['end_date']);
        }
        
        $feedbackData = $builder->get()->getResultArray();
        
        $analytics = [];
        $overallSum = 0;
        $overallCount = 0;
        
        foreach ($this->questions as $field => $label) {
            $questionAnalytics = $this->calculateQuestionStats($feedbackData, $field, $label);
            $analytics[$field] = $questionAnalytics;
            
            $overallSum += $questionAnalytics['weighted_mean'] * $questionAnalytics['total_responses'];
            $overallCount += $questionAnalytics['total_responses'];
        }
        
        // Calculate overall mean
        $overallMean = $overallCount > 0 ? $overallSum / $overallCount : 0;
        
        return [
            'questions' => $analytics,
            'overall_mean' => round($overallMean, 2),
            'overall_interpretation' => $this->getInterpretation($overallMean),
            'total_feedbacks' => count($feedbackData),
            'generated_at' => date('Y-m-d H:i:s')
        ];
    }

    /**
     * Calculate statistics for a single question
     * 
     * @param array $feedbackData All feedback records
     * @param string $field Question field name
     * @param string $label Question label
     * @return array Question statistics
     */
    private function calculateQuestionStats(array $feedbackData, string $field, string $label): array
    {
        // Initialize frequency counts
        $frequency = [
            1 => 0,
            2 => 0,
            3 => 0,
            4 => 0,
            5 => 0
        ];
        
        $sum = 0;
        $count = 0;
        
        foreach ($feedbackData as $feedback) {
            if (isset($feedback[$field]) && $feedback[$field] >= 1 && $feedback[$field] <= 5) {
                $value = (int)$feedback[$field];
                $frequency[$value]++;
                $sum += $value;
                $count++;
            }
        }
        
        // Calculate weighted mean
        $weightedMean = $count > 0 ? $sum / $count : 0;
        
        return [
            'field' => $field,
            'label' => $label,
            'frequency' => $frequency,
            'total_responses' => $count,
            'weighted_mean' => round($weightedMean, 2),
            'interpretation' => $this->getInterpretation($weightedMean)
        ];
    }

    /**
     * Get interpretation based on weighted mean
     * 
     * @param float $mean Weighted mean value
     * @return array Interpretation data
     */
    private function getInterpretation(float $mean): array
    {
        foreach ($this->interpretationScale as $range) {
            if ($mean >= $range['min'] && $mean <= $range['max']) {
                return [
                    'label' => $range['label'],
                    'color' => $range['color']
                ];
            }
        }
        
        // Default fallback
        return [
            'label' => 'Neutral',
            'color' => 'warning'
        ];
    }

    /**
     * Get question labels
     * 
     * @return array Question labels
     */
    public function getQuestionLabels(): array
    {
        return $this->questions;
    }

    /**
     * Get Likert scale labels
     * 
     * @return array Likert scale labels
     */
    public function getLikertScale(): array
    {
        return $this->likertScale;
    }

    /**
     * Get analytics for a specific counselor
     * 
     * @param string $counselorId
     * @return array Analytics data for counselor
     */
    public function getCounselorAnalytics(string $counselorId): array
    {
        return $this->getAnalytics(['counselor_id' => $counselorId]);
    }

    /**
     * Get analytics for a date range
     * 
     * @param string $startDate
     * @param string $endDate
     * @return array Analytics data for date range
     */
    public function getDateRangeAnalytics(string $startDate, string $endDate): array
    {
        return $this->getAnalytics([
            'start_date' => $startDate,
            'end_date' => $endDate
        ]);
    }

    /**
     * Get category means (grouping related questions)
     * 
     * @param array $analytics Full analytics data
     * @return array Category means
     */
    public function getCategoryMeans(array $analytics): array
    {
        $categories = [
            'Service Quality' => ['q2_satisfaction', 'q5_staff_helpfulness', 'q9_overall_experience'],
            'Technology' => ['q1_ease_of_use', 'q6_technology_reliability'],
            'Communication' => ['q3_timeliness', 'q4_information_clarity'],
            'Trust & Privacy' => ['q7_privacy_confidence'],
            'Loyalty' => ['q8_recommendation', 'q10_future_use']
        ];
        
        $categoryMeans = [];
        
        foreach ($categories as $category => $questions) {
            $sum = 0;
            $count = 0;
            
            foreach ($questions as $question) {
                if (isset($analytics['questions'][$question])) {
                    $sum += $analytics['questions'][$question]['weighted_mean'];
                    $count++;
                }
            }
            
            $mean = $count > 0 ? $sum / $count : 0;
            $categoryMeans[$category] = [
                'mean' => round($mean, 2),
                'interpretation' => $this->getInterpretation($mean),
                'question_count' => $count
            ];
        }
        
        return $categoryMeans;
    }

    /**
     * Get trend data over time (monthly)
     * 
     * @param int $months Number of months to include
     * @return array Monthly trend data
     */
    public function getMonthlyTrend(int $months = 12): array
    {
        $db = \Config\Database::connect();
        
        $trend = [];
        
        for ($i = $months - 1; $i >= 0; $i--) {
            $date = date('Y-m', strtotime("-{$i} months"));
            $startDate = $date . '-01';
            $endDate = date('Y-m-t', strtotime($startDate));
            
            $monthlyData = $this->getDateRangeAnalytics($startDate, $endDate);
            
            $trend[] = [
                'month' => date('F Y', strtotime($startDate)),
                'overall_mean' => $monthlyData['overall_mean'],
                'total_feedbacks' => $monthlyData['total_feedbacks']
            ];
        }
        
        return $trend;
    }
}
