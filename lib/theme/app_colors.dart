import 'package:flutter/material.dart';

/// The app's color palette.
///
/// WHY THIS FILE EXISTS:
/// Keeping every color as a named constant, in ONE file, means if you ever
/// want to change your brand color, you edit it here once instead of
/// hunting through every screen.
class AppColors {
  static const primary = Color.fromARGB(255, 178, 93, 195); // lightened for contrast on dark
  static const accentPrice = Color.fromARGB(255, 224, 42, 218); // used for prices

  // Note: dark backgrounds should NOT be pure black (#000000) — a very
  // dark grey is easier on the eyes and is Google's own Material Design
  // recommendation for dark surfaces.
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E); // cards, search bar, etc.
  static const border = Color(0xFF2C2C2E);
}