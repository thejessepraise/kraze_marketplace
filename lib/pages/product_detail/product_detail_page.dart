import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/app_error.dart';
import '../../services/marketplace_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/kraze_page_route.dart';
import '../../widgets/product_image.dart';
import '../chat/chat_page.dart';
import '../post_item/edit_item_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

const double _wideScreenBreakpoint = 700;

class ProductDetailPage extends StatelessWidget {
  final Product product;
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

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isSeller = currentUser?.uid == product.sellerId;

    if (isSeller) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    KrazePageRoute(builder: (_) => EditItemPage(product: product)),
                  );
                  if (updated == true && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Listing'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 52,
            height: 52,
            child: IconButton(
              onPressed: () => _confirmDelete(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete Listing',
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
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
              onPressed: () async {
                try {
                  final conversation = await marketplaceStore.openConversation(
                    product,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    KrazePageRoute(
                      builder: (_) => ChatPage(conversation: conversation),
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(userMessage(error))),
                  );
                }
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Message Seller'),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
            tooltip: 'Favorite',
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await marketplaceStore.deleteListing(product.id);
        if (context.mounted) Navigator.of(context).pop();
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userMessage(error))),
          );
        }
      }
    }
  }
}
