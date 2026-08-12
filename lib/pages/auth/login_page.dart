import 'package:flutter/material.dart';

import '../../services/app_error.dart';
import '../../services/auth_service.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/kraze_page_route.dart';
import '../home/home_page.dart';
import 'auth_widgets.dart';
import 'signup_page.dart';

/// The Login screen — a returning student signs back in.
///
/// WHY StatefulWidget:
/// This screen owns TextEditingControllers (which hold what the user has
/// typed) and a loading flag (whether we're currently "logging in"),
/// both of which change while the screen is open — exactly what State
/// objects are for.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // A Form widget needs a GlobalKey so we can ask it later "is everything
  // valid?" (_formKey.currentState!.validate()) before submitting.
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    // Controllers hold onto memory/resources until explicitly disposed.
    // Forgetting this is a common source of memory leaks in real apps.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // validate() runs every field's `validator` function. If any of them
    // return an error message, this returns false and the errors appear
    // under the fields automatically — we don't have to do anything else.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(error))));
      return;
    }

    // Guard against the screen having been closed during the request
    // (e.g. the user backed out) before touching it again.
    if (!mounted) return;

    setState(() => _isLoading = false);

    // pushAndRemoveUntil clears Splash/Login/Signup off the navigation
    // stack entirely, replacing them with Home. This means the phone's
    // back button from Home exits the app rather than returning to the
    // login screen — the correct behavior once someone is "logged in".
    Navigator.of(context).pushAndRemoveUntil(
      KrazePageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        // Student closed the account picker — not an error.
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(error))));
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushAndRemoveUntil(
      KrazePageRoute(builder: (_) => const HomePage()),
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
          // Center + ConstrainedBox caps how wide the form can get. On a
          // phone screen (narrower than 480), this has no visible effect
          // — content just uses the available width like before. On a
          // wide desktop/web window, it stops the pill fields and button
          // from stretching edge-to-edge across the whole screen, and
          // centers a sensible-width "card" instead — the same fix
          // pattern used for Product Detail's wide layout.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    // A single, restrained brand touch — not the full
                    // Splash treatment, just enough that Login still
                    // reads as unmistakably Kraze.
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.brand.createShader(bounds),
                      child: const Text(
                        'K',
                        style: TextStyle(
                          fontFamily: 'Glitch',
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome Back',
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
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              KrazePageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
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
                      hint: 'Enter Password',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 14),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Forgot Password page coming soon'),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const AuthDivider(label: 'Or sign in with'),
                    const SizedBox(height: 20),
                    SocialSignInRow(onGooglePressed: _handleGoogleSignIn),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
