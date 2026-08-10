import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Displays a single product's image, wherever it came from.
///
/// WHY THIS WIDGET EXISTS:
/// Until now every product image lived in assets/images/ (bundled with the
/// app), so ProductCard and ProductDetailPage could just call Image.asset
/// directly. Now that Post Item lets a student pick a photo from their own
/// device, a product's imageUrl might instead point at a photo living
/// outside the app bundle — which needs a different Image widget, and
/// (as covered below) even that answer depends on which platform we're
/// running on. Rather than duplicating this decision in three different
/// places, this widget makes it once.
///
/// HOW IT DECIDES asset VS device photo:
/// Every image bundled with the app lives under 'assets/images/', so we
/// just check for that prefix. Anything else came from image_picker.
///
/// WHY THE DEVICE-PHOTO CASE ALSO NEEDS A kIsWeb CHECK:
/// image_picker gives back a different KIND of path depending on
/// platform, and each kind needs its own Image widget:
///   - On Android/iOS/desktop, it's a real path on disk (e.g.
///     '/data/.../image123.jpg') — dart:io's File can open that, so we
///     use Image.file.
///   - On web, there IS no filesystem to read from — a browser tab can't
///     access your disk directly. image_picker instead hands back a
///     'blob:' URL, which is really a pointer to image data the browser
///     is already holding in memory for us. dart:io's File doesn't
///     understand 'blob:' URLs at all (that's the "Unsupported
///     operation" you were hitting), but Image.network does, because
///     the browser resolves that URL itself.
/// kIsWeb (from package:flutter/foundation.dart) tells us which of
/// those two situations we're in.
class ProductImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const ProductImage({super.key, required this.imagePath, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // No photo at all (e.g. a listing posted without one) — show a
    // placeholder immediately instead of trying (and failing) to load ''.
    if (imagePath.isEmpty) {
      return _placeholder(colorScheme);
    }

    final bool isBundledAsset = imagePath.startsWith('assets/');

    if (isBundledAsset) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(colorScheme),
      );
    }

    if (kIsWeb) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(colorScheme),
      );
    }

    // Otherwise, it's a real path to a file the student picked from
    // their own device's photo library.
    return Image.file(
      File(imagePath),
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(colorScheme),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

