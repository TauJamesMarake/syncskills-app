import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  String? profileImageUrl;
  bool isLoading = true;
  bool isSaving = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Load user profile
      final profileData = await supabase
          .from('employee_details')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        _firstNameController.text = profileData['first_name'] ?? '';
        _lastNameController.text = profileData['last_name'] ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = profileData['phone_number'] ?? '';
        _departmentController.text = profileData['department'] ?? '';
        _positionController.text = profileData['job_title'] ?? '';
        profileImageUrl = profileData['profile_picture_url'];
      }

      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF2D8F3C)),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 75,
                );
                if (photo != null) {
                  setState(() => _imageFile = File(photo.path));
                  _uploadImage();
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF2D8F3C),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 75,
                );
                if (image != null) {
                  setState(() => _imageFile = File(image.path));
                  _uploadImage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Create unique filename
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profile_pictures/$fileName';

      // Upload to Supabase Storage
      await supabase.storage.from('avatars').upload(filePath, _imageFile!);

      // Get public URL
      final imageUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      // Update database
      await supabase
          .from('employee_details')
          .update({'profile_picture_url': imageUrl})
          .eq('id', user.id);

      setState(() {
        profileImageUrl = imageUrl;
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase
          .from('employee_details')
          .update({
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'phone_number': _phoneController.text.trim(),
            'department': _departmentController.text.trim(),
            'job_title': _positionController.text.trim(),
          })
          .eq('id', user.id);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // Show the alert dialog
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop(); // Close the dialog after 1 second
          });

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 60,
            ),
            content: const Text(
              "Profile updated successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFD4F1D4),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2D8F3C)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD4F1D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D8F3C),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with curved design
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF2D8F3C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 56,
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : null,
                            child: profileImageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFF2D8F3C),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFDB913),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_firstNameController.text} ${_lastNameController.text}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _emailController.text,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: 16),

                    // .. First Name
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "First Name",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D8F3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField(
                      hint: "First Name",
                      controller: _firstNameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // .. First Name
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Last Name",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D8F3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField(
                      hint: "Last Name",
                      controller: _lastNameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // .. Email
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D8F3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField(
                      hint: "Email",
                      controller: _emailController,
                      icon: Icons.email,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    // .. Phone number
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Phone",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D8F3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField(
                      hint: "Phone",
                      controller: _phoneController,
                      icon: Icons.phone,
                    ),

                    const SizedBox(height: 30),
                    _buildSectionTitle('Work Information'),
                    const SizedBox(height: 16),

                    // .. Department
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Department",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D8F3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField(
                      hint: "Department",
                      controller: _departmentController,
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 16),

                    // .. Position
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Position",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D8F3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTextField(
                      hint: "Position",
                      controller: _positionController,
                      icon: Icons.work,
                    ),

                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D8F3C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Additional Options
                    _buildSectionTitle('Account Settings'),
                    const SizedBox(height: 16),
                    _buildSettingsTile(
                      icon: Icons.lock,
                      title: 'Change Password',
                      onTap: () {
                        // TODO: Navigate to change password
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Settings',
                      onTap: () {
                        // TODO: Navigate to privacy settings
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.info,
                      title: 'About Us',
                      onTap: () {
                        // TODO: Show about dialog
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.description,
                      title: 'Terms of Service',
                      onTap: () {
                        // TODO: Show terms
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      textColor: Colors.red,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text(
                              'Are you sure you want to sign out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _signOut();
                                },
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D8F3C),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2D8F3C)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? const Color(0xFF2D8F3C)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }
}
