import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/review.dart';
import '../../services/app_error.dart';
import '../../services/marketplace_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/kraze_page_route.dart';
import '../../widgets/product_image.dart';
import '../../widgets/seller_avatar.dart';
import '../chat/chat_page.dart';
import '../post_item/edit_item_page.dart';
import '../profile/seller_profile_page.dart';
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
    return ListenableBuilder(
      listenable: marketplaceStore,
      builder: (context, _) {
        final currentProduct = marketplaceStore.products.firstWhere(
          (p) => p.id == product.id,
          orElse: () => product,
        );

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
                  ? _buildWideLayout(context, currentProduct)
                  : _buildNarrowLayout(context, currentProduct);
            },
          ),
        );
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context, Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context, product),
          const SizedBox(height: 24),
          ..._buildDetailsColumn(context, product),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, Product product) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildImageSection(context, product, height: 480)),
          const SizedBox(width: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildDetailsColumn(context, product),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailsColumn(BuildContext context, Product product) {
    return [
      _buildProductInfo(context, product),
      const SizedBox(height: 20),
      _buildSellerCard(context, product),
      const SizedBox(height: 20),
      _buildDescriptionSection(context, product),
      const SizedBox(height: 20),
      _buildReviewsSection(context, product),
      const SizedBox(height: 28),
      _buildActions(context, product),
    ];
  }

  Widget _buildImageSection(
    BuildContext context,
    Product product, {
    double height = 340,
  }) {
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

  Widget _buildProductInfo(BuildContext context, Product product) {
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
              product.category.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                product.condition,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            if (product.status == 'sold') ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SOLD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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
        Row(
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'GH₵${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentPrice,
                  ),
                ),
              ),
            ),
            if (product.reviewCount > 0) ...[
              const SizedBox(width: 16),
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                product.averageRating.toStringAsFixed(1),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                ' (${product.reviewCount})',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: theme.dividerColor),
      ],
    );
  }

  Widget _buildSellerCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          KrazePageRoute(
            builder: (_) => SellerProfilePage(
              sellerId: product.sellerId,
              sellerName: product.sellerName,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            SellerAvatar(
              name: product.sellerName,
              uid: product.sellerId,
              radius: 24,
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
                  if (product.sellerLocation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.sellerLocation,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
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
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Product product) {
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

  Widget _buildReviewsSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => _showAddReviewDialog(context, product),
              child: const Text('Add Review'),
            ),
          ],
        ),
        StreamBuilder<List<Review>>(
          stream: marketplaceStore.watchReviews(product.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final reviews = snapshot.data!;
            if (reviews.isEmpty) {
              return Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length > 3 ? 3 : reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SellerAvatar(
                            name: review.userName,
                            uid: review.userId,
                            radius: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              review.userName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...List.generate(5, (i) {
                            return Icon(
                              Icons.star,
                              size: 12,
                              color: i < review.rating
                                  ? Colors.amber
                                  : theme.dividerColor,
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        review.comment,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Product product) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isSeller = currentUser?.uid == product.sellerId;

    if (isSeller) {
      return Column(
        children: [
          Row(
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
                        KrazePageRoute(
                          builder: (_) => EditItemPage(product: product),
                        ),
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
                  onPressed: () => _confirmDelete(context, product),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Delete Listing',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: product.status == 'sold'
                      ? colorScheme.primary
                      : Colors.redAccent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                foregroundColor: product.status == 'sold'
                    ? colorScheme.primary
                    : Colors.redAccent,
              ),
              onPressed: () => marketplaceStore.toggleSoldStatus(
                product.id,
                product.status,
              ),
              icon: Icon(
                product.status == 'sold'
                    ? Icons.replay_outlined
                    : Icons.check_circle_outline,
              ),
              label: Text(
                product.status == 'sold' ? 'Mark as Active' : 'Mark as Sold',
              ),
            ),
          ),
        ],
      );
    }

    if (product.status == 'sold') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(
              'This item has been sold.',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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

  void _showAddReviewDialog(BuildContext context, Product product) {
    double selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed:
                        () => setState(() => selectedRating = index + 1.0),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await marketplaceStore.addReview(
                    productId: product.id,
                    rating: selectedRating,
                    comment: commentController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(userMessage(e))),
                    );
                  }
                }
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
