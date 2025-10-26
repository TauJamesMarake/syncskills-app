import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/profile_setup/proficiency_level_screen.dart';

class SkillSelectionScreen extends StatefulWidget {
  const SkillSelectionScreen({Key? key}) : super(key: key);

  @override
  _SkillSelectionScreenState createState() => _SkillSelectionScreenState();
}

class _SkillSelectionScreenState extends State<SkillSelectionScreen> {
  final supabase = Supabase.instance.client;

  final List<String> allSkills = [
    "C#",
    "Java",
    "React",
    "JavaScript",
    "Power BI",
    "Flutter",
    "Tableau",
    "Python",
    "MySQL",
    "Data Analysis",
    "SQL",
    "Research",
  ];

  List<String> filteredSkills = [];
  Set<String> selectedSkills = {};

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSkills = List.from(allSkills);
    searchController.addListener(() => filterSkills(searchController.text));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterSkills(String query) {
    setState(() {
      filteredSkills = allSkills
          .where(
            (skill) => skill.toLowerCase().contains(query.toLowerCase().trim()),
          )
          .toList();
    });
  }

  void addNewSkill(String skill) {
    if (skill.isNotEmpty && !allSkills.contains(skill)) {
      setState(() {
        allSkills.add(skill);
        filteredSkills.add(skill);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('New skill "$skill" added to list'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _proceedToProficiency() {
    if (selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one skill"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert selected skills to list of maps
    final skillsList = selectedSkills.map((skill) {
      return {
        'skill_name': skill,
        'proficiency_level': null, // Will be set in proficiency screen
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProficiencyLevelScreen(selectedSkills: skillsList),
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
                  letterSpacing: 1,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Select Your Skills',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Show selected skills count
              if (selectedSkills.isNotEmpty)
                Container(
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
                        '${selectedSkills.length} skill(s) selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Search box
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search or add a new skill",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        addNewSkill(searchController.text.trim());
                        searchController.clear();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Skills Grid
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredSkills.length,
                    itemBuilder: (context, index) {
                      final skill = filteredSkills[index];
                      final isSelected = selectedSkills.contains(skill);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedSkills.remove(skill);
                            } else {
                              selectedSkills.add(skill);
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF2D8F3C),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: isSelected
                                  ? const Color(0xFF2D8F3C)
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _proceedToProficiency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8F3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
