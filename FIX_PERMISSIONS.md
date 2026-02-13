# 🔐 Fix Firestore Permissions for Notification Service

## Problem
The notification server cannot read user documents from Firestore, even though they exist. This is a **permissions issue**.

## Root Cause
The service account used by the notification server doesn't have permission to read the `users` collection due to Firestore security rules.

## Solution: Update Firestore Security Rules

### Option 1: Allow Service Account to Read Users (Recommended)

1. **Go to Firebase Console**
   - Navigate to: https://console.firebase.google.com/project/civicissue-aae6d/firestore/rules

2. **Update the Rules** to allow service account access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is admin
    function isAdmin() {
      return exists(/databases/$(database)/documents/adminusers/$(request.auth.uid));
    }
    
    // User profiles - users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if isAdmin(); // Admins can read all user profiles
      // Allow service account (server-side) to read all user profiles
      allow read: if request.auth == null; // This allows server-side access
    }
    
    // Issues/Complaints collection
    match /issues/{issueId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && 
        (resource.data.user_id == request.auth.uid || isAdmin());
      allow read: if isAdmin();
      allow update, delete: if isAdmin();
    }
    
    // Admin users collection
    match /adminusers/{adminId} {
      allow read: if isAdmin();
      allow write: if isAdmin();
      allow create: if request.auth != null && request.auth.uid == adminId;
    }
    
    // Default: deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**⚠️ Note:** The `request.auth == null` rule allows server-side access (service account), but this is less secure. See Option 2 for a better approach.

### Option 2: Use Firebase Admin SDK with Proper Service Account (Better Security)

The service account should bypass security rules automatically. If it's not working:

1. **Verify Service Account Key**
   - Make sure `service-account-key.json` has the correct permissions
   - The service account should have "Firebase Admin SDK Administrator Service Agent" role

2. **Check Service Account in Google Cloud Console**
   - Go to: https://console.cloud.google.com/iam-admin/iam?project=civicissue-aae6d
   - Find your service account
   - Ensure it has "Firebase Admin SDK Administrator Service Agent" role

### Option 3: Temporary Workaround - Store Email in Complaint

If you can't change the rules immediately, you could:

1. **Store user email in the complaint document** when it's created
2. **Update the notification server** to read email from the complaint instead

## Quick Test After Fix

1. Run the test script:
   ```bash
   node test-user-access.js
   ```

2. You should see:
   ```
   ✅ Document found!
   Data keys: [fullName, email, phonenumber, ...]
   ```

3. Then update a complaint status and notifications should work!

## Current Status

- ❌ Service account cannot read `users` collection
- ❌ Firestore rules are blocking server-side access
- ✅ User document exists in Firestore
- ✅ Notification server is running correctly

**Next Step:** Update Firestore security rules to allow service account access.





