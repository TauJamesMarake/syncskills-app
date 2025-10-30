import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/user_dashboard_screen.dart';

class AllBadgesScreen extends StatefulWidget {
  const AllBadgesScreen({super.key});

  @override
  _AllBadgesScreenState createState() => _AllBadgesScreenState();
}

class _AllBadgesScreenState extends State<AllBadgesScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> badges = [];
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadBadgesAndPoints();
  }

  Future<void> _loadBadgesAndPoints() async {
    setState(() => isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Load badges with points > 0
      final badgeResponse = await supabase
          .from('badges')
          .select()
          .gt('points', 0)
          .order('display_order', ascending: true);

      // Load user badge stats
      final pointsResponse = await supabase
          .rpc('get_user_badge_stats', params: {'p_user_id': user.id})
          .maybeSingle();

      setState(() {
        badges = List<Map<String, dynamic>>.from(badgeResponse);
        totalPoints = pointsResponse?['total_points'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading badges: $e');
      setState(() => isLoading = false);
    }
  }

  String _motivationalMessage(int points) {
    if (points < 50) return "Keep going! You're building your skills!";
    if (points < 150) return "Great progress! Keep leveling up!";
    if (points < 300) return "Impressive! You're a true achiever!";
    return "Outstanding! You're a badge master!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F1D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D8F3C),
        elevation: 0,
        title: const Text(
          'Milestones',
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
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Points counter and motivational message
                Container(
                  width: double.infinity,
                  color: const Color(0xFF2D8F3C),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Points: $totalPoints',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _motivationalMessage(totalPoints),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge list
                Expanded(
                  child: badges.isEmpty
                      ? const Center(child: Text('No badges available'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: badges.length,
                          itemBuilder: (context, index) {
                            final badge = badges[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: badge['icon_url'] != null
                                    ? Image.network(
                                        badge['icon_url'],
                                        width: 40,
                                        height: 40,
                                      )
                                    : Text(
                                        badge['icon_emoji'] ?? '🏅',
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                title: Text(
                                  badge['badge_name'] ?? 'Badge',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      badge['description'] ?? '',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _tierBadge(badge['tier']),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${badge['points'] ?? 0} pts',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
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
    );
  }

  Widget _tierBadge(String? tier) {
    Color color;
    switch (tier) {
      case 'Gold':
        color = Colors.amber.shade700;
        break;
      case 'Silver':
        color = Colors.grey.shade400;
        break;
      case 'Bronze':
        color = Colors.brown.shade400;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tier ?? 'Tier',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
