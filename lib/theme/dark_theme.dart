import 'package:flutter/material.dart';
import 'app_colors.dart';

/// The one and only theme for Campus Marketplace right now.
///
/// WHY ColorScheme.fromSeed:
/// Instead of manually picking a color for every single UI element
/// (buttons, icons, selected states...), Flutter can generate a whole
/// harmonious set of colors from just ONE seed color. This is a Material 3
/// feature, and it's why widgets can ask for
/// `Theme.of(context).colorScheme.primary` and get something that always
/// looks correct alongside the rest of the app.
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.surface,
  dividerColor: AppColors.border,
  fontFamily: 'Roboto',
);