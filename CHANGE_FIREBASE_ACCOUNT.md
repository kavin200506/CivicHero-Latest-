# How to Change Firebase Account

## ✅ Step 1: Logout Complete
You've been logged out from: `kmahari2007@gmail.com`

## 🔐 Step 2: Login with New Account

Run this command in your terminal:

```bash
cd /Users/kavin/Development/projects/CivicHero
firebase login
```

This will:
1. Open a browser window
2. Ask you to log in with Google
3. Use: **kavinchandrasekar4@gmail.com**
4. Authorize Firebase CLI access

## 📋 Step 3: Verify Login

After logging in, verify with:

```bash
firebase login:list
```

You should see: `Logged in as kavinchandrasekar4@gmail.com`

## 🔄 Step 4: Check Available Projects

List projects available to the new account:

```bash
firebase projects:list
```

## ⚠️ Important: Project Access

**If the new account doesn't have access to `civichero-480a3`:**

### Option A: Add New Account to Existing Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Log in with **kmahari2007@gmail.com** (old account)
3. Select project: **civichero-480a3**
4. Go to **⚙️ Settings** → **Users and permissions**
5. Click **Add member**
6. Add: **kavinchandrasekar4@gmail.com**
7. Give appropriate role (Editor or Owner)

### Option B: Create New Project with New Account
1. Log in with **kavinchandrasekar4@gmail.com**
2. Create a new Firebase project
3. Update Firebase configuration in your apps

## 🔧 Step 5: Update App Configuration (If New Project)

If you create a new project, you'll need to:

1. **User App:**
   - Download new `google-services.json` for Android
   - Download new `GoogleService-Info.plist` for iOS
   - Replace files in respective directories

2. **Admin App:**
   - Update Firebase options in `Admin/Admin/lib/main.dart`
   - Get new config from Firebase Console → Project Settings

## 📝 Quick Commands

```bash
# Login
firebase login

# Verify
firebase login:list

# List projects
firebase projects:list

# Use specific project (if needed)
firebase use civichero-480a3
```





