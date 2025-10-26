import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/profile_setup/skills_summary_screen.dart';

class ProficiencyLevelScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSkills;

  const ProficiencyLevelScreen({Key? key, required this.selectedSkills})
    : super(key: key);

  @override
  State<ProficiencyLevelScreen> createState() => _ProficiencyLevelScreenState();
}

class _ProficiencyLevelScreenState extends State<ProficiencyLevelScreen> {
  final supabase = Supabase.instance.client;
  late final user = Supabase.instance.client.auth.currentUser;
  Map<String, String> skillProficiency = {};
  bool _isSaving = false;

  final List<Map<String, String>> levels = [
    {"title": "Beginner", "desc": "Basic Understanding"},
    {"title": "Intermediate", "desc": "Independent User"},
    {"title": "Advanced", "desc": "Solve Problems"},
    {"title": "Expert", "desc": "Master Level"},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing proficiency levels if editing
    for (var skill in widget.selectedSkills) {
      if (skill['proficiency_level'] != null) {
        skillProficiency[skill['skill_name']] = _capitalize(
          skill['proficiency_level'],
        );
      } else {
        // Default to Beginner for new skills
        skillProficiency[skill['skill_name']] = 'Beginner';
      }
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _saveSkills() async {
    // Validate that all skills have proficiency selected
    for (var skill in widget.selectedSkills) {
      if (!skillProficiency.containsKey(skill['skill_name'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              'Please select proficiency level for ${skill['skill_name']}',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('User not authenticated'),
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    try {
      // Prepare skills for insertion/update
      final skillsToSave = widget.selectedSkills.map((skill) {
        return {
          'user_id': user!.id, // Use the authenticated user's id
          'skill_name': skill['skill_name'],
          'proficiency_level': skillProficiency[skill['skill_name']]!
              .toLowerCase(),
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      // Check if we're editing or adding new skills
      for (var skill in skillsToSave) {
        // Try to update first (if exists)
        final existing = await supabase
            .from('user_skills')
            .select()
            .eq('user_id', user!.id)
            .eq('skill_name', skill['skill_name'])
            .maybeSingle();

        if (existing != null) {
          // Update existing skill
          await supabase
              .from('user_skills')
              .update({'proficiency_level': skill['proficiency_level']})
              .match({'user_id': user!.id, 'skill_name': skill['skill_name']});
        } else {
          // Insert new skill
          await supabase.from('user_skills').insert(skill);
        }
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error saving skills: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 60, color: Colors.green),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.selectedSkills.length == 1
                      ? 'Your skill has been saved!'
                      : '${widget.selectedSkills.length} skills have been saved!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Go back to skill selection to add more
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to selection
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add more skills',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SkillsSummaryScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View my skills',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill) {
    final skillName = skill['skill_name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D8F3C), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: const Color(0xFF2D8F3C), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  skillName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2D8F3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Select your proficiency level:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: levels.map((level) {
              final isSelected = skillProficiency[skillName] == level["title"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    skillProficiency[skillName] = level["title"]!;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2D8F3C).withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2D8F3C)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2D8F3C)
                                : Colors.grey,
                            width: 2,
                          ),
                          color: isSelected
                              ? const Color(0xFF2D8F3C)
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level["title"]!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF2D8F3C)
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              level["desc"]!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Set Proficiency Levels',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.selectedSkills.length,
                itemBuilder: (context, index) {
                  return _buildSkillCard(widget.selectedSkills[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSkills,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8F3C),
                    foregroundColor: Colors.white,
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
                          'Save',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
