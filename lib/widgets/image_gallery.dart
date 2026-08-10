import 'package:flutter/material.dart';
import 'product_image.dart';

/// A swipeable set of product photos with dot indicators underneath —
/// the same "swipe through the listing's photos" pattern most shopping
/// apps use for product detail pages.
///
/// WHY A FIXED AspectRatio (not just however tall each photo happens to
/// be):
/// A listing's photos can come from wildly different phone cameras and
/// crops — a tall portrait photo next to a wide landscape one. Without a
/// fixed shape, swiping between them would make the whole card resize
/// itself on every swipe, which looks broken rather than polished. Every
/// photo gets fit: BoxFit.cover into the SAME square shape instead, so
/// resolution/orientation differences between photos are invisible —
/// this is the same trick Amazon/Depop/Vinted-style listings use.
///
/// WHY StatefulWidget:
/// The dot indicator needs to know which photo is currently on screen,
/// which changes as the student swipes — that's state.
class ImageGallery extends StatefulWidget {
  final List<String> imagePaths;

  const ImageGallery({super.key, required this.imagePaths});

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // A listing with no photos at all still needs SOMETHING to show —
    // reuse ProductImage's own placeholder rather than inventing a
    // second "no image" UI here.
    final images = widget.imagePaths.isEmpty ? [''] : widget.imagePaths;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return ProductImage(imagePath: images[index]);
                },
              ),
            ),
          ),
        ),

        // Dot indicators only make sense with more than one photo — a
        // single dot would just be visual noise.
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final bool active = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
