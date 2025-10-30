import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/user_dashboard_screen.dart';
import 'package:syncskills/views/add_all_qualifications.dart';
import 'package:syncskills/views/all_skills_screen.dart';
import 'package:syncskills/views/profile_screen.dart';

class AllQualificationsScreen extends StatefulWidget {
  const AllQualificationsScreen({Key? key}) : super(key: key);

  @override
  _AllQualificationsScreenState createState() =>
      _AllQualificationsScreenState();
}

class _AllQualificationsScreenState extends State<AllQualificationsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> qualifications = [];
  bool isLoading = true;

  int _selectedIndex = 0;

  // Data lists
  //List<Map<String, dynamic>> qualifications = [];
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> completedTrainings = [];
  List<Map<String, dynamic>> plannedTrainings = [];
  Map<String, dynamic>? userProfile;

  String selectedTraining = "Current";
  // bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQualifications();
  }

  Future<void> _loadAllData() async {
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

      // Load qualifications
      final qualData = await supabase
          .from('qualifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      // Load skills
      final skillsData = await supabase
          .from('user_skills')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      // Load completed trainings
      final trainingsData = await supabase
          .from('trainings')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      // Load planned trainings
      final plannedData = await supabase
          .from('planned_trainings')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        userProfile = profileData;
        qualifications = List<Map<String, dynamic>>.from(qualData);
        skills = List<Map<String, dynamic>>.from(skillsData);
        completedTrainings = List<Map<String, dynamic>>.from(trainingsData);
        plannedTrainings = List<Map<String, dynamic>>.from(plannedData);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  // String _formatDate(String? dateStr) {
  //   if (dateStr == null) return 'N/A';
  //   try {
  //     final date = DateTime.parse(dateStr);
  //     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  //   } catch (e) {
  //     return dateStr;
  //   }
  // }

  Future<void> _loadQualifications() async {
    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await supabase
          .from('qualifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        qualifications = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading qualifications: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteQualification(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Qualification?'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('qualifications').delete().eq('id', id);

      setState(() {
        qualifications.removeWhere((qual) => qual['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Qualification deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting qualification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewQualification(Map<String, dynamic> qual) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D8F3C).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Color(0xFF2D8F3C)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Qualification Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Title:', qual['title'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow('Institution:', qual['institution'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Year Completed:',
                qual['year_completed']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Certificate No:',
                qual['certificate_number'] ?? 'N/A',
              ),
              const SizedBox(height: 12),
              if (qual['certificate_url'] != null &&
                  qual['certificate_url'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Certificate:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'File attached',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editQualification(qual);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D8F3C),
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _editQualification(Map<String, dynamic> qual) {
    final titleController = TextEditingController(text: qual['title']);
    final institutionController = TextEditingController(
      text: qual['institution'],
    );
    final yearController = TextEditingController(
      text: qual['year_completed']?.toString() ?? '',
    );
    final certNumberController = TextEditingController(
      text: qual['certificate_number'],
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Qualification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Qualification Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: institutionController,
                  decoration: const InputDecoration(
                    labelText: 'Institution',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year Completed',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: certNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Certificate Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          // .. Save button
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await supabase
                      .from('qualifications')
                      .update({
                        'title': titleController.text.trim(),
                        'institution': institutionController.text.trim(),
                        'year_completed': int.tryParse(
                          yearController.text.trim(),
                        ),
                        'certificate_number': certNumberController.text.trim(),
                      })
                      .eq('id', qual['id']);

                  Navigator.pop(context);
                  _loadQualifications(); // Reload data

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Qualification(s) updated successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Error updating: $e'),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D8F3C),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F1D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D8F3C),
        elevation: 0,
        title: const Text(
          'Qualifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
            (route) => false,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D8F3C)),
            )
          : qualifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: qualifications.length,
              itemBuilder: (context, index) {
                final qual = qualifications[index];
                return _buildQualificationCard(qual);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAllQualificationScreen(),
            ),
          ).then((_) => _loadQualifications());
        },
        backgroundColor: const Color(0xFF2D8F3C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Qualification'),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No qualifications added yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first qualification',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationCard(Map<String, dynamic> qual) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _viewQualification(qual),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D8F3C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  color: Color(0xFF2D8F3C),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qual['title'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      qual['institution'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Year: ${qual['year_completed'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editQualification(qual),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteQualification(
                      qual['id'],
                      qual['title'] ?? 'qualification',
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
                (route) => false,
              );
              break;
            case 1:
              // TODO: Navigate to Skills Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSkillsScreen()),
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
