import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CriptaGamerApp());
}

class CriptaGamerApp extends StatelessWidget {
  const CriptaGamerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Cripta Gamer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        fontFamily: 'Segoe UI',
      ),
      home: const LoginScreen(),
    );
  }
}