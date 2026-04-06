# Backend Security Deployment Guide

## ✅ Security Configurations Applied

The following security enhancements have been applied to your CodeIgniter backend in the `Counselign` folder:

### 1. Session Security Configuration
- **File**: `app/Config/Session.php`
- **Changes Applied**:
  - `expiration`: Reduced from 7200 (2 hours) to 3600 (1 hour)
  - `matchIP`: Enabled (true) for better session hijacking protection
  - `regenerateDestroy`: Enabled (true) to destroy old session on regenerate
  - Added `cookieSecure`: Set to false for localhost (set to true in production with HTTPS)
  - Added `cookieHTTPOnly`: Enabled (true) to prevent XSS attacks
  - Added `cookieSameSite`: Set to 'Lax' (use 'Strict' in production)

### 2. CSRF Protection
- **File**: `app/Config/Filters.php`
- **Changes Applied**:
  - Enabled CSRF protection in global before filters
  - Enabled security headers in global after filters

- **File**: `app/Config/Security.php`
- **Changes Applied**:
  - `csrfProtection`: Changed to 'both' for maximum security
  - `tokenRandomize`: Enabled (true) for added security

### 3. Database Security
- **File**: `app/Config/Database.php`
- **Changes Applied**:
  - `DBDebug`: Set to false (was true) - prevents exposing errors in production
  - `saveQueries`: Set to false - prevents logging sensitive queries
  - `strictOn`: Already set to true - maintains data integrity

### 4. Logging Security
- **File**: `app/Config/Logger.php`
- **Changes Applied**:
  - `filePermissions`: Changed from 0644 to 0640 for restricted access
  - Existing threshold settings already configured for production

## 📋 Deployment Instructions

### Step 1: Backup Your Current Backend
1. Navigate to your XAMPP htdocs folder
2. Create a backup of your current `Counselign` folder:
   ```bash
   # In Windows Command Prompt or PowerShell
   xcopy C:\xampp\htdocs\Counselign C:\xampp\htdocs\Counselign_backup\ /E /I
   ```

### Step 2: Copy Updated Configuration Files
Copy ONLY the following configuration files from the `Counselign` folder in this project to your XAMPP htdocs:

#### From This Project Location:
- `Counselign/app/Config/Session.php`
- `Counselign/app/Config/Filters.php`
- `Counselign/app/Config/Security.php`
- `Counselign/app/Config/Database.php`
- `Counselign/app/Config/Logger.php`

#### To Your XAMPP Location:
```
C:\xampp\htdocs\Counselign\app\Config\
```

### Step 3: Verify the Changes
1. Open each file in a text editor
2. Verify the changes match the "Changes Applied" sections above
3. Make sure your database credentials in `Database.php` are still correct

### Step 4: Test Your Application
1. Start XAMPP (Apache and MySQL)
2. Navigate to your application in the browser
3. Test login functionality
4. Test other POST requests (they should now require CSRF tokens)

### Step 5: Test CSRF Protection
When CSRF is enabled, you'll need to update your Flutter app to handle CSRF tokens. However, for localhost testing, you may want to temporarily disable CSRF if you haven't implemented token handling yet.

To temporarily disable CSRF for testing, edit `app/Config/Filters.php`:
```php
public array $globals = [
    'before' => [
        'cors',
        // 'csrf',  // Temporarily commented out
    ],
```

## ⚠️ Important Notes

### For Localhost Development:
- Session cookie is set to non-secure (cookieSecure = false)
- SameSite is set to 'Lax' (more lenient for development)
- CSRF protection is enabled but may cause issues if not handled in frontend

### When Moving to Production:
1. **Set up HTTPS** - This is CRITICAL
2. Update `app/Config/Session.php`:
   ```php
   public bool $cookieSecure = true; // Enable secure cookies
   public string $cookieSameSite = 'Strict'; // Use strict same-site
   ```
3. Update `app/Config/App.php`:
   ```php
   public string $baseURL = 'https://your-domain.com/Counselign/public/';
   public bool $forceGlobalSecureRequests = true;
   ```
4. Configure your web server (Apache/Nginx) for HTTPS
5. Update Flutter app to use HTTPS URL instead of HTTP

### CSRF Token Handling (Future Enhancement)
Your Flutter app will need to handle CSRF tokens for POST requests. This requires:
1. Fetch CSRF token on app start
2. Include token in POST request headers
3. Implement token rotation

For now, CSRF is enabled but if you experience issues, you can temporarily disable it for development.

## 🔍 Testing Checklist

After deployment, verify:
- [ ] Application loads without errors
- [ ] Login still works
- [ ] Session expires after 1 hour of inactivity
- [ ] Cookies are HTTP-only (check browser dev tools)
- [ ] No sensitive data in logs
- [ ] Database connection works
- [ ] All features work as expected

## 📊 Security Improvements Summary

### Before:
- ❌ Sessions lasted 2 hours
- ❌ IP matching disabled
- ❌ No CSRF protection
- ❌ No security headers
- ❌ Query logging enabled
- ❌ Debug mode enabled
- ❌ Permissive file permissions

### After:
- ✅ Sessions last 1 hour
- ✅ IP matching enabled
- ✅ CSRF protection enabled
- ✅ Security headers enabled
- ✅ Query logging disabled
- ✅ Debug mode disabled
- ✅ Restricted file permissions (0640)
- ✅ Secure cookie configuration
- ✅ CSRF token randomization

## 🚨 Troubleshooting

### Issue: App stops working after deployment
**Solution**: Temporarily disable CSRF by commenting it out in `Filters.php`

### Issue: Sessions not working
**Solution**: Check that the session directory exists and is writable:
```php
// Path should be: app/writable/session/
```

### Issue: Can't connect to database
**Solution**: Verify database credentials in `Database.php` are correct

### Issue: 403 Forbidden on POST requests
**Solution**: CSRF protection is blocking requests. Either:
1. Implement CSRF token handling in Flutter app
2. Temporarily disable CSRF for development

## 📝 Next Steps

1. **Immediate**: Copy these config files to your XAMPP htdocs
2. **Short-term**: Test thoroughly and ensure compatibility
3. **Long-term**: Set up HTTPS and update configurations for production

## 🔐 Production Checklist

Before deploying to production:
- [ ] Set up SSL certificate
- [ ] Enable HTTPS
- [ ] Update `cookieSecure` to true
- [ ] Update `cookieSameSite` to 'Strict'
- [ ] Update `baseURL` to HTTPS
- [ ] Enable `forceGlobalSecureRequests`
- [ ] Implement CSRF token handling in Flutter app
- [ ] Set up proper firewall rules
- [ ] Configure regular backups
- [ ] Set up monitoring and logging

---

**Remember**: These changes make your backend more secure but work best when combined with HTTPS. Always use HTTPS in production!

