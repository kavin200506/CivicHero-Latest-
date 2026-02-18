# Update Firestore Rules for Notifications

## 🔴 Error
```
PERMISSION_DENIED: Missing or insufficient permissions
```

The notifications collection needs security rules to allow users to read/write their own notifications.

## ✅ Solution

### Step 1: Go to Firebase Console
1. Navigate to: https://console.firebase.google.com/project/civicissue-aae6d/firestore/rules

### Step 2: Update Rules

Add the notifications collection rules. The complete rules should look like this:

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
    }
    
    // Issues/Complaints collection
    match /issues/{issueId} {
      // Anyone authenticated can create an issue
      allow create: if request.auth != null;
      
      // Users can read their own issues
      allow read: if request.auth != null && 
        (resource.data.user_id == request.auth.uid || isAdmin());
      
      // Admins can read all issues
      allow read: if isAdmin();
      
      // Only admins can update/delete issues (to change status)
      allow update, delete: if isAdmin();
    }
    
    // Admin users collection
    match /adminusers/{adminId} {
      // Only admins can read admin users list
      allow read: if isAdmin();
      
      // Only admins can write (create/update) admin users
      allow write: if isAdmin();
      
      // Allow creating admin user during signup (if not exists)
      allow create: if request.auth != null && request.auth.uid == adminId;
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      // Users can create notifications (for their own userId)
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      
      // Users can read their own notifications
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      
      // Users can update/delete their own notifications
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      
      // Admins can read all notifications
      allow read: if isAdmin();
    }
    
    // Default: deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 3: Publish Rules
1. Click **"Publish"** button
2. Wait for rules to deploy (usually instant)

## What These Rules Do

- **Create**: Users can create notifications with their own `userId`
- **Read**: Users can only read notifications where `userId` matches their auth ID
- **Update/Delete**: Users can update/delete their own notifications
- **Admin Access**: Admins can read all notifications

## Testing

After updating rules:
1. Restart the app
2. Go to Notifications tab
3. Should load without permission errors

## Alternative: Quick Test Mode (Development Only)

If you want to test quickly, you can temporarily use test mode rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **Warning**: This allows any authenticated user to read/write all data. Only use for development/testing!




