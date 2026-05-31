import 'package:flutter/material.dart';
import '../../data/models/category.dart';

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
  Widget build(BuildContext context) => Icon(
        IconData(category.iconCodePoint, fontFamily: category.iconFontFamily),
        color: color,
        size: size,
      );
}
