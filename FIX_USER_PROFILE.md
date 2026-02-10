# 🔧 Fix User Profile Issue

## Problem
The notification service is failing because user `bGXdBCQH2SQ1yZk0QJD4mZb8oiL2` doesn't have a profile in Firestore.

## Solution Options

### Option 1: Create User Profile in Firestore (Recommended)

1. **Go to Firebase Console**
   - Navigate to: https://console.firebase.google.com/project/civicissue-aae6d/firestore

2. **Create User Document**
   - Go to `users` collection
   - Click "Add document"
   - Document ID: `bGXdBCQH2SQ1yZk0QJD4mZb8oiL2` (the userId from the complaint)
   - Add these fields:
     ```
     fullName: "User Name"
     email: "user@example.com"
     phonenumber: "+1234567890"  (with country code!)
     role: "Citizen"
     address: "User Address"
     dob: (timestamp)
     gender: "Male" or "Female"
     ```

3. **Save the document**

### Option 2: Verify User Exists in Firebase Auth

1. **Go to Firebase Console → Authentication**
   - Check if user `bGXdBCQH2SQ1yZk0QJD4mZb8oiL2` exists
   - If not, the user may have been deleted

2. **If user doesn't exist:**
   - The complaint was created by a user that no longer exists
   - You may need to:
     - Recreate the user in Firebase Auth
     - Or update the complaint with a valid user ID

### Option 3: Test with a Valid User

1. **Find a valid user ID:**
   - Go to Firestore → `users` collection
   - Pick any user document ID
   - Or go to Authentication and pick a user UID

2. **Update a complaint to use that user ID:**
   - Go to Firestore → `issues` collection
   - Find complaint `CH1770180393374`
   - Update `user_id` field to a valid user ID

3. **Test notification again**

## Quick Test

To test if notifications work with a valid user:

1. **Create a test user profile:**
   ```javascript
   // In Firebase Console → Firestore → users collection
   Document ID: test-user-123
   Fields:
   - fullName: "Test User"
   - email: "test@example.com"
   - phonenumber: "+1234567890"
   - role: "Citizen"
   - address: "Test Address"
   - dob: (current timestamp)
   - gender: "Male"
   ```

2. **Update a complaint's user_id to `test-user-123`**

3. **Change the complaint status in admin app**

4. **Check if notification is sent**

## Current Status

- ✅ Server is running and receiving requests
- ✅ Admin app is calling the notification API correctly
- ❌ User profile doesn't exist in Firestore
- ❌ User doesn't exist in Firebase Auth

**Next Step:** Create the user profile in Firestore with the userId from the complaint.



