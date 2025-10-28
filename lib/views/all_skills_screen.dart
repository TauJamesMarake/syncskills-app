import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/user_dashboard_screen.dart';
import 'package:syncskills/views/add_all_skills.dart';
import 'package:syncskills/views/add_proficiency_level_screen.dart';
import 'package:syncskills/views/profile_screen.dart';

class ViewSkillsScreen extends StatefulWidget {
  @override
  _ViewSkillsScreenState createState() => _ViewSkillsScreenState();
}

class _ViewSkillsScreenState extends State<ViewSkillsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> userSkills = [];
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await supabase
          .from('user_skills')
          .select()
          .eq('user_id', user.id);

      setState(() {
        userSkills = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading skills: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteSkill(String id) async {
    try {
      await supabase.from('user_skills').delete().eq('id', id);

      setState(() {
        userSkills.removeWhere((skill) => skill['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Skill deleted'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error deleting: $e'),
        ),
      );
    }
  }

  // View skill details
  void _viewSkill(Map<String, dynamic> skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Skill Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Skill:', skill['skill_name'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Proficiency Level:',
              _capitalize(skill['proficiency_level'] ?? 'N/A'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Edit skill
  void _editSkill(Map<String, dynamic> skill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProficiencyLevelScreen(
          selectedSkills: [
            {
              'skill_name': skill['skill_name'],
              'proficiency_level': skill['proficiency_level'],
            },
          ],
        ),
      ),
    ).then((_) {
      // Reload skills when returning from edit
      _loadSkills();
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getProficiencyColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.orange;
      case 'intermediate':
        return Colors.blue;
      case 'advanced':
        return Colors.purple;
      case 'expert':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F1D4),
     appBar: AppBar(
        backgroundColor: const Color(0xFF2D8F3C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Skills',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2D8F3C),
                      ),
                    )
                  : userSkills.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stars_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No skills added yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: userSkills.length,
                      itemBuilder: (context, index) {
                        final skill = userSkills[index];
                        final proficiency =
                            skill['proficiency_level'] ?? 'beginner';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            onTap: () => _viewSkill(skill),
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: _getProficiencyColor(
                                proficiency,
                              ),
                              child: Text(
                                skill['skill_name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              skill['skill_name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getProficiencyColor(
                                      proficiency,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _capitalize(proficiency),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getProficiencyColor(proficiency),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit button
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editSkill(skill),
                                ),
                                // Delete button
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Skill?'),
                                        content: Text(
                                          'Are you sure you want to delete ${skill['skill_name']}?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteSkill(skill['id']);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSkillSelectionScreen(selectedSkills: [],),
            ),
          ).then((_) => _loadSkills());
        },
        backgroundColor: const Color(0xFF2D8F3C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Skill'),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
   // .. Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2D8F3C),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          switch (index) {
            case 0:
              // DASHBOARD SCREEN
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
              break;
            case 1:
              // TODO: Navigate to Skills Screen
              Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewSkillsScreen(),
                            ),
                          );
              break;
            case 2:
              // TODO: Navigate to Learning Screen
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Learning screen coming soon')),
              // );

              // soon to be changed to LEARNING(): the screen that contains nav. for LMS (qualifications incl.)
              // CURRENT SCREEN
              
              break;
            case 3:
              // Navigate to Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Skills'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learning'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
