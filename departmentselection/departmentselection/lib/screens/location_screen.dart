import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/constants.dart';
import '../services/report_service.dart';
import '../models/complaint.dart';
import 'status_tracker_screen.dart';

class LocationScreen extends StatefulWidget {
  final String issueType;
  final String department;
  final String urgency;
  final String description;

  const LocationScreen({
    super.key,
    required this.issueType,
    required this.department,
    required this.urgency,
    required this.description,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _address = '';
  bool _isLoadingLocation = true;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionPermanentlyDeniedDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      await _getAddressFromCoordinates();

      setState(() {
        _isLoadingLocation = false;
        _locationPermissionGranted = true;
      });

    } catch (e) {
      print('Error getting location: $e');
      _showLocationError();
    }
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude,
        _longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _address = '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      } else {
        _address = 'Address not found';
      }
    } catch (e) {
      print('Error getting address: $e');
      _address = 'Unable to get address';
    }
  }

  void _showLocationServiceDialog() { /* ... (unchanged, from your code) ... */ }
  void _showPermissionDeniedDialog() { /* ... (unchanged, from your code) ... */ }
  void _showPermissionPermanentlyDeniedDialog() { /* ... (unchanged, from your code) ... */ }
  void _showLocationError() { /* ... (unchanged, from your code) ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Confirm Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issue Summary Card
            /* ... existing summary card code ... */

            const SizedBox(height: 24),

            // Location details and map (unchanged)
            /* ... rest of your location and map UI ... */
            
            const Spacer(),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: Icon(_isLoadingLocation ? Icons.hourglass_empty : Icons.refresh),
                    label: Text(_isLoadingLocation ? 'Loading...' : 'Update Location'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      foregroundColor: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingLocation || !_locationPermissionGranted
                        ? null
                        : () async {
                            // Submit the report (recommend this approach!)
                            // (You will need: imageFile parameter, so adjust as per your workflow)
                            //
                            // final complainId = await ReportService.submitReport(...);
                            // After submission, navigate
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => StatusTrackerScreen(complainId: complainId),
                            //   ),
                            // );
                          },
                    icon: const Icon(Icons.send),
                    label: const Text('Submit with GPS Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      disabledBackgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.darkGrey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... GPSMapPainter unchanged ...
