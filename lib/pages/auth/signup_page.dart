import 'package:flutter/material.dart';

import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../home/home_page.dart';
import 'auth_widgets.dart';

/// The Signup screen — a new student creates an account.
///
/// See login_page.dart for detailed comments on the overall pattern
/// (Form + GlobalKey validation, StatefulWidget for controllers/loading,
/// pushAndRemoveUntil on success) — this page follows the same approach.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // WHERE REAL AUTH GOES:
    // await authService.signUp(name, email, password);
    // once services/auth_service.dart and Firebase exist.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Same as Login: clear the whole auth stack so Home is the new
    // "root" the back button respects.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(),
                const SizedBox(height: 8),
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      // pop() (not push) — Signup was reached BY pushing
                      // from Login, so popping just returns to that
                      // existing Login screen rather than creating a
                      // second one on top of it.
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                CustomTextField(
                  hint: 'Full Name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Create Password',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Re-enter Password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Re-enter your password';
                    }
                    // Compares against the OTHER controller's current
                    // text — this is why both fields need their own
                    // TextEditingController rather than sharing one.
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                CustomButton(
                  label: 'Register',
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: 20),

                const AuthDivider(label: 'Or sign up with'),
                const SizedBox(height: 20),
                const SocialSignInRow(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
