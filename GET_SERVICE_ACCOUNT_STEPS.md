# Steps to Get Service Account Key

## Quick Steps:

1. **Open Firebase Console:**
   - Go to: https://console.firebase.google.com/
   - Select project: **civichero-480a3**

2. **Navigate to Service Accounts:**
   - Click the **⚙️ gear icon** (top left)
   - Click **Project settings**
   - Go to **Service accounts** tab

3. **Generate Key:**
   - Click **Generate new private key** button
   - A JSON file will download automatically

4. **Save the File:**
   - Rename it to: `service-account-key.json`
   - Move it to: `/Users/kavin/Development/projects/CivicHero/`
   - Make sure it's in the same directory as `clear-firebase-data.js`

5. **Run the Script:**
   ```bash
   cd /Users/kavin/Development/projects/CivicHero
   node clear-firebase-data.js
   ```

## ⚠️ Security Note:
- Keep this file secure and never commit it to Git
- The file contains sensitive credentials
- Delete it after use if you want extra security








