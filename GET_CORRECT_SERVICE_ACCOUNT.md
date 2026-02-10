# 🔑 Get Correct Service Account Key - Step by Step

## Current Problem
- ❌ Service account key is for: `civichero-480a3`
- ✅ Your project is: `civicissue-aae6d`
- ❌ Server can't read documents because it's looking in the wrong project

## Solution: Download Correct Service Account Key

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com/project/civicissue-aae6d/settings/serviceaccounts/adminsdk
2. Make sure you're in the **`civicissue-aae6d`** project (check the project name at the top)

### Step 2: Generate New Private Key
1. Scroll down to the **"Service accounts"** section
2. You'll see a section with **"Firebase Admin SDK"**
3. Click the **"Generate new private key"** button
4. A warning popup will appear - click **"Generate key"**
5. A JSON file will automatically download

### Step 3: Replace the Old Key
The downloaded file will have a name like: `civicissue-aae6d-firebase-adminsdk-xxxxx.json`

**Option A: Replace directly (Recommended)**
```bash
# Find the downloaded file (usually in Downloads folder)
# Then move it to your project:
mv ~/Downloads/civicissue-aae6d-*.json /Users/kavin/Development/projects/CivicHero/service-account-key.json
```

**Option B: Manual copy**
1. Open the downloaded JSON file
2. Copy all its contents
3. Open `/Users/kavin/Development/projects/CivicHero/service-account-key.json`
4. Replace all contents with the copied content
5. Save the file

### Step 4: Verify It's Correct
```bash
cd /Users/kavin/Development/projects/CivicHero
cat service-account-key.json | grep project_id
```

**Should show:** `"project_id": "civicissue-aae6d"` ✅

### Step 5: Restart Server
```bash
cd /Users/kavin/Development/projects/CivicHero
pkill -f "node notification-server.js"
node notification-server.js > server.log 2>&1 &
```

### Step 6: Test Access
```bash
node test-user-access.js
```

**Expected output:**
```
✅ Document found!
Data keys: [fullName, email, phonenumber, role, address, dob, gender]
Email: (your email)
Phone: +918610866523
```

### Step 7: Test Notification
1. Update a complaint status in admin app
2. Check server logs: `tail -f server.log`
3. You should see notifications being sent!

## ⚠️ Important Notes

- **Never commit** `service-account-key.json` to git (it's already in .gitignore)
- Keep the key file secure and private
- The key gives full admin access to your Firebase project

## Quick Verification Checklist

- [ ] Downloaded key from `civicissue-aae6d` project
- [ ] Replaced `service-account-key.json` in project root
- [ ] Verified `project_id` is `civicissue-aae6d`
- [ ] Restarted notification server
- [ ] Test shows document found
- [ ] Notifications work when updating status

## If You Can't Find the Service Account Page

Alternative path:
1. Go to: https://console.firebase.google.com/project/civicissue-aae6d/settings
2. Click on **"Service accounts"** tab
3. Follow Step 2 above

---

**After completing these steps, your notifications should work!** 🎉



