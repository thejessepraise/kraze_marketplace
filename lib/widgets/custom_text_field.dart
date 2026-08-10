import 'package:flutter/material.dart';

/// A reusable text input styled as a rounded "pill" — used across Login,
/// Signup, and any future form (Post Item, Edit Profile, etc).
///
/// WHY THIS IS ITS OWN WIDGET:
/// Login and Signup both need 2–4 fields that look and behave identically
/// (same border, same focus color, same password show/hide toggle). If we
/// built that styling directly inside login_page.dart, we'd have to
/// copy-paste it into signup_page.dart too — and any future form would
/// need it a third time. Building it once here means every form in the
/// app automatically looks consistent, and a style tweak only has to
/// happen in one place.
///
/// WHY StatefulWidget:
/// A password field needs to remember whether it's currently showing or
/// hiding the typed characters (the eye icon toggle) — that's state that
/// changes while the field is on screen, which is exactly what
/// StatefulWidget is for.
class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  /// How rounded the field's corners are. Defaults to a full "pill"
  /// shape (30) to match the reference design, but can be overridden for
  /// forms elsewhere in the app that want a less rounded look.
  final double borderRadius;

  /// How many lines tall the field is. Defaults to 1 (a single-line
  /// "pill" input, like Email/Password). Post Item's description field
  /// passes a higher number so students have room to actually write a
  /// few sentences instead of one long scrolling line.
  ///
  /// WHY NOT JUST HARDCODE maxLines: 1 HERE:
  /// A password field specifically must stay 1 line no matter what gets
  /// passed in — obscureText only works correctly on single-line fields —
  /// so that case is handled separately in build() below.
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.borderRadius = 30,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Password fields start hidden (obscured) — this is the current
  // show/hide state, toggled by tapping the eye icon.
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(widget.borderRadius);

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      // A password field must stay single-line regardless of what was
      // passed in, so obscureText keeps working correctly.
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: theme.cardColor,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: colorScheme.onSurfaceVariant)
            : null,
        // Only password fields get the eye toggle — a plain email field
        // has nothing to hide, so this stays null for those.
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
