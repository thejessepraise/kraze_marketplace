import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/kraze_page_route.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';

/// The very first screen a student sees when the app launches — shows the
/// Kraze logo/branding briefly, then moves on to the next screen.
///
/// WHY THIS SCREEN EXISTS (beyond just looking nice):
/// A splash screen isn't just decoration — it's normally where an app
/// does a bit of quick setup work before deciding where to send the user:
/// checking "is this student already logged in?", loading saved settings,
/// etc.
///
/// WHERE THE STUDENT GOES NEXT:
/// Splash checks FirebaseAuth.instance.currentUser once the 2-second
/// delay ends. Firebase Auth persists sessions across app restarts on
/// its own, so a previously-signed-in student goes straight to Home;
/// anyone else lands on Login.
///
/// WHY StatefulWidget:
/// This screen needs to run some code automatically the moment it
/// appears (start a timer, then navigate away) — that kind of "do
/// something once when this screen is first shown" logic belongs in
/// initState(), which only exists on State objects, which is why this
/// has to be a StatefulWidget rather than a StatelessWidget.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // initState() runs exactly once, right when this screen is first
    // created — the correct place to kick off a one-time timer like this,
    // rather than in build() (which can run many times).
    _goToNextScreen();
  }

  Future<void> _goToNextScreen() async {
    // Keeps the splash screen visible for 2 seconds. Future.delayed
    // pauses this function (not the whole app) for that long before
    // continuing to the next line.
    await Future.delayed(const Duration(seconds: 2));

    // `mounted` checks that this screen is still on screen before we try
    // to navigate. WHY THIS CHECK MATTERS: if the user somehow left this
    // screen during the 2-second delay (rare, but possible), calling
    // Navigator on a screen that's already gone would crash the app.
    if (!mounted) return;

    // Firebase Auth persists the session across app restarts on its
    // own — currentUser is already restored by the time this runs
    // (Firebase.initializeApp() in main.dart finished before runApp).
    // A signed-in student skips Login entirely; everyone else sees it.
    final isSignedIn = FirebaseAuth.instance.currentUser != null;

    // pushReplacement (not push) swaps Splash out entirely, rather than
    // stacking the next screen on top of it. This means pressing the
    // phone's back button won't take the student back to the splash
    // screen — exactly what you want, since there's nothing useful to
    // go "back" to on a splash screen.
    Navigator.of(context).pushReplacement(
      KrazePageRoute(
        builder: (_) => isSignedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // =========================================================
            // THE "K" MARK
            // =========================================================
            //
            // WHY ShaderMask (instead of just a colored Text widget):
            // A normal Text widget can only be ONE solid color. ShaderMask
            // lets us paint a gradient (two colors blending into each
            // other) THROUGH the shape of the letter "K" itself — which
            // is what gives it that rich, branded look instead of flat
            // text. The gradient uses your existing theme colors
            // (AppColors.primary → AppColors.accentPrice), so it's
            // unmistakably Kraze's palette, not a copy of anyone else's
            // brand colors.
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.accentPrice],
                ).createShader(bounds);
              },
              child: const Text(
                'K',
                style: TextStyle(
                  fontFamily: 'Glitch',
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                  // The actual color here doesn't matter — ShaderMask
                  // replaces it with the gradient above. It just needs
                  // to be opaque (not transparent) for the gradient to
                  // show through correctly.
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'KRAZE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 6, // spreads the letters apart
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'STUDENT MARKETPLACE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
