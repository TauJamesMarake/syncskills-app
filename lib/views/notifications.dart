import 'package:flutter/material.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<String> notifications = [
    "Training Completed - Congratulations! Your Microsoft Time Management course has been successfully completed.",
    "Training Overdue - Please note that Advanced Excel Skills must be completed within 2 days.",
    "Reminder: 'Cybersecurity Awareness' course starts tomorrow at 10:00 AM.",
    "Your certificate for 'Project Management Basics' has been successfully issued.",
    "New course 'AI Fundamentals' has been added to your learning plan.",
    "Training Overdue - Please note that Data Analysis Essentials must be completed in 1 day.",
    "Certificate for 'Leadership & Communication' is expiring soon. Renew before 20 Oct.",
    "Course 'Cloud Computing Basics' assigned to your profile. Start date: 19 Oct.",
    "You’ve successfully completed 'Time Management'. Congratulations!",
    "Your 'Data Privacy Awareness' training will expire in 5 days.",
    "New announcement: Upcoming webinar on 'AI in Business' on 21 Oct.",
    "Training Overdue - Please complete your 'Risk Assessment' course as soon as possible.",
  ];

  // Keeps track of selected notifications
  Set<int> selectedIndexes = {};

  Color _getCardColor(int index) {
    // Even index → Green, Odd index → Orange
    return index % 2 == 0
        ? const Color(0xFFC8E6C9) // Light Green
        : const Color(0xFFFFE0B2); // Light Orange
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
      // Remove any selection that’s out of bounds after deletion
      selectedIndexes = selectedIndexes.where((i) => i < notifications.length).toSet();
    });
  }

  void _deleteSelected() {
    setState(() {
      notifications = notifications
          .asMap()
          .entries
          .where((entry) => !selectedIndexes.contains(entry.key))
          .map((e) => e.value)
          .toList();
      selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'SYNCSKILLS',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Audit | Skills | Excel',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "Unread (${notifications.length})",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                if (selectedIndexes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Delete selected",
              onPressed: _deleteSelected,
            ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndexes.contains(index);
                return Card(
                  color: _getCardColor(index),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(index),
                      activeColor: Colors.green[700],
                    ),
                    title: Text(
                      notifications[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNotification(index),
                    ),
                    onTap: () => _toggleSelection(index),
                  ),
                );
              },
            ),
          ),
          
        ],
      ),
    );
  }
}
