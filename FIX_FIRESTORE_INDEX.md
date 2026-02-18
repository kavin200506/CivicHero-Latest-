# Fix Firestore Index Error

## 🔴 Error Message
```
[cloud_firestore/failed-precondition]
The query requires an index. You can create it here: [link]
```

## 🔍 What's Happening

Your app is making a **composite query** in `report_service.dart` (line 115-116):

```dart
.where('user_id', isEqualTo: userId)
.orderBy('reported_date', descending: true)
```

Firestore requires a **composite index** when you:
- Filter by one field (`user_id`)
- AND order by another field (`reported_date`)

## ✅ Solution: Create the Index

### **Option 1: Use the Direct Link (Easiest)**

The error message includes a direct link to create the index. Just click it:

```
https://console.firebase.google.com/v1/r/project/civicissue-aae6d/firestore/indexes?create_composite=...
```

This will automatically create the correct index for you!

### **Option 2: Manual Creation**

1. Go to [Firebase Console](https://console.firebase.google.com/project/civicissue-aae6d/firestore/indexes)
2. Click **"Create Index"** or **"Add Index"**
3. Configure the index:
   - **Collection ID**: `issues`
   - **Fields to index**:
     - Field: `user_id` → Order: **Ascending**
     - Field: `reported_date` → Order: **Descending**
4. Click **"Create"**

### **Option 3: Using Firebase CLI**

If you have `firebase.json` configured, you can add this to `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "issues",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "user_id",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "reported_date",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

Then run:
```bash
firebase deploy --only firestore:indexes
```

## ⏱️ Index Creation Time

- **Small collections**: 1-2 minutes
- **Large collections**: 5-10 minutes
- You'll see a status: "Building" → "Enabled"

## ✅ Verify It's Working

Once the index is created:

1. The error will disappear
2. Your queries will work normally
3. You can check index status in Firebase Console → Firestore → Indexes

## 📝 What This Index Does

This index allows Firestore to efficiently:
- Find all issues for a specific user (`user_id = X`)
- Sort them by date, newest first (`reported_date DESC`)

Without the index, Firestore can't efficiently execute this query.

## 🎯 Quick Fix

**Just click the link in the error message!** It will automatically create the correct index for you.

---

**Note**: If you see this error again for different fields, you'll need to create additional indexes. Firestore will always provide a direct link in the error message.









