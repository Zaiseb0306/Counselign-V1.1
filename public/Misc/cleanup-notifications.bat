@echo off
REM Batch script to run the cleanup:read-notifications command
REM This script is designed to be run by Windows Task Scheduler every minute
REM Works in both local development and production environments

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM Try to use run-cleanup.php first (cross-platform method)
if exist "run-cleanup.php" (
    "C:\xampp\php\php.exe" run-cleanup.php
    goto :end
)

REM Fallback to spark command if run-cleanup.php doesn't exist
"C:\xampp\php\php.exe" spark cleanup:read-notifications

:end
REM Optional: Log output to a file (uncomment if needed)
REM "C:\xampp\php\php.exe" run-cleanup.php >> "writable\logs\cleanup.log" 2>&1

exit /b 0

