import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile.dart';
import '../../services/app_error.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_store.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/kraze_page_route.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/product_image.dart';
import '../auth/login_page.dart';

// AppGradients (brand gradient) lives in app_text_styles.dart alongside
// AppTextStyles — already imported above.

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = marketplaceStore.myProducts;
    final profile = marketplaceStore.currentProfile;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _profileHeader(context, listings.length, profile),
        ),
        SliverToBoxAdapter(child: _profileActions(context, profile)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Text('My Listings', style: AppTextStyles.sectionTitle),
          ),
        ),
        ProductGridSliver(
          products: listings,
          emptyIcon: Icons.storefront_outlined,
          emptyMessage: 'You have not posted any listings yet.',
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 90)),
      ],
    );
  }

  Widget _profileHeader(
    BuildContext context,
    int listingCount,
    UserProfile? profile,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = profile?.name.trim();
    final displayName = (name == null || name.isEmpty)
        ? (FirebaseAuth.instance.currentUser?.email ?? 'Student')
        : name;
    final photoUrl = profile?.photoUrl ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          // A thin brand-gradient ring gives the avatar a bit of
          // identity. Tapping it lets a student pick a new photo,
          // which gets uploaded to Firebase Storage.
          GestureDetector(
            onTap: () => _changeAvatar(context),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.brand,
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: colorScheme.surface,
                child: ClipOval(
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: photoUrl.isEmpty
                        ? CircleAvatar(
                            radius: 39,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: colorScheme.primary,
                            ),
                          )
                        : ProductImage(imagePath: photoUrl),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Campus Marketplace Member',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _statCard(context, '$listingCount', 'Listings')),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  context,
                  '${marketplaceStore.favoriteProducts.length}',
                  'Favorites',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _changeAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 60,
    );
    if (picked == null) return;

    try {
      await marketplaceStore.uploadAvatar(picked);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(error))));
    }
  }

  Widget _statCard(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileActions(BuildContext context, UserProfile? profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          _actionTile(
            context,
            icon: Icons.edit_outlined,
            label: 'Edit profile',
            onTap: () => _showEditProfileSheet(context, profile),
          ),
          const SizedBox(height: 10),
          _actionTile(
            context,
            icon: Icons.logout,
            label: 'Log out',
            isDestructive: true,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      KrazePageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Future<void> _showEditProfileSheet(BuildContext context, UserProfile? profile) {
    final nameController = TextEditingController(
      text: profile?.name ?? '',
    );
    final phoneController = TextEditingController(
      text: profile?.phone ?? '',
    );

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 20),
              CustomTextField(
                hint: 'Full Name',
                controller: nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                hint: 'Phone Number',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: 'Save',
                onPressed: () async {
                  try {
                    await marketplaceStore.updateProfile(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                    );
                  } catch (error) {
                    if (!sheetContext.mounted) return;
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(content: Text(userMessage(error))),
                    );
                    return;
                  }
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isDestructive ? Colors.redAccent : colorScheme.onSurface;
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
