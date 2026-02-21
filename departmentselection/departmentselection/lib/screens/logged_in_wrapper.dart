import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import 'complete_profile_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// When user is logged in, shows either CompleteProfileScreen (if profile
/// incomplete) or HomeScreen. Profile completion is mandatory for new users.
class LoggedInWrapper extends StatefulWidget {
  const LoggedInWrapper({super.key});

  @override
  State<LoggedInWrapper> createState() => _LoggedInWrapperState();
}

class _LoggedInWrapperState extends State<LoggedInWrapper> {
  bool? _profileComplete;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    setState(() {
      _loading = true;
      _profileComplete = null;
    });
    final complete = await ProfileService.isProfileComplete();
    if (mounted) {
      setState(() {
        _profileComplete = complete;
        _loading = false;
      });
    }
  }

  void _onProfileCompleted() {
    setState(() => _profileComplete = true);
  }

  Future<void> _signOutAndGoToLogin() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_profileComplete == true) {
      return const HomeScreen();
    }

    return CompleteProfileScreen(
      mandatory: true,
      onProfileCompleted: _onProfileCompleted,
      onBackPressed: _signOutAndGoToLogin,
    );
  }
}
