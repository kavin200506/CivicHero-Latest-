# 📝 Update User Profile in Firestore

## Current Issues Found

Looking at your Firestore user profile for `bGXdBCQH2SQ1yZk0QJD4mZb8oiL2`:

### ❌ Issue 1: Email is Empty
- Current: `email: ""` (empty string)
- **Fix:** Add your email address

### ❌ Issue 2: Phone Number Missing Country Code
- Current: `phonenumber: "8610866523"`
- **Fix:** Should be `phonenumber: "+918610866523"` (with +91 for India)

## Quick Fix Steps

### Step 1: Update Email Field

1. Go to Firebase Console → Firestore → `users` collection
2. Click on document `bGXdBCQH2SQ1yZk0QJD4mZb8oiL2`
3. Click on the `email` field
4. Change the value from `""` to your actual email (e.g., `"kavinchandrasekar4@gmail.com"`)
5. Click "Update"

### Step 2: Update Phone Number

1. In the same document, click on the `phonenumber` field
2. Change from `"8610866523"` to `"+918610866523"`
3. Click "Update"

## Server Auto-Fix

The server has been updated to:
- ✅ Automatically add `+91` country code if phone number is 10 digits without `+`
- ✅ Try to get email from Firebase Auth if email field is empty

However, **it's still best to update the profile manually** to ensure notifications work reliably.

## After Updating

1. Update a complaint status in the admin app
2. You should receive:
   - ✅ SMS to `+918610866523`
   - ✅ Email to the email address you set

## Phone Number Format

For different countries, use these formats:
- **India:** `+91XXXXXXXXXX` (10 digits after +91)
- **USA:** `+1XXXXXXXXXX` (10 digits after +1)
- **UK:** `+44XXXXXXXXXX`

Always include the country code with `+` prefix!



