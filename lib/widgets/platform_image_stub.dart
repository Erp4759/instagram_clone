import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlatformImage extends StatelessWidget {
  final String src;
  final BoxFit fit;
  final double? width;
  final double? height;
  const PlatformImage(this.src,
      {super.key, this.fit = BoxFit.cover, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if (src.startsWith('http')) {
      return CachedNetworkImage(
          imageUrl: src, fit: fit, width: width, height: height);
    }
    // On web, local file paths are not accessible — show a fallback.
    return const Center(child: Icon(Icons.broken_image));
  }
}
