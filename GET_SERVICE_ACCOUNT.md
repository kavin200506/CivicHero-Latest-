# How to Get Firebase Service Account Key

To use the clear-firebase-data.js script, you need a service account key file.

## Steps:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **civichero-480a3**
3. Click the **gear icon** (⚙️) → **Project settings**
4. Go to **Service accounts** tab
5. Click **Generate new private key**
6. Save the JSON file as `service-account-key.json` in this directory
7. The script will automatically use it

## Alternative: Use Application Default Credentials

If you have Google Cloud SDK installed:
```bash
gcloud auth application-default login
```

Then the script will use those credentials automatically.








