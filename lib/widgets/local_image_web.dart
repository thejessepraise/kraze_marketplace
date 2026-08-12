import 'package:flutter/material.dart';

Widget buildLocalImage(
  String path, {
  required BoxFit fit,
  required ImageErrorWidgetBuilder errorBuilder,
}) {
  // image_picker on web returns a browser blob URL, which Image.network
  // can render directly.
  return Image.network(
    path,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
