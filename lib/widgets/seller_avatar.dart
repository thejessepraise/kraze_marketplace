import 'package:flutter/material.dart';

/// Consistent seller-identity avatar: initials on a tinted circle — the
/// same visual language as the person avatar on Profile.
///
/// Shared by Messages (conversation list) and Chat (app bar) so the
/// same seller always renders identically in both places.
class SellerAvatar extends StatelessWidget {
  const SellerAvatar({super.key, required this.name, this.radius = 24});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.65,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
