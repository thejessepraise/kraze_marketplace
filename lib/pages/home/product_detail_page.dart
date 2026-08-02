import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/app_colors.dart';

/// ===============================================================
/// PRODUCT DETAILS PAGE
/// ===============================================================
///
/// This screen displays everything we currently know about ONE
/// product.
///
/// WHY DOES THIS PAGE EXIST?
///
/// The Home Page should only answer ONE question:
///
/// "What products are available?"
///
/// Once the user taps one product, they leave the Home Page and
/// come here to learn more about THAT specific product.
///
/// This keeps both screens focused on a single responsibility.
///
/// Home Page
///     ↓
/// Browse products
///
/// Product Details
///     ↓
/// View one product
///
/// Later we'll expand this page with:
///
/// • Description
/// • Condition
/// • Posted date
/// • Location
/// • Similar products
///
/// But for now we're only using fields that already exist inside
/// our Product model.
class ProductDetailPage extends StatelessWidget {
  final Product product;

  /// Called when the favorite heart is tapped.
  ///
  /// The Home Page owns the actual product list, so it is
  /// responsible for changing the favorite state.
  final VoidCallback? onFavoriteTap;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,

        title: const Text(
          "Product Details",
        ),

        actions: [
          IconButton(
            onPressed: onFavoriteTap,
            icon: Icon(
              product.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: product.isFavorite
                  ? Colors.redAccent
                  : colorScheme.onSurface,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =====================================================
            // PRODUCT IMAGE
            // =====================================================
            //
            // This displays the local image stored inside
            // assets/images/.
            //
            // BoxFit.cover tells Flutter:
            //
            // "Fill the entire box, even if some edges must be
            // cropped."
            //
            // This is how almost every shopping app displays
            // product photos.
            Container(
              width: double.infinity,
              height: 300,
              color: theme.cardColor,

              child: ClipRRect(
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.contain,

                  // If an image can't be found we don't want the app
                  // to crash.
                  //
                  // Instead we'll simply show a placeholder.
                  errorBuilder: (_, __, ___) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 80,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // =================================================
                  // CATEGORY
                  // =================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      product.category,

                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // TITLE
                  // =================================================
                  Text(
                    product.title,

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // PRICE
                  // =================================================
                  Text(
                    'GH₵${product.price.toStringAsFixed(2)}',

                    style: const TextStyle(
                      color: AppColors.accentPrice,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                                    const SizedBox(height: 30),

                  // =================================================
                  // SELLER SECTION
                  // =================================================
                  //
                  // Every product belongs to a seller.
                  //
                  // Right now we only know the seller's name.
                  // Later we'll add:
                  //
                  // • Profile picture
                  // • Rating
                  // • Joined date
                  // • Response time
                  //
                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor,
                      ),
                    ),

                    child: Row(
                      children: [

                        // Seller avatar
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              colorScheme.primaryContainer,

                          child: Text(
                            product.sellerName[0].toUpperCase(),

                            style: TextStyle(
                              color:
                                  colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              const Text(
                                "Seller",

                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                product.sellerName,

                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =================================================
                  // FAVORITE INFORMATION
                  // =================================================
                  //
                  // This simply tells the user whether this item
                  // is currently in their favorites.
                  //
                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor,
                      ),
                    ),

                    child: Row(
                      children: [

                        Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,

                          color: product.isFavorite
                              ? Colors.redAccent
                              : colorScheme.onSurfaceVariant,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            product.isFavorite
                                ? "This item is in your favorites."
                                : "Tap the heart above to save this item.",

                            style: TextStyle(
                              color:
                                  colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // =================================================
                  // MESSAGE SELLER BUTTON
                  // =================================================
                  //
                  // The chat system doesn't exist yet.
                  //
                  // For now this button simply tells the user
                  // that messaging will come later.
                  //
                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),

                      label: const Text(
                        "Message Seller",
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            colorScheme.primary,
                        foregroundColor:
                            colorScheme.onPrimary,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),

                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Messaging feature coming soon!",
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}