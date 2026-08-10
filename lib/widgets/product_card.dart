import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import 'product_image.dart';

/// Displays one product inside a grid.
///
/// This widget is responsible for showing:
/// - Image placeholder (later replaced with real product photos)
/// - Product title
/// - Price
/// - Seller name
/// - Favorite (heart) button
///
/// WHY A SEPARATE WIDGET?
/// Instead of writing this layout directly inside home_page.dart,
/// we build it once here and reuse it anywhere products are shown
/// (Home, Search, Favorites, etc.).
///
/// If you ever redesign the product card, you'll only need to edit
/// this file instead of changing multiple pages.
class ProductCard extends StatelessWidget {
  final Product product;

  /// Runs when the entire card is tapped.
  /// Example: Open the product details page.
  final VoidCallback? onTap;

  /// Runs when only the heart icon is tapped.
  final VoidCallback? onFavoriteTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Getting these once makes the code below cleaner than repeatedly
    // writing Theme.of(context) everywhere.
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // GestureDetector allows the entire card to respond to taps.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // The card color comes from the app theme, so changing the
          // theme automatically changes every ProductCard.
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),

        // Column stacks widgets vertically.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // IMAGE AREA
            // ==========================================================
            //
            // Expanded tells Flutter:
            // "Take up all the remaining vertical space."
            //
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                // ProductImage handles both bundled assets/images/... paths
                // AND device file paths (from a student's own photo picked
                // in Post Item) — see widgets/product_image.dart.
                child: SizedBox(
                  width: double.infinity,
                  child: ProductImage(imagePath: product.imageUrl),
                ),
              ),
            ),
            // ==========================================================
            // PRODUCT INFORMATION
            // ==========================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- Product Title ----------------
                  Text(
                    product.title,

                    // Prevents very long titles from overflowing.
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ---------------- Price ----------------
                  Text(
                    'GH₵${product.price.toStringAsFixed(2)}',

                    // Accent green makes the price stand out.
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentPrice,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // Bottom Row
                  //
                  // Instead of floating over the image, the favorite
                  // button now sits beside the seller name.
                  //
                  // spaceBetween pushes the seller to the left and
                  // the heart to the far right.
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Expanded lets the seller name shrink if it's
                      // too long instead of pushing the heart off-screen.
                      Expanded(
                        child: Text(
                          product.sellerName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                      // The heart can be tapped independently of the
                      // rest of the card.
                      GestureDetector(
                        onTap: onFavoriteTap,
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,

                          size: 20,

                          color: product.isFavorite
                              ? Colors.redAccent
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}