# Automatic Notifications Cleanup - Windows Task Scheduler Setup

This guide explains how to set up automatic execution of the `cleanup:read-notifications` command every minute using Windows Task Scheduler.

## Prerequisites

- Windows operating system
- XAMPP installed (or PHP available in PATH)
- Project located at: `C:\xampp\htdocs\Counselign`

## Method 1: Using Batch File (Recommended)

### Step 1: Verify the Batch File

The batch file `cleanup-notifications.bat` is already created in the project root. Verify the paths match your setup:

- **Project Path**: `C:\xampp\htdocs\Counselign`
- **PHP Path**: `C:\xampp\php\php.exe`

If your paths are different, edit `cleanup-notifications.bat` and update the paths accordingly.

### Step 2: Create Windows Task Scheduler Task

1. **Open Task Scheduler**
   - Press `Win + R`, type `taskschd.msc`, and press Enter
   - Or search for "Task Scheduler" in the Start menu

2. **Create Basic Task**
   - Click "Create Basic Task..." in the right panel
   - Name: `Cleanup Read Notifications`
   - Description: `Automatically deletes read notifications every minute`

3. **Set Trigger**
   - Trigger: Select "Daily"
   - Start date: Today's date
   - Start time: Current time (or any time)
   - Check "Repeat task every: 1 minute"
   - Duration: Select "Indefinitely"

4. **Set Action**
   - Action: Select "Start a program"
   - Program/script: Browse to `C:\xampp\htdocs\Counselign\cleanup-notifications.bat`
   - Or enter: `C:\xampp\htdocs\Counselign\cleanup-notifications.bat`
   - Start in (optional): `C:\xampp\htdocs\Counselign`

5. **Finish**
   - Check "Open the Properties dialog for this task when I click Finish"
   - Click "Finish"

6. **Configure Advanced Settings**
   - In the Properties dialog:
     - **General Tab**: 
       - Check "Run whether user is logged on or not"
       - Check "Run with highest privileges" (if needed)
       - Configure for: "Windows 10" (or your Windows version)
     - **Conditions Tab**:
       - Uncheck "Start the task only if the computer is on AC power" (if you want it to run on battery)
       - Check "Wake the computer to run this task" (optional)
     - **Settings Tab**:
       - Check "Allow task to be run on demand"
       - Check "Run task as soon as possible after a scheduled start is missed"
       - If the task fails, restart every: `1 minute`
       - Attempt to restart up to: `3 times`
     - Click "OK"

7. **Test the Task**
   - Right-click the task in Task Scheduler
   - Select "Run"
   - Check the task history to verify it ran successfully

## Method 2: Using PowerShell Script

### Step 1: Verify the PowerShell Script

The PowerShell script `cleanup-notifications.ps1` is already created. Verify the paths match your setup.

### Step 2: Create Windows Task Scheduler Task

Follow the same steps as Method 1, but:

- **Program/script**: `powershell.exe`
- **Add arguments**: `-ExecutionPolicy Bypass -File "C:\xampp\htdocs\Counselign\cleanup-notifications.ps1"`

## Method 3: Direct PHP Command (Alternative)

If you prefer not to use batch/PowerShell files:

1. **Create Task** (same as Method 1, steps 1-2)

2. **Set Trigger** (same as Method 1, step 3)

3. **Set Action**:
   - Program/script: `C:\xampp\php\php.exe`
   - Add arguments: `spark cleanup:read-notifications`
   - Start in: `C:\xampp\htdocs\Counselign`

4. **Finish** (same as Method 1, steps 5-7)

## Verification

### Check Task Status

1. Open Task Scheduler
2. Find your task: "Cleanup Read Notifications"
3. Check the "Last Run Result" column
   - `0x0` = Success
   - Other values = Error (check task history)

### Check Logs

The cleanup command logs its operations. Check:
- `writable/logs/log-YYYY-MM-DD.log` for cleanup messages
- Look for entries like: "Notifications cleanup: Deleted X read notification(s)"

### Manual Test

Run the command manually to verify it works:

```cmd
cd C:\xampp\htdocs\Counselign
C:\xampp\php\php.exe spark cleanup:read-notifications
```

You should see output like:
```
Starting notifications cleanup...
Cleanup completed successfully. Deleted X read notification(s).
```

## Troubleshooting

### Task Not Running

1. **Check Task Status**
   - Open Task Scheduler
   - Check if task is enabled
   - Check "Last Run Result" for errors

2. **Check Task History**
   - In Task Scheduler, enable "Task Scheduler (Local)" → View → Show History
   - Check for error messages

3. **Verify Paths**
   - Ensure PHP path is correct: `C:\xampp\php\php.exe`
   - Ensure project path is correct: `C:\xampp\htdocs\Counselign`
   - Ensure `spark` file exists in project root

4. **Check Permissions**
   - Task should run with appropriate permissions
   - If using "Run whether user is logged on or not", ensure account has permissions

### Task Running But No Output

1. **Check Logs**
   - Review `writable/logs/log-YYYY-MM-DD.log`
   - Look for cleanup messages

2. **Enable Logging in Batch File**
   - Uncomment the logging line in `cleanup-notifications.bat`:
   ```batch
   "C:\xampp\php\php.exe" spark cleanup:read-notifications >> "C:\xampp\htdocs\Counselign\writable\logs\cleanup.log" 2>&1
   ```

### PHP Not Found

1. **Verify PHP Installation**
   - Check if `C:\xampp\php\php.exe` exists
   - If using a different XAMPP installation, update paths

2. **Alternative: Use PHP from PATH**
   - If PHP is in your system PATH, you can use `php` instead of full path
   - Update batch file accordingly

## Security Considerations

- The task runs with system/user permissions
- Ensure the account running the task has appropriate database access
- The cleanup command only deletes read notifications (`is_read = 1`), which is safe
- Consider restricting access to the batch/PowerShell scripts if needed

## Maintenance

- **Monitor Logs**: Periodically check logs to ensure cleanup is working
- **Task Status**: Check Task Scheduler periodically to ensure task is running
- **Update Paths**: If you move the project or change PHP location, update the task accordingly

## Notes

- The task runs every minute automatically
- No user interaction is required once set up
- The cleanup command is idempotent (safe to run multiple times)
- Only read notifications are deleted; unread notifications are preserved
- The `notification_reads` table is not affected by this cleanup (it's permanent tracking)

