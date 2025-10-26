import 'package:flutter/material.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Certificate"),
        backgroundColor: Colors.green,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Certificate Image Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/certificate.png", // <- place image in assets folder
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Certificate Details
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("COMPLETED BY",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 4),
                    Text("JOHN JAMESON DOE",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Divider(),

                    Text("ISSUE DATE",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 4),
                    Text("SEP 05, 2025",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Divider(),

                    Text("TOTAL HOURS",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 4),
                    Text("6",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Divider(),

                    Text("About Course",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      "Learn the fundamentals of software development, including programming, software design, and version control",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  "Download",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  // Add your download logic here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
