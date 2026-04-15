import 'package:flutter/material.dart';

import '../main.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  final String? prefilledName;
  final String? prefilledEmail;

  const LoginPage({
    super.key,
    this.prefilledName,
    this.prefilledEmail,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String get _prefilledName {
    final name = widget.prefilledName?.trim();
    if (name == null || name.isEmpty) return 'User';
    return name;
  }

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null && widget.prefilledEmail!.trim().isNotEmpty) {
      _emailController.text = widget.prefilledEmail!.trim();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          username: _prefilledName,
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  Future<void> _goToRegister() async {
    final result = await Navigator.pushNamed(context, RegisterPage.routeName);
    if (!mounted || result is! Map<String, String>) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          prefilledName: result['name'],
          prefilledEmail: result['email'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Icon(
                  Icons.lock_open_rounded,
                  size: 68,
                  color: kPrimary,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back, $_prefilledName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: kTextMuted,
                  ),
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _goToRegister,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: kPrimary),
                    foregroundColor: kPrimary,
                  ),
                  child: const Text('Create an Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text('Log In'),
      ),
    );
  }
}
