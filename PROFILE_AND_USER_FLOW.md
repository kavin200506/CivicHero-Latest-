# Profile & User Flow (Citizen App)

This document describes the mandatory profile flow, editable vs immutable fields, and UI behaviour in the citizen app (`departmentselection/departmentselection`).

---

## 1. Profile is compulsory for new users

- When a user **logs in** and their profile is **incomplete**, they are taken to **Complete Profile** and **cannot** access the home screen until the profile is saved.
- **Complete Profile** in this mode has **no "Skip"** button. The only way to leave is to **Save** a valid profile or use **Back** (which signs them out).
- When a user **registers**, they are sent to Complete Profile; "Skip for Now" is still available from the register flow. After the first login, if the profile was skipped, they will be sent back to Complete Profile (mandatory) until it is completed.

**Implementation**

- `LoggedInWrapper` (used as the post-login screen in `main.dart`) checks `ProfileService.isProfileComplete()`.
- If incomplete, it shows `CompleteProfileScreen(mandatory: true, onProfileCompleted: ..., onBackPressed: signOut)`.
- If complete, it shows `HomeScreen`.

---

## 2. Profile completion criteria

A profile is considered complete when all of the following are set (and non-empty):

- Full Name  
- Email (from Firebase Auth / already set)  
- **Phone Number** (mandatory)  
- Address  
- Date of Birth  
- Gender  

**Department/Role** is **not** required and is **removed** from the profile tab (no longer displayed or edited).

---

## 3. Immutable fields (cannot change without verification)

- **Phone Number**  
  - Shown as **read-only** on the Edit Profile screen.  
  - Helper text: *"Phone number cannot be changed here. Use verification to update."*  
  - Changing phone would require a separate verification flow (e.g. OTP); that flow is not implemented in this step.

- **Email**  
  - Shown as **disabled** on both Complete Profile and Edit Profile (comes from Firebase Auth).

- **Password**  
  - Not shown on the profile screens. Password change is done via Firebase Auth (e.g. "Forgot password" or a dedicated change-password screen with re-authentication), not from the profile tab.

All other profile fields (name, address, DOB, gender) **can be edited** after login from the profile tab.

---

## 4. Profile tab fields and behaviour

### Removed

- **Department/Role** – Removed from profile view and from Complete Profile / Edit Profile forms. Stored value in Firestore is left as-is or set to empty when saving.

### Address – place suggestions

- The address field uses **Google Places Autocomplete** (legacy HTTP API) to suggest places as the user types.
- To enable it, set one of these in `.env`:
  - `PLACES_API_KEY=your_key`
  - or `GOOGLE_PLACES_API_KEY=your_key`
- Enable the **Places API** (or legacy Place Autocomplete) for that key in Google Cloud Console.
- If no key is set, the address field is a normal text field (no suggestions).

### Date of Birth – calendar

- **DOB** is selected via a **calendar date picker** (`showDatePicker`).
- User taps the DOB field → calendar opens → chosen date is displayed and saved.

### Gender – options

- **Gender** is chosen from a **dropdown** with:
  - Male  
  - Female  
  - Other  
  - Prefer not to say  

### Phone Number

- **Mandatory** on Complete Profile.
- **Read-only** on Edit Profile (immutable without verification).

---

## 5. Files changed

| Area | File(s) | Change |
|------|--------|--------|
| Auth / routing | `main.dart` | When logged in, show `LoggedInWrapper` instead of `HomeScreen`. |
| Auth / routing | `screens/logged_in_wrapper.dart` | **New.** Checks `isProfileComplete()`; shows `CompleteProfileScreen` (mandatory) or `HomeScreen`. |
| Login | `screens/login_screen.dart` | After login, navigate to `LoggedInWrapper`. |
| Profile logic | `services/profile_service.dart` | `isProfileComplete()` no longer requires `department`. |
| Complete Profile | `screens/complete_profile_screen.dart` | Mandatory mode (no skip when `mandatory: true`), back = sign out; removed department; address autocomplete; DOB picker; gender dropdown; phone mandatory; optional `onProfileCompleted` / `onBackPressed`. |
| Edit Profile | `screens/edit_profile_screen.dart` | Phone read-only; removed department; address autocomplete; DOB picker; gender dropdown. |
| Profile view | `screens/profile_screen.dart` | Department/Role removed from the displayed fields list. |
| Address UI | `widgets/address_autocomplete_field.dart` | **New.** Address field with Google Places Autocomplete (optional, key in `.env`). |
| Model | `models/profile.dart` | Unchanged; `department` kept for Firestore compatibility (saved as empty when not used). |

---

## 6. Optional: Places API key for address autocomplete

In the project root or `departmentselection/departmentselection` (wherever `.env` is loaded), add:

```env
# Optional: for address place suggestions (Complete Profile / Edit Profile)
PLACES_API_KEY=your_google_places_api_key
```

Or reuse an existing key variable:

```env
GOOGLE_PLACES_API_KEY=your_key
```

Enable **Places API** (or **Place Autocomplete**) for the project in [Google Cloud Console](https://console.cloud.google.com/apis/library).

---

*Last updated: February 2026*
