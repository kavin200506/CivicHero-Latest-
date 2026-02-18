# 🔍 Debugging Notification Issues

## Quick Checks

### 1. Verify Server is Running
```bash
curl http://localhost:3000/health
```
Should return: `{"status":"ok","service":"CivicHero Notification Service"}`

### 2. Check Server Logs
```bash
tail -f /Users/kavin/Development/projects/CivicHero/server.log
```

### 3. Test Notification Endpoint Manually
```bash
curl -X POST http://localhost:3000/notify-status-change \
  -H "Content-Type: application/json" \
  -d '{
    "complaintId": "TEST123",
    "userId": "YOUR_USER_ID_HERE",
    "newStatus": "Assigned",
    "department": "Road Department",
    "issueType": "Pothole"
  }'
```

## Common Issues

### Issue 1: Admin App Can't Reach Server
**Symptom:** No requests in server logs when updating status

**Solution:** 
- If admin app is Flutter Web, it might need `http://127.0.0.1:3000` instead of `localhost:3000`
- Check browser console for CORS errors
- Update `data_service.dart` line 157 to use `http://127.0.0.1:3000/notify-status-change`

### Issue 2: Status Not Matching
**Symptom:** Server logs show "Status not in notification list"

**Check:** Status values must be:
- "Assigned" (capital A)
- "In Progress" (capital I and P)
- "Resolved" (capital R)

The server normalizes to lowercase, so this should work, but check logs.

### Issue 3: User Profile Missing Data
**Symptom:** Server logs show "No phone or email found"

**Check:**
1. User profile exists in Firestore `users` collection
2. Profile has `phonenumber` or `phoneNumber` field
3. Profile has `email` field

### Issue 4: Phone Number Format
**Symptom:** SMS fails with Twilio error

**Check:** Phone number must include country code (e.g., `+1234567890`)

## Debug Steps

1. **Check Admin App Console**
   - Open browser DevTools (F12)
   - Look for console logs starting with `📬 Sending notification...`
   - Check for any errors

2. **Check Server Logs**
   ```bash
   tail -f server.log
   ```
   - Look for incoming requests
   - Check for errors

3. **Verify User Profile**
   - Go to Firebase Console
   - Check `users` collection
   - Verify user has `phonenumber` and `email` fields

4. **Test with Real Data**
   - Get a real `userId` from Firestore
   - Test notification endpoint with that userId
   - Check if SMS/Email are sent

## Status Values in Admin App

The admin dashboard uses these exact values:
- `"Reported"` - No notification
- `"Assigned"` - ✅ Sends notification
- `"In Progress"` - ✅ Sends notification  
- `"Resolved"` - ✅ Sends notification

## Next Steps

1. Update a complaint status in admin app
2. Check browser console for logs
3. Check server.log for incoming requests
4. Verify user profile has phone/email
5. Check Twilio/Gmail for actual delivery







