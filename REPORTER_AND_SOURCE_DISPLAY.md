# Reporter & Source Display (Admin)

This document describes how reporter information (name, phone) and issue source (user vs camera) are stored, enriched, and displayed in the CivicHero admin dashboard.

---

## Overview

- **Person-reported issues:** Show the reporter’s full name and phone number (from Firebase Auth user profile or `users` collection).
- **Camera-reported issues:** Show the camera name (from `cameras` collection when the issue has `camera_id`).
- **Unknown source:** Show **"Unknown"** when there is no user profile and no valid camera.

---

## 1. Data model (Citizen app)

**File:** `departmentselection/departmentselection/lib/models/complaint.dart`

- Added optional fields on the complaint model:
  - **`reporterName`** – name of the person who reported (stored in Firestore as `reporter_name`).
  - **`reporterPhone`** – phone number of the reporter (stored as `reporter_phone`).
- Both default to empty string so existing complaints without these fields still work.
- **`toMap()`** and **`fromMap()`** include `reporter_name` and `reporter_phone` for Firestore.

---

## 2. Storing reporter info when a report is submitted (Citizen app)

**File:** `departmentselection/departmentselection/lib/services/report_service.dart`

- When a citizen submits a report, the app:
  1. Fetches the current user’s profile via **`ProfileService.fetchProfile()`** (from the `users` collection).
  2. Reads **`fullName`** and **`phoneNumber`** (Firestore field: `phonenumber`).
  3. Passes them into the **`Complaint`** as **`reporterName`** and **`reporterPhone`**.
- The complaint document in the **`issues`** collection is saved with **`reporter_name`** and **`reporter_phone`**.
- If the user has no profile or missing name/phone, those fields are stored as empty strings.

**Requirement:** Users should complete their profile (Full Name and Phone Number) so new reports show correct reporter info in the admin.

---

## 3. Admin: reading and enriching issue data

**File:** `Admin/Admin/lib/data_service.dart`

When the admin fetches issues, each issue is built with at least:

- **`user_id`** – Firebase Auth UID of the reporter (if any).
- **`reporter_name`**, **`reporter_phone`** – from the issue document (set at report time by the citizen app).
- **`camera_id`** – optional; set when the issue was created by a camera/system (e.g. automated pipeline).

Enrichment runs in three steps so that every issue ends up with a displayable source.

### Step 1: Enrich from `users` (match by `user_id`)

- For each issue that has **`user_id`** but **no** `reporter_name`:
  - Fetch the document **`users/{user_id}`**.
  - Set **`reporter_name`** = `fullName`, **`reporter_phone`** = `phonenumber` on the issue map.
- This fixes older issues that only had `user_id` and no stored reporter fields.

### Step 2: Enrich from `cameras` (when no user name, use camera)

- For each issue that **still** has no `reporter_name` but has **`camera_id`**:
  - Fetch the document **`cameras/{camera_id}`**.
  - Set **`reporter_name`** = camera’s **`name`**, **`reporter_phone`** = `''`.
- So issues reported by a camera show the camera name as the “reporter” in the UI.

### Step 3: Fallback to “Unknown”

- For any issue that **still** has no `reporter_name`:
  - Set **`reporter_name`** = **`"Unknown"`**, **`reporter_phone`** = `''`.
- The admin UI then shows **“Reported by: Unknown”** instead of a raw user ID.

---

## 4. Admin: UI display

**File:** `Admin/Admin/lib/screens/dashboard_screen.dart`

- **Issue details panel**
  - If **`reporter_name`** or **`reporter_phone`** are present: shows **“Reporter: &lt;name&gt;”** and **“Phone: &lt;phone&gt;”**.
  - If both are empty (before enrichment they would have fallen back to user ID): the data layer now always sets at least **“Unknown”**, so the panel shows reporter/phone or “Unknown” as appropriate.

- **Issue list (e.g. under clusters)**
  - **“Reported by:”** uses:
    - **Name · Phone** when both are present.
    - **Name** when only name is present (e.g. camera name, no phone).
    - **“Unknown”** when the data layer set `reporter_name` to `"Unknown"`.

No extra UI logic is needed for “Unknown”; the data service guarantees a non-empty display value.

---

## 5. Firestore field summary

| Location              | Field             | Description |
|-----------------------|-------------------|-------------|
| **issues** (complaint)| `user_id`         | Firebase Auth UID of reporter (if person). |
| **issues**            | `reporter_name`   | Reporter name (person or camera name). Set at report time or by enrichment. |
| **issues**            | `reporter_phone`  | Reporter phone (person only). Set at report time or by enrichment. |
| **issues**            | `camera_id`       | Optional. Document ID in **cameras** when issue is from a camera. |
| **users**             | `fullName`        | Used to enrich `reporter_name` when missing. |
| **users**             | `phonenumber`     | Used to enrich `reporter_phone` when missing. |
| **cameras**           | `name`            | Used to set `reporter_name` when issue has `camera_id` and no user name. |

---

## 6. Camera-reported issues

For issues created by an automated camera (or any backend):

- When writing the issue document to **`issues`**, set **`camera_id`** to the **cameras** document ID (e.g. the ID of the camera that generated the report).
- Do **not** set `user_id` for a pure camera report, or set it in a way that does not match a real user; the enrichment will then use **`camera_id`** and show the camera name.
- If **`camera_id`** is missing or the camera document doesn’t exist, and there’s no user profile, the issue will show as **“Unknown”**.

---

## 7. Summary of code changes

| Area              | File(s) | Change |
|-------------------|---------|--------|
| Complaint model   | `departmentselection/.../lib/models/complaint.dart` | Added `reporterName`, `reporterPhone`; `toMap`/`fromMap` use `reporter_name`, `reporter_phone`. |
| Report submission | `departmentselection/.../lib/services/report_service.dart` | Fetches profile via `ProfileService`, saves reporter name/phone on complaint. |
| Admin data        | `Admin/Admin/lib/data_service.dart` | Reads `reporter_name`, `reporter_phone`, `camera_id`; enriches from **users** then **cameras**; sets **“Unknown”** when neither applies. |
| Admin UI          | `Admin/Admin/lib/screens/dashboard_screen.dart` | Details show Reporter + Phone; list shows “Reported by: Name · Phone” or “Reported by: Unknown”. |

---

*Last updated: February 2026*
