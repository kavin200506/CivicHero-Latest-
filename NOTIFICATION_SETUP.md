# 📬 Notification Service Setup Guide

This guide will help you set up SMS and Email notifications for status changes in CivicHero.

## 🚀 Quick Start

### Step 1: Install Dependencies

```bash
cd /Users/kavin/Development/projects/CivicHero
npm install
```

### Step 2: Create Environment File

Create a `.env` file in the project root with your credentials:

```env
# Twilio Configuration
TWILIO_ACCOUNT_SID=your_twilio_account_sid_here
TWILIO_AUTH_TOKEN=your_twilio_auth_token_here
TWILIO_PHONE_NUMBER=your_twilio_phone_number_here

# Gmail Configuration
GMAIL_USERNAME=your_gmail@gmail.com
GMAIL_APP_PASSWORD=your_gmail_app_password_here
EMAIL_ENABLED=true

# Server Configuration
PORT=3000
```

### Step 3: Ensure Service Account Key Exists

Make sure you have `serviceAccountKey.json` in the project root (same file used for Firebase Admin SDK).

### Step 4: Start the Notification Server

```bash
npm start
```

The server will start on `http://localhost:3000`

### Step 5: Update Admin App Dependencies

```bash
cd Admin/Admin
flutter pub get
```

## 📱 How It Works

1. **Admin updates status** → Admin app calls notification API
2. **Notification server** → Fetches user profile from Firestore
3. **Sends SMS** → Via Twilio to user's phone number
4. **Sends Email** → Via Gmail to user's email address

## 🔔 Notification Triggers

Notifications are sent when status changes to:
- **Assigned** - "Your complaint has been assigned to [Department]"
- **In Progress** - "Good news! Your complaint is now In Progress"
- **Resolved/Completed** - "🎉 Your complaint has been marked as Resolved"

## 📝 Message Format

### SMS Example:
```
Your complaint "Pothole" has been assigned to Road Department. We'll keep you updated on the progress.
```

### Email Example:
```
Subject: Complaint Assigned - Pothole

Dear Citizen,

Your complaint "Pothole" has been assigned to Road Department.

We will keep you updated on the progress.

Thank you for using CivicHero.

Best regards,
CivicHero Team
```

## 🔧 Configuration

### Change Notification Server URL

If your server is running on a different URL, update in:
`Admin/Admin/lib/data_service.dart` (line ~120):

```dart
const notificationUrl = 'http://your-server-url:3000/notify-status-change';
```

### Disable Email Notifications

Set in `.env`:
```env
EMAIL_ENABLED=false
```

## 🧪 Testing

### Test the Server

```bash
curl http://localhost:3000/health
```

Should return:
```json
{"status":"ok","service":"CivicHero Notification Service"}
```

### Test Notification Endpoint

```bash
curl -X POST http://localhost:3000/notify-status-change \
  -H "Content-Type: application/json" \
  -d '{
    "complaintId": "CH1234567890",
    "userId": "user-id-here",
    "newStatus": "Assigned",
    "department": "Road Department",
    "issueType": "Pothole"
  }'
```

## 📋 Requirements

- Node.js 14+ installed
- Firebase Service Account Key (`serviceAccountKey.json`)
- Twilio account with phone number
- Gmail account with App Password enabled
- User profiles must have `phonenumber` and `email` fields in Firestore

## ⚠️ Important Notes

1. **Phone Number Format**: Must include country code (e.g., `+1234567890`)
2. **Gmail App Password**: Not your regular password, must be generated from Google Account settings
3. **Firestore Access**: Service account must have read access to `users` collection
4. **Network**: Admin app and notification server must be on the same network (or use public URL)

## 🐛 Troubleshooting

### SMS Not Sending
- Check Twilio credentials in `.env`
- Verify phone number format includes country code
- Check Twilio account balance

### Email Not Sending
- Verify `EMAIL_ENABLED=true` in `.env`
- Check Gmail App Password is correct
- Ensure Gmail account has "Less secure app access" enabled (or use App Password)

### Notification Server Not Responding
- Check if server is running: `npm start`
- Verify port 3000 is not in use
- Check firewall settings

### Admin App Can't Connect
- Verify notification server URL in `data_service.dart`
- Check if server is accessible from admin app's network
- Look for error logs in admin app console

## 📚 API Endpoints

### POST `/notify-status-change`

**Request Body:**
```json
{
  "complaintId": "CH1234567890",
  "userId": "user-id-from-firestore",
  "newStatus": "Assigned",
  "department": "Road Department",
  "issueType": "Pothole"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Notifications sent successfully",
  "results": {
    "sms": { "success": true, "sid": "SM..." },
    "email": { "success": true, "messageId": "..." }
  }
}
```

### GET `/health`

Returns server status.

---

✅ **Setup Complete!** Your notification service is ready to send SMS and Email notifications when admin updates complaint status.

