import 'package:flutter/material.dart';

import '../models/product.dart';
import '../pages/product_detail/product_detail_page.dart';
import '../services/marketplace_store.dart';
import 'kraze_page_route.dart';
import 'product_card.dart';

/// A reusable, scrollable grid of ProductCards, with the standard
/// "tap a card -> open Product Detail" and "tap the heart -> add to
/// favorites" behavior already wired up.
///
/// WHY THIS WIDGET EXISTS:
/// Home's "Recent Listings" grid and the Search Results grid need to
/// behave IDENTICALLY — same card layout, same tap-to-detail navigation,
/// same favorite-tap placeholder. This used to live directly inside
/// home_page.dart; pulling it out here means Search can reuse the exact
/// same behavior instead of copy-pasting ~40 lines of SliverGrid code,
/// and a future change (like wiring in a real favorites_service.dart)
/// only needs to happen in ONE place instead of two.
///
/// WHY THIS IS A SLIVER (SliverGrid), NOT A PLAIN GridView:
/// Both Home and Search scroll their grid alongside other content (a
/// header, a search bar, category chips) inside a single
/// CustomScrollView. Slivers are the pieces CustomScrollView is built
/// out of — a plain GridView can't share one scroll position with the
/// content around it.
class ProductGridSliver extends StatelessWidget {
  final List<Product> products;
  final String emptyMessage;

  /// Optional icon shown above the empty message (e.g. a heart outline
  /// for Favorites). Screens that don't pass one just get the message,
  /// so this stays backward-compatible with existing callers.
  final IconData? emptyIcon;

  const ProductGridSliver({
    super.key,
    required this.products,
    this.emptyMessage = 'No items found.',
    this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (emptyIcon != null) ...[
                  Icon(
                    emptyIcon,
                    size: 40,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cards per row
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.72, // controls card width-to-height ratio
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.of(context).push(
                KrazePageRoute(
                  builder: (_) => ProductDetailPage(
                    product: product,
                  ),
                ),
              );
            },
            onFavoriteTap: () => _toggleFavorite(context, product),
          );
        }, childCount: products.length),
      ),
    );
  }

  void _toggleFavorite(BuildContext context, Product product) {
    marketplaceStore.toggleFavorite(product.id);
    final isNowFavorite = marketplaceStore.products
        .firstWhere((item) => item.id == product.id)
        .isFavorite;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
      ),
    );
  }
}
