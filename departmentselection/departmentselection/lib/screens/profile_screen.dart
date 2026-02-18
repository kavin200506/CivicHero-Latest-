import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/global_voice_button.dart';
import '../widgets/language_selector.dart';
import '../widgets/voice_settings_widget.dart';
import '../models/voice_command_event.dart';
import 'edit_profile_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to global voice commands
    VoiceCommandEvent.listen(_handleGlobalVoiceCommand);
  }

  @override
  void dispose() {
    VoiceCommandEvent.removeListener(_handleGlobalVoiceCommand);
    super.dispose();
  }

  /// Handle global voice commands
  void _handleGlobalVoiceCommand(VoiceCommand command) {
    if (!mounted) return;
    
    switch (command.action) {
      case VoiceAction.navigateHome:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        break;
      case VoiceAction.logout:
        FirebaseAuth.instance.signOut();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: Colors.blue[50],
      body: user == null
          ? const Center(
              child: Text(
                'Not logged in',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Profile not found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Complete your profile to get started',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text(
                            'Add Profile Details',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final user = FirebaseAuth.instance.currentUser;
                final email = user?.email ?? 'Not added';

                final fields = [
                  {'label': 'Full Name', 'key': 'fullName', 'icon': Icons.person},
                  {'label': 'Email', 'value': email, 'icon': Icons.email},
                  {'label': 'Phone Number', 'key': 'phonenumber', 'icon': Icons.phone},
                  {'label': 'Department/Role', 'key': 'role', 'icon': Icons.work},
                  {'label': 'Address', 'key': 'address', 'icon': Icons.house},
                  {'label': 'Date of Birth', 'key': 'dob', 'icon': Icons.cake},
                  {'label': 'Gender', 'key': 'gender', 'icon': Icons.wc},
                ];

                int filledFields = 0;
                for (var field in fields) {
                  if (field.containsKey('value')) {
                    if (field['value'] != null &&
                        field['value'].toString().trim().isNotEmpty &&
                        field['value'] != 'Not added') {
                      filledFields++;
                    }
                  } else {
                    final value = data[field['key']] ?? '';
                    if (field['key'] == 'dob' && value is Timestamp) {
                      if (value.toDate().toString().isNotEmpty) filledFields++;
                    } else if (value.toString().trim().isNotEmpty &&
                        value.toString() != '0') {
                      filledFields++;
                    }
                  }
                }
                final completionPercent = (filledFields / fields.length);

                return Stack(
                  children: [
                    Container(
                      height: 240,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xff237fe7), Color(0xff78befa)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 38),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 123,
                                width: 123,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.11),
                                      blurRadius: 27,
                                      offset: const Offset(0, 9),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 110,
                                width: 110,
                                child: CircularProgressIndicator(
                                  value: completionPercent,
                                  strokeWidth: 9,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(
                                    completionPercent == 1.0
                                        ? Colors.green
                                        : Colors.blueAccent,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 36,
                                    color: completionPercent == 1.0
                                        ? Colors.green
                                        : Colors.blueAccent,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${(completionPercent * 100).round()}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xff2595ec),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Profile ${(completionPercent * 100).round()}% Complete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.10),
                                  blurRadius: 13,
                                  offset: const Offset(2, 13),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Profile Information',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                ...fields.map((field) {
                                  final value = field.containsKey('value')
                                      ? field['value']
                                      : data[field['key']];
                                  String displayValue;
                                  if (field['key'] == 'dob' &&
                                      value is Timestamp) {
                                    displayValue = value.toDate().toString().split(' ').first;
                                  } else {
                                    displayValue = (value == null ||
                                            value.toString().trim().isEmpty ||
                                            value.toString() == '0')
                                        ? 'Not added'
                                        : value.toString();
                                  }
                                  final isMissing = displayValue == 'Not added';
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0.5,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    color: isMissing
                                        ? Colors.blueGrey[50]
                                        : Colors.blue[50],
                                    child: ListTile(
                                      leading: Icon(
                                        field['icon'] as IconData,
                                        color: isMissing
                                            ? Colors.grey[400]
                                            : Colors.blue,
                                      ),
                                      title: Text(
                                        field['label'] as String,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey[800],
                                        ),
                                      ),
                                      subtitle: Text(
                                        displayValue,
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: isMissing
                                              ? Colors.grey[500]
                                              : Colors.black87,
                                          fontStyle: isMissing
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Voice Settings
                          const VoiceSettingsWidget(),
                          const SizedBox(height: 16),
                          // Language Selector
                          const LanguageSelector(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 55,
                      right: 28,
                      child: FloatingActionButton.extended(
                        heroTag: 'edit_fab',
                        backgroundColor: Colors.white,
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: const GlobalVoiceButton(),
    );
  }
}

// Add Language Selector to Profile Screen
// The language selector should be added in the profile information section
// For now, users can access it via a settings screen or we can add it directly
