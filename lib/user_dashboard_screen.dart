import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/all_badges_screen.dart';
import 'package:syncskills/views/all_qualifications_screen.dart';
import 'package:syncskills/views/all_skills_screen.dart';
import 'package:syncskills/views/notifications.dart';
import 'package:syncskills/views/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;

  int _selectedIndex = 0;

  // Data lists
  List<Map<String, dynamic>> qualifications = [];
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> completedTrainings = [];
  List<Map<String, dynamic>> plannedTrainings = [];
  Map<String, dynamic>? userProfile;

  String selectedTraining = "Current";
  bool isLoading = true;
  List<Map<String, dynamic>> earnedBadges = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // .. Load badges
      await supabase.rpc(
        'check_and_award_badges',
        params: {'p_user_id': user.id},
      );

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

      await Future.wait([_loadBadges()]);

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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  List<Map<String, dynamic>> _getFilteredTrainings() {
    switch (selectedTraining) {
      case "Current":
        return plannedTrainings
            .where((t) => t['status'] == 'planned' || t['status'] == 'assigned')
            .toList();
      case "In Progress":
        return plannedTrainings
            .where((t) => t['status'] == 'assigned')
            .toList();
      case "Completed":
        return completedTrainings;
      case "Expired":
        return plannedTrainings
            .where((t) => t['status'] == 'cancelled')
            .toList();
      default:
        return [];
    }
  }

  // .. Badges
  Future<void> _loadBadges() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from('user_badges')
          .select(
            'badge_id, earned_at, badges (badge_name, tier, icon_emoji, description, points)',
          )
          .eq('user_id', user.id)
          .order('earned_at', ascending: false);

      setState(() {
        earnedBadges = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print('Error loading badges: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.green.shade200,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2D8F3C)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
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
                  Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          // Navigate to Profile
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          ).then((_) {
                            setState(() => _selectedIndex = 0);
                            _loadAllData();
                          });
                        },
                        icon: const Icon(
                          Icons.account_circle,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------- PROFILE CARD ----------
              _buildProfileCard(),

              const SizedBox(height: 20),

              // ---------- MANAGE QUALIFICATIONS ----------
              _buildQualificationSection(),

              const SizedBox(height: 20),

              // ---------- MANAGE SKILLS ----------
              _buildSkillsSection(),

              const SizedBox(height: 20),

              // ---------- TRAINING SECTION ----------
              _buildTrainingCard(),

              const SizedBox(height: 20),

              // ---------- BADGES ----------
              _buildBadgesSection(),

              const SizedBox(height: 20),

              // ---------- NEW RELEASES ----------
              _buildNewReleasesSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // .. P,rofile Card
  Widget _buildProfileCard() {
    final user = supabase.auth.currentUser;
    final firstName = userProfile?['first_name'] ?? 'User';
    final lastName = userProfile?['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final email = user?.email ?? 'No email';
    final joinDate = user?.createdAt != null
        ? _formatDate(user!.createdAt)
        : 'N/A';
    final profilePicUrl = userProfile?['profile_picture_url'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            // MAKE AVATAR CLICKABLE
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => _loadAllData());
            },
            child: CircleAvatar(
              radius: 28,
              backgroundImage: profilePicUrl != null
                  ? NetworkImage(profilePicUrl)
                  : null,
              backgroundColor: Colors.grey,
              child: profilePicUrl == null
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.email, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Joined $joinDate",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              ).then((_) => _loadAllData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text(
              "Update",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // .. Manage Qualifications
  Widget _buildQualificationSection() {
    // Get last 3 qualifications
    final displayQuals = qualifications.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _boxStyle(),
      child: Column(
        children: [
          _titleRow("Manage Qualifications", qualifications.length),
          const SizedBox(height: 10),
          displayQuals.isEmpty
              ? _emptyState("No qualifications added yet")
              : _buildTable(
                  ["Date", "Qualification"],
                  displayQuals.map((q) {
                    return [
                      _formatDate(q['created_at']),
                      q['title']?.toString() ?? 'N/A',
                    ];
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // .. Manage Skills
  Widget _buildSkillsSection() {
    // Get last 3 skills
    final displaySkills = skills.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _boxStyle(),
      child: Column(
        children: [
          _titleRow("Manage Skills", skills.length),
          const SizedBox(height: 10),
          displaySkills.isEmpty
              ? _emptyState("No skills added yet")
              : _buildTable(
                  ["Skill", "Level"],
                  displaySkills.map((s) {
                    return [
                      s['skill_name']?.toString() ?? 'N/A',
                      _capitalize(
                        s['proficiency_level']?.toString() ?? 'beginner',
                      ),
                    ];
                  }).toList(),
                ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // .. Training Card
  Widget _buildTrainingCard() {
    final tabs = ["Current", "In Progress", "Completed", "Expired"];
    final filteredTrainings = _getFilteredTrainings();

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Training",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.map((tab) {
                  final isSelected = selectedTraining == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTraining = tab),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.amber[800]
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: filteredTrainings.isEmpty
                  ? Text(
                      "No $selectedTraining trainings",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: filteredTrainings.take(2).map((training) {
                        final name = selectedTraining == "Completed"
                            ? training['training_name']
                            : training['course_name'];
                        final date = selectedTraining == "Completed"
                            ? training['completion_date']
                            : training['expected_completion_date'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.school,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Date: ${date ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to full training list
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewSkillsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("View All"),
            ),
          ],
        ),
      ),
    );
  }

  // ..Badges Section
  Widget _buildBadgesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Badges",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          earnedBadges.isEmpty
              ? _emptyState("No badges earned yet")
              : Column(
                  children: earnedBadges.take(5).map((badge) {
                    final b = badge['badges'];
                    return _badgeItem(
                      b['icon_emoji'] ?? '🏅',
                      b['badge_name'] ?? 'Badge',
                      b['tier'] ?? '',
                      b['description'] ?? '',
                      b['points'] ?? 0,
                    );
                  }).toList(),
                ),
          if (earnedBadges.length > 5) const SizedBox(height: 8),
          if (earnedBadges.length > 5)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllBadgesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text("View All"),
              ),
            ),
        ],
      ),
    );
  }

  // .. New Releases with small images (mobile-friendly)
  Widget _buildNewReleasesSection() {
    final releases = [
      {'title': 'UI/UX Basics', 'img': 'assets/course1.jpg'},
      {'title': 'Advanced Flutter', 'img': 'assets/course2.jpg'},
      {'title': 'Cyber Security', 'img': 'assets/course3.jpg'},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "New Releases",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: releases.length,
              itemBuilder: (context, index) {
                final item = releases[index];
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Helper Widgets ----------
  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green, width: 1),
    );
  }

  Widget _titleRow(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title ($count)",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to qualifications management screen
            if (title == 'Manage Qualifications') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllQualificationsScreen(),
                ),
              );
            }
            // TODO: Navigate to skills management screen
            else if (title == 'Manage Skills') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewSkillsScreen()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text(
            "View All",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<String> headers, List<List<String>> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Colors.black26),
        ),
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
        children: [
          TableRow(
            children: headers
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      h,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
          ),
          for (var row in data)
            TableRow(
              children: row
                  .map(
                    (cell) => Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(cell),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  // .. badge item
  Widget _badgeItem(
    String emoji,
    String title,
    String tier,
    String desc,
    int points,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            '$points pts',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
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
              // Already on Dashboard
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              ).then((_) {
                setState(() => _selectedIndex = 0);
                _loadAllData();
              });
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Learning screen coming soon')),
              );
              break;
            case 3:
              // Navigate to Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) {
                setState(() => _selectedIndex = 0);
                _loadAllData();
              });
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
