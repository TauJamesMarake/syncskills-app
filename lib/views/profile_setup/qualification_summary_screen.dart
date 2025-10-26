import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/profile_setup/skills_selection_screen.dart';

class QualificationSummaryScreen extends StatefulWidget {
  @override
  _QualificationSummaryScreenState createState() =>
      _QualificationSummaryScreenState();
}

class _QualificationSummaryScreenState
    extends State<QualificationSummaryScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> qualifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQualifications();
  }

  Future<void> _loadQualifications() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await supabase
          .from('qualifications')
          .select()
          .eq('user_id', user.id);

      setState(() {
        qualifications = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading qualifications: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteQualification(String id) async {
    try {
      await supabase.from('qualifications').delete().eq('id', id);

      setState(() {
        qualifications.removeWhere((q) => q['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Qualification deleted'),
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

  // View qualification details in dialog
  void _viewQualification(Map<String, dynamic> qual) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Qualification Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Center(
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
                  'Certificate Number:',
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

  // Edit qualification dialog
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
                'Your Qualifications',
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
                  : qualifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No qualifications added yet',
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
                      itemCount: qualifications.length,
                      itemBuilder: (context, index) {
                        final qual = qualifications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            onTap: () => _viewQualification(qual),
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
                              qual['title'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(qual['institution'] ?? ''),
                                Text(
                                  'Year: ${qual['year_completed'] ?? 'N/A'}',
                                ),
                                if (qual['certificate_number'] != null)
                                  Text('Cert #: ${qual['certificate_number']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit button
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => _editQualification(qual),
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
                                        title: const Text(
                                          'Delete Qualification?',
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this qualification?',
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
                                              _deleteQualification(qual['id']);
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
                      builder: (context) => SkillSelectionScreen(),
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
