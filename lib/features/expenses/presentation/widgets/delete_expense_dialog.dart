import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/expense.dart';
import 'category_icon.dart';

/// Asks the user to confirm deleting [expense]. Returns true to delete.
Future<bool> showDeleteExpenseDialog(
  BuildContext context,
  Expense expense,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => _DeleteExpenseDialog(expense: expense),
  );
  return confirmed ?? false;
}

class _DeleteExpenseDialog extends StatelessWidget {
  const _DeleteExpenseDialog({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

    return Dialog(
      backgroundColor: context.colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.dangerSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.dangerBorder),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: context.colors.danger,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete this expense?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _ExpensePreview(expense: expense),
            const SizedBox(height: 16),
            Text(
              'It will be removed from your history and this month’s total. '
              'This can’t be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.textPrimary,
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: context.colors.border),
                      shape: buttonShape,
                      textStyle: buttonText,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.danger,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: buttonShape,
                      textStyle: buttonText,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpensePreview extends StatelessWidget {
  const _ExpensePreview({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CategoryIcon(category: expense.category, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense.category.label} · ${Formatters.dayMonthYear(expense.date)}',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${context.currency} ${Formatters.amount(expense.amount)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
