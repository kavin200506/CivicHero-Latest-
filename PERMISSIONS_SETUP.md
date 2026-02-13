# Permissions Setup for Mobile App

## ✅ Feature Implemented

The mobile app now **automatically requests both camera and location permissions** after login/registration, making it easy for users to grant permissions without going to settings manually.

## When Permissions Are Requested

### 1. **After Login**
- User logs in successfully
- Permission dialog appears immediately
- Explains why permissions are needed
- Requests both camera and location permissions

### 2. **After Registration & Profile Completion**
- User completes registration
- Completes profile (or skips)
- Permission dialog appears
- Requests both permissions before going to home screen

## Permission Flow

1. **Explanation Dialog** (First)
   - Shows why permissions are needed
   - Camera: To capture photos of civic issues
   - Location: To tag issues with accurate location
   - User can choose "Grant Permissions" or "Cancel"

2. **Permission Requests** (System Dialogs)
   - Camera permission request
   - Location permission request
   - Both requested automatically

3. **Location Service Check**
   - Checks if location services are enabled
   - If disabled, shows dialog to enable in settings

4. **Result Handling**
   - If granted: User proceeds to home screen
   - If denied: Shows warning but still allows access
   - User can grant permissions later in settings

## Permissions Requested

### Camera Permission
- **Purpose**: Capture photos of civic issues
- **When**: After login/registration
- **Required**: Yes (for reporting issues)

### Location Permission
- **Purpose**: Tag issues with accurate location
- **When**: After login/registration
- **Required**: Yes (for accurate issue location)

## Platform Configuration

### Android (`AndroidManifest.xml`)
✅ Already configured:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `CAMERA`
- `WRITE_EXTERNAL_STORAGE`

### iOS (`Info.plist`)
✅ Added permission descriptions:
- `NSCameraUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`

## User Experience

### If Permissions Granted
- ✅ User proceeds to home screen
- ✅ Can immediately use camera and location features
- ✅ No additional steps needed

### If Permissions Denied
- ⚠️ Warning message shown
- ✅ User can still access app
- 🔧 Can grant permissions later in settings
- 📱 "Open Settings" button available in dialogs

### If Location Service Disabled
- 📍 Dialog shown to enable location services
- 🔧 "Open Settings" button to enable
- ✅ Can proceed after enabling

## Code Implementation

### Permission Helper (`permission_helper.dart`)
- `requestPermissionsWithExplanation()`: Main method with explanation dialog
- `requestCameraAndLocationPermissions()`: Requests both permissions
- `arePermissionsGranted()`: Checks current permission status
- Handles all edge cases (denied, permanently denied, service disabled)

### Integration Points
1. **Login Screen** (`login_screen.dart`)
   - After successful login
   - Before navigating to HomeScreen

2. **Profile Completion Screen** (`complete_profile_screen.dart`)
   - After saving profile
   - After skipping profile
   - Before navigating to HomeScreen

## Benefits

1. **Better UX**: Users don't need to manually go to settings
2. **Clear Explanation**: Users understand why permissions are needed
3. **Non-Blocking**: App still works if permissions denied (with warnings)
4. **Easy Recovery**: "Open Settings" button for easy access
5. **Comprehensive**: Handles all permission states and edge cases

## Testing

To test permissions:
1. **Fresh Install**: Install app and login → Should see permission dialog
2. **Deny Permissions**: Deny permissions → Should see warning, app still works
3. **Grant Later**: Deny initially, then grant in settings → Should work
4. **Location Disabled**: Disable location services → Should see enable dialog

## Future Enhancements

- Optional: Request permissions when user first tries to use camera/location
- Optional: Show permission status indicator in app
- Optional: Periodic reminder if permissions denied


