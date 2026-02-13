# Setup CORS for Firebase Storage (Flutter Web)

## Problem
Flutter web cannot access Firebase Storage images due to CORS (Cross-Origin Resource Sharing) restrictions.

## Solution
Configure CORS on your Firebase Storage bucket to allow requests from your Flutter web app.

## Method 1: Using gcloud CLI (Recommended)

### Step 1: Install gcloud CLI (if not installed)

**macOS:**
```bash
brew install google-cloud-sdk
```

**Or download from:**
https://cloud.google.com/sdk/docs/install

### Step 2: Authenticate and Set Project

```bash
gcloud auth login
gcloud config set project civicissue-aae6d
```

### Step 3: Run the Setup Script

```bash
cd /Users/kavin/Development/projects/CivicHero
./setup-storage-cors.sh
```

### Step 4: Manual CORS Configuration (Alternative)

If the script doesn't work, create `cors-config.json`:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD"],
    "responseHeader": ["Content-Type", "Authorization"],
    "maxAgeSeconds": 3600
  }
]
```

Then run:
```bash
gsutil cors set cors-config.json gs://civicissue-aae6d.firebasestorage.app
```

## Method 2: Temporary Public Read (Quick Test)

If you can't use gcloud CLI, you can temporarily make images publicly readable:

### Update Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /issues/{allPaths=**} {
      allow read: if true;  // Public read (TEMPORARY!)
      allow write: if request.auth != null;
    }
    // Keep other paths secure
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **WARNING**: This makes images publicly accessible. Only use for testing!

## Method 3: Use Firebase Storage Web SDK Directly

We can modify the code to use Firebase Storage's web SDK which handles CORS better. This requires updating the image loading approach.

## After Setup

1. **Restart your Flutter app**
2. **Clear browser cache** (optional)
3. **Test image loading** - images should now load without CORS errors

## Verify CORS is Working

Check browser console - you should no longer see:
```
Access to fetch at '...' has been blocked by CORS policy
```

## Troubleshooting

### "gsutil: command not found"
- Install gcloud SDK which includes gsutil
- Or use: `gcloud components install gsutil`

### "Permission denied"
- Make sure you're authenticated: `gcloud auth login`
- Verify project: `gcloud config get-value project`

### "Bucket not found"
- Verify bucket name: `civicissue-aae6d.firebasestorage.app`
- Check Firebase Console → Storage → Settings

## Next Steps

Once CORS is configured, you can revert the code changes that use `getData()` and go back to using `Image.network()` with download URLs, which is more efficient.


