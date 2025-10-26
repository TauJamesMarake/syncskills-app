import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/profile_setup/add_qualification_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final supabase = Supabase.instance.client;
  late final user = Supabase.instance.client.auth.currentUser;
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController employmentTypeController =
      TextEditingController();
  final TextEditingController yearsOfExperienceController =
      TextEditingController();

  List<Map<String, dynamic>> departments = [];

  @override
  void initState() {
    super.initState();

    // Load user info from Supabase auth metadata or users table
    if (user != null) {
      emailController.text = user!.email ?? '';

      // If you stored names during signup, retrieve them from metadata
      final userMeta = user!.userMetadata;
      firstNameController.text = userMeta?['first_name'] ?? '';
      lastNameController.text = userMeta?['last_name'] ?? '';
    }

    roleController.addListener(_checkForm);
    departmentController.addListener(_checkForm);
    jobTitleController.addListener(_checkForm);
    employmentTypeController.addListener(_checkForm);
    yearsOfExperienceController.addListener(_checkForm);
  }

  void _checkForm() {
    setState(() {
      roleController.text.isNotEmpty &&
          departmentController.text.isNotEmpty &&
          jobTitleController.text.isNotEmpty &&
          employmentTypeController.text.isNotEmpty &&
          yearsOfExperienceController.text.isNotEmpty;
    });
  }

  Future<void> loadDepartments() async {
    try {
      final response = await supabase.from('departments').select();
      setState(() {
        // departments = List<Map<String, dynamic>>.from(response as List);
        departments = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading departments: $e')));
    }
  }

  @override
  void dispose() {
    roleController.dispose();
    jobTitleController.dispose();
    employmentTypeController.dispose();
    yearsOfExperienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F1D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4F1D4),
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'SYNCSKILLS\n',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D8F3C),
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'Audit.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: 'UpSkill.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFDB913),
                ),
              ),
              TextSpan(
                text: 'Excel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.person_outline, color: Colors.black),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.menu, color: Colors.black),
        //     onPressed: () {},
        //   ),
        // ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Profile Setup',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Form
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D8F3C),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildReadOnlyField("First Name", firstNameController),
                        buildReadOnlyField("Last Name", lastNameController),
                        buildReadOnlyField("Email", emailController),
                        // buildTextField("Email", emailController),
                        buildTextField("Department", departmentController),
                        buildTextField("Current Job Title", jobTitleController),
                        buildEmploymentDropdown(),
                        buildTextField(
                          "Years of Experience",
                          yearsOfExperienceController,
                          TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // .. save profiles
                                    try {
                                      await supabase
                                          .from('employee_details')
                                          .upsert({
                                            'id': user!.id,
                                            'first_name':
                                                firstNameController.text,
                                            'last_name':
                                                lastNameController.text,
                                            // 'email': emailController.text,
                                            'department':
                                                departmentController.text,
                                            'job_title':
                                                jobTitleController.text,
                                            'employment_type':
                                                employmentTypeController.text,
                                            'years_of_experience':
                                                int.tryParse(
                                                  yearsOfExperienceController
                                                      .text,
                                                ) ??
                                                0,
                                            'created_at': DateTime.now()
                                                .toIso8601String(),
                                          });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                            "Profile Saved Successfully!",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      );

                                      // .. navigate to add qualifications screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddQualificationScreen(),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Error saving profile: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Reusable text field
  Widget buildTextField(
    String label,
    TextEditingController controller, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: (value) =>
                value == null || value.isEmpty ? "$label is required" : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Read-Only Field Widget
  Widget buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            enabled: false,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade300,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Employment Type dropdown
  Widget buildEmploymentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Employment Type",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: employmentTypeController.text.isNotEmpty
                ? employmentTypeController.text
                : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
            hint: const Text("Select Employment Type"),
            items: const [
              DropdownMenuItem(value: "Permanent", child: Text("Permanent")),
              DropdownMenuItem(value: "Part-Time", child: Text("Part-Time")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  employmentTypeController.text = value;
                });
              }
            },
            dropdownColor: Colors.green.shade100,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
