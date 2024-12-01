import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout action (e.g., navigating back to LoginPage)
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message or user information
            Text(
              'Welcome to Sri Sai Ganesh Marketing!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // Quick Actions or Key Functionalities
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.build_circle_outlined,
                    label: 'Request Service',
                    onTap: () {
                      Navigator.pushNamed(context, '/services');
                    },
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.local_offer_outlined,
                    label: 'Our Products',
                    onTap: () {
                      Navigator.pushNamed(context, '/products');
                    },
                  ),
                ],
              ),
            ),

            // Footer with home, profile, and bookings icons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: Colors.blue.shade800, // Navy Blue color
                    ),
                    onPressed: () {
                      // Navigate to Home
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Already on Home Page!')),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      color: Colors.blue.shade800, // Navy Blue color
                    ),
                    onPressed: () {
                      // Navigate to ProfilePage
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.book,
                      color: Colors.blue.shade800, // Navy Blue color
                    ),
                    onPressed: () {
                      // Placeholder: Navigate to My Bookings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bookings Page Coming Soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 90,
              color: Colors.blue.shade800, // Navy Blue color
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
