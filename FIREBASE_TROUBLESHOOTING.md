# Firebase Authentication Troubleshooting Guide

## 🔍 Quick Diagnosis

If authentication is not working, follow these steps:

### Step 1: Check Console Logs
Run the app and check the console/terminal for:
- `✅ Firebase initialized successfully` - Good!
- `❌ Firebase initialization failed` - Problem with Firebase config
- `🔐 Attempting to sign in...` - Login attempt started
- `❌ Firebase Auth Error` - Specific authentication error

### Step 2: Common Issues & Solutions

#### Issue 1: "Firebase not initialized"
**Solution:**
1. Make sure you've run `flutter pub get` in both app directories
2. For **User App**: Check that `google-services.json` exists in `android/app/`
3. For **Admin App**: Check that Firebase options in `main.dart` are correct

#### Issue 2: "Network error" or "Network request failed"
**Solution:**
- Check your internet connection
- Verify Firebase project is active in Firebase Console
- Check if Firebase services are enabled (Auth, Firestore)

#### Issue 3: "Invalid API key" or "Project not found"
**Solution:**
- Your Firebase project may have been deleted or changed
- You need to regenerate Firebase configuration files

### Step 3: Regenerate Firebase Configuration

#### For User App (Mobile):
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `civichero-480a3`
3. Go to Project Settings (gear icon)
4. Under "Your apps", find your Android app
5. Download the new `google-services.json`
6. Replace the file at: `departmentselection/departmentselection/android/app/google-services.json`
7. For iOS, download `GoogleService-Info.plist` and add to `ios/Runner/`

#### For Admin App (Web):
1. In Firebase Console, go to Project Settings
2. Scroll to "Your apps" → Web app
3. Copy the Firebase configuration
4. Update the values in `Admin/Admin/lib/main.dart`:
   ```dart
   FirebaseOptions(
     apiKey: "YOUR_NEW_API_KEY",
     authDomain: "civichero-480a3.firebaseapp.com",
     databaseURL: "YOUR_DATABASE_URL",
     projectId: "civichero-480a3",
     storageBucket: "civichero-480a3.firebasestorage.app",
     messagingSenderId: "727957080527",
     appId: "YOUR_WEB_APP_ID",
   )
   ```

### Step 4: Verify Firebase Services

1. **Authentication:**
   - Go to Firebase Console → Authentication
   - Make sure "Email/Password" provider is enabled
   - Check if there are any restrictions

2. **Firestore:**
   - Go to Firebase Console → Firestore Database
   - Verify database exists and rules allow access

3. **Storage:**
   - Go to Firebase Console → Storage
   - Verify storage bucket exists

### Step 5: Test Authentication

#### Test Login:
1. Try logging in with an existing account
2. Check console for specific error messages
3. Common errors:
   - `user-not-found` → User doesn't exist, try registering
   - `wrong-password` → Incorrect password
   - `invalid-email` → Email format is wrong
   - `network-request-failed` → Internet/Firebase connectivity issue

#### Test Registration:
1. Try creating a new account
2. If it fails, check:
   - Password strength (minimum 6 characters)
   - Email format
   - Network connection

### Step 6: Use Diagnostic Helper

The app now includes a `FirebaseHelper` class. You can use it in your code:

```dart
import 'package:departmentselection/utils/firebase_helper.dart';

// Print diagnostics
await FirebaseHelper.printDiagnostics();
```

### Step 7: Check Firebase Rules

#### Firestore Rules:
Make sure your Firestore rules allow authentication:
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

#### Storage Rules:
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

## 🔧 Quick Fixes

### If nothing works:

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check Firebase project status:**
   - Go to Firebase Console
   - Verify project is not suspended
   - Check billing status (if applicable)

3. **Reinstall dependencies:**
   ```bash
   cd departmentselection/departmentselection
   flutter pub get
   cd ../../Admin/Admin
   flutter pub get
   ```

4. **Check package versions:**
   - Make sure Firebase packages are compatible
   - Check `pubspec.yaml` for version constraints

## 📞 Still Having Issues?

If authentication still doesn't work after these steps:

1. Check the exact error message in console
2. Verify Firebase project is active
3. Ensure you have the latest Firebase configuration files
4. Try creating a test user directly in Firebase Console → Authentication

## ✅ Success Indicators

When everything is working, you should see:
- `✅ Firebase initialized successfully`
- `✅ Login successful: user@example.com`
- User is redirected to HomeScreen/Dashboard
- No error messages in console










