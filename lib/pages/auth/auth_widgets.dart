import 'package:flutter/material.dart';

/// ===============================================================
/// SHARED AUTH SCREEN PIECES
/// ===============================================================
///
/// WHY THIS FILE EXISTS:
/// Login and Signup both need the exact same "Or sign in/up with" divider
/// and the exact same Google/Facebook button row. Rather than writing
/// that twice (and having it drift out of sync when one gets tweaked),
/// both widgets live here and get imported into both pages.

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: Icon(icon, color: iconColor ?? Colors.black87, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
