# Setup Firebase Storage for Images

## 🚀 Quick Setup Steps:

### Step 1: Enable Firebase Storage
1. Go to: https://console.firebase.google.com/project/civicissue-aae6d/storage
2. Click **"Get started"** or **"Create bucket"**
3. Choose **"Start in test mode"** (for development)
   - OR **"Start in production mode"** (with security rules)
4. Select **Storage location** (same region as Firestore is recommended)
5. Click **"Done"**

### Step 2: Set Storage Security Rules

Go to **Rules** tab in Storage and set:

#### For Development (Test Mode):
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

#### For Production (More Secure):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload/read their own images
    match /issues/{userId}/{imageName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow all authenticated users to read images
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Step 3: Publish Rules
1. Click **"Publish"** button
2. Rules will be active immediately

---

## ✅ Storage Structure

Your app stores images at:
- Path: `issues/{userId}/{imageName}.jpg`
- Example: `issues/abc123/CH1234567890.jpg`

---

## 📋 What Your App Does:

1. **User captures image** → Uploads to Firebase Storage
2. **Storage path**: `issues/{user.uid}/{complaintId}.jpg`
3. **Gets download URL** → Saves URL to Firestore
4. **AI analysis** → Downloads image from Storage URL
5. **Displays image** → Uses Storage URL

---

## 🔒 Security Rules Explained:

- **Test mode**: All authenticated users can upload/read
- **Production mode**: Users can only upload to their own folder
- **Read access**: All authenticated users can view images (for admin dashboard)

---

## ✅ After Setup:

Your app will automatically:
- Upload images when users report issues
- Generate download URLs
- Store URLs in Firestore
- Allow AI to download images for analysis

**No manual folder creation needed!**







