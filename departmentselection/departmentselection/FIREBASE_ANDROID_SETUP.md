# Fix: google-services.json missing (Android)

The build fails because **google-services.json** is required for Firebase on Android and is not in the repo.

## 1. Get the file from Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/).
2. Select your project (e.g. **civicissue-aae6d** or **civichero-480a3** — whichever this app uses).
3. Click the **gear** → **Project settings**.
4. Under **Your apps**, check if there is an **Android** app with package name:
   - `com.example.departmentselection`
5. If there is no Android app:
   - Click **Add app** → **Android**.
   - **Android package name:** `com.example.departmentselection`.
   - Register the app, then download **google-services.json**.
6. If the Android app already exists:
   - In **Your apps**, find the Android app and click **Download google-services.json**.

## 2. Place the file in the project

Put the downloaded file here (replace the existing path if you had one):

```
departmentselection/departmentselection/android/app/google-services.json
```

Full path on your Mac:

```
/Users/kavin/Development/projects/1/CivicHero/departmentselection/departmentselection/android/app/google-services.json
```

So: copy your downloaded **google-services.json** into the **android/app/** folder of this app.

## 3. Build again

From the app directory:

```bash
cd /Users/kavin/Development/projects/1/CivicHero/departmentselection/departmentselection
flutter run
```

The **File google-services.json is missing** error should be gone. If your app uses a different Firebase project than the one you used above, add an Android app for that project and use its **google-services.json** instead.
