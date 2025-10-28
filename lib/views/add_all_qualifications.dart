import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/all_qualiications_screen.dart';

class AddAllQualificationScreen extends StatefulWidget {
  @override
  _AddAllQualificationScreenState createState() => _AddAllQualificationScreenState();
}

class _AddAllQualificationScreenState extends State<AddAllQualificationScreen> {
  final supabase = Supabase.instance.client;
  late final user = Supabase.instance.client.auth.currentUser;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController certificateNumController =
      TextEditingController();

  String uploadedFileName = "";
  String uploadedFilePath = "";

  // List to store qualifications temporarily before saving
  List<Map<String, dynamic>> tempQualifications = [];

  @override
  void dispose() {
    qualificationController.dispose();
    institutionController.dispose();
    yearController.dispose();
    certificateNumController.dispose();
    super.dispose();
  }

  Widget buildUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Certificate',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'jpg', 'png'],
            );
            if (result != null) {
              setState(() {
                uploadedFileName = result.files.single.name;
                uploadedFilePath = result.files.single.path ?? "";
              });
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          icon: const Icon(Icons.upload_rounded),
          label: Text(uploadedFileName.isEmpty ? "Upload" : uploadedFileName),
        ),
        const SizedBox(height: 4),
        const Text(
          "Accepted formats: PDF, JPG, PNG. Max 10MB.",
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Add qualification to temporary list
  void _addQualificationToList() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        tempQualifications.add({
          'title': qualificationController.text.trim(),
          'institution': institutionController.text.trim(),
          'year_completed': int.tryParse(yearController.text.trim()) ?? 0,
          'certificate_number': certificateNumController.text.trim(),
          'certificate_url': uploadedFilePath,
        });

        // Clear form
        qualificationController.clear();
        institutionController.clear();
        yearController.clear();
        certificateNumController.clear();
        uploadedFileName = "";
        uploadedFilePath = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Qualification added! (${tempQualifications.length} total)',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Save all qualifications to database
  Future<void> _saveAllQualifications() async {
    // Add current form data if filled
    if (qualificationController.text.isNotEmpty) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          tempQualifications.add({
            'title': qualificationController.text.trim(),
            'institution': institutionController.text.trim(),
            'year_completed': int.tryParse(yearController.text.trim()) ?? 0,
            'certificate_number': certificateNumController.text.trim(),
            'certificate_url': uploadedFilePath,
          });
        });
      } else {
        return;
      }
    }

    if (tempQualifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please add at least one qualification'),
        ),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("User not authenticated"),
        ),
      );
      return;
    }

    try {
      // Add user_id to each qualification
      final qualificationsToInsert = tempQualifications.map((q) {
        return {
          'user_id': user!.id,
          'title': q['title'],
          'institution': q['institution'],
          'year_completed': q['year_completed'],
          'certificate_number': q['certificate_number'],
          'certificate_url': q['certificate_url'],
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      // Insert all qualifications
      await supabase.from('qualifications').insert(qualificationsToInsert);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("All qualifications saved successfully!"),
          ),
        );

        // Navigate to summary screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AllQualificationsScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error saving qualifications: $e"),
          ),
        );
      }
    }
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Add Qualification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Show count of added qualifications
            if (tempQualifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '${tempQualifications.length} qualification(s) added',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),

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
                        buildTextField(
                          'Qualification Title',
                          qualificationController,
                          'e.g. (Adv) Dip in Information Technology',
                        ),
                        buildTextField(
                          'Institution Name',
                          institutionController,
                          'e.g. Central University of Technology',
                        ),
                        buildTextField(
                          'Year Completed',
                          yearController,
                          'e.g. 2025',
                          TextInputType.number,
                        ),
                        buildTextField(
                          'Certificate Number',
                          certificateNumController,
                          'e.g. AOTY123456789',
                        ),
                        buildUploadField(),

                        // Add Another Qualification Button
                        ElevatedButton(
                          onPressed: _addQualificationToList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2D8F3C),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Another Qualification',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Save & Cancel Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2D8F3C),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
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
                                onPressed: _saveAllQualifications,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2D8F3C),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Save',
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
          ],
        ),
      ),
    );
  }
}

// Reuse the same field builder (no UI change)
Widget buildTextField(
  String label,
  TextEditingController controller,
  String placeholder, [
  TextInputType keyboardType = TextInputType.text,
]) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) =>
              value == null || value.isEmpty ? "$label is required" : null,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}
