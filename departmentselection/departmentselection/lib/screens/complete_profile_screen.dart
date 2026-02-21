import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';
import '../widgets/address_autocomplete_field.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/permission_helper.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({
    super.key,
    this.mandatory = false,
    this.onProfileCompleted,
    this.onBackPressed,
  });

  final bool mandatory;
  final VoidCallback? onProfileCompleted;
  final VoidCallback? onBackPressed;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();

  bool loading = false;
  String errorMessage = '';
  late String email;
  String _gender = '';
  DateTime _dob = DateTime.now();

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'Select date of birth',
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        dobController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender.isEmpty) {
      setState(() => errorMessage = 'Please select gender');
      return;
    }
    if (dobController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Please select date of birth');
      return;
    }
    setState(() {
      loading = true;
      errorMessage = '';
    });
    try {
      final newProfile = Profile(
        fullName: nameController.text.trim(),
        email: email,
        phoneNumber: phoneController.text.trim(),
        department: '', // No longer collected
        address: addressController.text.trim(),
        dob: _dob,
        gender: _gender,
      );
      await ProfileService.upsertProfile(newProfile);

      if (mounted) {
        final permissionsGranted = await PermissionHelper.requestPermissionsWithExplanation(context);
        if (!permissionsGranted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Some features may not work without permissions. You can grant them later in settings.'),
              duration: Duration(seconds: 4),
            ),
          );
        }

        if (widget.onProfileCompleted != null) {
          widget.onProfileCompleted!();
        } else if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      setState(() => errorMessage = 'Could not save profile!');
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.mandatory && widget.onBackPressed != null) {
              widget.onBackPressed!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffc8e6fc), Color(0xffffffff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.blueAccent.withOpacity(0.13),
                          child: const Icon(Icons.person_add_alt_1, color: Colors.blue, size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Let's set up your profile",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff0a2240),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.mandatory
                              ? 'All fields are required to continue'
                              : 'Fill in your details to get started',
                          style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.12),
                          blurRadius: 11,
                          offset: const Offset(1, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _textField(
                          controller: nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                        ),
                        _textField(
                          controller: phoneController,
                          label: 'Phone Number (required)',
                          icon: Icons.phone_rounded,
                          inputType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Phone number is required';
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: AddressAutocompleteField(
                            controller: addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              hintText: 'Start typing to see suggestions',
                              prefixIcon: const Icon(Icons.location_on, color: Colors.blueAccent),
                              filled: true,
                              fillColor: Colors.blueGrey.withOpacity(0.06),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                prefixIcon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                                filled: true,
                                fillColor: Colors.blueGrey.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              child: Text(
                                dobController.text.isEmpty
                                    ? 'Tap to choose date'
                                    : dobController.text,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: dobController.text.isEmpty ? Colors.grey[600] : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: DropdownButtonFormField<String>(
                            value: _gender.isEmpty ? null : _gender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: const Icon(Icons.wc_rounded, color: Colors.blueAccent),
                              filled: true,
                              fillColor: Colors.blueGrey.withOpacity(0.06),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            hint: const Text('Select gender'),
                            items: const [
                              DropdownMenuItem(value: 'Male', child: Text('Male')),
                              DropdownMenuItem(value: 'Female', child: Text('Female')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                              DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                            ],
                            onChanged: (v) => setState(() => _gender = v ?? ''),
                            validator: (v) => (v == null || v.isEmpty) ? 'Please select gender' : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                            filled: true,
                            fillColor: Colors.blueGrey.withOpacity(0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialValue: email,
                        ),
                        const SizedBox(height: 20),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 15)),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                loading ? 'Saving...' : 'Save Profile',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 2,
                              minimumSize: const Size.fromHeight(45),
                            ),
                            onPressed: loading ? null : saveProfile,
                          ),
                        ),
                        if (!widget.mandatory) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                            label: const Text('Skip for Now'),
                            onPressed: () async {
                              if (!mounted) return;
                              final permissionsGranted = await PermissionHelper.requestPermissionsWithExplanation(context);
                              if (!permissionsGranted && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Some features may not work without permissions.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? inputType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(fontSize: 17),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.blueGrey.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator ?? ((v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
      ),
    );
  }
}
