import 'package:flutter/material.dart';
import '../services/marketplace_store.dart';
import '../models/user_profile.dart';
import 'product_image.dart';

/// Consistent seller-identity avatar: shows the profile photo if available,
/// otherwise falls back to initials on a tinted circle.
/// 
/// Uses a StatefulWidget to keep the profile Future stable across parent rebuilds,
/// preventing the "flicker" effect.
class SellerAvatar extends StatefulWidget {
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
  State<SellerAvatar> createState() => _SellerAvatarState();
}

class _SellerAvatarState extends State<SellerAvatar> {
  Future<UserProfile?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _initFuture();
  }

  @override
  void didUpdateWidget(SellerAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _initFuture();
    }
  }

  void _initFuture() {
    if (widget.uid != null && widget.uid!.isNotEmpty) {
      _profileFuture = marketplaceStore.getUserProfile(widget.uid!);
    } else {
      _profileFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.uid == null || widget.uid!.isEmpty) {
      return _buildFallback(colorScheme);
    }

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        // Use the connectionState to decide if we should show a skeleton or fallback
        // but if we have data from a previous load or cache, use it immediately.
        final profile = snapshot.data;
        final photoUrl = profile?.photoUrl;
        final isOnline = profile?.isOnline ?? false;

        return Stack(
          children: [
            CircleAvatar(
              radius: widget.radius,
              backgroundColor: colorScheme.surface,
              child: ClipOval(
                child: SizedBox(
                  width: widget.radius * 2,
                  height: widget.radius * 2,
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? ProductImage(imagePath: photoUrl)
                      : _buildFallbackContent(colorScheme),
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: widget.radius * 0.5,
                  height: widget.radius * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFallbackContent(ColorScheme colorScheme) {
    final initial = widget.name.trim().isNotEmpty ? widget.name.trim()[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: widget.radius * 0.65,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildFallback(ColorScheme colorScheme) {
    final initial = widget.name.trim().isNotEmpty ? widget.name.trim()[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: widget.radius * 0.65,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
