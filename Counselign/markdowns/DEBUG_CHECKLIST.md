# Debug Checklist for Quotes and Resources

## Changes Made

### 1. Quote Rotation Timer Fixed ✅
- Changed from 900 seconds (15 minutes) to **15 seconds**
- Quotes will now rotate every 15 seconds

### 2. Session-Based Authentication Added ✅
- All three services now use `Session()` class for authenticated API calls
- This ensures session cookies are sent with each request

### 3. Comprehensive Debug Logging Added ✅
All services and widgets now log:
- API URLs being called
- HTTP response status codes
- Response body content
- Parsing progress
- Error details with stack traces

## How to Debug

### Step 1: Restart the App Completely
```bash
# Stop the app, then run:
flutter clean
flutter run
```

### Step 2: Check Debug Console Output

Look for these log messages:

#### For Quotes:
```
QuoteService: Fetching from http://192.168.18.89/Counselign/public/student/quotes/approved-quotes
QuoteService: Response status: 200
QuoteService: Response body: {...}
QuoteService: Data keys: [success, quotes]
QuoteService: Quotes count: X
QuoteService: Parsed X quotes from API
```

#### For Resources:
```
ResourceService: Fetching from http://192.168.18.89/Counselign/public/student/resources/get
ResourceService: Response status: 200
ResourceService: Response body: {...}
ResourceService: Data success: true
ResourceService: Resources count: X
```

### Step 3: Identify the Issue

#### If you see "HTTP error 401" or "403":
- Session authentication failed
- Check if user is properly logged in
- Check if session cookies are being stored

#### If you see "Using fallback quotes":
- API returned empty list OR
- API response format doesn't match expected structure
- Check the response body in logs to see actual structure

#### If you see "No resources available":
- API returned empty list OR
- API response format doesn't match expected structure
- Check the response body in logs

#### If you see "Response status: 404":
- API endpoint doesn't exist
- Check backend route configuration

#### If you see parsing errors:
- Database field names don't match model expectations
- Check the "JSON data" logs to see actual field names

## Expected API Response Formats

### Quotes Endpoint: `/student/quotes/approved-quotes`
```json
{
  "success": true,
  "quotes": [
    {
      "id": 1,
      "quote_text": "Your quote here",
      "author_name": "Author Name",
      "category": "Inspirational",
      "icon": "🌱"
    }
  ]
}
```

### Resources Endpoint: `/student/resources/get`
```json
{
  "success": true,
  "resources": [
    {
      "id": 1,
      "title": "Resource Title",
      "description": "Description",
      "resource_type": "file",
      "category": "Category",
      "file_path": "uploads/resources/file.pdf",
      "file_name": "file.pdf",
      "file_type": "application/pdf",
      "file_size_formatted": "1.5 MB",
      "uploader_name": "Admin"
    }
  ]
}
```

## Common Issues and Solutions

### Issue: Quotes showing but they're fallback quotes
**Solution**: Check if API is returning empty list or different field names

### Issue: Resources accordion says "No resources available"
**Solution**: Check if API is returning empty list or different field names

### Issue: Both not loading
**Solution**: 
1. Check if backend server is running (XAMPP)
2. Check if IP address is correct in ApiConfig
3. Check if user session is valid
4. Check backend logs for errors

## Next Steps

After running the app, share the console output with these specific log lines:
1. The complete URL being called
2. The response status code
3. The response body (at least the first few lines)
4. Any error messages

This will help identify exactly where the issue is occurring.
