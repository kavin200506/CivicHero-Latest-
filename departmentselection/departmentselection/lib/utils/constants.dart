import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryRed = Color(0xFFF44336);
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF616161);
}

class AppStrings {
  static const String appName = 'CivicHero';
  static const String capture = 'Capture Issue';
  static const String upload = 'Upload Photo';
  static const String home = 'Home';
  static const String history = 'History';
  static const String notifications = 'Notifications';
  static const String profile = 'Profile';
}

class DummyData {
  static const List<String> issueTypes = [
    'Pothole',
    'Streetlight Broken',
    'Drainage Overflow',
    'Garbage Pile',
    'Water Leak',
    'Road Crack'
  ];
  
  static const List<String> departments = [
    'Road Department',
    'Electrical Department',
    'Water & Sewerage',
    'Sanitation Department',
    'Public Works'
  ];
  
  static const List<String> urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];
  
  static const List<String> statusSteps = [
    'Reported',
    'Assigned',
    'In Progress',
    'Resolved'
  ];
}
