import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_clear_data_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/voice_command_help.dart';
import 'services/voice_controller_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded');
  } catch (e) {
    print('⚠️ Could not load .env file: $e');
    print('   Continuing without .env (voice commands may not work)');
  }
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    // Show error dialog or handle gracefully
  }
  
  // Initialize Voice Controller
  try {
    await VoiceControllerService().initialize();
    print('✅ Voice Controller initialized');
  } catch (e) {
    print('⚠️ Voice Controller initialization failed: $e');
  }
  
  runApp(const DepartmentSelectionApp());
}

class DepartmentSelectionApp extends StatelessWidget {
  const DepartmentSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivicHero - Department Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primaryBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        useMaterial3: true,
      ),

      // Auth State Logic - keeps user logged in after app restart
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          // Show loading while Firebase checks authentication state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.lightGrey,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading CivicHero...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // If user is logged in, show HomeScreen (persistent login)
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          
          // Otherwise, show LoginScreen
          return const LoginScreen();
        },
      ),
      routes: {
        // Temporary route for clearing data - REMOVE AFTER USE!
        '/clear-data': (context) => const AdminClearDataScreen(),
        // Voice control routes
        '/capture': (context) => const CaptureScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/voice-help': (context) => const VoiceCommandHelpScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
