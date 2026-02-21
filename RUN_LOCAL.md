# Run Admin + Notification Service Locally

So that changing status to "In progress" (or assigned/resolved/completed) sends SMS and email to the user, run both the **notification service** and the **Admin app** on your machine.

---

## Option 1: One command (recommended)

From the **CivicHero** folder:

```bash
./run-admin-and-notifications.sh
```

This starts the notification server on port 3000, then opens the Admin app in Chrome. When you close the app or press Ctrl+C, the notification server stops too.

---

## Option 2: Two terminals

**Terminal 1 – Notification service**

```bash
cd /Users/kavin/Development/projects/1/CivicHero
npm start
```

Leave this running. You should see: `CivicHero Notification Service running on port 3000`.

**Terminal 2 – Admin app**

```bash
cd /Users/kavin/Development/projects/1/CivicHero/Admin/Admin
flutter run -d chrome
```

Use the Admin app in the browser; status changes will call `http://127.0.0.1:3000` and trigger SMS/email.

---

## Requirements

- **CivicHero** has Node deps installed: `npm install` (in CivicHero folder).
- **.env** in CivicHero with Twilio and Gmail (see notification server docs).
- **service-account-key.json** in CivicHero for Firebase.
- **Flutter** and **Chrome** for the Admin app.

---

## Quick check

1. Start both (Option 1 or 2).
2. Open Admin, change an issue’s status to **In progress** (or **Resolved**).
3. In Terminal 1 you should see a log line for the `/notify-status-change` request.
4. The user (phone/email in Firestore) should get SMS/email if configured.
