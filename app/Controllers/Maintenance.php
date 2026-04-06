<?php

namespace App\Controllers;

use App\Models\NotificationsModel;
use CodeIgniter\API\ResponseTrait;
use CodeIgniter\Controller;

/**
 * Maintenance Controller
 * 
 * Handles automated maintenance tasks that can be called via HTTP
 * Protected by secret key for security
 */
class Maintenance extends Controller
{
    use ResponseTrait;

    /**
     * Cleanup read notifications endpoint
     * 
     * This endpoint can be called by external cron services or scheduled tasks
     * Protected by secret key in query parameter or header
     * 
     * Usage:
     * - GET /maintenance/cleanup-notifications?key=YOUR_SECRET_KEY
     * - Or set X-Maintenance-Key header
     * 
     * @return \CodeIgniter\HTTP\ResponseInterface
     */
    public function cleanupNotifications()
    {
        // Get secret key from config or environment
        $appConfig = config('App');
        $secretKey = getenv('MAINTENANCE_SECRET_KEY') ?: ($appConfig->maintenanceSecretKey ?? 'default-secret-key-change-in-production');
        
        // Get key from query parameter or header
        $providedKey = $this->request->getGet('key') ?? $this->request->getHeaderLine('X-Maintenance-Key');
        
        // Verify secret key
        if (empty($providedKey) || $providedKey !== $secretKey) {
            log_message('warning', 'Unauthorized maintenance cleanup attempt from IP: ' . $this->request->getIPAddress());
            return $this->respond([
                'status' => 'error',
                'message' => 'Unauthorized access'
            ], 401);
        }
        
        try {
            $notificationsModel = new NotificationsModel();
            $result = $notificationsModel->deleteReadNotifications();
            
            if ($result['success']) {
                log_message('info', sprintf(
                    'Maintenance cleanup completed via HTTP: Deleted %d read notification(s)',
                    $result['deleted_count']
                ));
                
                return $this->respond([
                    'status' => 'success',
                    'message' => $result['message'],
                    'deleted_count' => $result['deleted_count'],
                    'timestamp' => date('Y-m-d H:i:s')
                ]);
            } else {
                log_message('error', 'Maintenance cleanup failed: ' . $result['message']);
                return $this->respond([
                    'status' => 'error',
                    'message' => $result['message']
                ], 500);
            }
        } catch (\Exception $e) {
            log_message('error', 'Maintenance cleanup exception: ' . $e->getMessage());
            return $this->respond([
                'status' => 'error',
                'message' => 'An error occurred during cleanup: ' . $e->getMessage()
            ], 500);
        }
    }
}

