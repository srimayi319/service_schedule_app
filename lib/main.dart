import 'dart:async';
import 'package:flutter/material.dart';
import '/auth/loginscreen.dart';
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
        home: LoginScreen());
  }
}
