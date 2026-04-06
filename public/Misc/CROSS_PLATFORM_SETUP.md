# Cross-Platform Automatic Cleanup Setup

This guide explains how to set up automatic notifications cleanup that works in **both production and local development environments** on **Windows and Linux/Unix** systems.

## Overview

The system provides **three methods** for automatic cleanup:

1. **Standalone PHP Script** (`run-cleanup.php`) - **Recommended for production**
   - Works on both Windows and Linux/Unix
   - Can be called directly by cron or Task Scheduler
   - No CodeIgniter CLI dependencies

2. **HTTP Endpoint** (`/maintenance/cleanup-notifications`) - **Best for external cron services**
   - Works in both environments
   - Can be called by external cron services (EasyCron, cron-job.org, etc.)
   - Protected by secret key

3. **CodeIgniter CLI Command** (`php spark cleanup:read-notifications`)
   - Works in both environments
   - Requires CodeIgniter CLI access

## Method 1: Standalone PHP Script (Recommended)

### How It Works

The `run-cleanup.php` script is a standalone PHP file that:
- Works on both Windows and Linux/Unix
- Automatically detects the project root
- Can be called directly by cron or Task Scheduler
- Logs to `writable/logs/cleanup.log`

### Setup for Linux/Unix (Production/Development)

1. **Make the script executable** (optional):
   ```bash
   chmod +x run-cleanup.php
   ```

2. **Add to crontab**:
   ```bash
   crontab -e
   ```

3. **Add this line** (runs every minute):
   ```bash
   * * * * * /usr/bin/php /path/to/project/run-cleanup.php >> /path/to/project/writable/logs/cleanup.log 2>&1
   ```

   **Example** (adjust paths):
   ```bash
   * * * * * /usr/bin/php /var/www/html/Counselign/run-cleanup.php >> /var/www/html/Counselign/writable/logs/cleanup.log 2>&1
   ```

4. **Verify PHP path**:
   ```bash
   which php
   # Use the output path in crontab
   ```

### Setup for Windows (Local Development/Production)

1. **Open Task Scheduler**:
   - Press `Win + R`, type `taskschd.msc`, press Enter

2. **Create Basic Task**:
   - Name: `Cleanup Read Notifications`
   - Description: `Automatically deletes read notifications every minute`

3. **Set Trigger**:
   - Trigger: Daily
   - Start date: Today
   - Start time: Current time
   - Check "Repeat task every: 1 minute"
   - Duration: Indefinitely

4. **Set Action**:
   - Action: Start a program
   - Program/script: `C:\xampp\php\php.exe` (or your PHP path)
   - Add arguments: `C:\xampp\htdocs\Counselign\run-cleanup.php`
   - Start in: `C:\xampp\htdocs\Counselign`

5. **Configure Advanced Settings**:
   - Check "Run whether user is logged on or not"
   - Check "Run with highest privileges" (if needed)
   - Settings: Check "Run task as soon as possible after a scheduled start is missed"

6. **Test**:
   - Right-click task → "Run"
   - Check `writable/logs/cleanup.log` for output

## Method 2: HTTP Endpoint (Best for External Cron Services)

### How It Works

The HTTP endpoint `/maintenance/cleanup-notifications` can be called by:
- External cron services (EasyCron, cron-job.org, etc.)
- Server cron using `curl` or `wget`
- Any HTTP client

### Security

The endpoint is protected by a secret key that must be provided:
- As a query parameter: `?key=YOUR_SECRET_KEY`
- Or as a header: `X-Maintenance-Key: YOUR_SECRET_KEY`

### Configuration

1. **Set the secret key** in one of these ways:

   **Option A: Environment Variable (Recommended for Production)**
   ```bash
   # Linux/Unix
   export MAINTENANCE_SECRET_KEY="your-strong-random-secret-key-here"
   
   # Or add to .env file (if using environment files)
   MAINTENANCE_SECRET_KEY=your-strong-random-secret-key-here
   ```

   **Option B: Update App Config** (`app/Config/App.php`):
   ```php
   public string $maintenanceSecretKey = 'your-strong-random-secret-key-here';
   ```

   **Important**: Use a strong, random secret key in production!

2. **Generate a strong secret key**:
   ```bash
   # Linux/Unix
   openssl rand -hex 32
   
   # Or use online generator
   # https://randomkeygen.com/
   ```

### Setup for External Cron Services

1. **EasyCron** (https://www.easycron.com/):
   - URL: `https://yourdomain.com/maintenance/cleanup-notifications?key=YOUR_SECRET_KEY`
   - Schedule: Every minute
   - Method: GET

2. **cron-job.org** (https://cron-job.org/):
   - URL: `https://yourdomain.com/maintenance/cleanup-notifications?key=YOUR_SECRET_KEY`
   - Schedule: Every minute
   - Method: GET

3. **Other services**: Similar setup with your secret key

### Setup for Server Cron (Linux/Unix)

Add to crontab:
```bash
* * * * * curl -s "https://yourdomain.com/maintenance/cleanup-notifications?key=YOUR_SECRET_KEY" > /dev/null 2>&1
```

Or with wget:
```bash
* * * * * wget -q -O - "https://yourdomain.com/maintenance/cleanup-notifications?key=YOUR_SECRET_KEY" > /dev/null 2>&1
```

### Setup for Windows Task Scheduler

1. **Create a batch file** (`call-cleanup.bat`):
   ```batch
   @echo off
   curl -s "http://localhost/Counselign/public/maintenance/cleanup-notifications?key=YOUR_SECRET_KEY"
   ```

2. **Schedule the batch file** in Task Scheduler (same as Method 1)

## Method 3: CodeIgniter CLI Command

### Linux/Unix

Add to crontab:
```bash
* * * * * cd /path/to/project && /usr/bin/php spark cleanup:read-notifications >> /path/to/project/writable/logs/cleanup.log 2>&1
```

### Windows

Use the existing `cleanup-notifications.bat` file (already configured).

## Environment Detection

The system automatically works in both environments:

- **Local Development**: Uses local paths and configurations
- **Production**: Uses production paths and configurations
- **Cross-Platform**: Works on Windows, Linux, and Unix

## Verification

### Check if Cleanup is Running

1. **Check logs**:
   ```bash
   # Linux/Unix
   tail -f writable/logs/cleanup.log
   
   # Windows
   type writable\logs\cleanup.log
   ```

2. **Check CodeIgniter logs**:
   ```bash
   # Look for messages like:
   # "Notifications cleanup: Deleted X read notification(s)"
   tail -f writable/logs/log-YYYY-MM-DD.log
   ```

3. **Test manually**:
   ```bash
   # Linux/Unix
   php run-cleanup.php
   
   # Windows
   C:\xampp\php\php.exe run-cleanup.php
   ```

4. **Test HTTP endpoint**:
   ```bash
   curl "http://localhost/Counselign/public/maintenance/cleanup-notifications?key=YOUR_SECRET_KEY"
   ```

## Troubleshooting

### Script Not Running

1. **Check PHP path**:
   ```bash
   which php  # Linux/Unix
   where php  # Windows
   ```

2. **Check file permissions**:
   ```bash
   chmod +x run-cleanup.php  # Linux/Unix
   ```

3. **Check cron/Task Scheduler**:
   - Verify task is enabled
   - Check "Last Run Result"
   - Review task history

### HTTP Endpoint Not Working

1. **Check secret key**:
   - Verify it matches in config/environment
   - Check URL includes the key parameter

2. **Check server logs**:
   - Review CodeIgniter logs for errors
   - Check web server error logs

3. **Test with curl**:
   ```bash
   curl -v "http://yourdomain.com/maintenance/cleanup-notifications?key=YOUR_SECRET_KEY"
   ```

## Security Best Practices

1. **Use Strong Secret Keys**:
   - Generate random keys (32+ characters)
   - Use different keys for development and production
   - Never commit secret keys to version control

2. **Use Environment Variables**:
   - Store secret keys in environment variables
   - Use `.env` files (not committed to version control)

3. **Restrict Access**:
   - Use firewall rules to restrict access to maintenance endpoints
   - Consider IP whitelisting for production

4. **Monitor Logs**:
   - Regularly check logs for unauthorized access attempts
   - Set up alerts for suspicious activity

## Production Recommendations

1. **Use Method 1 (Standalone Script)** or **Method 2 (HTTP Endpoint)**:
   - More reliable than CLI commands
   - Better error handling
   - Easier to monitor

2. **Set up monitoring**:
   - Monitor cleanup logs
   - Set up alerts if cleanup fails
   - Track cleanup frequency

3. **Use external cron services** (Method 2):
   - More reliable than server cron
   - Better monitoring and alerting
   - Works even if server is temporarily down

## Summary

- **Method 1 (Standalone Script)**: Best for direct server cron/Task Scheduler
- **Method 2 (HTTP Endpoint)**: Best for external cron services and flexibility
- **Method 3 (CLI Command)**: Works but less flexible

All methods work in both **production and local development** environments on **Windows and Linux/Unix** systems.

