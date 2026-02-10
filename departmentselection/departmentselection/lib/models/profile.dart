import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String department; // or "role"
  final String address;
  final DateTime dob;
  final String gender;

  Profile({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.department,
    required this.address,
    required this.dob,
    required this.gender,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phonenumber'] ?? '',
      department: map['role'] ?? '',
      address: map['address'] ?? '',
      dob: map['dob'] != null
        ? (map['dob'] is DateTime ? map['dob'] : (map['dob'] as Timestamp).toDate())
        : DateTime.now(),
      gender: map['gender'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phonenumber': phoneNumber,
      'role': department,
      'address': address,
      'dob': dob,
      'gender': gender,
    };
  }
}
