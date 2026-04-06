# Quotes & Resources Debug Checklist

## Fixed Issues ✓
1. **Syntax Error** - Fixed spread operator in resources_accordion.dart (line 500)
2. **Download Functionality** - Implemented authenticated downloads using Session class with DownloadHelper
   - Downloads maintain session authentication
   - Files saved to device storage
   - Automatically opens downloaded files
3. **Preview Functionality** - Enhanced for all file types
   - Images: Interactive zoom/pan preview
   - PDFs, Word, Excel, PowerPoint, Videos: Preview dialog with file type icon and "Download & Open" button
4. **All lint errors cleared** - `flutter analyze` passes with no issues
5. **Improved Error Handling** - Better quote parsing with individual error catching

## What's Working ✓
- Event carousel displays events from database
- Resources accordion loads and displays resources from database
- Profile container layout optimized with proper icon sizing
- Text overflow handling for long filenames
- Preview dialog for images (with interactive zoom/pan)
- Preview dialog for all file types (PDFs, Word, Excel, PowerPoint, Videos)
- Authenticated downloads using Session class
- Files automatically save to Downloads folder and open with appropriate app

## Issues to Debug

### 1. Quotes Carousel Not Showing Database Quotes

**Current Behavior:** Showing fallback quotes instead of database quotes

**Debug Steps:**

1. **Run the app** and watch the console output for these logs:
   ```
   QuoteService: Fetching from [URL]
   QuoteService: Response status: [CODE]
   QuoteService: Full Response body: [JSON]
   QuoteService: Data success: [true/false]
   QuoteService: Quotes count: [number]
   QuoteService: Parsed X quotes from API
   QuoteService: Quote 0: [first 50 chars]...
   ```

2. **Check Database:**
   - Open phpMyAdmin and check the `daily_quotes` table
   - Verify there are quotes with `status = 'approved'`
   - Check field names are: `id`, `quote_text`, `author_name`, `category`

3. **Check Backend API:**
   - Open browser and go to: `http://192.168.18.89/Counselign/public/student/quotes/approved-quotes`
   - You should see JSON response like:
     ```json
     {
       "success": true,
       "quotes": [
         {
           "id": 1,
           "quote_text": "...",
           "author_name": "...",
           "category": "...",
           ...
         }
       ],
       "count": X
     }
     ```

4. **Expected vs Actual:**
   - If API returns `"success": false` → Backend issue
   - If API returns empty `"quotes": []` → No approved quotes in database
   - If console shows "Using fallback quotes" → Check console logs above it for the reason

**Common Causes:**
- No approved quotes in database (all are pending/rejected)
- Session authentication expired
- Backend API endpoint not accessible
- Database connection issue

### 2. Resource Download Testing

**Test Steps:**

1. **Test Image Download:**
   - Expand Resources accordion
   - Click on an image resource
   - Click "Preview" button
   - Verify image loads with zoom/pan functionality
   - Close preview
   - Click "Download" button
   - Verify download starts in in-app browser

2. **Test PDF Download:**
   - Click on a PDF resource
   - Click "Preview" button
   - Verify PDF preview dialog shows with "Open in PDF Viewer" button
   - Click "Open in PDF Viewer"
   - Verify PDF opens in device's PDF viewer or in-app browser

3. **Test Other File Types:**
   - Click on Word/Excel/PowerPoint resources
   - Click "Download" button
   - Verify file downloads via in-app browser

**Expected Behavior:**
- In-app webview should open with the file
- Download should start automatically
- Progress/completion notification should appear

**If Download Fails:**
- Check console for: `Downloading from: [URL]`
- Check console for: `Cannot launch download URL` error
- Verify session is still valid (not logged out)
- Check backend logs for authentication errors

## Console Commands for Debugging

### Check Quotes API Response
```bash
# From browser or curl
curl -b cookies.txt "http://192.168.18.89/Counselign/public/student/quotes/approved-quotes"
```

### Check Database
```sql
-- Check approved quotes count
SELECT COUNT(*) FROM daily_quotes WHERE status = 'approved';

-- View approved quotes
SELECT id, quote_text, author_name, category, status 
FROM daily_quotes 
WHERE status = 'approved' 
ORDER BY times_displayed ASC, RAND() 
LIMIT 10;
```

### Check Resources
```sql
-- Check resources visible to students
SELECT id, title, resource_type, file_name, visibility 
FROM resources 
WHERE is_active = 1 
AND (visibility = 'everyone' OR visibility LIKE '%students%')
ORDER BY created_at DESC;
```

## Next Steps

After running the app:

1. **Copy all console output** that contains:
   - "QuoteService:"
   - "ResourceService:"
   - "EventService:"
   - Any errors or stack traces

2. **Take screenshots** of:
   - The dashboard showing the quotes carousel
   - Any error messages
   - Database tables (daily_quotes, resources, events)

3. **Share findings** so we can:
   - Identify why fallback quotes are used
   - Verify download functionality works
   - Fix any remaining issues

## File Changes Made

### Modified Files:
1. `lib/studentscreen/widgets/resources_accordion.dart`
   - Line 500: Fixed spread operator syntax `..` → `...`
   - Added import for DownloadHelper
   - Replaced url_launcher download with authenticated DownloadHelper
   - Added `_buildFilePreview()` method for all file types
   - Added `_downloadAndOpenFile()` method with loading indicator

2. `lib/studentscreen/services/quote_service.dart`
   - Improved error handling with try-catch per quote
   - Better debug logging for parsing errors
   - Individual quote parsing to prevent one bad quote from breaking all

### New Files Created:
1. `lib/utils/download_helper.dart`
   - Downloads files using Session class (maintains authentication)
   - Saves to Downloads folder on device
   - Opens files automatically with appropriate app
   - Comprehensive error handling and logging

### Files with Debug Logging:
1. `lib/studentscreen/services/quote_service.dart` (lines 12-60)
2. `lib/studentscreen/services/event_service.dart` 
3. `lib/studentscreen/services/resource_service.dart` (lines 12-44)
4. `lib/studentscreen/widgets/resources_accordion.dart` (lines 28-53)

All debug logs use `debugPrint()` so they appear in console/terminal when running the app.
