# Quick Instructions to Clear Firebase Data

## 🚀 Easiest Method: Use Your Flutter App

### Step 1: Add a button to access the clear screen (temporary)

You can add this button to your HomeScreen temporarily, or just navigate directly:

**Option A: Add temporary button to HomeScreen**
- Open `lib/screens/home_screen.dart`
- Add a floating action button or menu item that navigates to `/clear-data`

**Option B: Navigate directly (for testing)**
- The route is already added to `main.dart`
- You can navigate to it programmatically or via URL

### Step 2: Run the app and clear data

1. Run your app:
   ```bash
   cd departmentselection/departmentselection
   flutter run
   ```

2. Navigate to the clear data screen:
   - Either use the button you added
   - Or navigate to: `/clear-data` route
   - Or add this code somewhere to test:
     ```dart
     Navigator.pushNamed(context, '/clear-data');
     ```

3. Use the buttons to:
   - Clear specific collections (`issues`, `adminusers`, `users`)
   - Clear ALL Firestore data
   - See status messages

### Step 3: Clear Authentication Users

The screen will show instructions, but here's how:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **civichero-480a3**
3. Go to **Authentication** → **Users**
4. Select all users → Click **Delete**

### Step 4: Remove the route (for security)

After clearing data, remove the route from `main.dart`:
- Delete the `/clear-data` route
- Remove the import for `admin_clear_data_screen.dart`

---

## 🔧 Alternative: Use Node.js Script

If you prefer using the command line:

### Step 1: Get Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **civichero-480a3**
3. Click **⚙️ Settings** → **Project settings**
4. Go to **Service accounts** tab
5. Click **Generate new private key**
6. Save the file as `service-account-key.json` in the project root

### Step 2: Run the script

```bash
cd /Users/kavin/Development/projects/CivicHero
node clear-firebase-data.js
```

Type `DELETE ALL` when prompted to confirm.

---

## ✅ Recommended: Use Flutter App Method

The Flutter app method is easier because:
- ✅ No need for service account keys
- ✅ Visual interface with confirmations
- ✅ Real-time status updates
- ✅ Already set up and working

Just navigate to `/clear-data` route in your app!






