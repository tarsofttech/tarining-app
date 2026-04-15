import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../services/storage_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final token = await StorageService.getAuthToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(
            username: 'User',
            email: 'No email provided',
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, LoginPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_rounded, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'To-Do App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Stay on top of your tasks',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
