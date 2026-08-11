import 'package:flutter/material.dart';

import '../models/product.dart';
import '../pages/product_detail/product_detail_page.dart';
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

  const ProductGridSliver({
    super.key,
    required this.products,
    this.emptyMessage = 'No items found.',
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(
                    product: product,
                    onFavoriteTap: () => _showFavoriteSnack(context),
                  ),
                ),
              );
            },
            onFavoriteTap: () => _showFavoriteSnack(context),
          );
        }, childCount: products.length),
      ),
    );
  }

  void _showFavoriteSnack(BuildContext context) {
    // Will call favorites_service.dart once that exists.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to favorites')),
    );
  }
}
