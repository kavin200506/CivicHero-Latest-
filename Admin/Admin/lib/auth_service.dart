import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  bool isLoading = false;
  bool isInitialized = false; // Track if auth state has been checked

  String? currentDepartment; // store logged-in admin's department

  // Constructor - Check for existing session
  AuthService() {
    _checkAuthState();
  }

  // Check for existing authentication state (persistent login)
  Future<void> _checkAuthState() async {
    try {
      isLoading = true;
      notifyListeners();

      // Check current user (Firebase Auth persists sessions automatically)
      User? firebaseUser = _auth.currentUser;
      
      if (firebaseUser != null) {
        // User is logged in, verify they're an admin
        try {
          final doc = await _firestore.collection('adminusers').doc(firebaseUser.uid).get();
          if (doc.exists) {
            user = firebaseUser;
            final data = doc.data()!;
            currentDepartment = data['department'] ?? '';
            debugPrint('✅ Admin: Auto-logged in as ${user?.email}');
          } else {
            // Not an admin user, sign them out
            await _auth.signOut();
            user = null;
            currentDepartment = null;
            debugPrint('⚠️ User is not an admin, signed out');
          }
        } catch (e) {
          debugPrint('❌ Error checking admin status: $e');
          user = null;
          currentDepartment = null;
        }
      } else {
        user = null;
        currentDepartment = null;
        debugPrint('ℹ️ No existing session found');
      }
      
      isLoading = false;
      isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error checking auth state: $e');
      isLoading = false;
      isInitialized = true;
      notifyListeners();
    }
  }

  // ---------------- LOGIN ----------------
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      debugPrint('🔐 Admin: Attempting to sign in with email: $email');

      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('❌ Firebase not initialized');
        throw Exception('Firebase not initialized. Please restart the app.');
      }

      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = result.user;

      debugPrint('✅ Admin: Authentication successful for: ${user?.email}');

      final doc = await _firestore.collection('adminusers').doc(user!.uid).get();
      if (!doc.exists) {
        debugPrint('❌ Admin: User document not found in adminusers collection');
        await _auth.signOut();
        user = null;
        isLoading = false;
        notifyListeners();
        return false;
      }

      final data = doc.data()!;
      currentDepartment = data['department'] ?? '';

      debugPrint('✅ Admin: Department assigned: $currentDepartment');

      await user?.updateDisplayName(currentDepartment);
      await user?.reload();
      user = _auth.currentUser;

      await _firestore.collection('adminusers').doc(user!.uid).update({
        'last_login': FieldValue.serverTimestamp(),
      });

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("❌ Admin Login Error (${e.code}): ${e.message}");
      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("❌ Admin Login Error: $e");
      return false;
    }
  }

  // ---------------- SIGN UP ----------------
  Future<String?> signUp(String email, String password, String department) async {
    try {
      isLoading = true;
      notifyListeners();

      if (password.length < 6) return "Password must be at least 6 characters";

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = result.user;
      if (user == null) return "User creation failed";

      currentDepartment = department;

      await user!.updateDisplayName(department);
      await user!.reload();
      user = _auth.currentUser;

      await _firestore.collection('adminusers').doc(user!.uid).set({
        'email': email,
        'department': department,
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
      });

      isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Sign Up failed: $e";
    }
  }

  // ---------------- SIGN OUT ----------------
  Future<void> signOut() async {
    await _auth.signOut();
    user = null;
    currentDepartment = null;
    notifyListeners();
  }

  // Check if user is already logged in (for persistent sessions)
  bool get isLoggedIn => user != null;
}
