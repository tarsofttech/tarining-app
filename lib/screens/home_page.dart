import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'todo_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  final String username;
  final String email;

  const HomePage({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _messageShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messageShown) return;
    _messageShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            tooltip: 'Todos',
            onPressed: () {
              Navigator.pushNamed(context, TodoPage.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F7FB),
              Color(0xFFEEF1F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 168,
                    height: 168,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDDE3F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 24,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'asset/todo.svg',
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(color: kPrimary),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome, ${widget.username}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: kTextMuted,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      onPressed: _logout,
                      child: const Text('Log Out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
