<?php

namespace App\Controllers\Student;


use App\Helpers\SecureLogHelper;
use App\Helpers\TimezoneHelper; // Add this import
use App\Controllers\BaseController;
use CodeIgniter\API\ResponseTrait;
use App\Models\QuoteModel;
use App\Models\ResourceModel;


class Dashboard extends BaseController
{
    use ResponseTrait;
    public function index()
    {
        // Check if user is logged in and is a regular user
        if (!session()->get('logged_in') || session()->get('role') !== 'student') {
            return redirect()->to('/');
        }

        $data = [
            'title' => 'Student Dashboard',
            'username' => session()->get('username'),
            'email' => session()->get('email')
        ];

        return view('student/dashboard', $data);
    }

    public function getProfileData()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'student') {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Access denied'
            ]);
        }

        try {
            $db = \Config\Database::connect();

            // Get student basic info
            $builder = $db->table('users');
            $builder->select('users.user_id, users.username, users.email, users.profile_picture, users.last_login');
            $builder->where('users.id', session()->get('user_id'));
            $query = $builder->get();

            if ($user = $query->getRowArray()) {
                // Try to get student personal info for full name
                $personalInfoBuilder = $db->table('student_personal_info');
                $personalInfoBuilder->select('first_name, last_name');
                $personalInfoBuilder->where('student_id', $user['user_id']);
                $personalInfo = $personalInfoBuilder->get()->getRowArray();

                // Add name fields if available
                if ($personalInfo) {
                    $user['first_name'] = $personalInfo['first_name'] ?? '';
                    $user['last_name'] = $personalInfo['last_name'] ?? '';

                    // Create full_name if both available
                    if (!empty($personalInfo['first_name']) && !empty($personalInfo['last_name'])) {
                        $user['full_name'] = trim($personalInfo['first_name'] . ' ' . $personalInfo['last_name']);
                    }
                }

                // Normalize profile picture URL
                if (!empty($user['profile_picture'])) {
                    if (strpos($user['profile_picture'], 'http') !== 0) {
                        $relativePath = '/' . ltrim($user['profile_picture'], '/');
                        $user['profile_picture'] = base_url($relativePath);
                    }
                } else {
                    $user['profile_picture'] = base_url('Photos/profile.png');
                }

                log_message('debug', 'Student profile data fetched: ' . json_encode($user));

                return $this->response->setJSON([
                    'success' => true,
                    'data' => $user
                ]);
            } else {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'User data not found'
                ]);
            }
        } catch (\Exception $e) {
            log_message('error', 'Student profile error: ' . $e->getMessage());
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Database error'
            ]);
        }
    }

    public function getApprovedQuotes()
    {
        try {
            $quoteModel = new QuoteModel();

            // Get all approved quotes, ordered randomly but prefer less-displayed ones
            $quotes = $quoteModel
                ->where('status', 'approved')
                ->orderBy('times_displayed', 'ASC')
                ->orderBy('RAND()')
                ->limit(10) // Limit to 10 most relevant quotes
                ->findAll();

            return $this->respond([
                'success' => true,
                'quotes' => $quotes,
                'count' => count($quotes)
            ]);
        } catch (\Exception $e) {
            log_message('error', '[Quote Carousel] Error fetching approved quotes: ' . $e->getMessage());

            return $this->respond([
                'success' => false,
                'message' => 'Failed to load quotes',
                'quotes' => []
            ], 500);
        }
    }

    /**
     * Get resources visible to students
     */
    public function getResources()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'student') {
            return $this->respond(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            $resourceModel = new ResourceModel();
            $resources = $resourceModel->getResourcesByVisibility('students', true);

            // Format file sizes and dates
            foreach ($resources as &$resource) {
                if ($resource['file_size']) {
                    $resource['file_size_formatted'] = $this->formatFileSize($resource['file_size']);
                }
                $resource['created_at_formatted'] = date('M d, Y h:i A', strtotime($resource['created_at']));
            }

            return $this->respond(['success' => true, 'resources' => $resources]);
        } catch (\Exception $e) {
            log_message('error', '[Student Resources] Error fetching resources: ' . $e->getMessage());
            return $this->respond(['success' => false, 'message' => 'Failed to load resources'], 500);
        }
    }

    /**
     * Format file size
     */
    private function formatFileSize($bytes)
    {
        if ($bytes >= 1073741824) {
            return number_format($bytes / 1073741824, 2) . ' GB';
        } elseif ($bytes >= 1048576) {
            return number_format($bytes / 1048576, 2) . ' MB';
        } elseif ($bytes >= 1024) {
            return number_format($bytes / 1024, 2) . ' KB';
        } else {
            return $bytes . ' bytes';
        }
    }
}
