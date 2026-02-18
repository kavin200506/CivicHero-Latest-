# Update Apps to Use New Firebase Project: civicissue-aae6d

## 📋 Steps to Update Configuration

### Step 1: Get Firebase Configuration Files

Go to [Firebase Console](https://console.firebase.google.com/) and:

1. **Select project**: `civicissue-aae6d`
2. **Go to Project Settings** (⚙️ gear icon)

### Step 2: Get Android Configuration (for User App)

1. In Project Settings, go to **Your apps** section
2. Find or **Add Android app**:
   - Package name: `com.example.departmentselection`
   - Download `google-services.json`
3. **Replace** the file at:
   ```
   departmentselection/departmentselection/android/app/google-services.json
   ```

### Step 3: Get Web Configuration (for Admin App)

1. In Project Settings, go to **Your apps** section
2. Find or **Add Web app**
3. Copy the Firebase configuration (it will look like):
   ```javascript
   const firebaseConfig = {
     apiKey: "...",
     authDomain: "...",
     projectId: "civicissue-aae6d",
     storageBucket: "...",
     messagingSenderId: "...",
     appId: "..."
   };
   ```

### Step 4: Update Admin App Configuration

Update `Admin/Admin/lib/main.dart` with the new Firebase options.

### Step 5: Get Service Account Key (for scripts)

1. Go to **Service accounts** tab
2. Click **Generate new private key**
3. Save as `service-account-key.json` in project root

---

## 🔄 After Getting Config Files

Once you have the configuration files, I can help you:
1. Update the Admin app Firebase options
2. Verify the google-services.json is correct
3. Test the connection

**Please download the config files first, then let me know!**









