# Quick Fix: CORS Issue with Images

## Problem
Flutter web cannot access Firebase Storage images due to CORS restrictions. Both `Image.network()` and `ref.getData()` are blocked.

## Quick Solution (Temporary)

Make images publicly readable to bypass CORS. This is a **temporary fix** for development.

### Step 1: Update Storage Rules

1. Go to Firebase Console: https://console.firebase.google.com/project/civicissue-aae6d/storage/rules

2. Replace the rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // TEMPORARY: Allow public read for issues folder (for Flutter web CORS fix)
    match /issues/{allPaths=**} {
      allow read: if true;  // Public read (TEMPORARY)
      allow write: if request.auth != null;
    }
    
    // Keep other paths secure
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

### Step 2: Update Code to Use Direct URLs

Since images are now publicly readable, we can use `Image.network()` directly:

Update `dashboard_screen.dart` to use the original URL directly:

```dart
// Use original URL directly (now that it's publicly readable)
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  // ... error handling
)
```

### Step 3: Restart App

Restart your Flutter app and images should load!

## ⚠️ Security Note

**This makes images publicly accessible!** Anyone with the URL can view images.

For production, you should:
1. Install gcloud CLI
2. Configure CORS properly (see `SETUP_STORAGE_CORS.md`)
3. Revert Storage rules to require authentication

## Proper Solution (Later)

Once you have gcloud CLI installed:

```bash
# Install gcloud (macOS)
brew install google-cloud-sdk

# Authenticate
gcloud auth login
gcloud config set project civicissue-aae6d

# Configure CORS
./setup-storage-cors.sh
```

Then revert Storage rules to require authentication.


