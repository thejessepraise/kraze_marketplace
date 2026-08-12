import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Displays a single product's image, wherever it came from.
/// 
/// Supported formats:
/// - Assets: 'assets/images/...'
/// - Network: 'http://...' or 'https://...'
/// - Data URI (Base64): 'data:image/...' (Used for free syncing without Storage)
/// - Local File: '/path/to/file' (or 'blob:...' on Web)
class ProductImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const ProductImage({super.key, required this.imagePath, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imagePath.isEmpty) {
      return _placeholder(colorScheme);
    }

    // 1. Handle Base64 Data URIs (the "Data Sync" approach)
    if (imagePath.startsWith('data:image')) {
      try {
        final base64String = imagePath.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: fit,
          errorBuilder: (_, __, ___) => _placeholder(colorScheme),
        );
      } catch (e) {
        return _placeholder(colorScheme);
      }
    }

    // 2. Handle Bundled Assets
    final bool isBundledAsset = imagePath.startsWith('assets/');
    if (isBundledAsset) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(colorScheme),
      );
    }

    // 3. Handle Network URLs & Web Blobs
    final bool isNetworkUrl =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    
    // image_picker on Web uses 'blob:' URLs for the local preview
    final bool isWebBlob = kIsWeb && imagePath.startsWith('blob:');

    if (isNetworkUrl || isWebBlob) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(colorScheme),
      );
    }

    // 4. Handle Local File Paths (Android/iOS)
    if (!kIsWeb) {
      return Image.file(
        File(imagePath),
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(colorScheme),
      );
    }

    return _placeholder(colorScheme);
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
