# Quick Guide: Get Firebase Service Account Key

## Steps

1. **Go to Firebase Console**
   - Open: https://console.firebase.google.com/project/civicissue-aae6d/settings/serviceaccounts/adminsdk

2. **Generate New Private Key**
   - Click the **"Generate new private key"** button
   - A dialog will appear warning you about security
   - Click **"Generate key"**

3. **Download the JSON File**
   - A JSON file will be downloaded (e.g., `civicissue-aae6d-firebase-adminsdk-xxxxx.json`)

4. **Save to Project Root**
   - Rename the file to: `service-account-key.json`
   - Move it to: `/Users/kavin/Development/projects/CivicHero/service-account-key.json`

5. **Verify**
   ```bash
   cd /Users/kavin/Development/projects/CivicHero
   ls -la service-account-key.json
   ```

## Important Notes

- ⚠️ **Never commit this file to Git** (it's already in `.gitignore`)
- ⚠️ **Keep it secure** - it has full admin access to your Firebase project
- ✅ The file should contain fields like: `project_id`, `private_key`, `client_email`, etc.

## After Adding the File

Once you've added `service-account-key.json`, the notification server will start automatically.


