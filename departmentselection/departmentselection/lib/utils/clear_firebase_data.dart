import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ⚠️ WARNING: This will delete ALL data from Firebase!
/// Use with extreme caution. Only use for development/testing.
/// 
/// This script will:
/// 1. Delete all authentication users
/// 2. Delete all Firestore collections and documents
class ClearFirebaseData {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Clear all authentication users
  /// ⚠️ WARNING: This requires Admin SDK or Firebase Console
  /// This method shows how to do it if you have admin access
  static Future<void> clearAllUsers() async {
    try {
      print('🗑️  Starting to clear authentication users...');
      
      // Note: Deleting users requires Admin SDK or Firebase Console
      // This is a helper method - actual deletion should be done via Console
      // or using Firebase Admin SDK on a backend server
      
      print('⚠️  To delete users, use Firebase Console:');
      print('   1. Go to Authentication > Users');
      print('   2. Select all users');
      print('   3. Click Delete');
      
      // If you have admin access, you could list users here:
      // final users = await _auth.listUsers();
      // for (var user in users) {
      //   await _auth.deleteUser(user.uid);
      // }
      
    } catch (e) {
      print('❌ Error clearing users: $e');
      rethrow;
    }
  }

  /// Clear all Firestore collections
  /// ⚠️ WARNING: This will delete ALL documents in ALL collections!
  static Future<void> clearAllFirestoreData() async {
    try {
      print('🗑️  Starting to clear Firestore data...');
      print('⚠️  This will delete ALL collections and documents!');

      // Known collections in the app (listCollections() not available in this Firestore version)
      final knownCollections = ['issues', 'adminusers', 'users'];
      
      print('📋 Clearing known collections: ${knownCollections.join(", ")}');

      // Delete each known collection
      for (var collectionName in knownCollections) {
        await clearCollection(collectionName);
      }

      print('✅ All Firestore data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing Firestore: $e');
      rethrow;
    }
  }

  /// Delete a specific collection by name
  static Future<void> clearCollection(String collectionName) async {
    try {
      print('🗑️  Deleting collection: $collectionName...');
      
      final collection = _firestore.collection(collectionName);

      // Get all documents in the collection
      final snapshot = await collection.get();
      
      if (snapshot.docs.isEmpty) {
        print('   ✓ Collection $collectionName is already empty');
        return;
      }

      // Delete in batches (Firestore has a limit of 500 operations per batch)
      const batchSize = 500;
      final batches = <WriteBatch>[];
      WriteBatch? currentBatch;
      int operationCount = 0;

      for (var doc in snapshot.docs) {
        if (currentBatch == null || operationCount >= batchSize) {
          currentBatch = _firestore.batch();
          batches.add(currentBatch);
          operationCount = 0;
        }
        
        currentBatch.delete(doc.reference);
        operationCount++;
      }

      // Commit all batches
      for (var batch in batches) {
        await batch.commit();
      }

      print('   ✅ Deleted ${snapshot.docs.length} documents from $collectionName');
    } catch (e) {
      print('   ❌ Error deleting collection $collectionName: $e');
      rethrow;
    }
  }

  /// Clear all data (both Auth and Firestore)
  /// ⚠️ WARNING: This is destructive!
  static Future<void> clearEverything() async {
    print('\n' + '=' * 60);
    print('⚠️  WARNING: This will delete ALL Firebase data!');
    print('=' * 60);
    
    try {
      // Clear Firestore
      await clearAllFirestoreData();
      
      // Note: Auth users need to be cleared via Console
      print('\n📝 To clear authentication users:');
      print('   Use Firebase Console > Authentication > Users');
      
      print('\n✅ Data clearing process completed!');
    } catch (e) {
      print('\n❌ Error during data clearing: $e');
      rethrow;
    }
  }
}

