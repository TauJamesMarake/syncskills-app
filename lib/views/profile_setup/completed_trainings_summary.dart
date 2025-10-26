import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/profile_setup/complete_profile_screen.dart';

class TrainingsSummaryScreen extends StatefulWidget {
  @override
  _TrainingsSummaryScreenState createState() => _TrainingsSummaryScreenState();
}

class _TrainingsSummaryScreenState extends State<TrainingsSummaryScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> trainings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await supabase
          .from('trainings')
          .select()
          .eq('user_id', user.id);

      setState(() {
        trainings = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading trainings: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteTraining(String id) async {
    try {
      await supabase.from('trainings').delete().eq('id', id);

      setState(() {
        trainings.removeWhere((training) => training['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Training deleted'),
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

  // View training details
  void _viewTraining(Map<String, dynamic> training) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Training Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Training:', training['title'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow('Provider:', training['provider'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow('Start Date:', training['start_date'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Completion Date:',
                training['completion_date'] ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Certificate No:',
                training['certificate_number'] ?? 'N/A',
              ),
              const SizedBox(height: 12),
              if (training['certificate_url'] != null &&
                  training['certificate_url'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Certificate:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
        ],
      ),
    );
  }

  // Edit training dialog
  void _editTraining(Map<String, dynamic> training) {
    final trainingNameController = TextEditingController(
      text: training['title'],
    );
    final providerController = TextEditingController(
      text: training['provider'],
    );
    final startDateController = TextEditingController(
      text: training['start_date'],
    );
    final completionDateController = TextEditingController(
      text: training['completion_date'],
    );
    final certNumberController = TextEditingController(
      text: training['certificate_number'],
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Training',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: trainingNameController,
                  decoration: const InputDecoration(
                    labelText: 'Training Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: providerController,
                  decoration: const InputDecoration(
                    labelText: 'Provider',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: completionDateController,
                  decoration: const InputDecoration(
                    labelText: 'Completion Date',
                    border: OutlineInputBorder(),
                  ),
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
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await supabase
                      .from('trainings')
                      .update({
                        'title': trainingNameController.text.trim(),
                        'provider': providerController.text.trim(),
                        'start_date': startDateController.text.trim(),
                        'completion_date': completionDateController.text.trim(),
                        'certificate_number': certNumberController.text.trim(),
                      })
                      .eq('id', training['id']);

                  Navigator.pop(context);
                  _loadTrainings(); // Reload data

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Training updated successfully'),
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
                'Your Trainings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2D8F3C),
                      ),
                    )
                  : trainings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No trainings added yet',
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
                      itemCount: trainings.length,
                      itemBuilder: (context, index) {
                        final training = trainings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            onTap: () => _viewTraining(training),
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2D8F3C),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              training['title'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(training['provider'] ?? ''),
                                Text(
                                  'Completed: ${training['completion_date'] ?? 'N/A'}',
                                ),
                                if (training['certificate_number'] != null)
                                  Text(
                                    'Cert #: ${training['certificate_number']}',
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
                                  onPressed: () => _editTraining(training),
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
                                        title: const Text('Delete Training?'),
                                        content: const Text(
                                          'Are you sure you want to delete this training?',
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
                                              _deleteTraining(training['id']);
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompleteProfileScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D8F3C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
