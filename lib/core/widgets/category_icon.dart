import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/category.dart';

/// Renders a category's brand logo or its Material icon fallback.
/// Logos are disk-cached after first download and load instantly on subsequent
/// app launches without a network request.
class CategoryIcon extends StatelessWidget {
  final Category category;
  final double size;
  final Color color;

  const CategoryIcon({
    super.key,
    required this.category,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final url = category.logoUrl;
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (ctx, url) => SizedBox(width: size, height: size),
        errorWidget: (ctx, url, err) => _materialIcon(),
      );
    }
    return _materialIcon();
  }

  Widget _materialIcon() => Icon(
        IconData(category.iconCodePoint, fontFamily: category.iconFontFamily),
        color: color,
        size: size,
      );
}
