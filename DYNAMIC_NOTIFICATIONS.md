# Dynamic Notifications Feature

## ✅ Feature Implemented

The notifications/alerts tab is now **fully dynamic** and connected to Firestore. Notifications are automatically created when complaint status changes, and users can manage them with "Clear All" functionality.

## What's New

### 1. **Dynamic Notifications from Firestore**
- Notifications are stored in Firestore `notifications` collection
- Real-time updates using StreamBuilder
- Automatically created when complaint status changes

### 2. **Clear All Functionality**
- "Clear All" button in app bar (trash icon)
- Confirmation dialog before deleting
- Deletes all notifications for the current user

### 3. **Additional Features**
- **Mark as Read**: Mark all notifications as read
- **Individual Delete**: Delete button on each notification card
- **Tap to View**: Tap notification to view complaint details
- **Auto Mark Read**: Notifications marked as read when tapped

## Notification Types

1. **Assigned** (Blue)
   - When complaint is assigned to department
   - Icon: Assignment

2. **In Progress** (Orange)
   - When work starts on complaint
   - Icon: Update

3. **Resolved** (Green)
   - When complaint is marked as resolved
   - Icon: Check Circle

4. **Feedback** (Purple)
   - For feedback requests (future feature)
   - Icon: Star

## How It Works

### Creating Notifications

When a complaint status changes in Firestore:
1. Home screen detects status change
2. Creates notification in Firestore via `NotificationService`
3. Notification appears in real-time in notifications screen

### Displaying Notifications

1. Notifications screen uses `StreamBuilder`
2. Fetches notifications from Firestore
3. Filters by current user ID
4. Sorted by timestamp (newest first)
5. Shows unread indicator (blue dot)

### Managing Notifications

- **Mark All as Read**: Updates all notifications to `isRead: true`
- **Clear All**: Deletes all notifications for user
- **Delete Individual**: Deletes single notification
- **Tap Notification**: Opens complaint details screen

## Firestore Structure

### Collection: `notifications`

```json
{
  "id": "notification_id",
  "userId": "user_uid",
  "title": "Complaint Assigned",
  "message": "Your pothole complaint has been assigned...",
  "type": "assigned",
  "timestamp": "2024-01-15T10:30:00Z",
  "isRead": false,
  "complainId": "CH1234567890"
}
```

## Required Firestore Index

Create a composite index:
- Collection: `notifications`
- Fields:
  - `userId` (Ascending)
  - `timestamp` (Descending)

See `CREATE_NOTIFICATIONS_INDEX.md` for instructions.

## Code Structure

### Models
- `notification_model.dart`: Notification data model

### Services
- `notification_service.dart`: Firestore operations for notifications

### Screens
- `notifications_screen.dart`: Dynamic notifications display
- `home_screen.dart`: Creates notifications on status change

## User Experience

1. **Real-time Updates**: Notifications appear instantly when status changes
2. **Visual Indicators**: Unread notifications have blue border and dot
3. **Easy Management**: Clear all or individual delete
4. **Quick Access**: Tap notification to view complaint
5. **Empty State**: Friendly message when no notifications

## Future Enhancements

- Push notifications (FCM)
- Notification categories/filters
- Notification preferences
- Sound/vibration settings
- Badge count on tab icon




