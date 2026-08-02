import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/app_colors.dart';

/// ===============================================================
/// PRODUCT DETAILS PAGE (v2)
/// ===============================================================
///
/// Shows everything we currently know about ONE product: image,
/// category, title, price, seller, description, and actions
/// (Favorite / Message Seller).
///
/// WHY THIS FILE MOVED FOLDERS:
/// It used to live inside pages/home/ alongside home_page.dart. But this
/// page isn't really "part of" Home — Home just happens to be one place
/// that navigates here. Giving it its own pages/product_detail/ folder
/// makes the project structure describe the app's features rather than
/// which screen happens to link to which.
///
/// WHY A BREAKPOINT CONSTANT:
/// `_wideScreenBreakpoint` is the screen width (in logical pixels) above
/// which we consider the device "desktop/web-sized" rather than "phone
/// -sized". We use ONE named constant instead of typing the number 700
/// directly in the layout logic below, so if you ever want to adjust when
/// the layout switches, you only change it in one place.
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
        // No actions/favorite icon here anymore — favorite now lives in
        // the bottom action bar alongside Message Seller, matching the
        // "Favorite | Message" pattern used by most marketplace apps.
      ),

      // LayoutBuilder tells us how much horizontal space is actually
      // available RIGHT NOW, so we can pick a layout that fits it.
      // WHY LayoutBuilder (not just MediaQuery.of(context).size.width):
      // LayoutBuilder reacts to the space this specific widget has been
      // given, which is more reliable if this page is ever shown inside
      // something narrower than the full screen (e.g. a split view).
      // For a full-screen page like this, either approach works, but
      // LayoutBuilder is the more broadly correct habit to build.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideScreenBreakpoint;
          return isWide
              ? _buildWideLayout(context)
              : _buildNarrowLayout(context);
        },
      ),

      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  // =================================================================
  // LAYOUT: PHONE (narrow) — image on top, details below, scrollable.
  // =================================================================
  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          const SizedBox(height: 24),
          _buildProductInfo(context),
          const SizedBox(height: 20),
          _buildSellerCard(context),
          const SizedBox(height: 20),
          _buildDescriptionSection(context),
        ],
      ),
    );
  }

  // =================================================================
  // LAYOUT: DESKTOP/WEB (wide) — image on the left, details on the
  // right, side by side. This is what fixes the awkward empty space
  // you saw when viewing the phone layout in a wide Chrome window.
  // =================================================================
  Widget _buildWideLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image takes the left half of the screen.
          Expanded(
            child: _buildImageSection(context, height: 480),
          ),
          const SizedBox(width: 32),
          // Details take the right half, and scroll independently if
          // the description is long.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(context),
                  const SizedBox(height: 20),
                  _buildSellerCard(context),
                  const SizedBox(height: 20),
                  _buildDescriptionSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // IMAGE SECTION
  // =================================================================
  //
  // WHY A CARD BEHIND THE IMAGE:
  // BoxFit.contain (see below) means the image may not fill the whole
  // box — it can leave empty space on the sides or top/bottom if the
  // photo's proportions don't match the box. Putting a matching
  // theme.cardColor behind it means that empty space reads as
  // intentional "framing" rather than a layout bug.
  Widget _buildImageSection(BuildContext context, {double height = 340}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16), // breathing room around the image
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          product.imageUrl,
          // BoxFit.contain shows the WHOLE product with nothing cropped
          // off — important on a Detail page, where the customer is
          // deciding whether to buy this exact item.
          fit: BoxFit.contain,
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
        // A small colored dot + category name — quieter than a full
        // filled pill, so it doesn't compete visually with the title
        // right below it.
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
          // A generic person icon (rather than the seller's initial)
          // reads more like "this is a Seller card", matching the
          // 👤 icon in the design reference.
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              color: colorScheme.onPrimaryContainer,
            ),
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
  //
  // Shows the seller's real description now that Product has that
  // field. If a seller left it blank (see sampleProducts — the PS4
  // controller has no description on purpose, as a test case), we
  // fall back to a friendly placeholder instead of showing nothing.
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
              height: 1.5, // line spacing, easier to read for longer text
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          Text(
            'No description has been added yet.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
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
  // BOTTOM ACTION BAR: Favorite + Message Seller, side by side.
  // =================================================================
  Widget _buildBottomActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Favorite — an OutlinedButton (border only, no fill) so it
            // reads as the SECONDARY action next to Message Seller.
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: theme.dividerColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onFavoriteTap,
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: product.isFavorite ? Colors.redAccent : null,
                ),
                label: const Text('Favorite'),
              ),
            ),
            const SizedBox(width: 12),
            // Message Seller — the PRIMARY action, filled with the
            // theme's primary color so it's the most visually prominent
            // button on the screen.
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // Will open chat_detail_page.dart once that screen
                  // exists.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Messaging feature coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}