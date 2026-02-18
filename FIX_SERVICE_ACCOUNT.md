# 🔑 Fix Service Account Key Issue

## ❌ Problem Found!

The service account key is for the **wrong Firebase project**:

- **Service Account Project:** `civichero-480a3` ❌
- **Your Project:** `civicissue-aae6d` ✅

This is why the notification server can't read user documents - it's looking in the wrong project!

## ✅ Solution: Get Correct Service Account Key

### Step 1: Download Service Account Key for `civicissue-aae6d`

1. **Go to Firebase Console**
   - Navigate to: https://console.firebase.google.com/project/civicissue-aae6d/settings/serviceaccounts/adminsdk

2. **Generate New Private Key**
   - Click **"Generate new private key"** button
   - Click **"Generate key"** in the popup
   - A JSON file will download

3. **Save the Key**
   - Rename the downloaded file to `service-account-key.json`
   - Replace the existing `service-account-key.json` in your project root
   - **OR** rename it to `service-account-key-civicissue.json` and update the server code

### Step 2: Update Notification Server

If you saved it with a different name, update `notification-server.js`:

```javascript
// Change this line:
const serviceAccount = require('./service-account-key.json');

// To:
const serviceAccount = require('./service-account-key-civicissue.json');
```

### Step 3: Restart Server

```bash
cd /Users/kavin/Development/projects/CivicHero
pkill -f "node notification-server.js"
node notification-server.js > server.log 2>&1 &
```

### Step 4: Test

```bash
node test-user-access.js
```

You should now see:
```
✅ Document found!
Data keys: [fullName, email, phonenumber, ...]
```

## 🔍 Verify Service Account Key

After downloading, verify it's for the correct project:

```bash
cat service-account-key.json | grep project_id
```

Should show: `"project_id": "civicissue-aae6d"`

## ⚠️ Important

- **Never commit** the service account key to git
- Keep it secure and private
- The key gives full admin access to your Firebase project

## After Fix

Once you have the correct service account key:
1. ✅ Server can read user documents
2. ✅ Notifications will work
3. ✅ SMS and Email will be sent

**Next Step:** Download the correct service account key from Firebase Console!







