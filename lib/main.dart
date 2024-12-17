import 'dart:async';
import 'package:flutter/material.dart';
import 'auth/loginscreen.dart';
import 'screens/products_page.dart';
import 'screens/bookings.dart';
import 'screens/services_page.dart';
import 'screens/profile_page.dart';
import 'screens/homepage.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set initial route
      routes: {
        '/': (context) => const LoginScreen(), // Login Page

        '/home':(context) =>  HomePage(),
        '/products': (context) => const ProductsPage(), // Products Page
        '/services': (context) => ServicePage(), // Services Page
        '/profile': (context) => const ProfilePage(),
        '/bookings':(context)=> const BookingsPage(),
      },
    );
  }
}
