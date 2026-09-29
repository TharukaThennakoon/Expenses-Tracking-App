import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/category_spending.dart';
import '../../../expenses/presentation/utils/category_style.dart';

class CategoryBreakdownCard extends StatelessWidget {
  const CategoryBreakdownCard({
    super.key,
    required this.categories,
    this.onInsightsTap,
    this.legendCount = 4,
  });

  /// Sorted highest spend first.
  final List<CategorySpending> categories;
  final VoidCallback? onInsightsTap;
  final int legendCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'By category',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              InkWell(
                onTap: onInsightsTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'Insights',
                        style: TextStyle(
                          color: context.colors.primaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: context.colors.primaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No spending recorded this month.',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            )
          else ...[
            _SegmentedBar(categories: categories),
            const SizedBox(height: 16),
            _Legend(categories: categories.take(legendCount).toList()),
          ],
        ],
      ),
    );
  }
}

class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({required this.categories});

  final List<CategorySpending> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        children: [
          for (var i = 0; i < categories.length; i++)
            Expanded(
              flex: categories[i].amount.round(),
              child: Container(
                margin: EdgeInsets.only(
                  right: i == categories.length - 1 ? 0 : 4,
                ),
                decoration: BoxDecoration(
                  color: categories[i].category.color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.categories});

  final List<CategorySpending> categories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 24.0;
        final itemWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: 10,
          children: [
            for (final c in categories)
              SizedBox(
                width: itemWidth,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: c.category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      Formatters.wholeAmount(c.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
