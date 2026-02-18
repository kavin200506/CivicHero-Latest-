# Delete All Authentication Users

## Quick Steps (Firebase Console - Easiest Method):

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com/
2. Select project: **civichero-480a3**

### Step 2: Go to Authentication
1. Click **Authentication** in the left sidebar
2. Click on the **Users** tab

### Step 3: Delete All Users
1. **Select All Users:**
   - Click the checkbox at the top of the user list (selects all users)
   - OR manually select individual users

2. **Delete:**
   - Click the **Delete** button (trash icon) at the top
   - Confirm the deletion in the dialog

3. **If you have many users:**
   - You may need to delete in batches (Firebase Console has limits)
   - Repeat the process until all users are deleted

### Step 4: Verify
- The user list should be empty
- All authentication users are now deleted

---

## Alternative: Enable API and Use Script

If you want to use the script, you need to enable the Identity Toolkit API:

1. Go to: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=civichero-480a3
2. Click **Enable**
3. Wait a few minutes for it to propagate
4. Then run the script again

But the Console method is faster and easier!










