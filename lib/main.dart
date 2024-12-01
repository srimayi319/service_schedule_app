import 'package:flutter/material.dart';
import 'screens/loginscreen.dart';
import 'screens/products_page.dart';
import 'screens/services_page.dart';
import 'screens/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900, // Primary seed color
          brightness: Brightness.light,
        ),
        useMaterial3: true, // Optional for Material 3 style
      ),
      debugShowCheckedModeBanner: false, // Hides debug banner
      initialRoute: '/', // Set initial route
      routes: {
        '/': (context) => const LoginPage(), // Login Page
        '/products': (context) => const ProductsPage(), // Products Page
        '/services': (context) => ServicePage(), // Services Page
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
