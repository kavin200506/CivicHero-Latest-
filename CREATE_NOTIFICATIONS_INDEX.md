# Create Firestore Index for Notifications

## 🔴 Error
```
FAILED_PRECONDITION: The query requires an index
```

The notifications collection needs a composite index for efficient querying.

## ✅ Quick Fix (Easiest Method)

**Click this link to auto-create the index:**
https://console.firebase.google.com/v1/r/project/civicissue-aae6d/firestore/indexes?create_composite=ClZwcm9qZWN0cy9jaXZpY2lzc3VlLWFhZTZkL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9ub3RpZmljYXRpb25zL2luZGV4ZXMvXxABGgoKBnVzZXJJZBABGg0KCXRpbWVzdGFtcBACGgwKCF9fbmFtZV9fEAI

This link will:
1. Open Firebase Console
2. Pre-fill the index configuration
3. You just need to click "Create"

## Manual Method

### Index Details
- **Collection**: `notifications`
- **Fields**:
  1. `userId` (Ascending)
  2. `timestamp` (Descending)

### Steps

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `civicissue-aae6d`
3. Navigate to **Firestore Database** → **Indexes** tab
4. Click **Create Index**
5. Set:
   - Collection ID: `notifications`
   - Fields:
     - `userId` → Ascending
     - `timestamp` → Descending
6. Click **Create**

## Index Status

- Index creation usually takes **1-2 minutes**
- You'll see **"Building"** status initially
- Once **"Enabled"**, the index is ready to use
- The app will work automatically once the index is ready

## After Creating Index

1. Wait 1-2 minutes for index to build
2. Restart the app (hot restart: `R` in terminal)
3. Go to Notifications tab
4. Should load without errors!

## Why This Index is Needed

The notifications query filters by `userId` and orders by `timestamp`:
```dart
.where('userId', isEqualTo: userId)
.orderBy('timestamp', descending: true)
```

Firestore requires a composite index for queries that combine `where` and `orderBy` on different fields.

