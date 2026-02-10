import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/complaint.dart';

class ReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload image to Firebase Storage, returns the download URL
  static Future<String> uploadPhoto(File imageFile, String complainId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      print('📤 ReportService: Starting image upload...');
      print('   User ID: ${user.uid}');
      print('   Complaint ID: $complainId');
      
      final imageName = '${user.uid}_$complainId.jpg';
      final storagePath = 'issues/${user.uid}/$imageName';
      print('   Storage path: $storagePath');
      print('   Image file exists: ${await imageFile.exists()}');
      print('   Image file size: ${await imageFile.length()} bytes');
      
      final ref = _storage.ref().child(storagePath);
      
      print('   📤 Uploading file to Firebase Storage...');
      final uploadTask = await ref.putFile(imageFile);
      print('   ✅ Upload task completed');
      
      print('   🔗 Getting download URL...');
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('   ✅ Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('❌ ReportService: Image upload failed: $e');
      rethrow;
    }
  }

  // Get user's current location (latitude/longitude + address)
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    String address = placemarks.isNotEmpty
        ? "${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}, ${placemarks.first.administrativeArea}"
        : "Unknown";
    return {
      "latitude": pos.latitude,
      "longitude": pos.longitude,
      "address": address,
    };
  }

  // Generate a random unique complain ID (CH + timestamp)
  static String generateComplainId() {
    final now = DateTime.now();
    return "CH${now.millisecondsSinceEpoch}";
  }

  // Save the Complaint to Firestore
  static Future<void> submitReport({
    required String issueType,
    required String department,
    required String urgency,
    required String description,
    required File imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    // 1. Generate id
    final complainId = generateComplainId();

    // 2. Get location+address
    final location = await getCurrentLocation();

    // 3. Upload photo
    final imageUrl = await uploadPhoto(imageFile, complainId);

    // 4. Create Complaint model
    final complaint = Complaint(
      complainId: complainId,
      issueType: issueType,
      department: department,
      urgency: urgency,
      latitude: location["latitude"],
      longitude: location["longitude"],
      address: location["address"],
      description: description,
      status: "Reported",
      reportedDate: DateTime.now(),
      imageUrl: imageUrl,
      userId: user.uid,
    );

    // 5. Save to Firestore
    await _firestore.collection('issues').doc(complainId).set(complaint.toMap());
  }

  // Real-time stream of all complaints for the current user
  static Stream<List<Complaint>> getUserComplaintsStream(String userId) {
    // Listen to the Firestore 'issues' collection where 'user_id' matches current user UID,
    // and order queries by 'reported_date' (latest first)
    return _firestore
        .collection('issues')
        .where('user_id', isEqualTo: userId)
        .orderBy('reported_date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Complaint.fromMap(doc.data())).toList();
    });
  }
}
