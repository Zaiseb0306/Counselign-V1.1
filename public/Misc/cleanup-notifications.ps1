# PowerShell script to run the cleanup:read-notifications command
# This script is designed to be run by Windows Task Scheduler every minute

# Set the project directory
$projectPath = "C:\xampp\htdocs\Counselign"
$phpPath = "C:\xampp\php\php.exe"
$logPath = Join-Path $projectPath "writable\logs\cleanup.log"

# Change to the project directory
Set-Location $projectPath

# Run the cleanup command
try {
    & $phpPath spark cleanup:read-notifications
    
    # Optional: Log with timestamp
    # $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    # "$timestamp - Cleanup completed" | Out-File -FilePath $logPath -Append
} catch {
    # Log errors if needed
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - Error: $_" | Out-File -FilePath $logPath -Append
}

exit 0

