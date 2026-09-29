import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/presentation/controllers/categories_controller.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/presentation/utils/category_style.dart';
import '../../domain/entities/history_filter.dart';

class HistoryFilterChips extends StatelessWidget {
  const HistoryFilterChips({
    super.key,
    required this.filter,
    required this.now,
    required this.onDateTap,
    required this.onAllTap,
    required this.onRemoveCategory,
  });

  final HistoryFilter filter;
  final DateTime now;
  final VoidCallback onDateTap;
  final VoidCallback onAllTap;
  final ValueChanged<ExpenseCategory> onRemoveCategory;

  Set<ExpenseCategory> get categories => filter.categories;

  String get _dateLabel {
    String month(DateTime d) => d.year == now.year
        ? Formatters.monthName(d)
        : '${Formatters.shortMonth(d)} ${d.year}';

    return switch (filter.preset) {
      DateRangePreset.thisMonth ||
      DateRangePreset.lastMonth => month(filter.from),
      DateRangePreset.last3Months => 'Last 3 months',
      DateRangePreset.custom =>
        filter.from == filter.to
            ? Formatters.dayMonth(filter.from)
            : '${Formatters.dayMonth(filter.from)} – ${Formatters.dayMonth(filter.to)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = categories.isEmpty;
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(
            label: _dateLabel,
            leading: Icons.calendar_today_outlined,
            background: context.colors.primary,
            foreground: Colors.white,
            border: context.colors.primary,
            onTap: onDateTap,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'All',
            background: context.colors.surface,
            foreground: context.colors.textPrimary,
            border: allSelected
                ? context.colors.primaryText
                : context.colors.border,
            borderWidth: allSelected ? 1.5 : 1,
            onTap: onAllTap,
          ),
          for (final category in context.categories)
            if (categories.contains(category)) ...[
              const SizedBox(width: 8),
              _Chip(
                label: category.label,
                trailing: Icons.close_rounded,
                background: category.color.withValues(alpha: 0.12),
                foreground: category.color,
                border: category.color.withValues(alpha: 0.35),
                onTap: () => onRemoveCategory(category),
                semanticLabel: 'Remove ${category.label} filter',
              ),
            ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
    required this.onTap,
    this.leading,
    this.trailing,
    this.borderWidth = 1,
    this.semanticLabel,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color border;
  final double borderWidth;
  final VoidCallback onTap;
  final IconData? leading;
  final IconData? trailing;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border, width: borderWidth),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  Icon(leading, size: 17, color: foreground),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailing, size: 16, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
