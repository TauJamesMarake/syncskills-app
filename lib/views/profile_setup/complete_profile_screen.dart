import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/profile_setup/planned_trainings_summary_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final supabase = Supabase.instance.client;

  // Data structure for multiple planned courses
  List<Map<String, TextEditingController>> plannedCourses = [
    {'course': TextEditingController(), 'date': TextEditingController()},
  ];

  // Privacy selection (default is public)
  String privacySetting = "public";
  bool _isSaving = false;

  @override
  void dispose() {
    for (var course in plannedCourses) {
      course['course']!.dispose();
      course['date']!.dispose();
    }
    super.dispose();
  }

  // Build a single course input block
  Widget _buildCourseInputBlock(
    int index,
    Map<String, TextEditingController> courseData,
  ) {
    return Container(
      key: ValueKey(index),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Course ${index + 1}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              if (plannedCourses.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      courseData['course']!.dispose();
                      courseData['date']!.dispose();
                      plannedCourses.removeAt(index);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Course input
          TextField(
            controller: courseData['course'],
            decoration: const InputDecoration(
              labelText: "Course / Certification",
              hintText: "e.g. Machine Learning Fundamentals",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Date input
          TextField(
            controller: courseData['date'],
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Expected completion date",
              hintText: "yyyy-mm-dd",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2035),
              );
              if (pickedDate != null) {
                setState(() {
                  courseData['date']!.text =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Save planned courses to database
  Future<void> _saveProfile() async {
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

    // Collect all planned courses
    List<Map<String, dynamic>> coursesToSave = [];
    for (var course in plannedCourses) {
      final courseName = course['course']!.text.trim();
      final courseDate = course['date']!.text.trim();

      if (courseName.isNotEmpty) {
        coursesToSave.add({
          'user_id': user.id,
          'course_name': courseName,
          'expected_completion_date': courseDate.isNotEmpty ? courseDate : null,
          'status': 'planned',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }

    if (coursesToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please add at least one planned training'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Save planned trainings
      await supabase.from('planned_trainings').insert(coursesToSave);

      // Update user privacy setting in users table
      await supabase
          .from('users')
          .update({'privacy_setting': privacySetting})
          .eq('id', user.id);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlannedTrainingsSummaryScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error saving profile: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
        automaticallyImplyLeading: false,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Planned Training Header
              Text(
                "Planned Training",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Add any courses or certifications you plan to complete in the future.",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Planned Courses Input
              ...plannedCourses.asMap().entries.map((entry) {
                int index = entry.key;
                var courseData = entry.value;
                return _buildCourseInputBlock(index, courseData);
              }).toList(),

              const SizedBox(height: 10),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      plannedCourses.add({
                        'course': TextEditingController(),
                        'date': TextEditingController(),
                      });
                    });
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF2D8F3C)),
                  label: const Text(
                    "Add Another Course",
                    style: TextStyle(color: Color(0xFF2D8F3C)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2D8F3C), width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 2),
              const SizedBox(height: 20),

              // Privacy Settings Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2D8F3C), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Privacy Settings",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D8F3C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Control who can see your profile information",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RadioListTile(
                      title: const Text(
                        "Public",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Everyone can see your profile information",
                        style: TextStyle(fontSize: 13),
                      ),
                      value: "public",
                      groupValue: privacySetting,
                      activeColor: const Color(0xFF2D8F3C),
                      onChanged: (value) {
                        setState(() {
                          privacySetting = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text(
                        "Private",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Only you and admins can see your profile information",
                        style: TextStyle(fontSize: 13),
                      ),
                      value: "private",
                      groupValue: privacySetting,
                      activeColor: const Color(0xFF2D8F3C),
                      onChanged: (value) {
                        setState(() {
                          privacySetting = value.toString();
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bottom Buttons
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFF2D8F3C),
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Back",
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
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D8F3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Complete Profile",
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
    );
  }
}
