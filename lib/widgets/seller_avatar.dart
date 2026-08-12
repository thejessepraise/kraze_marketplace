import 'package:flutter/material.dart';
import '../services/marketplace_store.dart';
import '../models/user_profile.dart';
import 'product_image.dart';

/// Consistent seller-identity avatar: shows the profile photo if available,
/// otherwise falls back to initials on a tinted circle.
class SellerAvatar extends StatelessWidget {
  const SellerAvatar({
    super.key,
    required this.name,
    this.uid,
    this.radius = 24,
  });

  final String name;
  final String? uid;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (uid == null || uid!.isEmpty) {
      return _buildFallback(colorScheme);
    }

    return FutureBuilder<UserProfile?>(
      future: marketplaceStore.getUserProfile(uid!),
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?.photoUrl;
        if (photoUrl != null && photoUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: colorScheme.surface,
            child: ClipOval(
              child: SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: ProductImage(imagePath: photoUrl),
              ),
            ),
          );
        }
        return _buildFallback(colorScheme);
      },
    );
  }

  Widget _buildFallback(ColorScheme colorScheme) {
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
