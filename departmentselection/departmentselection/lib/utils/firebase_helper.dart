import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to diagnose Firebase connectivity issues
class FirebaseHelper {
  /// Test Firebase initialization
  static Future<Map<String, dynamic>> testFirebaseConnection() async {
    final results = <String, dynamic>{
      'firebase_initialized': false,
      'auth_available': false,
      'firestore_available': false,
      'current_user': null,
      'errors': <String>[],
    };

    try {
      // Test 1: Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        results['errors'].add('Firebase is not initialized');
        return results;
      }
      results['firebase_initialized'] = true;

      // Test 2: Check Auth
      try {
        final auth = FirebaseAuth.instance;
        results['auth_available'] = true;
        results['current_user'] = auth.currentUser?.email ?? 'No user logged in';
      } catch (e) {
        results['errors'].add('Auth error: $e');
      }

      // Test 3: Check Firestore
      try {
        final firestore = FirebaseFirestore.instance;
        // Try a simple read operation
        await firestore.collection('_test').limit(1).get().timeout(
          const Duration(seconds: 5),
        );
        results['firestore_available'] = true;
      } catch (e) {
        results['errors'].add('Firestore error: $e');
      }

      return results;
    } catch (e) {
      results['errors'].add('General error: $e');
      return results;
    }
  }

  /// Print diagnostic information
  static Future<void> printDiagnostics() async {
    print('\n🔍 FIREBASE DIAGNOSTICS');
    print('=' * 50);
    
    final results = await testFirebaseConnection();
    
    print('Firebase Initialized: ${results['firebase_initialized']}');
    print('Auth Available: ${results['auth_available']}');
    print('Firestore Available: ${results['firestore_available']}');
    print('Current User: ${results['current_user']}');
    
    if (results['errors'].isNotEmpty) {
      print('\n❌ Errors:');
      for (var error in results['errors']) {
        print('  - $error');
      }
    } else {
      print('\n✅ All checks passed!');
    }
    
    print('=' * 50);
  }
}






