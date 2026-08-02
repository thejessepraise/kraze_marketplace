import 'package:flutter/material.dart';

/// The bottom navigation bar: Home, Favorites, Sell (center, highlighted),
/// Chat, Profile.
///
/// WHY BUILD A CUSTOM ONE INSTEAD OF FLUTTER'S BottomNavigationBar:
/// Flutter's built-in BottomNavigationBar can't easily make one middle
/// button visually "pop out" in a different color/shape — which is a very
/// common marketplace-app pattern for the "Sell" action, since posting an
/// item is the app's most important action. Building it ourselves with a
/// Row gives us full control over that center button's style.
///
/// NOTE ON COLORS:
/// The helper methods below take `BuildContext` as a parameter so they can
/// call Theme.of(context) to read colors from theme/dark_theme.dart,
/// rather than typing color values directly in this file.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      // SafeArea keeps icons above the phone's home indicator/gesture bar.
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navIcon(context, icon: Icons.home_outlined, index: 0),
            _navIcon(context, icon: Icons.favorite_border, index: 1),
            _sellButton(context),
            _navIcon(context, icon: Icons.chat_bubble_outline, index: 3),
            _navIcon(context, icon: Icons.person_outline, index: 4),
          ],
        ),
      ),
    );
  }

  /// A single regular nav icon. Turns the theme's primary color when it's
  /// the selected tab, and a muted grey (from the active theme) otherwise.
  Widget _navIcon(
    BuildContext context, {
    required IconData icon,
    required int index,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool selected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        size: 26,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// The special center "Sell" button — a filled circle that stands out
  /// from the other icons, since posting an item is the app's key action.
  Widget _sellButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        // onPrimary = whatever color reads clearly on top of "primary" in
        // THIS theme — Material 3 works this out for us.
        child: Icon(Icons.add, color: colorScheme.onPrimary, size: 26),
      ),
    );
  }
}