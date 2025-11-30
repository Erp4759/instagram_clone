import 'dart:io';

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
    try {
      final file = File(src);
      return Image.file(file, fit: fit, width: width, height: height);
    } catch (e) {
      return const Center(child: Icon(Icons.broken_image));
    }
  }
}
