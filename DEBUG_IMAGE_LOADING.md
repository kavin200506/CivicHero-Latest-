# Debug: Images Not Loading in Admin Dashboard

## Current Issue
Images show "Failed to load" in the admin dashboard.

## Debugging Steps

### 1. Check Browser Console
Open browser DevTools (F12) → Console tab and look for:
- `📸 ImageHelper: Processing URL: ...`
- `❌ Image load error for ...`
- Any CORS errors
- Any 403/404 errors

### 2. Check Network Tab
- Open DevTools → Network tab
- Filter by "Img" or "firebasestorage"
- Click on a failed image request
- Check:
  - **Status Code**: Should be 200 (if 403, it's a permissions issue)
  - **Request Headers**: Should include auth tokens
  - **Response**: What error message is returned

### 3. Test Image URL Directly
1. Copy an `image_url` from Firestore
2. Open it in a new browser tab (while logged into Firebase)
3. If it loads → URL is valid, issue is with Flutter web
4. If it doesn't load → Check Storage rules

### 4. Check Storage Rules
Current rules require authentication:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**For Flutter Web**, these rules should work, but the browser needs to send auth tokens.

### 5. Possible Solutions

#### Solution A: Make Images Publicly Readable (Temporary Test)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /issues/{allPaths=**} {
      allow read: if true;  // Public read
      allow write: if request.auth != null;
    }
  }
}
```
**⚠️ WARNING**: This makes images publicly accessible. Only for testing!

#### Solution B: Use Firebase Storage SDK Properly
The current code uses `ImageHelper.getAuthenticatedUrl()` which should work, but might need adjustment.

#### Solution C: Check CORS Configuration
Firebase Storage should handle CORS automatically, but verify in Firebase Console.

## Common Errors

### Error: 403 Forbidden
**Cause**: Storage rules blocking access
**Fix**: Ensure admin user is authenticated and rules allow read

### Error: CORS
**Cause**: Cross-origin request blocked
**Fix**: Firebase Storage should handle this automatically, but check browser console

### Error: Network Error
**Cause**: URL is invalid or network issue
**Fix**: Verify URL format in Firestore

## Next Steps

1. **Check browser console** for specific error messages
2. **Test image URL directly** in browser
3. **Verify admin user is authenticated** (check Firebase Auth)
4. **Try Solution A** (temporary public read) to test if it's a permissions issue

## Code Changes Made

1. ✅ Added `firebase_storage` package
2. ✅ Created `ImageHelper` to get authenticated URLs
3. ✅ Enhanced error handling with detailed logging
4. ✅ Added fallback to original URL if authenticated URL fails

## What to Report

If images still don't load, please provide:
1. Browser console error messages
2. Network tab status codes
3. Whether image URL works when opened directly in browser
4. Whether admin user is authenticated


