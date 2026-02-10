import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final departmentController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();
  String email = '';
  bool loading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.fetchProfile();
    if (profile != null) {
      nameController.text = profile.fullName;
      email = profile.email;
      phoneController.text = profile.phoneNumber;
      departmentController.text = profile.department;
      addressController.text = profile.address;
      dobController.text = profile.dob.toIso8601String().split('T').first;
      genderController.text = profile.gender;
    }
    setState(() {});
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      errorMessage = '';
    });
    try {
      final updatedProfile = Profile(
        fullName: nameController.text.trim(),
        email: email,
        phoneNumber: phoneController.text.trim(),
        department: departmentController.text.trim(),
        address: addressController.text.trim(),
        dob: DateTime.tryParse(dobController.text.trim()) ?? DateTime.now(),
        gender: genderController.text.trim(),
      );
      await ProfileService.upsertProfile(updatedProfile);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = 'Could not update profile!';
      });
    }
    setState(() => loading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    addressController.dispose();
    dobController.dispose();
    genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffd3eefd), Color(0xffffffff)],
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
                        // You may remove this for a minimalist look
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.blueAccent.withOpacity(0.16),
                          child: const Icon(Icons.edit, color: Colors.blue, size: 38),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold,
                              letterSpacing: 1.5, color: Color(0xff0a2240)
                          ),
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.10),
                          blurRadius: 11,
                          offset: const Offset(1, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _textField(
                          controller: nameController,
                          label: "Full Name",
                          icon: Icons.person,
                        ),
                        _textField(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_rounded,
                          inputType: TextInputType.phone,
                        ),
                        _textField(
                          controller: departmentController,
                          label: "Department/Role",
                          icon: Icons.work_rounded,
                        ),
                        _textField(
                          controller: addressController,
                          label: "Address",
                          icon: Icons.house_rounded,
                        ),
                        _textField(
                          controller: dobController,
                          label: "Date of Birth (yyyy-mm-dd)",
                          icon: Icons.cake_rounded,
                          inputType: TextInputType.datetime,
                        ),
                        _textField(
                          controller: genderController,
                          label: "Gender",
                          icon: Icons.wc_rounded,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Email",
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
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.save),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                loading ? "Saving..." : "Save Changes",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                              minimumSize: const Size.fromHeight(45),
                            ),
                            onPressed: loading ? null : saveProfile,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    label: const Text("Back to Profile"),
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({required TextEditingController controller, required String label, required IconData icon, TextInputType? inputType}) {
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
          fillColor: Colors.blueGrey.withOpacity(0.07),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          floatingLabelStyle: const TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }
}
