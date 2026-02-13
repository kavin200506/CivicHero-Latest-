# Create Firestore Database for civicissue-aae6d

## 🚀 Quick Steps:

### Step 1: Go to Firebase Console
1. Open: https://console.firebase.google.com/project/civicissue-aae6d/firestore
2. Or navigate: Firebase Console → Select project `civicissue-aae6d` → Firestore Database

### Step 2: Create Database
1. Click **"Create database"** button
2. Choose **"Start in production mode"** or **"Start in test mode"**
   - **Test mode**: Allows read/write for 30 days (good for development)
   - **Production mode**: Requires security rules (more secure)
3. Select **Cloud Firestore location**
   - Choose a region close to you (e.g., `us-central`, `asia-south1`, `europe-west`)
   - Click **"Enable"**

### Step 3: Set Up Security Rules (Important!)

After creating, go to **Rules** tab and set:

#### For Development (Test Mode):
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

#### For Production (More Secure):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Issues - users can create, read their own, admins can read all
    match /issues/{issueId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.user_id == request.auth.uid || 
         exists(/databases/$(database)/documents/adminusers/$(request.auth.uid)));
    }
    
    // Admin users - only admins can read
    match /adminusers/{adminId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/adminusers/$(request.auth.uid));
    }
  }
}
```

### Step 4: Publish Rules
1. Click **"Publish"** button
2. Rules will be active immediately

---

## ✅ After Creating Database:

Your app will automatically:
- Create collections when data is saved
- Store user data in `users` collection
- Store issues/complaints in `issues` collection
- Store admin users in `adminusers` collection

No manual collection creation needed!

---

## 📋 Collections Your App Uses:

Based on your code, these collections will be created automatically:
- `issues` - User complaints/reports
- `users` - User profiles
- `adminusers` - Admin user accounts







