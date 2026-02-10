import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile.dart'; // import the Profile model

class ProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches current user's profile as a Profile object, or null if not found.
  static Future<Profile?> fetchProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return Profile.fromMap(doc.data()!);
  }

  /// Checks if current user's profile is complete (all fields validated).
  static Future<bool> isProfileComplete() async {
    final profile = await fetchProfile();
    if (profile == null) return false;

    return profile.fullName.trim().isNotEmpty &&
        profile.email.trim().isNotEmpty &&
        profile.phoneNumber.trim().isNotEmpty &&
        profile.department.trim().isNotEmpty &&
        profile.address.trim().isNotEmpty &&
        profile.gender.trim().isNotEmpty;
        // add further validation if needed
  }

  /// Creates or updates the user's profile using the Profile object.
  static Future<void> upsertProfile(Profile profile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No user signed in!');
    await _firestore.collection('users').doc(uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }
}
