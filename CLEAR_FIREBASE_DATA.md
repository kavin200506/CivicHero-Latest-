# How to Clear Firebase Data

## ⚠️ WARNING
**This will permanently delete all data!** Make sure you have backups if you need any of this data later.

---

## Method 1: Firebase Console (Easiest & Recommended)

### Clear Authentication Users:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **civichero-480a3**
3. Click on **Authentication** in the left sidebar
4. Click on the **Users** tab
5. You have two options:

   **Option A: Delete Individual Users**
   - Select users you want to delete
   - Click the **Delete** button (trash icon)
   - Confirm deletion

   **Option B: Delete All Users (Bulk)**
   - Click the checkbox at the top to select all users
   - Click **Delete** button
   - Confirm deletion
   - ⚠️ Note: If you have many users, you may need to do this in batches

### Clear Firestore Database:

1. In Firebase Console, go to **Firestore Database**
2. You'll see all your collections (e.g., `issues`, `adminusers`, `users`)
3. For each collection:
   - Click on the collection name
   - Select all documents (checkbox at top)
   - Click **Delete** (trash icon)
   - Confirm deletion
4. Repeat for all collections

**OR Delete Entire Database:**
1. Go to **Project Settings** (gear icon)
2. Scroll to bottom
3. Click **Delete project** (⚠️ This deletes EVERYTHING - use with caution!)
4. Or use the method below to delete specific collections

---

## Method 2: Using Flutter Script (Programmatic)

I'll create a helper script you can run to clear data programmatically.

### Steps:
1. Run the script from your Flutter app
2. It will delete all users and Firestore documents
3. ⚠️ Make sure you're connected to the right Firebase project!

---

## Method 3: Firebase CLI (Command Line)

If you have Firebase CLI installed:

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Delete Firestore data (requires Firestore rules to allow deletion)
firebase firestore:delete --all-collections

# For Authentication, you'll need to use Console or Admin SDK
```

---

## Quick Checklist:

- [ ] Backup important data (if needed)
- [ ] Clear Authentication users via Console
- [ ] Clear Firestore collections via Console
- [ ] Verify data is cleared
- [ ] Test app to ensure it still works

---

## After Clearing:

1. Your app should still work fine
2. Users will need to register again
3. All complaints/issues will be deleted
4. Admin accounts will need to be recreated

---

## Need Help?

If you encounter any issues:
- Check Firebase Console for error messages
- Verify you have proper permissions
- Make sure you're in the correct Firebase project










