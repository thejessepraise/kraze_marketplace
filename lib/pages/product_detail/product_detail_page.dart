import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/marketplace_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/kraze_page_route.dart';
import '../../widgets/product_image.dart';
import '../chat/chat_page.dart';

/// ===============================================================
/// PRODUCT DETAILS PAGE
/// ===============================================================
///
/// Shows everything we currently know about ONE product: image,
/// category, title, price, seller, description, and actions
/// (Message Seller as the primary action, Favorite as a smaller
/// secondary one).
///
/// WHY StatelessWidget (again):
/// A previous version of this page briefly held a quantity stepper for
/// an "Add to Cart" flow, which needed local state (StatefulWidget).
/// We removed that — Kraze is a chat-based, peer-to-peer marketplace
/// (students messaging each other to arrange a sale), not a shop with
/// a cart/checkout system — so there's nothing left on this page that
/// changes while it's open. StatelessWidget is the simpler, correct
/// choice again.
///
/// WHY A BREAKPOINT CONSTANT:
/// `_wideScreenBreakpoint` is the screen width (in logical pixels) above
/// which we treat the device as "desktop/web-sized" rather than "phone
/// -sized". Using one named constant means adjusting the switch-over
/// point later only requires changing it in this one spot.
const double _wideScreenBreakpoint = 700;

class ProductDetailPage extends StatelessWidget {
  final Product product;

  /// Called when the favorite button is tapped.
  /// The Home Page owns the actual product list, so it is
  /// responsible for actually changing the favorite state.
  final VoidCallback? onFavoriteTap;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        title: const Text('Product Details'),
      ),

      // LayoutBuilder tells us how much horizontal space is actually
      // available RIGHT NOW, so we can pick a layout that fits it.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideScreenBreakpoint;
          return isWide
              ? _buildWideLayout(context)
              : _buildNarrowLayout(context);
        },
      ),
    );
  }

  // =================================================================
  // LAYOUT: PHONE (narrow) — image on top, details below, scrollable.
  // =================================================================
  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          const SizedBox(height: 24),
          ..._buildDetailsColumn(context),
        ],
      ),
    );
  }

  // =================================================================
  // LAYOUT: DESKTOP/WEB (wide) — image on the left, details on the
  // right, side by side.
  // =================================================================
  Widget _buildWideLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildImageSection(context, height: 480)),
          const SizedBox(width: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildDetailsColumn(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The shared right-hand-side (or below-image) content, used by both
  /// layouts so we don't duplicate this list in two places.
  List<Widget> _buildDetailsColumn(BuildContext context) {
    return [
      _buildProductInfo(context),
      const SizedBox(height: 20),
      _buildSellerCard(context),
      const SizedBox(height: 20),
      _buildDescriptionSection(context),
      const SizedBox(height: 28),
      _buildActions(context),
    ];
  }

  // =================================================================
  // IMAGE SECTION
  // =================================================================
  Widget _buildImageSection(BuildContext context, {double height = 340}) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ProductImage(imagePath: product.imageUrl, fit: BoxFit.contain),
      ),
    );
  }

  // =================================================================
  // PRODUCT INFO: category dot, title, price, divider.
  // =================================================================
  Widget _buildProductInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              product.category,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          product.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'GH₵${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.accentPrice,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: theme.dividerColor),
      ],
    );
  }

  // =================================================================
  // SELLER CARD
  // =================================================================
  Widget _buildSellerCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seller',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
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
                const SizedBox(height: 2),
                Text(
                  'Student Seller',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // DESCRIPTION SECTION
  // =================================================================
  Widget _buildDescriptionSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasDescription = product.description.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (hasDescription)
          Text(
            product.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          Text(
            'No description has been added yet.',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            "The seller hasn't provided additional details.",
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  // =================================================================
  // ACTIONS: Message Seller (primary, full width) + Favorite (small,
  // secondary — matching the "smaller favorite button" you asked for).
  // =================================================================
  //
  // WHY MESSAGE IS PRIMARY HERE (not Add to Cart):
  // Kraze is chat-first — a buyer and seller message each other to
  // negotiate price, arrange meetup, etc. There's no cart/checkout
  // system, so the one clear "next step" from this page is starting a
  // conversation, which is why it gets the big, prominent button.
  // =================================================================
  // ACTIONS: Message Seller + Favorite
  // =================================================================
  //
  // Both actions are placed on the same row.
  //
  // Message Seller is the primary action, so it gets most of the
  // available width.
  //
  // Favorite is secondary, so it gets a smaller square button.
  //
  // This makes the two actions feel like a single action area instead
  // of having the favorite button floating underneath the main button.
  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // =============================================================
        // MESSAGE SELLER BUTTON
        // =============================================================
        //
        // Expanded tells Flutter to give this button all the remaining
        // horizontal space after the Favorite button is placed.
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              onPressed: () {
                final conversation = marketplaceStore.openConversation(product);
                Navigator.of(context).push(
                  KrazePageRoute(
                    builder: (_) => ChatPage(conversation: conversation),
                  ),
                );
              },

              icon: const Icon(Icons.chat_bubble_outline),

              label: const Text('Message Seller'),
            ),
          ),
        ),

        // Space between the two buttons.
        const SizedBox(width: 12),

        // =============================================================
        // FAVORITE BUTTON
        // =============================================================
        //
        // Unlike the Message Seller button, this is only an icon.
        //
        // A fixed width keeps it compact and prevents it from taking
        // unnecessary space.
        SizedBox(
          width: 52,
          height: 52,
          child: IconButton(
            onPressed: () {
              marketplaceStore.toggleFavorite(product.id);
              onFavoriteTap?.call();
            },

            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,

              size: 23,

              color: product.isFavorite
                  ? Colors.redAccent
                  : colorScheme.onSurfaceVariant,
            ),

            // Useful on desktop/web when the user hovers over
            // the button.
            tooltip: 'Favorite',
          ),
        ),
      ],
    );
  }
}
