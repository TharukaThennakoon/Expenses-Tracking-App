import 'package:flutter/material.dart';

import '../../domain/entities/expense_category.dart';
import '../utils/category_style.dart';

/// Rounded, tinted square showing a category's icon.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 46});

  final ExpenseCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(category.icon, color: color, size: size * 0.48),
    );
  }
}
