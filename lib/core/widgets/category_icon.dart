import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/category.dart';

/// Renders a category's brand logo or its Material icon fallback.
///
/// Resolution order:
///   1. category.logoUrl (set for seeded brand categories)
///   2. Auto-derived from the first word of the name as a .com domain
///      (only for custom/user-created categories)
///   3. Material icon fallback (on network error or if no URL applies)
///
/// Logos are disk-cached after first download via cached_network_image.
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

  String? get _effectiveUrl {
    if (category.logoUrl != null) return category.logoUrl;
    if (!category.isCustom) return null; // default system categories use Material icons
    final firstWord = category.name.trim().split(' ').first.toLowerCase();
    if (firstWord.isEmpty) return null;
    return 'https://www.google.com/s2/favicons?sz=128&domain=$firstWord.com';
  }

  @override
  Widget build(BuildContext context) {
    final url = _effectiveUrl;
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
