import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// ===============================================================
/// SHARED AUTH SCREEN PIECES
/// ===============================================================
///
/// WHY THIS FILE EXISTS:
/// Login and Signup both need the exact same decorative header and the
/// exact same Google/Facebook button row. Rather than writing that twice
/// (and having it drift out of sync when one gets tweaked), both widgets
/// live here and get imported into both pages.

/// The soft gradient header shown at the top of Login/Signup, echoing the
/// splash screen's "K" mark so the auth flow still feels like Kraze,
/// with a couple of small decorative dots for visual interest —
/// standing in for the reference design's illustration, using simple
/// original shapes rather than copying anyone else's artwork.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity, // <-- without this, the box shrinks to fit
      // just the "K" text and hugs the left edge instead of centering
      // across the available width.
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Small floating decorative dots, loosely echoing the little
          // doodles (stars/planet) in the reference design.
          // Positioned(
          //   top: 20,
          //   left: 40,
          //   child: _dot(colorScheme.primary.withValues(alpha: 0.4), 10),
          // ),
          // Positioned(
          //   top: 50,
          //   right: 50,
          //   child: _dot(AppColors.accentPrice.withValues(alpha: 0.35), 14),
          // ),
          // Positioned(
          //   bottom: 24,
          //   left: 70,
          //   child: _dot(colorScheme.primary.withValues(alpha: 0.25), 8),
          // ),

          // The gradient "K" mark, same technique as the splash screen.
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
                fontSize: 90,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// The "Or sign in/up with" divider line with text in the middle.
class AuthDivider extends StatelessWidget {
  final String label;
  const AuthDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor)),
      ],
    );
  }
}

/// Google + Facebook buttons, side by side.
///
/// WHY THESE STAY LIGHT/WHITE (even in a dark-themed app):
/// This intentionally does NOT follow AppColors — Google's own brand
/// guidelines expect their button to be shown on a light background, and
/// keeping "Sign in with Google" visually consistent with how it looks
/// in every other app makes it instantly recognizable to a first-time
/// user. Facebook's blue is its brand color for the same reason.
///
/// WHY THESE ARE PLACEHOLDERS RIGHT NOW:
/// Actually signing someone in with Google/Facebook requires Firebase
/// (the `firebase_auth` and `google_sign_in` packages, plus setting up a
/// real Firebase project with OAuth credentials in the Firebase Console —
/// steps only you can do, since they involve your own Google/Firebase
/// account). Tapping these currently shows what's still needed, the same
/// way Message Seller does until Chat exists.
class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            // NOTE: Icons.g_mobiledata is a generic Material icon (it's
            // actually meant for signal-strength indicators), NOT
            // Google's real "G" logo. Flutter's built-in icon set
            // doesn't include Google's official trademarked logo. If you
            // want the real one, add the `google_sign_in` package (which
            // has official branded button widgets) or the
            // `font_awesome_flutter` package for a closer "G" icon.
            label: 'Google',
            icon: Icons.g_mobiledata,
            onTap: () => _showComingSoon(context, 'Google'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            label: 'Facebook',
            icon: Icons.facebook,
            iconColor: const Color(0xFF1877F2), // Facebook brand blue
            onTap: () => _showComingSoon(context, 'Facebook'),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$provider sign-in needs Firebase set up first — coming soon!',
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: Icon(icon, color: iconColor ?? Colors.black87, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
