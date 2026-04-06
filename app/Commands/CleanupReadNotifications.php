<?php

namespace App\Commands;

use App\Models\NotificationsModel;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;

/**
 * Command to clean up read notifications from the database
 * 
 * This command deletes all rows in the notifications table where is_read = 1
 * to reduce data load when retrieving notifications.
 * 
 * Usage: php spark cleanup:read-notifications
 * 
 * To run every minute via cron:
 * * * * * * cd /path/to/project && php spark cleanup:read-notifications
 */
class CleanupReadNotifications extends BaseCommand
{
    /**
     * The Command's Group
     *
     * @var string
     */
    protected $group = 'Maintenance';

    /**
     * The Command's Name
     *
     * @var string
     */
    protected $name = 'cleanup:read-notifications';

    /**
     * The Command's Description
     *
     * @var string
     */
    protected $description = 'Deletes all read notifications (is_read = 1) from the notifications table to reduce data load';

    /**
     * The Command's Usage
     *
     * @var string
     */
    protected $usage = 'cleanup:read-notifications';

    /**
     * The Command's Arguments
     *
     * @var array
     */
    protected $arguments = [];

    /**
     * The Command's Options
     *
     * @var array
     */
    protected $options = [];

    /**
     * Actually execute a command.
     *
     * @param array $params
     * @return void
     */
    public function run(array $params): void
    {
        try {
            CLI::write('Starting notifications cleanup...', 'yellow');
            
            // Initialize the NotificationsModel
            $notificationsModel = new NotificationsModel();
            
            // Execute the cleanup
            $result = $notificationsModel->deleteReadNotifications();
            
            if ($result['success']) {
                CLI::write(
                    sprintf(
                        'Cleanup completed successfully. Deleted %d read notification(s).',
                        $result['deleted_count']
                    ),
                    'green'
                );
                
                if ($result['deleted_count'] > 0) {
                    CLI::write($result['message'], 'cyan');
                }
            } else {
                CLI::error('Cleanup failed: ' . $result['message']);
                exit(1);
            }
        } catch (\Exception $e) {
            CLI::error('An error occurred during cleanup: ' . $e->getMessage());
            log_message('error', 'CleanupReadNotifications command error: ' . $e->getMessage());
            exit(1);
        }
    }
}

