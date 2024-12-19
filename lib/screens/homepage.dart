import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasNewNotifications = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _listenForScheduledServices();
  }

  // Listen for changes in scheduled services for the current user
  void _listenForScheduledServices() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore
          .collection('service_schedules')
          .where('userId', isEqualTo: user.uid) // Filter by user ID
          .snapshots()
          .listen((snapshot) {
        final scheduledServices = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'date': data['date'] as Timestamp,
            'service': data['service'] as String,
          };
        }).toList();

        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final notifications = scheduledServices.where((service) {
          final serviceDate = (service['date'] as Timestamp).toDate();
          return DateFormat('yyyy-MM-dd').format(serviceDate) ==
              DateFormat('yyyy-MM-dd').format(tomorrow);
        }).toList();

        setState(() {
          hasNewNotifications = notifications.isNotEmpty;
        });
      });
    }
  }

  // Show notification for upcoming scheduled services
  Future<void> _checkForNotifications(BuildContext context) async {
    try {
      // Fetch scheduled services from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('scheduled_services')
          .where('date',
          isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
          .orderBy('date')
          .get();

      // Extract data from the fetched services
      final List<Map<String, dynamic>> notifications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'date': DateTime.parse(data['date']),
          'service': data['service'],
        };
      }).toList();

      if (notifications.isNotEmpty) {
        _showNotificationDialog(context, notifications);
      } else {
        // Show no upcoming services message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No upcoming scheduled services.')),
        );
      }
    } catch (e) {
      // Handle errors (e.g., Firestore access issues)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking notifications: $e')),
      );
    }
  }

  // Function to show notification dialog with option to cancel the service
  void _showNotificationDialog(
      BuildContext context, List<Map<String, dynamic>> notifications) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upcoming Scheduled Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var notification in notifications)
                ListTile(
                  title: Text('Service: ${notification['service']}'),
                  subtitle: Text('Scheduled on: ${DateFormat('yyyy-MM-dd').format(notification['date'])}'),

                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to cancel the scheduled service


  // Logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout'),
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
        title: const Text("Home"),
        actions: [
          // Notification icon with a red dot for new notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Colors.black,
                onPressed: () {
                  _checkForNotifications(context);
                },
              ),
              if (hasNewNotifications)
                Positioned(
                  right: 10,
                  top: 15,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Text(
                  'Welcome to Sri Sai Ganesh Marketing!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 60),

                // Quick Actions or Key Functionalities (Service Request, Products)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: _buildFeatureCard(
                        context: context,
                        icon: Icons.local_offer_outlined,
                        label: 'Our Products',
                        onTap: () {
                          Navigator.pushNamed(context, '/products');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: _buildFeatureCard(
                        context: context,
                        icon: Icons.build_circle_outlined,
                        label: 'Request Service',
                        onTap: () {
                          Navigator.pushNamed(context, '/services');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Firestore Viewer Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: _buildFeatureCard(
                        context: context,
                        icon: Icons.view_list,
                        label: 'View Firestore Data',
                        onTap: () {
                          Navigator.pushNamed(context, '/firestore');
                        },
                      ),
                    ),
                  ],
                ),

                // Footer with home, profile, and bookings icons
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFooterIcon(
                        icon: Icons.home,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Already on Home Page!')),
                          );
                        },
                      ),
                      _buildFooterIcon(
                        icon: Icons.person,
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      _buildFooterIcon(
                        icon: Icons.book,
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/bookings'); // Navigate to Bookings page
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  // Create the feature card for actions (Request Service, Our Products)
  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: Colors.blue.shade800,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Footer icon with padding and increased size for better tap area
  Widget _buildFooterIcon({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 32),
      onPressed: onPressed,
      padding: const EdgeInsets.all(16.0),
    );
  }
}
