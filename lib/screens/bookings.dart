import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetching services from Firestore
  Future<List<Map<String, dynamic>>> _getServices() async {
    final snapshot = await _firestore.collection('service_schedules').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Showing feedback form for a completed service
  void _showFeedbackForm(BuildContext context, String serviceId) {
    final TextEditingController feedbackController = TextEditingController();
    int rating = 5; // Default rating value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Provide Feedback'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rating selection (you can use a widget like star_rating or a slider)
              Text('Rating: $rating'),
              Slider(
                min: 1,
                max: 5,
                value: rating.toDouble(),
                divisions: 4,
                onChanged: (value) {
                  setState(() {
                    rating = value.toInt();
                  });
                },
              ),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  hintText: 'Enter your feedback here',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Submit feedback to Firestore
                await _firestore.collection('service_schedules').doc(serviceId).update({
                  'feedback': feedbackController.text,
                  'rating': rating,
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted successfully!')),
                );
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Services"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final services = snapshot.data ?? [];

          // Separate pending and completed services
          final pendingServices = services.where((service) => service['status'] == 'pending').toList();
          final completedServices = services.where((service) => service['status'] == 'completed').toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pending Services Section
                  const Text(
                    'Pending Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (pendingServices.isEmpty)
                    const Text('No pending services.')
                  else
                    ...pendingServices.map((service) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Service scheduled for: ${service['date']}'),
                          subtitle: Text('Status: ${service['status']}'),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 20),

                  // Completed Services Section
                  const Text(
                    'Completed Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (completedServices.isEmpty)
                    const Text('No completed services.')
                  else
                    ...completedServices.map((service) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Completed on: ${service['date']}'),
                          subtitle: Text('Feedback: ${service['feedback'] ?? 'No feedback yet'}'),
                          trailing: service['feedback'] == null
                              ? IconButton(
                            icon: const Icon(Icons.feedback),
                            onPressed: () {
                              _showFeedbackForm(context, service['serviceId']);
                            },
                          )
                              : null,
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}