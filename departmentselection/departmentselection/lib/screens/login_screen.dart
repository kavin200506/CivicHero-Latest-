import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logged_in_wrapper.dart';
import 'register_screen.dart';
import '../utils/permission_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool loading = false;

  Future<void> signIn() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });
    
    try {
      print('🔐 Attempting to sign in...');
      
      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase not initialized. Please restart the app.');
      }
      
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      print('✅ Login successful: ${userCredential.user?.email}');
      
      // Request camera and location permissions after login
      if (mounted) {
        final permissionsGranted = await PermissionHelper.requestPermissionsWithExplanation(context);
        
        if (!permissionsGranted) {
          // Show warning but still allow access
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Some features may not work without permissions. You can grant them later in settings.'),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoggedInWrapper()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMsg = "Login failed";
      
      switch (e.code) {
        case 'user-not-found':
          errorMsg = "No user found with this email.";
          break;
        case 'wrong-password':
          errorMsg = "Incorrect password.";
          break;
        case 'invalid-email':
          errorMsg = "Invalid email address.";
          break;
        case 'user-disabled':
          errorMsg = "This account has been disabled.";
          break;
        case 'too-many-requests':
          errorMsg = "Too many failed attempts. Please try again later.";
          break;
        case 'network-request-failed':
          errorMsg = "Network error. Please check your internet connection.";
          break;
        default:
          errorMsg = e.message ?? "Login failed: ${e.code}";
      }
      
      if (mounted) {
        setState(() {
          errorMessage = errorMsg;
        });
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      if (mounted) {
        setState(() {
          errorMessage = "An unexpected error occurred: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      setState(() => errorMessage = "Please enter email to reset password.");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      setState(() =>
          errorMessage = "Password reset link sent! Check your inbox.");
    } on FirebaseAuthException catch (e) {
      setState(() =>
          errorMessage = e.message ?? "Could not send reset email.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Artwork
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, color: Colors.blue, size: 56),
                ),
                const SizedBox(height: 24),
                // Login Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text("Welcome Back!", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 26, color: Colors.blue.shade700,
                      )),
                      const SizedBox(height: 12),
                      Text(
                        "Login to continue your CivicHero journey",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: resetPassword,
                          child: const Text("Forgot Password?"),
                        ),
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(errorMessage,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : signIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Login", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text("Sign Up"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
