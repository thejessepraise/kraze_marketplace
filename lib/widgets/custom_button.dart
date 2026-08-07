import 'package:flutter/material.dart';

/// The app's primary filled button — used for "Sign In", "Register", and
/// any future primary form action.
///
/// WHY isLoading (rather than just disabling the button):
/// When Login/Signup eventually call a real backend (Firebase), that
/// network request takes a moment. Showing a small spinner INSIDE the
/// button (instead of the label) gives clear feedback that something is
/// happening, and `onPressed: isLoading ? null : onPressed` stops the
/// user from tapping "Sign In" five times while the first request is
/// still in flight.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        // Disabling the button while loading prevents duplicate taps.
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.onPrimary,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
