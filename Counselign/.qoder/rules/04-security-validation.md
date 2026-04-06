---
trigger: always_on
alwaysApply: true
---
# Security, Validation & Privacy Standards

## Authentication & Authorization

### Client-Side (Flutter)
**Rules:**
- Verify auth state before privileged screens
- Store tokens in secure storage (`lib/utils/secure_storage.dart`)
- Gate routes with navigation guards
- Enforce roles in backend, hide UI in client
- Clear sensitive data on logout

**Avoid:**
- Hardcoded credentials
- Tokens in plain storage
- Auth logic only in UI
- Exposing admin features without checks

### Backend (CodeIgniter 4)
**Rules:**
- Validate sessions on every protected endpoint
- Use CI4 Filters for auth middleware
- Implement role-based access control
- Log authentication events
- Rate limit auth endpoints

## Input Validation & Sanitization

### Flutter Frontend
**Validation:**
- Use form validators for all inputs
- Validate before API calls
- Surface user-friendly error messages
- Use `autovalidateMode` appropriately

**Sanitization:**
- Trim whitespace
- Enforce length limits
- Validate formats (email, phone, etc.)
- Normalize data in view models

**Error Display:**
- Show concise, helpful messages
- Never expose technical details
- Use SnackBars or inline errors
- Provide actionable guidance

### Backend Validation
**Rules:**
- Use CI4 Validation library
- Validate all endpoints
- Reject invalid data early
- Return structured error responses

**Never Trust Client:**
- Validate on server always
- Sanitize before database
- Check authorization
- Log validation failures

## Transport Security

### HTTPS & Network
**Requirements:**
- HTTPS-only backends
- Configure in `lib/api/config.dart`
- Set appropriate timeouts
- Handle network errors gracefully

**Headers & Tokens:**
- Attach tokens via interceptors
- Refresh tokens when expired
- Handle 401 responses
- Clear tokens on logout

### CORS & Web Builds
**Rules:**
- Configure CORS on backend
- Whitelist allowed origins
- Handle preflight requests
- Test web builds separately

## Error Handling

### User-Facing Errors
**Do:**
- Show friendly error messages
- Provide actionable steps
- Use consistent error UI
- Log errors for debugging

**Never:**
- Show raw stack traces
- Expose internal errors
- Display technical jargon
- Leak sensitive info

### Error Logging
**Frontend (`lib/utils/secure_logger.dart`):**
- Structured logging format
- Include context (user ID, action, timestamp)
- Different levels (info, warning, error)
- Remove verbose logs in release builds

**Backend (CI4 Logger):**
- Log security events
- Log failed validations
- Log authentication attempts
- Rotate logs regularly

### Error Mapping
**Centralize in API Layer:**
- Network errors → "Connection failed"
- Parsing errors → "Invalid response"
- Timeout errors → "Request timed out"
- Server errors → "Something went wrong"

## Data Privacy & Storage

### Sensitive Data Handling
**Rules:**
- Store tokens in secure storage only
- Minimize PII persistence
- Prefer in-memory for temporary data
- Clear sensitive data appropriately

**Avoid:**
- Logging passwords or tokens
- Storing PII unnecessarily
- Sending sensitive data in URLs
- Caching sensitive responses

### Platform Storage
**Secure Storage:**
- Use `flutter_secure_storage` for secrets
- Platform-specific encryption
- Biometric protection when available
- Clear on app uninstall

**Shared Preferences:**
- Non-sensitive config only
- User preferences
- App settings
- Feature flags

### Database Security (Backend)
**Rules:**
- Parameterized queries only
- Hash passwords (bcrypt/argon2)
- Encrypt sensitive columns
- Use database triggers for integrity

**Avoid:**
- Raw SQL with user input
- Storing passwords in plain text
- Exposing internal IDs
- Logging query values

## Permission Handling

### Mobile Permissions
**Best Practices:**
- Request only when needed
- Explain why in UI
- Handle denied gracefully
- Respect user choice

**Required Permissions:**
- Document in README
- Minimal necessary set
- Alternative flows if denied
- Re-request with context

## Session Management

### Session Security
**Frontend:**
- Store session tokens securely
- Implement auto-logout on inactivity
- Clear session on logout
- Refresh sessions appropriately

**Backend:**
- Secure session configuration
- HTTP-only cookies
- Session timeout
- Regenerate on privilege change

## Secure Logging Guidelines

### What to Log
**Do Log:**
- User actions (login, logout, key operations)
- API requests/responses (sanitized)
- Error conditions
- Security events

**Never Log:**
- Passwords or tokens
- Credit card numbers
- PII without hashing
- Sensitive API responses

### Log Structure
```dart
{
  "timestamp": "ISO 8601",
  "level": "INFO|WARNING|ERROR",
  "userId": "hashed or anonymized",
  "action": "descriptive action",
  "context": "relevant context",
  "result": "success|failure"
}
```

## Third-Party Dependencies

### Security Updates
**Rules:**
- Regularly update dependencies
- Monitor security advisories
- Test after updates
- Document dependency versions

### Vetting Libraries
**Before Adding:**
- Check maintenance status
- Review security history
- Verify license compatibility
- Consider alternatives

## Compliance Considerations

### Data Protection
- Follow GDPR/local regulations
- Implement data deletion
- Provide data export
- Document data flows

### Audit Trail
- Log significant operations
- Immutable audit logs
- Retention policies
- Access controls on logs
