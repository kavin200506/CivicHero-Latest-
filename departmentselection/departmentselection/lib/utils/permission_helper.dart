import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

/// Helper class to request camera and location permissions
class PermissionHelper {
  /// Request both camera and location permissions
  /// Returns true if both permissions are granted
  static Future<bool> requestCameraAndLocationPermissions(BuildContext context) async {
    try {
      print('🔐 Requesting camera and location permissions...');
      
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      print('📷 Camera permission: $cameraStatus');
      
      // Request location permission
      final locationStatus = await Permission.location.request();
      print('📍 Location permission: $locationStatus');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          _showLocationServiceDialog(context);
        }
        return false;
      }
      
      // Check final status
      final cameraGranted = cameraStatus.isGranted;
      final locationGranted = locationStatus.isGranted;
      
      if (!cameraGranted || !locationGranted) {
        if (context.mounted) {
          _showPermissionDeniedDialog(
            context,
            cameraGranted: cameraGranted,
            locationGranted: locationGranted,
          );
        }
        return false;
      }
      
      print('✅ Both permissions granted!');
      return true;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }
  
  /// Check if both permissions are granted
  static Future<bool> arePermissionsGranted() async {
    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    return cameraStatus.isGranted && 
           locationStatus.isGranted && 
           serviceEnabled;
  }
  
  /// Show dialog if location service is disabled
  static void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Disabled'),
        content: const Text(
          'Please enable location services in your device settings to report issues with accurate location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openLocationSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  
  /// Show dialog if permissions are denied
  static void _showPermissionDeniedDialog(
    BuildContext context, {
    required bool cameraGranted,
    required bool locationGranted,
  }) {
    String message = 'CivicHero needs the following permissions to work properly:\n\n';
    
    if (!cameraGranted) {
      message += '• Camera: To capture photos of issues\n';
    }
    if (!locationGranted) {
      message += '• Location: To tag issues with accurate location\n';
    }
    
    message += '\nPlease grant these permissions in app settings.';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  
  /// Request permissions with explanation dialog
  static Future<bool> requestPermissionsWithExplanation(BuildContext context) async {
    // First check if already granted
    if (await arePermissionsGranted()) {
      print('✅ Permissions already granted');
      return true;
    }
    
    // Show explanation dialog first
    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Permissions Needed'),
          ],
        ),
        content: const Text(
          'CivicHero needs the following permissions:\n\n'
          '📷 Camera: To capture photos of civic issues\n'
          '📍 Location: To tag issues with accurate location\n\n'
          'These permissions are essential for reporting issues. We will never share your location data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
    
    if (shouldProceed != true) {
      return false;
    }
    
    // Request permissions
    return await requestCameraAndLocationPermissions(context);
  }
}




