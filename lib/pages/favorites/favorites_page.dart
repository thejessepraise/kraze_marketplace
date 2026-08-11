import 'package:flutter/material.dart';

import '../../services/marketplace_store.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/product_grid.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final favorites = marketplaceStore.favoriteProducts;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text('Favorites', style: AppTextStyles.pageTitle),
                ),
                // A small saved-count gives the header a bit of life
                // without inventing a "meaningless statistic" — it's a
                // real, useful number (how many items are saved).
                if (favorites.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${favorites.length} saved',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Text(
              'Your saved listings, all in one place.',
              style: AppTextStyles.pageSubtitle.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        ProductGridSliver(
          products: favorites,
          emptyIcon: Icons.favorite_border,
          emptyMessage:
              'No favorites yet.\nTap the heart on a listing to save it here.',
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 90)),
      ],
    );
  }
}
