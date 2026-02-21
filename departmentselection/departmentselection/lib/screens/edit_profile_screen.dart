import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';
import '../widgets/address_autocomplete_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneDisplayController = TextEditingController(); // Read-only display
  final addressController = TextEditingController();
  final dobController = TextEditingController();

  String email = '';
  String _phoneNumber = ''; // Immutable: change requires verification
  bool loading = false;
  String errorMessage = '';
  String _gender = '';
  DateTime _dob = DateTime.now();

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
      _phoneNumber = profile.phoneNumber;
      phoneDisplayController.text = profile.phoneNumber;
      addressController.text = profile.address;
      _dob = profile.dob;
      dobController.text = '${_dob.year}-${_dob.month.toString().padLeft(2, '0')}-${_dob.day.toString().padLeft(2, '0')}';
      _gender = profile.gender;
    }
    setState(() {});
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
    setState(() {
      loading = true;
      errorMessage = '';
    });
    try {
      final updatedProfile = Profile(
        fullName: nameController.text.trim(),
        email: email,
        phoneNumber: _phoneNumber, // Keep existing; cannot change without verification
        department: '', // No longer edited
        address: addressController.text.trim(),
        dob: _dob,
        gender: _gender,
      );
      await ProfileService.upsertProfile(updatedProfile);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => errorMessage = 'Could not update profile!');
    }
    setState(() => loading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneDisplayController.dispose();
    addressController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.blueAccent.withOpacity(0.16),
                          child: const Icon(Icons.edit, color: Colors.blue, size: 38),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xff0a2240),
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
                          label: 'Full Name',
                          icon: Icons.person,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            controller: phoneDisplayController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Change requires verification',
                              prefixIcon: const Icon(Icons.phone_rounded, color: Colors.blueAccent),
                              filled: true,
                              fillColor: Colors.blueGrey.withOpacity(0.07),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              helperText: 'Phone number cannot be changed here. Use verification to update.',
                              helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
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
                              fillColor: Colors.blueGrey.withOpacity(0.07),
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
                                fillColor: Colors.blueGrey.withOpacity(0.07),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              child: Text(
                                dobController.text.isEmpty ? 'Tap to choose date' : dobController.text,
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
                              fillColor: Colors.blueGrey.withOpacity(0.07),
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
                                : const Icon(Icons.save),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                loading ? 'Saving...' : 'Save Changes',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    label: const Text('Back to Profile'),
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

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
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
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }
}
