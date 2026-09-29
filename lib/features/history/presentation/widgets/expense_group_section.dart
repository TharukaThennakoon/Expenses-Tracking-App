import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/swipe_action_tile.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/widgets/category_icon.dart';
import '../../domain/entities/expense_history.dart';

class ExpenseGroupSection extends StatelessWidget {
  const ExpenseGroupSection({
    super.key,
    required this.group,
    required this.now,
    required this.openTile,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseGroup group;
  final DateTime now;
  final ValueNotifier<Object?> openTile;
  final ValueChanged<Expense> onEdit;
  final ValueChanged<Expense> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Row(
            children: [
              Expanded(
                child: group.date == null
                    ? const Text(
                        'Highest amount first',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      )
                    : _DayLabel(date: group.date!, now: now),
              ),
              Text(
                '${context.currency} ${Formatters.amount(group.total)}',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < group.expenses.length; i++) ...[
                if (i > 0) const Divider(indent: 16, endIndent: 16),
                SwipeActionTile(
                  key: ValueKey(group.expenses[i].id),
                  id: group.expenses[i].id,
                  openTile: openTile,
                  onTap: () => onEdit(group.expenses[i]),
                  actions: [
                    SwipeAction(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      color: AppColors.edit,
                      onTap: () => onEdit(group.expenses[i]),
                    ),
                    SwipeAction(
                      label: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      color: context.colors.danger,
                      onTap: () => onDelete(group.expenses[i]),
                    ),
                  ],
                  child: _HistoryExpenseTile(
                    expense: group.expenses[i],
                    // Rows aren't grouped by day, so show each row's date.
                    date: group.date == null
                        ? Formatters.relativeDay(
                            group.expenses[i].date,
                            now: now,
                          )
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel({required this.date, required this.now});

  final DateTime date;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final daysAgo = Formatters.daysAgo(date, now: now);
    final relative = switch (daysAgo) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => null,
    };
    final bold = TextStyle(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 15,
    );
    return Text.rich(
      TextSpan(
        children: relative == null
            ? [TextSpan(text: Formatters.weekdayDayMonth(date), style: bold)]
            : [
                TextSpan(text: relative, style: bold),
                TextSpan(
                  text: ' · ${Formatters.weekdayDayMonth(date)}',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
      ),
    );
  }
}

class _HistoryExpenseTile extends StatelessWidget {
  const _HistoryExpenseTile({required this.expense, this.date});

  final Expense expense;

  /// Shown in the subtitle when set.
  final String? date;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      expense.category.label,
      ?date,
      if (expense.note case final note? when note.isNotEmpty) note,
    ].join(' · ');

    return Padding(
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
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            Formatters.amount(expense.amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
