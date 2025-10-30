import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/profile_setup/completed_trainings_summary.dart';

class CompletedTrainingsScreen extends StatefulWidget {
  const CompletedTrainingsScreen({Key? key}) : super(key: key);

  @override
  _CompletedTrainingsScreenState createState() =>
      _CompletedTrainingsScreenState();
}

class _CompletedTrainingsScreenState extends State<CompletedTrainingsScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _trainingNameController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  String uploadedFileName = "";
  String uploadedFilePath = "";
  PlatformFile? _certificateFile;
  String? certificateUrl;
  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingCertificate = false;

  // List to store trainings temporarily before saving
  List<Map<String, dynamic>> tempTrainings = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _trainingNameController.dispose();
    _institutionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _certificateController.dispose();
    super.dispose();
  }

  /// Pick a date
  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat("yyyy-MM-dd").format(picked);
    }
  }

  /// Pick file and upload
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && mounted) {
      setState(() {
        _certificateFile = result.files.single;
        uploadedFileName = result.files.single.name;
        uploadedFilePath = result.files.single.path ?? "";
      });
      // Upload immediately after selection
      await _uploadCertificate();
    }
  }

  Future<void> _uploadCertificate() async {
    if (_certificateFile == null) return;

    setState(() => isUploadingCertificate = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get file extension
      final fileExtension = _certificateFile!.extension ?? 'pdf';

      // Create unique filename with timestamp
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = '${user.id}/$fileName';

      print('Uploading certificate to: $filePath');

      // Read file bytes (works on web and mobile)
      final fileBytes =
          _certificateFile!.bytes ??
          await File(_certificateFile!.path!).readAsBytes();

      // Upload to certificates bucket
      await supabase.storage
          .from('certificates')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: _certificateFile!.extension == 'pdf'
                  ? 'application/pdf'
                  : 'image/${_certificateFile!.extension}',
            ),
          );

      print('Upload successful');

      // Get public URL
      final publicUrl = supabase.storage
          .from('certificates')
          .getPublicUrl(filePath);
      print('Public URL: $publicUrl');

      if (mounted) {
        setState(() {
          certificateUrl = publicUrl;
          isUploadingCertificate = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error uploading certificate: $e');

      if (mounted) {
        setState(() => isUploadingCertificate = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Add training to temporary list
  void _addTrainingToList() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        tempTrainings.add({
          'title': _trainingNameController.text.trim(),
          'provider': _institutionController.text.trim(),
          'start_date': _startDateController.text.trim(),
          'completion_date': _endDateController.text.trim(),
          'certificate_number': _certificateController.text.trim(),
          'certificate_url': certificateUrl ?? '', // Use uploaded URL
        });

        // Clear form
        _trainingNameController.clear();
        _institutionController.clear();
        _startDateController.clear();
        _endDateController.clear();
        _certificateController.clear();
        uploadedFileName = "";
        uploadedFilePath = "";
        certificateUrl = null;
        _certificateFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Training added! (${tempTrainings.length} total)'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Save all trainings to database
  Future<void> _saveAllTrainings() async {
    // Add current form data if filled
    if (_trainingNameController.text.isNotEmpty) {
      if (_formKey.currentState!.validate()) {
        _addTrainingToList();
      } else {
        return;
      }
    }

    if (tempTrainings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please add at least one training'),
        ),
      );
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('User not authenticated'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Add user_id to each training
      final trainingsToInsert = tempTrainings.map((training) {
        return {
          'user_id': user.id,
          'title': training['title'],
          'provider': training['provider'],
          'start_date': training['start_date'],
          'completion_date': training['completion_date'],
          'certificate_number': training['certificate_number'],
          'certificate_url': training['certificate_url'],
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      // Insert all trainings
      await supabase.from('trainings').insert(trainingsToInsert);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("All trainings saved successfully!"),
          ),
        );

        // Navigate to summary screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TrainingsSummaryScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error saving trainings: $e"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isDate = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: isDate,
              onTap: isDate ? () => _selectDate(controller) : null,
              validator:
                  validator ??
                  (value) => value!.isEmpty ? 'This field is required' : null,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ),
          Icon(icon, color: Colors.grey[700], size: 20),
        ],
      ),
    );
  }

  Widget _buildUploadField() {
    return InkWell(
      onTap: isUploadingCertificate ? null : _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isUploadingCertificate
                    ? "Uploading..."
                    : (uploadedFileName.isEmpty
                          ? "Upload Document (PDF, JPG, PNG)"
                          : uploadedFileName),
                style: TextStyle(color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            isUploadingCertificate
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file, size: 20),
          ],
        ),
      ),
    );
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
                'Add Training',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Show count of added trainings
            if (tempTrainings.isNotEmpty)
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
                        '${tempTrainings.length} training(s) added',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _trainingNameController,
                          hint: 'Training Name/Course',
                          icon: Icons.school,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _institutionController,
                          hint: 'Provider/Institution',
                          icon: Icons.business,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _startDateController,
                          hint: 'Start Date (YYYY-MM-DD)',
                          icon: Icons.calendar_today,
                          isDate: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _endDateController,
                          hint: 'Completion Date (YYYY-MM-DD)',
                          icon: Icons.calendar_today,
                          isDate: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _certificateController,
                          hint: 'Certificate Reference No.',
                          icon: Icons.confirmation_number,
                        ),
                        const SizedBox(height: 12),
                        _buildUploadField(),
                        const SizedBox(height: 20),

                        // Add Another Training Button
                        ElevatedButton(
                          onPressed: _addTrainingToList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add Another Training',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Save & Cancel Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                onPressed: _isSaving ? null : _saveAllTrainings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.green,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
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
