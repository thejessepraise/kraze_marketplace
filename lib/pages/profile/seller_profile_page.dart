import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/marketplace_store.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/seller_avatar.dart';

class SellerProfilePage extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  const SellerProfilePage({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    final listings = marketplaceStore.getProductsBySeller(sellerId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$sellerName\'s Profile'),
      ),
      body: FutureBuilder<UserProfile?>(
        future: marketplaceStore.getUserProfile(sellerId),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _profileHeader(context, listings.length, profile),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Text('Seller Listings', style: AppTextStyles.sectionTitle),
                ),
              ),
              ProductGridSliver(
                products: listings,
                emptyIcon: Icons.storefront_outlined,
                emptyMessage: 'This seller has no other active listings.',
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _profileHeader(
    BuildContext context,
    int listingCount,
    UserProfile? profile,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.brand,
            ),
            child: SellerAvatar(
              name: profile?.name ?? sellerName,
              uid: sellerId,
              radius: 42,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile?.name ?? sellerName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (profile?.location != null && profile!.location.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Campus Marketplace Seller',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _statCard(context, '$listingCount', 'Listings')),
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
}
