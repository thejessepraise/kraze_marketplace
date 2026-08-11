import 'package:flutter/material.dart';

import '../../services/marketplace_store.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/kraze_page_route.dart';
import '../../widgets/product_grid.dart';
import '../auth/login_page.dart';

// AppGradients (brand gradient) lives in app_text_styles.dart alongside
// AppTextStyles — already imported above.

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = marketplaceStore.myProducts;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _profileHeader(context, listings.length)),
        SliverToBoxAdapter(child: _profileActions(context)),
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

  Widget _profileHeader(BuildContext context, int listingCount) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          // A thin brand-gradient ring gives the avatar a bit of
          // identity without pulling in a full photo/edit flow yet.
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.brand,
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: colorScheme.surface,
              child: CircleAvatar(
                radius: 39,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.person, size: 40, color: colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'JessePraise.',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

  Widget _profileActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          _actionTile(
            context,
            icon: Icons.edit_outlined,
            label: 'Edit profile',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile editing will be added with account storage.'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _actionTile(
            context,
            icon: Icons.logout,
            label: 'Log out',
            isDestructive: true,
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              KrazePageRoute(builder: (_) => const LoginPage()),
              (_) => false,
            ),
          ),
        ],
      ),
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
