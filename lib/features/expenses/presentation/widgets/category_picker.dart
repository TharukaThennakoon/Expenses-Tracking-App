import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../domain/entities/expense_category.dart';
import '../utils/category_style.dart';

/// Four-column grid of category tiles; at most one is selected.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// Null when nothing has been picked yet.
  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory> onChanged;

  static const int _columns = 4;
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - _gap * (_columns - 1)) / _columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final category in context.categories)
              SizedBox(
                width: width,
                child: _CategoryTile(
                  category: category,
                  selected: category == selected,
                  onTap: () => onChanged(category),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    final radius = BorderRadius.circular(16);
    return Semantics(
      selected: selected,
      button: true,
      label: category.label,
      excludeSemantics: true,
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.14)
            : context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? color : context.colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colors.surface
                        : color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, size: 19, color: color),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? color : context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
