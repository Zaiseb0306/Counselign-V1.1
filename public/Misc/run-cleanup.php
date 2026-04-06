<?php
/**
 * Standalone PHP script to run notifications cleanup
 * 
 * This script can be called directly by cron on both Windows and Linux
 * Works in both production and local development environments
 * 
 * Usage:
 * - Linux/Unix: php /path/to/project/run-cleanup.php
 * - Windows: C:\xampp\php\php.exe C:\xampp\htdocs\Counselign\run-cleanup.php
 * 
 * For cron (Linux/Unix):
 * * * * * * php /path/to/project/run-cleanup.php >> /path/to/project/writable/logs/cleanup.log 2>&1
 * 
 * For Windows Task Scheduler:
 * - Program: C:\xampp\php\php.exe
 * - Arguments: C:\xampp\htdocs\Counselign\run-cleanup.php
 * - Start in: C:\xampp\htdocs\Counselign
 */

/**
 * Simple wrapper script that calls the CodeIgniter spark command
 * This works on both Windows and Linux/Unix systems
 */

// Get the project root directory (where this script is located)
$projectRoot = dirname(__FILE__);

// Change to project root directory
chdir($projectRoot);

// Determine PHP executable path
// On Windows, try common XAMPP paths, otherwise use 'php' from PATH
// On Linux/Unix, use 'php' from PATH
$phpExecutable = 'php';
if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    // Windows - try common XAMPP paths
    $xamppPaths = [
        'C:\xampp\php\php.exe',
        'C:\Program Files\xampp\php\php.exe',
        'C:\wamp\bin\php\php.exe',
    ];
    
    foreach ($xamppPaths as $path) {
        if (file_exists($path)) {
            $phpExecutable = $path;
            break;
        }
    }
}

// Build the command
$command = escapeshellarg($phpExecutable) . ' spark cleanup:read-notifications';

// Execute the command
$output = [];
$returnVar = 0;
exec($command . ' 2>&1', $output, $returnVar);

// Output the results
echo implode(PHP_EOL, $output) . PHP_EOL;

// Log to file if writable directory exists
$logPath = $projectRoot . DIRECTORY_SEPARATOR . 'writable' . DIRECTORY_SEPARATOR . 'logs' . DIRECTORY_SEPARATOR . 'cleanup.log';
if (is_writable(dirname($logPath))) {
    $logMessage = sprintf(
        '[%s] %s%s',
        date('Y-m-d H:i:s'),
        implode(PHP_EOL, $output),
        PHP_EOL
    );
    file_put_contents($logPath, $logMessage, FILE_APPEND);
}

// Exit with the return code from the command
exit($returnVar);

