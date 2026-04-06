<?php
// File: app/Controllers/Counselor/Dashboard.php

namespace App\Controllers\Counselor;

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
        // Ensure Manila timezone
        date_default_timezone_set('Asia/Manila');

        // Debug session data
        $session = session();
        $loggedIn = $session->get('logged_in');
        $role = $session->get('role');
        $userId = $session->get('user_id');

        // Log session data for debugging
        log_message('debug', 'Counselor Dashboard - Session check: logged_in=' . ($loggedIn ? 'true' : 'false') . ', role=' . $role . ', user_id=' . $userId);

        // Ensure user is logged in
        if (!$loggedIn) {
            log_message('debug', 'Counselor Dashboard - User not logged in, redirecting to landing page');
            return redirect()->to('/');
        }

        // Check if user has counselor role, if not redirect to appropriate dashboard
        if ($role !== 'counselor') {
            log_message('debug', 'Counselor Dashboard - User role is ' . $role . ', redirecting to appropriate dashboard');
            if ($role === 'admin') {
                return redirect()->to(base_url('admin/dashboard'));
            } else {
                return redirect()->to(base_url('user/dashboard'));
            }
        }

        $data = [
            'title' => 'Counselor Dashboard',
            'username' => $session->get('username'),
            'email' => $session->get('email')
        ];

        return view('counselor/dashboard', $data);
    }

    /**
     * Get recent pending appointments for the logged-in counselor
     * Returns the 2 most recent pending appointments where counselor_preference matches the logged-in counselor
     *
     * @return \CodeIgniter\HTTP\ResponseInterface
     */
    public function getRecentPendingAppointments()
    {
        // Verify counselor is logged in
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'status' => 'error',
                'message' => 'Unauthorized access - Please log in as counselor',
                'appointments' => []
            ], 401);
        }

        try {
            // Use user_id_display which contains the actual counselor ID
            $counselor_id = session()->get('user_id_display') ?? session()->get('user_id');

            if (!$counselor_id) {
                log_message('error', '[Counselor Dashboard] No counselor ID found in session');
                return $this->respond([
                    'status' => 'error',
                    'message' => 'Counselor ID not found',
                    'appointments' => []
                ], 400);
            }

            $db = \Config\Database::connect();

            // Set Manila timezone for this connection
            $db->query("SET time_zone = '+08:00'");

            // Query to get recent pending appointments for this counselor
            $query = "SELECT
                    a.id,
                    a.student_id,
                    a.preferred_date,
                    a.preferred_time,
                    a.method_type,
                    a.purpose,
                    a.counselor_preference,
                    a.status,
                    a.created_at,
                    COALESCE(CONCAT(spi.first_name, ' ', spi.last_name), u.username, a.student_id) as student_name,
                    u.email as user_email,
                    COALESCE(CONCAT(sai.course, ' - ', sai.year_level), 'N/A') as course_year
                  FROM appointments a
                  LEFT JOIN users u ON a.student_id = u.user_id
                  LEFT JOIN student_personal_info spi ON spi.student_id = u.user_id
                  LEFT JOIN student_academic_info sai ON sai.student_id = u.user_id
                  WHERE a.status = 'pending'
                  AND a.counselor_preference = ?
                  ORDER BY a.created_at DESC
                  LIMIT 2";

            $result = $db->query($query, [$counselor_id]);

            if (!$result) {
                log_message('error', '[Counselor Dashboard] Query failed: ' . $db->error());
                return $this->respond([
                    'status' => 'error',
                    'message' => 'Database query failed',
                    'appointments' => []
                ], 500);
            }

            $appointments = $result->getResultArray();

            log_message('info', '[Counselor Dashboard] Fetched ' . count($appointments) . ' pending appointments for counselor: ' . $counselor_id);

            return $this->respond([
                'status' => 'success',
                'appointments' => $appointments,
                'count' => count($appointments)
            ]);
        } catch (\Exception $e) {
            log_message('error', '[Counselor Dashboard] Error fetching pending appointments: ' . $e->getMessage());
            log_message('error', '[Counselor Dashboard] Stack trace: ' . $e->getTraceAsString());

            return $this->respond([
                'status' => 'error',
                'message' => 'An error occurred while fetching appointments',
                'appointments' => [],
                'debug' => ENVIRONMENT === 'development' ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Submit a new quote with Manila timezone
     */
    public function submitQuote()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 401);
        }

        $quoteModel = new QuoteModel();

        $data = [
            'quote_text' => $this->request->getPost('quote_text'),
            'author_name' => $this->request->getPost('author_name'),
            'category' => $this->request->getPost('category'),
            'source' => $this->request->getPost('source'),
            'submitted_by_id' => session()->get('user_id_display') ?? session()->get('user_id'),
            'submitted_by_name' => session()->get('username'),
            'submitted_by_role' => 'counselor',
            'status' => 'pending'
        ];

        if ($quoteModel->insert($data)) {
            log_message('info', '[Quote] New quote submitted by counselor: ' . $data['submitted_by_id'] . ' at ' . TimezoneHelper::getManilaDateTime() . ' (Manila time)');

            return $this->respond([
                'success' => true,
                'message' => 'Quote submitted successfully! It will be visible once approved by an admin.'
            ]);
        } else {
            return $this->respond([
                'success' => false,
                'message' => 'Failed to submit quote',
                'errors' => $quoteModel->errors()
            ], 400);
        }
    }

    /**
     * Get counselor's submitted quotes
     */
    public function getMyQuotes()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 401);
        }

        $quoteModel = new QuoteModel();
        $counselorId = session()->get('user_id_display') ?? session()->get('user_id');

        $quotes = $quoteModel->getCounselorQuotes($counselorId);

        // Format dates to Manila timezone for display
        foreach ($quotes as &$quote) {
            if (isset($quote['created_at'])) {
                $quote['submitted_at'] = $quote['created_at'];
                $quote['submitted_at_formatted'] = TimezoneHelper::formatManilaDateTime($quote['created_at']);
            }
            if (isset($quote['moderated_at']) && $quote['moderated_at']) {
                $quote['moderated_at_formatted'] = TimezoneHelper::formatManilaDateTime($quote['moderated_at']);
            }
        }

        return $this->respond([
            'success' => true,
            'quotes' => $quotes,
            'current_manila_time' => TimezoneHelper::getManilaDateTime()
        ]);
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
     * Update a quote (only for pending quotes)
     */
    public function updateQuote($quoteId)
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 401);
        }

        $quoteModel = new QuoteModel();
        $counselorId = session()->get('user_id_display') ?? session()->get('user_id');

        // Verify quote belongs to counselor and is pending
        $quote = $quoteModel->find($quoteId);
        if (!$quote) {
            return $this->respond([
                'success' => false,
                'message' => 'Quote not found'
            ], 404);
        }

        if ($quote['submitted_by_id'] !== $counselorId) {
            return $this->respond([
                'success' => false,
                'message' => 'You can only edit your own quotes'
            ], 403);
        }

        if ($quote['status'] !== 'pending') {
            return $this->respond([
                'success' => false,
                'message' => 'You can only edit pending quotes'
            ], 400);
        }

        // Handle both POST and PUT requests
        // For PUT requests with URL-encoded data, parse it manually if needed
        $quoteText = $this->request->getPost('quote_text');
        $authorName = $this->request->getPost('author_name');
        $category = $this->request->getPost('category');
        $source = $this->request->getPost('source');
        
        // If POST data is empty (PUT request), try getVar or parse raw input
        if (empty($quoteText)) {
            $quoteText = $this->request->getVar('quote_text');
        }
        if (empty($authorName)) {
            $authorName = $this->request->getVar('author_name');
        }
        if (empty($category)) {
            $category = $this->request->getVar('category');
        }
        if ($source === null) {
            $source = $this->request->getVar('source');
        }
        
        // If still empty, try parsing raw input for PUT requests
        if (empty($quoteText) || empty($authorName) || empty($category)) {
            $rawInput = $this->request->getBody();
            if (!empty($rawInput)) {
                parse_str($rawInput, $parsedData);
                $quoteText = $quoteText ?: ($parsedData['quote_text'] ?? '');
                $authorName = $authorName ?: ($parsedData['author_name'] ?? '');
                $category = $category ?: ($parsedData['category'] ?? '');
                $source = $source ?: ($parsedData['source'] ?? '');
            }
        }
        
        $data = [
            'quote_text' => $quoteText,
            'author_name' => $authorName,
            'category' => $category,
            'source' => $source ?: null
        ];

        if ($quoteModel->update($quoteId, $data)) {
            log_message('info', '[Quote] Quote updated by counselor: ' . $counselorId . ' - Quote ID: ' . $quoteId);

            return $this->respond([
                'success' => true,
                'message' => 'Quote updated successfully'
            ]);
        } else {
            return $this->respond([
                'success' => false,
                'message' => 'Failed to update quote',
                'errors' => $quoteModel->errors()
            ], 400);
        }
    }

    /**
     * Delete a quote
     */
    public function deleteQuote($quoteId)
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 401);
        }

        $quoteModel = new QuoteModel();
        $counselorId = session()->get('user_id_display') ?? session()->get('user_id');

        // Verify quote belongs to counselor
        $quote = $quoteModel->find($quoteId);
        if (!$quote) {
            return $this->respond([
                'success' => false,
                'message' => 'Quote not found'
            ], 404);
        }

        if ($quote['submitted_by_id'] !== $counselorId) {
            return $this->respond([
                'success' => false,
                'message' => 'You can only delete your own quotes'
            ], 403);
        }

        if ($quoteModel->delete($quoteId)) {
            log_message('info', '[Quote] Quote deleted by counselor: ' . $counselorId . ' - Quote ID: ' . $quoteId);

            return $this->respond([
                'success' => true,
                'message' => 'Quote deleted successfully'
            ]);
        } else {
            return $this->respond([
                'success' => false,
                'message' => 'Failed to delete quote'
            ], 500);
        }
    }

    /**
     * Get resources visible to counselors
     */
    public function getResources()
    {
        if (!session()->get('logged_in') || session()->get('role') !== 'counselor') {
            return $this->respond(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            $resourceModel = new ResourceModel();
            $resources = $resourceModel->getResourcesByVisibility('counselors', true);
            
            // Format file sizes and dates
            foreach ($resources as &$resource) {
                if ($resource['file_size']) {
                    $resource['file_size_formatted'] = $this->formatFileSize($resource['file_size']);
                }
                $resource['created_at_formatted'] = date('M d, Y h:i A', strtotime($resource['created_at']));
            }
            
            return $this->respond(['success' => true, 'resources' => $resources]);
        } catch (\Exception $e) {
            log_message('error', '[Counselor Resources] Error fetching resources: ' . $e->getMessage());
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
