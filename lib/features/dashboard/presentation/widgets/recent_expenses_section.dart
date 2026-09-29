import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/widgets/category_icon.dart';

class RecentExpensesSection extends StatelessWidget {
  const RecentExpensesSection({
    super.key,
    required this.expenses,
    this.onSeeAll,
    this.onExpenseTap,
  });

  final List<Expense> expenses;
  final VoidCallback? onSeeAll;
  final ValueChanged<Expense>? onExpenseTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: context.colors.primaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: expenses.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No expenses yet.',
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < expenses.length; i++) ...[
                      if (i > 0) const Divider(indent: 16, endIndent: 16),
                      _ExpenseTile(
                        expense: expenses[i],
                        onTap: onExpenseTap == null
                            ? null
                            : () => onExpenseTap!(expenses[i]),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CategoryIcon(category: expense.category),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${expense.category.label} · ${Formatters.relativeDay(expense.date)}',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${context.currency} ${Formatters.amount(expense.amount)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
