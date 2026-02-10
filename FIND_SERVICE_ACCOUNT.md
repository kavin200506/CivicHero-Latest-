# How to Find Service Account Key (NOT Database Secrets)

## ⚠️ Important:
- **Database Secrets** = For Realtime Database (old Firebase Database)
- **Service Account Key** = For Firestore, Authentication, Admin SDK (what we need!)

## Correct Steps to Get Service Account Key:

### Step 1: Go to Project Settings
1. Open: https://console.firebase.google.com/
2. Select project: **civichero-480a3**
3. Click the **⚙️ gear icon** (top left, next to "Project Overview")
4. Click **Project settings**

### Step 2: Find Service Accounts Tab
1. In Project Settings, you'll see several tabs:
   - General
   - **Service accounts** ← This is what you need!
   - Your apps
   - etc.

2. Click on **Service accounts** tab

### Step 3: Generate Private Key
1. You'll see a section that says:
   - "Firebase Admin SDK"
   - "Node.js" tab (should be selected)
   - A button: **"Generate new private key"**

2. Click **"Generate new private key"** button

3. A warning dialog will appear - click **"Generate key"**

4. A JSON file will download automatically (usually to your Downloads folder)

### Step 4: Save the File
1. Find the downloaded JSON file (name will be something like `civichero-480a3-firebase-adminsdk-xxxxx.json`)
2. Rename it to: `service-account-key.json`
3. Move it to: `/Users/kavin/Development/projects/CivicHero/`

## Visual Guide:
```
Firebase Console
  └─ Project: civichero-480a3
      └─ ⚙️ Settings (gear icon)
          └─ Project settings
              └─ Service accounts tab ← HERE!
                  └─ Generate new private key
```

## What the Service Account Key Looks Like:
The JSON file will contain something like:
```json
{
  "type": "service_account",
  "project_id": "civichero-480a3",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "...",
  ...
}
```

## ⚠️ Don't Use:
- ❌ Database Secrets (what you saw)
- ❌ API Keys
- ❌ Web app configuration

## ✅ Use:
- ✅ Service Account Key (from Service accounts tab)






