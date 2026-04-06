# Backend Security Configuration Guide

## Overview
This guide provides security recommendations for the CodeIgniter 4 backend running in `xampp/htdocs/` to address the vulnerabilities identified in the security audit.

## Critical Backend Security Fixes

### 1. Enable HTTPS (CRITICAL)
**Current Issue**: Backend uses HTTP instead of HTTPS
**Location**: Server configuration

**Solution**:
```apache
# In Apache virtual host configuration
<VirtualHost *:443>
    ServerName your-domain.com
    DocumentRoot /path/to/xampp/htdocs/Counselign/public
    
    SSLEngine on
    SSLCertificateFile /path/to/certificate.crt
    SSLCertificateKeyFile /path/to/private.key
    
    # Security headers
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
</VirtualHost>
```

### 2. Session Security Configuration
**Location**: `app/Config/App.php`

**Current Configuration**:
```php
public $sessionDriver            = 'CodeIgniter\Session\Handlers\FileHandler';
public $sessionCookieName        = 'ci_session';
public $sessionExpiration        = 7200;
public $sessionSavePath          = WRITEPATH . 'session';
public $sessionMatchIP           = false;
public $sessionTimeToUpdate      = 300;
public $sessionRegenerateDestroy = false;
```

**Secure Configuration**:
```php
public $sessionDriver            = 'CodeIgniter\Session\Handlers\FileHandler';
public $sessionCookieName        = 'ci_session';
public $sessionExpiration        = 3600; // Reduced to 1 hour
public $sessionSavePath          = WRITEPATH . 'session';
public $sessionMatchIP           = true; // Enable IP matching
public $sessionTimeToUpdate      = 300;
public $sessionRegenerateDestroy = true; // Regenerate on destroy
public $sessionCookieSecure      = true; // HTTPS only
public $sessionCookieHTTPOnly    = true; // HTTP only cookies
public $sessionCookieSameSite    = 'Strict'; // CSRF protection
```

### 3. CSRF Protection
**Location**: `app/Config/Filters.php`

**Enable CSRF Protection**:
```php
public $globals = [
    'before' => [
        'csrf' => ['except' => ['api/*']], // Enable CSRF except for API routes
    ],
    'after'  => [],
];
```

**For API Routes** (if needed):
```php
public $globals = [
    'before' => [
        'csrf' => ['except' => ['api/auth/login', 'api/auth/register']],
    ],
    'after'  => [],
];
```

### 4. Input Validation and Sanitization
**Location**: Controllers (e.g., `app/Controllers/Auth.php`)

**Example Secure Controller**:
```php
<?php

namespace App\Controllers;

use CodeIgniter\Controller;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Psr\Log\LoggerInterface;

class Auth extends Controller
{
    protected $validation;
    
    public function initController(RequestInterface $request, ResponseInterface $response, LoggerInterface $logger)
    {
        parent::initController($request, $response, $logger);
        
        // Load validation library
        $this->validation = \Config\Services::validation();
    }
    
    public function login()
    {
        // Define validation rules
        $rules = [
            'user_id' => [
                'rules' => 'required|min_length[3]|max_length[50]|alpha_numeric',
                'errors' => [
                    'required' => 'User ID is required',
                    'min_length' => 'User ID must be at least 3 characters',
                    'max_length' => 'User ID cannot exceed 50 characters',
                    'alpha_numeric' => 'User ID can only contain letters and numbers'
                ]
            ],
            'password' => [
                'rules' => 'required|min_length[8]',
                'errors' => [
                    'required' => 'Password is required',
                    'min_length' => 'Password must be at least 8 characters'
                ]
            ],
            'role' => [
                'rules' => 'required|in_list[student,counselor,admin]',
                'errors' => [
                    'required' => 'Role is required',
                    'in_list' => 'Invalid role selected'
                ]
            ]
        ];
        
        // Validate input
        if (!$this->validation->run($this->request->getPost(), $rules)) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $this->validation->getErrors()
            ]);
        }
        
        // Sanitize input
        $userId = $this->request->getPost('user_id');
        $password = $this->request->getPost('password');
        $role = $this->request->getPost('role');
        
        // Additional sanitization
        $userId = filter_var($userId, FILTER_SANITIZE_STRING);
        $role = filter_var($role, FILTER_SANITIZE_STRING);
        
        // Process login...
    }
}
```

### 5. Database Security
**Location**: `app/Config/Database.php`

**Secure Database Configuration**:
```php
public $default = [
    'DSN'      => '',
    'hostname' => 'localhost',
    'username' => 'counselign_user', // Use dedicated user
    'password' => 'strong_password_here', // Strong password
    'database' => 'counselign_db',
    'DBDriver' => 'MySQLi',
    'DBPrefix' => '',
    'pConnect' => false, // Disable persistent connections
    'DBDebug'  => false, // Disable debug in production
    'charset'  => 'utf8mb4',
    'DBCollat' => 'utf8mb4_unicode_ci',
    'swapPre'  => '',
    'encrypt'  => false,
    'compress' => false,
    'strictOn' => true, // Enable strict mode
    'failover' => [],
    'saveQueries' => false, // Disable query logging in production
];
```

### 6. Password Hashing
**Location**: Models (e.g., `app/Models/UserModel.php`)

**Secure Password Handling**:
```php
<?php

namespace App\Models;

use CodeIgniter\Model;

class UserModel extends Model
{
    protected $table = 'users';
    protected $primaryKey = 'id';
    protected $allowedFields = ['user_id', 'password', 'role', 'email', 'is_verified'];
    
    protected $beforeInsert = ['hashPassword'];
    protected $beforeUpdate = ['hashPassword'];
    
    protected function hashPassword(array $data)
    {
        if (isset($data['data']['password'])) {
            $data['data']['password'] = password_hash($data['data']['password'], PASSWORD_ARGON2ID);
        }
        return $data;
    }
    
    public function verifyPassword(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }
}
```

### 7. Rate Limiting
**Location**: `app/Config/Filters.php`

**Add Rate Limiting**:
```php
public $filters = [
    'rate_limit' => [
        'before' => ['throttle:10,60'], // 10 requests per minute
    ],
];
```

**Custom Rate Limiting Filter**:
```php
<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

class RateLimitFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $throttler = \Config\Services::throttler();
        
        if ($throttler->check($request->getIPAddress(), 10, 60) === false) {
            return service('response')->setStatusCode(429)->setJSON([
                'status' => 'error',
                'message' => 'Too many requests. Please try again later.'
            ]);
        }
    }
    
    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // No action needed
    }
}
```

### 8. Security Headers Middleware
**Location**: `app/Filters/SecurityHeaders.php`

```php
<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

class SecurityHeaders implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        // No action needed
    }
    
    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        $response->setHeader('X-Content-Type-Options', 'nosniff');
        $response->setHeader('X-Frame-Options', 'DENY');
        $response->setHeader('X-XSS-Protection', '1; mode=block');
        $response->setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
        $response->setHeader('Content-Security-Policy', "default-src 'self'");
        
        return $response;
    }
}
```

### 9. Logging Configuration
**Location**: `app/Config/Logger.php`

**Secure Logging Configuration**:
```php
public $threshold = 4; // Log only errors in production
public $handlers = [
    'CodeIgniter\Log\Handlers\FileHandler' => [
        'handles' => ['critical', 'alert', 'emergency', 'debug', 'error', 'info', 'notice', 'warning'],
        'fileExtension' => 'log',
        'filePermissions' => 0640, // Restrict file permissions
    ],
];
```

### 10. Environment Configuration
**Location**: `app/Config/App.php`

**Production Settings**:
```php
public $baseURL = 'https://your-domain.com/'; // HTTPS URL
public $indexPage = ''; // Remove index.php from URLs
public $uriProtocol = 'REQUEST_URI';
public $defaultLocale = 'en';
public $negotiateLocale = false;
public $supportedLocales = ['en'];
public $appTimezone = 'UTC';
public $charset = 'UTF-8';
public $forceGlobalSecureRequests = true; // Force HTTPS
public $sessionDriver = 'CodeIgniter\Session\Handlers\FileHandler';
public $sessionCookieName = 'ci_session';
public $sessionExpiration = 3600;
public $sessionSavePath = WRITEPATH . 'session';
public $sessionMatchIP = true;
public $sessionTimeToUpdate = 300;
public $sessionRegenerateDestroy = true;
public $sessionCookieSecure = true;
public $sessionCookieHTTPOnly = true;
public $sessionCookieSameSite = 'Strict';
public $cookieSecure = true;
public $cookieHTTPOnly = true;
public $cookieSameSite = 'Strict';
public $proxyIPs = '';
public $CSRFTokenName = 'csrf_test_name';
public $CSRFCookieName = 'csrf_cookie_name';
public $CSRFExpire = 7200;
public $CSRFRegenerate = true;
public $CSRFRedirect = true;
public $CSRFSameSite = 'Strict';
public $CSPEnabled = true;
```

## Implementation Priority

### Phase 1 (Critical - Implement Immediately)
1. **Enable HTTPS** - Configure SSL certificates
2. **Secure Session Configuration** - Update session settings
3. **Input Validation** - Add proper validation to all controllers
4. **Password Hashing** - Ensure all passwords use Argon2ID

### Phase 2 (High Priority - Within 1 Week)
1. **CSRF Protection** - Enable CSRF tokens
2. **Security Headers** - Add security middleware
3. **Rate Limiting** - Implement request throttling
4. **Database Security** - Use dedicated database user

### Phase 3 (Medium Priority - Within 2 Weeks)
1. **Logging Security** - Secure logging configuration
2. **Environment Hardening** - Production settings
3. **Content Security Policy** - Implement CSP headers
4. **File Upload Security** - Secure file handling

## Testing Checklist

- [ ] HTTPS is properly configured and working
- [ ] Session cookies are secure and HTTP-only
- [ ] CSRF protection is active
- [ ] Input validation prevents injection attacks
- [ ] Rate limiting prevents brute force attacks
- [ ] Security headers are present
- [ ] Password hashing uses Argon2ID
- [ ] Database uses dedicated user with minimal privileges
- [ ] Error messages don't leak sensitive information
- [ ] Logging doesn't contain sensitive data

## Monitoring and Maintenance

1. **Regular Security Audits** - Monthly security reviews
2. **Dependency Updates** - Keep CodeIgniter and dependencies updated
3. **Log Monitoring** - Monitor logs for suspicious activity
4. **Backup Security** - Ensure backups are encrypted
5. **Access Control** - Regular review of user permissions

## Emergency Response

If a security breach is detected:
1. **Immediate** - Change all passwords and session keys
2. **Short-term** - Review logs and identify compromised accounts
3. **Long-term** - Implement additional security measures
4. **Communication** - Notify affected users if necessary

This configuration will significantly improve the security posture of your CodeIgniter backend and address the critical vulnerabilities identified in the security audit.
