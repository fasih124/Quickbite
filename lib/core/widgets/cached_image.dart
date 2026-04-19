// lib/core/widgets/cached_image.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'shimmer_box.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const CachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => ShimmerBox(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          borderRadius: borderRadius,
        ),
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          color: const Color(0xFFEEEEEE),
          child: const Icon(Icons.broken_image_outlined, color: Color(0xFFBDBDBD)),
        ),
      ),
    );
  }
}